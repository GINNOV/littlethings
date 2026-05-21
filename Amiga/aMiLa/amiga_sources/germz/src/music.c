/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <music.h>
#include <assets.h>
#include <ace/managers/ptplayer.h>

static tMusicPreset s_eLastMusicPreset = 0;
static tAssetMods s_eCurrentMod = 0;

static void onSongEnd(void) {
	if(++s_eCurrentMod >= ASSET_MOD_GAME_COUNT) {
		s_eCurrentMod = ASSET_MOD_MENU;
	}
	ptplayerLoadMod(g_pMods[s_eCurrentMod], g_pModSamples, 0);
	ptplayerEnableMusic(1);
}

void musicLoadPreset(tMusicPreset ePreset) {
	if(ePreset != s_eLastMusicPreset) {
		switch(ePreset) {
			case MUSIC_PRESET_OUTRO:
				ptplayerLoadMod(g_pMods[ASSET_MOD_OUTRO], g_pModSamples, 0);
				ptplayerConfigureSongRepeat(1, 0);
				break;
			case MUSIC_PRESET_INTRO:
				ptplayerLoadMod(g_pMods[ASSET_MOD_INTRO], g_pModSamples, 0);
				ptplayerConfigureSongRepeat(1, 0);
				break;
			case MUSIC_PRESET_MENU:
				ptplayerLoadMod(g_pMods[ASSET_MOD_MENU], g_pModSamples, 0);
				ptplayerConfigureSongRepeat(1, 0);
				break;
			case MUSIC_PRESET_GAME:
				s_eCurrentMod = 0;
				ptplayerLoadMod(g_pMods[ASSET_MOD_GAME1], g_pModSamples, 0);
				ptplayerConfigureSongRepeat(0, onSongEnd);
				break;
		}
		ptplayerSetMasterVolume(0); // Will be faded-in
		ptplayerEnableMusic(1);
		s_eLastMusicPreset = ePreset;
	}
}
