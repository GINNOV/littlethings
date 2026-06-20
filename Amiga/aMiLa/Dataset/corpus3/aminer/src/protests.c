/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "protests.h"
#include "comm/page_office.h"
#include "comm/inbox.h"
#include "vehicle.h"
#include "save.h"
#include "game.h"
#include "background_bob.h"
#include "assets.h"

#define PROTEST_THRESHOLD_WARNING -300
#define PROTEST_THRESHOLD_PROTEST -500
#define PROTEST_THRESHOLD_STRIKE -1000
#define PROTEST_THRESHOLD_RIOTS -1500

#define PROTEST_BOB_WIDTH 48
#define PROTEST_BOB_HEIGHT 14
#define PROTEST_BOB_X (32 + 232)
#define PROTEST_BOB_Y 195

static tBitMap *s_pProtestBitmap;
static tBackgroundBob s_sBgBobProtest;
static tProtestState s_eProtestState;
static UBYTE *s_pOffsetNoProtest;
static UBYTE *s_pOffsetProtest;
static UBYTE *s_pOffsetStrike;

void protestsCreate(void) {
	s_pProtestBitmap = bitmapCreateFromFd(GET_SUBFILE_PREFIX("protests.bm"), 0);
	bobInit(
		&s_sBgBobProtest.sBob, PROTEST_BOB_WIDTH, PROTEST_BOB_HEIGHT, 0, 0, 0,
		PROTEST_BOB_X, PROTEST_BOB_Y
	);
	s_pOffsetNoProtest = bobCalcFrameAddress(s_pProtestBitmap, PROTEST_BOB_HEIGHT * 0);
	s_pOffsetProtest = bobCalcFrameAddress(s_pProtestBitmap, PROTEST_BOB_HEIGHT * 1);
	s_pOffsetStrike = bobCalcFrameAddress(s_pProtestBitmap, PROTEST_BOB_HEIGHT * 2);
	protestsReset();
}

void protestsDestroy(void) {
	bitmapDestroy(s_pProtestBitmap);
}

void protestsReset(void) {
	s_eProtestState = PROTEST_STATE_NONE;
	bobSetFrame(&s_sBgBobProtest.sBob, s_pOffsetNoProtest, 0);
	backgroundBobResetCounter(&s_sBgBobProtest);
}

void protestsSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_PROTEST);
	fileWrite(pFile, &s_eProtestState, sizeof(s_eProtestState));
	saveWriteTag(pFile, SAVE_TAG_PROTEST_END);
}

UBYTE protestsLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_PROTEST)) {
		return 0;
	}

	fileRead(pFile, &s_eProtestState, sizeof(s_eProtestState));
	return saveReadTag(pFile, SAVE_TAG_PROTEST_END);
}

void protestsProcess(void) {
	if(g_eGameMode != GAME_MODE_STORY) {
		return;
	}

	tProtestState eNewState = s_eProtestState;
	LONG lCash = g_pVehicles[0].lCash;

	// TODO: process on getting cash
	while(1) {
		switch(s_eProtestState) {
			case PROTEST_STATE_NONE:
				if(lCash < PROTEST_THRESHOLD_WARNING) {
					eNewState = PROTEST_STATE_WARNING;
					if(eNewState > s_eProtestState) {
						pageOfficeTryUnlockPersonSubpage(FACE_ID_KRYSTYNA, COMM_SHOP_PAGE_OFFICE_KRYSTYNA_PROTEST_WARNING);
						inboxPushBack(COMM_SHOP_PAGE_OFFICE_KRYSTYNA_PROTEST_WARNING, 1);
					}
				}
				break;
			case PROTEST_STATE_WARNING:
				if(lCash < PROTEST_THRESHOLD_PROTEST) {
					eNewState = PROTEST_STATE_PROTEST;
					bobSetFrame(&s_sBgBobProtest.sBob, s_pOffsetProtest, 0);
					backgroundBobResetCounter(&s_sBgBobProtest);
					if(eNewState > s_eProtestState) {
						pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_PROTEST_START);
						inboxPushBack(COMM_SHOP_PAGE_OFFICE_MIETEK_PROTEST_START, 1);
					}
				}
				else if(lCash > PROTEST_THRESHOLD_WARNING) {
					eNewState = PROTEST_STATE_NONE;
					bobSetFrame(&s_sBgBobProtest.sBob, s_pOffsetNoProtest, 0);
					backgroundBobResetCounter(&s_sBgBobProtest);
				}
				break;
			case PROTEST_STATE_PROTEST:
				if(lCash < PROTEST_THRESHOLD_STRIKE) {
					eNewState = PROTEST_STATE_STRIKE;
					bobSetFrame(&s_sBgBobProtest.sBob, s_pOffsetStrike, 0);
					backgroundBobResetCounter(&s_sBgBobProtest);
					if(eNewState > s_eProtestState) {
						pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_PROTEST_STRIKE);
						inboxPushBack(COMM_SHOP_PAGE_OFFICE_MIETEK_PROTEST_STRIKE, 1);
					}
				}
				else if(lCash > PROTEST_THRESHOLD_PROTEST) {
					eNewState = PROTEST_STATE_WARNING;
				}
				break;
			case PROTEST_STATE_STRIKE:
				if(lCash < PROTEST_THRESHOLD_RIOTS) {
					eNewState = PROTEST_STATE_RIOTS;
					if(eNewState > s_eProtestState) {
						inboxPushBack(COMM_SHOP_PAGE_NEWS_RIOTS, 1);
					}
				}
				else if(lCash > PROTEST_THRESHOLD_STRIKE) {
					eNewState = PROTEST_STATE_PROTEST;
				}
				break;
			case PROTEST_STATE_RIOTS:
				break;
		}

		if(eNewState != s_eProtestState) {
			logWrite("Protest state: %d -> %d", s_eProtestState, eNewState);
			s_eProtestState = eNewState;
		}
		else {
			break;
		}
	}
}

void protestsDrawBobs(void) {
	backgroundBobPush(&s_sBgBobProtest);
}

tProtestState protestsGetState(void) {
	return s_eProtestState;
}
