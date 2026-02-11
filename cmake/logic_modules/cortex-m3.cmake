###########################
#        Cortex M3        #
###########################

# Make sure contents of this file are only processed once per build
include_guard(GLOBAL)

add_library(cortex_m3_opts INTERFACE)

# Use INTERFACE to ensure these flags propagate to anything linking this target
target_compile_options(cortex_m3_opts INTERFACE 
    -mv7M3 
    --float_support=vfplib
)

target_link_options(cortex_m3_opts INTERFACE 
    -mv7M3 
    --float_support=vfplib
)
