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

# Appends values to a space-delimited string
macro(Append var)
  foreach(value ${ARGN})
    set("${var}" "${${var}} ${value}")
  endforeach()
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
# Adds a program, using separate C/CXX flags plus common CC flags
function(AddProgramPrv TARGET
    CXX_SOURCES C_SOURCES
    CC_FLAGS CXX_FLAGS C_FLAGS
    LINK_FLAGS)
  add_executable("${TARGET}" ${CXX_SOURCES} ${C_SOURCES})
  set(FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}")
  Append(FLAGS "${CC_FLAGS} ${CXX_FLAGS}")
  set_source_files_properties(${CXX_SOURCES} PROPERTIES COMPILE_FLAGS
      "${FLAGS}")
  set(FLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}}")
  Append(FLAGS "${CC_FLAGS} ${C_FLAGS}")
  set_source_files_properties(${C_SOURCES} PROPERTIES COMPILE_FLAGS "${FLAGS}")
  set(FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
  Append(FLAGS "${CMAKE_EXE_LINKER_FLAGS_${CMAKE_BUILD_TYPE}} ${LINK_FLAGS}")
  set_target_properties("${TARGET}" PROPERTIES LINK_FLAGS "${FLAGS}")
endfunction()
# Builds a program using the globals that govern its creation
macro(AddProgram TARGET)
  AddProgramPrv("${TARGET}"
      "${CXX_SOURCES}" "${C_SOURCES}"
      "${CC_FLAGS}" "${CXX_FLAGS}" "${C_FLAGS}"
      "${LINK_FLAGS}")
endmacro()
# Adds additional files to the list for make clean
function(AddCleanFiles)
  foreach(value ${ARGN})
    set_property(DIRECTORY . APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
        "${value}")
  endforeach()
endfunction()
# Use ${ECHO} for easier echo command invocation in custom commands
set(ECHO "COMMAND ${CMAKE_COMMAND} -E echo")
separate_arguments(ECHO)

# Clear it one time
ClearBuildValues()
