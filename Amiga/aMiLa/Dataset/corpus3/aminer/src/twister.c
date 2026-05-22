/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "twister.h"
#include <ace/generic/screen.h>
#include <ace/managers/blit.h>
#include <ace/utils/chunky.h>
#include "core.h"
#include "quest_gate.h"
#include "assets.h"

#define TWISTER_BITMAP_VISIBLE_WIDTH 80
#define TWISTER_BITMAP_VISIBLE_HEIGHT 65
#define CLIP_MARGIN_X 32
#define CLIP_MARGIN_Y 16
#define TWISTER_BITMAP_WIDTH (2 * CLIP_MARGIN_X + TWISTER_BITMAP_VISIBLE_WIDTH)
#define TWISTER_BITMAP_HEIGHT (2 * CLIP_MARGIN_Y + TWISTER_BITMAP_VISIBLE_HEIGHT)
#define TWISTER_CAMERA_OFFSET_X (65 / 2)
#define TWISTER_CAMERA_OFFSET_Y (65 / 2)
#define TWISTER_CENTER_X (CLIP_MARGIN_X + TWISTER_CAMERA_OFFSET_X)
#define TWISTER_CENTER_Y (CLIP_MARGIN_Y + TWISTER_CAMERA_OFFSET_Y)
#define TWISTER_CENTER_RADIUS 1
#define TWISTER_BLOCK_SIZE 32
#define TWISTER_MIN_BLOCK_X (-(((TWISTER_CAMERA_OFFSET_X + TWISTER_BLOCK_SIZE - 1) / TWISTER_BLOCK_SIZE) + 2))
#define TWISTER_MAX_BLOCK_X (+((((TWISTER_BITMAP_HEIGHT - TWISTER_CAMERA_OFFSET_X) + TWISTER_BLOCK_SIZE - 1) / TWISTER_BLOCK_SIZE) + 0))
#define TWISTER_MIN_BLOCK_Y (-(((TWISTER_CAMERA_OFFSET_Y + TWISTER_BLOCK_SIZE - 1) / TWISTER_BLOCK_SIZE) + 2))
#define TWISTER_MAX_BLOCK_Y (+(((TWISTER_BITMAP_WIDTH - TWISTER_CAMERA_OFFSET_Y + TWISTER_BLOCK_SIZE - 1) / TWISTER_BLOCK_SIZE) + 0))
// #define TWISTER_MIN_BLOCK_X  (-2)
// #define TWISTER_MAX_BLOCK_X (+2)
// #define TWISTER_MIN_BLOCK_Y (-2)
// #define TWISTER_MAX_BLOCK_Y (2)
#define TWISTER_BLOCKS_X (TWISTER_MAX_BLOCK_X - TWISTER_MIN_BLOCK_X)
#define TWISTER_BLOCKS_Y (TWISTER_MAX_BLOCK_Y - TWISTER_MIN_BLOCK_Y)
#define TWISTER_LEFT_BORDER (0)
#define TWISTER_RIGHT_BORDER (TWISTER_BITMAP_WIDTH)
#define TWISTER_TOP_BORDER (0)
#define TWISTER_BOTTOM_BORDER (TWISTER_BITMAP_HEIGHT)

static UBYTE s_ps;
static UBYTE s_isTwisterEnabled;
static tBitMap *s_pBitmaps[2];
static tBitMap *s_pEyeMask;
static UBYTE s_ubBackBuffer;

static void blitCopyAlignedMasked(
	const tBitMap *pSrc, WORD wSrcX, WORD wSrcY,
	tBitMap *pDst, WORD wDstX, WORD wDstY, WORD wWidth, WORD wHeight
) {
	UWORD uwBlitWords = wWidth >> 4;
	ULONG ulSrcOffs = pSrc->BytesPerRow * wSrcY + (wSrcX>>3);
	ULONG ulDstOffs = pDst->BytesPerRow * wDstY + (wDstX>>3);

	WORD wSrcModulo = bitmapGetByteWidth(pSrc) - uwBlitWords * 2;
	WORD wDstModulo = bitmapGetByteWidth(pDst) - uwBlitWords * 2;
	WORD wMaskModulo = bitmapGetByteWidth(s_pEyeMask) - uwBlitWords * 2;
	wHeight *= 5;

	blitWait(); // Don't modify registers when other blit is in progress
	g_pCustom->bltcon0 = USEA|USEB|USEC|USED | MINTERM_COOKIE;
	g_pCustom->bltcon1 = 0;
	g_pCustom->bltafwm = 0xFFFF;
	g_pCustom->bltalwm = 0xFFFF;
	g_pCustom->bltamod = wMaskModulo;
	g_pCustom->bltbmod = wSrcModulo;
	g_pCustom->bltcmod = wDstModulo;
	g_pCustom->bltdmod = wDstModulo;
	g_pCustom->bltapt = &s_pEyeMask->Planes[0][0];
	g_pCustom->bltbpt = &pSrc->Planes[0][ulSrcOffs];
	g_pCustom->bltcpt = &pDst->Planes[0][ulDstOffs];
	g_pCustom->bltdpt = &pDst->Planes[0][ulDstOffs];
	g_pCustom->bltsize = (wHeight << HSIZEBITS) | uwBlitWords;
}

void twisterEnable(void) {
	s_isTwisterEnabled = 1;
	s_ps = 0;
	s_pBitmaps[0] = bitmapCreate(TWISTER_BITMAP_WIDTH, TWISTER_BITMAP_HEIGHT, 5, BMF_CLEAR | BMF_INTERLEAVED);
	s_pBitmaps[1] = bitmapCreate(TWISTER_BITMAP_WIDTH, TWISTER_BITMAP_HEIGHT, 5, BMF_CLEAR | BMF_INTERLEAVED);
	s_pEyeMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("gate_eye_mask.bm"), 0);
	s_ubBackBuffer = 0;

	UWORD uwDestY = (GATE_DEPTH_PX & (512 - 1));
	blitCopyAligned(
		g_pMainBuffer->pScroll->pBack, 32 + 64, uwDestY + 29,
		s_pBitmaps[!s_ubBackBuffer], CLIP_MARGIN_X, CLIP_MARGIN_Y,
		TWISTER_BITMAP_VISIBLE_WIDTH, TWISTER_BITMAP_VISIBLE_HEIGHT
	);
	blitCopyAligned(
		g_pMainBuffer->pScroll->pBack, 32 + 64, uwDestY + 29,
		s_pBitmaps[s_ubBackBuffer], CLIP_MARGIN_X, CLIP_MARGIN_Y,
		TWISTER_BITMAP_VISIBLE_WIDTH, TWISTER_BITMAP_VISIBLE_HEIGHT
	);
}

void twisterDisable(void) {
	s_isTwisterEnabled = 0;
	bitmapDestroy(s_pBitmaps[0]);
	bitmapDestroy(s_pBitmaps[1]);
	bitmapDestroy(s_pEyeMask);
}

void twisterProcess(void) {
	if(!s_isTwisterEnabled) {
		return;
	}

	++s_ps;

	UWORD uwShift = 0;
	// for(UBYTE i = 0; i <= 4; ++i) {
		uwShift = (uwShift << 1) | ((s_ps >> 0) & 1);
		uwShift = (uwShift << 1) | ((s_ps >> 1) & 1);
		uwShift = (uwShift << 1) | ((s_ps >> 2) & 1);
		uwShift = (uwShift << 1) | ((s_ps >> 3) & 1);
		uwShift = (uwShift << 1) | ((s_ps >> 4) & 1);
	// }

	for(BYTE y = TWISTER_MIN_BLOCK_Y; y < TWISTER_MAX_BLOCK_Y; ++y) {
		WORD yy = TWISTER_CENTER_Y + y * TWISTER_BLOCK_SIZE + uwShift;
		for(BYTE x = TWISTER_MIN_BLOCK_X; x < TWISTER_MAX_BLOCK_X; ++x) {
			WORD xx = TWISTER_CENTER_X + x * TWISTER_BLOCK_SIZE + uwShift;

			WORD wSrcX = xx - (y + 1) - (x + 1);
			WORD wSrcY = yy - (y + 1) + (x + 1);
			WORD wDstX = xx;
			WORD wDstY = yy;
			WORD wWidth = TWISTER_BLOCK_SIZE;
			WORD wHeight = TWISTER_BLOCK_SIZE;

			if(wDstX < TWISTER_LEFT_BORDER) {
				WORD wDelta = TWISTER_LEFT_BORDER - wDstX;
				wSrcX += wDelta;
				wWidth -= wDelta;
				wDstX = TWISTER_LEFT_BORDER;
			}
			if(wSrcX < TWISTER_LEFT_BORDER) {
				WORD wDelta = TWISTER_LEFT_BORDER - wSrcX;
				wDstX += wDelta;
				wWidth -= wDelta;
				wSrcX = TWISTER_LEFT_BORDER;
			}
			if(wSrcX + wWidth > TWISTER_RIGHT_BORDER) {
				wWidth = TWISTER_RIGHT_BORDER - wSrcX;
			}
			if(wDstX + wWidth > TWISTER_RIGHT_BORDER) {
				wWidth = TWISTER_RIGHT_BORDER - wDstX;
			}

			if(wDstY < TWISTER_TOP_BORDER) {
				WORD wDelta = TWISTER_TOP_BORDER - wDstY;
				wSrcY += wDelta;
				wHeight -= wDelta;
				wDstY = TWISTER_TOP_BORDER;
			}
			if(wSrcY < TWISTER_TOP_BORDER) {
				WORD wDelta = TWISTER_TOP_BORDER - wSrcY;
				wDstY += wDelta;
				wWidth -= wDelta;
				wSrcY = TWISTER_TOP_BORDER;
			}
			if(wSrcY + wHeight > TWISTER_BOTTOM_BORDER) {
				wHeight = TWISTER_BOTTOM_BORDER - wSrcY;
			}
			if(wDstY + wHeight > TWISTER_BOTTOM_BORDER) {
				wHeight = TWISTER_BOTTOM_BORDER - wDstY;
			}

			if(wWidth <= 0 || wHeight <= 0) {
				continue;
			}

			blitCopy(
				s_pBitmaps[!s_ubBackBuffer], wSrcX, wSrcY,
				s_pBitmaps[s_ubBackBuffer], wDstX, wDstY, wWidth, wHeight, MINTERM_COOKIE
			);
			// blitLine(s_pBitmaps[s_ubBackBuffer], wSrcX, wSrcY, wDstX, wDstY, 2, 0xFFFF, 0);
			// chunkyToPlanar(1, wSrcX, wSrcY, s_pBitmaps[s_ubBackBuffer]);
			// chunkyToPlanar(3, wDstX, wDstY, s_pBitmaps[s_ubBackBuffer]);
		}
	}

	for(UWORD y = TWISTER_CENTER_Y - TWISTER_CENTER_RADIUS; y <= TWISTER_CENTER_Y + TWISTER_CENTER_RADIUS; ++y) {
		for(UWORD x = TWISTER_CENTER_X - TWISTER_CENTER_RADIUS; x <= TWISTER_CENTER_X + TWISTER_CENTER_RADIUS; ++x) {
			UBYTE ubColor = 17 + (randUw(&g_sRand) & 3);
			chunkyToPlanar(ubColor, x, y, s_pBitmaps[s_ubBackBuffer]);
		}
	}
	// UBYTE ubColor = 17 + (randUw(&g_sRand) & 3);
	// blitRect(
	// 	s_pBitmaps[s_ubBackBuffer],
	// 	TWISTER_CENTER_X - 1,
	// 	TWISTER_CENTER_Y - 8,
	// 	2, 16, ubColor
	// );
	// blitRect(
	// 	s_pBitmaps[s_ubBackBuffer],
	// 	TWISTER_CENTER_X - 8,
	// 	TWISTER_CENTER_Y - 1,
	// 	16, 1, ubColor
	// );

	UWORD uwDestY = (GATE_DEPTH_PX & (512 - 1));
	blitCopyAlignedMasked(
		s_pBitmaps[!s_ubBackBuffer], CLIP_MARGIN_X, CLIP_MARGIN_Y,
		g_pMainBuffer->pScroll->pBack, 32 + 64, uwDestY + 29,
		TWISTER_BITMAP_VISIBLE_WIDTH, TWISTER_BITMAP_VISIBLE_HEIGHT
	);
	s_ubBackBuffer = !s_ubBackBuffer;
}
