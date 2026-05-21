#include "cross.h"

#include <ace/managers/blit.h>

#include "game.h"
#include "atlas.h"

tBitMap *g_pCrossBitMapAtlas[CROSS_ATLAS_SIZE] = {0};
tBitMap *g_pCrossBitMapMaskAtlas[CROSS_ATLAS_SIZE] = {0};

UBYTE getCrossSideState(UBYTE ubCrossData, UBYTE ubCrossSide) {
	return (ubCrossData >> ubCrossSide) & 1;
}

UBYTE getOppositeCrossSide(UBYTE ubCrossSide) {
	return (ubCrossSide + CROSS_SIDE_OPPOSITE_SHIFT) % CROSS_SIDE_COUNT;
}

void createCrossAtlas() {
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_A, "data/cross_frames/a.bm", "data/cross_frames/a_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_B, "data/cross_frames/b.bm", "data/cross_frames/b_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_C, "data/cross_frames/c.bm", "data/cross_frames/c_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_D, "data/cross_frames/d.bm", "data/cross_frames/d_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_E, "data/cross_frames/e.bm", "data/cross_frames/e_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_F, "data/cross_frames/f.bm", "data/cross_frames/f_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_A_FINAL, "data/cross_frames/a_final.bm", "data/cross_frames/a_final_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_C_FINAL, "data/cross_frames/c_final.bm", "data/cross_frames/c_final_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_E_FINAL, "data/cross_frames/e_final.bm", "data/cross_frames/e_final_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_CENTER, "data/cross_frames/center.bm", "data/cross_frames/center_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_CURSOR, "data/cross_frames/cursor.bm", "data/cross_frames/cursor_mask.bm");
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_CLEANUP, "data/cross_frames/cleanup.bm", "data/cross_frames/cleanup_mask.bm");

	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_DESTINATION_OFFSET + CROSS_SIDE_A, "data/cross_frames/a_final.bm", "data/cross_frames/a_final_mask.bm");
	/* Cross side A destination is not visible so it's disabled */
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_DESTINATION_OFFSET + CROSS_SIDE_C, "data/cross_frames/c_final.bm", "data/cross_frames/c_final_mask.bm");
	/* Cross side D destination is not visible so it's disabled */
	createAtlasFileWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_SIDE_DESTINATION_OFFSET + CROSS_SIDE_E, "data/cross_frames/e_final.bm", "data/cross_frames/e_final_mask.bm");
	/* Cross side F destination is not visible so it's disabled */
}

void destroyCrossAtlas() {
	destroyAtlasFilesWithMask(g_pCrossBitMapAtlas, g_pCrossBitMapMaskAtlas, CROSS_ATLAS_SIZE);
}

void drawCross(UWORD uwX, UWORD uwY, UBYTE ubCrossData) {
	drawCrossCenter(uwX, uwY, ubCrossData);
	drawCrossDepthMiddle(uwX, uwY, ubCrossData);
	drawCrossDepthTop(uwX, uwY, ubCrossData);
}

void drawCrossCenter(UWORD uwX, UWORD uwY, UBYTE ubCrossData) {
	if (ubCrossData) {
		drawCrossAtlasIndex(uwX, uwY, CROSS_CENTER);
	}
}

void drawCrossDepthMiddle(UWORD uwX, UWORD uwY, UBYTE ubCrossData) {
	for (UBYTE ubCrossSide = 1; ubCrossSide < CROSS_SIDE_COUNT; ubCrossSide += 2) {
		drawCrossSide(uwX, uwY, ubCrossData, ubCrossSide);
	}
}

void drawCrossDepthTop(UWORD uwX, UWORD uwY, UBYTE ubCrossData) {
	for (UBYTE ubCrossSide = CROSS_SIDE_COUNT; 0 < ubCrossSide; ubCrossSide -= 2) {
		drawCrossSide(uwX, uwY, ubCrossData, ubCrossSide - 2);
	}
}

void undrawCross(UWORD uwX, UWORD uwY) {
	drawCrossAtlasIndex(uwX, uwY, CROSS_CLEANUP);
}

void drawCrossSide(UWORD uwX, UWORD uwY, UBYTE ubCrossData, UBYTE ubCrossSide) {
	UBYTE ubCrossSideState = getCrossSideState(ubCrossData, ubCrossSide);
	if (ubCrossSideState) {
		drawCrossAtlasIndex(uwX, uwY, ubCrossSide);
	}
}

void drawDestinationPoint(UWORD uwX, UWORD uwY, UBYTE ubDestinationPointSide) {
	drawCrossAtlasIndex(uwX, uwY, CROSS_SIDE_DESTINATION_OFFSET + ubDestinationPointSide);
}

void undrawDestinationPoint(UWORD uwX, UWORD uwY) {
	undrawCross(uwX, uwY);
}

void drawCrossAtlasIndex(UWORD uwX, UWORD uwY, UBYTE ubAtlasIndex) {
	blitCopyMask(
		g_pCrossBitMapAtlas[ubAtlasIndex], 0, 0,
		g_pBufferManager->pBack, uwX, uwY,
		CROSS_WIDTH, CROSS_HEIGHT,
		(const UWORD *) g_pCrossBitMapMaskAtlas[ubAtlasIndex]->Planes[0]
	);
}
