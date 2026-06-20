/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COLLECTIBLES_H_
#define _AMINER_COLLECTIBLES_H_

#include <ace/types.h>

typedef enum tCollectibleKind {
	COLLECTIBLE_KIND_DINO,
	COLLECTIBLE_KIND_GATE,
	COLLECTIBLE_KIND_COUNT,
} tCollectibleKind;

void collectiblesReset(void);

void collectiblesCreate(void);

void collectiblesProcess(void);

void collectiblesDestroy(void);

void collectibleSetFoundCount(tCollectibleKind eKind, UBYTE ubCount);

UBYTE collectibleGetMaxCount(tCollectibleKind eKind);

#endif // _AMINER_COLLECTIBLES_H_
