#ifndef GUARD_OF_GAMESTATES_GAME_TURRET_H
#define GUARD_OF_GAMESTATES_GAME_TURRET_H

#include "gamestates/game/projectile.h"
#include "gamestates/game/game.h"
#include "gamestates/game/bob_new.h"

#define TURRET_INVALID      0xFFFF
#define TURRET_MIN_DISTANCE (PROJECTILE_RANGE+32)
#define TURRET_COOLDOWN     PROJECTILE_FRAME_LIFE
#define TURRET_MAX_PROCESS_RANGE_Y ((WORLD_VPORT_HEIGHT>>MAP_TILE_SIZE) + 1)

/**
 *  Turret struct.
 *  Turrets can't have X = 0, because that's the way for checking
 *  if they are valid.
 */
typedef struct _tTurret {
	tBobNew sBob;
	UWORD uwCenterX; ///< In pixels.
	UWORD uwCenterY;
	UBYTE ubTeam;     ///< See TEAM_* defines.
	UBYTE ubAngle;
	UBYTE ubDestAngle;
	UBYTE isTargeting;
	FUBYTE fubSeq;
	UBYTE ubCooldown; ///< Cooldown between shots.
} tTurret;

extern tBitMap *g_pTurretFrames[TEAM_COUNT+1];
extern UWORD g_uwTurretCount;
extern tTurret *g_pTurrets;
extern UWORD g_pTurretTiles[MAP_MAX_SIZE][MAP_MAX_SIZE];

void turretListCreate(FUBYTE fubMapWidth, FUBYTE fubMapHeight);
void turretListDestroy(void);

UWORD turretAdd(UWORD uwX, UWORD uwY, UBYTE ubTeam);

void turretDestroy(UWORD uwIdx);

void turretCapture(UWORD uwIdx, FUBYTE fubTeam);

void turretSim(void);

tBitMap *turretGenerateFrames(const char *szPath);

#endif
