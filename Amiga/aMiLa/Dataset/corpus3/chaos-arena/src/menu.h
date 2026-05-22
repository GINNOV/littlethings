/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_MENU_H
#define INCLUDE_MENU_H

#include "steer.h"

void menuSetupMain(void);

void menuSetupSummary(UBYTE ubWinnerIndex);

tSteerMode menuGetSteerModeForPlayer(UBYTE ubPlayerIndex);

UBYTE menuIsExtraEnemiesEnabled(void);

UBYTE menuAreThundersEnabled(void);

#endif // INCLUDE_MENU_H
