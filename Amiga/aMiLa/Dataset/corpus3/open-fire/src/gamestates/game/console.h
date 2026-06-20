#ifndef GUARD_OF_GAMESTATES_GAME_CONSOLE_H
#define GUARD_OF_GAMESTATES_GAME_CONSOLE_H

#include <ace/types.h>
#include <ace/utils/font.h>

#define CONSOLE_COLOR_GENERAL 4
#define CONSOLE_COLOR_SAY     13
#define CONSOLE_COLOR_BLUE    12
#define CONSOLE_COLOR_RED     10
#define CONSOLE_MESSAGE_MAX 35

void consoleCreate(tFont *pFont);

void consoleDestroy(void);

void consoleWrite(const char *szMsg, UBYTE ubColor);

void consoleUpdate(void);

void consoleChatBegin(void);

void consoleChatEnd(void);

/**
 * Processes given character or keypress in chat entry.
 * @param c Character to be processed.
 * @return 0 if keypress resulted in end of chat edit, otherwise 1.
 */
FUBYTE consoleChatProcessChar(char c);

extern FUBYTE g_isChatting;

#endif // GUARD_OF_GAMESTATES_GAME_CONSOLE_H
