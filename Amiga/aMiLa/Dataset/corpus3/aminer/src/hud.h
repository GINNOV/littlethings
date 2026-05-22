/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _HUD_H_
#define _HUD_H_

#include <ace/utils/extview.h>
#include <ace/utils/font.h>
#include "string_array.h"
#include "face_id.h"
#include "game.h"

#define HUD_HEIGHT 31

typedef enum _tHudPlayer {
	PLAYER_1 = 0,
	PLAYER_2
} tHudPlayer;

void hudCreate(tVPort *pVpHud, const tFont *pFont);

void hudDestroy(void);

void hudSet2pPlaying(UBYTE isPlaying);

void hudReset(tGameMode eGameMode, UBYTE is2pPlaying);

void hudSave(tFile *pFile);

UBYTE hudLoad(tFile *pFile);

void hudSetDepth(UBYTE ubPlayer, UWORD uwDepth);

void hudSetTime(UWORD uwTime);

void hudSetCash(UBYTE ubPlayer, LONG lCash);

void hudSetCargo(UBYTE ubPlayer, UBYTE ubCargo, UBYTE ubCargoMax);

void hudSetDrill(UBYTE ubPlayer, UWORD uwDrill, UWORD uwDrillMax);

void hudSetHull(UBYTE ubPlayer, UWORD uwHull, UWORD uwHullMax);

void hudClearInboxNotification(void);

void hudProcess(void);

UBYTE hudIsShowingMessage(void);

void hudShowMessage(tFaceId eFace, const char *szMsg);

void hudShowMessageVa(tFaceId eFace, const char *szFormat, ...);

void hudShowMain(void);

void hudPause(UBYTE isPaused);

UBYTE hudGetSelection(void);

void hudSelect(UBYTE ubSelection);

#endif // _HUD_H_
