/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _HI_SCORE_H_
#define _HI_SCORE_H_

#include <ace/types.h>
#include "string_array.h"

typedef enum tScoreMode {
	SCORE_MODE_CHALLENGE,
	SCORE_MODE_DEADLINE,
	SCORE_MODE_COUNT
} tScoreMode;

void hiScoreEnteringProcess(void);

UBYTE hiScoreIsEnteringNew(void);

void hiScoreSetup(LONG lScore, const char *szResult, tScoreMode eScoreMode);

void hiScoreLoad(void);

void hiScoreDrawAll(void);

#endif // _HI_SCORE_H_
