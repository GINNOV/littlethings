/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "core.h"
#include <ace/generic/screen.h>
#include <ace/managers/rand.h>
#include <ace/managers/system.h>
#include <ace/managers/key.h>
#include <ace/utils/palette.h>
#include <ace/contrib/managers/audio_mixer.h>
#include "menu.h"
#include "dino.h"
#include "inventory.h"
#include "quest_gate.h"
#include "game.h"
#include "hud.h"
#include "vehicle.h"
#include "fade.h"
#include "debug.h"
#include "base.h"
#include "ground_layer.h"
#include "hi_score.h"
#include "tile.h"
#include "flipbook.h"
#include <comm/comm.h>
#include <comm/page_news.h>
#include "defs.h"
#include "settings.h"
#include "collectibles.h"
#include "progress_bar.h"
#include "assets.h"
#include "bob_sequence.h"
#include "language.h"
#include "blitter_mutex.h"
#include "mode_menu.h"
#include "tile_variant.h"
#include "base_unlocks.h"
#include "protests.h"
#include "msg.h"

#define CORE_INIT_BAR_MARGIN 10
#define CORE_INIT_BAR_WIDTH (SCREEN_PAL_WIDTH - 2 * CORE_INIT_BAR_MARGIN)
#define CORE_INIT_BAR_HEIGHT 1
#define CORE_INIT_BAR_BORDER_DISTANCE 2
#define DRIP_ANIM_LENGTH 10

static tBitMap *s_pTiles;
static UWORD s_pPaletteRef[1 << GAME_BPP];
static UWORD *s_pColorBg;

static tView *s_pView;
static tVPort *s_pVpMain;
static tBitMap *s_pDripBitmap;
static tBitMap *s_pDripMask;
static tBobAnimFrame s_pDripFrames[DRIP_ANIM_LENGTH];
static tBitMap *s_pPristineBuffer;

static const tProgressBarConfig s_sProgressBarConfig = {
	.sBarPos = {
		.uwX = CORE_INIT_BAR_MARGIN,
		.uwY = SCREEN_PAL_HEIGHT - HUD_HEIGHT - CORE_INIT_BAR_MARGIN - CORE_INIT_BAR_HEIGHT
	},
	.uwWidth =  CORE_INIT_BAR_WIDTH,
	.uwHeight = CORE_INIT_BAR_HEIGHT,
	.ubBorderDistance = CORE_INIT_BAR_BORDER_DISTANCE,
	.ubColorBorder = COMM_DISPLAY_COLOR_TEXT,
	.ubColorBar = COMM_DISPLAY_COLOR_TEXT_DARK,
};

//------------------------------------------------------------------ PRIVATE FNS

static void mainPaletteProcess(UBYTE ubFadeLevel) {
	tFadeState eState = fadeGetState();
	if(eState == FADE_STATE_IN_MORPHING || eState == FADE_STATE_OUT_MORPHING) {
		*s_pColorBg = paletteColorMix(s_pPaletteRef[0], fadeGetSecondaryColor(), ubFadeLevel);
		for(UBYTE i = 0; i < 27; ++i) {
			g_pCustom->color[i] = paletteColorMix(s_pPaletteRef[i], fadeGetSecondaryColor(), ubFadeLevel);
		}
	}
}

static void coreBobSequencesCreate(void) {
	s_pDripMask = bitmapCreate(16, 20, GAME_BPP, BMF_INTERLEAVED);
	blitRect(s_pDripMask, 0, 0, 16, 20, (1 << GAME_BPP) - 1);
	bobSequenceReset(s_pDripMask->Planes[0]);

	s_pDripBitmap = bitmapCreateFromFd(GET_SUBFILE_PREFIX("bg_factory_drip.bm"), 0);
	for(UBYTE i = 0; i < DRIP_ANIM_LENGTH; ++i) {
		s_pDripFrames[i].pAddrFrame = bobCalcFrameAddress(s_pDripBitmap, i * 20);
	}

	bobSequenceAdd((tUwRect){.uwX = 32 + 247, .uwY = 233, .uwWidth = 16, .uwHeight = 20}, s_pDripFrames, DRIP_ANIM_LENGTH, 5);
}

static void coreBobSequencesDestroy(void) {
	bitmapDestroy(s_pDripMask);
	bitmapDestroy(s_pDripBitmap);
}

static void coreVblankHandler(
	UNUSED_ARG REGARG(volatile tCustom *pCustom, "a0"),
	UNUSED_ARG REGARG(volatile void *pData, "a1")
) {
	if(systemBlitterIsUsed() || !blitterMutexTryLock()) {
		return;
	}

	commProcessPage();
	blitterMutexUnlock();
}

static void onTileDraw(
	UNUSED_ARG UWORD uwTileX, UNUSED_ARG UWORD uwTileY,
	tBitMap *pBitMap, UWORD uwBitMapX, UWORD uwBitMapY
) {
	if(tileIsExcavated(uwTileX, uwTileY)) {
		BYTE bOverlay = -1;
		if(tileIsSolid(uwTileX, uwTileY - 1)) {
			bOverlay += 1;
		}

		tBaseId eBaseId = baseGetCurrentId();
		const tBase *pBase = baseGetById(eBaseId);
		if(
			g_eGameMode != GAME_MODE_STORY || eBaseId == BASE_ID_GROUND ||
			uwTileY < pBase->uwTileDepth || pBase->uwTileDepth + BASE_CAVE_HEIGHT < uwTileY
		) {
			if(tileIsSolid(uwTileX, uwTileY + 1)) {
				bOverlay += 2;
			}

			if(uwTileX >= 10 || tileIsSolid(uwTileX + 1, uwTileY)) {
				bOverlay += 4;
			}

			if(tileIsSolid(uwTileX - 1, uwTileY)) {
				bOverlay += 8;
			}
		}

		if(bOverlay >= 0) {
			// TODO: optimize with custom blitter code
			blitCopyMask(
				g_pTileOverlays, 0, (UBYTE)bOverlay * TILE_SIZE,
				pBitMap, uwBitMapX, uwBitMapY, TILE_SIZE, TILE_SIZE,
				g_pTileOverlayMasks->Planes[0]
			);
			// blitRect(pBitMap, uwBitMapX + 5, uwBitMapY + 5, 20, 20, COMM_DISPLAY_COLOR_TEXT);
		}
	}

	blitCopyAligned(
		pBitMap, uwBitMapX, uwBitMapY,
		s_pPristineBuffer, uwBitMapX, uwBitMapY, TILE_SIZE, TILE_SIZE
	);
}

//------------------------------------------------------------------- PUBLIC FNS

void coreProcessBeforeBobs(void) {
	// Undraw all bobs
	debugColor(0x008);
	bobBegin(g_pMainBuffer->pScroll->pBack);

	// Draw pending tiles
	tileBufferQueueProcess(g_pMainBuffer);

	// Draw collectibles and bg anims before anything else
	collectiblesProcess();
	if(!gameIsCutsceneActive()) {
		bobSequenceProcess();
		protestsDrawBobs();
		baseUnlocksDrawBack();
	}
}

void coreProcessAfterBobs(void) {

	// Finish bob drawing
	bobPushingDone();
	bobEnd();

	if(!gameIsCutsceneActive()) {
		// Update HUD state machine and draw stuff
		hudProcess();
	}

	// Load next base tiles, if needed
	baseProcess();

	// Update palette for new ground layers, also take into account fade level
	fadeProcess();
	UBYTE ubFadeLevel = fadeGetLevel();
	groundLayerProcess(g_pMainBuffer->pCamera->uPos.uwY, ubFadeLevel, fadeGetSecondaryColor());
	mainPaletteProcess(ubFadeLevel);

	debugColor(0x800);
	viewProcessManagers(s_pView);
	copProcessBlocks();
	debugColor(*s_pColorBg);
	systemIdleBegin();
	vPortWaitUntilEnd(s_pVpMain);
	systemIdleEnd();
}

void coreTransferBobToPristine(tBob *pBob) {
	bobProcessAll();
	UWORD uwAvailHeight = g_pMainBuffer->pScroll->uwBmAvailHeight;
	UWORD uwPartHeight = uwAvailHeight - SCROLLBUFFER_HEIGHT_MODULO(pBob->sPos.uwY, uwAvailHeight);

	UBYTE ubDstOffs = pBob->sPos.uwX & 0xF;
	UWORD uwBlitWidth = (pBob->uwWidth + ubDstOffs + 15) & 0xFFF0;
	UWORD uwBlitWords = uwBlitWidth >> 4;
	UWORD uwBlitSize = ((pBob->_uwInterleavedHeight) << HSIZEBITS) | uwBlitWords;
	UBYTE *pB = pBob->pFrameData;
	ULONG ulDestinationOffset = pBob->_pSaveOffsets[bobGetCurrentBufferIndex()];
	UBYTE *pCD = &s_pPristineBuffer->Planes[0][ulDestinationOffset];

	blitWait();
	if(pBob->pMaskData) {
		UBYTE *pA = pBob->pMaskData;
		g_pCustom->bltapt = (APTR)pA;
	}

	g_pCustom->bltbpt = (APTR)pB;
	g_pCustom->bltcpt = (APTR)pCD;
	g_pCustom->bltdpt = (APTR)pCD;
	if(uwPartHeight >= pBob->uwHeight) {
		g_pCustom->bltsize = uwBlitSize;
	}
	else {
		UWORD uwInterleavedPartHeight = uwPartHeight * GAME_BPP;
		g_pCustom->bltsize = (uwInterleavedPartHeight << HSIZEBITS) | uwBlitWords;
		pCD = &s_pPristineBuffer->Planes[0][pBob->sPos.uwX / 8];
		blitWait();
		g_pCustom->bltcpt = (APTR)pCD;
		g_pCustom->bltdpt = (APTR)pCD;
		g_pCustom->bltsize =((pBob->_uwInterleavedHeight - uwInterleavedPartHeight) << HSIZEBITS) | uwBlitWords;
	}
}

//-------------------------------------------------------------------- GAMESTATE

static void coreGsCreate(void) {
	// Create bare-minimum display
	s_pView = viewCreate(0,
		TAG_VIEW_GLOBAL_PALETTE, 1,
	TAG_END);

  tVPort *pVpHud = vPortCreate(0,
    TAG_VPORT_VIEW, s_pView,
    TAG_VPORT_BPP, GAME_BPP,
    TAG_VPORT_HEIGHT, HUD_HEIGHT,
  TAG_END);

	s_pVpMain = vPortCreate(0,
		TAG_VPORT_VIEW, s_pView,
		TAG_VPORT_BPP, GAME_BPP,
	TAG_END);

	// It should be fine with 1 extra on TAG_TILEBUFFER_BOUND_TILE_X to the left -
	// if something gets drawn to the right it will flow to the offscreen left.
	s_pTiles = bitmapCreateFromFd(GET_SUBFILE_PREFIX("tiles.bm"), 0);
	g_pMainBuffer = tileBufferCreate(0,
		TAG_TILEBUFFER_VPORT, s_pVpMain,
		TAG_TILEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
		TAG_TILEBUFFER_BOUND_TILE_X, 1 + 10,
		TAG_TILEBUFFER_BOUND_TILE_Y, TILE_MINE_DEPTH,
		TAG_TILEBUFFER_IS_DBLBUF, 1,
		TAG_TILEBUFFER_TILE_SHIFT, 5,
		TAG_TILEBUFFER_REDRAW_QUEUE_LENGTH, 100,
		TAG_TILEBUFFER_CALLBACK_TILE_DRAW, onTileDraw,
		TAG_TILEBUFFER_TILESET, s_pTiles,
	TAG_END);
	s_pPristineBuffer = bitmapCreate(
		bitmapGetByteWidth(g_pMainBuffer->pScroll->pBack) * 8,
		g_pMainBuffer->pScroll->pBack->Rows, GAME_BPP, BMF_INTERLEAVED | BMF_CLEAR
	);

	// Load the view and draw the progress bar
	paletteLoadFromFd(GET_SUBFILE_PREFIX("aminer.plt"), s_pPaletteRef, 1 << GAME_BPP);
	memcpy(pVpHud->pPalette, s_pPaletteRef, sizeof(pVpHud->pPalette));
	defsCreateLocale(languageGetPrefix());
	commCreate(s_pPristineBuffer);
	viewLoad(s_pView);
	viewProcessManagers(s_pView);
	commTryShow(0, 0, 1);
	viewProcessManagers(s_pView);
	copProcessBlocks();

#ifdef GAME_DEBUG
	randInit(&g_sRand, 2184, 1911);
#else
	// Seed from beam pos Y & X
	tRayPos sRayPos = getRayPos();
	randInit(&g_sRand, 1 + (sRayPos.bfPosY << 8), 1 + sRayPos.bfPosX);
#endif


	progressBarInit(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront);
	pageNewsCreate(randUwMinMax(&g_sRand, NEWS_KIND_INTRO_1, NEWS_KIND_INTRO_3));

	systemSetInt(INTB_VERTB, &coreVblankHandler, 0);

	inventoryInit();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 5);
	assetsTileOverlayCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 10);
	hiScoreLoad();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 15);
	textBobManagerCreate(g_pFont);
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 20);
	baseCreate(g_pMainBuffer);
	tileVariantManagerCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 25);
	collectiblesCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 30);
	hudCreate(pVpHud, g_pFont);
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 35);
	audioMixerCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 40);
	assetsAudioCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 45);

	tileReset(0, GAME_MODE_CHALLENGE);
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 50);

	bobManagerCreate(
		g_pMainBuffer->pScroll->pFront, g_pMainBuffer->pScroll->pBack,
		s_pPristineBuffer, g_pMainBuffer->pScroll->uwBmAvailHeight
	);
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 55);
	flipbookManagerCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 60);
	baseUnlocksCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 65);
	groundLayerCreate(s_pVpMain);
	protestsCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 70);
	coreBobSequencesCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 75);
	vehicleManagerCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 80);

	assetsMarkersCreate();
	modeMenuManagerCreate();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 85);
	gameInitBobs();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 90);

	menuPreload();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 95);
	bobReallocateBuffers();
	progressBarAdvance(&s_sProgressBarConfig, g_pMainBuffer->pScroll->pFront, 100);

	blitterMutexLock();
	blitRect(
		g_pMainBuffer->pScroll->pFront,
		s_sProgressBarConfig.sBarPos.uwX - 2, s_sProgressBarConfig.sBarPos.uwY - 2,
		s_sProgressBarConfig.uwWidth + 4, s_sProgressBarConfig.uwHeight + 4, 0
	);
	tTextBitMap *pTextBm = fontCreateTextBitMapFromStr(g_pFont, g_pMsgs[MSG_COMM_PRESS_SKIP]);
	fontDrawTextBitMap(
		g_pMainBuffer->pScroll->pFront,
		pTextBm, SCREEN_PAL_WIDTH / 2, s_sProgressBarConfig.sBarPos.uwY,
		COMM_DISPLAY_COLOR_TEXT, FONT_LAZY | FONT_CENTER
	);
	blitterMutexUnlock();
	fontDestroyTextBitMap(pTextBm);
	systemUnuse();

	while(
		!keyUse(KEY_RETURN) && !keyUse(KEY_NUMENTER) && !keyUse(KEY_SPACE) &&
		!keyUse(KEY_LSHIFT) && !keyUse(KEY_RSHIFT) &&
		!joyUse(JOY1_FIRE) && !joyUse(JOY2_FIRE) && !pageNewsIsDone()
	) {
		keyProcess();
		joyProcess();
		vPortWaitForEnd(s_pVpMain);
	}
	systemSetInt(INTB_VERTB, 0, 0);
	commRegisterPage(0, 0);

	// Prepare for game display
	g_pMainBuffer->pCamera->uPos.uwX = 32;
	memset(pVpHud->pPalette, 0, sizeof(pVpHud->pPalette));
	s_pColorBg = &pVpHud->pPalette[0];
	viewUpdateGlobalPalette(s_pView);

	// Initial background
	tileBufferRedrawAll(g_pMainBuffer);

	// Default config
	g_is2pPlaying = 0;

	hudReset(0, 0);
	fadeMorphTo(FADE_STATE_IN, 0);
	statePush(g_pGameStateManager, &g_sStateMenu);
}

static void coreGsLoop(void) {
	// you shouldn't be here!
	statePopAll(g_pGameStateManager);
}

static void coreGsDestroy(void) {
	systemUse();

	menuUnload();
	protestsDestroy();
	bitmapDestroy(s_pTiles);
	collectiblesDestroy();
	baseDestroy();
	tileVariantManagerDestroy();
	textBobManagerDestroy();
	vehicleManagerDestroy();
	commDestroy();
	bobManagerDestroy();

	audioMixerDestroy();
	assetsAudioDestroy();

	assetsMarkersDestroy();
	modeMenuManagerDestroy();
	assetsTileOverlayDestroy();
	flipbookManagerDestroy();
	baseUnlocksDestroy();
	coreBobSequencesDestroy();
	defsDestroyLocale();

  hudDestroy();
  viewDestroy(s_pView);
	bitmapDestroy(s_pPristineBuffer);
}

//---------------------------------------------------------------------- GLOBALS

tTileBufferManager *g_pMainBuffer;
tRandManager g_sRand;

tState g_sStateCore = {
	.cbCreate = coreGsCreate, .cbLoop = coreGsLoop, .cbDestroy = coreGsDestroy
};
