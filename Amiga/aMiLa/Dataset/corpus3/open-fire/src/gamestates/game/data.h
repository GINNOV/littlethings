#ifndef GUARD_OF_GAMESTATES_GAME_DATA_H
#define GUARD_OF_GAMESTATES_GAME_DATA_H

#include <ace/types.h>
#include "gamestates/game/explosions.h"
#include "gamestates/game/projectile.h"
#include "gamestates/game/player.h"

#define DATA_MAX_SERVER_NAME 20
#define DATA_MAX_MOTD        80
#define DATA_MAX_CHAT        40
#define DATA_MAX_PACKET_SIZE 1000

#define DATA_PACKET_TYPE_JO         1 /* C->S Join request */
#define DATA_PACKET_TYPE_JOIN_RESPONSE 2 /* S->C Join request reply */
#define DATA_PACKET_TYPE_SRV_STATE     3 /* S->C State frame */
#define DATA_PACKET_TYPE_CLT_FRAME     4 /* C->S Move request from client */

// http://amiga.sourceforge.net/amigadevhelp/phpwebdev.php?keyword=recv&funcgroup=AmiTCP&action=Search
// http://amiga.sourceforge.net/amigadevhelp/phpwebdev.php?keyword=ioctlsocket&funcgroup=AmiTCP&action=Search
typedef struct _tDataHeader {
	UWORD uwType;
	UWORD uwSize;
	UWORD uwServerTime;
} tDataHeader;

// size: 22 (could be 20)
typedef struct _tVehicleState {
	// Copypasta from tVehicle
	fix16_t fX;          ///< Vehicle X-position relative to center of gfx.
	fix16_t fY;          ///< Ditto, vehicle Y.
	UBYTE ubBodyAngle;   ///< Measured clockwise, +90deg is to bottom.
	UBYTE ubTurretAngle; ///< NOT relative to body angle, measured as above.
	// Aligned with ubDestAngle
	UBYTE ubVehicleType;  ///< Could be combined with ubVehicleState per nibble
	UBYTE ubPlayerState;  ///< DEAD, SURFACING, etc.
	// For vehicle prediction
	UBYTE ubDestAngle;    ///< Turret.
	fix16_t fDx;
	fix16_t fDy;
} tVehicleState;

#define DATA_PROJECTILE_STATE_TYPE_CREATED   1
#define DATA_PROJECTILE_STATE_TYPE_MOVING    2
#define DATA_PROJECTILE_STATE_TYPE_DESTROYED 3

// There is no need to transfer dx,dy since let's assume dx,dy = 0,0;
// then next frame with changed position may be used to calculate dx/dy.
// But then if next frame is dropped, dx,dy will be too large, also homing
// size: 12
typedef struct _tProjectileState {
	// Copypasta from tProjectile
	UBYTE ubProjectileState;   /// CREATED, MOVING, DESTROYED
	UBYTE ubAngle;
	union {
		struct {
			UBYTE ubType;          ///< See PROJECTILE_TYPE_* defines.
			UBYTE ubOwnerType;     ///< See PROJECTILE_OWNER_TYPE_* defines.
		} sCreated;
		struct {
			// Idx could be bigger if ubWhat would reside in lower 2 bits
			UBYTE ubWhat; // PLAYER, TURRET, BUILDING
			UBYTE ubIdx;  // Player idx or building idx
		} sDestroyed;
	} u;
	fix16_t fX;                ///< X-coord of current position.
	fix16_t fY;                ///< Ditto, Y-coord.
} tProjectileState;

typedef struct _tAction {
	UBYTE ubType; // NONE, PLAYER_JOINED, PLAYER_LEAVED, CHAT
	union {
		struct {
			UBYTE ubIdx;
			UWORD uwHardware;
			char szName[PLAYER_NAME_MAX];
		} sPlayer;
		struct {
			char szMessage[DATA_MAX_CHAT];
		} sChat;
	} u;
} tAction;

// Header + stuff: 6
// Players: 8 * 22 = 176
// Projectiles: 20 * 12  = 240
// Action: 41 bytes
// TOTAL: 463 bytes
typedef struct _tDataFrame {
	tDataHeader sHeader;
	tVehicleState pPlayerStates[8];
	tProjectileState pProjectiles[20];
	tAction sAction;
} tDataFrame;

// Packet sent while connecting to server
typedef struct _tDataJoin {
	tDataHeader sHeader;
	UWORD uwHardware;
	UWORD uwVersion;
	char szPlayerName[PLAYER_NAME_MAX];
} tDataJoin;

// Welcome packet from server, sent after tDataJoin
// Next one is tDataFrame
typedef struct _tDataJoinResponse {
	tDataHeader sHeader;
	UBYTE ubErrorCode; // Should be zero on success
	UBYTE ubMaxPlayers;
	UBYTE ubMaxProjectiles;
	UBYTE ubLocalPlayerIdx;
	char szServerName[DATA_MAX_SERVER_NAME];
	char szMotd[DATA_MAX_MOTD];
	struct {
		char szName[PLAYER_NAME_MAX];
		UBYTE ubTeam;
	} pPlayerDefs[8];
} tDataJoinResponse;

void dataSend(void);
void dataRecv(void);

void dataForcePlayerState(tPlayer *pPlayer, tVehicleState *pState);

#endif // GUARD_OF_GAMESTATES_GAME_DATA_H
