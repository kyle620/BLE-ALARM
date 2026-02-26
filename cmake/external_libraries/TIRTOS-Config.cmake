function(add_tirtos_config TARGET CFG_FILE)
    if(NOT TI_XDC_XS)
        message(FATAL_ERROR "add_tirtos_config called, but TI_XDC_XS is not defined. Is the toolchain loaded?")
    endif()
    
    # 1. Define the output directory for configuro
    set(CONFIG_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/configPkg")
    set(CC26XXWARE_ROOT "${TIRTOS_ROOT}/products/cc26xxware_2_24_03_17272")

    # Build the compile options string with all needed include paths
    set(XDC_COMPILE_OPTS
    "--include_path=${CC26XXWARE_ROOT}"
    "--include_path=${TI_CGT_ROOT}/include"
    )

    list(JOIN XDC_COMPILE_OPTS " " XDC_COMPILE_OPTS_STRING)

    # Define the full XDC Path (Order matters: BIOS first, then Drivers, then XDC)
    set(FULL_XDC_PATH 
        "${TIRTOS_ROOT}/packages"
        "${TIRTOS_ROOT}/products/tidrivers_cc13xx_cc26xx_2_21_01_01/packages"
        "${TIRTOS_ROOT}/products/bios_6_46_01_38/packages"
        "${TIRTOS_ROOT}/products/uia_2_01_00_01/packages"
        "${XDC_ROOT}/packages"
    )
    
    # Join them with a semicolon for the TI-RTOS toolchain
    list(JOIN FULL_XDC_PATH ";" XDC_PATH_STRING)

    # 2. Run Configuro
    add_custom_command(
        OUTPUT "${CONFIG_OUT_DIR}/linker.cmd" "${CONFIG_OUT_DIR}/compiler.opt"
        # Use the variable found by find_program instead of hardcoding the path
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
        VERBATIM # Recommended for complex commands to handle spaces/quotes correctly
    )

    add_custom_target(${TARGET}_tirtos_config
        DEPENDS "${CONFIG_OUT_DIR}/linker.cmd" "${CONFIG_OUT_DIR}/compiler.opt"
    )
    add_dependencies(${TARGET} ${TARGET}_tirtos_config)

    # 3. Use -i to add the directory to the linker's search path
    target_link_options(${TARGET} PRIVATE "-i${CONFIG_OUT_DIR}")

    # 4. Add the generated linker file to your target
    target_link_options(${TARGET} PRIVATE "${CONFIG_OUT_DIR}/linker.cmd")
    
    # 5. Add the generated compiler options (macros/includes)
    target_compile_options(${TARGET} PRIVATE "@${CONFIG_OUT_DIR}/compiler.opt")

    # 6. Add include directories (Generated headers like 'configPkg/package/cfg/...')
    target_include_directories(${TARGET} PRIVATE 
    "${CONFIG_OUT_DIR}"
    "${CONFIG_OUT_DIR}/package/cfg"
    )
    
endfunction()