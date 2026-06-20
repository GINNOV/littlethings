/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_QUESTIONING_H_
#define _AMINER_COMM_PAGE_QUESTIONING_H_

#include <ace/utils/file.h>
#include <ace/macros.h>
#include <comm/gs_shop.h>

// Be sure to update pageQuestioningBitToShopPage() accordingly
typedef enum tQuestioningBit {
	QUESTIONING_BIT_GATE,
	QUESTIONING_BIT_TELEPORT_PARTS,
	QUESTIONING_BIT_AGENT,
	QUESTIONING_BIT_COUNT ///< Not really a bit, used for iterating
} tQuestioningBit;

typedef enum tQuestioningFlag {
	QUESTIONING_FLAG_NONE = 0,
	QUESTIONING_FLAG_GATE = BV(QUESTIONING_BIT_GATE),
	QUESTIONING_FLAG_TELEPORT_PARTS = BV(QUESTIONING_BIT_TELEPORT_PARTS),
	QUESTIONING_FLAG_AGENT = BV(QUESTIONING_BIT_AGENT),
	QUESTIONING_FLAG_ALL = (BV(QUESTIONING_BIT_COUNT) - 1)
} tQuestioningFlag;

typedef void (*tQuestioningHandler)(tQuestioningBit eQuestioningBit, UBYTE isReportedOrCaught);

void pageQuestioningCreate(void);

void pageQuestioningReset(void);

void pageQuestioningSave(tFile *pFile);

UBYTE pageQuestioningLoad(tFile *pFile);

void pageQuestioningTrySetPendingQuestioning(tQuestioningBit eQuestioningBit, UBYTE isForce);

void pageQuestioningTryCancelPendingQuestioning(tQuestioningBit eQuestioningBit);

UBYTE pageQuestioningIsReported(tQuestioningBit eQuestioningBit);

void pageQuestioningSetHandler(tQuestioningBit eQuestioningBit, tQuestioningHandler cbOnQuestioningEnded);

const tCommShopPage *pageQuestioningGetNotReportedPages(void);

void pageQuestioningReport(tQuestioningBit eQuestioningBit);

void pageQuestioningAddReporting(tQuestioningBit eQuestioningBit);

UBYTE pageQuestioningIsAnyReported(void);

UBYTE pageQuestioningGetLiesCount(void);

#endif // _AMINER_COMM_PAGE_QUESTIONING_H_
