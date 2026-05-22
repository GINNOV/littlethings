#include "gamestates/game/projectile.h"
#include "gamestates/game/vehicle.h"
#include "gamestates/game/bob_new.h"
#include "gamestates/game/game.h"
#include "gamestates/game/worldmap.h"
#include "gamestates/game/building.h"
#include "gamestates/game/player.h"
#include "gamestates/game/explosions.h"
#include "gamestates/game/console.h"

#define PROJECTILE_BULLET_HEIGHT 2
#define PROJECTILE_DAMAGE 10

static tProjectile *s_pProjectiles;
static FUBYTE s_fubProjectileMaxCount;
static FUBYTE s_fubPrevProjectileAdded;
static tBitMap *s_pBulletBitmap;
static tBitMap *s_pBulletMask;

static fix16_t s_pProjectileDx[VEHICLE_TURRET_ANGLE_COUNT];
static fix16_t s_pProjectileDy[VEHICLE_TURRET_ANGLE_COUNT];

void projectileListCreate(FUBYTE fubProjectileMaxCount) {
	logBlockBegin(
		"projectileListCreate(ubProjectileMaxCount: %hhu)", fubProjectileMaxCount
	);

	// Load gfx
	s_pBulletBitmap = bitmapCreateFromFile("data/projectiles/bullet.bm");
	s_pBulletMask = bitmapCreateFromFile("data/projectiles/bullet_mask.bm");

	// Create projectiles
	s_fubProjectileMaxCount = fubProjectileMaxCount;
	s_pProjectiles = memAllocFastClear(fubProjectileMaxCount * sizeof(tProjectile));
	s_fubPrevProjectileAdded = fubProjectileMaxCount - 1;
	for(FUBYTE i = 0; i < fubProjectileMaxCount; ++i) {
		s_pProjectiles[i].ubType = PROJECTILE_TYPE_OFF;
		bobNewInit(
			&s_pProjectiles[i].sBob,
			bitmapGetByteWidth(s_pBulletBitmap) * 8, PROJECTILE_BULLET_HEIGHT, 1,
			s_pBulletBitmap, s_pBulletMask, 0, 0
		);
	}

	logBlockEnd("projectileListCreate()");

	// Prepare projectile speeds
	for(FUBYTE i = 0; i < VEHICLE_TURRET_ANGLE_COUNT; ++i) {
		s_pProjectileDx[i] = fix16_mul(ccos(i), PROJECTILE_SPEED);
		s_pProjectileDy[i] = fix16_mul(csin(i), PROJECTILE_SPEED);
	}
}

void projectileListDestroy(void) {
	logBlockBegin("projectileListDestroy()");

	memFree(s_pProjectiles, s_fubProjectileMaxCount * sizeof(tProjectile));
	// Dealloc bob bitmaps
	bitmapDestroy(s_pBulletBitmap);
	bitmapDestroy(s_pBulletMask);

	logBlockEnd("projectileListDestroy()");
}

tProjectile *projectileCreate(
	UBYTE ubOwnerType, tProjectileOwner uOwner, UBYTE ubType
) {
	// Find free projectile
	tProjectile *pProjectile = 0;
	FUBYTE i = s_fubPrevProjectileAdded+1;
	do {
		if(i == s_fubProjectileMaxCount) {
			i = 0;
		}
		if(s_pProjectiles[i].ubType == PROJECTILE_TYPE_OFF) {
			pProjectile = &s_pProjectiles[i];
			s_fubPrevProjectileAdded = i;
			break;
		}
	} while(i++ != s_fubPrevProjectileAdded);
	if(!pProjectile) {
		return 0;
	}

	pProjectile->uOwner = uOwner;
	pProjectile->ubType = ubType;
	pProjectile->ubOwnerType = ubOwnerType;

	// Initial projectile position & angle
	if(ubOwnerType == PROJECTILE_OWNER_TYPE_VEHICLE) {
		if(uOwner.pVehicle->pType == &g_pVehicleTypes[VEHICLE_TYPE_TANK]) {
			pProjectile->ubAngle = uOwner.pVehicle->ubTurretAngle;
		}
		else {
			pProjectile->ubAngle = uOwner.pVehicle->ubBodyAngle;
		}
		fix16_t fSin = csin(pProjectile->ubAngle);
		fix16_t fCos = ccos(pProjectile->ubAngle);
		pProjectile->fX = fix16_add(uOwner.pVehicle->fX, (VEHICLE_BODY_WIDTH/2) * fCos);
		pProjectile->fY = fix16_add(uOwner.pVehicle->fY, (VEHICLE_BODY_HEIGHT/2) * fSin);
	}
	else {
		pProjectile->fX = fix16_from_int(uOwner.pTurret->uwCenterX);
		pProjectile->fY = fix16_from_int(uOwner.pTurret->uwCenterY);
		pProjectile->ubAngle = uOwner.pTurret->ubAngle;
	}

	// Frame life
	pProjectile->uwFrameLife = PROJECTILE_FRAME_LIFE;
	return pProjectile;
}

void projectileDestroy(tProjectile *pProjectile) {
	pProjectile->ubType = PROJECTILE_TYPE_OFF;
}

void projectileSim(void) {
	tProjectile *pProjectile = &s_pProjectiles[0];
	for(UBYTE i = s_fubProjectileMaxCount; i--; ++pProjectile) {
		if(pProjectile->ubType == PROJECTILE_TYPE_OFF) {
			continue;
		}
		// Verify projectile lifespan
		if(!pProjectile->uwFrameLife) {
			projectileDestroy(pProjectile);
			continue;
		}
		--pProjectile->uwFrameLife;

		// Increment position
		pProjectile->fX = fix16_add(pProjectile->fX, s_pProjectileDx[pProjectile->ubAngle]);
		pProjectile->fY = fix16_add(pProjectile->fY, s_pProjectileDy[pProjectile->ubAngle]);

		// Check collision with vehicles
		if(projectileHasCollidedWithAnyPlayer(pProjectile)) {
			projectileDestroy(pProjectile);
			continue;
		}

		// Check collistion with buildings
		UBYTE ubTileX = fix16_to_int(pProjectile->fX) >> MAP_TILE_SIZE;
		UBYTE ubTileY = fix16_to_int(pProjectile->fY) >> MAP_TILE_SIZE;
		UBYTE ubBuildingIdx = g_sMap.pData[ubTileX][ubTileY].ubBuilding;
		if(ubBuildingIdx != BUILDING_IDX_INVALID && (
			pProjectile->ubOwnerType != PROJECTILE_OWNER_TYPE_TURRET ||
			g_sMap.pData[ubTileX][ubTileY].ubIdx != MAP_LOGIC_WALL
		)) {
			if(buildingDamage(ubBuildingIdx, PROJECTILE_DAMAGE) == BUILDING_DESTROYED) {
				mapSetLogic(ubTileX, ubTileY, MAP_LOGIC_DIRT);
				g_sMap.pData[ubTileX][ubTileY].ubBuilding = 0;
				worldMapSetTile(ubTileX, ubTileY, worldMapTileDirt(ubTileX, ubTileY));
				explosionsAdd(
					(ubTileX << MAP_TILE_SIZE) + MAP_HALF_TILE,
					(ubTileY << MAP_TILE_SIZE) + MAP_HALF_TILE
				);
			}
			projectileDestroy(pProjectile);
			continue;
		}
		pProjectile->sBob.sPos.sUwCoord.uwX = fix16_to_int(pProjectile->fX)-PROJECTILE_BULLET_HEIGHT/2;
		pProjectile->sBob.sPos.sUwCoord.uwY = fix16_to_int(pProjectile->fY)-PROJECTILE_BULLET_HEIGHT/2;
		bobNewPush(&pProjectile->sBob);
	}
}

UBYTE projectileHasCollidedWithAnyPlayer(tProjectile *pProjectile) {
	for(FUBYTE i = g_ubPlayerLimit; i--;) {
		if(!g_pPlayers[i].szName[0] || g_pPlayers[i].ubState != PLAYER_STATE_DRIVING)
			continue;
		tVehicle *pVehicle = &g_pPlayers[i].sVehicle;
		const fix16_t fQuarterWidth = fix16_from_int(VEHICLE_BODY_WIDTH/4);
		if(
			pProjectile->fX > fix16_sub(pVehicle->fX, fQuarterWidth) &&
			pProjectile->fX < fix16_add(pVehicle->fX, fQuarterWidth) &&
			pProjectile->fY > fix16_sub(pVehicle->fY, fQuarterWidth) &&
			pProjectile->fY < fix16_add(pVehicle->fY, fQuarterWidth)
		) {
			if(playerDamageVehicle(&g_pPlayers[i], PROJECTILE_DAMAGE)) {
				char szBfr[CONSOLE_MESSAGE_MAX];
				if(pProjectile->ubOwnerType == PROJECTILE_OWNER_TYPE_TURRET) {
					sprintf(szBfr, "%s was killed by turret", g_pPlayers[i].szName);
				}
				else {
					sprintf(
						szBfr, "%s was killed by %s",g_pPlayers[i].szName,
						playerGetByVehicle(pProjectile->uOwner.pVehicle)->szName
					);
				}
				consoleWrite(szBfr, CONSOLE_COLOR_GENERAL);
			}
			projectileDestroy(pProjectile);
			return 1;
		}
	}
	return 0;
}
