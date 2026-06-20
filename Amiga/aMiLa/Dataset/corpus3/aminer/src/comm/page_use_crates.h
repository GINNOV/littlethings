/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_USE_CRATES_H_
#define _AMINER_COMM_PAGE_USE_CRATES_H_

typedef enum tPageUseCratesScenario {
	PAGE_USE_CRATES_SCENARIO_TELEPORTER,
	PAGE_USE_CRATES_SCENARIO_CAPSULE,
	PAGE_USE_CRATES_SCENARIO_SELL,
} tPageUseCratesScenario;

void pageUseCratesCreate(tPageUseCratesScenario eScenario);

#endif // _AMINER_COMM_PAGE_USE_CRATES_H_
