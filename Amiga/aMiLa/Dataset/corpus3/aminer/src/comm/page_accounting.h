/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_ACCOUNTING_H_
#define _AMINER_COMM_PAGE_ACCOUNTING_H_

#include <ace/utils/file.h>

void pageAccountingCreate(void);

void pageAccountingReset(void);

void pageAccountingSave(tFile *pFile);

UBYTE pageAccountingLoad(tFile *pFile);

UBYTE pageAccountingGetUses(void);

#endif // _AMINER_COMM_PAGE_ACCOUNTING_H_
