/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_BRIBE_H_
#define _AMINER_COMM_PAGE_BRIBE_H_

#include <ace/utils/file.h>

void pageBribeCreate(void);

void pageBribeReset(void);

void pageBribeSave(tFile *pFile);

UBYTE pageBribeLoad(tFile *pFile);

UBYTE pageBribeGetCount(void);

#endif // _AMINER_COMM_PAGE_BRIBE_H_
