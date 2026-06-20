/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _FLIPBOOK_H_
#define _FLIPBOOK_H_

#include <ace/types.h>

typedef void (*tCbFlipbook)(void *pData);

typedef enum tFlipbookKind {
	FLIPBOOK_KIND_BOOM,
	FLIPBOOK_KIND_TELEPORT,
	FLIPBOOK_KIND_TELEPORTER_OUT,
	FLIPBOOK_KIND_TELEPORTER_IN,
	FLIPBOOK_KIND_COUNT,
} tFlipbookKind;

void flipbookManagerCreate(void);

void flipbookManagerDestroy(void);

void flipbookAdd(
	UWORD uwX, UWORD uwY, tCbFlipbook cbOnPeak, tCbFlipbook cbOnEnd,
	void *pCbData, tFlipbookKind eKind
);

void flipbookManagerProcess(void);

#endif // _FLIPBOOK_H_
