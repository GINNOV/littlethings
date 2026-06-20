file(MAKE_DIRECTORY ${GEN_DIR}/base2)

extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/base2.png
	GENERATED_FILE_LIST "TILES_BASE2_LIST"
	DESTINATIONS
	${GEN_DIR}/base2/0.png    0 128 32 32 # TILE_BASE_BG_FIRST
	${GEN_DIR}/base2/1.png   32 128 32 32
	${GEN_DIR}/base2/2.png  128 128 32 32
	${GEN_DIR}/base2/3.png  160 128 32 32
	${GEN_DIR}/base2/4.png    0 160 32 32
	${GEN_DIR}/base2/5.png   32 160 32 32
	${GEN_DIR}/base2/6.png  128 160 32 32
	${GEN_DIR}/base2/7.png  160 160 32 32
	${GEN_DIR}/base2/8.png  224 160 32 32
	${GEN_DIR}/base2/9.png  256 160 32 32
	${GEN_DIR}/base2/10.png  224 160 32 32 # Dummy
	${GEN_DIR}/base2/11.png  224 160 32 32 # Dummy
	# Above surface: TILE_BASE_BG_FIRST + 12 .. 19
	${GEN_DIR}/base2/12.png   0 192 32 32
	${GEN_DIR}/base2/13.png  32 192 32 32
	${GEN_DIR}/base2/14.png 128 192 32 32
	${GEN_DIR}/base2/15.png 160 192 32 32
	${GEN_DIR}/base2/16.png 192 192 32 32
	${GEN_DIR}/base2/17.png 224 192 32 32
	${GEN_DIR}/base2/18.png 256 192 32 32
	${GEN_DIR}/base2/19.png 288 192 32 32
	# Surface: TILE_BASE_BG_FIRST + 20 .. 29
	${GEN_DIR}/base2/20.png   0 224 32 32
	${GEN_DIR}/base2/21.png  32 224 32 32
	${GEN_DIR}/base2/22.png  64 224 32 32
	${GEN_DIR}/base2/23.png  96 224 32 32
	${GEN_DIR}/base2/24.png 128 224 32 32
	${GEN_DIR}/base2/25.png 160 224 32 32
	${GEN_DIR}/base2/26.png 192 224 32 32
	${GEN_DIR}/base2/27.png 224 224 32 32
	${GEN_DIR}/base2/28.png 256 224 32 32
	${GEN_DIR}/base2/29.png 288 224 32 32
	# Dummy
	${GEN_DIR}/base2/30.png   0   0 32 32
	${GEN_DIR}/base2/31.png   0   0 32 32
	${GEN_DIR}/base2/32.png   0   0 32 32
	# Rest of base tiles
	${GEN_DIR}/base2/34.png   0 256 32 32 # TILE_BASE_GROUND_1
	${GEN_DIR}/base2/35.png  32 256 32 32 # TILE_BASE_GROUND_2
	${GEN_DIR}/base2/36.png  64 256 32 32 # TILE_BASE_GROUND_3
	${GEN_DIR}/base2/37.png  96 256 32 32 # TILE_BASE_GROUND_4
	${GEN_DIR}/base2/38.png 128 256 32 32 # TILE_BASE_GROUND_5
	${GEN_DIR}/base2/33.png 160 256 32 32 # TILE_BASE_SHAFT
	${GEN_DIR}/base2/39.png 192 256 32 32 # TILE_BASE_GROUND_6
	${GEN_DIR}/base2/40.png 224 256 32 32 # TILE_BASE_GROUND_7
	${GEN_DIR}/base2/41.png 256 256 32 32 # TILE_BASE_GROUND_8
	${GEN_DIR}/base2/42.png 288 256 32 32 # TILE_BASE_GROUND_9
)

convertTileset(
	TARGET ${GAME_EXECUTABLE} SIZE 32 PALETTE ${palette_aminer_unique}
	INTERLEAVED SOURCE ${GEN_DIR}/base2 DESTINATION ${DATA_DIR}/base2.bm
	TILE_PATHS ${TILES_BASE2_LIST}
)
