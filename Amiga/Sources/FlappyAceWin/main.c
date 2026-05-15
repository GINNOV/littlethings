/*Use this only if you want to enable logging to file instead of UAE console (heavy performance hit, not recommended)*/ 
//#define GENERIC_MAIN_LOG_PATH "game.log"

#include <ace/generic/main.h>
#include <ace/managers/key.h>
#include <ace/managers/state.h>
// Without it compiler will yell about undeclared gameGsCreate etc
#include "src/game.h"
#include "src/menu.h"
#include "src/states.h"

tStateManager *g_pStateManager;
tState *g_pGameState;
tState *g_pMenuState;

void genericCreate(void) {
  // Here goes your startup code
  keyCreate(); // We'll use keyboard
  timerCreate();
  // Initialize gamestate
  g_pStateManager = stateManagerCreate();
  g_pGameState = stateCreate(gameGsCreate, gameGsLoop, gameGsDestroy, 0, 0);
  g_pMenuState = stateCreate(menuGsCreate, menuGsLoop, menuGsDestroy, 0, 0);
  statePush(g_pStateManager, g_pGameState);
}

void genericProcess(void) {
  // Here goes code done each game frame
  keyProcess();
  timerProcess();
  stateProcess(g_pStateManager); // Process current gamestate's loop
}

void genericDestroy(void) {
  // Here goes your cleanup code
  stateManagerDestroy(g_pStateManager);
  stateDestroy(g_pGameState);
  keyDestroy(); // We don't need it anymore
  logWrite("Goodbye, Amiga!\n");
}