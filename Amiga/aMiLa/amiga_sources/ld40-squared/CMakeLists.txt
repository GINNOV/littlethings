cmake_minimum_required(VERSION 3.14.0)
project(squared LANGUAGES C)

if(NOT AMIGA)
	message(SEND_ERROR "This project only compiles for Amiga")
endif()

# ACE
add_subdirectory(deps/ace ace)

set(CMAKE_C_STANDARD 11)

set(CMAKE_C_STANDARD 11)
file(GLOB_RECURSE SOURCES src/*.c src/*.h)

if(ELF2HUNK)
	set(SQUARED_EXECUTABLE squared.elf)
	set(SQUARED_OUTPUT_EXECUTABLE squared.exe)
	add_executable(${SQUARED_EXECUTABLE} ${SOURCES})
	target_link_libraries(${SQUARED_EXECUTABLE} -Wl,-Map=squared.map)

	if(NOT (CMAKE_BUILD_TYPE STREQUAL "Debug") AND NOT (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo"))
		set(ELF2HUNK_ARGS ${ELF2HUNK_ARGS} -s)
	endif()

	add_custom_command(
		TARGET ${SQUARED_EXECUTABLE} POST_BUILD
		COMMAND ${ELF2HUNK} ${SQUARED_EXECUTABLE} ${SQUARED_OUTPUT_EXECUTABLE} ${ELF2HUNK_ARGS}
	)
	add_custom_command(
		TARGET ${SQUARED_EXECUTABLE} POST_BUILD
		COMMAND ${OBJDUMP} --disassemble -S ${SQUARED_EXECUTABLE} > squared.s
	)
else()
	SET(SQUARED_EXECUTABLE squared)
	SET(SQUARED_OUTPUT_EXECUTABLE squared)
	add_executable(${SQUARED_EXECUTABLE} ${SOURCES})
endif()

# Version stuff
string(TIMESTAMP YEAR "%y")
string(TIMESTAMP DAY "%d")
string(TIMESTAMP MONTH "%m")
MATH(EXPR VER_MAJOR "0 + ${YEAR}")
MATH(EXPR VER_MINOR "0 + ${MONTH}")
MATH(EXPR VER_FIX "0 + ${DAY}")
set(VERSION "${VER_MAJOR}.${VER_MINOR}.${VER_FIX}")
target_compile_definitions(${SQUARED_EXECUTABLE} PRIVATE SQUARED_VERSION="${VERSION}")

target_include_directories(${SQUARED_EXECUTABLE} PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_compile_options(${SQUARED_EXECUTABLE} PUBLIC -Wall)
target_link_libraries(${SQUARED_EXECUTABLE} ace)
if(GAME_DEBUG)
	target_compile_definitions(${SQUARED_EXECUTABLE} PRIVATE GAME_DEBUG)
	target_compile_definitions(ace PUBLIC ACE_DEBUG_UAE)
endif()
if(GAME_DEBUG_AI)
	target_compile_definitions(${SQUARED_EXECUTABLE} PRIVATE GAME_DEBUG_AI)
endif()

set(RES_DIR ${CMAKE_CURRENT_LIST_DIR}/res)
set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data)
set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)

file(
	MAKE_DIRECTORY
	${DATA_DIR} ${DATA_DIR}/logo ${DATA_DIR}/levels
)


