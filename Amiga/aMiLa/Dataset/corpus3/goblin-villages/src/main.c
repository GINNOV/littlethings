#include "main.h"

int main(void) {
	logOpen();
	memlogOpen();
	randInit(0);
	
	inputOpen();
	windowCreate();
	blitManagerCreate(0, 0);
	
	globalCreate();
	
	gameCreate(gsMenuCreate, gsMenuSplashSetup, gsMenuDestroy);
	
	while (gameIsRunning()) {
		timerProcess();
		inputProcess();
		gameProcess();
	}
	
	gameDestroy();
	
	blitManagerDestroy();
	globalDestroy();
	windowDestroy();
	inputClose();

	memlogClose();
	logClose();
	
	return EXIT_SUCCESS;
}