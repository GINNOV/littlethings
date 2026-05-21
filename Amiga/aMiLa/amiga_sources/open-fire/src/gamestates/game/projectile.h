#ifndef GUARD_OF_GAMESTATES_GAME_PROJECTILE_H
#define GUARD_OF_GAMESTATES_GAME_PROJECTILE_H

#include "gamestates/game/vehicle.h"
#include "gamestates/game/turret.h"
#include "gamestates/game/bob_new.h"

#define PROJECTILE_RANGE      ((320-32)/4)
#define PROJECTILE_SPEED      (fix16_one*3)
#define PROJECTILE_FRAME_LIFE fix16_to_int(fix16_div(fix16_from_int(PROJECTILE_RANGE), PROJECTILE_SPEED))


// Projectile types.
#define PROJECTILE_TYPE_OFF    0
#define PROJECTILE_TYPE_BULLET 1
#define PROJECTILE_TYPE_NADE   2
#define PROJECTILE_TYPE_ROCKET 3

// Projectile owner types.
#define PROJECTILE_OWNER_TYPE_VEHICLE 0
#define PROJECTILE_OWNER_TYPE_TURRET  1

struct _tVehicle;
struct _tTurret;

typedef union _tProjectileOwner {
	struct _tVehicle *pVehicle;
	struct _tTurret *pTurret;
} tProjectileOwner;

typedef struct _tProjectile {
	tBobNew sBob;            ///< Bob for projectile display
	tProjectileOwner uOwner; ///< Owner for scoring kills
	fix16_t fX;              ///< X-coord of current position.
	fix16_t fY;              ///< Ditto, Y-coord.
	UBYTE ubAngle;           ///< For determining dx/dy
	UWORD uwFrameLife;       ///< Projectile life, in remaining frame count.
	UBYTE ubType;            ///< See PROJECTILE_TYPE_* defines.
	UBYTE ubOwnerType;       ///< See PROJECTILE_OWNER_TYPE_* defines.
} tProjectile;

void projectileListCreate(FUBYTE ubProjectileCount);
void projectileListDestroy(void);

tProjectile *projectileCreate(
	UBYTE ubOwnerType, tProjectileOwner uOwner, UBYTE ubType
);

void projectileDestroy( tProjectile *pProjectile);

void projectileUndraw(void);
void projectileDraw(void);
void projectileSim(void);

UBYTE projectileHasCollidedWithAnyPlayer(tProjectile *pProjectile);


#endif // GUARD_OF_GAMESTATES_GAME_PROJECTILE_H
