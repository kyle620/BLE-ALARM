# TI_Toolchain.cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# ─── Tool Paths ─────────────────────────────────────────────────────────────
set(TI_CGT_ROOT  "/opt/tools/compiler/ti-cgt-arm_20.2.6.LTS"            CACHE PATH "Path to TI CGT root")
set(TI_CGT_PATH  "${TI_CGT_ROOT}/bin"                                   CACHE PATH "Path to TI CGT binaries")
set(XDC_ROOT     "/opt/tools/tirtos/xdctools_3_32_00_06_core"           CACHE PATH "Path to XDCtools")
set(TIRTOS_ROOT  "/opt/tools/tirtos/tirtos_cc13xx_cc26xx_2_21_01_08"    CACHE PATH "Path to TI-RTOS")

# ─── Find Tools ─────────────────────────────────────────────────────────────
find_program(TI_ARMCL   NAMES armcl armcl.exe   PATHS "${TI_CGT_PATH}" NO_DEFAULT_PATH REQUIRED)
find_program(TI_XDC_XS  NAMES xs xs.exe         PATHS "${XDC_ROOT}"    NO_DEFAULT_PATH)
find_program(CMAKE_AR   NAMES armar armar.exe   PATHS "${TI_CGT_PATH}" NO_DEFAULT_PATH REQUIRED)
find_program(CMAKE_AR   NAMES armar armar.exe   PATHS "${TI_CGT_PATH}" NO_DEFAULT_PATH)

# CMAKE_AR must be found before add_library() is called — finding it here in
# the toolchain file (rather than after set(CMAKE_C_COMPILER)) is correct.

if(TI_XDC_XS)
    message(STATUS "[Toolchain] Found XDC xs: ${TI_XDC_XS}")
else()
    message(WARNING "[Toolchain] XDC 'xs' not found in ${XDC_ROOT}. XDCtools-based build steps will not work.")
endif()

# ─── Compilers ──────────────────────────────────────────────────────────────
set(CMAKE_C_COMPILER   "${TI_ARMCL}")
set(CMAKE_CXX_COMPILER "${TI_ARMCL}")
set(CMAKE_ASM_COMPILER "${TI_ARMCL}")

# Prevent CMake from running its built-in compiler identification tests,
# which will fail because armcl doesn't produce a native host executable.
set(CMAKE_C_COMPILER_ID_RUN    TRUE)
set(CMAKE_C_COMPILER_ID        TI)
set(CMAKE_CXX_COMPILER_ID_RUN  TRUE)
set(CMAKE_CXX_COMPILER_ID      TI)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_C_COMPILER_WORKS TRUE CACHE BOOL "" FORCE)

# ─── Linker ─────────────────────────────────────────────────────────────────
set(CMAKE_EXE_LINKER_FLAGS_INIT "--rom_model --reread_libs")

# -z activates link mode and MUST come first, before any object files.
# -o MUST come after all objects and libraries.
# <FALGS> 
# <CMAKE_C_LINK_FLAGS Global Scope (All executables)
# <LINK_FLAGS> Specific Target Scope
set(CMAKE_C_LINK_EXECUTABLE 
    "<CMAKE_C_COMPILER> <FLAGS> -z <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> <LINK_LIBRARIES> -o <TARGET>"
)

# ─── Archiver ───────────────────────────────────────────────────────────────
set(CMAKE_C_CREATE_STATIC_LIBRARY
    "<CMAKE_AR> r <TARGET> <OBJECTS>"
)

# ─── Sysroot / Search Roots ─────────────────────────────────────────────────
# Prevent CMake from accidentally finding host system libraries.
set(CMAKE_FIND_ROOT_PATH        "${TI_CGT_ROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)   # find_program uses host paths
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)    # libraries must come from sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)    # headers must come from sysroot

# ─── Compiler Identity Defines ───────────────────────────────────────────────
# __TI_COMPILER_VERSION__ is normally predefined by armcl automatically,
# but CMake's compiler abstraction layer can suppress it. Define it explicitly
# to ensure it is always available to both stack and app projects.
add_compile_definitions(__TI_COMPILER_VERSION)
