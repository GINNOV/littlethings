/*
        This program is copyright 1990, 1993 Stephen Norris. 
        May be freely distributed provided this notice remains intact.
*/

#ifndef CONSOLE_H
#define CONSOLE_H

#include "stdinc.h"
#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <devices/conunit.h>

#define ACTION_SCREEN_MODE  994L
#define DOSTRUE  -1L
#define DOSFALSE  0L

#define CSI 0x9b

typedef enum {
	C_KEYSTROKE, C_HELP,
	C_CUP, C_CDOWN, C_CLEFT, C_CRIGHT, C_CSUP, C_CSDOWN, C_CSLEFT, C_CSRIGHT,
	C_F1, C_F2, C_F3, C_F4, C_F5, C_F6, C_F7, C_F8, C_F9, C_F10,
	C_SF1, C_SF2, C_SF3, C_SF4, C_SF5, C_SF6, C_SF7, C_SF8, C_SF9, C_SF10,
	C_RAWKEYIN, C_MOUSEIN, C_EVENT, C_POINTPOS, C_TIMER, C_GADPRESS, C_GADREL, C_REQACT,
	C_MENUNUM, C_CLOSEGAD, C_WINSIZE, C_WINREF, C_PREFCHANGE, C_DISKOUT, C_DISKIN
}       conKeyCodes;

typedef enum {
	C_NOP1, C_ONKEY, C_ONMOUSE, C_ONEVENT, C_ONPOINTPOS, C_UNUSED1, C_ONTIMER, C_ONGADPRESS,
	C_ONGADREL, C_REQACTON, C_ONMENUNUM, C_ONCLOSEGAD, C_ONWINSIZE, C_ONWINREF,
	C_ONPREFCHANGE, C_ONDISKOUT, C_ONDISKIN,
	C_NOP2, C_OFFKEY, C_OFFMOUSE, C_OFFEVENT, C_OFFPOINTPOS, C_UNUSED2, C_OFFTIMER, C_OFFGADPRESS,
	C_OFFGADREL, C_REQACTOFF, C_OFFMENUNUM, C_OFFCLOSEGAD, C_OFFWINSIZE, C_OFFWINREF,
	C_OFFPREFCHANGE, C_OFFDISKOUT, C_OFFDISKIN
}	conEventCodes;

typedef struct {
conKeyCodes Type;
char Key;	/* Used for normal keypresses. */
short keycode; 	/* As in structure on p231. */
short qualifier;
long seconds;
long microseconds;
short x,y;
} conReportEvents;

void    conClean();
void    conDelChars(int x, int y, int num);
conReportEvents *conGetKeys(int TimeOut);
int     conInit();
void    conMoveTo(int x, int y);
void    conPutStr(int x, int y, char *String);
void    ConsoleClean();
LONG    setRawCon(LONG toggle);
LONG    findWindow();

#endif
