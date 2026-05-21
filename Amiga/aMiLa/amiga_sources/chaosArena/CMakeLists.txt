cmake_minimum_required(VERSION 3.14.0)
project(chaosArena LANGUAGES C)

if(NOT AMIGA)
	message(SEND_ERROR "This project only compiles for Amiga")
endif()

# ACE
set(ACE_BOB_WRAP_Y OFF)
set(ACE_BOB_PRISTINE_BUFFER OFF)
add_subdirectory(deps/ace ace)

set(CMAKE_C_STANDARD 11)
file(GLOB_RECURSE SOURCES src/*.c src/*.h)

if(ELF2HUNK)
	set(GAME_EXECUTABLE chaosArena.elf)
	set(GAME_OUTPUT_EXECUTABLE chaosArena.exe)
	add_executable(${GAME_EXECUTABLE} ${SOURCES})
	target_link_libraries(${GAME_EXECUTABLE} -Wl,-Map=chaosArena.map)

	if(NOT (CMAKE_BUILD_TYPE STREQUAL "Debug") AND NOT (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo"))
		set(ELF2HUNK_ARGS ${ELF2HUNK_ARGS} -s)
	endif()

	add_custom_command(
		TARGET ${GAME_EXECUTABLE} POST_BUILD
		COMMAND ${ELF2HUNK} ${GAME_EXECUTABLE} ${GAME_OUTPUT_EXECUTABLE} ${ELF2HUNK_ARGS}
	)
	add_custom_command(
		TARGET ${GAME_EXECUTABLE} POST_BUILD
		COMMAND ${OBJDUMP} --disassemble -S ${GAME_EXECUTABLE} > chaosArena.s
	)
else()
	SET(GAME_EXECUTABLE chaosArena)
	SET(GAME_OUTPUT_EXECUTABLE chaosArena)
	add_executable(${GAME_EXECUTABLE} ${SOURCES})
endif()

# Version stuff
string(TIMESTAMP YEAR "%y")
string(TIMESTAMP DAY "%d")
string(TIMESTAMP MONTH "%m")
MATH(EXPR VER_MAJOR "0 + ${YEAR}")
MATH(EXPR VER_MINOR "0 + ${MONTH}")
MATH(EXPR VER_FIX "0 + ${DAY}")
set(VERSION "${VER_MAJOR}.${VER_MINOR}.${VER_FIX}")
target_compile_definitions(${GAME_EXECUTABLE} PRIVATE GAME_VERSION="${VERSION}")

target_include_directories(${GAME_EXECUTABLE} PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_compile_options(${GAME_EXECUTABLE} PUBLIC -Wall)
target_link_libraries(${GAME_EXECUTABLE} ace)
if(GAME_DEBUG)
	target_compile_definitions(${GAME_EXECUTABLE} PRIVATE GAME_DEBUG)
	target_compile_definitions(ace PUBLIC ACE_DEBUG_UAE)
endif()

set(RES_DIR ${CMAKE_CURRENT_LIST_DIR}/res)
set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data)
set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)
set(WARRIOR_DIR ${GEN_DIR}/warrior)
set(THUNDER_DIR ${GEN_DIR}/thunder)
file(MAKE_DIRECTORY ${DATA_DIR} ${GEN_DIR} ${WARRIOR_DIR} ${THUNDER_DIR})

# Fonts
convertFont(
	TARGET ${GAME_EXECUTABLE} FIRST_CHAR 32
	SOURCE ${RES_DIR}/font.png DESTINATION ${DATA_DIR}/menu.fnt
)
convertFont(
	TARGET ${GAME_EXECUTABLE} FIRST_CHAR 29
	SOURCE ${RES_DIR}/font_uni54.png DESTINATION ${DATA_DIR}/uni54.fnt
)

# Warrior frames
SET(X_SPACING 0)
SET(Y_SPACING 0)
SET(FRAME_WIDTH 16)
SET(FRAME_HEIGHT 16)
foreach(direction RANGE 7)
	SET(warriorFrames "")
	file(MAKE_DIRECTORY ${WARRIOR_DIR})
	foreach(anim RANGE 10)
		MATH(EXPR posX "${anim} * (${FRAME_WIDTH} + ${X_SPACING})")
		MATH(EXPR posY "${direction} * (${FRAME_HEIGHT} + ${Y_SPACING})")
		MATH(EXPR frameIndex "11 * ${direction} + ${anim}")
		extractBitmaps(
			TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/warrior.png
			DESTINATIONS
				${WARRIOR_DIR}/${frameIndex}.png ${posX} ${posY} ${FRAME_WIDTH} ${FRAME_HEIGHT}
			GENERATED_FILE_LIST warriorFrame
		)
		SET(warriorFrames "${warriorFrames};${warriorFrame}")
	endforeach()
endforeach()

# Convert warrior frames to linear tile-like format
convertTileset(
	TARGET ${GAME_EXECUTABLE} SIZE 16
	SOURCE ${WARRIOR_DIR} DESTINATION ${GEN_DIR}/warrior.png
	TILE_PATHS ${warriorFrames}
)

# Thunder
extractBitmaps(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/thunder.png
	DESTINATIONS
		${THUNDER_DIR}/0.png 0 0 16 258
		${THUNDER_DIR}/1.png 16 0 16 258
)

# Converting bimaps
convertBitmaps(
	TARGET ${GAME_EXECUTABLE}
	PALETTE ${RES_DIR}/chaos_arena.pal
	MASK_COLOR "#FF00FF"
	INTERLEAVED SOURCES ${GEN_DIR}/warrior.png ${RES_DIR}/countdown.png ${RES_DIR}/fight.png ${RES_DIR}/title.png ${RES_DIR}/tiles.png
	DESTINATIONS ${DATA_DIR}/warrior.bm ${DATA_DIR}/countdown.bm ${DATA_DIR}/fight.bm ${DATA_DIR}/title.bm ${DATA_DIR}/tiles.bm
	MASKS ${DATA_DIR}/warrior_mask.bm ${DATA_DIR}/countdown_mask.bm ${DATA_DIR}/fight_mask.bm ${DATA_DIR}/title_mask.bm ${DATA_DIR}/tiles_mask.bm
)
convertBitmaps(
	TARGET ${GAME_EXECUTABLE}
	PALETTE ${RES_DIR}/chaos_arena_short.gpl
	SOURCES ${RES_DIR}/chaos.png
	DESTINATIONS ${DATA_DIR}/chaos.bm
)
convertBitmaps(
	TARGET ${GAME_EXECUTABLE}
	PALETTE ${RES_DIR}/cross.gpl
	INTERLEAVED SOURCES ${THUNDER_DIR}/0.png ${THUNDER_DIR}/1.png ${RES_DIR}/cross.png
	DESTINATIONS ${DATA_DIR}/thunder_0.bm ${DATA_DIR}/thunder_1.bm ${DATA_DIR}/cross.bm
)

convertPalette(
	${GAME_EXECUTABLE} ${RES_DIR}/chaos_arena.pal ${DATA_DIR}/palette.plt
)
convertPalette(
	${GAME_EXECUTABLE} ${RES_DIR}/thunder.pal ${DATA_DIR}/thunder.plt
)

convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/bricks.wav
	DESTINATION ${DATA_DIR}/crumble.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/noo5.wav
	DESTINATION ${DATA_DIR}/noo.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/swipe1.wav
	DESTINATION ${DATA_DIR}/swipe1.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/swipe2.wav
	DESTINATION ${DATA_DIR}/swipe2.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/swipeHit.wav
	DESTINATION ${DATA_DIR}/swipeHit.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/countdown_3.wav
	DESTINATION ${DATA_DIR}/cd3.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/countdown_2.wav
	DESTINATION ${DATA_DIR}/cd2.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/countdown_1.wav
	DESTINATION ${DATA_DIR}/cd1.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/countdown_fight.wav
	DESTINATION ${DATA_DIR}/cdfight.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/sfx/thunder.wav
	DESTINATION ${DATA_DIR}/thunder.sfx
)
mergeMods(
	TARGET ${GAME_EXECUTABLE}
	SOURCES ${RES_DIR}/charena_menu.mod ${RES_DIR}/charena_game.mod
	DESTINATIONS ${DATA_DIR}/charena_menu.mod ${DATA_DIR}/charena_game.mod
	SAMPLE_PACK ${DATA_DIR}/samples.samplepack
)

# Logo assets
set(LMC_PLT_PATH ${DATA_DIR}/lmc.plt)
convertPalette(${GAME_EXECUTABLE} ${RES_DIR}/logo/lmc.gpl ${LMC_PLT_PATH})
convertBitmaps(
	TARGET ${GAME_EXECUTABLE} PALETTE ${LMC_PLT_PATH}
	INTERLEAVED SOURCES ${RES_DIR}/logo/lmc.png DESTINATIONS ${DATA_DIR}/lmc.bm
)
convertBitmaps(
	TARGET ${GAME_EXECUTABLE} PALETTE ${RES_DIR}/logo/ace.gpl
	INTERLEAVED SOURCES ${RES_DIR}/logo/ace.png DESTINATIONS ${DATA_DIR}/ace.bm
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/logo/ace.wav
	DESTINATION ${DATA_DIR}/ace.sfx
)
convertAudio(
	TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/logo/lmc.wav
	STRICT DESTINATION ${DATA_DIR}/lmc.sfx
)

# Generating ZIP
set(GAME_PACKAGE_NAME "${CMAKE_PROJECT_NAME} ${VER_MAJOR}_${VER_MINOR}_${VER_FIX}")
add_custom_target(generateZip COMMAND
	${CMAKE_COMMAND} -E tar "cf" "${GAME_PACKAGE_NAME}.zip" --format=zip
	"${CMAKE_CURRENT_BINARY_DIR}/${GAME_OUTPUT_EXECUTABLE}" "${DATA_DIR}"
	COMMENT "Generating ZIP file ${GAME_PACKAGE_NAME}.zip"
)

# Generating ADF
set(ADF_DIR "${CMAKE_CURRENT_BINARY_DIR}/adf")
add_custom_target(generateAdf
	COMMAND ${CMAKE_COMMAND} -E make_directory "${ADF_DIR}/s"
	COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/${GAME_OUTPUT_EXECUTABLE}" "${ADF_DIR}"
	COMMAND ${CMAKE_COMMAND} -E copy_directory "${DATA_DIR}" "${ADF_DIR}/data"
	# COMMAND ${CMAKE_COMMAND} -E echo "c:add21k" > "${ADF_DIR}/s/startup-sequence"
	COMMAND ${CMAKE_COMMAND} -E echo "${GAME_OUTPUT_EXECUTABLE}" > "${ADF_DIR}/s/startup-sequence"
	COMMAND exe2adf -l ${CMAKE_PROJECT_NAME} -a "${GAME_PACKAGE_NAME}.adf" -d ${ADF_DIR}
	COMMAND ${CMAKE_COMMAND} -E rm -rf "${ADF_DIR}"
	COMMENT "Generating ADF file ${GAME_PACKAGE_NAME}.adf"
)
