/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef QUEST_GATE_H
#define QUEST_GATE_H

#include <ace/utils/file.h>

#define GATE_DEPTH_PX 6816

void questGateReset(void);

void questGateSave(tFile *pFile);

UBYTE questGateLoad(tFile *pFile);

void questGateProcess(void);

UBYTE questGateAddFragment(void);

void questGateMarkExploded(void);

UBYTE questGateIsExploded(void);

UBYTE questGateGetFoundFragmentCount(void);

UBYTE questGateGetMaxFragmentCount(void);

void questGateUnlockPrisoner(void);

UBYTE questGateIsPrisonerFound(void);

#endif // QUEST_GATE_H
