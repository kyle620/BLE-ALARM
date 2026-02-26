# TI_Toolchain.cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Use a cache variable so users can override the path via command line if needed
set(TI_CGT_ROOT "/opt/tools/compiler/ti-cgt-arm_20.2.6.LTS/" CACHE PATH "Path to TI CGT")
set(TI_CGT_PATH "${TI_CGT_ROOT}/bin" CACHE PATH "Path to TI CGT")
set(XDC_ROOT "/opt/tools/tirtos/xdctools_3_32_00_06_core" CACHE PATH "Path to XDCtools installation")
set(TIRTOS_ROOT "/opt/tools/tirtos/tirtos_cc13xx_cc26xx_2_21_01_08" CACHE PATH "Path to TI-RTOS installation")

# Verify the tools exist at the specified paths
find_program(TI_ARMCL NAMES armcl armcl.exe PATHS "${TI_CGT_PATH}" NO_DEFAULT_PATH)
find_program(TI_XDC_XS NAMES xs xs.exe PATHS "${XDC_ROOT}" NO_DEFAULT_PATH)

# Verify the tool was found
if(TI_XDC_XS)
    message(STATUS "[Toolchain Check] Found XDC 'xs' tool: ${TI_XDC_XS}")
else()
    message(FATAL_ERROR "[Toolchain Check] FAILED to find 'xs' tool in ${XDC_ROOT}. Check your path!")
endif()

set(CMAKE_C_COMPILER   ${TI_ARMCL})
set(CMAKE_CXX_COMPILER ${TI_ARMCL})
set(CMAKE_ASM_COMPILER ${TI_ARMCL})

# Tell CMake these are TI Compilers (helps CMake apply the right flag syntax)
set(CMAKE_C_COMPILER_ID_RUN TRUE)
set(CMAKE_C_COMPILER_ID TI)

# Modern way to skip tests without hardcoding 'WORKS' variables
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Tell CMake how to invoke armcl as a linker.
# -z activates link mode and MUST come first, before any object files.
# -o MUST come after all objects and libraries.
set(CMAKE_C_LINK_EXECUTABLE
    "<CMAKE_C_COMPILER> -z <OBJECTS> <LINK_FLAGS> <LINK_LIBRARIES> -o <TARGET>"
)

set(CMAKE_C_CREATE_STATIC_LIBRARY
    "<CMAKE_AR> r <TARGET> <OBJECTS>"
)
find_program(CMAKE_AR NAMES armar armar.exe PATHS "${TI_CGT_PATH}" NO_DEFAULT_PATH)