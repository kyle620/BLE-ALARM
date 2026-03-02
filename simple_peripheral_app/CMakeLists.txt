cmake_minimum_required(VERSION 3.28)

project(simple_peripheral_app VERSION 1.0.0 LANGUAGES C)

include_guard(GLOBAL)

# ─── Shared cmake modules ─────────────────────────────────────────────────────
# These live in the workspace-level cmake/ directory, shared by both the stack
# and app projects. Neither project owns them.
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/logic_modules/cortex-m3.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/logic_modules/cc2650-ti-cgt.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../cmake/external_libraries/TIRTOS-Paths.cmake")

add_executable(${PROJECT_NAME})

target_sources(${PROJECT_NAME}
PRIVATE
src/main.c
src/simple_peripheral.c
src/uart_task.c

PUBLIC
FILE_SET HEADERS
BASE_DIRS hdr
FILES
hdr/simple_peripheral.h
hdr/uart_task.h
)
