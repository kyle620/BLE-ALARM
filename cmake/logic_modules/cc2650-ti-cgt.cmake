include_guard(GLOBAL)

# Create a shared 'config' target for CC2650 settings
add_library(cc2650_config INTERFACE)

# 1. Compiler Flags (C only)
target_compile_options(cc2650_config INTERFACE
    --c11
    --code_state=16
    -me
    -O4
    --opt_for_speed=0
    --abi=eabi
    -g
    --gen_func_subsections=on
    --diag_wrap=off
    --diag_warning=225
    --display_error_number
)

# 3. Linker Flags
target_link_options(cc2650_config INTERFACE 
    --warn_sections
    --diag_wrap=off
    --rom_model
)