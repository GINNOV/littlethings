file(MAKE_DIRECTORY ${GEN_DIR}/base0)

extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/base0.png
	GENERATED_FILE_LIST "TILES_BASE0_LIST"
	DESTINATIONS
	${GEN_DIR}/base0/0.png    0   0 32 32 # TILE_BASE_BG_FIRST
	${GEN_DIR}/base0/1.png    0  32 32 32
	${GEN_DIR}/base0/2.png    0  64 32 32
	${GEN_DIR}/base0/3.png    0  96 32 32
	${GEN_DIR}/base0/4.png    0 128 32 32
	${GEN_DIR}/base0/5.png  288 128 32 32
	${GEN_DIR}/base0/6.png    0 160 32 32
	${GEN_DIR}/base0/7.png   64 160 32 32
	${GEN_DIR}/base0/8.png  160 160 32 32
	${GEN_DIR}/base0/9.png  192 160 32 32
	${GEN_DIR}/base0/10.png 224 160 32 32
	${GEN_DIR}/base0/11.png 256 160 32 32
	${GEN_DIR}/base0/12.png 288 160 32 32
	# Above surface: TILE_BASE_BG_FIRST + 13 .. 22
	${GEN_DIR}/base0/13.png   0 192 32 32
	${GEN_DIR}/base0/14.png  32 192 32 32
	${GEN_DIR}/base0/15.png  64 192 32 32
	${GEN_DIR}/base0/16.png  96 192 32 32
	${GEN_DIR}/base0/17.png 128 192 32 32
	${GEN_DIR}/base0/18.png 160 192 32 32
	${GEN_DIR}/base0/19.png 192 192 32 32
	${GEN_DIR}/base0/20.png 224 192 32 32
	${GEN_DIR}/base0/21.png 256 192 32 32
	${GEN_DIR}/base0/22.png 288 192 32 32
	# Surface: TILE_BASE_BG_FIRST + 23 .. 32
	${GEN_DIR}/base0/23.png   0 224 32 32
	${GEN_DIR}/base0/24.png  32 224 32 32
	${GEN_DIR}/base0/25.png  64 224 32 32
	${GEN_DIR}/base0/26.png  96 224 32 32
	${GEN_DIR}/base0/27.png 128 224 32 32
	${GEN_DIR}/base0/28.png 160 224 32 32
	${GEN_DIR}/base0/29.png 192 224 32 32
	${GEN_DIR}/base0/30.png 224 224 32 32
	${GEN_DIR}/base0/31.png 256 224 32 32
	${GEN_DIR}/base0/32.png 288 224 32 32
	# Rest of base tiles
	${GEN_DIR}/base0/33.png  32 256 32 32 # TILE_BASE_SHAFT
	${GEN_DIR}/base0/34.png   0 256 32 32 # TILE_BASE_GROUND_1
	${GEN_DIR}/base0/35.png  64 256 32 32 # TILE_BASE_GROUND_2
	${GEN_DIR}/base0/36.png  96 256 32 32 # TILE_BASE_GROUND_3
	${GEN_DIR}/base0/37.png 128 256 32 32 # TILE_BASE_GROUND_4
	${GEN_DIR}/base0/38.png 160 256 32 32 # TILE_BASE_GROUND_5
	${GEN_DIR}/base0/39.png 192 256 32 32 # TILE_BASE_GROUND_6
	${GEN_DIR}/base0/40.png 224 256 32 32 # TILE_BASE_GROUND_7
	${GEN_DIR}/base0/41.png 256 256 32 32 # TILE_BASE_GROUND_8
	${GEN_DIR}/base0/42.png 288 256 32 32 # TILE_BASE_GROUND_9
)

convertTileset(
	TARGET ${GAME_EXECUTABLE} SIZE 32 PALETTE ${palette_aminer_unique}
	INTERLEAVED SOURCE ${GEN_DIR}/base0 DESTINATION ${DATA_DIR}/base0.bm
	TILE_PATHS ${TILES_BASE0_LIST}
)
