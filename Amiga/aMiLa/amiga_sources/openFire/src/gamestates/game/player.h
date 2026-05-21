#ifndef GUARD_OF_GAMESTATES_GAME_PLAYER_H
#define GUARD_OF_GAMESTATES_GAME_PLAYER_H

#include "gamestates/game/vehicle.h"

#define PLAYER_MAX_COUNT 8
#define PLAYER_NAME_MAX        20

#define PLAYER_DEATH_COOLDOWN 150
#define PLAYER_SURFACING_COOLDOWN 60

#define PLAYER_STATE_OFF       0 /* Offline */
#define PLAYER_STATE_LIMBO     1 /* Dead / in bunker */
#define PLAYER_STATE_SURFACING 2 /* Animation out of bunker */
#define PLAYER_STATE_DRIVING   3 /* On map */
#define PLAYER_STATE_PARKING   4 /* Changing angle to facing south */
#define PLAYER_STATE_BUNKERING 5 /* Animating to bunker */

typedef struct _tPlayer {
	// General
	char szName[PLAYER_NAME_MAX];
	UBYTE ubTeam;
	UBYTE ubCurrentVehicleType;
	UBYTE ubState;
	UBYTE isBot;
	UWORD uwCooldown;
	tVehicle sVehicle;
	tSteerRequest sSteerRequest;

	UBYTE ubSpawnIdx;
	// Stats for score table displaying - for CTF
	UBYTE ubHasFlag;
	// Vehicles available - for last man standing
	UBYTE pVehiclesLeft[4];
	// Score - kills?
	UWORD uwScore;
} tPlayer;

void playerListInit(UBYTE ubPlayerLimit);

tPlayer *playerAdd(const char *szName, UBYTE ubTeam);

void playerRemoveByIdx(UBYTE ubPlayerIdx);

void playerRemoveByPtr(tPlayer *pPlayer);

void playerSelectVehicle(
	tPlayer *pPlayer,
	UBYTE ubVehicleType
);

void playerHideInBunker(tPlayer *pPlayer, FUBYTE fubSpawnIdx);

FUBYTE playerDamageVehicle(tPlayer *pPlayer, UBYTE ubDamage);

void playerLoseVehicle(tPlayer *pPlayer);

void playerSteerVehicle(tPlayer *pPlayer);

void playerLocalProcessInput(void);

void playerSim(void);

void playerSimVehicle(tPlayer *pPlayer);

void playerSay(tPlayer *pPlayer, char *szMsg, UBYTE isSayTeam);

static inline tPlayer *playerGetByVehicle(const tVehicle *pVehicle) {
	UBYTE *pVehicleByteAddr = (UBYTE*)pVehicle;
	tPlayer sPlayer;
	UBYTE ubDist = ((UBYTE*)&sPlayer.sVehicle) - ((UBYTE*)&sPlayer);
	return (tPlayer*)(pVehicleByteAddr - ubDist);
}

UBYTE playerAnyNearPoint(UWORD uwChkX, UWORD uwChkY, UWORD uwDist);

tPlayer *playerGetClosestInRange(
	UWORD uwX, UWORD uwY, UWORD uwRange, UBYTE ubTeam
);

extern tPlayer g_pPlayers[PLAYER_MAX_COUNT];
extern tPlayer *g_pLocalPlayer;
extern UBYTE g_ubPlayerLimit; /// Defined by current server
extern UBYTE g_ubPlayerCount;

#endif
