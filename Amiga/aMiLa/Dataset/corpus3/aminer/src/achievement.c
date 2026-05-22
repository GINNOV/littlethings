/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "achievement.h"
#include <ace/utils/string.h>
#include "settings.h"
#include "hud.h"
#include <comm/page_accounting.h>
#include <comm/page_bribe.h>
#include <comm/page_questioning.h>
#include <comm/page_market.h>

#define NON_PLATINUM_MASK (BV(ACHIEVEMENT_PLATINUM) - 1)

void achievementUnlock(tAchievement eAchievement) {
	if(settingsTryUnlockAchievement(eAchievement)) {
		logWrite("Unlocked achievement %hu\n", eAchievement);
		if((g_sSettings.ulAchievementsUnlocked & NON_PLATINUM_MASK) == NON_PLATINUM_MASK) {
			settingsTryUnlockAchievement(ACHIEVEMENT_PLATINUM);
			logWrite("Unlocked platinum achievmeent\n");
		}
		hudShowMessageVa(FACE_ID_MIETEK, g_pMsgs[MSG_HUD_ACHIEVEMENT_UNLOCKED], g_pMsgs[MSG_ACHIEVEMENT_TITLE_LAST_RIGHTEOUS + eAchievement]);
	}
}

UBYTE achievementTryUnlockRighteous(void) {
	if(
		!pageQuestioningIsAnyReported() && pageQuestioningGetLiesCount() == 0 &&
		pageAccountingGetUses() == 0 && pageBribeGetCount() == 0 &&
		pageMarketGetResourcesTraded() == 0
	) {
		return 1;
	}
	return 0;
}

UBYTE achievementIsUnlocked(tAchievement eAchievement) {
	return (g_sSettings.ulAchievementsUnlocked & BV(eAchievement)) != 0;
}
