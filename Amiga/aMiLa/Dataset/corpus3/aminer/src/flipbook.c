/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "flipbook.h"
#include <ace/managers/bob.h>
#include "game.h"
#include <ace/managers/ptplayer.h>
#include <ace/contrib/managers/audio_mixer.h>
#include "assets.h"

#define FLIPBOOK_NARROW_MAX 6
#define FLIPBOOK_WIDE_MAX 2
#define FLIPBBOK_MAX 6
#define FLIPBBOK_FRAME_WIDTH_NARROW 32
#define FLIPBBOK_FRAME_WIDTH_WIDE 48
#define FLIPBBOK_FRAME_HEIGHT 32
#define FLIPBOOK_FRAME_INDEX_FINISHED 255

#define SFX_CHANNEL_BOOM 1
#define SFX_PRIORITY_BOOM 5

typedef struct tFrameOffsets {
	UBYTE *pFrame;
	UBYTE *pMask;
} tFrameOffsets;

typedef struct tFlipbookBobRing {
	tBob *pBuffer;
	tBob *pNext;
	tBob *pLast;
} tFlipbookBobRing;

typedef struct tFlipbookAnimData {
	UBYTE ubPeakFrameIndex;
	UBYTE ubFrameCount;
	tFrameOffsets *pAnimFrameOffsets;
	UBYTE *pFrameDelays;
	tFlipbookBobRing *pBobRing;
	tPtplayerSfx *pSfx;
} tFlipbookAnimData;

typedef struct tFlipbookSpawn {
	tBob *pBob;
	const tFlipbookAnimData *pAnimData;
	tCbFlipbook cbOnPeak;
	tCbFlipbook cbOnEnd;
	void *pCbData;
	UBYTE ubFrame;
	UBYTE ubCnt;
} tFlipbookSpawn;

static tFlipbookAnimData s_pAnimDatas[FLIPBOOK_KIND_COUNT];

static tBob s_pBobsNarrow[FLIPBOOK_NARROW_MAX];
static tBob s_pBobsWide[FLIPBOOK_WIDE_MAX];
static tFlipbookBobRing s_sBobRingNarrow;
static tFlipbookBobRing s_sBobRingWide;

static tFlipbookSpawn s_pFlipbooks[FLIPBBOK_MAX];
static tFlipbookSpawn *s_pFlipbookNext = 0;

static tBitMap *s_pBoomFrames, *s_pBoomFramesMask;
static tBitMap *s_pTpFrames, *s_pTpFramesMask;
static tBitMap *s_pTeleporterFrames, *s_pTeleporterFramesMask;
static tPtplayerSfx *s_pSfxBoom, *s_pSfxTeleport;

static void flipbookAnimDataCreate(
	tFlipbookAnimData *pData, UBYTE ubPeakFrameIndex, UBYTE ubAnimFrameCount,
	UBYTE *pAnimFrameIndices, UBYTE *pAnimFrameDelays,
	tBitMap *pFrames, tBitMap *pFrameMasks, tFlipbookBobRing *pBobRing, tPtplayerSfx *pSfx
) {
	pData->ubFrameCount = ubAnimFrameCount;
	pData->pBobRing = pBobRing;
	pData->ubPeakFrameIndex = ubPeakFrameIndex;
	pData->pSfx = pSfx;
	pData->pAnimFrameOffsets = memAllocFast(pData->ubFrameCount * sizeof(pData->pAnimFrameOffsets[0]));
	pData->pFrameDelays = memAllocFast(pData->ubFrameCount * sizeof(pData->pFrameDelays[0]));
	for(UBYTE i = 0; i < pData->ubFrameCount; ++i) {
		UWORD uwOffsY = pAnimFrameIndices[i] * FLIPBBOK_FRAME_HEIGHT;
		pData->pAnimFrameOffsets[i].pFrame = bobCalcFrameAddress(pFrames, uwOffsY);
		pData->pAnimFrameOffsets[i].pMask = bobCalcFrameAddress(pFrameMasks, uwOffsY);
		pData->pFrameDelays[i] = pAnimFrameDelays[i];
	}
}

static void flipbookAnimDataDestroy(tFlipbookAnimData *pData) {
	memFree(pData->pAnimFrameOffsets, pData->ubFrameCount * sizeof(pData->pAnimFrameOffsets[0]));
	memFree(pData->pFrameDelays, pData->ubFrameCount * sizeof(pData->pFrameDelays[0]));
}

static void flipbookBobRingInit(
	tFlipbookBobRing *pRing, tBob *pBuffer, UBYTE ubCount, UBYTE ubWidth
) {
	pRing->pBuffer = pBuffer;
	pRing->pLast = &pRing->pBuffer[ubCount];
	pRing->pNext = &pRing->pBuffer[0];
	for(UBYTE i = 0; i < ubCount; ++i) {
		bobInit(
			&pBuffer[i], ubWidth, FLIPBBOK_FRAME_HEIGHT,
			1, 0, 0, 0, 0
		);
	}
}

static tBob *flipbookBobRingGetNext(tFlipbookBobRing *pRing) {
	tBob *pNext = pRing->pNext;
	if(++pRing->pNext == pRing->pLast) {
		pRing->pNext = pRing->pBuffer;
	}
	return pNext;
}

void flipbookManagerCreate(void) {
	s_pBoomFrames = bitmapCreateFromFd(GET_SUBFILE_PREFIX("explosion.bm"), 0);
	s_pBoomFramesMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("explosion_mask.bm"), 0);
	s_pTpFrames = bitmapCreateFromFd(GET_SUBFILE_PREFIX("teleport.bm"), 0);
	s_pTpFramesMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("teleport_mask.bm"), 0);
	s_pTeleporterFrames = bitmapCreateFromFd(GET_SUBFILE_PREFIX("base_teleporter.bm"), 0);
	s_pTeleporterFramesMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("base_teleporter_mask.bm"), 0);

	s_pSfxBoom = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/explosion.sfx"), 1);
	s_pSfxTeleport = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/teleport.sfx"), 1);


	flipbookBobRingInit(
		&s_sBobRingNarrow, s_pBobsNarrow,
		FLIPBOOK_NARROW_MAX, FLIPBBOK_FRAME_WIDTH_NARROW
	);
	flipbookBobRingInit(
		&s_sBobRingWide, s_pBobsWide,
		FLIPBOOK_WIDE_MAX, FLIPBBOK_FRAME_WIDTH_WIDE
	);

	flipbookAnimDataCreate(
		&s_pAnimDatas[FLIPBOOK_KIND_TELEPORTER_OUT], 20, 25,
		(UBYTE[]){0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24},
		(UBYTE[]){4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
		s_pTeleporterFrames, s_pTeleporterFramesMask, &s_sBobRingWide, s_pSfxTeleport
	);
	flipbookAnimDataCreate(
		&s_pAnimDatas[FLIPBOOK_KIND_TELEPORTER_IN], 8, 17,
		(UBYTE[]){24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8},
		(UBYTE[]){2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
		s_pTeleporterFrames, s_pTeleporterFramesMask, &s_sBobRingWide, s_pSfxTeleport
	);
	flipbookAnimDataCreate(
		&s_pAnimDatas[FLIPBOOK_KIND_BOOM], 5, 10,
		(UBYTE[]){0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
		(UBYTE[]){2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
		s_pBoomFrames, s_pBoomFramesMask, &s_sBobRingNarrow, s_pSfxBoom
	);
	flipbookAnimDataCreate(
		&s_pAnimDatas[FLIPBOOK_KIND_TELEPORT], 5, 10,
		(UBYTE[]){0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
		(UBYTE[]){3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
		s_pTpFrames, s_pTpFramesMask, &s_sBobRingNarrow, s_pSfxTeleport
	);

	s_pFlipbookNext = &s_pFlipbooks[0];
	for(UBYTE i = 0; i < FLIPBBOK_MAX; ++i) {
		s_pFlipbooks[i].ubFrame = FLIPBOOK_FRAME_INDEX_FINISHED;
		s_pFlipbooks[i].ubCnt = 0;
	}
}

void flipbookManagerDestroy(void) {
	flipbookAnimDataDestroy(&s_pAnimDatas[FLIPBOOK_KIND_TELEPORTER_OUT]);
	flipbookAnimDataDestroy(&s_pAnimDatas[FLIPBOOK_KIND_TELEPORTER_IN]);
	flipbookAnimDataDestroy(&s_pAnimDatas[FLIPBOOK_KIND_BOOM]);
	flipbookAnimDataDestroy(&s_pAnimDatas[FLIPBOOK_KIND_TELEPORT]);

	bitmapDestroy(s_pBoomFrames);
	bitmapDestroy(s_pBoomFramesMask);
	bitmapDestroy(s_pTpFrames);
	bitmapDestroy(s_pTpFramesMask);
	bitmapDestroy(s_pTeleporterFrames);
	bitmapDestroy(s_pTeleporterFramesMask);

	ptplayerSfxDestroy(s_pSfxBoom);
	ptplayerSfxDestroy(s_pSfxTeleport);
}

void flipbookAdd(
	UWORD uwX, UWORD uwY, tCbFlipbook cbOnPeak, tCbFlipbook cbOnEnd,
	void *pCbData, tFlipbookKind eKind
) {
	const tFlipbookAnimData *pAnimData = &s_pAnimDatas[eKind];
	tFlipbookSpawn *pStart = s_pFlipbookNext;
	do {
		if(s_pFlipbookNext->ubFrame == FLIPBOOK_FRAME_INDEX_FINISHED) {
			break;
		}
		if(++s_pFlipbookNext >= &s_pFlipbooks[FLIPBBOK_MAX]) {
			s_pFlipbookNext = &s_pFlipbooks[0];
		}
	} while(s_pFlipbookNext != pStart);

	// If there's free slot, s_pFlipbookNext will point to it
	// Otherwise, it will use oldest - the one from pStart

	if(
		s_pFlipbookNext == pStart &&
		s_pFlipbookNext->ubFrame != FLIPBOOK_FRAME_INDEX_FINISHED
	) {
		if(
			s_pFlipbookNext->ubFrame < s_pFlipbookNext->pAnimData->ubPeakFrameIndex &&
			s_pFlipbookNext->cbOnPeak
		) {
			// Call pStart's callback if it's before peak
			s_pFlipbookNext->cbOnPeak(s_pFlipbookNext->pCbData);
		}
		if(s_pFlipbookNext->cbOnEnd) {
			s_pFlipbookNext->cbOnEnd(s_pFlipbookNext->pCbData);
		}
	}

	s_pFlipbookNext->pBob = flipbookBobRingGetNext(pAnimData->pBobRing);
	s_pFlipbookNext->pBob->sPos.uwX = uwX;
	s_pFlipbookNext->pBob->sPos.uwY = uwY;
	s_pFlipbookNext->ubFrame = 0;
	s_pFlipbookNext->ubCnt = 0;
	s_pFlipbookNext->cbOnPeak = cbOnPeak;
	s_pFlipbookNext->cbOnEnd = cbOnEnd;
	s_pFlipbookNext->pCbData = pCbData;
	s_pFlipbookNext->pAnimData = pAnimData;

	bobSetFrame(
		s_pFlipbookNext->pBob,
		pAnimData->pAnimFrameOffsets[0].pFrame,
		pAnimData->pAnimFrameOffsets[0].pMask
	);

	audioMixerPlaySfx(pAnimData->pSfx, SFX_CHANNEL_BOOM, SFX_PRIORITY_BOOM, 0);
}

void flipbookManagerProcess(void) {
	tFlipbookSpawn *pFlipbook = &s_pFlipbooks[0];
	for(UBYTE i = 0; i < FLIPBBOK_MAX; ++i, ++pFlipbook) {
		const tFlipbookAnimData *pAnimData = pFlipbook->pAnimData;
		if(pFlipbook->ubFrame != FLIPBOOK_FRAME_INDEX_FINISHED) {
			if(pFlipbook->ubCnt >= pAnimData->pFrameDelays[pFlipbook->ubFrame]) {
				pFlipbook->ubCnt = 0;
				++pFlipbook->ubFrame;
				if(pFlipbook->ubFrame == pAnimData->ubPeakFrameIndex && pFlipbook->cbOnPeak) {
					pFlipbook->cbOnPeak(pFlipbook->pCbData);
				}
				bobSetFrame(
					pFlipbook->pBob,
					pAnimData->pAnimFrameOffsets[pFlipbook->ubFrame].pFrame,
					pAnimData->pAnimFrameOffsets[pFlipbook->ubFrame].pMask
				);
			}
			else {
				++pFlipbook->ubCnt;
			}
			if(pFlipbook->ubFrame < pAnimData->ubFrameCount) {
				gameTryPushBob(pFlipbook->pBob);
			}
			else {
				if(pFlipbook->cbOnEnd) {
					pFlipbook->cbOnEnd(pFlipbook->pCbData);
				}
				pFlipbook->ubFrame = FLIPBOOK_FRAME_INDEX_FINISHED;
			}
		}
	}
}
