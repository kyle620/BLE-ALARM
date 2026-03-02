include_guard(GLOBAL)

# ─── TIRTOS Interface Target ─────────────────────────────────────────────────
# Provides all TIRTOS/XDC include paths and link directories as a single
# reusable target. Link against this to get everything transitively.
# Usage: target_link_libraries(my_target PRIVATE tirtos_config)
# ─────────────────────────────────────────────────────────────────────────────

add_library(tirtos_config INTERFACE)

target_include_directories(tirtos_config INTERFACE
    "${TI_CGT_ROOT}/include"
    "${XDC_ROOT}/packages"
    "${TIRTOS_ROOT}/packages"
    "${TIRTOS_ROOT}/products/bios_6_46_01_38/packages"
    "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages"
    "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272"
    "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272/inc"
)

target_link_directories(tirtos_config INTERFACE
    "${TI_CGT_ROOT}/lib"
    "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272/driverlib/bin/ti/targets/arm/elf/M3"
    "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages/ti/drivers/lib"
)

# ─── Pre-built TIRTOS Libraries ───────────────────────────────────────────────
add_library(tirtos_driverlib STATIC IMPORTED GLOBAL)
set_target_properties(tirtos_driverlib PROPERTIES
    IMPORTED_LOCATION "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272/driverlib/bin/ccs/driverlib.lib"
)

add_library(tirtos_bios_rts STATIC IMPORTED GLOBAL)
set_target_properties(tirtos_bios_rts PROPERTIES
    IMPORTED_LOCATION "${TIRTOS_ROOT}/products/bios_6_46_01_38/packages/ti/targets/arm/rtsarm/lib/ti.targets.arm.rtsarm.aem3"
)

add_library(tirtos_ti_drivers STATIC IMPORTED GLOBAL)
set_target_properties(tirtos_ti_drivers PROPERTIES
    IMPORTED_LOCATION "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages/ti/drivers/lib/drivers_cc26xxware.aem3"
)
