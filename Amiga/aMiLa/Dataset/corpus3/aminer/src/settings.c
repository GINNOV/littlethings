/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "settings.h"
#include <ace/managers/log.h>
#include <ace/utils/disk_file.h>
#include "save.h"

// Default config
tSettings g_sSettings;

//------------------------------------------------------------------ PRIVATE FNS

static void settingsSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_SETTINGS_V2);
	fileWrite(pFile, &g_sSettings.ubSoundVolume, sizeof(g_sSettings.ubSoundVolume));
	fileWrite(pFile, &g_sSettings.ubMusicVolume, sizeof(g_sSettings.ubMusicVolume));
	fileWrite(pFile, &g_sSettings.ubSteer1p, sizeof(g_sSettings.ubSteer1p));
	fileWrite(pFile, &g_sSettings.ubSteer2p, sizeof(g_sSettings.ubSteer2p));
	fileWrite(pFile, &g_sSettings.isAtariHidden, sizeof(g_sSettings.isAtariHidden));
	fileWrite(pFile, &g_sSettings.ulAchievementsUnlocked, sizeof(g_sSettings.ulAchievementsUnlocked));
	saveWriteTag(pFile, SAVE_TAG_SETTINGS_END);
}

static UBYTE settingsLoad(tFile*pFile) {
	UBYTE ubVersion;
	char szTag[sizeof(SAVE_TAG_SETTINGS_V2)];
	saveTagGet(pFile, szTag);
	if(saveTagIs(szTag, SAVE_TAG_SETTINGS_V1)) {
		ubVersion = 1;
	}
	else if(saveTagIs(szTag, SAVE_TAG_SETTINGS_V2)) {
		ubVersion = 2;
	}
	else {
		return 0;
	}

	fileRead(pFile, &g_sSettings.ubSoundVolume, sizeof(g_sSettings.ubSoundVolume));
	fileRead(pFile, &g_sSettings.ubMusicVolume, sizeof(g_sSettings.ubMusicVolume));
	fileRead(pFile, &g_sSettings.ubSteer1p, sizeof(g_sSettings.ubSteer1p));
	fileRead(pFile, &g_sSettings.ubSteer2p, sizeof(g_sSettings.ubSteer2p));
	fileRead(pFile, &g_sSettings.isAtariHidden, sizeof(g_sSettings.isAtariHidden));
	fileRead(pFile, &g_sSettings.ulAchievementsUnlocked, sizeof(g_sSettings.ulAchievementsUnlocked));

	if(ubVersion == 1) {
		// Migrate from is1pKbd/is2pKbd
		g_sSettings.ubSteer1p = (g_sSettings.ubSteer1p ? SETTINGS_PLAYER_STEER_WSAD : SETTINGS_PLAYER_STEER_JOY1);
		g_sSettings.ubSteer2p = (g_sSettings.ubSteer2p ? SETTINGS_PLAYER_STEER_ARROWS : SETTINGS_PLAYER_STEER_JOY2);
	}

	return saveReadTag(pFile, SAVE_TAG_SETTINGS_END);
}

static void settingsReset(void) {
	g_sSettings.ubSoundVolume = 10;
	g_sSettings.ubMusicVolume = 5;
	g_sSettings.ubSteer1p = SETTINGS_PLAYER_STEER_JOY1;
	g_sSettings.ubSteer2p = SETTINGS_PLAYER_STEER_WSAD;
	g_sSettings.isAtariHidden = 1;
	g_sSettings.ulAchievementsUnlocked = 0;
}

//------------------------------------------------------------------- PUBLIC FNS

void settingsFileSave(void) {
	tFile *pFileSettings = diskFileOpen("settings.tmp", DISK_FILE_MODE_WRITE, 1);
	if(pFileSettings) {
		settingsSave(pFileSettings);
		fileClose(pFileSettings);
		diskFileDelete("settings.dat");
		diskFileMove("settings.tmp", "settings.dat");
		logWrite("Saved settings\n");
	}
}

void settingsFileLoad(void) {
	tFile *pFileSettings = diskFileOpen("settings.dat", DISK_FILE_MODE_READ, 1);
	if(pFileSettings) {
		if(settingsLoad(pFileSettings)) {
			logWrite("Loaded settings\n");
		}
		else {
			logWrite("ERR: Can't load settings - restoring defaults\n");
			settingsReset();
		}

		fileClose(pFileSettings);
	}
	else {
		logWrite("ERR: Can't load settings - restoring defaults\n");
		settingsReset();
	}
}

UBYTE settingsTryUnlockAchievement(UBYTE ubAchievementIndex) {
	if(g_sSettings.ulAchievementsUnlocked & BV(ubAchievementIndex)) {
		return 0;
	}
	g_sSettings.ulAchievementsUnlocked |= BV(ubAchievementIndex);
	return 1;
}
