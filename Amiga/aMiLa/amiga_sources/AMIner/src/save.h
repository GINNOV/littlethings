/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef SAVE_H
#define SAVE_H

#include <ace/utils/file.h>
#define SAVE_TAG_SETTINGS_V1 "STG1"
#define SAVE_TAG_SETTINGS_V2 "STG2"
#define SAVE_TAG_SETTINGS_END "STGE"
#define SAVE_TAG_INBOX "INB1"
#define SAVE_TAG_INBOX_END "INBE"
#define SAVE_TAG_ACCOUNTING "ACT1"
#define SAVE_TAG_ACCOUNTING_END "ACTE"
#define SAVE_TAG_BRIBE "BRB1"
#define SAVE_TAG_BRIBE_END "BRBE"
#define SAVE_TAG_OFFICE "OFC1"
#define SAVE_TAG_OFFICE_END "OFCE"
#define SAVE_TAG_QUESTIONING "QTN1"
#define SAVE_TAG_QUESTIONING_END "QTNE"
#define SAVE_TAG_DINO "DIN1"
#define SAVE_TAG_DINO_END "DINE"
#define SAVE_TAG_SUMMARY "SMR1"
#define SAVE_TAG_SUMMARY_END "SMRE"
#define SAVE_TAG_GAME "GAM1"
#define SAVE_TAG_GAME_END "GAME"
#define SAVE_TAG_HEAT "HET1"
#define SAVE_TAG_HEAT_END "HETE"
#define SAVE_TAG_HUD "HUD1"
#define SAVE_TAG_HUD_END "HUDE"
#define SAVE_TAG_INVENTORY "ITR1"
#define SAVE_TAG_INVENTORY_END "ITRE"
#define SAVE_TAG_PLAN "PLN1"
#define SAVE_TAG_PLAN_END "PLNE"
#define SAVE_TAG_CRATE "CRT1"
#define SAVE_TAG_CRATE_END "CRTE"
#define SAVE_TAG_GATE "GAT1"
#define SAVE_TAG_GATE_END "GATE"
#define SAVE_TAG_TILE "TIL1"
#define SAVE_TAG_TILE_END "TILE"
#define SAVE_TAG_TUTORIAL "TUT1"
#define SAVE_TAG_TUTORIAL_END "TUTE"
#define SAVE_TAG_VEHICLE "VHC1"
#define SAVE_TAG_VEHICLE_END "VHCE"
#define SAVE_TAG_WAREHOUSE "WHS1"
#define SAVE_TAG_WAREHOUSE_END "WHSE"
#define SAVE_TAG_MARKET "MKT1"
#define SAVE_TAG_MARKET_END "MKTE"
#define SAVE_TAG_PROTEST "PRT1"
#define SAVE_TAG_PROTEST_END "PRTE"

void saveTagGet(tFile *pFile, char *szTagRead);

UBYTE saveTagIs(const char *szTagRead, const char *szTagRef);

UBYTE saveReadTag(tFile *pFile, const char *szHeader);

void saveWriteTag(tFile *pFile, const char *szHeader);

#endif // SAVE_H
