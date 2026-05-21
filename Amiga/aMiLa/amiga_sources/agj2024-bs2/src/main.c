#include <ace/generic/main.h>
#include "main.h"

UBYTE g_ubLoopIteration = 0;
UBYTE g_ubCurrentStage = 0;
ULONG g_ulPlayerScore = 0;
UBYTE g_ubEquippedProjectileType = 0;
UBYTE g_ubPlayerLives = PLAYER_LIVES_START;
UBYTE g_ubPlayerSpecial = PLAYER_SPECIAL_START;

tPakFile *g_pPakFile;
tStateManager *g_pGameStateManager = 0;
tState g_pGameStates[GAME_STATES] = {
  [STATE_INTRO] = {.cbCreate = introGsCreate, .cbLoop = introGsLoop, .cbDestroy = introGsDestroy},
  [STATE_GAME] = {.cbCreate = gameGsCreate, .cbLoop = gameGsLoop, .cbDestroy = gameGsDestroy},
  [STATE_INTERMISSION] = {.cbCreate = intermissionGsCreate, .cbLoop = intermissionGsLoop, .cbDestroy = intermissionGsDestroy},
  [STATE_SCORE] = {.cbCreate = highscoreGsCreate, .cbLoop = highscoreGsLoop, .cbDestroy = highscoreGsDestroy},
  [STATE_WIN] = {.cbCreate = winGsCreate, .cbLoop = winGsLoop, .cbDestroy = winGsDestroy},
};

void genericCreate(void) {
  keyCreate();
  joyOpen();
  g_pPakFile = pakFileOpen("data.tte");
  g_pGameStateManager = stateManagerCreate();
  stateChange(g_pGameStateManager, &g_pGameStates[STATE_INTRO]);
}

void genericProcess(void) {
  keyProcess();
  joyProcess();
  stateProcess(g_pGameStateManager);
}

void genericDestroy(void) {
  stateManagerDestroy(g_pGameStateManager);
  pakFileClose(g_pPakFile);
  keyDestroy();
  joyClose();
}