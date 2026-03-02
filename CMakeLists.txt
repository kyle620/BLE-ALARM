cmake_minimum_required(VERSION 3.28)

project(hello-test)

add_subdirectory(simplelink-ble_sdk_2_02_08_12)

include(simplelink-ble_sdk_2_02_08_12/cmake/external_libraries/TIRTOS-Config.cmake)

add_executable(${PROJECT_NAME})

target_sources(${PROJECT_NAME}
PRIVATE
app/src/hello.c
app/src/ccfg.c
app/src/CC2650_LAUNCHXL.c

PUBLIC
FILE_SET HEADERS
BASE_DIRS app/hdr
FILES
app/hdr/Board.h
app/hdr/CC2650_LAUNCHXL.h
)

target_link_libraries(${PROJECT_NAME} PRIVATE ble_sdk_2_02_08_12)

target_include_directories(${PROJECT_NAME} PRIVATE 
    "${TI_CGT_ROOT}/include"
    "${XDC_ROOT}/packages"
    "${TIRTOS_ROOT}/products/bios_6_46_01_38/packages"
    "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages"
    
    # REQUIRED: Root for #include <driverlib/ioc.h>
    "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272" 
    
    # REQUIRED: Root for #include <hw_memmap.h> (inside the inc folder)
    "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272/inc"
)

# Declare pre-built TI libraries as imported targets
add_library(driverlib STATIC IMPORTED GLOBAL)
set_target_properties(driverlib PROPERTIES
    IMPORTED_LOCATION "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272/driverlib/bin/ccs/driverlib.lib"
)

add_library(bios_rts STATIC IMPORTED GLOBAL)
set_target_properties(bios_rts PROPERTIES
    IMPORTED_LOCATION "${TIRTOS_ROOT}/products/bios_6_46_01_38/packages/ti/targets/arm/rtsarm/lib/ti.targets.arm.rtsarm.aem3"
)

add_library(ti_drivers STATIC IMPORTED GLOBAL)
set_target_properties(ti_drivers PROPERTIES
    IMPORTED_LOCATION "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages/ti/drivers/lib/drivers_cc26xxware.aem3"
)

# "Link" the architecture settings
target_link_libraries(${PROJECT_NAME} PRIVATE cortex_m3_opts)
target_link_libraries(${PROJECT_NAME} PRIVATE cc2650_config)

# This handles the complex XDCtools logic for you
# add_tirtos_config(${PROJECT_NAME} app/config_tirtos/hello.cfg)

# Link TIRTOS libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    "${TI_CGT_ROOT}/lib/libc.a"
    driverlib
    bios_rts
    ti_drivers
)

# Tell the linker where the TI standard libraries and SDK libraries live
target_link_directories(${PROJECT_NAME} PRIVATE 
    "${TI_CGT_ROOT}/lib"
    "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272/driverlib/bin/ti/targets/arm/elf/M3"
    "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages/ti/drivers/lib"
)