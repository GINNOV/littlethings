/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

typedef enum tMusicPreset {
	MUSIC_PRESET_OUTRO, //
	MUSIC_PRESET_INTRO,
	MUSIC_PRESET_MENU,
	MUSIC_PRESET_GAME,
} tMusicPreset;

void musicLoadPreset(tMusicPreset ePreset);
