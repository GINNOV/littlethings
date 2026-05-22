/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <ace/managers/log.h>
#include <ace/managers/system.h>
#include "map_data.h"
#include "json/json.h"
#include <assets.h>

static const char s_pTileToChar[TILE_COUNT] = {'\0',
	[TILE_BLANK] = '.',
	[TILE_BLOB_P1] = '1',
	[TILE_BLOB_P2] = '2',
	[TILE_BLOB_P3] = '3',
	[TILE_BLOB_P4] = '4',
	[TILE_BLOB_NEUTRAL] = 'N',
	[TILE_SUPER_CAP_P1] = 'A',
	[TILE_SUPER_CAP_P2] = 'B',
	[TILE_SUPER_CAP_P3] = 'C',
	[TILE_SUPER_CAP_P4] = 'D',
	[TILE_SUPER_CAP_NEUTRAL] = 'X',
	[TILE_SUPER_TICK_P1] = 'E',
	[TILE_SUPER_TICK_P2] = 'F',
	[TILE_SUPER_TICK_P3] = 'G',
	[TILE_SUPER_TICK_P4] = 'H',
	[TILE_SUPER_TICK_NEUTRAL] = 'Y',
	[TILE_SUPER_ATK_P1] = 'J',
	[TILE_SUPER_ATK_P2] = 'K',
	[TILE_SUPER_ATK_P3] = 'L',
	[TILE_SUPER_ATK_P4] = 'M',
	[TILE_SUPER_ATK_NEUTRAL] = 'Z',
	[TILE_PATH_H1...TILE_PATH_H4] = '-',
	[TILE_PATH_V1...TILE_PATH_V4] = '|',
	[TILE_PATH_X1...TILE_PATH_X4] = '+',
};

static tTile tileFromChar(char c) {

	for(tTile eTile = 0; eTile < TILE_COUNT; ++eTile) {
		if(c == s_pTileToChar[eTile]) {
			return eTile;
		}
	}
	return TILE_COUNT;
}

UBYTE mapDataInitFromFile(tMapData *pMapData, const char *szPath) {
	systemUse();
	logBlockBegin("mapDataInitFromFile(szPath: '%s')", szPath);
	UBYTE isOk = 0;
	tJson *pJson = jsonCreate(szPath);
	if(!pJson) {
		goto end;
	}
	mapDataClear(pMapData);

	UWORD uwTokName = jsonGetDom(pJson, "name");
	UWORD uwTokAuthor = jsonGetDom(pJson, "author");
	UWORD uwTokTiles = jsonGetDom(pJson, "tiles");

	if(!uwTokName || !uwTokAuthor || !uwTokTiles) {
		logWrite("ERR: couldn't find all tokens\n");
		goto end;
	}

	jsonTokStrCpy(pJson, 0, uwTokName, pMapData->szName, MAP_NAME_MAX);
	jsonTokStrCpy(pJson, 0, uwTokAuthor, pMapData->szAuthor, MAP_AUTHOR_MAX);
	logWrite("Name: '%s' by '%s'\n", pMapData->szName, pMapData->szAuthor);

	UBYTE ubCharsInRow = jsonStrLen(pJson, jsonGetElementInArray(pJson, uwTokTiles, 0));
	UBYTE ubPadX = (MAP_SIZE - ubCharsInRow) / 2;
	UBYTE ubRowCount = pJson->pTokens[uwTokTiles].size;
	UBYTE ubPadY = (MAP_SIZE - ubRowCount) / 2;
	logWrite(
		"PadX: %hhu, Pad Y: %hhu, row count: %hhu, line width: %hhu\n",
		ubPadX, ubPadY, ubRowCount, ubCharsInRow
	);

	pMapData->ubPlayerMask = 0;
	for(UBYTE y = 0; y < ubRowCount; ++y) {
		UWORD uwTokRow = jsonGetElementInArray(pJson, uwTokTiles, y);
		const char *pRow = &pJson->szData[pJson->pTokens[uwTokRow].start];

		UBYTE ubCurrentRowLength = jsonStrLen(pJson, uwTokRow);
		if(ubCurrentRowLength != ubCharsInRow) {
			logWrite("ERR: line length mismatch\n");
			goto end;
		}

		for(UBYTE x = 0; x < ubCharsInRow; ++x) {
			tTile eTile = tileFromChar(pRow[x]);
			if(eTile != TILE_COUNT) {
				UBYTE ubMapX = ubPadX + x;
				UBYTE ubMapY = ubPadY + y;
				pMapData->pTiles[ubMapX][ubMapY] = eTile;
			}
			else {
				logWrite("ERR: Can't find tile for '%c' at %hu,%hu\n", pRow[x], x, y);
				goto end;
			}
		}
	}

	mapDataRecalculateStuff(pMapData);
	isOk = 1;
end:
	if(pJson) {
		jsonDestroy(pJson);
	}
	logBlockEnd("mapDataInitFromFile()");
	systemUnuse();
	return isOk;
}

void mapDataClear(tMapData *pMapData) {
	for(UBYTE x = 0; x < MAP_SIZE; ++x) {
		for(UBYTE y = 0; y < MAP_SIZE; ++y) {
			pMapData->pTiles[x][y] = TILE_BLANK;
		}
	}
	strcpy(pMapData->szAuthor, "");
	strcpy(pMapData->szName, "");
	pMapData->ubPlayerMask = 0;
}

UBYTE tileIsJunction(tTile eTile) {
	UBYTE isMovable = (eTile >= TILE_PATH_X1);
	return isMovable;
}

UBYTE tileIsVariantOfPath(tTile eTile, tTile eAllowedPath) {
	UBYTE isAllowed = (eAllowedPath <= eTile && eTile <= eAllowedPath);
	return isAllowed;
}

UBYTE tileIsNode(tTile eTile) {
	UBYTE isNode = (eTile < TILE_BLOB_COUNT);
	return isNode;
}

void mapDataRecalculateStuff(tMapData *pMapData) {
	pMapData->ubPlayerMask = 0;
	for(UBYTE x = 0; x < MAP_SIZE; ++x) {
		for(UBYTE y = 0; y < MAP_SIZE; ++y) {
			tTile eTile = pMapData->pTiles[x][y];
			if(tileIsNode(eTile)) {
				// Convert to plain node type
				while(eTile >= TILE_SUPER_CAP_P1) {
					eTile -= TILE_SUPER_CAP_P1;
				}
				if(eTile != TILE_BLOB_NEUTRAL) {
					pMapData->ubPlayerMask |= BV(eTile - TILE_BLOB_P1);
				}
			}
		}
	}
}

UBYTE mapDataSaveToFile(const tMapData *pMapData, const char *szPath) {
	systemUse();
	logBlockBegin("mapDataSaveToFile(pMapData: %p, szPath: '%s')", pMapData, szPath);
	tFile *pFile = fileOpen(szPath, "wb");
	if(!pFile) {
		logWrite("ERR: File doesn't exist\n");
		logBlockEnd("mapDataSaveToFile()");
		systemUnuse();
		return 0;
	}
	fileWriteStr(pFile, "{\n");

	fileWriteStr(pFile, "\t\"name\": \"");
	fileWriteStr(pFile, pMapData->szName);
	fileWriteStr(pFile, "\",\n");

	fileWriteStr(pFile, "\t\"author\": \"");
	fileWriteStr(pFile, pMapData->szAuthor);
	fileWriteStr(pFile, "\",\n");

	fileWriteStr(pFile, "\t\"tiles\": [\n");
	for(UBYTE ubY = 0; ubY < MAP_SIZE; ++ubY) {
		fileWriteStr(pFile, "\t\t\"");
		for(UBYTE ubX = 0; ubX < MAP_SIZE; ++ubX) {
			char c = s_pTileToChar[pMapData->pTiles[ubX][ubY]];
			fileWrite(pFile, &c, 1);
		}
		fileWriteStr(pFile, "\"");
		if(ubY < MAP_SIZE - 1) {
			fileWriteStr(pFile, ",");
		}
		fileWriteStr(pFile, "\n");
	}
	fileWriteStr(pFile, "\t]\n}\n");

	fileClose(pFile);
	logBlockEnd("mapDataSaveToFile()");
	systemUnuse();
	return 1;
}

UBYTE mapDataGetPlayerCount(const tMapData *pMapData) {
	UBYTE ubCount = 0;
	UBYTE ubMask = pMapData->ubPlayerMask;

	while(ubMask) {
		if(ubMask & 1) {
			++ubCount;
		}
		ubMask >>= 1;
	}

	return ubCount;
}
