/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "debug.h"
#include <ace/utils/custom.h>

static UWORD s_uwBaseColor;
static UBYTE s_isDebug;

void debugInit(UWORD uwBaseColor) {
	s_uwBaseColor = uwBaseColor;
	s_isDebug = 0;
}

void debugToggle(void) {
	s_isDebug = !s_isDebug;
}

void debugEnable(UBYTE isEnabled) {
	s_isDebug = isEnabled;
}

void debugReset(void) {
	g_pCustom->color[0] = s_uwBaseColor;
}

void debugSetColor(UWORD uwColor) {
	if (s_isDebug) {
		g_pCustom->color[0] = uwColor;
	}
}


