/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef PROTESTS_H
#define PROTESTS_H

#include <ace/utils/file.h>

typedef enum tProtestState {
	PROTEST_STATE_NONE,
	PROTEST_STATE_WARNING,
	PROTEST_STATE_PROTEST,
	PROTEST_STATE_STRIKE,
	PROTEST_STATE_RIOTS,
} tProtestState;

void protestsCreate(void);

void protestsDestroy(void);

void protestsReset(void);

void protestsSave(tFile *pFile);

UBYTE protestsLoad(tFile *pFile);

void protestsProcess(void);

void protestsDrawBobs(void);

tProtestState protestsGetState(void);

#endif // PROTESTS_H
