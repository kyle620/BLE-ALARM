# This function will use the .cfg file to generate the necessary linker and compiler options for the TIRTOS target
function(add_tirtos_config TARGET CFG_FILE)
    # Define paths based on your Docker setup
    set(XDC_ROOT "/opt/tools/tirtos/xdctools_3_32_00_06_core")
    set(TIRTOS_ROOT "/opt/tools/tirtos/tirtos_cc13xx_cc26xx_2_21_01_08")

    # Define the output directory for configuro
    set(CONFIG_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/configPkg")
    
    # 1. Run Configuro
    add_custom_command(
        OUTPUT "${CONFIG_OUT_DIR}/linker.cmd" "${CONFIG_OUT_DIR}/compiler.opt"
        COMMAND "${XDC_ROOT}/xs" "--xdcpath=${TIRTOS_ROOT}/products/bios_6_46_01_38/packages" 
                xdc.tools.configuro -c "${CMAKE_C_COMPILER}" 
                -t ti.targets.arm.elf.M3 -p ti.platforms.simplelink:CC2650F128
                -o "${CONFIG_OUT_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/${CFG_FILE}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${CFG_FILE}"
        COMMENT "Running XDCtools Configuro on ${CFG_FILE}"
    )

    # 2. Add the generated linker file to your target
    target_link_options(${TARGET} PRIVATE "-l${CONFIG_OUT_DIR}/linker.cmd")
    
    # 3. Add the generated compiler options (macros/includes)
    target_compile_options(${TARGET} PRIVATE "@${CONFIG_OUT_DIR}/compiler.opt")
endfunction()