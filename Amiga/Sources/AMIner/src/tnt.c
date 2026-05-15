#include "tnt.h"
#include "flipbook.h"
#include "tile.h"
#include "vehicle.h"
#include "inventory.h"
#include "game.h"
#include "ground_layer.h"
#include <ace/managers/log.h>

#define DETONATION_CURRENT_INVALID 0xFF

static void onExplosionPeak(void *pData) {
	tTnt *pTnt = pData;
	UWORD uwX = pTnt->pCoords[pTnt->ubCurrent].uwX;
	UWORD uwY = pTnt->pCoords[pTnt->ubCurrent].uwY;
	// TODO Hurt player if is on explosion tile?

	// Excavate tile under explosion
	if(tileIsDrillable(uwX, uwY)) {
		if(inventoryGetPartDef(INVENTORY_PART_TNT)->ubLevel >= 4) {
			vehicleExcavateTile(&g_pVehicles[pTnt->ubPlayer], uwX, uwY);
		}
		else {
			tileExcavate(uwX, uwY);
		}

		UBYTE ubDifficulty;
		if(tileIsHardToDrill(uwX, uwY)) {
			ubDifficulty = 10;
		}
		else {
			ubDifficulty = groundLayerGetDifficultyAtDepth(uwY << TILE_SHIFT);
		}
		UBYTE ubExcavateTime = g_ubDrillingCost * ubDifficulty;
		gameElapseTime(ubExcavateTime);
	}

	// Trigger next explosion
	if(++pTnt->ubCurrent < pTnt->ubCoordCount) {
		flipbookAdd(
			pTnt->pCoords[pTnt->ubCurrent].uwX << 5,
			pTnt->pCoords[pTnt->ubCurrent].uwY << 5,
			onExplosionPeak, 0, pData, FLIPBOOK_KIND_BOOM
		);
	}
}

//------------------------------------------------------------------- PUBLIC FNS

void tntReset(tTnt *pTnt, UBYTE ubPlayer, tUwCoordYX sStartPos) {
	pTnt->sStartPos.ulYX = sStartPos.ulYX;
	pTnt->ubChargeCost = 0;
	pTnt->ubCoordCount = 0;
	pTnt->ubCurrent = DETONATION_CURRENT_INVALID;
	pTnt->ubPlayer = ubPlayer;
	pTnt->eDir = DIRECTION_COUNT;
}

void tntDetonate(tTnt *pTnt) {
	if(tntIsDetonationActive(pTnt) || pTnt->ubCoordCount == 0) {
		return;
	}

	pTnt->ubCurrent = 0;
	const tUwCoordYX *pFirst = &pTnt->pCoords[0];
	flipbookAdd(
		pFirst->uwX << 5, pFirst->uwY << 5, onExplosionPeak, 0, pTnt, FLIPBOOK_KIND_BOOM
	);
}

UBYTE tntIsDetonationActive(const tTnt *pTnt) {
	UBYTE isActive = (
		pTnt->ubCurrent != DETONATION_CURRENT_INVALID &&
		pTnt->ubCurrent < pTnt->ubCoordCount
	);
	return isActive;
}

void tntAdd(tTnt *pTnt, tDirection eDir) {
	tDirection eOpposite = dirGetOpposite(eDir);
	if(pTnt->eDir == eOpposite && pTnt->ubCoordCount) {
		// Opposite dir - reduce the chain
		// TODO: calculate the charge cost of removed tile
		--pTnt->ubCoordCount;
		tUwCoordYX sTntPos = pTnt->pCoords[pTnt->ubCoordCount - 1];
		UBYTE ubChargeCost = tileIsHardToDrill(sTntPos.uwX, sTntPos.uwY) ? 2 : 1;
		pTnt->ubChargeCost -= ubChargeCost;
		return;
	}

	UBYTE ubMaxCharges = MIN(3, inventoryGetPartDef(INVENTORY_PART_TNT)->ubLevel);
	if(pTnt->eDir != eDir) {
		// Other dir - reset the TNT chain
		pTnt->ubCoordCount = 0;
		pTnt->ubChargeCost = 0;
		pTnt->eDir = eDir;
	}

	tBCoordYX sDelta = dirToDelta(pTnt->eDir);
	tUwCoordYX sTntPos = ((pTnt->ubCoordCount == 0) ?
		pTnt->sStartPos :
		pTnt->pCoords[pTnt->ubCoordCount - 1]
	);
	sTntPos.uwX += sDelta.bX;
	sTntPos.uwY += sDelta.bY;
	if(sTntPos.uwX < 1 || 10 < sTntPos.uwX) {
		return;
	}
	if(
		!tileIsDrillable(sTntPos.uwX, sTntPos.uwY) &&
		tileIsSolid(sTntPos.uwX, sTntPos.uwY)
	) {
		return;
	}

	// TODO: calculate the charge cost
	UBYTE ubChargeCost = tileIsHardToDrill(sTntPos.uwX, sTntPos.uwY) ? 2 : 1;
	if(pTnt->ubChargeCost + ubChargeCost > ubMaxCharges) {
		return;
	}

	pTnt->pCoords[pTnt->ubCoordCount] = sTntPos;
	pTnt->ubChargeCost += ubChargeCost;
	++pTnt->ubCoordCount;
}
