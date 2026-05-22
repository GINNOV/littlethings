/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _INVENTORY_H_
#define _INVENTORY_H_

#include <ace/types.h>
#include <ace/utils/file.h>
#include "base.h"

#define UPGRADE_LEVEL_COUNT 4
#define INVENTORY_LEVEL_PLATFORM_RESTOCK 1
#define INVENTORY_LEVEL_PLATFORM_ADJACENT 2
#define INVENTORY_LEVEL_PLATFORM_ALL 3

#define INVENTORY_LEVEL_TELEPORTER_WEAK 1
#define INVENTORY_LEVEL_TELEPORTER_NODMG 2
#define INVENTORY_LEVEL_TELEPORTER_RETURN 3

typedef enum tPartKind {
	INVENTORY_PART_DRILL,
	INVENTORY_PART_CARGO,
	INVENTORY_PART_HULL,
	INVENTORY_PART_TNT,
	INVENTORY_PART_TELEPORT,
	INVENTORY_PART_BASE_PLATFORM,
	INVENTORY_PART_BASE_WORKSHOP,
	INVENTORY_PART_COUNT
} tPartKind;

typedef enum tCommUnlockState {
	COMM_UNLOCK_STATE_NONE,
	COMM_UNLOCK_STATE_OFFICE_WORKSHOP,
	COMM_UNLOCK_STATE_WAREHOUSE,
} tCommUnlockState;

typedef struct tPartDef {
	UBYTE ubLevel;
	UWORD uwMaxBase;
	UWORD uwMaxAddPerLevel;
	UWORD uwMax;
} tPartDef;

typedef struct _tInventory {
	tPartDef pParts[INVENTORY_PART_COUNT];
	tCommUnlockState pCommUnlock[BASE_ID_COUNT_UNIQUE];
} tInventory;

void inventoryReset(void);

void inventorySave(tFile *pFile);

UBYTE inventoryLoad(tFile *pFile);

const tPartDef *inventoryGetPartDef(tPartKind ePart);

void inventorySetPartLevel(tPartKind ePart, UBYTE ubLevel);

UBYTE inventoryGetBasePartLevel(tPartKind ePart, tBaseId eBaseId);

void inventorySetBasePartLevel(tPartKind ePart, tBaseId eBaseId, UBYTE ubLevel);

UBYTE inventoryIsBasePart(tPartKind ePart);

void inventoryInit(void);

void inventorySetCommUnlock(tBaseId eBase, tCommUnlockState eState);

tCommUnlockState inventoryGetCommUnlockState(tBaseId eBase);

UBYTE inventoryGetPartMaxLevel(tPartKind ePart);

#endif // _INVENTORY_H_
