cmake_minimum_required(VERSION 3.28)

project(hello-test)

# Include the shared file for Cortex-M3 settings
include("cmake/logic_modules/cortex-m3.cmake")

# Inlclude the shared file for CC2650-specific settings
include("cmake/logic_modules/cc2650-ti-cgt.cmake")

# Include the function for handling TIRTOS configuration
include("cmake/external_libraries/TIRTOS-Config.cmake")


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

# This handles the complex XDCtools logic for you
add_tirtos_config(${PROJECT_NAME} app/config_tirtos/hello.cfg)

# "Link" the architecture settings
target_link_libraries(${PROJECT_NAME} PRIVATE cortex_m3_opts)
target_link_libraries(${PROJECT_NAME} PRIVATE cc2650_config)