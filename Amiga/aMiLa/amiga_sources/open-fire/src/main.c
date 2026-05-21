#include "main.h"
#include <ace/generic/main.h>
#include <ace/managers/game.h>

#include "config.h"
#include "input.h"
#include "gamestates/precalc/precalc.h"

void genericCreate(void) {
	inputOpen();
	gamePushState(precalcCreate, precalcLoop, precalcDestroy);
}

void genericProcess(void) {
	inputProcess();
	gameProcess();
}

void genericDestroy(void) {
	inputClose();
}
