cmake_minimum_required(VERSION 3.28)

project(simple_peripheral_app VERSION 1.0.0 LANGUAGES C)

include_guard(GLOBAL)

# ─── Shared cmake modules ─────────────────────────────────────────────────────
# These live in the workspace-level cmake/ directory, shared by both the stack
# and app projects. Neither project owns them.
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/logic_modules/cortex-m3.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/logic_modules/cc2650-ti-cgt.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/external_libraries/TIRTOS-Paths.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/external_libraries/TIRTOS-Config.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/tools/case_fixups.cmake")

# ─── SDK Root ─────────────────────────────────────────────────────────────────
# The SDK is a plain source tree with no CMakeLists.txt. We point into it
# explicitly — mirroring exactly what the CCS .project file does.
set(SDK_ROOT "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/src"
    CACHE PATH "Path to BLE SDK src directory")

add_executable(${PROJECT_NAME})

target_sources(${PROJECT_NAME}
PRIVATE
    # ── Application ──────────────────────────────────────────────────────────
    src/main.c
    src/simple_peripheral.c
    src/uart_task.c

    # ── ICallBLE ─────────────────────────────────────────────────────────────
    "${SDK_ROOT}/icall/app/ble_user_config.c"
    "${SDK_ROOT}/icall/app/icall_api.c"

    # ── ICall (common) ───────────────────────────────────────────────────────
    "${SDK_ROOT}/components/icall/src/icall.c"
    "${SDK_ROOT}/components/icall/src/icall_cc2650.c"

    # ── Profiles ─────────────────────────────────────────────────────────────
    "${SDK_ROOT}/profiles/roles/cc26xx/peripheral.c"
    "${SDK_ROOT}/profiles/dev_info/cc26xx/devinfoservice.c"
    "${SDK_ROOT}/profiles/simple_profile/cc26xx/simple_gatt_profile.c"
    "${SDK_ROOT}/host/gatt_uuid.c"
    "${SDK_ROOT}/host/gattservapp_util.c"

    # ── Common CC26xx ────────────────────────────────────────────────────────
    "${SDK_ROOT}/common/cc26xx/util.c"
    "${SDK_ROOT}/common/cc26xx/ecc/ECCROMCC26XX.c"

    # ── HAL / TRNG ───────────────────────────────────────────────────────────
    "${SDK_ROOT}/components/hal/src/target/_common/TRNGCC26XX.c"

    # ── Board / Startup ──────────────────────────────────────────────────────
    "${SDK_ROOT}/target/board.c"

    # ── TI-RTOS Drivers ──────────────────────────────────────────────────────
    "${TI_RTOS_DRIVERS_BASE}/ti/drivers/pin/PINCC26XX.c"
    "${TI_RTOS_DRIVERS_BASE}/ti/drivers/rf/RFCC26XX_singleMode.c"
    "${TI_RTOS_DRIVERS_BASE}/ti/drivers/SPI.c"
    "${TI_RTOS_DRIVERS_BASE}/ti/drivers/spi/SPICC26XXDMA.c"
    "${TI_RTOS_DRIVERS_BASE}/ti/drivers/UART.c"
    "${TI_RTOS_DRIVERS_BASE}/ti/drivers/uart/UARTCC26XX.c"
    "${TI_RTOS_DRIVERS_BASE}/ti/drivers/dma/UDMACC26XX.c"

    # ── TI-RTOS Middleware ───────────────────────────────────────────────────
    "${TI_RTOS_DRIVERS_BASE}/ti/mw/display/Display.c"
    "${TI_RTOS_DRIVERS_BASE}/ti/mw/display/DisplayUart.c"
    "${TI_RTOS_DRIVERS_BASE}/ti/mw/display/DisplayDogm1286.c"

PUBLIC
    FILE_SET HEADERS
    BASE_DIRS hdr
    FILES
        hdr/simple_peripheral.h
        hdr/uart_task.h
)

# ─── Include Directories ─────────────────────────────────────────────────────
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

    #HEAP
    "${SDK_ROOT}/components/heapmgr"

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
    "${SDK_ROOT}/profiles/dev_info"
    "${SDK_ROOT}/profiles/roles"
    "${SDK_ROOT}/profiles/roles/cc26xx"
    "${SDK_ROOT}/profiles/simple_profile"

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
    "${SDK_ROOT}/target/"

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
    # ── From CCS Example ───────────────────────────────────────────────
    CC2650DK_7ID      # board selection
    CC2650EM_7ID      # RF package variant — required by ble_user_config.c
    CC26XX
    GAPROLE_TASK_STACK_SIZE=540
    HEAPMGR_SIZE=0
    ICALL_MAX_NUM_ENTITIES=6
    ICALL_MAX_NUM_TASKS=3
    POWER_SAVING
    USE_ICALL
    xBOARD_DISPLAY_EXCLUDE_LCD
    xDisplay_DISABLE_ALL
    xdc_runtime_Assert_DISABLE_ALL
    xdc_runtime_Log_DISABLE_ALL


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
)

# ─── Compile Options ──────────────────────────────────────────────────────────
target_compile_options(${PROJECT_NAME} PRIVATE
    --diag_warning=225
    --diag_suppress=48
    --diag_suppress=16004
    --display_error_number

    # Grab the ICALL_STACK0_ADDR and other defines from the output file generated from the stack build
    # WARNING! do not use the alias '@' it does not parse the .opt file correctly, use 'd--cmd_file'
    "--cmd_file=${CMAKE_CURRENT_LIST_DIR}/../simple_peripheral_stack/build/debug/boundary/compiler_boundary.opt"
)

# ─── TIRTOS CONFIGURO ──────────────────────────────────────────────────────────
add_tirtos_config(${PROJECT_NAME} "tirtos/cc2640.cfg")

# ─── Link Options ──────────────────────────────────────────────────────────────
get_filename_component(BOUNDARY_CMD
    "${CMAKE_CURRENT_LIST_DIR}/../simple_peripheral_stack/build/debug/boundary/linker_boundary.cmd"
    REALPATH)

target_link_options(${PROJECT_NAME} PRIVATE
    # Output map file
    "--map_file=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.map"
    
    # Stack size and heap
    "--stack_size=256"
    "--heap_size=0"
    "--unused_section_elimination=on"
    "--compress_dwarf=on"
    "--diag_suppress=16002-D"
    "--diag_suppress=10247-D"
    "--diag_suppress=10325-D"
    "--diag_suppress=10229-D"

    # Output files
    "--xml_link_info=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.xml"
    "--output_file=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.out"

    # Required by cc26xx_stack.cmd
    "--entry_point=startup_entry"
    
    # Contains defines to set ICALL_STACK_0, needs to be from stack build so memory aligns
    "${BOUNDARY_CMD}"
    
    # Linker script
    "${SDK_ROOT}/common/cc26xx/ccs/cc26xx_app.cmd"
    
    # Symbol/library inputs via -l
    "-l${SDK_ROOT}/rom/common_rom_releases/03282014/common_rom.symbols"
    "-l${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272/driverlib/bin/ccs/driverlib.lib"
    "-l${TI_CGT_ROOT}/lib/rtsv7M3_T_le_eabi.lib"
)

# ─── Link Dependencies ────────────────────────────────────────────────────────
# cortex_m3_opts and cc2650_config carry compiler/linker flags via INTERFACE.
# tirtos_config carries all TIRTOS/XDC include paths.
target_link_libraries(${PROJECT_NAME} PUBLIC
    cortex_m3_opts
    cc2650_config
    tirtos_config
)
