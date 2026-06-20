#ifndef GUARD_OF_VEHICLETYPES_H
#define GUARD_OF_VEHICLETYPES_H

#include "gamestates/game/team.h"
#include <ace/utils/bitmap.h>

#define VEHICLE_TYPE_COUNT 4
#define VEHICLE_TYPE_TANK 0
#define VEHICLE_TYPE_CHOPPER 1
#define VEHICLE_TYPE_ASV 2
#define VEHICLE_TYPE_JEEP 3

#define VEHICLE_BODY_WIDTH 32
#define VEHICLE_BODY_HEIGHT 32
#define VEHICLE_BODY_ANGLE_COUNT 64
#define VEHICLE_TURRET_ANGLE_COUNT 128
#define VEHICLE_TURRET_WIDTH 32
#define VEHICLE_TURRET_HEIGHT 32

/**
 * 0--1--2
 * 3 --> 4
 * 5--6--7
 */
typedef struct _tCollisionPoints {
	tBCoordYX pPts[8]; ///< Collision points
	BYTE bTopmost;
	BYTE bBottommost;
	BYTE bLeftmost;
	BYTE bRightmost;
} tCollisionPts;

typedef struct _tVehicleType {
	UBYTE ubFwdSpeed;     ///< Forward movement speed
	UBYTE ubBwSpeed;      ///< Backward movement speed
	UBYTE ubRotSpeed;     ///< Rotate speed
	UBYTE ubRotSpeedDiv;  ///< Rotate speed divider - do rotation every ubRotSpeedDiv frames
	UBYTE ubMaxBaseAmmo;  ///< Tank cannon, chopper gun, ASV rockets, jeep 'nades
	UBYTE ubMaxSuperAmmo; ///< Chopper rockets, ASV mines
	UBYTE ubMaxFuel;
	UBYTE ubMaxLife;
	tCollisionPts pCollisionPts[VEHICLE_BODY_ANGLE_COUNT];
	// Main bob source
	tBitMap *pMainFrames[TEAM_COUNT];
	tBitMap *pMainMask;
	// Aux bob source
	tBitMap *pAuxFrames[TEAM_COUNT];
	tBitMap *pAuxMask;
} tVehicleType;

void vehicleTypesCreate(void);

void vehicleTypesDestroy(void);

/**
 *  Generates rotated frames for vehicle use.
 *  @param szPath Path to file with source frame.
 *  @return       Pointer to newly created bitmap with rotated frames, otherwise zero.
 */
tBitMap *vehicleTypeGenerateRotatedFrames(const char *szPath);

void vehicleTypeFramesDestroy(tVehicleType *pType);

extern tVehicleType g_pVehicleTypes[VEHICLE_TYPE_COUNT];

#endif // GUARD_OF_VEHICLETYPES_H
