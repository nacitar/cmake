#
# Copyright (C) 2014 Jacob McIntosh <nacitar at ubercpp dot com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


###
# Build Values
###
#
# C++ sources: list(APPEND CXX_SOURCES ...)
# C sources:   list(APPEND C_SOURCES ...)
# C/C++ flags: Append(CC_FLAGS ...)
# C++ flags:   Append(CXX_FLAGS ...)
# C flags:     Append(C_FLAGS ...)
# Link flags:  Append(LINK_FLAGS ...)
#
# Clear all:   ClearBuildValues()
#
###

# New linker directory behavior
if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
  cmake_policy(SET CMP0011 NEW)
endif(COMMAND cmake_policy)

# Sets several variables after examining the environment for a given language
macro(ExamineEnvironment LANG)
  if (CMAKE_${LANG}_COMPILER_ID STREQUAL "Clang")
    set(TOOLCHAIN_${LANG}_CLANG "1")
    set(TOOLCHAIN_${LANG}_GNU_COMPATIBLE "1")
  elseif (CMAKE_${LANG}_COMPILER_ID STREQUAL "GNU")
    set(TOOLCHAIN_${LANG}_GNU "1")
    set(TOOLCHAIN_${LANG}_GNU_COMPATIBLE "1")
  endif()
endmacro()
# Appends values to a space-delimited string
macro(Append var)
  foreach(value ${ARGN})
    set("${var}" "${${var}} ${value}")
  endforeach()
endmacro()
# Appends values to a list
macro(ListAppend var)
  list(APPEND "${var}" ${ARGN})
endmacro()
# Sets a list to the specified values
macro(ListSet var)
  set("${var}")
  ListAppend("${var}" ${ARGN})
endmacro()
# Clears global lists for flags and source files
macro(ClearBuildValues)
  set(CXX_SOURCES)
  set(C_SOURCES)
  set(CC_FLAGS)
  set(CXX_FLAGS)
  set(C_FLAGS)
  set(LINK_FLAGS)
endmacro()
# Adds a target, using separate C/CXX flags plus common CC flags
function(AddTargetPrv TARGET TYPE
    CXX_SOURCES C_SOURCES
    CC_FLAGS CXX_FLAGS C_FLAGS
    LINK_FLAGS)
  string(TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE)
  set(SOURCES "${CXX_SOURCES};${C_SOURCES}")
  # for generic library additions, choose the proper type
  if ("${TYPE}" STREQUAL "LIBRARY")
    if (BUILD_SHARED_LIBS)
      set(TYPE "SHARED")
    else()
      set(TYPE "STATIC")
    endif()
  endif()
  # add the proper type of target
  if ("${TYPE}" STREQUAL "EXE")
    add_executable("${TARGET}" ${SOURCES})
  elseif ("${TYPE}" STREQUAL "SHARED"
      OR "${TYPE}" STREQUAL "STATIC"
      OR "${TYPE}" STREQUAL "MODULE")
    add_library("${TARGET}" "${TYPE}" ${SOURCES})
  else()
    message(FATAL_ERROR "Invalid target type: ${TYPE}")
  endif()
  set(FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${BUILD_TYPE}}")
  Append(FLAGS "${CC_FLAGS} ${CC_FLAGS_${BUILD_TYPE}}")
  Append(FLAGS "${CXX_FLAGS} ${CXX_FLAGS_${BUILD_TYPE}}")
  set_source_files_properties(${CXX_SOURCES} PROPERTIES COMPILE_FLAGS
      "${FLAGS}")
  set(FLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${BUILD_TYPE}}")
  Append(FLAGS "${CC_FLAGS} ${CC_FLAGS_${BUILD_TYPE}}")
  Append(FLAGS "${C_FLAGS} ${C_FLAGS_${BUILD_TYPE}}")
  set_source_files_properties(${C_SOURCES} PROPERTIES COMPILE_FLAGS "${FLAGS}")
  set(FLAGS "${CMAKE_${TYPE}_LINKER_FLAGS}")
  Append(FLAGS "${CMAKE_${TYPE}_LINKER_FLAGS_${BUILD_TYPE}}")
  Append(FLAGS "${LINK_FLAGS} ${LINK_FLAGS_${BUILD_TYPE}}")
  Append(FLAGS "${LINK_FLAGS_${TYPE}}")
  Append(FLAGS "${LINK_FLAGS_${TYPE}_${BUILD_TYPE}}")
  set_target_properties("${TARGET}" PROPERTIES LINK_FLAGS "${FLAGS}")
endfunction()
# Builds a target using the globals that govern its creation
macro(AddTarget TARGET TYPE)
  AddTargetPrv("${TARGET}" "${TYPE}"
      "${CXX_SOURCES}" "${C_SOURCES}"
      "${CC_FLAGS}" "${CXX_FLAGS}" "${C_FLAGS}"
      "${LINK_FLAGS}")
endmacro()
# Macros for easily adding targets of certain types.
macro(AddExecutable TARGET)
  AddTarget("${TARGET}" EXE)
endmacro()
macro(AddLibrary TARGET)
  AddTarget("${TARGET}" LIBRARY)
endmacro()
macro(AddStaticLibrary TARGET)
  AddTarget("${TARGET}" STATIC)
endmacro()
macro(AddSharedLibrary TARGET)
  AddTarget("${TARGET}" SHARED)
endmacro()
macro(AddModule TARGET)
  AddTarget("${TARGET}" MODULE)
endmacro()
# Adds additional files to the list for make clean
function(AddCleanFiles)
  foreach(value ${ARGN})
    set_property(DIRECTORY . APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
        "${value}")
  endforeach()
endfunction()
# Creates a binary name from a given target
macro(ExecutableName var target)
  set("${var}" "${CMAKE_EXECUTABLE_PREFIX}${target}${CMAKE_EXECUTABLE_SUFFIX}")
endmacro()
# Use ${ECHO} for easier echo command invocation in custom commands
set(ECHO "COMMAND ${CMAKE_COMMAND} -E echo")
separate_arguments(ECHO)

# Initialization
ExamineEnvironment(CXX)
ClearBuildValues()
# Deduce the target
if (CMAKE_SYSTEM_NAME STREQUAL "Generic")
  set(TARGET_EMBEDDED "1")
elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(TARGET_WINDOWS "1")
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(TARGET_LINUX "1")
elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(TARGET_MAC "1")
endif()
