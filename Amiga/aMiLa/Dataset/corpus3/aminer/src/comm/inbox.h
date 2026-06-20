/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_INBOX_H_
#define _AMINER_COMM_INBOX_H_

#include "gs_shop.h"
#include <ace/utils/file.h>

typedef struct tInboxMessage {
	tCommShopPage ePage;
	// TODO: something to tell shop which next page to show - for going to default state, triggering rebuke game over
} tInboxMessage;

typedef enum tInboxState {
	INBOX_STATE_NONE,
	INBOX_STATE_PENDING,
	INBOX_STATE_URGENT
}  tInboxState;

void inboxSave(tFile *pFile);

UBYTE inboxLoad(tFile *pFile);

void inboxReset(void);

void inboxPushBack(tCommShopPage ePage, UBYTE isUrgent);

UBYTE inboxTryPopFront(tCommShopPage *ePage);

tInboxState inboxGetState(void);

#endif // _AMINER_COMM_INBOX_H_
