#include "debug.h"
#include <ace/utils/custom.h>

UBYTE s_isDebug = 0;

void debugToggle(void) {
	s_isDebug = !s_isDebug;
}

void debugColor(UWORD uwColor) {
	if(s_isDebug) {
		g_pCustom->color[0] = uwColor;
	}
}

