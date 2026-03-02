# ─── add_frontier() ───────────────────────────────────────────────────────────
# Runs frontier.py after the stack links to generate memory boundary files
# for the app project.
#
# Usage (in simple_peripheral_stack/CMakeLists.txt):
#   add_frontier(${PROJECT_NAME})
#
# Outputs (consumed by app):
#   <binary_dir>/boundary/compiler_boundary.opt  ← passed to app via @file
#   <binary_dir>/boundary/linker_boundary.cmd    ← passed to app linker
# ─────────────────────────────────────────────────────────────────────────────
function(add_frontier TARGET)
    set(FRONTIER_PY
        "${CMAKE_CURRENT_LIST_DIR}/../../../../simplelink-ble_sdk_2_02_08_12/tools/frontier.py"
        CACHE PATH "Path to frontier.py"
    )
    set(BOUNDARY_DIR    "${CMAKE_CURRENT_BINARY_DIR}/boundary")
    set(STACK_XML       "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.xml")
    set(COMPILER_BOUNDARY "${BOUNDARY_DIR}/compiler_boundary.opt")
    set(LINKER_BOUNDARY   "${BOUNDARY_DIR}/linker_boundary.cmd")

    # ── Generate XML link info from the stack link step ───────────────────────
    target_link_options(${TARGET} PRIVATE
        "--xml_link_info=${STACK_XML}"
    )

    # ── Run frontier.py after the stack .lib is linked ────────────────────────
    add_custom_command(
        TARGET ${TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${BOUNDARY_DIR}"
        COMMAND python3 "${FRONTIER_PY}"
                ccs
                "${STACK_XML}"
                "${COMPILER_BOUNDARY}"
                "${LINKER_BOUNDARY}"
        COMMENT "Running frontier.py to generate app memory boundaries"
        VERBATIM
    )

    # ── Export boundary file paths for the app to consume ─────────────────────
    set(BLE_COMPILER_BOUNDARY "${COMPILER_BOUNDARY}" CACHE PATH
        "Frontier-generated compiler boundary file for app project" FORCE)
    set(BLE_LINKER_BOUNDARY  "${LINKER_BOUNDARY}"  CACHE PATH
        "Frontier-generated linker boundary file for app project"  FORCE)

endfunction()