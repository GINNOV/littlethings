cmake_minimum_required(VERSION 2.8.5)
project(atarenium LANGUAGES C)

# ACE
add_subdirectory(ACE ace)

add_executable(
	falkon.elf
	main.c game.c menu.c gameover.c intro.c credits.c score.c wungiel.c guruMastah.c leakedGameOver.c lmcAce.c
) # Compiler emits .elf file, we need hunk for Amiga

target_compile_options(falkon.elf PRIVATE -Wall -Wextra)

target_link_libraries(falkon.elf ace)
#target_compile_definitions(ace PUBLIC ACE_DEBUG ACE_DEBUG_UAE)

if(NOT (CMAKE_BUILD_TYPE STREQUAL "Debug") AND NOT (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo"))
    set(ELF2HUNK_ARGS ${ELF2HUNK_ARGS} -s)
endif()

add_custom_command( # So call elf2hunk
	TARGET falkon.elf POST_BUILD
	COMMAND ${ELF2HUNK} falkon.elf falkon.exe ${ELF2HUNK_ARGS}
)

set(RES_DIR ${CMAKE_CURRENT_LIST_DIR}/res) # st�d bierzemy pliki do konwersji
set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data) # tu maj� l�dowa�
file(MAKE_DIRECTORY ${DATA_DIR}) #za���my data

set(LMC_PLT_PATH ${DATA_DIR}/lmcpalette.plt)
set(ACE_GPL_PATH ${RES_DIR}/ace.gpl)
convertPalette(falkon.elf ${RES_DIR}/lmc.gpl ${LMC_PLT_PATH})

convertBitmaps(
	TARGET falkon.elf PALETTE ${LMC_PLT_PATH}
	INTERLEAVED SOURCES ${RES_DIR}/LMC.png
	DESTINATIONS ${DATA_DIR}/LMC.bm
)

convertBitmaps(
	TARGET falkon.elf PALETTE ${ACE_GPL_PATH}
	INTERLEAVED SOURCES ${RES_DIR}/ace_4col.png
	DESTINATIONS ${DATA_DIR}/ace.bm
)

convertFont(
    TARGET falkon.elf FIRST_CHAR 32
    SOURCE ${RES_DIR}/topaz.png DESTINATION ${DATA_DIR}/topaz.fnt
)
convertFont(
    TARGET falkon.elf FIRST_CHAR 32
    SOURCE ${RES_DIR}/gotekFont.png DESTINATION ${DATA_DIR}/gotekFont.fnt
)

	set(PLT_PATH ${DATA_DIR}/falkon.plt ) #tak si� b�dzie nazywa� docelowa paleta
convertPalette(falkon.elf ${RES_DIR}/falkon.pal ${PLT_PATH}) # z res/falkon.pal do build/data/falkon.plt

convertBitmaps(
	TARGET falkon.elf PALETTE ${PLT_PATH}
	INTERLEAVED SOURCES
		${RES_DIR}/amiHUD.png ${RES_DIR}/amiHUD_LED_OFF_green.png ${RES_DIR}/amiHUD_LED_OFF_yellow.png
	DESTINATIONS
	${DATA_DIR}/amiHUD.bm ${DATA_DIR}/amiHUD_LED_OFF_green.bm ${DATA_DIR}/amiHUD_LED_OFF_yellow.bm
)

convertBitmaps(
	TARGET falkon.elf PALETTE ${PLT_PATH}
	INTERLEAVED SOURCES
		${RES_DIR}/menulogo.png ${RES_DIR}/menuoptions.png ${RES_DIR}/menulmc.png
		${RES_DIR}/gej_ower.png ${RES_DIR}/HUD.png
		${RES_DIR}/tlo1.png ${RES_DIR}/tlo2.png ${RES_DIR}/tlo3.png
		${RES_DIR}/tlo4.png ${RES_DIR}/tlo5.png ${RES_DIR}/tlo6.png
		${RES_DIR}/vampire.png ${RES_DIR}/falkon_robbo.png
	DESTINATIONS
		${DATA_DIR}/menulogo.bm ${DATA_DIR}/menuoptions.bm  ${DATA_DIR}/menulmc.bm
		${DATA_DIR}/gej_ower.bm ${DATA_DIR}/HUD.bm
		${DATA_DIR}/tlo1.bm ${DATA_DIR}/tlo2.bm ${DATA_DIR}/tlo3.bm
		${DATA_DIR}/tlo4.bm ${DATA_DIR}/tlo5.bm ${DATA_DIR}/tlo6.bm
		${DATA_DIR}/vampire.bm ${DATA_DIR}/falkon_robbo.bm
)


convertBitmaps(
	TARGET falkon.elf PALETTE ${PLT_PATH}
	MASK_COLOR "#880088"
	INTERLEAVED SOURCES ${RES_DIR}/tileset.png ${RES_DIR}/tileset2.png ${RES_DIR}/saberman.png
	DESTINATIONS ${DATA_DIR}/tileset.bm ${DATA_DIR}/tileset2.bm ${DATA_DIR}/saberman.bm
	MASKS ${DATA_DIR}/tileset_mask.bm ${DATA_DIR}/tileset_mask2.bm ${DATA_DIR}/saberman_mask.bm

)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/falkonEngine.wav
    DESTINATION ${DATA_DIR}/falkonEngine.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/Atari.wav
    DESTINATION ${DATA_DIR}/Atari.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/AceSample.wav
    DESTINATION ${DATA_DIR}/AceSample.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/cap11025.wav
    DESTINATION ${DATA_DIR}/cap11025.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/LadujWegiel.wav
    DESTINATION ${DATA_DIR}/LadujWegiel.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/robbo8000.wav
    DESTINATION ${DATA_DIR}/robbo8000.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/Morse_LMC8000.wav
    DESTINATION ${DATA_DIR}/Morse_LMC8000.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/AceSample.wav
    DESTINATION ${DATA_DIR}/AceSample.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/wicherEngine.wav
    DESTINATION ${DATA_DIR}/wicherEngine.sfx
)

convertAudio(
    TARGET falkon.elf 	SOURCE ${RES_DIR}/portalSfx8000.wav
    DESTINATION ${DATA_DIR}/portalSfx8000.sfx
)

file(
	COPY ${RES_DIR}/topaz.fnt ${RES_DIR}/mod.falkon ${RES_DIR}/mod.falkon-ambient2
	DESTINATION ${DATA_DIR}
)
