/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "bob_sequence.h"
#include <ace/managers/log.h>
#include "game.h"
#include "core.h"

#define BOB_SEQUENCE_COUNT_MAX 5

static tBobSequence s_pSequences[BOB_SEQUENCE_COUNT_MAX];
static UBYTE s_ubSequenceCount;
static UBYTE s_ubDrawCount;
static UBYTE s_ubCurrentSequence;
static UBYTE *s_pFrameMask;

void bobSequenceReset(UBYTE *pFrameMask) {
	s_ubSequenceCount = 0;
	s_ubDrawCount = 0;
	s_ubCurrentSequence = 0;
	s_pFrameMask = pFrameMask;
}

void bobSequenceAdd(
	tUwRect sAnimRect, tBobAnimFrame *pAnimFrames, UBYTE ubAnimLength,
	UBYTE ubSpeed
) {
	if(s_ubSequenceCount >= BOB_SEQUENCE_COUNT_MAX) {
		logWrite("ERR: No more room for sequence %hhu\n", s_ubSequenceCount);
		return;
	}
	tBobSequence *pSequence = &s_pSequences[s_ubSequenceCount];
	pSequence->sAnimRect = sAnimRect;
	pSequence->pAnimFrames = pAnimFrames;
	pSequence->ubAnimLength = ubAnimLength;
	pSequence->ubCurrentFrame = 0;
	pSequence->ubSpeed = ubSpeed;
	pSequence->ubCurrentCooldown = ubSpeed;
	pSequence->isDrawnOnce = 0;
	pSequence->ubWasVisible = 0;
	bobInit(
		&pSequence->sBob, sAnimRect.uwWidth, sAnimRect.uwHeight, 0,
		pAnimFrames[0].pAddrFrame, s_pFrameMask,
		sAnimRect.uwX, sAnimRect.uwY
	);
	logWrite("Added bob sequence %hhu\n", s_ubSequenceCount);
	++s_ubSequenceCount;
}

void bobSequenceProcess(void) {
	UBYTE ubStartSequence = s_ubCurrentSequence;
	do {
		tBobSequence *pSequence = &s_pSequences[s_ubCurrentSequence++];
		if(s_ubCurrentSequence == s_ubSequenceCount) {
			s_ubCurrentSequence = 0;
		}

		UBYTE isOnBuffer = gameCanPushBob(&pSequence->sBob);
		if(isOnBuffer) {
			if(!pSequence->ubWasVisible) {
				pSequence->ubCurrentFrame = 0xFF-1;
				pSequence->isDrawnOnce = 0;
				pSequence->ubCurrentCooldown = 1;
				pSequence->ubWasVisible = 1;
			}
			else if(pSequence->isDrawnOnce) {
				pSequence->isDrawnOnce = 0;
				bobPush(&pSequence->sBob);
				coreTransferBobToPristine(&pSequence->sBob);
				break;
			}
			else {
				if(--pSequence->ubCurrentCooldown == 0) {
					pSequence->ubCurrentCooldown = pSequence->ubSpeed;
					if(++pSequence->ubCurrentFrame >= pSequence->ubAnimLength) {
						pSequence->ubCurrentFrame = 0;
					}
					const tBobAnimFrame *pAnimFrame = &pSequence->pAnimFrames[pSequence->ubCurrentFrame];
					bobSetFrame(&pSequence->sBob, pAnimFrame->pAddrFrame, s_pFrameMask);
					bobPush(&pSequence->sBob);
					coreTransferBobToPristine(&pSequence->sBob);
					pSequence->isDrawnOnce = 1;
					break;
				}
			}
		}
		else {
			pSequence->ubWasVisible = 0;
		}
	} while(s_ubCurrentSequence != ubStartSequence);
}
