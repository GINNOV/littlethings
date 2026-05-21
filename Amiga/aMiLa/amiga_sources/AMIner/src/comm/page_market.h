/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_MARKET_H_
#define _AMINER_COMM_PAGE_MARKET_H_

#include <ace/utils/file.h>

void pageMarketCreate(void);

void pageMarketReset(void);

void pageMarketSave(tFile *pFile);

UBYTE pageMarketLoad(tFile *pFile);

UBYTE pageMarketGetResourcesTraded(void);

#endif // _AMINER_COMM_PAGE_MARKET_H_
