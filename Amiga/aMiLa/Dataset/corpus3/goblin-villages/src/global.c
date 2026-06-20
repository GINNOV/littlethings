#include "global.h"

tFont *g_pFont;
struct BitMap *g_pCharactersBitMap;

__chip UWORD g_pCursorData[288];
__chip UWORD g_pPawnCursorData[36];

tGameConfig g_sGameConfig = {
	{1, 1, 1, 1, 0, 0, 0, 0}, // pPlayersSelected
	4, // ubPlayerCount
	0, // pPlayerFirst;
	7, // ubPawnsPerPlayer;
	0, // ubPawnCount;
	0 // pPawnFirst;
};	

UBYTE g_pPlayerColors[PLAYER_COUNT][2] = {
	{13, 14},
	{15, 16},
	{20, 21},
	{22, 23},
	{24, 25},
	{26, 27},
	{28, 29},
	{30, 31}
};

WORD g_pPointerSpots[8][2] = {
	{0, 0},
	{-6, 0},
	{-11, 0},
	{-15, -6},
	{-15, -11},
	{-9, -15},
	{-2, -15},
	{0, -8}
};

BYTE g_pPointerDirs[3][3] = {
	{POINTER_NW, POINTER_N,  POINTER_NE},
	{POINTER_W,  POINTER_NW, POINTER_E},
	{POINTER_SW, POINTER_S,  POINTER_SE}
};

void globalLoadCursorData(void) {
	FILE *pFile;
	pFile = fopen("data/hand.cur", "rb");
	fseek(pFile, 9, SEEK_CUR); // pominiêcie nag³ówka: ubCursorCount + paleta
	fread(g_pCursorData, 576, 1, pFile);
	fclose(pFile);
	pFile = fopen("data/pawn.cur", "rb");
	fseek(pFile, 9, SEEK_CUR); // pominiêcie nag³ówka: ubCursorCount + paleta
	fread(g_pPawnCursorData, 72, 1, pFile);
	fclose(pFile);
	mouseSetPointer(g_pCursorData, 16, 16, 0, 0);
}

void globalCreate(void) {
	logWrite("globalCreate begin\n");
	logPushIndent();
	globalLoadCursorData();
	g_pFont = fontCreate("data/fonts/arpegius-15.fnt");
	g_pCharactersBitMap = bitmapCreateFromFile("data/bitmaps/goblins.bm");
	logPopIndent();
	logWrite("globalCreate end\n");
}

void globalDestroy(void) {
	fontDestroy(g_pFont);
	bitmapDestroy(g_pCharactersBitMap);
}