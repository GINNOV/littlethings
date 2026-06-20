file(MAKE_DIRECTORY ${GEN_DIR}/base3)

extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/base3.png
	GENERATED_FILE_LIST "TILES_BASE3_LIST"
	DESTINATIONS
	${GEN_DIR}/base3/0.png   32 192 32 32 # TILE_BASE_BG_FIRST
	${GEN_DIR}/base3/1.png   64 192 32 32
	${GEN_DIR}/base3/2.png   96 192 32 32
	${GEN_DIR}/base3/3.png    0 160 32 32 # Dummy
	${GEN_DIR}/base3/4.png   32 160 32 32 # Dummy
	${GEN_DIR}/base3/5.png  128 160 32 32 # Dummy
	${GEN_DIR}/base3/6.png  160 160 32 32 # Dummy
	${GEN_DIR}/base3/7.png  224 160 32 32 # Dummy
	${GEN_DIR}/base3/8.png  224 160 32 32 # Dummy
	${GEN_DIR}/base3/9.png  224 160 32 32 # Dummy
	${GEN_DIR}/base3/10.png  224 160 32 32 # Dummy
	${GEN_DIR}/base3/11.png  224 160 32 32 # Dummy
	# Above surface: TILE_BASE_BG_FIRST + 12 .. 19
	${GEN_DIR}/base3/12.png   0 192 32 32 # Dummy
	${GEN_DIR}/base3/13.png  32 192 32 32 # Dummy
	${GEN_DIR}/base3/14.png 128 192 32 32 # Dummy
	${GEN_DIR}/base3/15.png 160 192 32 32 # Dummy
	${GEN_DIR}/base3/16.png 192 192 32 32 # Dummy
	${GEN_DIR}/base3/17.png 224 192 32 32 # Dummy
	${GEN_DIR}/base3/18.png 256 192 32 32 # Dummy
	${GEN_DIR}/base3/19.png 288 192 32 32 # Dummy
	# Surface: TILE_BASE_BG_FIRST + 20 .. 22
	${GEN_DIR}/base3/20.png   0 224 32 32 # Dummy
	${GEN_DIR}/base3/21.png   0 224 32 32 # Dummy
	${GEN_DIR}/base3/22.png   0 224 32 32 # Dummy
	# Ground layer
	${GEN_DIR}/base3/23.png   0 224 32 32
	${GEN_DIR}/base3/24.png  32 224 32 32
	${GEN_DIR}/base3/25.png  64 224 32 32
	${GEN_DIR}/base3/26.png  96 224 32 32
	${GEN_DIR}/base3/27.png 128 224 32 32
	${GEN_DIR}/base3/28.png 160 224 32 32
	${GEN_DIR}/base3/29.png 192 224 32 32
	${GEN_DIR}/base3/30.png 224 224 32 32
	${GEN_DIR}/base3/31.png 256 224 32 32
	${GEN_DIR}/base3/32.png 288 224 32 32
	# Rest of base tiles
	${GEN_DIR}/base3/34.png   0 256 32 32 # TILE_BASE_GROUND_1
	${GEN_DIR}/base3/35.png  32 256 32 32 # TILE_BASE_GROUND_2
	${GEN_DIR}/base3/36.png  64 256 32 32 # TILE_BASE_GROUND_3
	${GEN_DIR}/base3/37.png  96 256 32 32 # TILE_BASE_GROUND_4
	${GEN_DIR}/base3/38.png 128 256 32 32 # TILE_BASE_GROUND_5
	${GEN_DIR}/base3/33.png 160 256 32 32 # TILE_BASE_SHAFT
	${GEN_DIR}/base3/39.png 192 256 32 32 # TILE_BASE_GROUND_6
	${GEN_DIR}/base3/40.png 224 256 32 32 # TILE_BASE_GROUND_7
	${GEN_DIR}/base3/41.png 256 256 32 32 # TILE_BASE_GROUND_8
	${GEN_DIR}/base3/42.png 288 256 32 32 # TILE_BASE_GROUND_9
)

convertTileset(
	TARGET ${GAME_EXECUTABLE} SIZE 32 PALETTE ${palette_aminer_unique}
	INTERLEAVED SOURCE ${GEN_DIR}/base3 DESTINATION ${DATA_DIR}/base3.bm
	TILE_PATHS ${TILES_BASE3_LIST}
)
