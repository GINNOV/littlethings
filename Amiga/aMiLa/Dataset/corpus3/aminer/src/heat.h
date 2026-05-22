/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_HEAT_H_
#define _AMINER_HEAT_H_

#include <ace/utils/file.h>

UBYTE heatGetPercent(void);

void heatTryIncrease(UBYTE ubPercent);

void heatTryReduce(UBYTE ubPercent);

void heatReset(void);

void heatSave(tFile *pFile);

UBYTE heatLoad(tFile *pFile);

UBYTE heatTryPassCheck();

#endif // _AMINER_HEAT_H_
