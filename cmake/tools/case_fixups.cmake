# cmake/case_fixups.cmake
# Creates case-compatibility symlinks for TI SDK headers originally
# developed on Windows (case-insensitive) that break on Linux.
set(_RF_DIR "${TI_RTOS_DRIVERS_BASE}/ti/drivers/rf")
if(NOT EXISTS "${_RF_DIR}/rf.h")
    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
        "${_RF_DIR}/RF.h" "${_RF_DIR}/rf.h")
endif()
# Add more here as discovered...