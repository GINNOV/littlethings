cmake_minimum_required(VERSION 3.14.0)
project(ace_audio_mixer VERSION 3.1 LANGUAGES C ASM_VASM)

include(mixer_config.cmake)
file(GLOB_RECURSE ACE_MIXER_SOURCES src/ace/*.c inc/ace/*.h src/mixer.asm)
add_library(ace_audio_mixer OBJECT ${ACE_MIXER_SOURCES})
target_include_directories(ace_audio_mixer PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)
target_include_directories(ace_audio_mixer PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(ace_audio_mixer PUBLIC ace)

if(AUDIO_MIXER_WORD_SIZED)
	target_compile_definitions(ace_audio_mixer PUBLIC MIXER_WORDSIZED)
endif()

if(AUDIO_MIXER_68020)
	target_compile_definitions(ace_audio_mixer PUBLIC MIXER_68020)
endif()

if(AUDIO_MIXER_HW_CHANNEL_MODE STREQUAL "SINGLE")
	target_compile_definitions(ace_audio_mixer PUBLIC MIXER_SINGLE)
elseif(AUDIO_MIXER_HW_CHANNEL_MODE STREQUAL "MULTI_PAIRED")
	target_compile_definitions(ace_audio_mixer PUBLIC MIXER_MULTI_PAIRED)
endif()

target_sources(ace_audio_mixer INTERFACE ${MIXER_OBJ_FILE})
