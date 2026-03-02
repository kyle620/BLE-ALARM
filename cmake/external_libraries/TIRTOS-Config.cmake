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
        message(FATAL_ERROR "add_tirtos_config called, but TI_XDC_XS is not defined. Is the toolchain loaded?")
    endif()

    set(CONFIG_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/configPkg")
    set(CC26XXWARE_ROOT "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272")

    # Build compile options string for Configuro — must match the compiler
    # include paths so XDC can resolve the same headers armcl sees.
    set(XDC_COMPILE_OPTS
        "--include_path=${CC26XXWARE_ROOT}"
        "--include_path=${TI_CGT_ROOT}/include"
    )
    list(JOIN XDC_COMPILE_OPTS " " XDC_COMPILE_OPTS_STRING)

    # XDC package path — order matters: BIOS first, then Drivers, then XDC
    set(FULL_XDC_PATH
        "${TIRTOS_ROOT}/packages"
        "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages"
        "${TIRTOS_ROOT}/products/bios_6_46_01_38/packages"
        "${TIRTOS_ROOT}/products/uia_2_01_00_01/packages"
        "${XDC_ROOT}/packages"
    )
    list(JOIN FULL_XDC_PATH ";" XDC_PATH_STRING)

    # ── Run Configuro ─────────────────────────────────────────────────────────
    add_custom_command(
        OUTPUT "${CONFIG_OUT_DIR}/linker.cmd" "${CONFIG_OUT_DIR}/compiler.opt"
        COMMAND "${TI_XDC_XS}"
                "--xdcpath=${XDC_PATH_STRING}"
                xdc.tools.configuro
                -c "${TI_CGT_ROOT}"
                -t ti.targets.arm.elf.M3
                -p ti.platforms.simplelink:CC2650F128
                --compileOptions "${XDC_COMPILE_OPTS_STRING}"
                -o "${CONFIG_OUT_DIR}"
                "${CMAKE_CURRENT_SOURCE_DIR}/${CFG_FILE}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${CFG_FILE}"
        COMMENT "Running XDCtools Configuro on ${CFG_FILE}"
        VERBATIM
    )

    add_custom_target(${TARGET}_tirtos_config
        DEPENDS "${CONFIG_OUT_DIR}/linker.cmd" "${CONFIG_OUT_DIR}/compiler.opt"
    )
    add_dependencies(${TARGET} ${TARGET}_tirtos_config)

    # ── Wire generated artifacts into the target ──────────────────────────────
    target_link_options(${TARGET} PRIVATE
        "-i${CONFIG_OUT_DIR}"           # linker search path for configPkg
        "${CONFIG_OUT_DIR}/linker.cmd"  # generated linker command file
    )
    target_compile_options(${TARGET} PRIVATE
        "@${CONFIG_OUT_DIR}/compiler.opt"  # generated macros/includes
    )
    target_include_directories(${TARGET} PRIVATE
        "${CONFIG_OUT_DIR}"
        "${CONFIG_OUT_DIR}/package/cfg"
    )

endfunction()
