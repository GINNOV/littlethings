/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _DINO_H_
#define _DINO_H_

#include <ace/types.h>
#include <ace/utils/file.h>

void dinoReset(void);

void dinoSave(tFile *pFile);

UBYTE dinoLoad(tFile *pFile);

void dinoProcess(void);

UBYTE dinoAddBone(void);

UBYTE dinoIsAllFound(void);

UBYTE dinoIsQuestStarted(void);

#endif // _DINO_H_
