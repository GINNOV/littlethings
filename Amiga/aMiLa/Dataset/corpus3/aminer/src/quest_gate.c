/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "quest_gate.h"
#include "collectibles.h"
#include <comm/page_questioning.h>
#include <comm/page_office.h>
#include <comm/inbox.h>
#include "hud.h"
#include "save.h"
#include "game.h"
#include "core.h"
#include "tile.h"
#include "dino.h"
#include "achievement.h"

#define PRISONER_ANIM_COOLDOWN 6

typedef enum tQuestGateState {
	QUEST_GATE_STATE_UNEXPLODED,
	QUEST_GATE_STATE_EXPLODED,
} tQuestGateState;

static tQuestGateState s_eGateQuestState;
static UBYTE s_ubFoundFragments;
static UBYTE s_isPrisonerFound;
static UBYTE s_ubPrisonerAnimCooldown;
static tTile s_ePrisonerAnimFrame;

void questGateReset(void) {
	s_eGateQuestState = QUEST_GATE_STATE_UNEXPLODED;
	s_ubFoundFragments = 0;
	s_isPrisonerFound = 0;
	s_ePrisonerAnimFrame = TILE_PRISONER_1;
	s_ubPrisonerAnimCooldown = PRISONER_ANIM_COOLDOWN;
}

void questGateSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_GATE);
	fileWrite(pFile, &s_eGateQuestState, sizeof(s_eGateQuestState));
	fileWrite(pFile, &s_ubFoundFragments, sizeof(s_ubFoundFragments));
	fileWrite(pFile, &s_isPrisonerFound, sizeof(s_isPrisonerFound));
	saveWriteTag(pFile, SAVE_TAG_GATE_END);
}

UBYTE questGateLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_GATE)) {
		return 0;
	}

	fileRead(pFile, &s_eGateQuestState, sizeof(s_eGateQuestState));
	fileRead(pFile, &s_ubFoundFragments, sizeof(s_ubFoundFragments));
	fileRead(pFile, &s_isPrisonerFound, sizeof(s_isPrisonerFound));
	collectibleSetFoundCount(COLLECTIBLE_KIND_GATE, s_ubFoundFragments);
	return saveReadTag(pFile, SAVE_TAG_GATE_END);
}

void questGateProcess(void) {
	if(!questGateIsPrisonerFound()) {
		if(s_ubPrisonerAnimCooldown) {
			--s_ubPrisonerAnimCooldown;
		}
		else {
			s_ubPrisonerAnimCooldown = PRISONER_ANIM_COOLDOWN;
			UWORD uwCamTopPos = g_pMainBuffer->pCamera->uPos.uwY;
			UWORD uwCamBottomPos = uwCamTopPos + g_pMainBuffer->sCommon.pVPort->uwHeight- TILE_SIZE;
			UWORD uwPrisonerPos = g_uwPrisonerDepth * TILE_SIZE;
			if(uwCamTopPos < uwPrisonerPos && uwPrisonerPos < uwCamBottomPos) {
				if(s_ePrisonerAnimFrame < TILE_PRISONER_8) {
					++s_ePrisonerAnimFrame;
				}
			}
			else {
				if(s_ePrisonerAnimFrame > TILE_PRISONER_1) {
					--s_ePrisonerAnimFrame;
				}
			}
			if(tileGetPrisoner() != s_ePrisonerAnimFrame) {
				tileSetPrisoner(s_ePrisonerAnimFrame);
			}
		}
	}
}

UBYTE questGateAddFragment(void) {
	const UBYTE ubMaxFragmentCount = questGateGetMaxFragmentCount();
	s_ubFoundFragments = MIN(s_ubFoundFragments + 1, ubMaxFragmentCount);
	collectibleSetFoundCount(COLLECTIBLE_KIND_GATE, s_ubFoundFragments);
	if(s_ubFoundFragments < ubMaxFragmentCount) {
		pageQuestioningTrySetPendingQuestioning(QUESTIONING_BIT_GATE, 0);
	}
	else {
		pageQuestioningTryCancelPendingQuestioning(QUESTIONING_BIT_GATE);
		gameTriggerCutscene(GAME_CUTSCENE_TELEPORT);
	}

	return s_ubFoundFragments;
}

void questGateMarkExploded(void) {
	s_eGateQuestState = QUEST_GATE_STATE_EXPLODED;
	collectibleSetFoundCount(COLLECTIBLE_KIND_GATE, 0);
	achievementUnlock(ACHIEVEMENT_LOST_WISDOM);
	if(
		!s_isPrisonerFound && !dinoIsQuestStarted() &&
		!pageQuestioningIsReported(QUESTIONING_BIT_GATE)
	) {
		achievementUnlock(ACHIEVEMENT_NO_WITNESSES);
	}
}

UBYTE questGateIsExploded(void) {
	return s_eGateQuestState == QUEST_GATE_STATE_EXPLODED;
}

UBYTE questGateGetFoundFragmentCount(void) {
	return s_ubFoundFragments;
}

UBYTE questGateGetMaxFragmentCount(void) {
	return collectibleGetMaxCount(COLLECTIBLE_KIND_GATE);
}

void questGateUnlockPrisoner(void) {
	s_isPrisonerFound = 1;
	hudShowMessage(FACE_ID_MIETEK, g_pMsgs[MSG_HUD_PRISONER_FOUND]);
	pageOfficeUnlockPerson(FACE_ID_PRISONER);
	pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_DOSSIER);
	pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_WELCOME);
	inboxPushBack(COMM_SHOP_PAGE_OFFICE_PRISONER_WELCOME, 1);
}

UBYTE questGateIsPrisonerFound(void) {
	return s_isPrisonerFound;
}
