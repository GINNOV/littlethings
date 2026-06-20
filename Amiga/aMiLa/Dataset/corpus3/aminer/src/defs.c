/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "defs.h"
#include <ace/managers/log.h>
#include "assets.h"
#include "string_array.h"
#include "msg.h"

const LONG g_lInitialCash = 0;
const UBYTE g_ubUpgradeLevels = 4;
const UBYTE g_ubDrillingCost = 15;
const UBYTE g_ubLiterPrice = 5, g_ubFuelInLiter = 100, g_ubHullPrice = 2;
const UBYTE g_ubPlansPerAccolade = 10;
const UBYTE g_ubAccoladesInMainStory = 5;
const fix16_t g_fPlanIncreaseRatioSingleplayer = F16(0.25);
const fix16_t g_fPlanIncreaseRatioMultiplayer = F16(0.5);

const UWORD g_pUpgradeCosts[4] = {100, 300, 600, 1000};
const UWORD g_pDinoDepths[DEFS_QUEST_DINO_BONE_COUNT] = {
	80, 130, 170, 190, 220, 230, 250, 270, 290,
};
const UWORD g_pGateDepths[DEFS_QUEST_GATE_PART_COUNT] = {
	235, 255, 275, 300, 330, 360, 390, 420, 450, 480, 510, 540, 570, 600, 630, 660
};
const UWORD g_pCrateDepths[DEFS_QUEST_CRATE_COUNT] = {
	350, 430, 470, 530, 590, 640, 680, 720, 770, 810,
};
const UWORD g_uwCapsuleDepth = 1020;
const UWORD g_uwPrisonerDepth = 229;
const UWORD g_pMineralPlans[MINERAL_TYPE_COUNT] = {0, 10, 30, 40, 20, 65535};
const UBYTE g_ubMinePercentForPlans = 75;
const UBYTE g_ubTrailingMineralCountPercent = 20;
const ULONG g_ulExtraPlanMoney = 50;

const char **g_pMsgs;

const tCodeRemap g_pRemap[19] = {
	{323, 145}, // "Ń"
	{377, 144}, // "Ź"
	{260, 143}, // "Ą"
	{346, 142}, // "Ś"
	{280, 141}, // "Ę"
	{262, 140}, // "Ć"
	{321, 139}, // "Ł"
	{211, 138}, // "Ó"
	{379, 137}, // "Ż"
	{324, 136}, // "ń"
	{378, 135}, // "ź"
	{261, 134}, // "ą"
	{347, 133}, // "ś"
	{281, 132}, // "ę"
	{263, 131}, // "ć"
	{322, 130}, // "ł"
	{243, 129}, // "ó"
	{380, 128}, // "ż"
	{0, 0} // Terminator
};

void defsCreateLocale(const char *szLangPrefix) {
	logBlockBegin("defsCreateLocale(szLangPrefix: %s)", szLangPrefix);

	char szPath[30];
	sprintf(szPath, SUBFILE_PREFIX "txt_%s/messages.str", szLangPrefix);
	g_pMsgs = (const char**)stringArrayCreateFromFd(GET_SUBFILE(szPath));

#if defined(ACE_DEBUG)
	if(stringArrayGetCount(g_pMsgs) != MSG_COUNT) {
		logWrite("ERR: g_pMsgs length %hhu, expected %hhu\n", stringArrayGetCount(g_pMsgs), MSG_COUNT);
	}
#endif

	logBlockEnd("defsCreateLocale()");
}

void defsDestroyLocale(void) {
	logBlockBegin("defsDestroyLocale()");
	stringArrayDestroy((char**)g_pMsgs);
	logBlockEnd("defsDestroyLocale()");
}
