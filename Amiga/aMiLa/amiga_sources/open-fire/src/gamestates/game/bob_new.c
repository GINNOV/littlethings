/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <gamestates/game/bob_new.h>
#include <ace/managers/memory.h>
#include <ace/managers/system.h>
#include <ace/utils/custom.h>

// Undraw stack must be accessible during adding new bobs, so the most safe
// approach is to have two lists - undraw list gets populated after draw
// and depopulated during undraw
typedef struct _tBobQueue {
	UBYTE ubUndrawCount;
	tBobNew **pBobs;
	tBitMap *pBg;
	tBitMap *pDst;
} tBobQueue;

static UBYTE s_ubBufferCurr;
static UBYTE s_ubMaxBobCount;

static UBYTE s_isPushingDone;
static UBYTE s_ubBpp;

// This can't be a decreasing counter such as in toSave/toDraw since after
// decrease another bob may be pushed, which would trash bg saving
static UBYTE s_ubBobsPushed;
static UBYTE s_ubBobsDrawn;
static UBYTE s_ubBobsSaved;

tBobQueue s_pQueues[2];

void bobNewManagerCreate(
	UBYTE ubMaxBobCount, UWORD uwBgBufferLength,
	tBitMap *pFront, tBitMap *pBack
) {
	s_ubBpp = pFront->Depth;
	s_ubMaxBobCount = ubMaxBobCount;
	systemUse();
	s_pQueues[0].pBobs = memAllocFast(sizeof(tBobNew*) * s_ubMaxBobCount);
	s_pQueues[1].pBobs = memAllocFast(sizeof(tBobNew*) * s_ubMaxBobCount);
	s_pQueues[0].pBg = bitmapCreate(16, uwBgBufferLength, s_ubBpp, BMF_INTERLEAVED);
	s_pQueues[1].pBg = bitmapCreate(16, uwBgBufferLength, s_ubBpp, BMF_INTERLEAVED);
	systemUnuse();

	s_pQueues[0].pDst = pBack;
	s_pQueues[1].pDst = pFront;

	s_isPushingDone = 0;
	s_ubBufferCurr = 0;
	s_ubBobsPushed = 0;
	s_ubBobsSaved = 0;
	s_ubBobsDrawn = 0;
	s_pQueues[0].ubUndrawCount = 0;
	s_pQueues[1].ubUndrawCount = 0;
}

void bobNewManagerDestroy(void) {
	blitWait();
	systemUse();
	memFree(s_pQueues[0].pBobs, sizeof(tBobNew*) * s_ubMaxBobCount);
	memFree(s_pQueues[1].pBobs, sizeof(tBobNew*) * s_ubMaxBobCount);
	bitmapDestroy(s_pQueues[0].pBg);
	bitmapDestroy(s_pQueues[1].pBg);
	systemUnuse();
}

void bobNewPush(tBobNew *pBob) {
	tBobQueue *pQueue = &s_pQueues[s_ubBufferCurr];
	pQueue->pBobs[s_ubBobsPushed] = pBob;
	++s_ubBobsPushed;
	if(blitIsIdle()) {
		bobNewProcessNext();
	}
}

void bobNewInit(
	tBobNew *pBob, UWORD uwWidth, UWORD uwHeight, UBYTE isUndrawRequired,
	tBitMap *pBitMap, tBitMap *pMask, UWORD uwX, UWORD uwY
) {
	pBob->uwWidth = uwWidth;
	pBob->uwHeight = uwHeight;
	pBob->isUndrawRequired = isUndrawRequired;
	pBob->pBitmap = pBitMap;
	pBob->pMask = pMask;
	UWORD uwBlitWords = (uwWidth+15)/16 + 1; // One word more for aligned copy
	pBob->_uwBlitSize = ((uwHeight*s_ubBpp) << 6) | uwBlitWords;
	pBob->_wModuloUndrawSave = bitmapGetByteWidth(s_pQueues[0].pDst) - uwBlitWords*2;
	pBob->uwOffsetY = 0;

	pBob->sPos.sUwCoord.uwX = uwX;
	pBob->sPos.sUwCoord.uwY = uwY;
	pBob->pOldPositions[0].sUwCoord.uwX = uwX;
	pBob->pOldPositions[0].sUwCoord.uwY = uwY;
	pBob->pOldPositions[1].sUwCoord.uwX = uwX;
	pBob->pOldPositions[1].sUwCoord.uwY = uwY;
}

void bobNewSetBitMapOffset(tBobNew *pBob, UWORD uwOffsetY) {
	pBob->uwOffsetY = uwOffsetY * pBob->pBitmap->BytesPerRow;
}

UBYTE bobNewProcessNext(void) {
	if(s_ubBobsSaved < s_ubBobsPushed) {
		tBobQueue *pQueue = &s_pQueues[s_ubBufferCurr];
		if(!s_ubBobsSaved) {
			// Prepare for saving
			// Bltcon0/1, bltaxwm could be reset between Begin and ProcessNext
			UWORD uwBltCon0 = USEA|USED | MINTERM_A;
			g_pCustom->bltcon0 = uwBltCon0;
			g_pCustom->bltcon1 = 0;
			g_pCustom->bltafwm = 0xFFFF;
			g_pCustom->bltalwm = 0xFFFF;

			g_pCustom->bltdmod = 0;
			ULONG ulD = (ULONG)(pQueue->pBg->Planes[0]);
			g_pCustom->bltdpt = (APTR)ulD;
		}
		const tBobNew *pBob = pQueue->pBobs[s_ubBobsSaved];
		++s_ubBobsSaved;
		if(pBob->isUndrawRequired) {
			ULONG ulSrcOffs = (
				pQueue->pDst->BytesPerRow * pBob->sPos.sUwCoord.uwY +
				pBob->sPos.sUwCoord.uwX/8
			);
			ULONG ulA = (ULONG)(pQueue->pDst->Planes[0]) + ulSrcOffs;
			g_pCustom->bltamod = pBob->_wModuloUndrawSave;
			g_pCustom->bltapt = (APTR)ulA;
			g_pCustom->bltsize = pBob->_uwBlitSize;
		}
		return 1;
	}
	else {
		if(!s_isPushingDone) {
			return 1;
		}

		tBobQueue *pQueue = &s_pQueues[s_ubBufferCurr];
		if(s_ubBobsDrawn < s_ubBobsPushed) {
			// Draw next
			tBobNew *pBob = pQueue->pBobs[s_ubBobsDrawn];
			const tUwCoordYX * pPos = &pBob->sPos;
			++s_ubBobsDrawn;

			if(!blitCheck(
				pBob->pBitmap, 0, pBob->uwOffsetY / pBob->pBitmap->BytesPerRow,
				pQueue->pDst, pPos->sUwCoord.uwX, pPos->sUwCoord.uwY,
				pBob->uwWidth, pBob->uwHeight, __LINE__, __FILE__
			)) {
				return 1;
			}

			UBYTE ubDstOffs = pPos->sUwCoord.uwX & 0xF;
			UWORD uwBlitWidth = (pBob->uwWidth +ubDstOffs+15) & 0xFFF0;
			UWORD uwBlitWords = uwBlitWidth >> 4;
			UWORD uwBlitSize = ((pBob->uwHeight * s_ubBpp) << 6) | uwBlitWords;
			WORD wSrcModulo = (pBob->uwWidth >> 3) - (uwBlitWords<<1);
			UWORD uwLastMask = 0xFFFF << (uwBlitWidth-pBob->uwWidth);
			UWORD uwBltCon1 = ubDstOffs << BSHIFTSHIFT;
			UWORD uwBltCon0;
			if(pBob->pMask) {
				uwBltCon0 = uwBltCon1 | USEA|USEB|USEC|USED | MINTERM_COOKIE;
			}
			else {
				// TODO change to A - performance boost
				// TODO setting B & C regs isn't necessary - few write cycles less
				uwBltCon0 = uwBltCon1 | USEB|USED | MINTERM_B;
			}
			ULONG ulSrcOffs = pBob->uwOffsetY;
			ULONG ulDstOffs = (
				pQueue->pDst->BytesPerRow * pPos->sUwCoord.uwY + (pPos->sUwCoord.uwX>>3)
			);

			WORD wDstModulo = bitmapGetByteWidth(pQueue->pDst) - (uwBlitWords<<1);
			ULONG ulA = (ULONG)(pBob->pMask->Planes[0] + ulSrcOffs);
			ULONG ulB = (ULONG)(pBob->pBitmap->Planes[0] + ulSrcOffs);
			ULONG ulCD = (ULONG)(pQueue->pDst->Planes[0]) + ulDstOffs;

			g_pCustom->bltcon0 = uwBltCon0;
			g_pCustom->bltcon1 = uwBltCon1;
			g_pCustom->bltalwm = uwLastMask;

			g_pCustom->bltamod = wSrcModulo;
			g_pCustom->bltbmod = wSrcModulo;
			g_pCustom->bltcmod = wDstModulo;
			g_pCustom->bltdmod = wDstModulo;

			g_pCustom->bltapt = (APTR)ulA;
			g_pCustom->bltbpt = (APTR)ulB;
			g_pCustom->bltcpt = (APTR)ulCD;
			g_pCustom->bltdpt = (APTR)ulCD;
			g_pCustom->bltsize = uwBlitSize;

			pBob->pOldPositions[s_ubBufferCurr].ulYX = pPos->ulYX;

			return 1;
		}
	}
	return 0;
}

void bobNewBegin(void) {
	tBobQueue *pQueue = &s_pQueues[s_ubBufferCurr];

	// Prepare for undraw
	blitWait();
	UWORD uwBltCon0 = USEA|USED | MINTERM_A;
	g_pCustom->bltcon0 = uwBltCon0;
	g_pCustom->bltcon1 = 0;
	g_pCustom->bltafwm = 0xFFFF;
	g_pCustom->bltalwm = 0xFFFF;
	g_pCustom->bltamod = 0;
	ULONG ulA = (ULONG)(pQueue->pBg->Planes[0]);
	g_pCustom->bltapt = (APTR)ulA;
#ifdef GAME_DEBUG
	UWORD uwDrawnHeight = 0;
#endif

	for(UBYTE i = 0; i < pQueue->ubUndrawCount; ++i) {
		const tBobNew *pBob = pQueue->pBobs[i];
		if(pBob->isUndrawRequired) {
			// Undraw next
			ULONG ulDstOffs = (
				pQueue->pDst->BytesPerRow * pBob->pOldPositions[s_ubBufferCurr].sUwCoord.uwY +
				pBob->pOldPositions[s_ubBufferCurr].sUwCoord.uwX/8
			);
			ULONG ulCD = (ULONG)(pQueue->pDst->Planes[0]) + ulDstOffs;
			g_pCustom->bltdmod = pBob->_wModuloUndrawSave;
			g_pCustom->bltdpt = (APTR)ulCD;
			g_pCustom->bltsize = pBob->_uwBlitSize;

#ifdef GAME_DEBUG
			UWORD uwBlitWords = (pBob->uwWidth+15)/16 + 1;
			uwDrawnHeight += uwBlitWords * pBob->uwHeight;
#endif
			blitWait();
		}
	}
#ifdef GAME_DEBUG
	UWORD uwDrawLimit = s_pQueues[0].pBg->Rows * s_pQueues[0].pBg->Depth;
	if(uwDrawnHeight > uwDrawLimit) {
		logWrite(
			"ERR: BG restore out of bounds: used %hu, limit: %hu",
			uwDrawnHeight, uwDrawLimit
		);
	}
#endif
	s_ubBobsSaved = 0;
	s_ubBobsDrawn = 0;
	s_ubBobsPushed = 0;
	s_isPushingDone = 0;
}

void bobNewPushingDone(void) {
	s_isPushingDone = 1;
}

void bobNewEnd(void) {
	bobNewPushingDone();
	do {
		blitWait();
	} while(bobNewProcessNext());
	s_pQueues[s_ubBufferCurr].ubUndrawCount = s_ubBobsPushed;
	s_ubBufferCurr = !s_ubBufferCurr;
}
