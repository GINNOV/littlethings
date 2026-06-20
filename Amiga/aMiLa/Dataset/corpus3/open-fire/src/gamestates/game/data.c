#include "gamestates/game/data.h"
#include "gamestates/game/game.h"
#include "gamestates/game/vehicle.h"
#include "gamestates/game/player.h"
#include "gamestates/game/gamemath.h"

static UBYTE s_pDataBfr[DATA_MAX_PACKET_SIZE];
static UBYTE s_isPacketRead;

void dataTryReadPacket(void) {
	if(0) {
		// TODO packet successfully received
		s_isPacketRead = 1;
	}
}

void dataSend(void) {
	// TODO: dataSend: ???
}

void dataRecv(void) {
	// Packet spoofing
	tDataFrame *pFrame = (tDataFrame*)&s_pDataBfr;
	pFrame->sHeader.uwServerTime = 0;
	pFrame->sHeader.uwSize = 0;
	pFrame->sHeader.uwType = DATA_PACKET_TYPE_SRV_STATE;
	// for(UWORD i = 0; i != 8; ++i) {
	// 	// Fill players
	// 	pFrame->pPlayerStates[i].fDx = 0;
	// 	pFrame->pPlayerStates[i].fDy = 0;
	// 	pFrame->pPlayerStates[i].fX = fix16_from_int((10+(i & 3)*2) << MAP_TILE_SIZE);
	// 	pFrame->pPlayerStates[i].fY = fix16_from_int((5 + 2*(i/4)) << MAP_TILE_SIZE);
	// 	pFrame->pPlayerStates[i].ubBodyAngle = 0;
	// 	pFrame->pPlayerStates[i].ubDestAngle = 0;
	// 	pFrame->pPlayerStates[i].ubTurretAngle = 0;
	// 	pFrame->pPlayerStates[i].ubPlayerState = PLAYER_STATE_DRIVING;
	// 	pFrame->pPlayerStates[i].ubVehicleType = VEHICLE_TYPE_TANK;
	// }
	// s_isPacketRead = 1;
	s_isPacketRead = 0;

	if(s_isPacketRead) {
		for(UBYTE i = 0; i != 8; ++i) {
			if(&g_pPlayers[i] != g_pLocalPlayer) // TODO later remove
				dataForcePlayerState(&g_pPlayers[i], &pFrame->pPlayerStates[i]);
		}
		// TODO force projectiles
		// TODO force turrets
		// TODO force explosions
		s_isPacketRead = 0;
	}
	else {
		// Prediction
	}
}

void dataForcePlayerState(tPlayer *pPlayer, tVehicleState *pState) {
	if(pPlayer->ubState != pState->ubPlayerState) {
		pPlayer->ubState = pState->ubPlayerState;
	}
	if(pPlayer->ubState != PLAYER_STATE_LIMBO && pPlayer->ubState != PLAYER_STATE_OFF) {
		// Driving, surfacing or bunkering
		pPlayer->sVehicle.fX = pState->fX;
		pPlayer->sVehicle.fY = pState->fY;
		pPlayer->sVehicle.uwX = fix16_to_int(pState->fX);
		pPlayer->sVehicle.uwY = fix16_to_int(pState->fY);
		pPlayer->sVehicle.ubBodyAngle = pState->ubBodyAngle;
		pPlayer->sVehicle.ubTurretAngle = pState->ubTurretAngle;
		// TODO: destination angle
		// TODO: delta x,y
		if(pPlayer->ubCurrentVehicleType != pState->ubVehicleType) {
			pPlayer->ubCurrentVehicleType = pState->ubVehicleType;
			pPlayer->sVehicle.pType = &g_pVehicleTypes[pState->ubVehicleType];
		}
	}
}
