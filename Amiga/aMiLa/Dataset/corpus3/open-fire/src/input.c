#include "input.h"
#include <ace/managers/mouse.h>
#include <ace/managers/joy.h>

/* Globals */

/* Functions */
void inputOpen() {
	mouseCreate(MOUSE_PORT_1);
	keyCreate();
}

void inputProcess() {
	mouseProcess();
	keyProcess();
}

void inputClose() {
	mouseDestroy();
	keyDestroy();
}
