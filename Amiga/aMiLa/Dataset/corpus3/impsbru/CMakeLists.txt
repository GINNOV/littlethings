cmake_minimum_required(VERSION 2.8.5)
project(impbru LANGUAGES C)

if(NOT AMIGA)
	message(SEND_ERROR "This project only compiles for Amiga")
endif()

# ACE
add_subdirectory(deps/ace ace)

set(CMAKE_C_STANDARD 11)
file(GLOB_RECURSE SOURCES src/*.c src/*.h)
add_executable(impsbru ${SOURCES})
target_include_directories(impsbru PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_compile_options(impsbru PUBLIC -Wall -Wextra)
target_link_libraries(impsbru ace)
if(GAME_DEBUG)
	target_compile_definitions(impsbru PRIVATE GAME_DEBUG)
	target_compile_definitions(ace PUBLIC ACE_DEBUG_UAE)
endif()

set(RES_DIR ${CMAKE_CURRENT_LIST_DIR}/res)
set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data)

# Directory preparation
file(
	MAKE_DIRECTORY
	${DATA_DIR}
	${DATA_DIR}/cross_frames
	${DATA_DIR}/editor_frames
	${DATA_DIR}/cube_frames
	${DATA_DIR}/menu_frames
	${DATA_DIR}/maps
)

# Copy example maps files as is
file(GLOB MAP_FILES "${RES_DIR}/maps/*.map")
file(COPY ${MAP_FILES} DESTINATION ${DATA_DIR}/maps)

# Palette
set(PLT_PATH ${DATA_DIR}/impsbru.plt)
set(TRANSPARENCY_HEX "#FF00FF")
convertPalette(impsbru ${RES_DIR}/impsbru.act ${PLT_PATH})

# Convert to .bm
convertBitmaps(
	TARGET impsbru PALETTE ${PLT_PATH} MASK_COLOR ${TRANSPARENCY_HEX}
	SOURCES
		${RES_DIR}/cross_frames/cross_0000s_0000_A-Final.png
		${RES_DIR}/cross_frames/cross_0000s_0001_C-Final.png
		${RES_DIR}/cross_frames/cross_0000s_0002_E-Final.png
		${RES_DIR}/cross_frames/cross_0003_Cursor.png
		${RES_DIR}/cross_frames/cross_0001s_0000_A.png
		${RES_DIR}/cross_frames/cross_0001s_0001_C.png
		${RES_DIR}/cross_frames/cross_0001s_0002_E.png
		${RES_DIR}/cross_frames/cross_0001s_0003_B.png
		${RES_DIR}/cross_frames/cross_0001s_0004_D.png
		${RES_DIR}/cross_frames/cross_0001s_0005_F.png
		${RES_DIR}/cross_frames/cross_0001s_0006_Center.png
		${RES_DIR}/cross_frames/cross_0000_Cleanup.png
		${RES_DIR}/cross_frames/cross_0001_Depth-mask-bottom.png
		${RES_DIR}/cross_frames/cross_0002_Depth-mask-middle.png
	DESTINATIONS
		${DATA_DIR}/cross_frames/a_final.bm
		${DATA_DIR}/cross_frames/c_final.bm
		${DATA_DIR}/cross_frames/e_final.bm
		${DATA_DIR}/cross_frames/cursor.bm
		${DATA_DIR}/cross_frames/a.bm
		${DATA_DIR}/cross_frames/c.bm
		${DATA_DIR}/cross_frames/e.bm
		${DATA_DIR}/cross_frames/b.bm
		${DATA_DIR}/cross_frames/d.bm
		${DATA_DIR}/cross_frames/f.bm
		${DATA_DIR}/cross_frames/center.bm
		${DATA_DIR}/cross_frames/cleanup.bm
		${DATA_DIR}/cross_frames/depth_mask_bottom.bm
		${DATA_DIR}/cross_frames/depth_mask_middle.bm
	MASKS
		${DATA_DIR}/cross_frames/a_final_mask.bm
		${DATA_DIR}/cross_frames/c_final_mask.bm
		${DATA_DIR}/cross_frames/e_final_mask.bm
		${DATA_DIR}/cross_frames/cursor_mask.bm
		${DATA_DIR}/cross_frames/a_mask.bm
		${DATA_DIR}/cross_frames/c_mask.bm
		${DATA_DIR}/cross_frames/e_mask.bm
		${DATA_DIR}/cross_frames/b_mask.bm
		${DATA_DIR}/cross_frames/d_mask.bm
		${DATA_DIR}/cross_frames/f_mask.bm
		${DATA_DIR}/cross_frames/center_mask.bm
		${DATA_DIR}/cross_frames/cleanup_mask.bm
		${DATA_DIR}/cross_frames/depth_mask_bottom_mask.bm
		${DATA_DIR}/cross_frames/depth_mask_middle_mask.bm
)

convertBitmaps(
	TARGET impsbru PALETTE ${PLT_PATH} MASK_COLOR ${TRANSPARENCY_HEX}
	SOURCES
		${RES_DIR}/cube_frames/cube.png
	DESTINATIONS
		${DATA_DIR}/cube_frames/cube.bm
	MASKS
		${DATA_DIR}/cube_frames/cube_mask.bm
)

convertBitmaps(
	TARGET impsbru PALETTE ${PLT_PATH} MASK_COLOR ${TRANSPARENCY_HEX}
	SOURCES
        ${RES_DIR}/editor_frames/editor_0000_Create.png
        ${RES_DIR}/editor_frames/editor_0001_Start-point.png
        ${RES_DIR}/editor_frames/editor_0002_Destination-point.png
        ${RES_DIR}/editor_frames/editor_0003_Play-test.png
        ${RES_DIR}/editor_frames/editor_0004_Share.png
        ${RES_DIR}/editor_frames/editor_0005_Share-1.png
	DESTINATIONS
        ${DATA_DIR}/editor_frames/create.bm
        ${DATA_DIR}/editor_frames/start_point.bm
        ${DATA_DIR}/editor_frames/destination_point.bm
        ${DATA_DIR}/editor_frames/play_test.bm
        ${DATA_DIR}/editor_frames/share.bm
        ${DATA_DIR}/editor_frames/share_text.bm
	MASKS
        ${DATA_DIR}/editor_frames/create_mask.bm
        ${DATA_DIR}/editor_frames/start_point_mask.bm
        ${DATA_DIR}/editor_frames/destination_point_mask.bm
        ${DATA_DIR}/editor_frames/play_test_mask.bm
        ${DATA_DIR}/editor_frames/share_mask.bm
        ${DATA_DIR}/editor_frames/share_text_mask.bm
)

convertBitmaps(
	TARGET impsbru PALETTE ${PLT_PATH} MASK_COLOR ${TRANSPARENCY_HEX}
	SOURCES
        ${RES_DIR}/menu_frames/logo.png
	DESTINATIONS
        ${DATA_DIR}/menu_frames/logo.bm
	MASKS
        ${DATA_DIR}/menu_frames/logo_mask.bm
)
