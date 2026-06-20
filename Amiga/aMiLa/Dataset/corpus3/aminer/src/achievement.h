/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef ACHIEVEMENT_H
#define ACHIEVEMENT_H

#include <ace/types.h>

typedef enum tAchievement {
	ACHIEVEMENT_LAST_RIGHTEOUS,
	ACHIEVEMENT_WORK_LEADER,
	ACHIEVEMENT_CONFIDENT,
	ACHIEVEMENT_SLACKER,
	ACHIEVEMENT_ARCHEO_ENTUSIAST,
	ACHIEVEMENT_ARCHEO_VICTIM,
	ACHIEVEMENT_BATTLE_OF_CENTURY,
	ACHIEVEMENT_LOST_WISDOM,
	ACHIEVEMENT_MORE_COAL,
	ACHIEVEMENT_RECORD_HOLDER,
	ACHIEVEMENT_CO_OP,
	ACHIEVEMENT_NO_WITNESSES,
	ACHIEVEMENT_DEADLINE,
	ACHIEVEMENT_PROTESTS,
	ACHIEVEMENT_ESCAPE,
	ACHIEVEMENT_NO_ACCOLADES,
	ACHIEVEMENT_NO_REBUKES,
	ACHIEVEMENT_PLATINUM,
} tAchievement;

void achievementUnlock(tAchievement eAchievement);

UBYTE achievementTryUnlockRighteous(void);

UBYTE achievementIsUnlocked(tAchievement eAchievement);

#endif // ACHIEVEMENT_H
