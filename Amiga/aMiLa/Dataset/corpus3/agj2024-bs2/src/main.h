#ifndef _MAIN_H_
#define _MAIN_H_

#include <ace/types.h>
#include <ace/generic/screen.h>
#include <ace/managers/game.h>
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/viewport/tilebuffer.h>
#include <ace/managers/blit.h>
#include <ace/managers/bob.h>
#include <ace/managers/copper.h>
#include <ace/managers/memory.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/managers/ptplayer.h>
#include <ace/managers/rand.h>
#include <ace/managers/sprite.h>
#include <ace/managers/state.h>
#include <ace/managers/system.h>
#include <ace/utils/font.h>
#include <ace/utils/palette.h>
#include <ace/utils/string.h>
#include <ace/utils/disk_file.h>
#include <ace/utils/pak_file.h>
#include <fixmath/fixmath.h>
#include "../ace_audio_mixer/include/ace/contrib/managers/audio_mixer.h"

#define GAME_BPP 5
#define GAME_STATES 5
#define GAME_STAGES 4
#define FIRST_STAGE 0
#define SECOND_STAGE 1
#define THIRD_STAGE 2
#define BOSS_STAGE 3
#define PLAYER_LIVES_START 3
#define PLAYER_SPECIAL_START 2

void introGsCreate(void);
void introGsLoop(void);
void introGsDestroy(void);

void gameGsCreate(void);
void gameGsLoop(void);
void gameGsDestroy(void);

void intermissionGsCreate(void);
void intermissionGsLoop(void);
void intermissionGsDestroy(void);

void highscoreGsCreate(void);
void highscoreGsLoop(void);
void highscoreGsDestroy(void);

void winGsCreate(void);
void winGsLoop(void);
void winGsDestroy(void);

typedef enum tGameState {
    STATE_INTRO,
    STATE_GAME,
    STATE_INTERMISSION,
    STATE_SCORE,
    STATE_WIN
} tGameState;

extern tPakFile *g_pPakFile;
extern tStateManager *g_pGameStateManager;
extern tState g_pGameStates[GAME_STATES];
extern ULONG g_ulPlayerScore;
extern UBYTE g_ubPlayerLives;
extern UBYTE g_ubPlayerSpecial;
extern UBYTE g_ubEquippedProjectileType;
extern UBYTE g_ubCurrentStage;
extern UBYTE g_ubLoopIteration;

#endif // _MAIN_H_