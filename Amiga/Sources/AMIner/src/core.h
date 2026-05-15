/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _CORE_H_
#define _CORE_H_

#include "aminer.h"
#include <ace/managers/viewport/tilebuffer.h>
#include <ace/utils/font.h>
#include <ace/managers/rand.h>
#include <ace/managers/ptplayer.h>
#include <ace/managers/bob.h>

void coreProcessBeforeBobs(void);

void coreProcessAfterBobs(void);

void coreTransferBobToPristine(tBob *pBob);

extern tTileBufferManager *g_pMainBuffer;
extern tRandManager g_sRand;
extern tState g_sStateCore;

#endif // _CORE_H_
