/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_BOB_SEQUENCE_H_
#define _AMINER_BOB_SEQUENCE_H_

#include <ace/managers/bob.h>
#include <ace/managers/viewport/tilebuffer.h>

#define BOB_SEQUENCE_ANIM_LENGTH_MAX 200

typedef struct tBobAnimFrame {
	UBYTE *pAddrFrame;
} tBobAnimFrame;

typedef struct _tBobSequence {
	tBob sBob;
	tUwRect sAnimRect;
	tBobAnimFrame *pAnimFrames;
	UBYTE ubAnimLength;
	UBYTE ubCurrentFrame; ///< Current sequence frame.
	UBYTE ubSpeed; ///< Determines cooldown.
	UBYTE ubCurrentCooldown;
	UBYTE ubWasVisible;
	UBYTE isDrawnOnce;
} tBobSequence;

void bobSequenceReset(UBYTE *pFrameMask);

void bobSequenceAdd(
	tUwRect sAnimRect, tBobAnimFrame *pAnimFrames, UBYTE ubAnimLength,
	UBYTE ubSpeed
);

void bobSequenceProcess(void);

#endif // _AMINER_BOB_SEQUENCE_H_
