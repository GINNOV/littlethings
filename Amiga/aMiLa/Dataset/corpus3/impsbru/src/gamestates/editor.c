#include "gamestates/editor.h"

#include <ace/macros.h>

#include <ace/managers/log.h>
#include <ace/managers/key.h>
#include <ace/managers/state.h>
#include <ace/managers/blit.h>
#include <ace/managers/system.h>

#include <ace/utils/bitmap.h>

#include "game.h"
#include "cross.h"
#include "cube.h"
#include "map.h"
#include "atlas.h"

#include "gamestates/menu.h"

UBYTE s_ubMapCursorX = 0;
UBYTE s_ubMapCursorY = 0;
UBYTE s_pKeysForCrossSide[CROSS_SIDE_COUNT] = {
	KEY_W, // N
	KEY_E, // NE
	KEY_C, // SE
	KEY_X, // S
	KEY_Z, // SW
	KEY_Q // NW
};
UBYTE s_pKeysForMapCursor[CROSS_SIDE_COUNT] = {
	KEY_I, // N
	KEY_O, // NE
	KEY_PERIOD, // SE
	KEY_COMMA, // S
	KEY_M, // SW
	KEY_U // NW
};
tBitMap *s_pEditorStepBitMapAtlas[EDITOR_STEP_ATLAS_SIZE] = {0};
UBYTE s_ubCubeStartPointX = 0;
UBYTE s_ubCubeStartPointY = 0;
UBYTE s_ubCubeStartPointCrossSide = 0;
UBYTE s_ubMapStartPointCrossSideAdjustRotation = 0;
UBYTE s_ubCubeFinishPointX = 0;
UBYTE s_ubCubeFinishPointY = 0;
UBYTE s_ubCubeFinishPointCrossSide = 0;
UBYTE s_ubCubeFinishPointCrossSideAdjustRotation = 0;
UWORD s_uwCubeX = 0;
UWORD s_uwCubeY = 0;
UBYTE s_ubCubeMoveCrossSide = CROSS_SIDE_COUNT;
UWORD s_uwCubeStartPointX = 0;
UWORD s_uwCubeStartPointY = 0;
UWORD s_uwCubeDestinationPointX = 0;
UWORD s_uwCubeDestinationPointY = 0;
UBYTE s_ubEditorStep = EDITOR_STEP_MAP;
tStateManager *s_pEditorStateManager;
tState *s_pEditorGameStates[EDITOR_STEP_COUNT] = {0};

void gsEditorCreate() {
	logBlockBegin("gsEditorCreate()");

	systemUse();

	createCrossAtlas();
	createCubeAtlas();
	createEditorStepAtlas();
	createEditorStates();

	statePush(s_pEditorStateManager, s_pEditorGameStates[EDITOR_STEP_MAP]);

	systemUnuse();

	logBlockEnd("gsEditorCreate()");
}

void gsEditorLoop() {
	stateProcess(s_pEditorStateManager);

	handleMapLoadActions();
}

void gsEditorDestroy() {
	logBlockBegin("gsEditorDestroy()");

	systemUse();

	destroyEditorStates();
	destroyCrossAtlas();
	destroyCubeAtlas();
	destroyEditorStepAtlas();

	systemUnuse();

	logBlockEnd("gsEditorDestroy()");
}

void createEditorStates() {
	logBlockBegin("createEditorStates()");

	s_pEditorStateManager = stateManagerCreate();

	s_pEditorGameStates[EDITOR_STEP_MAP] = stateCreate(stepMapCreate, stepMapLoop, 0, 0, stepMapResume, 0);
	s_pEditorGameStates[EDITOR_STEP_START_POINT] = stateCreate(stepStartPointCreate, stepStartPointLoop, stepStartPointDestory, 0, stepStartPointResume, s_pEditorGameStates[EDITOR_STEP_MAP]);
	s_pEditorGameStates[EDITOR_STEP_FINISH_POINT] = stateCreate(stepFinishPointCreate, stepFinishPointLoop, stepFinishPointDestroy, stepFinishPointSuspend, stepFinishPointResume, s_pEditorGameStates[EDITOR_STEP_START_POINT]);
	s_pEditorGameStates[EDITOR_STEP_PLAY_TEST] = stateCreate(stepPlayTestCreate, stepPlayTestLoop, stepPlayTestDestroy, stepPlayTestSuspend, stepPlayTestResume, s_pEditorGameStates[EDITOR_STEP_FINISH_POINT]);
	s_pEditorGameStates[EDITOR_STEP_SHARE] = stateCreate(stepShareCreate, stepShareLoop, stepShareDestroy, 0, 0, s_pEditorGameStates[EDITOR_STEP_PLAY_TEST]);

	logBlockEnd("createEditorStates()");
}

void destroyEditorStates() {
	logBlockBegin("destroyEditorStates()");

	stateManagerDestroy(s_pEditorStateManager);

	UBYTE ubStateIndex = EDITOR_STEP_COUNT;
	while (ubStateIndex--) {
		stateDestroy(s_pEditorGameStates[ubStateIndex]);
	}

	logBlockEnd("destroyEditorStates()");
}

void createEditorStepAtlas() {
	createAtlasFile(s_pEditorStepBitMapAtlas, EDITOR_STEP_MAP, "data/editor_frames/create.bm");
	createAtlasFile(s_pEditorStepBitMapAtlas, EDITOR_STEP_START_POINT, "data/editor_frames/start_point.bm");
	createAtlasFile(s_pEditorStepBitMapAtlas, EDITOR_STEP_FINISH_POINT, "data/editor_frames/destination_point.bm");
	createAtlasFile(s_pEditorStepBitMapAtlas, EDITOR_STEP_PLAY_TEST, "data/editor_frames/play_test.bm");
	createAtlasFile(s_pEditorStepBitMapAtlas, EDITOR_STEP_SHARE, "data/editor_frames/share.bm");
	createAtlasFile(s_pEditorStepBitMapAtlas, EDITOR_SHARE_TEXT, "data/editor_frames/share_text.bm");
}

void destroyEditorStepAtlas() {
	destroyAtlasFiles(s_pEditorStepBitMapAtlas, EDITOR_STEP_ATLAS_SIZE);
}

void stepMapCreate() {
	logBlockBegin("stepMapCreate()");

	drawEditorStep();
	drawMap();
	drawCursor();

	logBlockEnd("stepMapCreate()");
}

void stepMapLoop() {
	/* Cross sides toggling */
	for (UBYTE ubKeyIndex = 0; ubKeyIndex < CROSS_SIDE_COUNT; ++ubKeyIndex) {
		if (keyUse(s_pKeysForCrossSide[ubKeyIndex])) {
			BYTE ubCursorX = getMapNeighborXRestrictive(s_ubMapCursorX, ubKeyIndex);
			BYTE ubCursorY = getMapNeighborYRestrictive(s_ubMapCursorX, s_ubMapCursorY, ubKeyIndex);

			if ((ubCursorX != MAP_WIDTH) && (ubCursorY != MAP_HEIGHT)) {
				logWrite("Toggling cross side %u at %ux%u\n", ubKeyIndex, s_ubMapCursorX, s_ubMapCursorY);

				toggleCrossSideState(s_ubMapCursorX, s_ubMapCursorY, ubKeyIndex);
				toggleNeighborCrossSideState(s_ubMapCursorX, s_ubMapCursorY, ubKeyIndex);

				drawCursor();
			}
			else {
				logWrite("Cross not toggled - can't toggle cross out of map\n");
			}
		}
	}

	/* Cancel buttons handling */
	if (keyUse(KEY_ESCAPE) || keyUse(KEY_BACKSPACE)) {
		if (isMapEmpty()) {
			statePop(g_pGameStateManager);
			return;
		}
		else {
			logWrite("Clearing map\n");

			memset(g_pMapData, 0, MAP_WIDTH * MAP_HEIGHT);
			undrawMap();
			drawEditorStep();
			drawCursor();
		}
	}

	/* Accept buttons handling */
	if (keyUse(KEY_RETURN) || keyUse(KEY_SPACE)) {
		if (!isMapEmpty()) {
			statePush(s_pEditorStateManager, s_pEditorGameStates[EDITOR_STEP_START_POINT]);
			return;
		}
		else {
			logWrite("Can't go to next state - map is empty\n");
		}
	}

	handleMapCursorActions();
}

void stepMapResume() {
	logBlockBegin("stepMapResume()");
	
	drawEditorStep();
	drawCursor();

	logBlockEnd("stepMapResume()");
}

void stepStartPointCreate() {
	logBlockBegin("stepStartPointCreate()");

	++s_ubEditorStep;
	drawEditorStep();

	logBlockEnd("stepStartPointCreate()");
}

void stepStartPointLoop() {
	/* Cross sides toggling */
	for (UBYTE ubKeyIndex = 0; ubKeyIndex < CROSS_SIDE_COUNT; ++ubKeyIndex) {
		if (keyUse(s_pKeysForCrossSide[ubKeyIndex])) {
			UBYTE ubCrossData = g_pMapData[s_ubMapCursorX][s_ubMapCursorY];
			if (ubCrossData && !getCrossSideState(ubCrossData, ubKeyIndex)) {
				if ((g_ubMapStartPointX != s_ubMapCursorX) || (g_ubMapStartPointY != s_ubMapCursorY) || (g_ubMapStartPointCrossSide != ubKeyIndex)) {
					logWrite("Setting starting point %u at %ux%u\n", ubKeyIndex, s_ubMapCursorX, s_ubMapCursorY);

					undrawMapStartPoint();

					g_ubMapStartPointX = s_ubMapCursorX;
					g_ubMapStartPointY = s_ubMapCursorY;
					g_ubMapStartPointCrossSide = ubKeyIndex;

					drawMapStartPoint();
					drawCursor();
				}
				else {
					logWrite("Starting point not set - %u already at %ux%u\n", ubKeyIndex, s_ubMapCursorX, s_ubMapCursorY);
				}
			}
			else {
				logWrite("Starting point not set - can't be there\n");
			}
		}
	}

	/* Cancel buttons handling */
	if (keyUse(KEY_ESCAPE) || keyUse(KEY_BACKSPACE)) {
		statePop(s_pEditorStateManager);
		return;
	}

	/* Accept buttons handling */
	if (keyUse(KEY_RETURN) || keyUse(KEY_SPACE)) {
		if ((g_ubMapStartPointX != MAP_WIDTH) && (g_ubMapStartPointY != MAP_HEIGHT)) {
			statePush(s_pEditorStateManager, s_pEditorGameStates[EDITOR_STEP_FINISH_POINT]);
			return;
		}
	}

	handleMapCursorActions();
}

void stepStartPointDestory() {
	logBlockBegin("stepStartPointDestory()");

	--s_ubEditorStep;

	undrawMapStartPoint();

	g_ubMapStartPointX = MAP_WIDTH;
	g_ubMapStartPointY = MAP_HEIGHT;
	g_ubMapStartPointCrossSide = 0;

	logBlockEnd("stepStartPointDestory()");
}

void stepStartPointResume() {
	logBlockBegin("stepStartPointResume()");

	drawEditorStep();

	drawMapStartPoint();

	s_ubMapCursorX = g_ubMapStartPointX;
	s_ubMapCursorY = g_ubMapStartPointY;

	drawCursor();

	logBlockEnd("stepStartPointResume()");
}

void stepFinishPointCreate() {
	logBlockBegin("stepFinishPointCreate()");
	
	++s_ubEditorStep;

	drawEditorStep();

	logBlockEnd("stepFinishPointCreate()");
}

void stepFinishPointLoop() {
	/* Cross sides toggling */
	for (UBYTE ubKeyIndex = 0; ubKeyIndex < CROSS_SIDE_COUNT; ++ubKeyIndex) {
		if (keyUse(s_pKeysForCrossSide[ubKeyIndex])) {
			UBYTE ubCrossData = g_pMapData[s_ubMapCursorX][s_ubMapCursorY];
			if (ubCrossData && !(ubKeyIndex & 1) && !getCrossSideState(ubCrossData, ubKeyIndex) && !((s_ubMapCursorX == g_ubMapStartPointX) && (s_ubMapCursorY == g_ubMapStartPointY) && (g_ubMapStartPointCrossSide == ubKeyIndex))) {
				if ((g_ubMapFinishPointX != s_ubMapCursorX) || (g_ubMapFinishPointY != s_ubMapCursorY) || (g_ubMapFinishPointCrossSide != ubKeyIndex)) {
					logWrite("Setting finish point %u at %ux%u\n", ubKeyIndex, s_ubMapCursorX, s_ubMapCursorY);

					undrawMapFinishPoint();

					if ((g_ubMapFinishPointX == g_ubMapStartPointX) && (g_ubMapFinishPointY == g_ubMapStartPointY)) {
						drawMapStartPoint();
					}

					g_ubMapFinishPointX = s_ubMapCursorX;
					g_ubMapFinishPointY = s_ubMapCursorY;
					g_ubMapFinishPointCrossSide = ubKeyIndex;

					drawMapFinishPoint();
					drawCursor();
				}
				else {
					logWrite("Finish point not set - %u already at %ux%u\n", ubKeyIndex, s_ubMapCursorX, s_ubMapCursorY);
				}
			}
			else {
				logWrite("Finish point not set - can't be there\n");
			}
		}
	}

	/* Cancel buttons handling */
	if (keyUse(KEY_ESCAPE) || keyUse(KEY_BACKSPACE)) {
		statePop(s_pEditorStateManager);
	}

	/* Accept buttons handling */
	if (keyUse(KEY_RETURN) || keyUse(KEY_SPACE)) {
		if ((g_ubMapFinishPointX != MAP_WIDTH) && (g_ubMapFinishPointY != MAP_HEIGHT)) {
			statePush(s_pEditorStateManager, s_pEditorGameStates[EDITOR_STEP_PLAY_TEST]);
		}
	}

	handleMapCursorActions();
}

void stepFinishPointDestroy() {
	logBlockBegin("stepFinishPointDestroy()");

	--s_ubEditorStep;

	undrawCursor();
	undrawMapFinishPoint();

	g_ubMapFinishPointX = MAP_WIDTH;
	g_ubMapFinishPointY = MAP_HEIGHT;
	g_ubMapFinishPointCrossSide = 0;

	logBlockEnd("stepFinishPointDestroy()");
}

void stepFinishPointSuspend() {
	logBlockBegin("stepFinishPointSuspend()");

	undrawCursor();

	logBlockEnd("stepFinishPointSuspend()");
}

void stepFinishPointResume() {
	logBlockBegin("stepFinishPointResume()");

	drawEditorStep();

	s_ubMapCursorX = g_ubMapFinishPointX;
	s_ubMapCursorY = g_ubMapFinishPointY;

	drawMapStartPoint();
	drawMapFinishPoint();
	drawCursor();

	logBlockEnd("stepFinishPointResume()");
}

void stepPlayTestCreate() {
	logBlockBegin("stepPlayTestCreate()");

	++s_ubEditorStep;

	loadCubePositionsFromMap();

	drawEditorStep();

	logBlockEnd("stepPlayTestCreate()");
}

void stepPlayTestLoop() {
	for (UBYTE ubKeyIndex = 0; ubKeyIndex < CROSS_SIDE_COUNT; ++ubKeyIndex) {
		if (keyUse(s_pKeysForCrossSide[ubKeyIndex]) || keyUse(s_pKeysForMapCursor[ubKeyIndex])) {
			if (s_ubCubeMoveCrossSide == CROSS_SIDE_COUNT) {
			 	if (isCubeMovePossible(ubKeyIndex)) {
					logWrite("Setting cube destination: %u\n", ubKeyIndex);

					setNewCubeDestination(ubKeyIndex);

					s_ubCubeMoveCrossSide = ubKeyIndex;
			 	}
				else {
					logWrite("Cube destination not set - cube can't move there\n");
				}
			}
			else if (getOppositeCrossSide(s_ubCubeMoveCrossSide) == ubKeyIndex) {
				logWrite("Swapping cube destination: %u\n", ubKeyIndex);
				
				s_ubCubeMoveCrossSide = ubKeyIndex;

				swapCubePositions();
			}
		}
	}

	/* Cancel buttons handling */
	if (keyUse(KEY_ESCAPE) || keyUse(KEY_BACKSPACE)) {
		statePop(s_pEditorStateManager);
		return;
	}

	moveCube();

	if (isCubeAtMapFinishPoint()) {
		statePush(s_pEditorStateManager, s_pEditorGameStates[EDITOR_STEP_SHARE]);
		return;
	}
}

void stepPlayTestDestroy() {
	logBlockBegin("stepPlayTestDestroy()");

	--s_ubEditorStep;

	undrawCube(s_uwCubeX, s_uwCubeY);

	logBlockEnd("stepPlayTestDestroy()");
}

void stepPlayTestSuspend() {
	logBlockBegin("stepPlayTestSuspend()");

	clearBuffer();

	logBlockEnd("stepPlayTestSuspend()");
}

void stepPlayTestResume() {
	logBlockBegin("stepPlayTestResume()");

	loadCubePositionsFromMap();
	drawMap();

	drawEditorStep();

	logBlockEnd("stepPlayTestResume()");
}

void stepShareCreate() {
	logBlockBegin("stepShareCreate()");

	++s_ubEditorStep;

	blitCopyAligned(
		s_pEditorStepBitMapAtlas[EDITOR_SHARE_TEXT], 0, 0,
		g_pBufferManager->pBack, 0, 115,
		EDITOR_STEP_WIDTH, 32
	);

	drawEditorStep();

	logBlockEnd("stepShareCreate()");
}

void stepShareLoop() {
	/* Cancel buttons handling */
	if (keyUse(KEY_ESCAPE) || keyUse(KEY_BACKSPACE)) {
		statePop(s_pEditorStateManager);
		return;
	}

	handleMapSaveActions();
}

void stepShareDestroy() {
	logBlockBegin("stepShareCreate()");

	--s_ubEditorStep;

	clearBuffer();

	logBlockEnd("stepShareCreate()");
}

void handleMapCursorActions() {
	for (UBYTE ubKeyIndex = 0; ubKeyIndex < CROSS_SIDE_COUNT; ++ubKeyIndex) {
		if (keyUse(s_pKeysForMapCursor[ubKeyIndex])) {
			UBYTE ubCursorX = getMapNeighborX(s_ubMapCursorX, ubKeyIndex);
			UBYTE ubCursorY = getMapNeighborY(s_ubMapCursorX, s_ubMapCursorY, ubKeyIndex);

			if ((ubCursorX != MAP_WIDTH) && (ubCursorY != MAP_HEIGHT)) {
				if ((s_ubMapCursorX != ubCursorX) || s_ubMapCursorY != ubCursorY) {
					logWrite("Moving cursor at %ux%u\n", ubCursorX, ubCursorY);

					undrawCursor();

					s_ubMapCursorX = ubCursorX;
					s_ubMapCursorY = ubCursorY;

					drawCursor();
				}
				else {
					logWrite("Cursor not moved - already at %ux%u\n", ubCursorX, ubCursorY);
				}
			}
			else {
				logWrite("Cursor not moved - can't move out of map\n");
			}
		}
	}
}

void handleMapLoadActions() {
	for (UBYTE ubKey = KEY_1; ubKey <= KEY_0; ++ubKey) {
		if (keyUse(ubKey)) {
			char szMapFilePath[255];
			sprintf(szMapFilePath, "data/maps/%u.map", ubKey);

			if (loadMapFromFile(szMapFilePath)) {
				loadCubePositionsFromMap();

				undrawMap();
				drawMap();

				s_ubEditorStep = EDITOR_STEP_PLAY_TEST;
				s_pEditorStateManager->pCurrent = s_pEditorGameStates[EDITOR_STEP_PLAY_TEST];
				drawEditorStep();

				return;
			}
		}
	}
}

void handleMapSaveActions() {
	for (UBYTE ubKey = KEY_1; ubKey <= KEY_0; ++ubKey) {
		if ((keyCheck(KEY_LSHIFT) || keyCheck(KEY_RSHIFT)) && keyCheck(ubKey)) {
			char szMapFilePath[255];
			sprintf(szMapFilePath, "data/maps/%u.map", ubKey);

			saveMapToFile(szMapFilePath);
		}
	}
}

void loadCubePositionsFromMap() {
	s_ubCubeStartPointX = g_ubMapStartPointX;
	s_ubCubeStartPointY = g_ubMapStartPointY;
	s_ubCubeStartPointCrossSide = g_ubMapStartPointCrossSide;
	s_ubMapStartPointCrossSideAdjustRotation = g_ubMapStartPointCrossSide;

	s_uwCubeX = getMapCrossX(s_ubCubeStartPointX) + g_pCubeCrossSideAdjust[s_ubCubeStartPointCrossSide][s_ubCubeStartPointCrossSide][0];
	s_uwCubeY = getMapCrossY(s_ubCubeStartPointX, s_ubCubeStartPointY) + g_pCubeCrossSideAdjust[s_ubCubeStartPointCrossSide][s_ubCubeStartPointCrossSide][1];

	s_uwCubeStartPointX = s_uwCubeX;
	s_uwCubeStartPointY = s_uwCubeY;

	s_ubCubeMoveCrossSide = CROSS_SIDE_COUNT;

	s_ubCubeFinishPointX = 0;
	s_ubCubeFinishPointX = 0;
	s_ubCubeFinishPointCrossSide = 0;
	s_ubCubeFinishPointCrossSideAdjustRotation = 0;

	s_uwCubeDestinationPointX = 0;
	s_uwCubeDestinationPointY = 0;
}

void setNewCubeDestination(UBYTE ubCrossSide) {
	s_ubCubeFinishPointX = getMapNeighborX(s_ubCubeStartPointX, ubCrossSide);
	s_ubCubeFinishPointY = getMapNeighborY(s_ubCubeStartPointX, s_ubCubeStartPointY, ubCrossSide);

	if (s_ubMapStartPointCrossSideAdjustRotation == ubCrossSide) {
		UBYTE ubCrossCrossSideAdjustRotation = s_ubMapStartPointCrossSideAdjustRotation;
		s_ubMapStartPointCrossSideAdjustRotation = s_ubCubeStartPointCrossSide;
		s_ubCubeStartPointCrossSide = ubCrossCrossSideAdjustRotation;
	}

	if (getCrossSideState(g_pMapData[s_ubCubeFinishPointX][s_ubCubeFinishPointY], s_ubMapStartPointCrossSideAdjustRotation)) { /* Cube will be next to the cross side */
		s_ubCubeFinishPointCrossSide = getOppositeCrossSide(ubCrossSide);
	}
	else { /* Cube will be directly in cross side */
		s_ubCubeFinishPointCrossSide = s_ubMapStartPointCrossSideAdjustRotation;
	}

	s_ubCubeFinishPointCrossSideAdjustRotation = s_ubMapStartPointCrossSideAdjustRotation;

	s_uwCubeDestinationPointX = getMapCrossX(s_ubCubeFinishPointX) + g_pCubeCrossSideAdjust[s_ubCubeFinishPointCrossSide][s_ubCubeFinishPointCrossSideAdjustRotation][0];
	s_uwCubeDestinationPointY = getMapCrossY(s_ubCubeFinishPointX, s_ubCubeFinishPointY) + g_pCubeCrossSideAdjust[s_ubCubeFinishPointCrossSide][s_ubCubeFinishPointCrossSideAdjustRotation][1];

	s_ubCubeMoveCrossSide = ubCrossSide;

	cacheCubeDepth();
//
//	drawCubeDebugCrossSide(
//		0,
//		WINDOW_SCREEN_HEIGHT - CROSS_HEIGHT,
//		s_ubCubeMapStartPointCrossSide,
//		s_ubCubeMapStartPointCrossSideAdjustRotation
//	);
//
//	drawCubeDebugCrossSide(
//		WINDOW_SCREEN_WIDTH - CROSS_WIDTH,
//		WINDOW_SCREEN_HEIGHT - CROSS_HEIGHT,
//		s_ubCubeMapDestinationPointCrossSide,
//		s_ubCubeMapDestinationPointCrossSideAdjustRotation
//	);
}

void drawCubeDebugCrossSide(UWORD uwX, UWORD uwY, UBYTE ubCrossSide, UBYTE ubCrossSideAdjustRotation) {
	undrawCross(uwX, uwY);
	drawCrossAtlasIndex(uwX, uwY, CROSS_CENTER);

	drawCubeAtlasIndex(
		uwX + g_pCubeCrossSideAdjust[ubCrossSide][ubCrossSideAdjustRotation][0],
		uwY + g_pCubeCrossSideAdjust[ubCrossSide][ubCrossSideAdjustRotation][1],
		0
	);

	if (ubCrossSide & 1) {
		drawCrossAtlasIndex(uwX, uwY, CROSS_CENTER);
	}
}

void swapCubePositions() {
	UBYTE ubCubeMapStartPointX = s_ubCubeStartPointX;
	UBYTE ubCubeMapStartPointY = s_ubCubeStartPointY;
	UBYTE ubCubeMapStartPointCrossSide = s_ubCubeStartPointCrossSide;
	UBYTE ubCubeMapStartPointCrossSideAdjustRotation = s_ubMapStartPointCrossSideAdjustRotation;

	s_ubCubeStartPointX = s_ubCubeFinishPointX;
	s_ubCubeStartPointY = s_ubCubeFinishPointY;
	s_ubCubeStartPointCrossSide = s_ubCubeFinishPointCrossSide;
	s_ubMapStartPointCrossSideAdjustRotation = s_ubCubeFinishPointCrossSideAdjustRotation;

	s_ubCubeFinishPointX = ubCubeMapStartPointX;
	s_ubCubeFinishPointY = ubCubeMapStartPointY;
	s_ubCubeFinishPointCrossSide = ubCubeMapStartPointCrossSide;
	s_ubCubeFinishPointCrossSideAdjustRotation = ubCubeMapStartPointCrossSideAdjustRotation;

	UWORD uwCubeStartPointX = s_uwCubeStartPointX;
	UWORD uwCubeStartPointY = s_uwCubeStartPointY;

	s_uwCubeStartPointX = s_uwCubeDestinationPointX;
	s_uwCubeStartPointY = s_uwCubeDestinationPointY;

	s_uwCubeDestinationPointX = uwCubeStartPointX;
	s_uwCubeDestinationPointY = uwCubeStartPointY;
}

UBYTE isCubeMovePossible(UBYTE ubCrossSide) {
	if (s_ubCubeStartPointCrossSide == s_ubMapStartPointCrossSideAdjustRotation) { /* Cube is directly in cross side */
		return getCrossSideState(g_pMapData[s_ubCubeStartPointX][s_ubCubeStartPointY], ubCrossSide) && (getOppositeCrossSide(ubCrossSide) != s_ubCubeStartPointCrossSide);
	}
	else { /* Cube is next to the cross side */
		return (ubCrossSide == s_ubCubeStartPointCrossSide) || (ubCrossSide == s_ubMapStartPointCrossSideAdjustRotation);
	}
}

void moveCube() {
	if (s_ubCubeMoveCrossSide == CROSS_SIDE_COUNT) {
		return;
	}

	if (isCubeAtDestination()) {
		finishCubeMove();
	}
	else {
		moveCubeStep();
	}
}

UBYTE isCubeAtDestination() {
	return (s_uwCubeX == s_uwCubeDestinationPointX) && (s_uwCubeY == s_uwCubeDestinationPointY);
}

UBYTE isCubeAtMapFinishPoint() {
	return (s_ubCubeStartPointX == g_ubMapFinishPointX)
		&& (s_ubCubeStartPointY == g_ubMapFinishPointY)
		&& (s_ubCubeStartPointCrossSide == g_ubMapFinishPointCrossSide)
		&& (s_ubCubeMoveCrossSide == CROSS_SIDE_COUNT);
}

void finishCubeMove() {
	logWrite("Cube move finished\n");

	s_ubCubeStartPointX = s_ubCubeFinishPointX;
	s_ubCubeStartPointY = s_ubCubeFinishPointY;
	s_ubCubeStartPointCrossSide = s_ubCubeFinishPointCrossSide;
	s_ubMapStartPointCrossSideAdjustRotation = s_ubCubeFinishPointCrossSideAdjustRotation;

	s_uwCubeStartPointX = s_uwCubeDestinationPointX;
	s_uwCubeStartPointY = s_uwCubeDestinationPointY;

	UBYTE ubNoOtherDirections = 1;
	for (UBYTE ubCrossSide = 0; ubCrossSide < CROSS_SIDE_COUNT; ++ubCrossSide) {
		if (isCubeMovePossible(ubCrossSide) && (ubCrossSide != s_ubCubeMoveCrossSide) && (ubCrossSide != getOppositeCrossSide(s_ubCubeMoveCrossSide))) {
			ubNoOtherDirections = 0;
			break;
		}
	}

	if (ubNoOtherDirections && getCrossSideState(g_pMapData[s_ubCubeStartPointX][s_ubCubeStartPointY], s_ubCubeMoveCrossSide) && (s_ubCubeStartPointCrossSide == s_ubMapStartPointCrossSideAdjustRotation)) {
		setNewCubeDestination(s_ubCubeMoveCrossSide);
	}
	else {
		s_ubCubeMoveCrossSide = CROSS_SIDE_COUNT;
	}
}

void moveCubeStep() {
	undrawCube(s_uwCubeX, s_uwCubeY);

	makeCubeStepToDestination(&s_uwCubeX, CUBE_STEP_X, s_uwCubeDestinationPointX);
	makeCubeStepToDestination(&s_uwCubeY, s_uwCubeX == s_uwCubeDestinationPointX ? CUBE_STEP_Y_FAST : CUBE_STEP_Y_SLOW, s_uwCubeDestinationPointY);

	drawCube(s_uwCubeX, s_uwCubeY);
	// redrawCrossDepth(
	// 	s_ubCubeMapStartPointX,
	// 	s_ubCubeMapStartPointY,
	// 	s_ubCubeMapStartPointCrossSide,
	// 	s_ubCubeMapStartPointCrossSideAdjustRotation
	// );

	// redrawCrossDepth(
	// 	s_ubCubeMapDestinationPointX,
	// 	s_ubCubeMapDestinationPointY,
	// 	s_ubCubeMapDestinationPointCrossSide,
	// 	s_ubCubeMapDestinationPointCrossSideAdjustRotation
	// );
}

void redrawCrossDepth(UBYTE ubCrossMapX, UBYTE ubCrossMapY, UBYTE ubCubeMapStartPointCrossSide, UBYTE ubCubeCrossSideAdjustRotation) {
	UBYTE ubCubeDepth = getCubeDepth(ubCubeMapStartPointCrossSide, ubCubeCrossSideAdjustRotation);

	UWORD uwCubeStartPointX = getMapCrossX(ubCrossMapX);
	UWORD uwCubeStartPointY = getMapCrossY(ubCrossMapX, ubCrossMapY);
	UBYTE ubCrossData = g_pMapData[ubCrossMapX][ubCrossMapY];

	if (ubCubeDepth <= CUBE_DEPTH_BOTTOM) {
		drawCrossCenter(uwCubeStartPointX, uwCubeStartPointY, ubCrossData);
		drawCrossDepthMiddle(uwCubeStartPointX, uwCubeStartPointY, ubCrossData);
	}

	if (ubCubeDepth <= CUBE_DEPTH_MIDDLE) {
		drawCrossDepthTop(uwCubeStartPointX, uwCubeStartPointY, ubCrossData);
	}

	if ((ubCrossMapX == g_ubMapFinishPointX) && (ubCrossMapY == g_ubMapFinishPointY)) {
		drawMapFinishPoint();
	}
}

void makeCubeStepToDestination(UWORD *pCubeCoordValue, UBYTE ubCubeStep, UWORD ubDestinationValue) {
	if (*pCubeCoordValue < ubDestinationValue) {
		*pCubeCoordValue += ubCubeStep;

		if (ubDestinationValue < *pCubeCoordValue) {
			*pCubeCoordValue = ubDestinationValue;
		}
	}
	else if (ubDestinationValue < *pCubeCoordValue) {
		*pCubeCoordValue -= ubCubeStep;

		if (*pCubeCoordValue < ubDestinationValue) {
			*pCubeCoordValue = ubDestinationValue;
		}
	}
}

void toggleCrossSideState(UBYTE ubCrossXIndex, UBYTE ubCrossYIndex, UBYTE ubCrossSide) {
	g_pMapData[ubCrossXIndex][ubCrossYIndex] ^= 1 << ubCrossSide;

	UWORD uwX = getMapCrossX(s_ubMapCursorX);
	UWORD uwY = getMapCrossY(s_ubMapCursorX, s_ubMapCursorY);

	undrawCross(uwX, uwY);
	drawCross(uwX, uwY, g_pMapData[s_ubMapCursorX][s_ubMapCursorY]);
}

void toggleNeighborCrossSideState(UBYTE ubCrossXIndex, UBYTE ubCrossYIndex, UBYTE ubCrossSide) {
	UBYTE ubMapNeighborX = getMapNeighborX(ubCrossXIndex, ubCrossSide);
	UBYTE ubMapNeighborY = getMapNeighborY(ubCrossXIndex, ubCrossYIndex, ubCrossSide);

	UBYTE ubOppositeCrossSide = getOppositeCrossSide(ubCrossSide);

	g_pMapData[ubMapNeighborX][ubMapNeighborY] &= ~(1 << ubOppositeCrossSide);
	if (getCrossSideState(g_pMapData[ubCrossXIndex][ubCrossYIndex], ubCrossSide)) {
		g_pMapData[ubMapNeighborX][ubMapNeighborY] |= (1 << ubOppositeCrossSide);
	}

	UWORD uwX = getMapCrossX(ubMapNeighborX);
	UWORD uwY = getMapCrossY(ubMapNeighborX, ubMapNeighborY);

	undrawCross(uwX, uwY);
	drawCross(uwX, uwY, g_pMapData[ubMapNeighborX][ubMapNeighborY]);
}

void cacheCubeDepth() {
	blitRect(
		g_pCubeMapDepthMask, 0, 0,
		WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT, 0
	);

	cacheCubeDepthMapPoint(s_ubCubeStartPointX, s_ubCubeStartPointY, getCubeDepth(s_ubCubeStartPointCrossSide, s_ubMapStartPointCrossSideAdjustRotation));
	cacheCubeDepthMapPoint(s_ubCubeFinishPointX, s_ubCubeFinishPointY, getCubeDepth(s_ubCubeFinishPointCrossSide, s_ubCubeFinishPointCrossSideAdjustRotation));

//	tBitmap sBottomDepthMask;
//	sBottomDepthMask.pData = (const UWORD *) g_pCubeMapDepthMask->Planes[0];
//	sBottomDepthMask.uwWidth = WINDOW_SCREEN_WIDTH;
//	sBottomDepthMask.uwHeight = WINDOW_SCREEN_HEIGHT;
//	bitmapMaskSaveBmp(&sBottomDepthMask, "map_mask.bmp");
}

void cacheCubeDepthMapPoint(UBYTE ubMapPointX, UBYTE ubMapPointY, UBYTE ubCubeDepth) {
	if (ubCubeDepth == CUBE_DEPTH_BOTTOM) {
		for (UBYTE ubCrossSide = 0; ubCrossSide < CROSS_SIDE_COUNT; ++ubCrossSide) {
			if (getCrossSideState(g_pMapData[ubMapPointX][ubMapPointY], ubCrossSide)) {
				cacheCubeDepthCrossSide(ubMapPointX, ubMapPointY, ubCrossSide);
			}
		}
	}

	if (ubCubeDepth == CUBE_DEPTH_MIDDLE) {
		for (UBYTE ubCrossSide = 0; ubCrossSide < CROSS_SIDE_COUNT; ubCrossSide += 2) {
			if (getCrossSideState(g_pMapData[ubMapPointX][ubMapPointY], ubCrossSide)) {
				cacheCubeDepthCrossSide(ubMapPointX, ubMapPointY, ubCrossSide);
			}
		}
	}
}

void cacheCubeDepthCrossSide(UBYTE ubCrossXIndex, UBYTE ubCrossYIndex, UBYTE ubCrossSide) {
	UWORD uwX, uwY;
	tBitMap sCrossSideMaskBitmap;
	InitBitMap(&sCrossSideMaskBitmap, 1, CROSS_WIDTH, CROSS_HEIGHT);

	uwX = getMapCrossX(ubCrossXIndex);
	uwY = getMapCrossY(ubCrossXIndex, ubCrossYIndex);

	sCrossSideMaskBitmap.Planes[0] = (PLANEPTR) g_pCrossBitMapMaskAtlas[CROSS_CENTER]->Planes[0];
	blitCopyMask(
		&sCrossSideMaskBitmap, 0, 0,
		g_pCubeMapDepthMask, uwX, uwY,
		CROSS_WIDTH, CROSS_HEIGHT,
		(const UWORD *) g_pCrossBitMapMaskAtlas[CROSS_CENTER]->Planes[0]
	);

	sCrossSideMaskBitmap.Planes[0] = (PLANEPTR) g_pCrossBitMapMaskAtlas[ubCrossSide]->Planes[0];
	blitCopyMask(
		&sCrossSideMaskBitmap, 0, 0,
		g_pCubeMapDepthMask, uwX, uwY,
		CROSS_WIDTH, CROSS_HEIGHT,
		(const UWORD *) g_pCrossBitMapMaskAtlas[ubCrossSide]->Planes[0]
	);
}

void drawEditorStep() {
	blitCopyAligned(
		s_pEditorStepBitMapAtlas[s_ubEditorStep], 0, 0,
		g_pBufferManager->pBack, 0, 0,
		EDITOR_STEP_WIDTH, EDITOR_STEP_HEIGHT
	);
}

void drawCursor() {
	UWORD uwX = getMapCrossX(s_ubMapCursorX);
	UWORD uwY = getMapCrossY(s_ubMapCursorX, s_ubMapCursorY);
	UBYTE ubWidth = CROSS_WIDTH;
	UBYTE ubHeight = CROSS_HEIGHT;
	UBYTE ubStartX = 0;
	UBYTE ubStartY = 0;

	/* Cut off horizontal sides of cursor at map edges */
	if (!s_ubMapCursorX) {
		uwX += CROSS_CURSOR_LEFT;
		ubWidth -= CROSS_CURSOR_LEFT;
		ubStartX = CROSS_CURSOR_LEFT;
	}
	else if (s_ubMapCursorX == (MAP_WIDTH - 1)) {
		ubWidth -= CROSS_CURSOR_RIGHT;
	}

	/* Cut off vertical sides of cursor at map edges */
	if (!s_ubMapCursorY) {
		uwY += CROSS_CURSOR_TOP;
		ubHeight -= CROSS_CURSOR_TOP;
		ubStartY = CROSS_CURSOR_TOP;
	}
	else if (s_ubMapCursorY == (MAP_HEIGHT - 1)) {
		ubHeight -= CROSS_CURSOR_BOTTOM;
	}

	blitCopyMask(
		g_pCrossBitMapAtlas[CROSS_CURSOR], ubStartX, ubStartY,
		g_pBufferManager->pBack, uwX, uwY,
		ubWidth, ubHeight,
		(const UWORD *) g_pCrossBitMapMaskAtlas[CROSS_CURSOR]->Planes[0]
	);
}

void undrawCursor() {
	blitCopyMask(
		g_pCrossBitMapAtlas[CROSS_CLEANUP], 0, 0,
		g_pBufferManager->pBack, getMapCrossX(s_ubMapCursorX), getMapCrossY(s_ubMapCursorX, s_ubMapCursorY),
		CROSS_WIDTH, CROSS_HEIGHT,
		(const UWORD *) g_pCrossBitMapMaskAtlas[CROSS_CURSOR]->Planes[0]
	);
}
