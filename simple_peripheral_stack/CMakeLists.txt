cmake_minimum_required(VERSION 3.28)

project(simple_peripheral_stack VERSION 1.0.0 LANGUAGES C)

include_guard(GLOBAL)

# ─── Shared cmake modules ─────────────────────────────────────────────────────
# These live in the workspace-level cmake/ directory, shared by both the stack
# and app projects. Neither project owns them.
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/logic_modules/cortex-m3.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/logic_modules/cc2650-ti-cgt.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/external_libraries/TIRTOS-Paths.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/tools/frontier.cmake")


# ─── SDK Root ─────────────────────────────────────────────────────────────────
# The SDK is a plain source tree with no CMakeLists.txt. We point into it
# explicitly — mirroring exactly what the CCS .project file does.
set(SDK_ROOT "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/src"
    CACHE PATH "Path to BLE SDK src directory")

# ─── Explicit Source List ─────────────────────────────────────────────────────
# This list mirrors the CCS simple_peripheral_cc2650em_stack .project file
# exactly. Do not use GLOB here — CCS hand-picks these files per example,
# and the SDK contains many files for other roles/boards that must be excluded.
set(STACK_SOURCES
    # ── HAL ──────────────────────────────────────────────────────────────────
    "${SDK_ROOT}/components/hal/src/common/hal_assert.c"
    "${SDK_ROOT}/components/hal/src/target/_common/hal_flash_wrapper.c"
    "${SDK_ROOT}/components/hal/src/target/_common/hal_rtc_wrapper.c"
    "${SDK_ROOT}/components/hal/src/target/_common/hal_trng_wrapper.c"
    "${SDK_ROOT}/components/hal/src/target/_common/cc26xx/mb_patch.c"

    # ── OSAL ─────────────────────────────────────────────────────────────────
    "${SDK_ROOT}/components/osal/src/common/osal.c"
    "${SDK_ROOT}/components/osal/src/common/osal_bufmgr.c"
    "${SDK_ROOT}/components/osal/src/common/osal_cbtimer.c"
    "${SDK_ROOT}/components/osal/src/common/osal_clock.c"
    "${SDK_ROOT}/components/osal/src/common/osal_memory_icall.c"
    "${SDK_ROOT}/components/osal/src/common/osal_pwrmgr.c"
    "${SDK_ROOT}/components/osal/src/common/osal_timers.c"
    "${SDK_ROOT}/components/osal/src/mcu/cc26xx/osal_snv_wrapper.c"

    # ── ICall / BLE Dispatch ──────────────────────────────────────────────────
    "${SDK_ROOT}/icall/stack/ble_dispatch.c"
    "${SDK_ROOT}/icall/stack/ble_user_config.c"

    # ── Common Stack Startup ──────────────────────────────────────────────────
    "${SDK_ROOT}/common/cc26xx/icall_startup.c"
    "${SDK_ROOT}/common/cc26xx/onboard.c"
    "${SDK_ROOT}/common/cc26xx/npi/stack/npi.c"

    # ── Host ─────────────────────────────────────────────────────────────────
    "${SDK_ROOT}/host/gattservapp_util.c"
    "${SDK_ROOT}/host/sm_ecc.c"

    # ── ROM Jump Table ────────────────────────────────────────────────────────
    "${SDK_ROOT}/rom/rom_jt.c"

    # ── Profiles (Peripheral Role) ────────────────────────────────────────────
    "${SDK_ROOT}/profiles/roles/gap.c"
    "${SDK_ROOT}/profiles/roles/gapbondmgr.c"

    # ── App-specific OSAL init ────────────────────────────────────────────────
    # This file is peripheral-specific. In CCS it lives under
    # src/examples/simple_peripheral/cc26xx/stack/ and is part of the stack
    # project, not the app project. We keep it here for the same reason.
    "${CMAKE_CURRENT_LIST_DIR}/src/osal_icall_ble.c"
)

# ─── Stack Library Target ─────────────────────────────────────────────────────
add_executable(${PROJECT_NAME} ${STACK_SOURCES})

# ─── Include Directories ─────────────────────────────────────────────────────
# These mirror the include paths from the CCS project, plus the parent-of-inc
# entries needed for headers included as "inc/foo.h".
target_include_directories(${PROJECT_NAME} PUBLIC
    # BLE core public headers
    "${SDK_ROOT}/inc"
    "${SDK_ROOT}/controller/cc26xx/inc"

    # COMMON CC26xx
    "${SDK_ROOT}/common/cc26xx"
    "${SDK_ROOT}/common/cc26xx/time"

    # HAL
    "${SDK_ROOT}/components/hal/src/inc"
    "${SDK_ROOT}/components/hal/src/target/_common"
    "${SDK_ROOT}/components/hal/src/target/_common/cc26xx"
    "${SDK_ROOT}/components/hal/src/target"
    "${SDK_ROOT}/components/hal/src/target/cc2650tirtos"

    # OSAL
    "${SDK_ROOT}/components/osal/src/inc"
    "${SDK_ROOT}/components/osal/src/mcu/cc26xx"

    # ICall
    "${SDK_ROOT}/icall/inc"
    "${SDK_ROOT}/components/icall/src"
    "${SDK_ROOT}/components/icall/src/inc"

    # NPI
    "${SDK_ROOT}/components/npi/src"
    "${SDK_ROOT}/components/npi/src/inc"
    "${SDK_ROOT}/components/npi/src/unified/inc"
    "${SDK_ROOT}/components/npi/src/unified/subsystem"
    "${SDK_ROOT}/common/cc26xx/npi/stack"

    # Profiles
    "${SDK_ROOT}/profiles/roles"
    "${SDK_ROOT}/profiles/roles/cc26xx"

    # RCOSC
    "${SDK_ROOT}/common/cc26xx/rcosc"

    # ROM
    "${SDK_ROOT}/rom"

    # SERVICES
    "${SDK_ROOT}/components/services/src/aes/cc26xx"
    "${SDK_ROOT}/components/services/src/appasrt"
    "${SDK_ROOT}/components/services/src/appasrt/cc26xx"
    "${SDK_ROOT}/components/services/src/kcb"
    "${SDK_ROOT}/components/services/src/nv"
    "${SDK_ROOT}/components/services/src/nv/cc26xx"
    "${SDK_ROOT}/components/services/src/saddr"
    "${SDK_ROOT}/components/services/src/sdata"
    "${SDK_ROOT}/components/services/src/watchdog"

    # Board (CC2650 EM variant used by simple_peripheral)
    "${SDK_ROOT}/boards/CC2650DK_7ID"

    # App-specific OSAL init header (osal_icall_ble.h)
    "${CMAKE_CURRENT_LIST_DIR}/src"
)

# ─── Compile Definitions ──────────────────────────────────────────────────────
target_compile_definitions(${PROJECT_NAME} PRIVATE
    # ── Compiler compatibility ────────────────────────────────────────────────
    # ZBIT gates out OSAL code paths written for older TI-CGT (16.x) where
    # ltoa() took 2 arguments. CGT 20.x requires 3 arguments, causing a
    # build error. ZBIT skips the broken wrapper in osal.c and osal_memory.c.
    # Safe for BLE-only builds — ZBIT originally targeted Zigbee/Z-Stack variants.
    ZBIT

    # ── Device Type Specific Defenitions (Simple Peripheral) ──────────────────
    # ── Substitute for running lib_search tool with input 
    # ──  examples/cc2650em/simple_peripheral/iar/stack/build_config.opt
    # ── Instead this project is setup to be a peripheral, so set the defines here
    HOST_CONFIG=PERIPHERAL_CFG
    GAP_BOND_MGR
    HCI_TL_NONE

    # ── From BLE Host/Controller Build Components ─────────────────────────────
    BROADCASTER_CFG=0x01
    OBSERVER_CFG=0x02
    PERIPHERAL_CFG=0x04
    CENTRAL_CFG=0x08
    ADV_NCONN_CFG=0x01
    ADV_CONN_CFG=0x02
    SCAN_CFG=0x04
    INIT_CFG=0x08
    ADV_CFG=ADV_NCONN_CFG+ADV_CONN_CFG
    LINK_CFG=ADV_CONN_CFG+INIT_CFG
    FULL_CFG=INIT_CFG+SCAN_CFG+ADV_NCONN_CFG+ADV_CONN_CFG
    L2CAP_COC_CFG=0x80
    HOST_V41_MASK=0x80
    PING_CFG=0x01
    SLV_FEAT_EXCHG_CFG=0x02
    CONN_PARAM_REQ_CFG=0x04
    LOW_DUTY_CYCLE_DIRECTED_CFG=0x08
    DTM_625US_TX_CFG=0x10
    FRAG_CFG=0x20
    MST_SLV_CFG=0x40
    V41_CTRL_CFG=0x47
    CTRL_V41_MASK=0x7F
    PRIVACY_1_2_CFG=0x01
    SECURE_CONNS_CFG=0x02
    EXT_DATA_LEN_CFG=0x04

    # ── From CCS Example ───────────────────────────────────────────────
    CC26XX
    CC26XXWARE
    DATA=
    EXT_HAL_ASSERT
    FLASH_ROM_BUILD
    GATT_NO_CLIENT
    INCLUDE_AES_DECRYPT
    NEAR_FUNC=
    OSAL_CBTIMER_NUM_TASKS=1
    OSAL_SNV=1
    POWER_SAVING
    USE_ICALL
    xDEBUG
    xDEBUG_ENC
    xDEBUG_GPIO
    xDEBUG_SW_TRACE
    xPM_DISABLE_PWRDOWN
    xTESTMODES
    xTEST_BLEBOARD
)

target_compile_options(${PROJECT_NAME} PRIVATE
    --diag_warning=225
    --diag_suppress=48
    --diag_suppress=16004
    --display_error_number
)

# ─── Link Options ──────────────────────────────────────────────────────────────
target_link_options(${PROJECT_NAME} PRIVATE

    # Stack size and heap
    "--heap_size=0"
    "--stack_size=256"

    # Output files
    "--output_file=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.out"
    "--map_file=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.map"
    "--xml_link_info=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.xml"

    # Required by cc26xx_stack.cmd
    "--entry_point=startup_entry"
    "--retain=g_pfnVectors"
    
    # Stack memory map — defines FLASH and SRAM regions
    "${SDK_ROOT}/common/cc26xx/ccs/cc26xx_stack.cmd"
)

# ─── Link Dependencies ────────────────────────────────────────────────────────
# cortex_m3_opts and cc2650_config carry compiler/linker flags via INTERFACE.
# tirtos_config carries all TIRTOS/XDC include paths.
target_link_libraries(${PROJECT_NAME} PUBLIC
    cortex_m3_opts
    cc2650_config
    tirtos_config
)

# ─── Pre-built BLE Stack Libraries ───────────────────────────────────────────
# TI-CGT's linker requires .a files passed as positional arguments rather
# than via -l flags. Pass them directly via target_link_options so they
# appear correctly in the armcl -z invocation.
target_link_options(${PROJECT_NAME} PRIVATE
    --reread_libs
    --unused_section_elimination=on
    --compress_dwarf=on
    --diag_suppress=16002-D
    --diag_suppress=10247-D
    --diag_suppress=10325-D
    --diag_suppress=10229-D

    # Positional inputs — no -l, passed like object files
    "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/blelib/host/host_pxxx.a"
    "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/blelib/ctrl/cc2640/cc2640_ctrl_pxxx.a"
    "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/blelib/hci_tl/cc26xx/cc26xx_hci_tl_none.a"

    # -l libraries — searched via --search_path, placed after positional inputs
    "-l${SDK_ROOT}/rom/ble_rom_releases/04242014/ble_rom_patch.symbols"
    "-l${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272/driverlib/bin/ccs/driverlib.lib"

    # Replace libc.a with the correct pre-built RTS for -mv7M3 --code_state=16 -me --abi=eabi
    "${TI_CGT_ROOT}/lib/rtsv7M3_T_le_eabi.lib"
)


# ─── Post Build ──────────────────────────────────────────────────────────────
add_frontier(${PROJECT_NAME})

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    # Run frontier to generate app memory boundaries
    COMMAND ${CMAKE_COMMAND} -E make_directory
            "${CMAKE_CURRENT_BINARY_DIR}/boundary"
    COMMAND python3 "${FRONTIER_PY}"
            ccs
            "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.xml"
            "${CMAKE_CURRENT_BINARY_DIR}/boundary/compiler_boundary.opt"
            "${CMAKE_CURRENT_BINARY_DIR}/boundary/linker_boundary.cmd"
    COMMENT "Running frontier.py to generate app memory boundaries"
    VERBATIM
)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    # Generate .hex from .out
    COMMAND "${TI_CGT_PATH}/armhex"
            "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.out"
            --intel
            --outfile="${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
    COMMENT "Generating hex file"
    VERBATIM
)