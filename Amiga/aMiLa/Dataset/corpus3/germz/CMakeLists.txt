cmake_minimum_required(VERSION 3.14.0)
project(germz LANGUAGES C)

if(NOT AMIGA)
	message(SEND_ERROR "This project only compiles for Amiga")
endif()

# ACE
add_subdirectory(deps/ace ace)

set(CMAKE_C_STANDARD 11)
file(GLOB_RECURSE SOURCES src/*.c src/*.h)

if(ELF2HUNK)
	set(GERMZ_EXECUTABLE germz.elf)
	set(GERMZ_OUTPUT_EXECUTABLE germz.exe)
	add_executable(${GERMZ_EXECUTABLE} ${SOURCES})
	target_link_libraries(${GERMZ_EXECUTABLE} -Wl,-Map=germz.map)

	if(NOT (CMAKE_BUILD_TYPE STREQUAL "Debug") AND NOT (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo"))
		set(ELF2HUNK_ARGS ${ELF2HUNK_ARGS} -s)
	endif()

	add_custom_command(
		TARGET ${GERMZ_EXECUTABLE} POST_BUILD
		COMMAND ${ELF2HUNK} ${GERMZ_EXECUTABLE} ${GERMZ_OUTPUT_EXECUTABLE} ${ELF2HUNK_ARGS}
	)
	add_custom_command(
		TARGET ${GERMZ_EXECUTABLE} POST_BUILD
		COMMAND ${OBJDUMP} --disassemble -S ${GERMZ_EXECUTABLE} > germz.s
	)
else()
	SET(GERMZ_EXECUTABLE germz)
	SET(GERMZ_OUTPUT_EXECUTABLE germz)
	add_executable(${GERMZ_EXECUTABLE} ${SOURCES})
endif()

# Version stuff
string(TIMESTAMP YEAR "%y")
string(TIMESTAMP DAY "%d")
string(TIMESTAMP MONTH "%m")
MATH(EXPR VER_MAJOR "0 + ${YEAR}")
MATH(EXPR VER_MINOR "0 + ${MONTH}")
MATH(EXPR VER_FIX "0 + ${DAY}")
set(VERSION "${VER_MAJOR}.${VER_MINOR}.${VER_FIX}")
target_compile_definitions(${GERMZ_EXECUTABLE} PRIVATE GERMZ_VERSION="${VERSION}")

target_include_directories(${GERMZ_EXECUTABLE} PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_compile_options(${GERMZ_EXECUTABLE} PUBLIC -Wall)
target_link_libraries(${GERMZ_EXECUTABLE} ace)
if(GAME_DEBUG)
	target_compile_definitions(${GERMZ_EXECUTABLE} PRIVATE GAME_DEBUG)
	target_compile_definitions(ace PUBLIC ACE_DEBUG_UAE)
	# target_compile_definitions(ace PUBLIC ACE_DEBUG_PTPLAYER)
endif()
if(GAME_DEBUG_AI)
	target_compile_definitions(${GERMZ_EXECUTABLE} PRIVATE GAME_DEBUG_AI)
endif()

set(RES_DIR ${CMAKE_CURRENT_LIST_DIR}/res)
set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data)
set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)

file(
	MAKE_DIRECTORY
	${DATA_DIR} ${DATA_DIR}/sfx ${DATA_DIR}/intro ${DATA_DIR}/outro
	${GEN_DIR}/cursors ${GEN_DIR}/links ${GEN_DIR}/blob0
	${GEN_DIR}/blob1 ${GEN_DIR}/blob2 ${GEN_DIR}/blob3 ${GEN_DIR}/blob4
	${GEN_DIR}/led_small ${GEN_DIR}/led_big ${GEN_DIR}/btn_small ${GEN_DIR}/btn_big
	${GEN_DIR}/plep0_up ${GEN_DIR}/plep0_down ${GEN_DIR}/plep0_left ${GEN_DIR}/plep0_right
	${GEN_DIR}/plep1_up ${GEN_DIR}/plep1_down ${GEN_DIR}/plep1_left ${GEN_DIR}/plep1_right
	${GEN_DIR}/plep2_up ${GEN_DIR}/plep2_down ${GEN_DIR}/plep2_left ${GEN_DIR}/plep2_right
	${GEN_DIR}/plep3_up ${GEN_DIR}/plep3_down ${GEN_DIR}/plep3_left ${GEN_DIR}/plep3_right
	${GEN_DIR}/game_bg ${GEN_DIR}/display
)

# Palette
set(GERMZ_PLT_PATH ${DATA_DIR}/germz.plt)
set(LMC_PLT_PATH ${DATA_DIR}/lmc.plt)
set(MONO_PLT_PATH ${RES_DIR}/mono.gpl)
set(TRANSPARENCY_HEX "#000000")
convertPalette(${GERMZ_EXECUTABLE} ${RES_DIR}/germz.gpl ${GERMZ_PLT_PATH})
convertPalette(${GERMZ_EXECUTABLE} ${RES_DIR}/lmc.gpl ${LMC_PLT_PATH})

# Extract smaller gfx from bigger gfx sheet
extractBitmaps(TARGET ${GERMZ_EXECUTABLE} SOURCE 	${RES_DIR}/gfx.png
	DESTINATIONS
		${GEN_DIR}/cursors/0.png 112   0 16 16
		${GEN_DIR}/cursors/1.png  96   0 16 16
		${GEN_DIR}/cursors/2.png  96  16 16 16
		${GEN_DIR}/cursors/3.png 112  16 16 16
		# Blob anim 0 - green
		${GEN_DIR}/blob0/0.png    0 176 16 16
		${GEN_DIR}/blob0/1.png   16 176 16 16
		${GEN_DIR}/blob0/2.png   32 176 16 16
		${GEN_DIR}/blob0/3.png   48 176 16 16
		${GEN_DIR}/blob0/4.png   64 176 16 16
		${GEN_DIR}/blob0/5.png   80 176 16 16
		${GEN_DIR}/blob0/6.png   96 176 16 16
		${GEN_DIR}/blob0/7.png  112 176 16 16
		${GEN_DIR}/blob0/8.png  128 176 16 16 # Full - default
		${GEN_DIR}/blob0/9.png   80  48 16 16 # Full - capacity
		${GEN_DIR}/blob0/10.png  48  48 16 16 # Full - tick
		${GEN_DIR}/blob0/11.png  64  48 16 16 # Full - attack
		# Blob anim 1 - red
		${GEN_DIR}/blob1/0.png    0 160 16 16
		${GEN_DIR}/blob1/1.png   16 160 16 16
		${GEN_DIR}/blob1/2.png   32 160 16 16
		${GEN_DIR}/blob1/3.png   48 160 16 16
		${GEN_DIR}/blob1/4.png   64 160 16 16
		${GEN_DIR}/blob1/5.png   80 160 16 16
		${GEN_DIR}/blob1/6.png   96 160 16 16
		${GEN_DIR}/blob1/7.png  112 160 16 16
		${GEN_DIR}/blob1/8.png  128 160 16 16 # Full - default
		${GEN_DIR}/blob1/9.png   80  64 16 16 # Full - capacity
		${GEN_DIR}/blob1/10.png  48  64 16 16 # Full - tick
		${GEN_DIR}/blob1/11.png  64  64 16 16 # Full - attack
		# Blob anim 2 - yellow
		${GEN_DIR}/blob2/0.png    0 192 16 16
		${GEN_DIR}/blob2/1.png   16 192 16 16
		${GEN_DIR}/blob2/2.png   32 192 16 16
		${GEN_DIR}/blob2/3.png   48 192 16 16
		${GEN_DIR}/blob2/4.png   64 192 16 16
		${GEN_DIR}/blob2/5.png   80 192 16 16
		${GEN_DIR}/blob2/6.png   96 192 16 16
		${GEN_DIR}/blob2/7.png  112 192 16 16
		${GEN_DIR}/blob2/8.png  128 192 16 16 # Full - default
		${GEN_DIR}/blob2/9.png   80  32 16 16 # Full - capacity
		${GEN_DIR}/blob2/10.png  48  32 16 16 # Full - tick
		${GEN_DIR}/blob2/11.png  64  32 16 16 # Full - attack
		# Blob anim 3 - blue
		${GEN_DIR}/blob3/0.png    0 208 16 16
		${GEN_DIR}/blob3/1.png   16 208 16 16
		${GEN_DIR}/blob3/2.png   32 208 16 16
		${GEN_DIR}/blob3/3.png   48 208 16 16
		${GEN_DIR}/blob3/4.png   64 208 16 16
		${GEN_DIR}/blob3/5.png   80 208 16 16
		${GEN_DIR}/blob3/6.png   96 208 16 16
		${GEN_DIR}/blob3/7.png  112 208 16 16
		${GEN_DIR}/blob3/8.png  128 208 16 16 # Full - default
		${GEN_DIR}/blob3/9.png   80  16 16 16 # Full - capacity
		${GEN_DIR}/blob3/10.png  48  16 16 16 # Full - tick
		${GEN_DIR}/blob3/11.png  64  16 16 16 # Full - attack
		# Blob anim 4 - neutral
		${GEN_DIR}/blob4/0.png    0 224 16 16
		${GEN_DIR}/blob4/1.png   16 224 16 16
		${GEN_DIR}/blob4/2.png   32 224 16 16
		${GEN_DIR}/blob4/3.png   48 224 16 16
		${GEN_DIR}/blob4/4.png   64 224 16 16
		${GEN_DIR}/blob4/5.png   80 224 16 16
		${GEN_DIR}/blob4/6.png   96 224 16 16
		${GEN_DIR}/blob4/7.png  112 224 16 16
		${GEN_DIR}/blob4/8.png  128 224 16 16 # Full - default
		${GEN_DIR}/blob4/9.png   80   0 16 16 # Full - capacity
		${GEN_DIR}/blob4/10.png  48   0 16 16 # Full - tick
		${GEN_DIR}/blob4/11.png  64   0 16 16 # Full - attack
		# Links - additional tiles
		${GEN_DIR}/links/0.png 128 0 16 16
		# Links - horizontal
		${GEN_DIR}/links/1.png   0 112 16 16
		${GEN_DIR}/links/2.png  16 112 16 16
		${GEN_DIR}/links/3.png   0 128 16 16
		${GEN_DIR}/links/4.png  16 128 16 16
		# Links - vertical
		${GEN_DIR}/links/5.png  32 112 16 16
		${GEN_DIR}/links/6.png  48 112 16 16
		${GEN_DIR}/links/7.png  32 128 16 16
		${GEN_DIR}/links/8.png  48 128 16 16
		# Links - junctions
		${GEN_DIR}/links/9.png   0 144 16 16
		${GEN_DIR}/links/10.png  16 144 16 16
		${GEN_DIR}/links/11.png 32 144 16 16
		${GEN_DIR}/links/12.png 48 144 16 16
)

extractBitmaps(TARGET ${GERMZ_EXECUTABLE} SOURCE 	${RES_DIR}/editor_gfx.png
	DESTINATIONS
		# Editor button - small
		${GEN_DIR}/btn_small/0.png 64   0 16 10
		${GEN_DIR}/btn_small/1.png 64  10 16 10
		${GEN_DIR}/btn_small/2.png 64  20 16 10
		${GEN_DIR}/btn_small/3.png 64  30 16 10
		${GEN_DIR}/btn_small/4.png 64  40 16 10
		${GEN_DIR}/btn_small/5.png 64  50 16 10
		${GEN_DIR}/btn_small/6.png 64  60 16 10
		${GEN_DIR}/btn_small/7.png 64  70 16 10
		${GEN_DIR}/btn_small/8.png 64  80 16 10
		# Editor button - big
		${GEN_DIR}/btn_big/0.png   64  90 32 10
		${GEN_DIR}/btn_big/1.png   64 100 32 10
		${GEN_DIR}/btn_big/2.png   64 110 32 10
		${GEN_DIR}/btn_big/3.png   64 120 32 10
		${GEN_DIR}/btn_big/4.png   64 130 32 10
		${GEN_DIR}/btn_big/5.png   64 140 32 10
		# Editor led small
		${GEN_DIR}/led_small.png    0  44 16 10
		# Editor led big
		${GEN_DIR}/led_big/0.png    0  66 32 10
		${GEN_DIR}/led_big/1.png    0  77 32 10
		${GEN_DIR}/led_big/2.png    0  88 32 10
		${GEN_DIR}/led_big/3.png    0  99 32 10
		${GEN_DIR}/led_big/4.png    0 110 32 10
		${GEN_DIR}/editor_hud.png   0 176 64 256
		${GEN_DIR}/game_hud.png     0 433 64  64
		# Game bg
		${GEN_DIR}/game_bg.png 0 498 64 64
		# Display border
		${GEN_DIR}/display/0.png  0 605 16 16
		${GEN_DIR}/display/1.png 17 605 16 16
		${GEN_DIR}/display/2.png 34 605 16 16
		${GEN_DIR}/display/3.png  0 622 16 16
		${GEN_DIR}/display/4.png 17 622 16 16
		${GEN_DIR}/display/5.png 34 622 16 16
		${GEN_DIR}/display/6.png  0 639 16 16
		${GEN_DIR}/display/7.png 17 639 16 16
		${GEN_DIR}/display/8.png 34 639 16 16
		# HUD icon
		${GEN_DIR}/hud_target.png 0 593 16 9
)

# Pleps
foreach(player RANGE 3)
	MATH(EXPR offsBorn "0 + ${player} * 16")
	MATH(EXPR offsMove "128 + ${player} * 16")
	MATH(EXPR offsWin "192 + ${player} * 16")
	MATH(EXPR offsLose "256 + ${player} * 16")
	extractBitmaps(TARGET ${GERMZ_EXECUTABLE} SOURCE ${RES_DIR}/plep.png
		DESTINATIONS
			# Born
			${GEN_DIR}/plep${player}_right/0.png  6 ${offsBorn} 16 16
			${GEN_DIR}/plep${player}_right/1.png 23 ${offsBorn} 16 16
			${GEN_DIR}/plep${player}_right/2.png 41 ${offsBorn} 16 16
			${GEN_DIR}/plep${player}_right/3.png 59 ${offsBorn} 16 16
			# Move
			${GEN_DIR}/plep${player}_right/4.png   11 ${offsMove} 16 16
			${GEN_DIR}/plep${player}_right/5.png   44 ${offsMove} 16 16
			${GEN_DIR}/plep${player}_right/6.png   78 ${offsMove} 16 16
			${GEN_DIR}/plep${player}_right/7.png  112 ${offsMove} 16 16
			${GEN_DIR}/plep${player}_right/8.png  146 ${offsMove} 16 16
			${GEN_DIR}/plep${player}_right/9.png  180 ${offsMove} 16 16
			${GEN_DIR}/plep${player}_right/10.png 214 ${offsMove} 16 16
			${GEN_DIR}/plep${player}_right/11.png 250 ${offsMove} 16 16
			# Win
			${GEN_DIR}/plep${player}_right/12.png  11 ${offsWin} 16 16
			${GEN_DIR}/plep${player}_right/13.png  45 ${offsWin} 16 16
			${GEN_DIR}/plep${player}_right/14.png  80 ${offsWin} 16 16
			${GEN_DIR}/plep${player}_right/15.png 116 ${offsWin} 16 16
			# Lose
			${GEN_DIR}/plep${player}_right/16.png  11 ${offsLose} 16 16
			${GEN_DIR}/plep${player}_right/17.png  46 ${offsLose} 16 16
			${GEN_DIR}/plep${player}_right/18.png  80 ${offsLose} 16 16
			${GEN_DIR}/plep${player}_right/19.png 113 ${offsLose} 16 16
			${GEN_DIR}/plep${player}_right/20.png 146 ${offsLose} 16 16
			${GEN_DIR}/plep${player}_right/21.png 179 ${offsLose} 16 16
			${GEN_DIR}/plep${player}_right/22.png 212 ${offsLose} 16 16
			${GEN_DIR}/plep${player}_right/23.png 245 ${offsLose} 16 16
	)

	foreach(i RANGE 23)
		# Left plep anim = right plep anim mirrored Y
		transformBitmap(
			TARGET ${GERMZ_EXECUTABLE} SOURCE ${GEN_DIR}/plep${player}_right/${i}.png
			DESTINATION ${GEN_DIR}/plep${player}_left/${i}.png TRANSFORM -mirror y
		)
		# Up plep anim = right plep anim rotated by 90deg
		transformBitmap(
			TARGET ${GERMZ_EXECUTABLE} SOURCE ${GEN_DIR}/plep${player}_right/${i}.png
			DESTINATION ${GEN_DIR}/plep${player}_up/${i}.png TRANSFORM -rotate -90 ${TRANSPARENCY_HEX}
		)
		# Down plep anim = up plep anim mirrored X
		transformBitmap(
			TARGET ${GERMZ_EXECUTABLE} SOURCE ${GEN_DIR}/plep${player}_up/${i}.png
			DESTINATION ${GEN_DIR}/plep${player}_down/${i}.png TRANSFORM -mirror x
		)
	endforeach()
endforeach()

# Group small gfx into bigger tile sheets
set(CURSOR_PATHS
	${GEN_DIR}/cursors/0.png
	${GEN_DIR}/cursors/1.png
	${GEN_DIR}/cursors/2.png
	${GEN_DIR}/cursors/3.png
)
convertTileset(
	TARGET ${GERMZ_EXECUTABLE} SIZE 16
	SOURCE ${GEN_DIR}/cursors DESTINATION ${GEN_DIR}/cursors.png
	TILE_PATHS ${CURSOR_PATHS}
)

foreach(i RANGE 4)
	set(BLOB_PATHS
		${GEN_DIR}/blob${i}/0.png
		${GEN_DIR}/blob${i}/1.png
		${GEN_DIR}/blob${i}/2.png
		${GEN_DIR}/blob${i}/3.png
		${GEN_DIR}/blob${i}/4.png
		${GEN_DIR}/blob${i}/5.png
		${GEN_DIR}/blob${i}/6.png
		${GEN_DIR}/blob${i}/7.png
		${GEN_DIR}/blob${i}/8.png
		${GEN_DIR}/blob${i}/9.png
		${GEN_DIR}/blob${i}/10.png
		${GEN_DIR}/blob${i}/11.png
	)
	convertTileset(
		TARGET ${GERMZ_EXECUTABLE} SIZE 16
		SOURCE ${GEN_DIR}/blob${i} DESTINATION ${GEN_DIR}/blob${i}.png
		TILE_PATHS ${BLOB_PATHS}
	)
endforeach()

set(LINK_PATHS
	${GEN_DIR}/links/0.png
	${GEN_DIR}/links/1.png
	${GEN_DIR}/links/2.png
	${GEN_DIR}/links/3.png
	${GEN_DIR}/links/4.png
	${GEN_DIR}/links/5.png
	${GEN_DIR}/links/6.png
	${GEN_DIR}/links/7.png
	${GEN_DIR}/links/8.png
	${GEN_DIR}/links/9.png
	${GEN_DIR}/links/10.png
	${GEN_DIR}/links/11.png
	${GEN_DIR}/links/12.png
)
convertTileset(
	TARGET ${GERMZ_EXECUTABLE} SIZE 16
	SOURCE ${GEN_DIR}/links DESTINATION ${GEN_DIR}/links.png
	TILE_PATHS ${LINK_PATHS}
)

set(BTN_SMALL_PATHS
	${GEN_DIR}/btn_small/0.png
	${GEN_DIR}/btn_small/1.png
	${GEN_DIR}/btn_small/2.png
	${GEN_DIR}/btn_small/3.png
	${GEN_DIR}/btn_small/4.png
	${GEN_DIR}/btn_small/5.png
	${GEN_DIR}/btn_small/6.png
	${GEN_DIR}/btn_small/7.png
	${GEN_DIR}/btn_small/8.png
)
convertTileset(
	TARGET ${GERMZ_EXECUTABLE} SIZE 16 HEIGHT 10
	SOURCE ${GEN_DIR}/btn_small DESTINATION ${GEN_DIR}/btn_small.png
	TILE_PATHS ${BTN_SMALL_PATHS}
)

set(BTN_BIG_PATHS
	${GEN_DIR}/btn_big/0.png
	${GEN_DIR}/btn_big/1.png
	${GEN_DIR}/btn_big/2.png
	${GEN_DIR}/btn_big/3.png
	${GEN_DIR}/btn_big/4.png
	${GEN_DIR}/btn_big/5.png
)
convertTileset(
	TARGET ${GERMZ_EXECUTABLE} SIZE 32 HEIGHT 10
	SOURCE ${GEN_DIR}/btn_big DESTINATION ${GEN_DIR}/btn_big.png
	TILE_PATHS ${BTN_BIG_PATHS}
)

set(LED_BIG_PATHS
	${GEN_DIR}/led_big/0.png
	${GEN_DIR}/led_big/1.png
	${GEN_DIR}/led_big/2.png
	${GEN_DIR}/led_big/3.png
	${GEN_DIR}/led_big/4.png
)
convertTileset(
	TARGET ${GERMZ_EXECUTABLE} SIZE 32 HEIGHT 10
	SOURCE ${GEN_DIR}/led_big DESTINATION ${GEN_DIR}/led_big.png
	TILE_PATHS ${LED_BIG_PATHS}
)

set(DISPLAY_PATHS
	${GEN_DIR}/display/0.png
	${GEN_DIR}/display/1.png
	${GEN_DIR}/display/2.png
	${GEN_DIR}/display/3.png
	${GEN_DIR}/display/4.png
	${GEN_DIR}/display/5.png
	${GEN_DIR}/display/6.png
	${GEN_DIR}/display/7.png
	${GEN_DIR}/display/8.png
)
convertTileset(
	TARGET ${GERMZ_EXECUTABLE} SIZE 16
	SOURCE ${GEN_DIR}/display DESTINATION ${GEN_DIR}/display.png
	TILE_PATHS ${DISPLAY_PATHS}
)

set(DIRS "up;down;left;right")
foreach(player RANGE 3)
	foreach(dir ${DIRS})
		set(PLEP_PATHS "")
		foreach(frame RANGE 23)
			list(APPEND PLEP_PATHS "${GEN_DIR}/plep${player}_${dir}/${frame}.png")
		endforeach()
		convertTileset(
			TARGET ${GERMZ_EXECUTABLE} SIZE 16
			SOURCE ${GEN_DIR}/plep${player}_${dir} DESTINATION ${GEN_DIR}/plep${player}_${dir}.png
			TILE_PATHS ${PLEP_PATHS}
		)
	endforeach()
endforeach()

# Convert to .bm
convertBitmaps(
	TARGET ${GERMZ_EXECUTABLE} PALETTE ${GERMZ_PLT_PATH} MASK_COLOR ${TRANSPARENCY_HEX}
	INTERLEAVED SOURCES
		${GEN_DIR}/cursors.png ${GEN_DIR}/blob0.png
		${GEN_DIR}/plep0_right.png ${GEN_DIR}/plep0_left.png
		${GEN_DIR}/plep0_up.png ${GEN_DIR}/plep0_down.png
		${GEN_DIR}/btn_big.png ${GEN_DIR}/btn_small.png
		${GEN_DIR}/led_big.png ${GEN_DIR}/led_small.png
		${GEN_DIR}/links.png
	DESTINATIONS
		${DATA_DIR}/cursors.bm ${DATA_DIR}/blob0.bm
		${DATA_DIR}/plep0_right.bm ${DATA_DIR}/plep0_left.bm
		${DATA_DIR}/plep0_up.bm ${DATA_DIR}/plep0_down.bm
		${DATA_DIR}/btn_big.bm ${DATA_DIR}/btn_small.bm
		${DATA_DIR}/led_big.bm ${DATA_DIR}/led_small.bm
		${DATA_DIR}/links.bm
	MASKS
		${DATA_DIR}/cursors_mask.bm ${DATA_DIR}/blob_mask.bm
		${DATA_DIR}/plep_right_mask.bm ${DATA_DIR}/plep_left_mask.bm
		${DATA_DIR}/plep_up_mask.bm ${DATA_DIR}/plep_down_mask.bm
		${DATA_DIR}/btn_big_mask.bm ${DATA_DIR}/btn_small_mask.bm
		${DATA_DIR}/led_big_mask.bm ${DATA_DIR}/led_small_mask.bm
		${DATA_DIR}/links_mask.bm
)

convertBitmaps(
	TARGET ${GERMZ_EXECUTABLE} PALETTE ${GERMZ_PLT_PATH}
	INTERLEAVED SOURCES
		${GEN_DIR}/blob1.png ${GEN_DIR}/blob2.png ${GEN_DIR}/blob3.png
		${GEN_DIR}/blob4.png ${GEN_DIR}/game_hud.png
		${GEN_DIR}/plep1_right.png ${GEN_DIR}/plep1_left.png
		${GEN_DIR}/plep1_up.png ${GEN_DIR}/plep1_down.png
		${GEN_DIR}/plep2_right.png ${GEN_DIR}/plep2_left.png
		${GEN_DIR}/plep2_up.png ${GEN_DIR}/plep2_down.png
		${GEN_DIR}/plep3_right.png ${GEN_DIR}/plep3_left.png
		${GEN_DIR}/plep3_up.png ${GEN_DIR}/plep3_down.png
		${GEN_DIR}/editor_hud.png ${GEN_DIR}/game_bg.png
		${RES_DIR}/menu_main.png ${RES_DIR}/menu_sub.png
		${GEN_DIR}/game_bg.png ${GEN_DIR}/display.png
	DESTINATIONS
		${DATA_DIR}/blob1.bm ${DATA_DIR}/blob2.bm ${DATA_DIR}/blob3.bm
		${DATA_DIR}/blob4.bm ${DATA_DIR}/game_hud.bm
		${DATA_DIR}/plep1_right.bm ${DATA_DIR}/plep1_left.bm
		${DATA_DIR}/plep1_up.bm ${DATA_DIR}/plep1_down.bm
		${DATA_DIR}/plep2_right.bm ${DATA_DIR}/plep2_left.bm
		${DATA_DIR}/plep2_up.bm ${DATA_DIR}/plep2_down.bm
		${DATA_DIR}/plep3_right.bm ${DATA_DIR}/plep3_left.bm
		${DATA_DIR}/plep3_up.bm ${DATA_DIR}/plep3_down.bm
		${DATA_DIR}/editor_hud.bm ${DATA_DIR}/game_bg.bm
		${DATA_DIR}/menu_main.bm ${DATA_DIR}/menu_sub.bm
		${DATA_DIR}/game_bg.bm ${DATA_DIR}/display.bm
)

convertBitmaps(
	TARGET ${GERMZ_EXECUTABLE} PALETTE ${LMC_PLT_PATH}
	INTERLEAVED SOURCES ${RES_DIR}/lmc.png DESTINATIONS ${DATA_DIR}/lmc.bm
)

convertBitmaps(
	TARGET ${GERMZ_EXECUTABLE} PALETTE ${RES_DIR}/ace.gpl
	INTERLEAVED SOURCES ${RES_DIR}/ace.png DESTINATIONS ${DATA_DIR}/ace.bm
)

foreach(intro_idx RANGE 7)
	convertPalette(
		${GERMZ_EXECUTABLE}
		${RES_DIR}/intro/${intro_idx}.pal ${DATA_DIR}/intro/${intro_idx}.plt
	)
	convertBitmaps(
		TARGET ${GERMZ_EXECUTABLE} PALETTE ${RES_DIR}/intro/${intro_idx}.pal
		SOURCES ${RES_DIR}/intro/${intro_idx}.png
		INTERLEAVED DESTINATIONS ${DATA_DIR}/intro/${intro_idx}.bm
	)
endforeach()

foreach(outro_idx RANGE 3)
	convertPalette(
		${GERMZ_EXECUTABLE}
		${RES_DIR}/outro/${outro_idx}.pal ${DATA_DIR}/outro/${outro_idx}.plt
	)
	convertBitmaps(
		TARGET ${GERMZ_EXECUTABLE} PALETTE ${RES_DIR}/outro/${outro_idx}.pal
		SOURCES ${RES_DIR}/outro/${outro_idx}.png
		INTERLEAVED DESTINATIONS ${DATA_DIR}/outro/${outro_idx}.bm
	)
endforeach()

convertBitmaps(
	TARGET ${GERMZ_EXECUTABLE} PALETTE ${MONO_PLT_PATH}
	SOURCES ${GEN_DIR}/hud_target.png DESTINATIONS ${DATA_DIR}/hud_target.bm
)

convertAudio(
	TARGET ${GERMZ_EXECUTABLE} SOURCE ${RES_DIR}/sfx/ace.wav
	DESTINATION ${DATA_DIR}/sfx/ace.sfx
)
convertAudio(
	TARGET ${GERMZ_EXECUTABLE} SOURCE ${RES_DIR}/sfx/lmc.wav
	STRICT DESTINATION ${DATA_DIR}/sfx/lmc.sfx
)
convertAudio(
	TARGET ${GERMZ_EXECUTABLE} SOURCE ${RES_DIR}/sfx/plep1.wav
	STRICT DESTINATION ${DATA_DIR}/sfx/plep1.sfx
)
convertAudio(
	TARGET ${GERMZ_EXECUTABLE} SOURCE ${RES_DIR}/sfx/plep2.wav
	STRICT DESTINATION ${DATA_DIR}/sfx/plep2.sfx
)

convertFont(
	TARGET ${GERMZ_EXECUTABLE} FIRST_CHAR 32
	SOURCE ${RES_DIR}/font_germz.png DESTINATION ${DATA_DIR}/germz.fnt
)

convertFont(
	TARGET ${GERMZ_EXECUTABLE} FIRST_CHAR 29
	SOURCE ${RES_DIR}/font_uni54.png DESTINATION ${DATA_DIR}/uni54.fnt
)

mergeMods(
	TARGET ${GERMZ_EXECUTABLE}
	SOURCES ${RES_DIR}/germz1.mod ${RES_DIR}/germz2.mod ${RES_DIR}/germz3.mod
	${RES_DIR}/germz4.mod ${RES_DIR}/germz5.mod ${RES_DIR}/germz6.mod
	DESTINATIONS ${DATA_DIR}/germz1.mod ${DATA_DIR}/germz2.mod ${DATA_DIR}/germz3.mod
	${DATA_DIR}/germz4.mod ${DATA_DIR}/germz5.mod ${DATA_DIR}/germz6.mod
	SAMPLE_PACK ${DATA_DIR}/samples.samplepack
)

# Copy maps and defs
file(
	COPY
		${RES_DIR}/maps ${RES_DIR}/defs.json
	DESTINATION ${DATA_DIR}
)

# Generating ZIP
set(GERMZ_ZIP_NAME "${CMAKE_PROJECT_NAME} ${VER_MAJOR}_${VER_MINOR}_${VER_FIX}")
add_custom_target(generateZip COMMAND
	${CMAKE_COMMAND} -E tar "cf" "${GERMZ_ZIP_NAME}.zip" --format=zip
	"${CMAKE_CURRENT_BINARY_DIR}/${GERMZ_OUTPUT_EXECUTABLE}" "${DATA_DIR}"
	COMMENT "Generating ${GERMZ_ZIP_NAME}.zip"
)

# Generating ADF
set(ADF_DIR "${CMAKE_CURRENT_BINARY_DIR}/adf")
add_custom_target(generateAdf
	COMMAND ${CMAKE_COMMAND} -E make_directory "${ADF_DIR}/s"
	COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_BINARY_DIR}/${GERMZ_OUTPUT_EXECUTABLE}" "${ADF_DIR}"
	COMMAND ${CMAKE_COMMAND} -E copy_directory "${DATA_DIR}" "${ADF_DIR}/data"
	COMMAND ${CMAKE_COMMAND} -E echo "${GERMZ_OUTPUT_EXECUTABLE}" > "${ADF_DIR}/s/startup-sequence"
	COMMAND exe2adf -l ${CMAKE_PROJECT_NAME} -a "${CMAKE_PROJECT_NAME}.adf" -d ${ADF_DIR}
	COMMAND ${CMAKE_COMMAND} -E rm -rf "${ADF_DIR}"
	COMMENT "Generating ADF file"
)
