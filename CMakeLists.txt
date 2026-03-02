cmake_minimum_required(VERSION 3.28)

# Workspace root — this file exists only to satisfy CMake's requirement that
# a CMakeLists.txt be present alongside CMakePresets.json.
#
# Do NOT add subdirectories here. The stack and app are independent projects,
# each configured and built via their own presets in CMakePresets.json.
#
# To build:
#   cmake --build --preset stack-debug
#   cmake --build --preset app-debug

project(workspace LANGUAGES NONE)