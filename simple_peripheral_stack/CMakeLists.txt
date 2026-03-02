cmake_minimum_required(VERSION 3.28)

project(simple_peripheral_stack VERSION 1.0.0 LANGUAGES C)

include_guard(GLOBAL)

# ─── Shared cmake modules ─────────────────────────────────────────────────────
# These live in the workspace-level cmake/ directory, shared by both the stack
# and app projects. Neither project owns them.
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/logic_modules/cortex-m3.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/logic_modules/cc2650-ti-cgt.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/external_libraries/TIRTOS-Paths.cmake")

# ─── SDK Root ─────────────────────────────────────────────────────────────────
# The SDK is a plain source tree with no CMakeLists.txt. We point into it
# explicitly — mirroring exactly what the CCS .project file does.
set(SDK_ROOT "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/src"
    CACHE PATH "Path to BLE SDK src directory")

# ─── Pre-built BLE Stack Libraries ───────────────────────────────────────────
# These are the closed-source core stack blobs shipped by TI.
# They are NOT compiled — only linked.
add_library(ble_host STATIC IMPORTED GLOBAL)
set_target_properties(ble_host PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/blelib/host/host_pxxx.a"
)

add_library(ble_ctrl STATIC IMPORTED GLOBAL)
set_target_properties(ble_ctrl PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/blelib/ctrl/cc2640/cc2640_ctrl_pxxx.a"
)

add_library(ble_hci_tl STATIC IMPORTED GLOBAL)
set_target_properties(ble_hci_tl PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../simplelink-ble_sdk_2_02_08_12/blelib/hci_tl/cc26xx/cc26xx_hci_tl_none.a"
)

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
add_library(${PROJECT_NAME} STATIC ${STACK_SOURCES})

# ─── Include Directories ─────────────────────────────────────────────────────
# These mirror the include paths from the CCS project, plus the parent-of-inc
# entries needed for headers included as "inc/foo.h".
target_include_directories(${PROJECT_NAME} PUBLIC
    # BLE core public headers
    "${SDK_ROOT}/inc"
    "${SDK_ROOT}/controller/cc26xx/inc"

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
    "${SDK_ROOT}/components/icall/src/inc"

    # NPI
    "${SDK_ROOT}/components/npi/src/inc"
    "${SDK_ROOT}/common/cc26xx/npi/stack"        # parent of inc/ for "inc/npi_ble.h"

    # Profiles
    "${SDK_ROOT}/profiles/roles"
    "${SDK_ROOT}/profiles/roles/cc26xx"

    # ROM
    "${SDK_ROOT}/rom"

    # Board (CC2650 EM variant used by simple_peripheral)
    "${SDK_ROOT}/boards/CC2650DK_7ID"

    # App-specific OSAL init header (osal_icall_ble.h)
    "${CMAKE_CURRENT_LIST_DIR}/src"
)

# ─── Compile Definitions ──────────────────────────────────────────────────────
target_compile_definitions(${PROJECT_NAME} PRIVATE
    CC2650DK_7ID
    CC26XX
    CCS
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
)

# ─── Link Dependencies ────────────────────────────────────────────────────────
# cortex_m3_opts and cc2650_config carry compiler/linker flags via INTERFACE.
# tirtos_config carries all TIRTOS/XDC include paths.
# ble_host/ctrl/hci_tl are the pre-built closed-source stack blobs.
target_link_libraries(${PROJECT_NAME} PUBLIC
    cortex_m3_opts
    cc2650_config
    tirtos_config
    ble_host
    ble_ctrl
    ble_hci_tl
)
