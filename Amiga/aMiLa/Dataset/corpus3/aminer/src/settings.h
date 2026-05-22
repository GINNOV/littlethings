/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef SETTINGS_H
#define SETTINGS_H

#include <ace/utils/file.h>

typedef enum tSettingsPlayerSteer {
	SETTINGS_PLAYER_STEER_JOY1,
	SETTINGS_PLAYER_STEER_JOY2,
	SETTINGS_PLAYER_STEER_WSAD,
	SETTINGS_PLAYER_STEER_ARROWS,
} tSettingsPlayerSteer;

typedef struct tSettings {
	UBYTE ubSoundVolume;
	UBYTE ubMusicVolume;
	UBYTE ubSteer1p;
	UBYTE ubSteer2p;
	UBYTE isAtariHidden;
	ULONG ulAchievementsUnlocked;
} tSettings;

extern tSettings g_sSettings;

void settingsFileSave(void);

void settingsFileLoad(void);

UBYTE settingsTryUnlockAchievement(UBYTE ubAchievementIndex);

#endif // SETTINGS_H
