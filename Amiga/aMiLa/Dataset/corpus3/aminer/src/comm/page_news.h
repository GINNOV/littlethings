/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_NEWS_H_
#define _AMINER_COMM_PAGE_NEWS_H_

#include "game.h"

typedef enum tNewsKind {
	NEWS_KIND_INTRO_1,
	NEWS_KIND_INTRO_2,
	NEWS_KIND_INTRO_3,
	NEWS_KIND_ACCOLADES,
	NEWS_KIND_GATE_ENEMY,
	NEWS_KIND_GATE_RED,
	NEWS_KIND_ESCAPE_FAIL,
	NEWS_KIND_RIOTS,
	NEWS_KIND_COUNT
} tNewsKind;

void pageNewsCreate(tNewsKind eNewsKind);

// Use only for initial loading screen!
void pageNewsDestroy(void);

UBYTE pageNewsIsDone(void);

#endif // _AMINER_COMM_PAGE_NEWS_H_
