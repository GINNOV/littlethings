#include "vehicletypes.h"
#include <ace/managers/blit.h>
#include <ace/utils/chunky.h>
#include <fixmath/fix16.h>
#include "cache.h"
#include "gamestates/game/gamemath.h"
#include "gamestates/precalc/precalc.h"

tVehicleType g_pVehicleTypes[VEHICLE_TYPE_COUNT];

tBitMap *vehicleTypeGenerateRotatedFrames(const char *szPath) {
	logBlockBegin("vehicleTypeGenerateRotatedFrames(szPath: '%s')", szPath);

	char szBitmapFileName[100];
	if(cacheIsValid(szPath)) {
		sprintf(szBitmapFileName, "precalc/%s", szPath);
		tBitMap *pBitmap = bitmapCreateFromFile(szBitmapFileName);
		logBlockEnd("vehicleTypeGenerateRotatedFrames()");
		return pBitmap;
	}

	// Load first frame to determine sizes
	sprintf(szBitmapFileName, "data/%s", szPath);
	tBitMap *pFirstFrame = bitmapCreateFromFile(szBitmapFileName);
	UWORD uwFrameWidth = bitmapGetByteWidth(pFirstFrame) * 8;

	// Create huge-ass bitmap for all frames
	UBYTE ubFlags = 0;
	if(bitmapIsInterleaved(pFirstFrame)) {
		ubFlags = BMF_INTERLEAVED;
	}
	tBitMap *pBitmap = bitmapCreate(
		uwFrameWidth, uwFrameWidth * VEHICLE_BODY_ANGLE_COUNT,
		pFirstFrame->Depth, ubFlags
	);
	if(!pBitmap) {
		logWrite("ERR: Couldn't allocate bitmap\n");
		logBlockEnd("vehicleTypeGenerateRotatedFrames()");
		return 0;
	}

	// Copy first frame to main bitmap
	blitCopyAligned(pFirstFrame, 0, 0, pBitmap, 0, 0, uwFrameWidth, uwFrameWidth);
	bitmapDestroy(pFirstFrame);

	// Convert first frame to chunky
	UBYTE *pChunkySrc = memAllocFast(uwFrameWidth * uwFrameWidth);
	chunkyFromBitmap(pBitmap, pChunkySrc, 0, 0, uwFrameWidth, uwFrameWidth);

	UBYTE *pChunkyRotated = memAllocFast(uwFrameWidth * uwFrameWidth);
	for(FUBYTE fubFrame = 1; fubFrame < VEHICLE_BODY_ANGLE_COUNT; ++fubFrame) {
		// Rotate chunky source and place on huge-ass bitmap
		UBYTE ubAngle = ANGLE_360 - (fubFrame<<1);
		chunkyRotate(
			pChunkySrc, pChunkyRotated,	csin(ubAngle), ccos(ubAngle),
			0, uwFrameWidth, uwFrameWidth
		);
		chunkyToBitmap(
			pChunkyRotated, pBitmap,
			0, uwFrameWidth*fubFrame, uwFrameWidth, uwFrameWidth
		);
	}
	memFree(pChunkySrc, uwFrameWidth * uwFrameWidth);
	memFree(pChunkyRotated, uwFrameWidth * uwFrameWidth);

	// Generate cache
	sprintf(szBitmapFileName, "precalc/%s", szPath);
	bitmapSave(pBitmap, szBitmapFileName);
	cacheGenerateChecksum(szPath);

	logBlockEnd("vehicleTypeGenerateRotatedFrames()");
	return pBitmap;
}

static void vehicleTypeFramesCreate(tVehicleType *pType, char *szVehicleName, UBYTE isAux) {
	char szFilePath[100];

	sprintf(szFilePath, "vehicles/%s/main_blue.bm", szVehicleName);
	pType->pMainFrames[TEAM_BLUE] = vehicleTypeGenerateRotatedFrames(szFilePath);

	sprintf(szFilePath, "vehicles/%s/main_red.bm", szVehicleName);
	pType->pMainFrames[TEAM_RED] = vehicleTypeGenerateRotatedFrames(szFilePath);

	sprintf(szFilePath, "vehicles/%s/main_mask.bm", szVehicleName);
	pType->pMainMask = vehicleTypeGenerateRotatedFrames(szFilePath);
	if(isAux) {
		sprintf(szFilePath, "vehicles/%s/aux_blue.bm", szVehicleName);
		pType->pAuxFrames[TEAM_BLUE] = vehicleTypeGenerateRotatedFrames(szFilePath);

		sprintf(szFilePath, "vehicles/%s/aux_red.bm", szVehicleName);
		pType->pAuxFrames[TEAM_RED] = vehicleTypeGenerateRotatedFrames(szFilePath);

		sprintf(szFilePath, "vehicles/%s/aux_mask.bm", szVehicleName);
		pType->pAuxMask = vehicleTypeGenerateRotatedFrames(szFilePath);
	}
	else {
		pType->pAuxFrames[TEAM_BLUE] = 0;
		pType->pAuxFrames[TEAM_RED] = 0;
		pType->pAuxMask = 0;
	}
}

#define MIN4(a,b,c,d) (MIN((a), MIN((b), MIN((c), (d)))))
#define MAX4(a,b,c,d) (MAX((a), MAX((b), MAX((c), (d)))))

static void vehicleTypeGenerateRotatedCollisions(tCollisionPts *pFrameCollisions) {
	logBlockBegin(
		"vehicleTypeGenerateRotatedCollisions(pFrameCollisions: %p)", pFrameCollisions
	);
	fix16_t fHalf = fix16_one >> 1;
	for(FUBYTE fubFrame = VEHICLE_BODY_ANGLE_COUNT; fubFrame--;) {
		FUBYTE fubAngle = fubFrame << 1;
		tCollisionPts *pNewCollisions = &pFrameCollisions[fubFrame];
		for(FUBYTE fubPoint = 0; fubPoint != 8; ++fubPoint) {
			pNewCollisions->pPts[fubPoint].bX = fix16_to_int(fix16_sub(
				pFrameCollisions[0].pPts[fubPoint].bX * ccos(fubAngle),
				pFrameCollisions[0].pPts[fubPoint].bY * csin(fubAngle)
			) + fHalf);
			pNewCollisions->pPts[fubPoint].bY = fix16_to_int(fix16_add(
				pFrameCollisions[0].pPts[fubPoint].bX * csin(fubAngle),
				pFrameCollisions[0].pPts[fubPoint].bY * ccos(fubAngle)
			) + fHalf);
		}

		pNewCollisions->bLeftmost = MIN4(
			pNewCollisions->pPts[0].bX, pNewCollisions->pPts[2].bX,
			pNewCollisions->pPts[5].bX, pNewCollisions->pPts[7].bX
		);
		pNewCollisions->bRightmost = MAX4(
			pNewCollisions->pPts[0].bX, pNewCollisions->pPts[2].bX,
			pNewCollisions->pPts[5].bX, pNewCollisions->pPts[7].bX
		);
		pNewCollisions->bTopmost = MIN4(
			pNewCollisions->pPts[0].bY, pNewCollisions->pPts[2].bY,
			pNewCollisions->pPts[5].bY, pNewCollisions->pPts[7].bY
		);
		pNewCollisions->bBottommost = MAX4(
			pNewCollisions->pPts[0].bY, pNewCollisions->pPts[2].bY,
			pNewCollisions->pPts[5].bY, pNewCollisions->pPts[7].bY
		);
	}
	logBlockEnd("vehicleTypeGenerateRotatedCollisions()");
}

/**
 *  Generates vehicle type defs.
 *  This fn fills g_pVehicleTypes array
 *  @todo Chopper
 *  @todo ASV
 */
void vehicleTypesCreate(void) {
	tVehicleType *pType;

	logBlockBegin("vehicleTypesCreate");

	// Tank
	pType = &g_pVehicleTypes[VEHICLE_TYPE_TANK];
	pType->ubFwdSpeed = 1;
	pType->ubBwSpeed = 1;
	pType->ubRotSpeed = 2;
	pType->ubRotSpeedDiv = 4;
	pType->ubMaxBaseAmmo = 100;
	pType->ubMaxSuperAmmo = 0;
	pType->ubMaxFuel = 100;
	pType->ubMaxLife = 100;

	precalcIncreaseProgress(15, "Generating tank frames");
	vehicleTypeFramesCreate(pType, "tank", 1);

	// Tank collision coords
	precalcIncreaseProgress(15, "Calculating tank collision coords");
	pType->pCollisionPts[0].pPts[0].bX = 6;  pType->pCollisionPts[0].pPts[0].bY = 8;
	pType->pCollisionPts[0].pPts[1].bX = 17; pType->pCollisionPts[0].pPts[1].bY = 8;
	pType->pCollisionPts[0].pPts[2].bX = 29; pType->pCollisionPts[0].pPts[2].bY = 8;
	pType->pCollisionPts[0].pPts[3].bX = 6;  pType->pCollisionPts[0].pPts[3].bY = 16;
	pType->pCollisionPts[0].pPts[4].bX = 29; pType->pCollisionPts[0].pPts[4].bY = 16;
	pType->pCollisionPts[0].pPts[5].bX = 6;  pType->pCollisionPts[0].pPts[5].bY = 24;
	pType->pCollisionPts[0].pPts[6].bX = 17; pType->pCollisionPts[0].pPts[6].bY = 24;
	pType->pCollisionPts[0].pPts[7].bX = 29; pType->pCollisionPts[0].pPts[7].bY = 24;
	for(FUBYTE i = 0; i != 8; ++i) {
		pType->pCollisionPts[0].pPts[i].bX -= VEHICLE_BODY_WIDTH/2;
		pType->pCollisionPts[0].pPts[i].bY -= VEHICLE_BODY_HEIGHT/2;
	}

	vehicleTypeGenerateRotatedCollisions(pType->pCollisionPts);

	// Jeep
	pType = &g_pVehicleTypes[VEHICLE_TYPE_JEEP];
	pType->ubFwdSpeed = 2;
	pType->ubBwSpeed = 1;
	pType->ubRotSpeed = 2;
	pType->ubRotSpeedDiv = 1;
	pType->ubMaxBaseAmmo = 20;
	pType->ubMaxSuperAmmo = 0;
	pType->ubMaxFuel = 100;
	pType->ubMaxLife = 1;

	precalcIncreaseProgress(15, "Generating jeep frames");
	vehicleTypeFramesCreate(pType, "jeep", 0);

	// Jeep collision coords
	precalcIncreaseProgress(15, "Calculating jeep collision coords");
	pType->pCollisionPts[0].pPts[0].bX = 8;  pType->pCollisionPts[0].pPts[0].bY = 11;
	pType->pCollisionPts[0].pPts[1].bX = 16; pType->pCollisionPts[0].pPts[1].bY = 11;
	pType->pCollisionPts[0].pPts[2].bX = 25; pType->pCollisionPts[0].pPts[2].bY = 11;
	pType->pCollisionPts[0].pPts[3].bX = 8;  pType->pCollisionPts[0].pPts[3].bY = 16;
	pType->pCollisionPts[0].pPts[4].bX = 25; pType->pCollisionPts[0].pPts[4].bY = 16;
	pType->pCollisionPts[0].pPts[5].bX = 8;  pType->pCollisionPts[0].pPts[5].bY = 20;
	pType->pCollisionPts[0].pPts[6].bX = 16; pType->pCollisionPts[0].pPts[6].bY = 20;
	pType->pCollisionPts[0].pPts[7].bX = 25; pType->pCollisionPts[0].pPts[7].bY = 20;
	for(FUBYTE i = 0; i != 8; ++i) {
		pType->pCollisionPts[0].pPts[i].bX -= VEHICLE_BODY_WIDTH/2;
		pType->pCollisionPts[0].pPts[i].bY -= VEHICLE_BODY_HEIGHT/2;
	}
	vehicleTypeGenerateRotatedCollisions(pType->pCollisionPts);

	logBlockEnd("vehicleTypesCreate");
}

static void vehicleTypeUnloadFrameData(tVehicleType *pType) {
	bitmapDestroy(pType->pMainFrames[TEAM_BLUE]);
	bitmapDestroy(pType->pMainFrames[TEAM_RED]);
	bitmapDestroy(pType->pMainMask);
	if(pType->pAuxFrames[TEAM_BLUE])
		bitmapDestroy(pType->pAuxFrames[TEAM_BLUE]);
	if(pType->pAuxFrames[TEAM_RED])
		bitmapDestroy(pType->pAuxFrames[TEAM_RED]);
	if(pType->pAuxMask)
		bitmapDestroy(pType->pAuxMask);
}

void vehicleTypesDestroy(void) {
	logBlockBegin("vehicleTypesDestroy()");

	// Free bob sources
	vehicleTypeUnloadFrameData(&g_pVehicleTypes[VEHICLE_TYPE_TANK]);
	vehicleTypeUnloadFrameData(&g_pVehicleTypes[VEHICLE_TYPE_JEEP]);
	// TODO ASV
	// TODO Chopper

	logBlockEnd("vehicleTypesDestroy()");
}
