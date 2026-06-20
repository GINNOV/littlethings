file(MAKE_DIRECTORY ${GEN_DIR}/tiles)
file(MAKE_DIRECTORY ${GEN_DIR}/tiles_overlay)

extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/dirt.png
	GENERATED_FILE_LIST "TILES_MAIN_LIST_1"
	DESTINATIONS
	${GEN_DIR}/tiles/43.png  66  0 32 32 # TILE_CAVE_BG_1
	${GEN_DIR}/tiles/44.png 231  0 32 32 # TILE_CAVE_BG_STONE_1
	${GEN_DIR}/tiles/45.png 264  0 32 32 # TILE_CAVE_BG_STONE_2
	${GEN_DIR}/tiles/46.png 231 33 32 32 # TILE_CAVE_BG_STONE_3
	${GEN_DIR}/tiles/47.png 264 33 32 32 # TILE_CAVE_BG_STONE_4
	${GEN_DIR}/tiles/48.png 231 66 32 32 # TILE_CAVE_BG_STONE_5
	${GEN_DIR}/tiles/49.png 264 66 32 32 # TILE_CAVE_BG_STONE_6
	${GEN_DIR}/tiles/50.png   0  0 32 32 # TILE_DIRT_1
	${GEN_DIR}/tiles/51.png  33  0 32 32 # TILE_DIRT_2
)

extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/dirt.png
	GENERATED_FILE_LIST "TILES_OVERLAY_LIST_1"
	DESTINATIONS
	# TILE_CAVE_BG edges:
	${GEN_DIR}/tiles_overlay/0.png  66 66 32 32 # N
	${GEN_DIR}/tiles_overlay/1.png   0 99 32 32 # S
	${GEN_DIR}/tiles_overlay/2.png  33 66 32 32 # NS
	${GEN_DIR}/tiles_overlay/3.png  99 66 32 32 # E
	${GEN_DIR}/tiles_overlay/4.png  66 99 32 32 # NE
	${GEN_DIR}/tiles_overlay/5.png  99 99 32 32 # SE
	${GEN_DIR}/tiles_overlay/6.png   0 33 32 32 # NSE
	${GEN_DIR}/tiles_overlay/7.png  33 99 32 32 # W
	${GEN_DIR}/tiles_overlay/8.png  33 132 32 32 # NW
	${GEN_DIR}/tiles_overlay/9.png   0 132 32 32 # SW
	${GEN_DIR}/tiles_overlay/10.png 99 33 32 32 # NSW
	${GEN_DIR}/tiles_overlay/11.png  0 66 32 32 # EW
	${GEN_DIR}/tiles_overlay/12.png 66 33 32 32 # NEW
	${GEN_DIR}/tiles_overlay/13.png 33 33 32 32 # SEW
	${GEN_DIR}/tiles_overlay/14.png 99  0 32 32 # NSEW
)

extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/minerals.png
	GENERATED_FILE_LIST "TILES_MAIN_LIST_3"
	DESTINATIONS
	${GEN_DIR}/tiles/52.png 34   1 32 32 # TILE_SILVER_1
	${GEN_DIR}/tiles/53.png 34  34 32 32 # TILE_SILVER_2
	${GEN_DIR}/tiles/54.png 34  67 32 32 # TILE_SILVER_3
	${GEN_DIR}/tiles/55.png  1   1 32 32 # TILE_GOLD_1
	${GEN_DIR}/tiles/56.png  1  34 32 32 # TILE_GOLD_2
	${GEN_DIR}/tiles/57.png  1  67 32 32 # TILE_GOLD_3
	${GEN_DIR}/tiles/58.png  1 298 32 32 # TILE_COAL_1
	${GEN_DIR}/tiles/59.png 34 298 32 32 # TILE_COAL_2
	${GEN_DIR}/tiles/60.png 67 298 32 32 # TILE_COAL_3
	${GEN_DIR}/tiles/61.png  67 331 32 32 # TILE_MAGMA_1
	${GEN_DIR}/tiles/62.png 100 331 32 32 # TILE_MAGMA_2
)

extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/checkpoint.png
	GENERATED_FILE_LIST "TILES_MAIN_LIST_4"
	DESTINATIONS
	${GEN_DIR}/tiles/63.png   0 0 32 32 # TILE_CHECKPOINT_1
	${GEN_DIR}/tiles/64.png  32 0 32 32 # TILE_CHECKPOINT_2
	${GEN_DIR}/tiles/65.png  64 0 32 32 # TILE_CHECKPOINT_3
	${GEN_DIR}/tiles/66.png  96 0 32 32 # TILE_CHECKPOINT_4
	${GEN_DIR}/tiles/67.png 128 0 32 32 # TILE_CHECKPOINT_5
	${GEN_DIR}/tiles/68.png 160 0 32 32 # TILE_CHECKPOINT_6
	${GEN_DIR}/tiles/69.png 192 0 32 32 # TILE_CHECKPOINT_7
	${GEN_DIR}/tiles/70.png 224 0 32 32 # TILE_CHECKPOINT_8
	${GEN_DIR}/tiles/71.png 256 0 32 32 # TILE_CHECKPOINT_9
	${GEN_DIR}/tiles/72.png 288 0 32 32 # TILE_CHECKPOINT_10
	)

extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/dirt.png
	GENERATED_FILE_LIST "TILES_MAIN_LIST_2"
	DESTINATIONS
		${GEN_DIR}/tiles/73.png 198  33 32 32 # TILE_STONE_1
		${GEN_DIR}/tiles/74.png 198  66 32 32 # TILE_STONE_2
		${GEN_DIR}/tiles/75.png 198  99 32 32 # TILE_STONE_2
		${GEN_DIR}/tiles/76.png 198 132 32 32 # TILE_STONE_2
)

	extractBitmaps(TARGET ${GAME_EXECUTABLE} SOURCE ${RES_DIR}/minerals.png
	GENERATED_FILE_LIST "TILES_MAIN_LIST_5"
	DESTINATIONS
		${GEN_DIR}/tiles/77.png  67 232 32 32 # TILE_EMERALD_1
		${GEN_DIR}/tiles/78.png  34 232 32 32 # TILE_EMERALD_2
		${GEN_DIR}/tiles/79.png   1 232 32 32 # TILE_EMERALD_3
		${GEN_DIR}/tiles/80.png  67 199 32 32 # TILE_RUBY_1
		${GEN_DIR}/tiles/81.png  34 199 32 32 # TILE_RUBY_2
		${GEN_DIR}/tiles/82.png   1 199 32 32 # TILE_RUBY_3
		${GEN_DIR}/tiles/83.png  67 265 32 32 # TILE_MOONSTONE_1
		${GEN_DIR}/tiles/84.png  34 265 32 32 # TILE_MOONSTONE_2
		${GEN_DIR}/tiles/85.png   1 265 32 32 # TILE_MOONSTONE_3
		${GEN_DIR}/tiles/86.png  34 331 32 32 # TILE_BONE_HEAD
		${GEN_DIR}/tiles/87.png   1 331 32 32 # TILE_BONE_1
		${GEN_DIR}/tiles/88.png 133   1 32 32 # TILE_CRATE_1
		${GEN_DIR}/tiles/89.png 133  67 32 32 # TILE_GATE_1
		${GEN_DIR}/tiles/90.png 133 100 32 32 # TILE_GATE_2
)

convertTileset(
	TARGET ${GAME_EXECUTABLE} SIZE 32 PALETTE ${palette_aminer_unique}
	INTERLEAVED SOURCE ${GEN_DIR}/tiles DESTINATION ${DATA_DIR}/tiles.bm
	TILE_PATHS
		${TILES_MAIN_LIST_1} ${TILES_MAIN_LIST_2} ${TILES_MAIN_LIST_3}
		${TILES_MAIN_LIST_4} ${TILES_MAIN_LIST_5}
)

convertTileset(
	TARGET ${GAME_EXECUTABLE} SIZE 32
	INTERLEAVED SOURCE ${GEN_DIR}/tiles_overlay DESTINATION ${GEN_DIR}/tiles_overlay.png
	TILE_PATHS ${TILES_OVERLAY_LIST_1}
)

convertBitmaps(
	TARGET ${GAME_EXECUTABLE} PALETTE ${palette_aminer_unique} MASK_COLOR "#221100"
	INTERLEAVED SOURCES ${GEN_DIR}/tiles_overlay.png
	DESTINATIONS ${DATA_DIR}/tiles_overlay.bm
	MASKS ${DATA_DIR}/tiles_overlay_masks.bm
)
