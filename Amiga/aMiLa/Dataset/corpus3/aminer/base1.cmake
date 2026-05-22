file(MAKE_DIRECTORY ${GEN_DIR}/base1)
file(MAKE_DIRECTORY ${GEN_DIR}/base1_populated)

# Make the scientist part at the end of the bg tiles so that they can be easily swapped out
extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/base1.png
	GENERATED_FILE_LIST "TILES_BASE1_LIST"
	DESTINATIONS
	# BG row 1
	${GEN_DIR}/base1/0.png    0 160 32 32 # TILE_BASE_BG_FIRST
	${GEN_DIR}/base1/1.png   32 160 32 32
	${GEN_DIR}/base1/2.png   64 160 32 32
	${GEN_DIR}/base1/3.png   96 160 32 32
	${GEN_DIR}/base1/4.png  128 160 32 32
	${GEN_DIR}/base1/5.png  160 160 32 32
	${GEN_DIR}/base1/6.png  192 160 32 32
	${GEN_DIR}/base1/7.png  224 160 32 32
	${GEN_DIR}/base1/8.png  256 160 32 32
	${GEN_DIR}/base1/9.png  288 160 32 32
	# BG row 2
	${GEN_DIR}/base1/20.png   0 192 32 32
	${GEN_DIR}/base1/21.png  32 192 32 32
	${GEN_DIR}/base1/22.png  64 192 32 32
	${GEN_DIR}/base1/23.png  96 192 32 32
	${GEN_DIR}/base1/24.png 128 192 32 32
	${GEN_DIR}/base1/10.png 160 192 32 32
	${GEN_DIR}/base1/11.png 192 192 32 32
	${GEN_DIR}/base1/12.png 224 192 32 32
	${GEN_DIR}/base1/13.png 256 192 32 32
	${GEN_DIR}/base1/14.png 288 192 32 32
	# BG row 3
	${GEN_DIR}/base1/25.png   0 224 32 32
	${GEN_DIR}/base1/26.png  32 224 32 32
	${GEN_DIR}/base1/27.png  64 224 32 32
	${GEN_DIR}/base1/28.png  96 224 32 32
	${GEN_DIR}/base1/29.png 128 224 32 32
	${GEN_DIR}/base1/15.png 160 224 32 32
	${GEN_DIR}/base1/16.png 192 224 32 32
	${GEN_DIR}/base1/17.png 224 224 32 32
	${GEN_DIR}/base1/18.png 256 224 32 32
	${GEN_DIR}/base1/19.png 288 224 32 32
	# Rest of base tiles
	${GEN_DIR}/base1/34.png   0 256 32 32 # TILE_BASE_GROUND_1
	${GEN_DIR}/base1/35.png  32 256 32 32 # TILE_BASE_GROUND_2
	${GEN_DIR}/base1/36.png  64 256 32 32 # TILE_BASE_GROUND_3
	${GEN_DIR}/base1/37.png  96 256 32 32 # TILE_BASE_GROUND_4
	${GEN_DIR}/base1/38.png 128 256 32 32 # TILE_BASE_GROUND_5
	${GEN_DIR}/base1/33.png 160 256 32 32 # TILE_BASE_SHAFT
	${GEN_DIR}/base1/39.png 192 256 32 32 # TILE_BASE_GROUND_6
	${GEN_DIR}/base1/40.png 224 256 32 32 # TILE_BASE_GROUND_7
	${GEN_DIR}/base1/41.png 256 256 32 32 # TILE_BASE_GROUND_8
	${GEN_DIR}/base1/42.png 288 256 32 32 # TILE_BASE_GROUND_9
)
extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/base1_populated.png
	GENERATED_FILE_LIST "TILES_BASE1_POPULATED_LIST"
	DESTINATIONS
	# BG row 2
	${GEN_DIR}/base1_populated/0.png   0 192 32 32
	${GEN_DIR}/base1_populated/1.png  32 192 32 32
	${GEN_DIR}/base1_populated/2.png  64 192 32 32
	${GEN_DIR}/base1_populated/3.png  96 192 32 32
	${GEN_DIR}/base1_populated/4.png 128 192 32 32
	# BG row 3
	${GEN_DIR}/base1_populated/5.png   0 224 32 32
	${GEN_DIR}/base1_populated/6.png  32 224 32 32
	${GEN_DIR}/base1_populated/7.png  64 224 32 32
	${GEN_DIR}/base1_populated/8.png  96 224 32 32
	${GEN_DIR}/base1_populated/9.png 128 224 32 32
)

convertTileset(
	TARGET ${GAME_EXECUTABLE} SIZE 32 PALETTE ${palette_aminer_unique}
	INTERLEAVED SOURCE ${GEN_DIR}/base1 DESTINATION ${DATA_DIR}/base1.bm
	TILE_PATHS ${TILES_BASE1_LIST}
)
convertTileset(
	TARGET ${GAME_EXECUTABLE} SIZE 32 PALETTE ${palette_aminer_unique}
	INTERLEAVED SOURCE ${GEN_DIR}/base1_populated DESTINATION ${DATA_DIR}/base1_populated.bm
	TILE_PATHS ${TILES_BASE1_POPULATED_LIST}
)
