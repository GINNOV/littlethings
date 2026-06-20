/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _MENU_H_
#define _MENU_H_

#include "aminer.h"
#include <string_array.h>
#include <ace/managers/ptplayer.h>

// must be same order as in strings.json: menu.captions
typedef enum tMenuCaptionKind {
	// Main
	MENU_CAPTION_STORY,
	MENU_CAPTION_DEADLINE,
	MENU_CAPTION_CHALLENGE,
	MENU_CAPTION_ACHIEVEMENTS,
	MENU_CAPTION_SETTINGS,
	MENU_CAPTION_EXIT,
	// Story/Free/Challenge
	MENU_CAPTION_START,
	MENU_CAPTION_CONTINUE,
	MENU_CAPTION_PLAYER_COUNT,
	MENU_CAPTION_BACK,
	MENU_CAPTION_ATARI_MODE,
	MENU_CAPTION_HI_SCORES,
	// Settings
	MENU_CAPTION_VOLUME_MUSIC,
	MENU_CAPTION_VOLUME_SOUND,
	MENU_CAPTION_STEER_P1,
	MENU_CAPTION_STEER_P2,
	MENU_CAPTION_CREDITS,
	MENU_CAPTION_COUNT,
} tMenuCaptionKind;

void menuPreload(void);
void menuUnload(void);

void menuGsEnter(UBYTE isScoreShow);

extern tState g_sStateMenu;

#endif // _MENU_H_
