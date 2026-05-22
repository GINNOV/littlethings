#ifndef _TNT_H_
#define _TNT_H_

#include <ace/types.h>
#include "direction.h"

#define VEHICLE_DYNAMITE_MAX 3

typedef struct tTnt {
	tUwCoordYX sStartPos; // Player pos rounded to a tile
	tUwCoordYX pCoords[VEHICLE_DYNAMITE_MAX];
	UBYTE ubCoordCount;
	UBYTE ubCurrent;
	UBYTE ubPlayer;
	UBYTE ubChargeCost;
	tDirection eDir;
} tTnt;

void tntReset(tTnt *pTnt, UBYTE ubPlayer, tUwCoordYX sStartPos);

void tntAdd(tTnt *pTnt, tDirection eDir);

void tntDetonate(tTnt *pDynamite);

UBYTE tntIsDetonationActive(const tTnt *pDynamite);

#endif // _TNT_H_
