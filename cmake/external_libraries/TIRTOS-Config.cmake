# Pulls in the tirtos_config INTERFACE target and pre-built libraries.
# This means any caller of add_tirtos_config() automatically has access
# to all TIRTOS paths without needing a separate include().
include("${CMAKE_CURRENT_LIST_DIR}/TIRTOS-Paths.cmake")

# ─── add_tirtos_config() ──────────────────────────────────────────────────────
# Runs XDCtools Configuro on a .cfg file and wires the generated linker.cmd
# and compiler.opt into the given target.
#
# Usage:
#   add_tirtos_config(<target> <path/to/app.cfg>)
#
# Only call this from the top-level application CMakeLists.txt — not from
# library subdirectories.
# ─────────────────────────────────────────────────────────────────────────────

function(add_tirtos_config TARGET CFG_FILE)
    if(NOT TI_XDC_XS)
        message(FATAL_ERROR "add_tirtos_config called, but TI_XDC_XS is not defined.")
    endif()

    set(CONFIG_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/configPkg")
    set(CC26XXWARE_ROOT "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272")

    # ── Pull include dirs and defines from the target ─────────────────────────
    get_target_property(TARGET_INCLUDES ${TARGET} INCLUDE_DIRECTORIES)
    if(NOT TARGET_INCLUDES)
        set(TARGET_INCLUDES "")
    endif()

# Only pass defines that Configuro actually needs for BIOS configuration
set(XDC_CONFIGURO_DEFS
    "USE_ICALL"
    "ICALL_MAX_NUM_TASKS=3"
    "ICALL_MAX_NUM_ENTITIES=6"
    "POWER_SAVING"
    "xdc_runtime_Assert_DISABLE_ALL"
    "xdc_runtime_Log_DISABLE_ALL"
)

foreach(DEF IN LISTS XDC_CONFIGURO_DEFS)
    list(APPEND XDC_COMPILE_OPTS_LIST "--define=${DEF}")
endforeach()

    # ── Build compileOptions string ───────────────────────────────────────────
    set(XDC_COMPILE_OPTS_LIST
        "-mv7M3"
        "--code_state=16"
        "-me"
        "-Ooff"
        "--opt_for_speed=0"
        "--abi=eabi"
        "--c99"
        "--gcc"
        "--diag_suppress=48"
        "--diag_warning=225"
    )

    foreach(INC IN LISTS TARGET_INCLUDES)
        list(APPEND XDC_COMPILE_OPTS_LIST "--include_path=${INC}")
    endforeach()

    list(APPEND XDC_COMPILE_OPTS_LIST
        "--include_path=${TI_CGT_ROOT}/include"
        "--include_path=${CC26XXWARE_ROOT}"
    )

    foreach(DEF IN LISTS TARGET_DEFS)
        list(APPEND XDC_COMPILE_OPTS_LIST "--define=${DEF}")
    endforeach()

    list(JOIN XDC_COMPILE_OPTS_LIST " " XDC_COMPILE_OPTS_STRING)

    # ── XDC package path ──────────────────────────────────────────────────────
    set(FULL_XDC_PATH
        "${TIRTOS_ROOT}/packages"
        "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages"
        "${TIRTOS_ROOT}/products/bios_6_46_01_38/packages"
        "${TIRTOS_ROOT}/products/uia_2_01_00_01/packages"
    )
    list(JOIN FULL_XDC_PATH ";" XDC_PATH_STRING)

    # ── Write the cmake wrapper script ────────────────────────────────────────
    # This is generated into the build directory at configure time.
    # It exists solely to invoke xs without going through /bin/sh,
    # which would split the semicolon-separated --xdcpath on the shell.
    set(CONFIGURO_SCRIPT "${CONFIG_OUT_DIR}/run_configuro.cmake")
    file(MAKE_DIRECTORY "${CONFIG_OUT_DIR}")
    file(WRITE "${CONFIGURO_SCRIPT}" "
execute_process(
    COMMAND \"${TI_XDC_XS}\"
            \"--xdcpath=${XDC_PATH_STRING}\"
            xdc.tools.configuro
            -c \"${TI_CGT_ROOT}\"
            -t ti.targets.arm.elf.M3
            -p ti.platforms.simplelink:CC2640F128
            -r release
            \"--compileOptions=${XDC_COMPILE_OPTS_STRING}\"
            -o \"${CONFIG_OUT_DIR}\"
            \"${CMAKE_CURRENT_SOURCE_DIR}/${CFG_FILE}\"
    WORKING_DIRECTORY \"${CMAKE_CURRENT_BINARY_DIR}\"
    RESULT_VARIABLE result
)
if(NOT result EQUAL 0)
    message(FATAL_ERROR \"Configuro failed with status: \${result}\")
endif()
")

    # ── Custom command invokes the wrapper script via cmake -P ────────────────
    add_custom_command(
        OUTPUT "${CONFIG_OUT_DIR}/linker.cmd" "${CONFIG_OUT_DIR}/compiler.opt"
        COMMAND ${CMAKE_COMMAND} -P "${CONFIGURO_SCRIPT}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${CFG_FILE}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Running XDCtools Configuro on ${CFG_FILE}"
    )

    add_custom_target(${TARGET}_tirtos_config
        DEPENDS "${CONFIG_OUT_DIR}/linker.cmd" "${CONFIG_OUT_DIR}/compiler.opt"
    )
    add_dependencies(${TARGET} ${TARGET}_tirtos_config)

    # ── Wire generated artifacts into the target ──────────────────────────────
    target_link_options(${TARGET} PRIVATE
        "-i${CONFIG_OUT_DIR}"
        "-l${CONFIG_OUT_DIR}/linker.cmd"
    )
    target_compile_options(${TARGET} PRIVATE
        "@${CONFIG_OUT_DIR}/compiler.opt"
    )
    target_include_directories(${TARGET} PRIVATE
        "${CONFIG_OUT_DIR}"
        "${CONFIG_OUT_DIR}/package/cfg"
    )

endfunction()