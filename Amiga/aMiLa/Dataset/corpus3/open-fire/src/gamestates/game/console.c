#include "gamestates/game/console.h"
#include <ace/utils/font.h>
#include <ace/managers/key.h>
#include "gamestates/game/game.h"
#include "gamestates/game/hud.h"
#include "gamestates/game/player.h"

// 210x59
#define CONSOLE_MAX_ENTRIES 8
#define CONSOLE_LOG_MAX 10
#define CHAT_MAX 50

static tFont *s_pConsoleFont;
static char s_pChatBfr[CHAT_MAX] = "say: ";
FUBYTE g_isChatting;
static FUBYTE s_fubChatLineLength;

static tTextBitMap *s_pChatLineBfr;

UWORD s_uwToDraw;

typedef struct _tConsoleEntry {
	UBYTE ubColor;
	char szMessage[CHAT_MAX];
} tConsoleEntry;

typedef struct _tConsoleLog {
	UWORD uwTailIdx;
	tConsoleEntry pLog[CONSOLE_LOG_MAX];
} tConsoleLog;

tConsoleLog s_sLog;

void consoleCreate(tFont *pFont) {
	s_pConsoleFont = pFont;
	g_isChatting = 0;
	s_pChatLineBfr = fontCreateTextBitMap(192, pFont->uwHeight);
	s_sLog.uwTailIdx = 0;
	s_uwToDraw = 0;
}

void consoleDestroy(void) {
	fontDestroyTextBitMap(s_pChatLineBfr);
}

void consoleWrite(const char *szMsg, UBYTE ubColor) {
	s_sLog.pLog[s_sLog.uwTailIdx].ubColor = ubColor;
#ifdef GAME_DEBUG
	if(strlen(szMsg) > CHAT_MAX) {
		logWrite("ERR: Text too long (%d): '%s'\n", strlen(szMsg), szMsg);
		return;
	}
#endif
	strcpy(s_sLog.pLog[s_sLog.uwTailIdx].szMessage, szMsg);
	++s_sLog.uwTailIdx;
	if(s_sLog.uwTailIdx >= CONSOLE_LOG_MAX) {
		s_sLog.uwTailIdx -= CONSOLE_LOG_MAX;
	}
}

void consoleUpdate(void) {
	if(s_uwToDraw == s_sLog.uwTailIdx) {
		return;
	}

	if(fontFillTextBitMap(
		s_pConsoleFont, s_pChatLineBfr, s_sLog.pLog[s_uwToDraw].szMessage
	)) {
		// Move remaining messages up
		blitCopyAligned(
			g_pHudBfr->pBack, 112, 9,
			g_pHudBfr->pBack, 112, 3,
			192, 41
		);

		// Clear last line
		blitRect(g_pHudBfr->pBack, 112,45, 192, 5, 0);

		// Draw new message
		fontDrawTextBitMap(
			g_pHudBfr->pBack, s_pChatLineBfr, 112, 45,
			s_sLog.pLog[s_uwToDraw].ubColor, FONT_TOP | FONT_LEFT | FONT_LAZY
		);
	}
	else {
		logWrite("ERR: Couldn't render '%s'", s_sLog.pLog[s_uwToDraw].szMessage);
	}
	++s_uwToDraw;
	if(s_uwToDraw >= CONSOLE_LOG_MAX) {
		s_uwToDraw -= CONSOLE_LOG_MAX;
	}
}

void consoleChatBegin(void) {
	s_fubChatLineLength = 5;
	s_pChatBfr[s_fubChatLineLength] = 0;
	g_isChatting = 1;
	fontFillTextBitMap(s_pConsoleFont, s_pChatLineBfr, s_pChatBfr);
	fontDrawTextBitMap(
		g_pHudBfr->pBack, s_pChatLineBfr, 112, 51,
		CONSOLE_COLOR_GENERAL, FONT_TOP | FONT_LEFT | FONT_LAZY
	);
}

void consoleChatEnd(void) {
	// Erase chat line
	blitRect(g_pHudBfr->pBack, 112,51, 192, 5, 0);
	g_isChatting = 0;
}

FUBYTE consoleChatProcessChar(char c) {
	// Try control chars
	if(c == KEY_RETURN || c == KEY_NUMENTER) {
		if(s_fubChatLineLength == 5)
			return 0;
		s_pChatBfr[s_fubChatLineLength] = 0;
		playerSay(g_pLocalPlayer, &s_pChatBfr[5], 0);
		consoleChatEnd();
		return 0;
	}
	else {
		// Printable chars
		c= g_pToAscii[(UBYTE)c];
		if(
			(c >= 'A' && c <= 'Z') ||
			(c >= 'a' && c <= 'z') ||
			(c >= '0' && c <= '9') ||
			c == ' '
		) {
			s_pChatBfr[s_fubChatLineLength++] = c;
			s_pChatBfr[s_fubChatLineLength] = 0; // for printing
			fontFillTextBitMap(s_pConsoleFont, s_pChatLineBfr, s_pChatBfr);
			fontDrawTextBitMap(
				g_pHudBfr->pBack, s_pChatLineBfr, 112, 51,
				CONSOLE_COLOR_GENERAL, FONT_TOP | FONT_LEFT | FONT_LAZY
			);
		}
	}
	return 1;
}
