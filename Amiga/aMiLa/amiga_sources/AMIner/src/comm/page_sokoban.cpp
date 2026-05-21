/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "page_sokoban.h"
#include <ace/types.h>
#include <ace/managers/key.h>
#include <comm/gs_shop.h>
#include "../assets.h"
#include "../game.h"

namespace {

//---------------------------------------------------------------- PRIVATE TYPES

struct tLevelData {
	enum class tTile: char {
		FLOOR = ' ',
		WALL = '#',
		SLOT = '.',
		BOX_ON_FLOOR = '$',
		BOX_ON_SLOT = '*',
		PLAYER_ON_FLOOR = '@',
		PLAYER_ON_SLOT = '+',
	};

	static constexpr UBYTE s_ubWidth = 8;
	static constexpr UBYTE s_ubHeight = 7;

	tTile m_pTiles[s_ubWidth][s_ubHeight]; ///< [x, y]

	consteval tLevelData() = default;

	consteval tLevelData(
		const char *pRow1, const char *pRow2, const char *pRow3, const char *pRow4,
		const char *pRow5, const char *pRow6, const char *pRow7
	) {
		for(UBYTE ubX = 0; ubX < s_ubWidth; ++ubX) {
			m_pTiles[ubX][0] = static_cast<tTile>(pRow1[ubX]);
			m_pTiles[ubX][1] = static_cast<tTile>(pRow2[ubX]);
			m_pTiles[ubX][2] = static_cast<tTile>(pRow3[ubX]);
			m_pTiles[ubX][3] = static_cast<tTile>(pRow4[ubX]);
			m_pTiles[ubX][4] = static_cast<tTile>(pRow5[ubX]);
			m_pTiles[ubX][5] = static_cast<tTile>(pRow6[ubX]);
			m_pTiles[ubX][6] = static_cast<tTile>(pRow7[ubX]);
		}
	}
};

class tLevelState {
public:
	constexpr void load(const tLevelData &rLevelData);

	constexpr const tLevelData &getData(void) const;

	constexpr bool isSolved(void) const;

	constexpr bool tryMovePlayer(tDirection eDirection);

	void drawAll(void);

	void drawDirty(void);

	void drawStepCount(void);

private:
	static constexpr UBYTE s_ubMaxBoxes = 5;
	static constexpr UBYTE s_ubMaxDirty = 4;

	tLevelData m_LevelData;
	tUbCoordYX m_PlayerPos;
	UBYTE m_ubSlotCount;
	UBYTE m_ubDirtyCount;
	UWORD m_uwStepCount;
	tUbCoordYX m_pSlotPositions[s_ubMaxBoxes];
	tUbCoordYX m_pDirtyPositions[s_ubMaxDirty];

	void drawTileAt(UBYTE ubX, UBYTE ubY);

	void drawLevelIndex();

	constexpr bool tryMoveBox(tUbCoordYX BoxPos, tDirection eDirection);
};

//----------------------------------------------------------------- PRIVATE VARS

// http://sneezingtiger.com/sokoban/levels/yoshioText.html
const tLevelData s_pLevels[] = {
	tLevelData(
		"####### ",
		"# . . # ",
		"# $ $ # ",
		"#  .   # ",
		"#  $ ## ",
		"## @ #  ",
		" #####  "
	),
	tLevelData(
		" ###### ",
		"##  . # ",
		"# * # # ",
		"# .$  # ",
		"#  #$## ",
		"## @ #  ",
		" #####  "
	),
	tLevelData(
		"####### ",
		"#  .@ # ",
		"# #.# # ",
		"#   $ # ",
		"#.$$ ## ",
		"#  ###  ",
		"####    "
	),
	tLevelData(
		"        ",
		"#####   ",
		"# ..####",
		"# $    #",
		"#  #$# #",
		"# @ .$ #",
		"########"
	),
	tLevelData(
		"####### ",
		"#.  @.# ",
		"#  $# ##",
		"# # $. #",
		"#   $# #",
		"####   #",
		"   #####"
	),
	tLevelData(
		"#####   ",
		"#. .### ",
		"#.#$$ # ",
		"#   @ # ",
		"# $#  # ",
		"##   ## ",
		" #####  "
	),
	tLevelData(
		"########",
		"#.   . #",
		"# # #  #",
		"#@$  $.#",
		"##### $#",
		"    #  #",
		"    ####"
	),
	tLevelData(
		" #####  ",
		" # @ ###",
		"## .   #",
		"#. $.$ #",
		"##$# ###",
		" #   #  ",
		" #####  "
	),
	tLevelData(
		" ####   ",
		"##  ####",
		"#..$  .#",
		"# #$ $ #",
		"#@  #  #",
		"#####  #",
		"    ####"
	),
	tLevelData(
		"#####   ",
		"#.  #   ",
		"# # ### ",
		"# *$  # ",
		"#  $. # ",
		"#  @### ",
		"#####   "
	),
	tLevelData(
		"  ##### ",
		"  #   # ",
		"  # #.# ",
		"###  .# ",
		"#@ $$ # ",
		"#  .$ # ",
		"####### "
	),
	tLevelData(
		"######  ",
		"#   @## ",
		"#  #  # ",
		"#.  $ # ",
		"# $$#.# ",
		"###  .# ",
		"  ##### "
	),
	tLevelData(
		"        ",
		"  ####  ",
		"###. #  ",
		"# .  ###",
		"#   $$ #",
		"## . $@#",
		" #######"
	),
	tLevelData(
		"#####   ",
		"#   ### ",
		"# # *@##",
		"#  *   #",
		"###$   #",
		"  #   .#",
		"  ######"
	),
	tLevelData(
		"        ",
		" ####   ",
		"##  ### ",
		"#     ##",
		"#  #$$@#",
		"#  . *.#",
		"########"
	),
	tLevelData(
		" #######",
		"##@    #",
		"#. #   #",
		"# $$$.##",
		"# .#  # ",
		"#  #### ",
		"####    "
	),
	tLevelData(
		"        ",
		"######  ",
		"# .  #  ",
		"# .# ###",
		"# @$$  #",
		"# $.   #",
		"########"
	),
	tLevelData(
		"   #####",
		"#### . #",
		"# *@ . #",
		"# $ #  #",
		"# #  $ #",
		"#   ####",
		"#####   "
	),
	tLevelData(
		"        ",
		"  ####  ",
		"###  ###",
		"# .. $.#",
		"#  $$ @#",
		"####   #",
		"   #####"
	),
	tLevelData(
		"    ####",
		"    #@ #",
		"##### .#",
		"# $ $ $#",
		"#   .  #",
		"### .  #",
		"  ######"
	),
	tLevelData(
		"   #####",
		"####. @#",
		"#  .$  #",
		"# #  ###",
		"# $ $ .#",
		"####   #",
		"   #####"
	),
	tLevelData(
		"########",
		"#  .# @#",
		"# # $  #",
		"# $.#$ #",
		"## .   #",
		" #  ####",
		" ####   "
	),
	tLevelData(
		"#######",
		"#     #",
		"#.## .#",
		"#*  $@#",
		"#  #$ #",
		"#  #  #",
		"#######"
	),
	tLevelData(
		"########",
		"#      #",
		"# #$   #",
		"# $ @#.#",
		"##$#.  #",
		" #    .#",
		" #######"
	),
};
constexpr UBYTE s_ubLevelCount = ARRAY_SIZE(s_pLevels);

constexpr UBYTE s_ubTileSize = 16;
tLevelState s_CurrentLevel;
tBitMap *s_pBmTiles;
UBYTE s_ubCurrentLevelIndex;
UBYTE s_isSolved;

//------------------------------------------------------------------ PRIVATE FNS

tUbCoordYX positionMoveInDirection(tUbCoordYX Position, tDirection eDirection) {
	tBCoordYX sDelta = dirToDelta(eDirection);
	Position.ubX += sDelta.bX;
	Position.ubY += sDelta.bY;
	return Position;
}

void loadLevel(UBYTE ubIndex) {
	s_CurrentLevel.load(s_pLevels[ubIndex]);
	s_CurrentLevel.drawAll();
	s_isSolved = false;
}

void pageSokobanProcess(void) {
	if(s_isSolved) {
		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			if(++s_ubCurrentLevelIndex >= s_ubLevelCount) {
				s_ubCurrentLevelIndex = 0;
			}
			loadLevel(s_ubCurrentLevelIndex);
		}
	}
	else {
		tDirection eDirection = DIRECTION_COUNT;
		if(commNavUse(DIRECTION_UP)) {
			eDirection = DIRECTION_UP;
		}
		else if(commNavUse(DIRECTION_DOWN)) {
			eDirection = DIRECTION_DOWN;
		}
		else if(commNavUse(DIRECTION_LEFT)) {
			eDirection = DIRECTION_LEFT;
		}
		else if(commNavUse(DIRECTION_RIGHT)) {
			eDirection = DIRECTION_RIGHT;
		}

		if(eDirection != DIRECTION_COUNT) {
			bool isMoved = s_CurrentLevel.tryMovePlayer(eDirection);
			if(isMoved) {
				s_CurrentLevel.drawDirty();
				s_CurrentLevel.drawStepCount();
				if(s_CurrentLevel.isSolved()) {
					s_isSolved = true;
					UWORD uwY = tLevelData::s_ubHeight * s_ubTileSize;
					commErase(0, uwY - 10, COMM_DISPLAY_WIDTH, 10);
					commDrawText(
						COMM_DISPLAY_WIDTH / 2, uwY,
						g_pMsgs[MSG_BONUS_COMPLETE],
						FONT_COOKIE | FONT_BOTTOM | FONT_HCENTER,
						COMM_DISPLAY_COLOR_TEXT_HOVER
					);
				}
			}
		}
		else if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			loadLevel(s_ubCurrentLevelIndex);
		}
		else if(keyUse(KEY_ESCAPE)) {
			commShopChangePage(COMM_SHOP_PAGE_SOKOBAN, COMM_SHOP_PAGE_WAREHOUSE);
		}
	}
}

void pageSokobanDestroy(void) {
	bitmapDestroy(s_pBmTiles);
}

__attribute__((optimize("Os")))
constexpr void tLevelState::load(const tLevelData &rLevelData) {
	m_LevelData  = rLevelData;

	// Initialize metadata
	m_ubSlotCount = 0;
	m_ubDirtyCount = 0;
	m_uwStepCount = 0;
	for(UBYTE ubY = 0; ubY < tLevelData::s_ubHeight; ++ubY) {
		for(UBYTE ubX = 0; ubX < tLevelData::s_ubWidth; ++ubX) {
			switch(rLevelData.m_pTiles[ubX][ubY]) {
				case tLevelData::tTile::PLAYER_ON_FLOOR:
				case tLevelData::tTile::PLAYER_ON_SLOT:
					m_PlayerPos = {.ubY = ubY, .ubX = ubX};
					break;
				case tLevelData::tTile::BOX_ON_SLOT:
					m_pSlotPositions[m_ubSlotCount++] = {.ubY = ubY, .ubX = ubX};
					break;
				case tLevelData::tTile::SLOT:
					m_pSlotPositions[m_ubSlotCount++] = {.ubY = ubY, .ubX = ubX};
					break;
				case tLevelData::tTile::BOX_ON_FLOOR:
				case tLevelData::tTile::FLOOR:
				case tLevelData::tTile::WALL:
					break;
			}
		}
	}
}

constexpr const tLevelData &tLevelState::getData() const {
	return m_LevelData;
}

constexpr bool tLevelState::isSolved(void) const {
	for(UBYTE i = 0; i < m_ubSlotCount; ++i) {
		const tUbCoordYX &rBoxPos = m_pSlotPositions[i];
		if(m_LevelData.m_pTiles[rBoxPos.ubX][rBoxPos.ubY] != tLevelData::tTile::BOX_ON_SLOT) {
			return false;
		}
	}

	return true;
}

constexpr bool tLevelState::tryMoveBox(tUbCoordYX BoxPos, tDirection eDirection) {
	using tTile = tLevelData::tTile;

	auto NewBoxPosition = positionMoveInDirection(BoxPos, eDirection);
	auto &rCurrentTileOnBoxPos = m_LevelData.m_pTiles[BoxPos.ubX][BoxPos.ubY];
	auto &rCurrentTileOnNewBoxPos = m_LevelData.m_pTiles[NewBoxPosition.ubX][NewBoxPosition.ubY];

	if(rCurrentTileOnNewBoxPos == tTile::FLOOR) {
		// TODO: move in box array
		rCurrentTileOnNewBoxPos = tTile::BOX_ON_FLOOR;
	}
	else if(rCurrentTileOnNewBoxPos == tTile::SLOT) {
		rCurrentTileOnNewBoxPos = tTile::BOX_ON_SLOT;
	}
	else {
		return false;
	}

	m_pDirtyPositions[m_ubDirtyCount++] = BoxPos;
	m_pDirtyPositions[m_ubDirtyCount++] = NewBoxPosition;

	if(rCurrentTileOnBoxPos == tTile::BOX_ON_SLOT) {
		rCurrentTileOnBoxPos = tTile::SLOT;
	}
	else {
		rCurrentTileOnBoxPos = tTile::FLOOR;
	}
	return true;
}

constexpr bool tLevelState::tryMovePlayer(tDirection eDirection) {
	using tTile = tLevelData::tTile;
	auto NewPlayerPos = positionMoveInDirection(m_PlayerPos, eDirection);

	auto &rCurrentTileOnNewPlayerPos = m_LevelData.m_pTiles[NewPlayerPos.ubX][NewPlayerPos.ubY];
	switch(rCurrentTileOnNewPlayerPos) {
		case tTile::WALL:
			return false;
		case tTile::FLOOR:
			rCurrentTileOnNewPlayerPos = tTile::PLAYER_ON_FLOOR;
			break;
		case tTile::SLOT:
			rCurrentTileOnNewPlayerPos = tTile::PLAYER_ON_SLOT;
			break;
		case tTile::BOX_ON_SLOT:
		case tTile::BOX_ON_FLOOR: {
			bool isBoxMoved = tryMoveBox(NewPlayerPos, eDirection);
			if(!isBoxMoved) {
				return false;
			}
			if(rCurrentTileOnNewPlayerPos == tTile::FLOOR) {
				rCurrentTileOnNewPlayerPos = tTile::PLAYER_ON_FLOOR;
			}
			else { // if(rCurrentTileOnNewPlayerPos == tTile::SLOT)
				rCurrentTileOnNewPlayerPos = tTile::PLAYER_ON_SLOT;
			}
		} break;
		case tTile::PLAYER_ON_FLOOR:
		case tTile::PLAYER_ON_SLOT:
			break;
	}

	m_pDirtyPositions[m_ubDirtyCount++] = m_PlayerPos;
	m_pDirtyPositions[m_ubDirtyCount++] = NewPlayerPos;

	tTile &rOldPlayerTile = m_LevelData.m_pTiles[m_PlayerPos.ubX][m_PlayerPos.ubY];
	if(rOldPlayerTile == tTile::PLAYER_ON_FLOOR) {
		rOldPlayerTile = tTile::FLOOR;
	}
	else if(rOldPlayerTile == tTile::PLAYER_ON_SLOT) {
		rOldPlayerTile = tTile::SLOT;
	}
	m_PlayerPos = NewPlayerPos;
	++m_uwStepCount;
	return true;
}

void tLevelState::drawTileAt(UBYTE ubX, UBYTE ubY) {
	tBitMap *pBuffer = commGetDisplayBuffer();
	tUwCoordYX sOrigin = commGetOriginDisplay();
	const auto Tile = s_CurrentLevel.getData().m_pTiles[ubX][ubY];
	constexpr UBYTE ubOffsX = (COMM_DISPLAY_WIDTH - tLevelData::s_ubWidth * s_ubTileSize) / 2;

	UBYTE ubTileOffsetY;
	switch(Tile) {
		case tLevelData::tTile::FLOOR:
			ubTileOffsetY = 1 * 16;
			break;
		case tLevelData::tTile::PLAYER_ON_FLOOR:
		case tLevelData::tTile::PLAYER_ON_SLOT:
			ubTileOffsetY = 2 * 16;
			break;
		case tLevelData::tTile::BOX_ON_FLOOR:
		case tLevelData::tTile::BOX_ON_SLOT:
			ubTileOffsetY = 3 * 16;
			break;
		case tLevelData::tTile::SLOT:
			ubTileOffsetY = 4 * 16;
			break;
		case tLevelData::tTile::WALL:
		default:
			ubTileOffsetY = 0;
			break;
	}

	blitCopy(
		s_pBmTiles, 0, ubTileOffsetY,
		pBuffer,
		sOrigin.uwX + ubOffsX + ubX * s_ubTileSize,
		sOrigin.uwY + ubY * s_ubTileSize,
		s_ubTileSize, s_ubTileSize, MINTERM_COOKIE
	);
}

void tLevelState::drawLevelIndex(void) {
	snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, g_pMsgs[MSG_BONUS_LEVEL], s_ubCurrentLevelIndex + 1);
	commDrawText(COMM_DISPLAY_WIDTH - 60, COMM_DISPLAY_HEIGHT - 10, gameGetMessageBuffer(), FONT_COOKIE | FONT_LAZY, COMM_DISPLAY_COLOR_TEXT_DARK);
}

void tLevelState::drawStepCount(void) {
	snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, g_pMsgs[MSG_BONUS_STEPS], m_uwStepCount);
	commErase(20, COMM_DISPLAY_HEIGHT - 10, 60, 10);
	commDrawText(20, COMM_DISPLAY_HEIGHT - 10, gameGetMessageBuffer(), FONT_COOKIE | FONT_LAZY, COMM_DISPLAY_COLOR_TEXT_DARK);
}

void tLevelState::drawAll(void) {
	commEraseAll();
	for(UBYTE ubY = 0; ubY < tLevelData::s_ubHeight; ++ubY) {
		for(UBYTE ubX = 0; ubX < tLevelData::s_ubWidth; ++ubX) {
			drawTileAt(ubX, ubY);
		}
	}

	drawLevelIndex();
	drawStepCount();
	m_uwStepCount = 0;
	m_ubDirtyCount = 0;
}

void tLevelState::drawDirty(void) {
	for(UBYTE ubIdx = 0; ubIdx < m_ubDirtyCount; ++ubIdx) {
		drawTileAt(m_pDirtyPositions[ubIdx].ubX, m_pDirtyPositions[ubIdx].ubY);
	}

	m_ubDirtyCount = 0;
}

} // namespace

//------------------------------------------------------------------- PUBLIC FNS


void pageSokobanCreate(void) {
	s_ubCurrentLevelIndex = 0;
	s_pBmTiles = bitmapCreateFromFd(GET_SUBFILE_PREFIX("soko.bm"), 0);
	commRegisterPage(pageSokobanProcess, pageSokobanDestroy);
	loadLevel(0);
}
