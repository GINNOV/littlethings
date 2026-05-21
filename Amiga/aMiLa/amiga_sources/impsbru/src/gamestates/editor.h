#ifndef GUARD_IMPSBRU_GAMESTATES_EDITOR_H
#define GUARD_IMPSBRU_GAMESTATES_EDITOR_H

#include <ace/types.h>

#define EDITOR_STEP_MAP 0
#define EDITOR_STEP_START_POINT 1
#define EDITOR_STEP_FINISH_POINT 2
#define EDITOR_STEP_PLAY_TEST 3
#define EDITOR_STEP_SHARE 4
#define EDITOR_STEP_COUNT 5

#define EDITOR_SHARE_TEXT 5
#define EDITOR_STEP_ATLAS_SIZE 6

#define EDITOR_STEP_WIDTH WINDOW_SCREEN_WIDTH
#define EDITOR_STEP_HEIGHT 22

void gsEditorCreate();
void gsEditorLoop();
void gsEditorDestroy();

void createEditorStates();
void destroyEditorStates();

void createEditorStepAtlas();
void destroyEditorStepAtlas();

void stepMapCreate();
void stepMapLoop();
void stepMapResume();
void stepStartPointCreate();
void stepStartPointLoop();
void stepStartPointDestory();
void stepStartPointResume();
void stepFinishPointCreate();
void stepFinishPointLoop();
void stepFinishPointDestroy();
void stepFinishPointSuspend();
void stepFinishPointResume();
void stepPlayTestCreate();
void stepPlayTestLoop();
void stepPlayTestDestroy();
void stepPlayTestSuspend();
void stepPlayTestResume();
void stepShareCreate();
void stepShareLoop();
void stepShareDestroy();

void handleMapCursorActions();
void handleMapLoadActions();
void handleMapSaveActions();

void loadCubePositionsFromMap();
void setNewCubeDestination(
	UBYTE ubCrossSide
);
void swapCubePositions();

void makeCubeStepToDestination(
	UWORD *pCubeCoordValue,
	UBYTE ubCubeStep,
	UWORD ubDestinationValue
);

void drawCubeDebugCrossSide(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubCrossSide,
	UBYTE ubCrossSideAdjustRotation
);

UBYTE isCubeMovePossible(
	UBYTE ubCrossSide
);

void moveCube();
UBYTE isCubeAtDestination();
UBYTE isCubeAtMapFinishPoint();
void finishCubeMove();
void moveCubeStep();

void drawCubeDebugCrossSide(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubCrossSide,
	UBYTE ubCrossSideAdjustRotation
);

void redrawCrossDepth(
	UBYTE ubCrossMapX,
	UBYTE ubCrossMapY,
	UBYTE ubCubeMapStartPointCrossSide,
	UBYTE ubCubeCrossSideAdjustRotation
);

void toggleCrossSideState(
	UBYTE ubCrossXIndex,
	UBYTE ubCrossYIndex,
	UBYTE ubCrossSide
);

void toggleNeighborCrossSideState(
	UBYTE ubCrossXIndex,
	UBYTE ubCrossYIndex,
	UBYTE ubCrossSide
);

void cacheCubeDepth();
void cacheCubeDepthMapPoint(
	UBYTE ubMapPointX,
	UBYTE ubMapPointY,
	UBYTE ubCubeDepth
);
void cacheCubeDepthCrossSide(
	UBYTE ubCrossXIndex,
	UBYTE ubCrossYIndex,
	UBYTE ubCrossSide
);

void drawEditorStep();
void drawCursor();
void undrawCursor();

#endif
