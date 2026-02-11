# TI_Toolchain.cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Use a cache variable so users can override the path via command line if needed
set(TI_CGT_PATH "/opt/tools/compiler/ti-cgt-arm_20.2.6.LTS" CACHE PATH "Path to TI CGT")

# Use 'find_program' instead of hardcoded paths to make it more portable
find_program(TI_ARMCL NAMES armcl armcl.exe PATHS "${TI_CGT_PATH}/bin" NO_DEFAULT_PATH)

set(CMAKE_C_COMPILER   ${TI_ARMCL})
set(CMAKE_CXX_COMPILER ${TI_ARMCL})
set(CMAKE_ASM_COMPILER ${TI_ARMCL})

# Tell CMake these are TI Compilers (helps CMake apply the right flag syntax)
set(CMAKE_C_COMPILER_ID_RUN TRUE)
set(CMAKE_C_COMPILER_ID TI)

# Modern way to skip tests without hardcoding 'WORKS' variables
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)