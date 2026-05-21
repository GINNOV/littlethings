/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_PLEP_H
#define GERMZ_PLEP_H

#include "bob_new.h"
#include "direction.h"

//------------------------------------------------------------------------ TYPES

typedef enum tPlepAnim {
	PLEP_ANIM_BORN,
	PLEP_ANIM_MOVE,
	PLEP_ANIM_WIN,
	PLEP_ANIM_LOSE,
	PLEP_ANIM_COUNT,
} tPlepAnim;

typedef struct tPlep {
	UBYTE isActive;
	tDirection eDir;
	UBYTE ubAnimFrame;
	UBYTE ubAnimTick;
	tUwCoordYX sAnimAnchor;
	tPlepAnim eAnim;
	WORD wCharges;
	tBobNew sBob;
	struct tPlayer *pPlayer;
	struct tNode *pDestination;
} tPlep;

#include "player.h"

void plepCreate(void);

void plepDestroy(void);

void plepInitBob(tPlep *pPlep);

void plepReset(tPlep *pPlep, struct tPlayer *pPlayer);

void plepProcess(tPlep *pPlep);

void plepSpawn(tPlep *pPlep, WORD wCharges, tDirection eDir);

void plepSetMap(const tMap *pMap);

#endif // GERMZ_PLEP_H
