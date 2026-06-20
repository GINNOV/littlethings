/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "game.h"
#include <ace/managers/key.h>
#include <ace/managers/blit.h>
#include <ace/managers/system.h>
#include <ace/utils/custom.h>
#include <ace/utils/chunky.h>
#include <ace/utils/disk_file.h>
#include <ace/utils/string.h>
#include <ace/contrib/managers/audio_mixer.h>
#include <comm/gs_shop.h>
#include <comm/gs_msg.h>
#include <comm/page_questioning.h>
#include <comm/page_office.h>
#include <comm/inbox.h>
#include "vehicle.h"
#include "hud.h"
#include "tile.h"
#include "menu.h"
#include "hi_score.h"
#include "ground_layer.h"
#include "base.h"
#include "warehouse.h"
#include "tutorial.h"
#include "flipbook.h"
#include "fade.h"
#include "pause.h"
#include "core.h"
#include "dino.h"
#include "quest_gate.h"
#include "quest_crate.h"
#include "debug.h"
#include "inventory.h"
#include "defs.h"
#include "save.h"
#include "settings.h"
#include "collectibles.h"
#include "heat.h"
#include "assets.h"
#include "mode_menu.h"
#include "tile_variant.h"
#include "twister.h"
#include "protests.h"
#include "base_unlocks.h"
#include "achievement.h"

#define GAME_MUSIC_INTERVAL 100

#define CAMERA_SPEED 4
#define CAMERA_SHAKE_AMPLITUDE 2

#define SFX_CHANNEL_QUAKE 0
#define SFX_PRIORITY_QUAKE 10
#define SFX_CHANNEL_GATE 1
#define SFX_PRIORITY_GATE 10
#define SFX_CHANNEL_RUNE 2
#define SFX_PRIORITY_RUNE 5
#define REBUKES_MAX 3

//------------------------------------------------------------------------ TYPES

typedef enum _tCameraType {
	CAMERA_TYPE_P1,
	CAMERA_TYPE_P2,
} tCameraType;

typedef enum tModePreset {
	MODE_PRESET_OFF,
	MODE_PRESET_PROMPT_SHOP,
	MODE_PRESET_PROMPT_TRAVEL,
	MODE_PRESET_TOOLS,
	MODE_PRESET_TRAVEL,
	MODE_PRESET_COUNT,
} tModePreset;

typedef enum tGateCutsceneStep {
	GATE_CUTSCENE_STEP_OFF,
	// player teleport to gate steps
	GATE_CUTSCENE_TELEPORT_STEP_START,
	GATE_CUTSCENE_TELEPORT_STEP_WAIT_FOR_FADE_START,
	GATE_CUTSCENE_TELEPORT_STEP_FADE_OUT,
	GATE_CUTSCENE_TELEPORT_STEP_FADE_IN,
	GATE_CUTSCENE_TELEPORT_STEP_WAIT_FOR_GATE_DRAW,
	GATE_CUTSCENE_TELEPORT_STEP_END,
	// gate open steps
	GATE_CUTSCENE_OPEN_STEP_START,
	GATE_CUTSCENE_OPEN_STEP_WAIT_FOR_SHAKE,
	GATE_CUTSCENE_OPEN_STEP_SHAKE_BEFORE_LIGHTS,
	GATE_CUTSCENE_OPEN_STEP_LIGHTS_BEFORE_TWIST,
	GATE_CUTSCENE_OPEN_STEP_TWIST_BEFORE_FADE,
	GATE_CUTSCENE_OPEN_STEP_FADE_OUT,
	GATE_CUTSCENE_OPEN_STEP_FADE_IN,
	GATE_CUTSCENE_OPEN_STEP_OPEN_END,
	// gate destroy steps
	GATE_CUTSCENE_DESTROY_STEP_START,
	GATE_CUTSCENE_DESTROY_STEP_EXPLODING,
	GATE_CUTSCENE_DESTROY_STEP_FADE_OUT,
	GATE_CUTSCENE_DESTROY_STEP_FADE_IN,
	GATE_CUTSCENE_DESTROY_STEP_END,
} tGateCutsceneStep;

//----------------------------------------------------------------- PRIVATE VARS

static tBob s_pPlayerBombMarkers[2][3];
static tModePreset s_pPlayerModePreset[2];

static tUwCoordYX s_sTeleportReturn;

static tSteer s_pPlayerSteers[2];
static tCameraType s_eCameraType = CAMERA_TYPE_P1;
static UBYTE s_ubChallengeCamCnt;
static tVPort *s_pVpMain;
static UBYTE s_ubRebukeCount, s_ubAccolades, s_ubAccoladesFract;
static WORD s_wLastReminder;
static UBYTE s_ubCurrentMod;
static ULONG s_ulGameTime;
static UWORD s_uwMaxTileY;
static tModeMenu s_pModeMenus[2];
static tGateCutsceneStep s_eGateCutsceneStep;
static UBYTE s_isCameraShake;
static UBYTE s_ubMusicCooldown;
static UBYTE s_isMusicEnabled;
static UBYTE s_isHandlingPause;
static UBYTE s_pRebukes[REBUKES_MAX];

static char s_szMessageBuffer[GAME_MESSAGE_BUFFER_SIZE];

//------------------------------------------------------------------ PUBLIC VARS

UBYTE g_is2pPlaying;
UBYTE g_isAtari;
UBYTE g_isSokoUnlock;
tGameMode g_eGameMode;

//------------------------------------------------------------ PRIVATE FNS: MODE
// TODO: reformat somehow? Move to separate file?

static tBaseId gameModeToBaseId(tModeOption eMode) {
	return (eMode - MODE_OPTION_TRAVEL_BASE1_GROUND) + BASE_ID_GROUND;
}

static tModeOption gameBaseIdToMode(tBaseId eBaseId) {
	return (eBaseId - BASE_ID_GROUND) + MODE_OPTION_TRAVEL_BASE1_GROUND;
}

static UBYTE gameChangeModePreset(UBYTE ubPlayerIndex, tModePreset ePreset) {
	if(s_pPlayerModePreset[ubPlayerIndex] == ePreset) {
		return 0;
	}

	s_pPlayerModePreset[ubPlayerIndex] = ePreset;
	tModeMenu *pModeMenu = &s_pModeMenus[ubPlayerIndex];
	modeMenuClearOptions(pModeMenu);
	switch(ePreset) {
		case MODE_PRESET_PROMPT_SHOP:
			modeMenuAddOption(pModeMenu, MODE_OPTION_EXCLAMATION);
			break;
		case MODE_PRESET_PROMPT_TRAVEL:
			modeMenuAddOption(pModeMenu, MODE_OPTION_EXCLAMATION);
			break;
		case MODE_PRESET_TRAVEL:
			UBYTE ubPlatformLevel = inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, baseGetCurrentId());
			if(
				inventoryGetPartDef(INVENTORY_PART_TELEPORT)->ubLevel >= 3 &&
				s_sTeleportReturn.ulYX != -1u &&
				inventoryGetPartDef(INVENTORY_PART_TELEPORT)->ubLevel >= 3
			) {
				modeMenuAddOption(pModeMenu, MODE_OPTION_TELEPORT);
			}
			if(ubPlatformLevel == INVENTORY_LEVEL_PLATFORM_ADJACENT) {
				BYTE bPrevBaseId = (BYTE)baseGetCurrentId() - 1;
				BYTE bNextBaseId = (BYTE)baseGetCurrentId() + 1;
				if(
					bPrevBaseId >= BASE_ID_GROUND &&
					inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, bPrevBaseId)
				) {
					modeMenuAddOption(pModeMenu, gameBaseIdToMode(baseGetCurrentId() - 1));
				}
				modeMenuAddOption(pModeMenu, gameBaseIdToMode(baseGetCurrentId()));
				if(
					baseGetCurrentId() + 1 < BASE_ID_COUNT_UNIQUE &&
					inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, bNextBaseId)
				) {
					modeMenuAddOption(pModeMenu, gameBaseIdToMode(baseGetCurrentId() + 1));
				}
			}
			else if(ubPlatformLevel == INVENTORY_LEVEL_PLATFORM_ALL) {
				if(inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, BASE_ID_GROUND)) {
					modeMenuAddOption(pModeMenu, MODE_OPTION_TRAVEL_BASE1_GROUND);
				}
				if(inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, BASE_ID_DINO)) {
					modeMenuAddOption(pModeMenu, MODE_OPTION_TRAVEL_BASE2_DINO);
				}
				if(inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, BASE_ID_GATE)) {
					modeMenuAddOption(pModeMenu, MODE_OPTION_TRAVEL_BASE3_GATE);
				}
				if(inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, BASE_ID_WESTERN)) {
					modeMenuAddOption(pModeMenu, MODE_OPTION_TRAVEL_BASE4_SCI);
				}
			}
			break;
		case MODE_PRESET_TOOLS:
			modeMenuAddOption(pModeMenu, MODE_OPTION_DRILL);
			if(inventoryGetPartDef(INVENTORY_PART_TNT)->ubLevel) {
				modeMenuAddOption(pModeMenu, MODE_OPTION_TNT);
			}
			if(inventoryGetPartDef(INVENTORY_PART_TELEPORT)->ubLevel) {
				modeMenuAddOption(pModeMenu, MODE_OPTION_TELEPORT);
			}
			break;
		case MODE_PRESET_OFF:
		default:
			break;
	}
	return 1;
}

static void gameResetModePreset(UBYTE ubPlayerIndex) {
	// set to  anything else to trigger change
	s_pPlayerModePreset[ubPlayerIndex] = MODE_PRESET_PROMPT_SHOP;

	gameChangeModePreset(ubPlayerIndex, MODE_PRESET_OFF);
}

static void gameProcessModeTnt(UBYTE ubPlayer) {
	tTnt *pTnt = &g_pVehicles[ubPlayer].sDynamite;
	if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_LEFT)) {
		tntAdd(pTnt, DIRECTION_LEFT);
	}
	else if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_RIGHT)) {
		tntAdd(pTnt, DIRECTION_RIGHT);
	}
	else if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_UP)) {
		tntAdd(pTnt, DIRECTION_UP);
	}
	else if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_DOWN)) {
		tntAdd(pTnt, DIRECTION_DOWN);
	}
	else if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_FIRE)) {
		tntDetonate(pTnt);
		g_pVehicles[ubPlayer].eDrillMode = MODE_OPTION_DRILL;
	}
}

static void gameDisplayModeTnt(UBYTE ubPlayer) {
	if(
		s_pModeMenus[ubPlayer].isActive ||
		g_pVehicles[ubPlayer].eDrillMode != MODE_OPTION_TNT
	) {
		return;
	}
	const tTnt *pTnt = &g_pVehicles[ubPlayer].sDynamite;
	tBob *pPlayerBombMarkers = s_pPlayerBombMarkers[ubPlayer];
	for(UBYTE i = 0; i < pTnt->ubCoordCount; ++i) {
		pPlayerBombMarkers[i].sPos.uwX = (pTnt->pCoords[i].uwX << TILE_SHIFT) + 8;
		pPlayerBombMarkers[i].sPos.uwY = (pTnt->pCoords[i].uwY << TILE_SHIFT) + 11;
		gameTryPushBob(&pPlayerBombMarkers[i]);
	}
}

static void gameProcessModeTeleport(UBYTE ubPlayer) {
	s_sTeleportReturn = (tUwCoordYX) {
		.uwX = fix16_to_int(g_pVehicles[ubPlayer].fX),
		.uwY = fix16_to_int(g_pVehicles[ubPlayer].fY)
	};
	if(g_pVehicles[ubPlayer].eLastVisitedTeleportableBase != BASE_ID_COUNT_UNIQUE) {
		const tBase *pBase = baseGetById(g_pVehicles[ubPlayer].eLastVisitedTeleportableBase);
		vehicleTeleport(&g_pVehicles[ubPlayer], pBase->sPosTeleport.uwX, pBase->sPosTeleport.uwY, TELEPORT_KIND_MINE_TO_BASE);
	}
	g_pVehicles[ubPlayer].eDrillMode = MODE_OPTION_DRILL;
}

static UBYTE gameProcessModeDrill(UBYTE ubPlayer) {
	tModeMenu *pModeMenu = &s_pModeMenus[ubPlayer];

	if(g_eGameMode != GAME_MODE_CHALLENGE) {
		tModePreset eNextPreset = s_pPlayerModePreset[ubPlayer];
		switch(eNextPreset) {
			case MODE_PRESET_COUNT:
				eNextPreset = MODE_PRESET_OFF;
				// fallthrough
			case MODE_PRESET_OFF:
				if(vehicleIsNearShop(&g_pVehicles[ubPlayer])) {
					if(g_eGameMode == GAME_MODE_STORY) {
						eNextPreset = MODE_PRESET_PROMPT_SHOP;
					}
				}
				else if(
					vehicleIsNearBaseTeleporter(&g_pVehicles[ubPlayer]) &&
					inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, baseGetCurrentId()) >= INVENTORY_LEVEL_PLATFORM_ADJACENT
				) {
					eNextPreset = MODE_PRESET_PROMPT_TRAVEL;
				}
				else {
					if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_FIRE)) {
						if(g_pVehicles[ubPlayer].isMarkerShown) {
							// Focus on player if off-screen
							s_eCameraType = (ubPlayer == 0) ? CAMERA_TYPE_P1 : CAMERA_TYPE_P2;
						}
						else {
							eNextPreset = MODE_PRESET_TOOLS;
						}
					}
				}
				break;
			case MODE_PRESET_TOOLS:
				if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_FIRE)) {
					tModeOption eSelectedMode = modeMenuHide(pModeMenu);
					if(eSelectedMode == MODE_OPTION_TNT) {
						tUwCoordYX sTilePos = {
							.uwX = (g_pVehicles[ubPlayer].sBobBody.sPos.uwX + VEHICLE_WIDTH / 2) >> 5,
							.uwY = (g_pVehicles[ubPlayer].sBobBody.sPos.uwY + VEHICLE_WIDTH / 2) >> 5
						};
						tntReset(&g_pVehicles[ubPlayer].sDynamite, ubPlayer, sTilePos);
					}
					g_pVehicles[ubPlayer].eDrillMode = eSelectedMode;
					eNextPreset = MODE_PRESET_OFF;
				}
				break;
			case MODE_PRESET_PROMPT_SHOP:
					if(!vehicleIsNearShop(&g_pVehicles[ubPlayer])) {
						eNextPreset = MODE_PRESET_OFF;
					}
					else if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_FIRE) || inboxGetState() == INBOX_STATE_URGENT) {
						vehicleStopLoopAudio(0);
						vehicleStopLoopAudio(1);
						statePush(g_pGameStateManager, &g_sStateShop);
						return 1;
					}
					break;
			case MODE_PRESET_PROMPT_TRAVEL:
				if(!vehicleIsNearBaseTeleporter(&g_pVehicles[ubPlayer])) {
					eNextPreset = MODE_PRESET_OFF;
				}
				else if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_FIRE)) {
					eNextPreset = MODE_PRESET_TRAVEL;
				}
				break;
			case MODE_PRESET_TRAVEL:
				if(!vehicleIsNearBaseTeleporter(&g_pVehicles[ubPlayer])) {
					eNextPreset = MODE_PRESET_OFF;
				}
				else if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_FIRE)) {
					tModeOption eSelectedMode = modeMenuHide(pModeMenu);
					if(eSelectedMode == MODE_OPTION_TELEPORT) {
						vehicleTeleport(
							&g_pVehicles[ubPlayer],
							s_sTeleportReturn.uwX, s_sTeleportReturn.uwY,
							TELEPORT_KIND_BASE_TO_MINE
						);
						s_sTeleportReturn.ulYX = -1;
					}
					else {
						tBaseId eSelectedBaseId = gameModeToBaseId(eSelectedMode);
						const tBase *pBase = baseGetById(eSelectedBaseId);
						if(pBase != baseGetCurrent()) {
							g_pVehicles[ubPlayer].eLastVisitedTeleportableBase = eSelectedBaseId;
							vehicleTeleport(
								&g_pVehicles[ubPlayer],
								pBase->sPosTeleport.uwX, pBase->sPosTeleport.uwY,
								TELEPORT_KIND_BASE_TO_BASE
							);
						}
					}
					eNextPreset = MODE_PRESET_OFF;
				}
				break;
		}

		if(gameChangeModePreset(ubPlayer, eNextPreset)) {
			if(eNextPreset == MODE_PRESET_OFF) {
				modeMenuHide(&s_pModeMenus[ubPlayer]);
			}
			else {
				modeMenuShow(&s_pModeMenus[ubPlayer]);
			}
		}
	}

	if(pModeMenu->isActive && s_pPlayerModePreset[ubPlayer] >= MODE_PRESET_TOOLS) {
		tDirection eDirection = DIRECTION_COUNT;
		if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_LEFT)) {
			eDirection = DIRECTION_LEFT;
		}
		else if(steerDirUse(&s_pPlayerSteers[ubPlayer], DIRECTION_RIGHT)) {
			eDirection = DIRECTION_RIGHT;
		}
		modeMenuProcess(pModeMenu, eDirection);
		vehicleMove(&g_pVehicles[ubPlayer], 0, 0);
	}
	else {
		BYTE bDirX = 0, bDirY = 0;
		if(!g_pVehicles[ubPlayer].isChallengeEnded) {
			if(steerDirCheck(&s_pPlayerSteers[ubPlayer], DIRECTION_RIGHT)) { bDirX += 1; }
			if(steerDirCheck(&s_pPlayerSteers[ubPlayer], DIRECTION_LEFT)) { bDirX -= 1; }
			if(steerDirCheck(&s_pPlayerSteers[ubPlayer], DIRECTION_DOWN)) { bDirY += 1; }
			if(steerDirCheck(&s_pPlayerSteers[ubPlayer], DIRECTION_UP)) { bDirY -= 1; }
		}
		vehicleMove(&g_pVehicles[ubPlayer], bDirX, bDirY);
	}
	return 0;
}

static UBYTE gameProcessSteer(UBYTE ubPlayer) {
	UBYTE isReturnImmediately = 0;
	if(ubPlayer == 0 || g_is2pPlaying) {
		if(s_pModeMenus[ubPlayer].isActive) {
			isReturnImmediately = gameProcessModeDrill(ubPlayer);
		}
		else {
			switch(g_pVehicles[ubPlayer].eDrillMode) {
				case MODE_OPTION_DRILL:
					isReturnImmediately = gameProcessModeDrill(ubPlayer);
					break;
				case MODE_OPTION_TNT:
					gameProcessModeTnt(ubPlayer);
					break;
				case MODE_OPTION_TELEPORT:
					gameProcessModeTeleport(ubPlayer);
					break;
				default:
					break;
			}
		}
	}
	return isReturnImmediately;
}

//------------------------------------------------------------------ PRIVATE FNS

static void gameProcessHotkeys(void) {
  if(keyUse(KEY_ESCAPE) || keyUse(KEY_P)) {
		s_isHandlingPause = 1;
		stateChange(g_pGameStateManager, &g_sStatePause);
		return;
  }
	if(keyUse(KEY_B)) {
		debugToggle();
	}
	if(keyCheck(KEY_SLASH)) {
		vPortWaitForEnd(s_pVpMain);
		vPortWaitForEnd(s_pVpMain);
		vPortWaitForEnd(s_pVpMain);
	}

	if(keyUse(KEY_F1) && g_eGameMode != GAME_MODE_CHALLENGE) {
		if(!g_is2pPlaying) {
			g_is2pPlaying = 1;
			hudSet2pPlaying(1);
			modeMenuReset(&s_pModeMenus[1], 1);
			gameResetModePreset(1);
			vehicleResetPos(&g_pVehicles[1]);
			g_pVehicles[1].fX = g_pVehicles[0].fX;
			g_pVehicles[1].fY = g_pVehicles[0].fY;
		}
		else {
			g_is2pPlaying = 0;
			hudSet2pPlaying(0);
		}
	}
	else if(keyUse(KEY_F2)) {
		if(g_eGameMode != GAME_MODE_CHALLENGE) {
			if(s_eCameraType == CAMERA_TYPE_P1) {
				s_eCameraType = CAMERA_TYPE_P2;
			}
			else {
				s_eCameraType = CAMERA_TYPE_P1;
			}
		}
	}
#if defined(GAME_DEBUG)
	else if(keyUse(KEY_O)) {
		pageOfficeUnlockPerson(FACE_ID_MIETEK);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_WELCOME);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_FIRST_PLAN);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_PLAN_COMPLETE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_MARKET);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_PROTEST_START);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_PROTEST_STRIKE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_CAPSULE_FOUND);

		pageOfficeUnlockPerson(FACE_ID_KRYSTYNA);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_KRYSTYNA, COMM_SHOP_PAGE_OFFICE_KRYSTYNA_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_KRYSTYNA, COMM_SHOP_PAGE_OFFICE_KRYSTYNA_ACCOUNTING);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_KRYSTYNA, COMM_SHOP_PAGE_OFFICE_KRYSTYNA_PROTEST_WARNING);

		pageOfficeUnlockPerson(FACE_ID_URZEDAS);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_WELCOME);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_FIRST_PLAN);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_COMPLETE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_DELAYED);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_ACCOLADE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_BRIBE);

		pageOfficeUnlockPerson(FACE_ID_KOMISARZ);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_KOMISARZ, COMM_SHOP_PAGE_OFFICE_KOMISARZ_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_KOMISARZ, COMM_SHOP_PAGE_OFFICE_KOMISARZ_WELCOME);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_KOMISARZ, COMM_SHOP_PAGE_OFFICE_KOMISARZ_DINO_INTRO);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_KOMISARZ, COMM_SHOP_PAGE_OFFICE_KOMISARZ_ARCH_ACCOLADE);

		pageOfficeUnlockPerson(FACE_ID_ARCH);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_ARCH, COMM_SHOP_PAGE_OFFICE_ARCH_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_ARCH, COMM_SHOP_PAGE_OFFICE_ARCH_WELCOME);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_ARCH, COMM_SHOP_PAGE_OFFICE_ARCH_PLAN_FAIL);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_ARCH, COMM_SHOP_PAGE_OFFICE_ARCH_ACCOLADE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_ARCH, COMM_SHOP_PAGE_OFFICE_ARCH_GATE_OPENED_DINO_INCOMPLETE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_ARCH, COMM_SHOP_PAGE_OFFICE_ARCH_GATE_OPENED_DINO_COMPLETE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_ARCH, COMM_SHOP_PAGE_OFFICE_ARCH_GATE_DESTROYED);

		pageOfficeUnlockPerson(FACE_ID_PRISONER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_WELCOME);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_GATE_DESTROYED);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_1);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_2);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_3);

		pageOfficeUnlockPerson(FACE_ID_AGENT);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_WELCOME);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_SCIENTISTS);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_SELL_CRATES);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_ALL_CRATES);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_ESCAPE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_EPILOGUE);

		pageOfficeUnlockPerson(FACE_ID_SCIENTIST);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_WELCOME);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_FIRST_CRATE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_CRATE_TELEPORTER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_ALL_CRATES);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_ESCAPE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_EPILOGUE);

		pageOfficeUnlockPerson(FACE_ID_CRYO);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_CRYO, COMM_SHOP_PAGE_OFFICE_CRYO_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_CRYO, COMM_SHOP_PAGE_OFFICE_CRYO_TRAMIEL);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_CRYO, COMM_SHOP_PAGE_OFFICE_CRYO_CONSOLE);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_CRYO, COMM_SHOP_PAGE_CRYO_SUCCESS);

		pageOfficeUnlockPerson(FACE_ID_JAY);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_JAY, COMM_SHOP_PAGE_JAY_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_JAY, COMM_SHOP_PAGE_JAY_CONGRATS);
	}
	else if(keyUse(KEY_1)) {
		inventorySetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, BASE_ID_GROUND, INVENTORY_LEVEL_PLATFORM_ALL);
		inventorySetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, BASE_ID_DINO, INVENTORY_LEVEL_PLATFORM_ALL);
		inventorySetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, BASE_ID_GATE, INVENTORY_LEVEL_PLATFORM_ALL);
		inventorySetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, BASE_ID_WESTERN, INVENTORY_LEVEL_PLATFORM_ALL);
	}
	else if(keyUse(KEY_2)) {
		g_pVehicles[0].lCash -= 50;
		protestsProcess();
	}
	else if(keyUse(KEY_3)) {
		dinoAddBone();
	}
	else if(keyUse(KEY_4)) {
		questCrateSetCapsuleState(CAPSULE_STATE_FOUND);
	}
	else if(keyUse(KEY_5)) {
		g_pVehicles[0].lCash = 50000;
		g_pVehicles[0].wHullCurr = inventoryGetPartDef(INVENTORY_PART_HULL)->uwMax;
		protestsProcess();
	}
	else if(keyUse(KEY_6)) {
		questCrateAdd();
	}
	else if(keyUse(KEY_7)) {
		hudShowMessage(FACE_ID_KRYSTYNA, g_pMsgs[MSG_HUD_GUEST]);
		inboxPushBack(COMM_SHOP_PAGE_OFFICE_ARCH_PLAN_FAIL, 0);
	}
	else if(keyUse(KEY_8)) {
		g_pVehicles[0].lCash += 1000;
		protestsProcess();
	}
	else if(keyUse(KEY_9)) {
		questGateAddFragment();
	}
	else if(keyUse(KEY_MINUS)) {
		gameElapseDay();
	}
	else if(keyUse(KEY_EQUALS)) {
		hudShowMessage(FACE_ID_URZEDAS, g_pMsgs[MSG_HUD_NEW_PLAN]);
		warehouseNextPlan(NEXT_PLAN_REASON_FULFILLED);
	}
	else if(keyUse(KEY_0)) {
		heatTryReduce(5);
	}
#endif
}

static UWORD gameGetCameraDestinationY(void) {
	UWORD uwCamDestY;
	if(g_is2pPlaying && vehiclesAreClose()) {
		uwCamDestY = (
			fix16_to_int(g_pVehicles[0].fY) +
			fix16_to_int(g_pVehicles[1].fY) + VEHICLE_HEIGHT
		) / 2;
	}
	else if(g_is2pPlaying && s_eCameraType == CAMERA_TYPE_P2) {
		uwCamDestY = fix16_to_int(g_pVehicles[1].fY) + VEHICLE_HEIGHT / 2;
	}
	else {
		uwCamDestY = fix16_to_int(g_pVehicles[0].fY) + VEHICLE_HEIGHT / 2;
	}
	return uwCamDestY;
}

static UBYTE s_ubGateCutsceneCooldown;
static UBYTE s_ubGateCutsceneColorIndex;
static UBYTE s_ubGateCutsceneItemIndex;
static UBYTE s_ubGateCutsceneUpdateCount;

static void gameSetMusic(UBYTE isEnabled) {
	s_isMusicEnabled = isEnabled;
	if(!isEnabled) {
		ptplayerEnableMusic(0);
	}
	else if(!s_ubMusicCooldown) {
		ptplayerEnableMusic(1);
	}
}

static UBYTE gameProcessGateCutscene(void) {
	if(s_eGateCutsceneStep == GATE_CUTSCENE_STEP_OFF) {
		return 0;
	}

	switch(s_eGateCutsceneStep) {
		case GATE_CUTSCENE_TELEPORT_STEP_START:
			s_ubGateCutsceneCooldown = 0;
			++s_eGateCutsceneStep;
			break;
		case GATE_CUTSCENE_TELEPORT_STEP_WAIT_FOR_FADE_START:
			if(++s_ubGateCutsceneCooldown > 100) {
				s_ubGateCutsceneCooldown = 0;
				fadeMorphTo(FADE_STATE_OUT, 0);
				++s_eGateCutsceneStep;
			}
			break;
		case GATE_CUTSCENE_TELEPORT_STEP_FADE_OUT:
			if(fadeGetState() == FADE_STATE_OUT) {
				vehicleSetPos(&g_pVehicles[0], 64, 216 * TILE_SIZE);
				vehicleSetPos(&g_pVehicles[1], 160, 216 * TILE_SIZE);
				++s_eGateCutsceneStep;
			}
			break;
		case GATE_CUTSCENE_TELEPORT_STEP_FADE_IN:
			if(fadeGetState() == FADE_STATE_IN) {
				++s_eGateCutsceneStep;
			}
			break;
		case GATE_CUTSCENE_TELEPORT_STEP_WAIT_FOR_GATE_DRAW:
			if(++s_ubGateCutsceneCooldown > 100) {
				s_ubGateCutsceneCooldown = 0;
				// TODO: remove pending questioning msgs
				if(questGateIsPrisonerFound()) {
					inboxPushBack(COMM_SHOP_PAGE_PRISONER_GATE_PLEA, 1);
				}
				if(dinoIsQuestStarted()) {
					inboxPushBack(COMM_SHOP_PAGE_ARCH_GATE_PLEA, 1);
				}

				if(!pageQuestioningIsReported(QUESTIONING_BIT_GATE)) {
					inboxPushBack(COMM_SHOP_PAGE_GATE_DILEMMA, 1);
					statePush(g_pGameStateManager, &g_sStateShop);
					++s_eGateCutsceneStep;
				}
				else {
					gsMsgInit(FACE_ID_KOMISARZ, "gate_opening", g_pMsgs[MSG_KOMISARZ_GATE_OPENING]);
					statePush(g_pGameStateManager, &g_sStateMsg);
					gameTriggerCutscene(GAME_CUTSCENE_GATE_OPEN);
					// Don't push step here bacause cutscene trigger changes it already
				}
				return 1;
			}
			break;
		case GATE_CUTSCENE_OPEN_STEP_START:
			++s_eGateCutsceneStep;
			s_ubGateCutsceneCooldown = 0;
			// TODO: disable movement
			// TODO: disable context menu
			// TODO: disable entering pause
			gameSetMusic(0);
			break;
		case GATE_CUTSCENE_OPEN_STEP_WAIT_FOR_SHAKE:
			if(++s_ubGateCutsceneCooldown > 30) {
				s_ubGateCutsceneCooldown = 0;
				++s_eGateCutsceneStep;
				s_isCameraShake = 1;
				audioMixerPlaySfx(g_pSfxQuake, SFX_CHANNEL_QUAKE, SFX_PRIORITY_QUAKE, 1);
			}
			break;
		case GATE_CUTSCENE_OPEN_STEP_SHAKE_BEFORE_LIGHTS:
			if(++s_ubGateCutsceneCooldown > 80) {
				s_ubGateCutsceneCooldown = 0;
				++s_eGateCutsceneStep;
				s_ubGateCutsceneUpdateCount = 0;
				s_ubGateCutsceneColorIndex = 21;
				s_ubGateCutsceneItemIndex = 0;
				audioMixerPlaySfx(g_pSfxRune, SFX_CHANNEL_RUNE, SFX_PRIORITY_RUNE, 0);
			}
			break;
		case GATE_CUTSCENE_OPEN_STEP_LIGHTS_BEFORE_TWIST:
			++s_ubGateCutsceneCooldown;
			if(s_ubGateCutsceneCooldown == 2) {
				s_ubGateCutsceneUpdateCount = 2;
			}
			else if(s_ubGateCutsceneCooldown > 2) {
				if(s_ubGateCutsceneUpdateCount-- > 0) {
					static const tUbCoordYX pPixels[16][20] = {
						[0] = {
							{.ubX = 96 + 7, .ubY = 95 + 0}, {.ubX = 96 + 7, .ubY = 95 + 1},
							{.ubX = 96 + 8, .ubY = 95 + 1}, {.ubX = 96 + 8, .ubY = 95 + 2},
							{.ubX = 96 + 8, .ubY = 95 + 3}, {.ubX = 96 + 7, .ubY = 95 + 3},
							{.ubX = 96 + 5, .ubY = 95 + 4}, {.ubX = 96 + 5, .ubY = 95 + 5},
							{.ubX = 96 + 9, .ubY = 95 + 4}, {.ubX = 96 + 9, .ubY = 95 + 5},
							{.uwYX = 0}
						},
						[1] = {
							{.ubX = 110 + 8, .ubY = 85 + 5}, {.ubX = 110 + 6, .ubY = 85 + 6},
							{.ubX = 110 + 8, .ubY = 85 + 6}, {.ubX = 110 + 8, .ubY = 85 + 7},
							{.ubX = 110 + 8, .ubY = 85 + 8}, {.ubX = 110 + 8, .ubY = 85 + 9},
							{.ubX = 110 + 8, .ubY = 85 + 10},
							{.uwYX = 0}
						},
						[2] = {
							{.ubX = 120 + 6, .ubY = 74 + 5}, {.ubX = 120 + 7, .ubY = 74 + 5},
							{.ubX = 120 + 5, .ubY = 74 + 6}, {.ubX = 120 + 6, .ubY = 74 + 6},
							{.ubX = 120 + 5, .ubY = 74 + 7}, {.ubX = 120 + 6, .ubY = 74 + 7},
							{.ubX = 120 + 7, .ubY = 74 + 7}, {.ubX = 120 + 6, .ubY = 74 + 8},
							{.ubX = 120 + 7, .ubY = 74 + 8}, {.ubX = 120 + 8, .ubY = 74 + 9},
							{.ubX = 120 + 8, .ubY = 74 + 10}, {.ubX = 120 + 9, .ubY = 74 + 10},
							{.uwYX = 0}
						},
						[3] = {
							{.ubX = 127 + 6, .ubY = 61 + 5}, {.ubX = 127 + 7, .ubY = 61 + 5},
							{.ubX = 127 + 4, .ubY = 61 + 6}, {.ubX = 127 + 5, .ubY = 61 + 6},
							{.ubX = 127 + 4, .ubY = 61 + 7}, {.ubX = 127 + 5, .ubY = 61 + 7},
							{.ubX = 127 + 7, .ubY = 61 + 7}, {.ubX = 127 + 5, .ubY = 61 + 8},
							{.ubX = 127 + 6, .ubY = 61 + 8}, {.ubX = 127 + 7, .ubY = 61 + 8},
							{.ubX = 127 + 6, .ubY = 61 + 9}, {.ubX = 127 + 6, .ubY = 61 + 10},
							{.uwYX = 0}
						},
						[4] = {
							{.ubX = 127 + 4, .ubY = 44 + 8}, {.ubX = 127 + 5, .ubY = 44 + 8},
							{.ubX = 127 + 6, .ubY = 44 + 8}, {.ubX = 127 + 7, .ubY = 44 + 8},
							{.ubX = 127 + 4, .ubY = 44 + 9}, {.ubX = 127 + 3, .ubY = 44 + 10},
							{.ubX = 127 + 3, .ubY = 44 + 11}, {.ubX = 127 + 6, .ubY = 44 + 11},
							{.ubX = 127 + 9, .ubY = 44 + 11}, {.ubX = 127 + 9, .ubY = 44 + 12},
							{.ubX = 127 + 4, .ubY = 44 + 13}, {.ubX = 127 + 5, .ubY = 44 + 13},
							{.ubX = 127 + 7, .ubY = 44 + 13}, {.ubX = 127 + 8, .ubY = 44 + 13},
							{.uwYX = 0}
						},
						[5] = {
							{.ubX = 120 + 8, .ubY = 29 + 9}, {.ubX = 120 + 9, .ubY = 29 + 9},
							{.ubX = 120 + 7, .ubY = 29 + 10}, {.ubX = 120 + 8, .ubY = 29 + 10},
							{.ubX = 120 + 9, .ubY = 29 + 10}, {.ubX = 120 + 6, .ubY = 29 + 11},
							{.ubX = 120 + 5, .ubY = 29 + 12}, {.ubX = 120 + 5, .ubY = 29 + 13},
							{.ubX = 120 + 7, .ubY = 29 + 13}, {.ubX = 120 + 8, .ubY = 29 + 13},
							{.ubX = 120 + 8, .ubY = 29 + 14},
							{.uwYX = 0}
						},
						[6] = {
							{.ubX = 113 + 3, .ubY = 20 + 8}, {.ubX = 113 + 4, .ubY = 20 + 8},
							{.ubX = 113 + 5, .ubY = 20 + 8}, {.ubX = 113 + 6, .ubY = 20 + 8},
							{.ubX = 113 + 3, .ubY = 20 + 9}, {.ubX = 113 + 2, .ubY = 20 + 10},
							{.ubX = 113 + 2, .ubY = 20 + 11}, {.ubX = 113 + 5, .ubY = 20 + 11},
							{.ubX = 113 + 8, .ubY = 20 + 11}, {.ubX = 113 + 8, .ubY = 20 + 12},
							{.ubX = 113 + 3, .ubY = 20 + 13}, {.ubX = 113 + 4, .ubY = 20 + 13},
							{.ubX = 113 + 6, .ubY = 20 + 13}, {.ubX = 113 + 7, .ubY = 20 + 13},
							{.uwYX = 0}
						},
						[7] = {
							{.ubX = 96 + 8, .ubY = 17 + 5}, {.ubX = 96 + 9, .ubY = 17 + 5},
							{.ubX = 96 + 7, .ubY = 17 + 6}, {.ubX = 96 + 8, .ubY = 17 + 6},
							{.ubX = 96 + 9, .ubY = 17 + 6}, {.ubX = 96 + 6, .ubY = 17 + 7},
							{.ubX = 96 + 5, .ubY = 17 + 8}, {.ubX = 96 + 5, .ubY = 17 + 9},
							{.ubX = 96 + 7, .ubY = 17 + 9}, {.ubX = 96 + 8, .ubY = 17 + 9},
							{.ubX = 96 + 8, .ubY = 17 + 10},
							{.uwYX = 0}
						},
						[8] = {
							{.ubX = 78 + 9, .ubY = 17 + 4}, {.ubX = 78 + 10, .ubY = 17 + 4},
							{.ubX = 78 + 8, .ubY = 17 + 5}, {.ubX = 78 + 9, .ubY = 17 + 5},
							{.ubX = 78 + 8, .ubY = 17 + 6}, {.ubX = 78 + 9, .ubY = 17 + 6},
							{.ubX = 78 + 10, .ubY = 17 + 6}, {.ubX = 78 + 9, .ubY = 17 + 7},
							{.ubX = 78 + 10, .ubY = 17 + 7}, {.ubX = 78 + 11, .ubY = 17 + 8},
							{.ubX = 78 + 11, .ubY = 17 + 9}, {.ubX = 78 + 12, .ubY = 17 + 9},
							{.uwYX = 0}
						},
						[9] = {
							{.ubX = 64 + 9, .ubY = 20 + 7}, {.ubX = 64 + 13, .ubY = 20 + 7},
							{.ubX = 64 + 10, .ubY = 20 + 8}, {.ubX = 64 + 11, .ubY = 20 + 8},
							{.ubX = 64 + 12, .ubY = 20 + 8}, {.ubX = 64 + 13, .ubY = 20 + 8},
							{.ubX = 64 + 14, .ubY = 20 + 8}, {.ubX = 64 + 10, .ubY = 20 + 9},
							{.ubX = 64 + 9, .ubY = 20 + 10}, {.ubX = 64 + 10, .ubY = 20 + 10},
							{.ubX = 64 + 12, .ubY = 20 + 10}, {.ubX = 64 + 13, .ubY = 20 + 10},
							{.ubX = 64 + 14, .ubY = 20 + 10}, {.ubX = 64 + 9, .ubY = 20 + 11},
							{.ubX = 64 + 12, .ubY = 20 + 11}, {.ubX = 64 + 14, .ubY = 20 + 11},
							{.ubX = 64 + 9, .ubY = 20 + 12}, {.ubX = 64 + 12, .ubY = 20 + 12},
							{.ubX = 64 + 13, .ubY = 20 + 12},
							{.uwYX = 0}
						},
						[10] = {
							{.ubX = 55 + 9, .ubY = 30 + 7}, {.ubX = 55 + 9, .ubY = 30 + 8},
							{.ubX = 55 + 10, .ubY = 30 + 8}, {.ubX = 55 + 10, .ubY = 30 + 9},
							{.ubX = 55 + 10, .ubY = 30 + 10}, {.ubX = 55 + 9, .ubY = 30 + 10},
							{.ubX = 55 + 7, .ubY = 30 + 11}, {.ubX = 55 + 7, .ubY = 30 + 12},
							{.ubX = 55 + 11, .ubY = 30 + 11}, {.ubX = 55 + 11, .ubY = 30 + 12},
							{.uwYX = 0}
						},
						[11] = {
							{.ubX = 52 + 6, .ubY = 44 + 6}, {.ubX = 52 + 7, .ubY = 44 + 6},
							{.ubX = 52 + 5, .ubY = 44 + 7}, {.ubX = 52 + 6, .ubY = 44 + 7},
							{.ubX = 52 + 5, .ubY = 44 + 8}, {.ubX = 52 + 6, .ubY = 44 + 8},
							{.ubX = 52 + 7, .ubY = 44 + 8}, {.ubX = 52 + 6, .ubY = 44 + 9},
							{.ubX = 52 + 7, .ubY = 44 + 9}, {.ubX = 52 + 8, .ubY = 44 + 10},
							{.ubX = 52 + 8, .ubY = 44 + 11}, {.ubX = 52 + 9, .ubY = 44 + 11},
							{.uwYX = 0}
						},
						[12] = {
							{.ubX = 52 + 4, .ubY = 62 + 4}, {.ubX = 52 + 8, .ubY = 62 + 4},
							{.ubX = 52 + 5, .ubY = 62 + 5}, {.ubX = 52 + 6, .ubY = 62 + 5},
							{.ubX = 52 + 7, .ubY = 62 + 5}, {.ubX = 52 + 8, .ubY = 62 + 5},
							{.ubX = 52 + 9, .ubY = 62 + 5}, {.ubX = 52 + 5, .ubY = 62 + 6},
							{.ubX = 52 + 4, .ubY = 62 + 7}, {.ubX = 52 + 5, .ubY = 62 + 7},
							{.ubX = 52 + 7, .ubY = 62 + 7}, {.ubX = 52 + 8, .ubY = 62 + 7},
							{.ubX = 52 + 9, .ubY = 62 + 7}, {.ubX = 52 + 4, .ubY = 62 + 8},
							{.ubX = 52 + 7, .ubY = 62 + 8}, {.ubX = 52 + 9, .ubY = 62 + 8},
							{.ubX = 52 + 4, .ubY = 62 + 9}, {.ubX = 52 + 7, .ubY = 62 + 9},
							{.ubX = 52 + 8, .ubY = 62 + 9},
							{.uwYX = 0}
						},
						[13] = {
							{.ubX = 55 + 10, .ubY = 75 + 4}, {.ubX = 55 + 10, .ubY = 75 + 5},
							{.ubX = 55 + 11, .ubY = 75 + 5}, {.ubX = 55 + 11, .ubY = 75 + 6},
							{.ubX = 55 + 11, .ubY = 75 + 7}, {.ubX = 55 + 10, .ubY = 75 + 7},
							{.ubX = 55 + 8, .ubY = 75 + 8}, {.ubX = 55 + 8, .ubY = 75 + 9},
							{.ubX = 55 + 12, .ubY = 75 + 8}, {.ubX = 55 + 12, .ubY = 75 + 9},
							{.uwYX = 0}
						},
						[14] = {
							{.ubX = 59 + 14, .ubY = 85 + 4}, {.ubX = 59 + 15, .ubY = 85 + 4},
							{.ubX = 59 + 16, .ubY = 85 + 5}, {.ubX = 59 + 17, .ubY = 85 + 5},
							{.ubX = 59 + 14, .ubY = 85 + 6}, {.ubX = 59 + 15, .ubY = 85 + 6},
							{.ubX = 59 + 16, .ubY = 85 + 6}, {.ubX = 59 + 17, .ubY = 85 + 6},
							{.ubX = 59 + 17, .ubY = 85 + 7}, {.ubX = 59 + 15, .ubY = 85 + 8},
							{.ubX = 59 + 16, .ubY = 85 + 8}, {.ubX = 59 + 14, .ubY = 85 + 9},
							{.ubX = 59 + 15, .ubY = 85 + 9}, {.ubX = 59 + 16, .ubY = 85 + 9},
							{.uwYX = 0}
						},
						[15] = {
							{.ubX = 79 + 8, .ubY = 92 + 3}, {.ubX = 79 + 9, .ubY = 92 + 3},
							{.ubX = 79 + 10, .ubY = 92 + 3}, {.ubX = 79 + 11, .ubY = 92 + 3},
							{.ubX = 79 + 8, .ubY = 92 + 4}, {.ubX = 79 + 7, .ubY = 92 + 5},
							{.ubX = 79 + 7, .ubY = 92 + 6}, {.ubX = 79 + 10, .ubY = 92 + 6},
							{.ubX = 79 + 13, .ubY = 92 + 6}, {.ubX = 79 + 13, .ubY = 92 + 7},
							{.ubX = 79 + 8, .ubY = 92 + 8}, {.ubX = 79 + 9, .ubY = 92 + 8},
							{.ubX = 79 + 11, .ubY = 92 + 8}, {.ubX = 79 + 12, .ubY = 92 + 8},
							{.uwYX = 0}
						},
					};

					UWORD uwDestY = (GATE_DEPTH_PX & (512 - 1));
					for(UBYTE i = 0; i < 20; ++i) {
						if(pPixels[s_ubGateCutsceneItemIndex][i].uwYX == 0) {
							break;
						}

						chunkyToPlanar(
							s_ubGateCutsceneColorIndex,
							32 + pPixels[s_ubGateCutsceneItemIndex][i].ubX,
							uwDestY + pPixels[s_ubGateCutsceneItemIndex][i].ubY,
							g_pMainBuffer->pScroll->pBack
						);
					}
				}
				else {
					s_ubGateCutsceneCooldown = 0;
					if(++s_ubGateCutsceneColorIndex > 25) {
						if(++s_ubGateCutsceneItemIndex >= 16) {
							++s_eGateCutsceneStep;
							twisterEnable();
							audioMixerPlaySfx(g_pSfxGate, SFX_CHANNEL_GATE, SFX_PRIORITY_GATE, 1);
						}
						else {
							audioMixerPlaySfx(g_pSfxRune, SFX_CHANNEL_RUNE, SFX_PRIORITY_RUNE, 0);
						}
						s_ubGateCutsceneColorIndex = 21;
					}
				}
			}
			break;
		case GATE_CUTSCENE_OPEN_STEP_TWIST_BEFORE_FADE:
			if(++s_ubGateCutsceneCooldown > 200) {
				s_ubGateCutsceneCooldown = 0;
				fadeMorphTo(FADE_STATE_OUT, 0);
				++s_eGateCutsceneStep;
			}
			break;
		case GATE_CUTSCENE_OPEN_STEP_FADE_OUT:
			if(fadeGetState() == FADE_STATE_OUT) {
				const tBase *pBaseGround = baseGetById(BASE_ID_GROUND);
				vehicleSetPos(&g_pVehicles[0], pBaseGround->sPosTeleport.uwX, pBaseGround->sPosTeleport.uwY);
				vehicleSetPos(&g_pVehicles[1], pBaseGround->sPosTeleport.uwX, pBaseGround->sPosTeleport.uwY);
				s_isCameraShake = 0;
				audioMixerStopSfxOnChannel(SFX_CHANNEL_QUAKE);
				audioMixerStopSfxOnChannel(SFX_CHANNEL_GATE);
				twisterDisable();
				++s_eGateCutsceneStep;
			}
			break;
		case GATE_CUTSCENE_OPEN_STEP_FADE_IN:
			if(fadeGetState() == FADE_STATE_IN) {
				gameSetMusic(1);
				++s_eGateCutsceneStep;
				if(dinoIsQuestStarted()) {
					if(dinoIsAllFound()) {
						inboxPushBack(COMM_SHOP_PAGE_OFFICE_ARCH_GATE_OPENED_DINO_COMPLETE, 0);
					}
					else {
						inboxPushBack(COMM_SHOP_PAGE_OFFICE_ARCH_GATE_OPENED_DINO_INCOMPLETE, 0);
					}
				}
				tCommShopPage ePage = (
					pageQuestioningIsReported(QUESTIONING_BIT_GATE) ?
					COMM_SHOP_PAGE_NEWS_GATE_RED :
					COMM_SHOP_PAGE_NEWS_GATE_ENEMY
				);
				inboxPushBack(ePage, 0);
				statePush(g_pGameStateManager, &g_sStateShop);
				return 1;
			}
			break;

		case GATE_CUTSCENE_DESTROY_STEP_START:
			questGateMarkExploded();
			s_ubGateCutsceneCooldown = 0;
			s_ubGateCutsceneItemIndex = 0;
			++s_eGateCutsceneStep;
			gameSetMusic(0);
			break;
		case GATE_CUTSCENE_DESTROY_STEP_EXPLODING:
		case GATE_CUTSCENE_DESTROY_STEP_FADE_OUT:
			if(++s_ubGateCutsceneCooldown > 10) {
				if(
					s_eGateCutsceneStep == GATE_CUTSCENE_DESTROY_STEP_EXPLODING &&
					++s_ubGateCutsceneItemIndex >= 25
				) {
					fadeMorphTo(FADE_STATE_OUT, 0xFFF);
					++s_eGateCutsceneStep;
				}

				s_ubGateCutsceneItemIndex = MIN(s_ubGateCutsceneItemIndex + 1, 5 * 5);
				s_ubGateCutsceneCooldown = 0;
				UWORD uwAddX = randUwMax(&g_sRand, 90);
				UWORD uwAddY = randUwMax(&g_sRand, 90);
				flipbookAdd(
					32 + 35 + uwAddX, GATE_DEPTH_PX + uwAddY,
					0, 0, 0, FLIPBOOK_KIND_BOOM
				);
			}

			if (s_eGateCutsceneStep == GATE_CUTSCENE_DESTROY_STEP_FADE_OUT) {
				if(fadeGetState() == FADE_STATE_OUT) {
					baseProcess();
					groundLayerReset(groundLayerGetLowerAtDepth(g_pMainBuffer->pCamera->uPos.uwY), fadeGetSecondaryColor());
					tileBufferRedrawAll(g_pMainBuffer);
					bobDiscardUndraw();
					fadeMorphTo(FADE_STATE_IN, 0xFFF);

					++s_eGateCutsceneStep;
				}
			}
			break;
		case GATE_CUTSCENE_DESTROY_STEP_FADE_IN:
			if(fadeGetState() == FADE_STATE_IN) {
				++s_eGateCutsceneStep;

				if(questGateIsPrisonerFound()) {
					pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, COMM_SHOP_PAGE_OFFICE_PRISONER_GATE_DESTROYED);
					inboxPushBack(COMM_SHOP_PAGE_OFFICE_PRISONER_GATE_DESTROYED, 1);
				}
				if(pageOfficeHasPerson(FACE_ID_ARCH)) {
					inboxPushBack(COMM_SHOP_PAGE_OFFICE_ARCH_GATE_DESTROYED, 1);
					gameAddRebuke(REBUKE_GATE_DESTROYED);
				}

				if(inboxGetState() == INBOX_STATE_URGENT) {
					statePush(g_pGameStateManager, &g_sStateShop);
					return 1;
				}
			}
			break;

		case GATE_CUTSCENE_DESTROY_STEP_END:
			gameSetMusic(1);
			[[fallthrough]];
		case GATE_CUTSCENE_OPEN_STEP_OPEN_END:
		case GATE_CUTSCENE_STEP_OFF:
		case GATE_CUTSCENE_TELEPORT_STEP_END:
			s_eGateCutsceneStep = GATE_CUTSCENE_STEP_OFF;
			break;
	}
	return 0;
}

static void gameCameraProcess(void) {
	if(g_eGameMode == GAME_MODE_CHALLENGE) {
		const UWORD uwBottomPos = g_pMainBuffer->pCamera->uPos.uwY + g_pMainBuffer->sCommon.pVPort->uwHeight - 2 * TILE_SIZE;
		if(
			g_pVehicles[0].sBobBody.sPos.uwY >  uwBottomPos ||
			(g_is2pPlaying && g_pVehicles[1].sBobBody.sPos.uwY > uwBottomPos)
		) {
			g_pMainBuffer->pCamera->uPos.uwY += 1;
		}
		else {
			++s_ubChallengeCamCnt;
			if(s_ubChallengeCamCnt >= 3) {
				g_pMainBuffer->pCamera->uPos.uwY += 1;
				s_ubChallengeCamCnt = 0;
			}
		}
	}
	else {
		UWORD uwCamDestX = 32;
		UWORD uwCamDestY = gameGetCameraDestinationY();
		WORD wCameraDistance = (
			uwCamDestY - g_pMainBuffer->pCamera->sCommon.pVPort->uwHeight / 2
		) - g_pMainBuffer->pCamera->uPos.uwY;
		UWORD uwAbsDistance = ABS(wCameraDistance);
		if(uwAbsDistance > CAMERA_SPEED * 50 && fadeGetState() == FADE_STATE_IN) {
			fadeMorphTo(FADE_STATE_OUT, 0);
		}

		if(uwAbsDistance > CAMERA_SPEED) {
			cameraMoveBy(g_pMainBuffer->pCamera, 0, SGN(wCameraDistance) * CAMERA_SPEED);
		}
		else {
			cameraMoveBy(g_pMainBuffer->pCamera, 0, wCameraDistance);
		}
		g_pMainBuffer->pCamera->uPos.uwX = uwCamDestX;

		if(fadeGetState() == FADE_STATE_OUT) {
			cameraCenterAt(g_pMainBuffer->pCamera, uwCamDestX, uwCamDestY);
			g_pMainBuffer->pCamera->uPos.uwX = uwCamDestX;
			baseProcess();
			groundLayerReset(groundLayerGetLowerAtDepth(g_pMainBuffer->pCamera->uPos.uwY), fadeGetSecondaryColor());
			tileBufferRedrawAll(g_pMainBuffer);
			bobDiscardUndraw();
			g_pMainBuffer->pCamera->uPos.uwX = uwCamDestX;
			fadeMorphTo(FADE_STATE_IN, 0);
		}

		if(s_isCameraShake) {
			BYTE bShake = (randUw(&g_sRand) & 0b11) - 2;
			cameraMoveBy(g_pMainBuffer->pCamera, 0, bShake);
		}
	}
}

static void onSongEnd(void) {
	if(++s_ubCurrentMod >= ASSETS_GAME_MOD_COUNT) {
		s_ubCurrentMod = 0;
	}
	logWrite("Song ended, next: %hhu", s_ubCurrentMod);
	s_ubMusicCooldown = GAME_MUSIC_INTERVAL;
}

static void gameChallengeResult(void) {
	if(!g_is2pPlaying) {
		char szBfr[30];
		snprintf(
			s_szMessageBuffer, GAME_MESSAGE_BUFFER_SIZE, "%s: %ld",
			g_pMsgs[MSG_HI_SCORE_WIN_SCORE], g_pVehicles[0].lCash
		);
		hiScoreSetup(g_pVehicles[0].lCash, szBfr, SCORE_MODE_CHALLENGE);
		menuGsEnter(1);
	}
	else {
		// No entering hi score for 2 players, just summary who wins
		const char *pMsg;
		if(g_pVehicles[0].lCash > g_pVehicles[1].lCash) {
			pMsg = g_pMsgs[MSG_HI_SCORE_WIN_P1];
		}
		else if(g_pVehicles[0].lCash < g_pVehicles[1].lCash) {
			pMsg = g_pMsgs[MSG_HI_SCORE_WIN_P2];
		}
		else {
			pMsg = g_pMsgs[MSG_HI_SCORE_DRAW];
		}
		hiScoreSetup(0, pMsg, SCORE_MODE_CHALLENGE);
		menuGsEnter(1);
	}
}

static void gameDeadlineResult(void) {
	char szBfr[30];
	snprintf(
		s_szMessageBuffer, GAME_MESSAGE_BUFFER_SIZE, "%s: %ld",
		g_pMsgs[MSG_HI_SCORE_WIN_SCORE], g_pVehicles[0].lCash
	);
	achievementUnlock(ACHIEVEMENT_DEADLINE);
	hiScoreSetup(g_pVehicles[0].lCash, szBfr, SCORE_MODE_DEADLINE);
	menuGsEnter(1);
}

static void gameProcessPlan(void) {
	if(g_eGameMode == GAME_MODE_DEADLINE) {
		WORD wRemainingDays = planGetRemainingDays();
		if(wRemainingDays <= 0) {
			g_pVehicles[0].isChallengeEnded = 1;
		}
		else if(wRemainingDays == 10 || wRemainingDays == 5 || wRemainingDays == 3) {
			if(wRemainingDays != s_wLastReminder) {
				s_wLastReminder = wRemainingDays;
				hudShowMessage(FACE_ID_SCIENTIST, g_pMsgs[MSG_HUD_DEADLINE_REMAINING]);
			}
		}
		else {
			s_wLastReminder = 0;
		}
		hudSetTime(wRemainingDays);
	}
	else if(g_eGameMode == GAME_MODE_STORY) {
		if(!planManagerGet()->isPlanActive) {
			return;
		}

		WORD wRemainingDays = planGetRemainingDays();
		if(wRemainingDays <= 0) {
			if(!planManagerGet()->isExtendedTimeByBribe && planTryProlong()) {
				hudShowMessageVa(FACE_ID_URZEDAS, g_pMsgs[MSG_HUD_PLAN_EXTENDING], 14);
			}
			else {
				hudShowMessage(FACE_ID_KRYSTYNA, g_pMsgs[MSG_HUD_WAITING_KOMISARZ]);
				gameAddRebuke(REBUKE_PLAN_1);
				planFailDeadline();
			}
		}
		else if(wRemainingDays == 10 || wRemainingDays == 3) {
			if(wRemainingDays != s_wLastReminder) {
				s_wLastReminder = wRemainingDays;
				hudShowMessageVa(FACE_ID_URZEDAS, g_pMsgs[MSG_HUD_PLAN_REMAINING], wRemainingDays);
			}
		}
		else {
			s_wLastReminder = 0;
		}
	}
}

static void gameSaveSummary(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_SUMMARY);
	tGameSummary sSummary = {
		.lCash = g_pVehicles[0].lCash,
		.ubAccolades = s_ubAccolades,
		.ubHeatPercent = heatGetPercent(),
		.ubPlanIndex = planManagerGet()->ubCurrentPlanIndex,
		.ubRebukes = s_ubRebukeCount,
		.ulGameTime = s_ulGameTime,
		.uwMaxDepth = s_uwMaxTileY,
	};

	fileWrite(pFile, &sSummary.ulGameTime, sizeof(sSummary.ulGameTime));
	fileWrite(pFile, &sSummary.lCash, sizeof(sSummary.lCash));
	fileWrite(pFile, &sSummary.uwMaxDepth, sizeof(sSummary.uwMaxDepth));
	fileWrite(pFile, &sSummary.ubRebukes, sizeof(sSummary.ubRebukes));
	fileWrite(pFile, &sSummary.ubAccolades, sizeof(sSummary.ubAccolades));
	fileWrite(pFile, &sSummary.ubHeatPercent, sizeof(sSummary.ubHeatPercent));
	fileWrite(pFile, &sSummary.ubPlanIndex, sizeof(sSummary.ubPlanIndex));
	saveWriteTag(pFile, SAVE_TAG_SUMMARY_END);
}

static void gameSave(tFile *pFile) {
	gameSaveSummary(pFile);
	saveWriteTag(pFile, SAVE_TAG_GAME);
	fileWrite(pFile, &g_is2pPlaying, sizeof(g_is2pPlaying));
	fileWrite(pFile, &g_eGameMode, sizeof(g_eGameMode));
	fileWrite(pFile, &g_isAtari, sizeof(g_isAtari));
	fileWrite(pFile, &g_isSokoUnlock, sizeof(g_isSokoUnlock));

	fileWrite(pFile, &s_sTeleportReturn.ulYX, sizeof(s_sTeleportReturn.ulYX));
	fileWrite(pFile, &s_eCameraType, sizeof(s_eCameraType));
	fileWrite(pFile, &s_ubChallengeCamCnt, sizeof(s_ubChallengeCamCnt));

	fileWrite(pFile, &s_ubRebukeCount, sizeof(s_ubRebukeCount));
	fileWrite(pFile, s_pRebukes, sizeof(s_pRebukes));
	fileWrite(pFile, &s_ubAccolades, sizeof(s_ubAccolades));
	fileWrite(pFile, &s_ubAccoladesFract, sizeof(s_ubAccoladesFract));
	fileWrite(pFile, &s_wLastReminder, sizeof(s_wLastReminder));
	fileWrite(pFile, &s_ubCurrentMod, sizeof(s_ubCurrentMod));
	fileWrite(pFile, &s_ulGameTime, sizeof(s_ulGameTime));
	fileWrite(pFile, &s_uwMaxTileY, sizeof(s_uwMaxTileY));

	inboxSave(pFile);
	dinoSave(pFile);
	questGateSave(pFile);
	questCrateSave(pFile);
	tutorialSave(pFile);
	pageOfficeSave(pFile);
	warehouseSave(pFile);
	tileSave(pFile);
	protestsSave(pFile);
	inventorySave(pFile);
	vehicleSave(&g_pVehicles[0], pFile);
	vehicleSave(&g_pVehicles[1], pFile);
	hudSave(pFile);
	heatSave(pFile);
	saveWriteTag(pFile, SAVE_TAG_GAME_END);
}

//------------------------------------------------------------------- PUBLIC FNS

#define RADIO_MESSAGE_COUNT 3
#define RADIO_MESSAGE_INTERVAL 150

static UBYTE s_ubRadioMessageCounter;
static UBYTE s_ubRadioMessageIndex = 0;

void gameProcessBaseWestern(void) {
	questCrateProcessBase();
}

void gameProcessBaseGate(void) {
	if(gameIsCutsceneActive()) {
		return;
	}
	if(questGateIsExploded()) {
		return;
	}

	if(
		!vehicleIsInBase(&g_pVehicles[0]) &&
		(!g_is2pPlaying || !vehicleIsInBase(&g_pVehicles[1]))
	) {
		return;
	}

	if(hudIsShowingMessage()) {
		s_ubRadioMessageCounter = RADIO_MESSAGE_INTERVAL;
		return;
	}

	if(s_ubRadioMessageCounter == 0) {
		UBYTE ubFoundCount = questGateGetFoundFragmentCount();
		UBYTE ubMaxCount = questGateGetMaxFragmentCount();
		tMsg eMsgStart;
		tCommShopPage ePrisonerPageUnlock;
		if(ubFoundCount >= (ubMaxCount * 2) / 3) {
			eMsgStart = MSG_HUD_RADIO_FULL_0;
			ePrisonerPageUnlock = COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_3;
		}
		else if(ubFoundCount >= (ubMaxCount * 1) / 3) {
			eMsgStart = MSG_HUD_RADIO_HALF_0;
			ePrisonerPageUnlock = COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_2;
		}
		else {
			eMsgStart = MSG_HUD_RADIO_START_0;
			ePrisonerPageUnlock = COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_1;
		}

		if(questGateIsPrisonerFound()) {
			if(pageOfficeTryUnlockPersonSubpage(FACE_ID_PRISONER, ePrisonerPageUnlock)) {
				inboxPushBack(ePrisonerPageUnlock, 0);
			}
		}
		hudShowMessage(FACE_ID_RADIO, g_pMsgs[eMsgStart + s_ubRadioMessageIndex]);
		if(++s_ubRadioMessageIndex >= RADIO_MESSAGE_COUNT) {
			s_ubRadioMessageIndex = 0;
		}
	}
	else {
		--s_ubRadioMessageCounter;
	}
}

char *gameGetMessageBuffer(void) {
	return s_szMessageBuffer;
}

void gameCancelModeForPlayer(UBYTE ubPlayer) {
	if(!s_pModeMenus[ubPlayer].isActive) {
		g_pVehicles[ubPlayer].eDrillMode = MODE_OPTION_DRILL;
	}
}

void gameAdvanceAccolade(void) {
	if(++s_ubAccoladesFract >= g_ubPlansPerAccolade) {
		s_ubAccoladesFract = 0;
		pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_ACCOLADE);
		inboxPushBack(COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_ACCOLADE, 1);
		gameAddAccolade();
	}
}

void gameAddAccolade(void) {
	++s_ubAccolades;

	if(s_ubAccolades >= g_ubAccoladesInMainStory) {
		if(dinoIsQuestStarted() && !dinoIsAllFound()) {
			inboxPushBack(COMM_SHOP_PAGE_OFFICE_ARCH_PLAN_FAIL, 0);
		}
		inboxPushBack(COMM_SHOP_PAGE_NEWS_ACCOLADES, 0);
	}
}

void gameAddRebuke(tRebukeKind eRebuke) {
	if(s_ubRebukeCount >= REBUKES_MAX) {
		return;
	}

	if(s_ubRebukeCount == REBUKES_MAX - 1) {
		eRebuke = REBUKE_FINAL;
	}
	else if(
		eRebuke == REBUKE_PLAN_1 &&
		(s_pRebukes[0] == REBUKE_PLAN_1 || s_pRebukes[1] == REBUKE_PLAN_2)
	) {
		eRebuke = REBUKE_PLAN_2;
	}
	s_pRebukes[s_ubRebukeCount] = eRebuke;

	tCommShopPage ePage = COMM_SHOP_PAGE_OFFICE_KOMISARZ_REBUKE_1 + s_ubRebukeCount;
	if(pageOfficeTryUnlockPersonSubpage(FACE_ID_KOMISARZ, ePage)) {
		inboxPushBack(ePage, 1);
	}

	++s_ubRebukeCount;
}

UBYTE gameGetAccoladeCount(void) {
	return s_ubAccolades;
}

UBYTE gameGetRebukeCount(void) {
	return s_ubRebukeCount;
}

tRebukeKind gameGetRebuke(UBYTE ubRebukeIndex) {
	return s_pRebukes[ubRebukeIndex];
}

void gameInitBobs(void) {
	UBYTE *pAddressFrame = bobCalcFrameAddress(g_pBombMarker, 0);
	UBYTE *pAddressMask = bobCalcFrameAddress(g_pBombMarkerMask, 0);
	for(UBYTE ubPlayer = 0; ubPlayer < 2; ++ubPlayer) {
		for(UBYTE i = 0; i < 3; ++i) {
			bobInit(
				&s_pPlayerBombMarkers[ubPlayer][i], 16, 10, 1,
				pAddressFrame, pAddressMask, 0, 0
			);
		}
	}

	modeMenuInitBob(&s_pModeMenus[0]);
	modeMenuInitBob(&s_pModeMenus[1]);
}

UBYTE gameIsRangeVisibleOnCamera(UWORD uwStartY, UWORD uwEndY) {
	const tRedrawState *pBufferState = &g_pMainBuffer->pRedrawStates[g_pMainBuffer->ubStateIdx];
	UBYTE isOnCamera = (
		uwStartY >= (((pBufferState->sMarginU.wTilePos + 1) << TILE_SHIFT)) &&
		uwEndY <= ((pBufferState->sMarginD.wTilePos) << TILE_SHIFT)
	);
	return isOnCamera;
}

UBYTE gameCanPushBob(const tBob *pBob) {
	return gameIsRangeVisibleOnCamera(
		pBob->sPos.uwY, pBob->sPos.uwY + pBob->uwHeight
	);
}

UBYTE gameTryPushBob(tBob *pBob) {
	if(gameCanPushBob(pBob)) {
		bobPush(pBob);
		return 1;
	}
	else {
		return 0;
	}
}

void gameElapseTime(UWORD uwTime) {
	if(ULONG_MAX - s_ulGameTime > uwTime) {
		s_ulGameTime += uwTime;
	}
	else {
		s_ulGameTime = ULONG_MAX;
	}

	planElapseTime(uwTime);
	if(!planManagerGet()->isPlanActive && planManagerGet()->wTimeRemaining == 0 && planManagerGet()->ubCurrentPlanIndex > 0) {
		// first plan start (index 0) is handled by tutorial
		hudShowMessage(FACE_ID_URZEDAS, g_pMsgs[MSG_HUD_NEW_PLAN]);
		planStart();
	}
}

void gameElapseDay(void) {
	gameElapseTime(GAME_TIME_PER_DAY);
}

ULONG gameGetTime(void) {
	return s_ulGameTime;
}

UBYTE gameIsElapsedDays(ULONG ulStart, UBYTE ubDays) {
	if(s_ulGameTime - ulStart >= ubDays * GAME_TIME_PER_DAY) {
		return 1;
	}
	return 0;
}

tSteer *gameGetSteers(void) {
	return s_pPlayerSteers;
}

UBYTE gameLoad(tFile *pFile) {
	{
		tGameSummary sSummary; ///< Only for skipping it
		if(!gameLoadSummary(pFile, &sSummary)) {
			return 0;
		}
	}

	if(!saveReadTag(pFile, SAVE_TAG_GAME)) {
		return 0;
	}

	fileRead(pFile, &g_is2pPlaying, sizeof(g_is2pPlaying));
	fileRead(pFile, &g_eGameMode, sizeof(g_eGameMode));
	fileRead(pFile, &g_isAtari, sizeof(g_isAtari));
	fileRead(pFile, &g_isSokoUnlock, sizeof(g_isSokoUnlock));

	fileRead(pFile, &s_sTeleportReturn.ulYX, sizeof(s_sTeleportReturn.ulYX));
	fileRead(pFile, &s_eCameraType, sizeof(s_eCameraType));
	fileRead(pFile, &s_ubChallengeCamCnt, sizeof(s_ubChallengeCamCnt));

	fileRead(pFile, &s_ubRebukeCount, sizeof(s_ubRebukeCount));
	fileRead(pFile, s_pRebukes, sizeof(s_pRebukes));
	fileRead(pFile, &s_ubAccolades, sizeof(s_ubAccolades));
	fileRead(pFile, &s_ubAccoladesFract, sizeof(s_ubAccoladesFract));
	fileRead(pFile, &s_wLastReminder, sizeof(s_wLastReminder));
	fileRead(pFile, &s_ubCurrentMod, sizeof(s_ubCurrentMod));
	fileRead(pFile, &s_ulGameTime, sizeof(s_ulGameTime));
	fileRead(pFile, &s_uwMaxTileY, sizeof(s_uwMaxTileY));

	UBYTE isSuccess = (
		inboxLoad(pFile) &&
		dinoLoad(pFile) &&
		questGateLoad(pFile) &&
		questCrateLoad(pFile) &&
		tutorialLoad(pFile) &&
		pageOfficeLoad(pFile) &&
		warehouseLoad(pFile) &&
		tileLoad(pFile) &&
		protestsLoad(pFile) &&
		inventoryLoad(pFile) &&
		vehicleLoad(&g_pVehicles[0], pFile) &&
		vehicleLoad(&g_pVehicles[1], pFile) &&
		hudLoad(pFile) &&
		heatLoad(pFile) &&
		saveReadTag(pFile, SAVE_TAG_GAME_END)
	);

	if(g_eGameMode == GAME_MODE_DEADLINE) {
		tileVariantChangeTo(TILE_VARIANT_FINISH);
	}
	else {
		tileVariantChangeTo(TILE_VARIANT_CAMPAIGN);
	}
	return isSuccess;
}

UBYTE gameLoadSummary(tFile *pFile, tGameSummary *pSummary) {
	if(!saveReadTag(pFile, SAVE_TAG_SUMMARY)) {
		return 0;
	}

	fileRead(pFile, &pSummary->ulGameTime, sizeof(pSummary->ulGameTime));
	fileRead(pFile, &pSummary->lCash, sizeof(pSummary->lCash));
	fileRead(pFile, &pSummary->uwMaxDepth, sizeof(pSummary->uwMaxDepth));
	fileRead(pFile, &pSummary->ubRebukes, sizeof(pSummary->ubRebukes));
	fileRead(pFile, &pSummary->ubAccolades, sizeof(pSummary->ubAccolades));
	fileRead(pFile, &pSummary->ubHeatPercent, sizeof(pSummary->ubHeatPercent));
	fileRead(pFile, &pSummary->ubPlanIndex, sizeof(pSummary->ubPlanIndex));
	return saveReadTag(pFile, SAVE_TAG_SUMMARY_END);
}

void gameStart(tGameMode eGameMode, tSteer sSteerP1, tSteer sSteerP2) {
	s_isHandlingPause = 0;
	s_ubChallengeCamCnt = 0;
	g_eGameMode = eGameMode;
	s_pPlayerSteers[0] = sSteerP1;
	s_pPlayerSteers[1] = sSteerP2;
	inboxReset();
	dinoReset();
	questGateReset();
	questCrateReset();
	collectiblesReset();
	tutorialReset();
	pageOfficeReset();
	warehouseReset();
	if(g_eGameMode != GAME_MODE_STORY) {
		baseTilesetPrepareForChallenge();
	}
	tileReset(g_isAtari, g_eGameMode);
	inventoryReset();
	protestsReset();
	vehicleReset(&g_pVehicles[0]);
	vehicleReset(&g_pVehicles[1]);
	modeMenuReset(&s_pModeMenus[0], 0);
	modeMenuReset(&s_pModeMenus[1], 1);
	gameResetModePreset(0);
	gameResetModePreset(1);
	s_ulGameTime = 0;
	s_uwMaxTileY = 0;
	s_ubCurrentMod = 0;
	s_ubRebukeCount = 0;
	s_ubAccolades = 0;
	s_ubAccoladesFract = 0;
	s_wLastReminder = 0;
	s_sTeleportReturn.ulYX = -1;
	s_eGateCutsceneStep = GATE_CUTSCENE_STEP_OFF;
	s_ubRadioMessageCounter = RADIO_MESSAGE_INTERVAL;
	hudReset(g_eGameMode, g_is2pPlaying);
	heatReset();
	groundLayerReset(1, 0);
	s_pVpMain = g_pMainBuffer->sCommon.pVPort;
	if(g_eGameMode == GAME_MODE_DEADLINE) {
		tileVariantChangeTo(TILE_VARIANT_FINISH);
	}
	else {
		tileVariantChangeTo(TILE_VARIANT_CAMPAIGN);
	}
}

void gameTriggerSave(void) {
	logWrite("game save");
	systemUse();

	if(diskFileExists("save_story.tmp")) {
		diskFileDelete("save_story.tmp");
	}
	if(diskFileExists("save_deadline.tmp")) {
		diskFileDelete("save_deadline.tmp");
	}

	char *szPathTmp = gameGetMessageBuffer();
	*szPathTmp = '\0';
	char *szPathDat = &gameGetMessageBuffer()[GAME_MESSAGE_BUFFER_SIZE / 2];
	*szPathDat = '\0';
	char *pEndTmp = stringCopy("save_", szPathTmp);
	pEndTmp = stringCopy((g_eGameMode == GAME_MODE_STORY) ? "story" : "deadline", pEndTmp);
	char *pEndDat = stringCopy(szPathTmp, szPathDat);
	pEndTmp = stringCopy(".tmp", pEndTmp);
	pEndDat = stringCopy(".dat", pEndDat);
	tFile *pFileSave = diskFileOpen(szPathTmp, DISK_FILE_MODE_WRITE, 1);
	if(pFileSave) {
		gameSave(pFileSave);
		fileClose(pFileSave);
		diskFileDelete(szPathDat);
		diskFileMove(szPathTmp, szPathDat);
	}
	settingsFileSave();
	systemUnuse();
}

void gameUpdateMaxDepth(UWORD uwTileY) {
	s_uwMaxTileY = MAX(s_uwMaxTileY, uwTileY);
}

UBYTE gameIsCutsceneActive(void) {
	return s_eGateCutsceneStep != GATE_CUTSCENE_STEP_OFF;
}

void gameTriggerCutscene(tGameCutscene eCutscene) {
	switch(eCutscene) {
		case GAME_CUTSCENE_TELEPORT:
			s_eGateCutsceneStep = GATE_CUTSCENE_TELEPORT_STEP_START;
			break;
		case GAME_CUTSCENE_GATE_OPEN:
			s_eGateCutsceneStep = GATE_CUTSCENE_OPEN_STEP_START;
			break;
		case GAME_CUTSCENE_GATE_EXPLODE:
			s_eGateCutsceneStep = GATE_CUTSCENE_DESTROY_STEP_START;
			break;
	}
}

void gameProcessMusicInterval(void) {
	if(s_ubMusicCooldown && s_isMusicEnabled) {
		if(--s_ubMusicCooldown == 0) {
			ptplayerLoadMod(g_pGameMods[s_ubCurrentMod], g_pModSampleData, 0);
			ptplayerEnableMusic(1);
		}
	}
}

//-------------------------------------------------------------------- GAMESTATE

static void gameGsCreate(void) {
	if(s_isHandlingPause) {
		ptplayerEnableMusic(1);
		s_isHandlingPause = 0;
	}
	else {
		ptplayerConfigureSongRepeat(0, onSongEnd);
		s_isMusicEnabled = 1;
		s_ubMusicCooldown = 0;
		ptplayerLoadMod(g_pGameMods[s_ubCurrentMod], g_pModSampleData, 0);
		ptplayerEnableMusic(1);
	}
}

static void gameGsLoop(void) {
	if(tutorialProcess()) {
		return;
	}

	if(g_eGameMode == GAME_MODE_STORY) {
		dinoProcess();
		questGateProcess();
		questCrateProcess();
		UBYTE isGameStateChange = gameProcessGateCutscene();
		if(isGameStateChange) {
			return;
		}
	}

	debugColor(0x080);
	gameCameraProcess();
	if(!gameIsCutsceneActive()) {
		steerProcess(&s_pPlayerSteers[0]);
		steerProcess(&s_pPlayerSteers[1]);
		gameProcessHotkeys();
		UBYTE isGameStateChange = gameProcessSteer(0) | gameProcessSteer(1);
		if(isGameStateChange) {
			return;
		}
		vehicleProcessText();
		gameProcessPlan();
	}

	coreProcessBeforeBobs();
	twisterProcess();
	debugColor(0x088);
	vehicleProcess(&g_pVehicles[0]);
	if(g_is2pPlaying) {
		debugColor(0x880);
		vehicleProcess(&g_pVehicles[1]);
	}
	debugColor(0x808);
	flipbookManagerProcess();
	if(!gameIsCutsceneActive()) {
		baseUnlocksDrawFront();
		modeMenuTryDisplay(&s_pModeMenus[0]);
		modeMenuTryDisplay(&s_pModeMenus[1]);
		gameDisplayModeTnt(0);
		gameDisplayModeTnt(1);
	}
	coreProcessAfterBobs();

	gameProcessMusicInterval();

	if(
		g_pVehicles[0].isChallengeEnded &&
		(!g_is2pPlaying || g_pVehicles[1].isChallengeEnded)
	) {
		vehicleStopLoopAudio(0);
		vehicleStopLoopAudio(1);
		if(g_eGameMode == GAME_MODE_CHALLENGE) {
			gameChallengeResult();
		}
		else {
			gameDeadlineResult();
		}
	}
}

static void gameGsDestroy(void) {
	ptplayerEnableMusic(0);
}

tState g_sStateGame = {
	.cbCreate = gameGsCreate, .cbLoop = gameGsLoop, .cbDestroy = gameGsDestroy
};
