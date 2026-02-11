
include_guard(GLOBAL)

# Create a shared 'config' target for CC2650 settings
add_library(cc2650_config INTERFACE)

# 1. Compiler Flags (C only)
target_compile_options(cc2650_config INTERFACE 
    $<$<COMPILE_LANGUAGE:C>:
        --code_state=16
        -me
        --abi=eabi
        -g
        --gen_func_subsections=on
        --diag_wrap=on
        --diag_warning=255
        --display_error_number
    >
)

# 2. Preprocessor Definitions
target_compile_definitions(cc2650_config INTERFACE CCS)

# 3. Linker Flags
target_link_options(cc2650_config INTERFACE 
    --warn_sections
    --diag_wrap=on
    --diag_warning=255
    --display_error_number
    --rom_model
)