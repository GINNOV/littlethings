cmake_minimum_required(VERSION 3.14.0)
project(FlappyAceWin LANGUAGES ASM C)
#set(ACE_DEBUG ON)
#set(ACE_DEBUG_UAE ON)
#set(CMAKE_C_STANDARD 17)
file(GLOB_RECURSE SOURCES src/*.c main.c my_strtol.c)

if(ELF2HUNK)
	set(FlappyAceWin_EXECUTABLE FlappyAceWin.elf)
	set(FlappyAceWin_OUTPUT_EXECUTABLE FlappyAceWin.exe)
	add_executable(${FlappyAceWin_EXECUTABLE} ${SOURCES})
	
	target_link_libraries(${FlappyAceWin_EXECUTABLE} -Wl,-Map=FlappyAceWin.map)
	
	add_custom_command(
		TARGET ${FlappyAceWin_EXECUTABLE} POST_BUILD
		COMMAND ${ELF2HUNK} ${FlappyAceWin_EXECUTABLE} ${FlappyAceWin_OUTPUT_EXECUTABLE}
	)
	add_custom_command(
		TARGET ${FlappyAceWin_EXECUTABLE} POST_BUILD
		COMMAND ${OBJDUMP} --disassemble -S ${FlappyAceWin_EXECUTABLE} > FlappyAceWin.s
	)
else()
	SET(FlappyAceWin_EXECUTABLE FlappyAceWin)
	SET(FlappyAceWin_OUTPUT_EXECUTABLE FlappyAceWin)
	
	add_executable(${FlappyAceWin_EXECUTABLE} ${SOURCES})
endif()

add_subdirectory(deps/ace ace)

# Version stuff
string(TIMESTAMP YEAR "%y")
string(TIMESTAMP DAY "%d")
string(TIMESTAMP MONTH "%m")
MATH(EXPR VER_MAJOR "0 + ${YEAR}")
MATH(EXPR VER_MINOR "0 + ${MONTH}")
MATH(EXPR VER_FIX "0 + ${DAY}")
set(VERSION "${VER_MAJOR}.${VER_MINOR}.${VER_FIX}")


target_compile_definitions(${FlappyAceWin_EXECUTABLE} PRIVATE FlappyAceWin_VERSION="${VERSION}")
include_directories(${SDL2_INCLUDE_DIRS} include/)
target_link_libraries(${FlappyAceWin_EXECUTABLE} ace )  
target_compile_options(${FlappyAceWin_EXECUTABLE} PUBLIC -Wall)


if(GAME_DEBUG)
	target_compile_definitions(${FlappyAceWin_EXECUTABLE} PRIVATE GAME_DEBUG)
	target_compile_definitions(ace PUBLIC ACE_DEBUG_ALL ACE_DEBUG_UAE)
endif()

set(RES_DIR ${CMAKE_CURRENT_LIST_DIR}/res)
set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data)
set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)


# Generating ZIP
set(FlappyAceWin_ZIP_NAME "${CMAKE_PROJECT_NAME} ${VER_MAJOR}_${VER_MINOR}_${VER_FIX}")
add_custom_target(generateZip COMMAND
	${CMAKE_COMMAND} -E tar "cf" "${FlappyAceWin_ZIP_NAME}.zip" --format=zip
	"${CMAKE_CURRENT_BINARY_DIR}/${FlappyAceWin_OUTPUT_EXECUTABLE}" "${CMAKE_CURRENT_BINARY_DIR}/myacefont.fnt"
	COMMENT "Generating ${FlappyAceWin_ZIP_NAME}.zip"
)
# Generating ADF
set(ADF_DIR "${CMAKE_CURRENT_BINARY_DIR}/adf")
add_custom_target(generateAdf
	COMMAND ${CMAKE_COMMAND} -E make_directory "${ADF_DIR}/s"
	COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/${FlappyAceWin_OUTPUT_EXECUTABLE}" "${ADF_DIR}"
	COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/myacefont.fnt" "${ADF_DIR}"
	COMMAND ${CMAKE_COMMAND} -E copy_directory "${DATA_DIR}" "${ADF_DIR}/data"
	COMMAND ${CMAKE_COMMAND} -E echo "${FlappyAceWin_OUTPUT_EXECUTABLE}" > "${ADF_DIR}/s/startup-sequence"
	COMMAND exe2adf -l ${CMAKE_PROJECT_NAME} -a "${CMAKE_PROJECT_NAME}.adf" -d ${ADF_DIR}
	COMMAND ${CMAKE_COMMAND} -E rm -rf "${ADF_DIR}"
	COMMENT "Generating ADF file"
)