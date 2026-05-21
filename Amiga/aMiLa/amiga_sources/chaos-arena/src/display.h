/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_DISPLAY_H
#define INCLUDE_DISPLAY_H

#include <ace/generic/screen.h>
#include <ace/managers/viewport/simplebuffer.h>
#include "fade.h"
#include "tile.h"

#define DISPLAY_BPP 4
#define DISPLAY_TILE_MARGIN 1
#define DISPLAY_WIDTH (SCREEN_PAL_WIDTH + 2 * DISPLAY_TILE_MARGIN * 16)
#define DISPLAY_HEIGHT (SCREEN_PAL_HEIGHT + 2 * DISPLAY_TILE_MARGIN * 16)
#define DISPLAY_MARGIN_SIZE (DISPLAY_TILE_MARGIN * MAP_TILE_SIZE)

#define DISPLAY_SPRITE_CHANNEL_THUNDER 0
#define DISPLAY_SPRITE_CHANNEL_CURSOR 2

void displayCreate(void);

void displayDestroy(void);

void displayProcess(void);

tFadeState displayFadeProcess(void);

void displayFadeStart(UBYTE isIn, void (*cbOnFadeDone)(void));

void displayOn(void);

void displayOff(void);

tSimpleBufferManager *displayGetManager(void);

void displaySetThunderColor(UBYTE ubColorIndex);

#endif // INCLUDE_DISPLAY_H
