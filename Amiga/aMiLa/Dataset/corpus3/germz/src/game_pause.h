/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_GAME_PAUSE_H
#define GERMZ_GAME_PAUSE_H

typedef enum tPauseKind {
	PAUSE_KIND_BATTLE_PAUSE,
	PAUSE_KIND_CAMPAIGN_PAUSE,
	PAUSE_KIND_CAMPAIGN_WIN,
	PAUSE_KIND_CAMPAIGN_DEFEAT,
	PAUSE_KIND_BATTLE_SUMMARY,
} tPauseKind;

void gamePauseEnable(tPauseKind eKind);

#endif // GERMZ_GAME_PAUSE_H
