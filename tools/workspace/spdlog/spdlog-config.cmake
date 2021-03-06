# This file is only used in cases when we need to rebuild spdlog from source.
# See repository.bzl for the logic to select when that occurs.

# Generated by cps2cmake https://github.com/mwoehlke/pycps
# and then subsequently edited by hand.

if(CMAKE_VERSION VERSION_LESS 3.9.0)
  message(FATAL_ERROR "CMake >= 3.9 required")
endif()
cmake_policy(PUSH)
cmake_policy(VERSION 3.0)
set(CMAKE_IMPORT_FILE_VERSION 1)

include(CMakeFindDependencyMacro)

get_filename_component(${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX "${${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX}" PATH)
get_filename_component(${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX "${${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX}" PATH)
get_filename_component(${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX "${${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX}" PATH)

if(${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX STREQUAL "/")
  set(${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX)
endif()

find_dependency(fmt 6.1.2 CONFIG HINTS "${${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX}/lib/cmake/fmt")
set(_expectedTargets spdlog::spdlog)

set(_targetsDefined)
set(_targetsNotDefined)

foreach(_expectedTarget ${_expectedTargets})
  if(NOT TARGET ${_expectedTarget})
    list(APPEND _targetsNotDefined ${_expectedTarget})
  endif()
  if(TARGET ${_expectedTarget})
    list(APPEND _targetsDefined ${_expectedTarget})
  endif()
endforeach()
if("${_targetsDefined}" STREQUAL "${_expectedTargets}")
  set(CMAKE_IMPORT_FILE_VERSION)
  cmake_policy(POP)
  return()
endif()
if(NOT "${_targetsDefined}" STREQUAL "")
  message(FATAL_ERROR "Some (but not all) targets in this export set were already defined.\nTargets Defined: ${_targetsDefined}\nTargets not yet defined: ${_targetsNotDefined}\n")
endif()
unset(_targetsDefined)
unset(_targetsNotDefined)
unset(_expectedTargets)

set(spdlog_VERSION "1.5.0")

set(_apple_soname_prologue)
if(APPLE)
  set(_apple_soname_prologue "@rpath/")
endif()
add_library(spdlog::spdlog SHARED IMPORTED)
set_target_properties(spdlog::spdlog PROPERTIES
  IMPORTED_LOCATION "${${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX}/lib/libdrake_spdlog.so"
  IMPORTED_SONAME "${_apple_soname_prologue}libdrake_spdlog.so"
  INTERFACE_INCLUDE_DIRECTORIES "${${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX}/include/spdlog"
  INTERFACE_LINK_LIBRARIES "fmt::fmt-header-only"
  INTERFACE_COMPILE_DEFINITIONS "HAVE_SPDLOG;SPDLOG_COMPILED_LIB;SPDLOG_FMT_EXTERNAL"
)
unset(_apple_soname_prologue)

set(spdlog_LIBRARIES "spdlog::spdlog")
set(spdlog_INCLUDE_DIRS "")


unset(${CMAKE_FIND_PACKAGE_NAME}_IMPORT_PREFIX)
unset(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

