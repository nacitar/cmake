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

set(CMAKE_SYSTEM_NAME Generic)

find_program(CMAKE_C_COMPILER avr-gcc)
find_program(CMAKE_CXX_COMPILER avr-g++)
find_program(CMAKE_OBJCOPY avr-objcopy)
find_program(AVR_SIZE_TOOL avr-size)
