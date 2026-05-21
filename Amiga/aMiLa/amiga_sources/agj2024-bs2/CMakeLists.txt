cmake_minimum_required(VERSION 3.14.0)
project(shmupace)

# Lowercase project name for binaries and packaging
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)

# Version number in format X.Y.Z
set(VER_X  0)
set(VER_Y 0)
set(VER_Z 1)
set(VER_FULL "${VER_X}.${VER_Y}.${VER_Z}")

if(NOT AMIGA)
  message(SEND_ERROR "This project only compiles for Amiga")
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DAMIGA -Wall -Wextra -fomit-frame-pointer")
#set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DACE_DEBUG")
file(GLOB_RECURSE SOURCES src/*.c src/*.vasm)
file(GLOB_RECURSE HEADERS src/*.h)

list(APPEND CMAKE_MODULE_PATH "../../AmigaCMakeCrossToolchains/Modules/m68k-amigaos")

include_directories(${PROJECT_SOURCE_DIR}/src)
include_directories(ace/include)

set(RES_DIR ${CMAKE_CURRENT_LIST_DIR}/res)
set(DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/data)

# ACE
set(AUDIO_MIXER_HW_CHANNEL_MODE "SINGLE")
set(AUDIO_MIXER_WORD_SIZED ON)
set(AUDIO_MIXER_ROUND_TO_32 ON)
set(AUDIO_MIXER_PROFILER OFF)
set(AUDIO_MIXER_HW_CHANNELS 3)
set(AUDIO_MIXER_SW_CHANNEL_COUNT 3)
set(AUDIO_MIXER_PERIOD 161)
set(ACE_BOB_PRISTINE_BUFFER ON)
set(ACE_TILEBUFFER_TILE_TYPE UWORD)
set(ACE_SCROLLBUFFER_ENABLE_SCROLL_X OFF)
set(ACE_SCROLLBUFFER_X_MARGIN_SIZE 1)
set(ACE_SCROLLBUFFER_Y_MARGIN_SIZE 2)
set(ACE_SCROLLBUFFER_POT_BITMAP_HEIGHT ON)

add_subdirectory(ace)
add_subdirectory(ace_audio_mixer ace_audio_mixer)

# Linux/other UNIX get a lower-case binary name
set(TARGET_NAME ${PROJECT_NAME_LOWER})

if(ELF2HUNK)
  # Add elf2hunk step for Bartman compiler
  set(GAME_LINKED ${TARGET_NAME}.elf) # Intermediate executable
  set(GAME_EXE ${TARGET_NAME}.exe) # Use this to launch the game
  add_executable(${GAME_LINKED} ${SOURCES} ${HEADERS})
  add_custom_command(
    TARGET ${GAME_LINKED} POST_BUILD
    COMMAND ${ELF2HUNK} ${GAME_LINKED} ${GAME_EXE}
  )
else()
  # Just produce the executable with Bebbo compiler
  SET(GAME_LINKED ${TARGET_NAME})
  SET(GAME_EXE ${TARGET_NAME})
  add_executable(${GAME_LINKED} ${SOURCES} ${HEADERS})
endif()

target_link_libraries(${GAME_LINKED} ace_audio_mixer ace)

# Copy example maps files as is
file(COPY "${RES_DIR}/*" DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
