#ifndef _HIGHSCORE_H_
#define _HIGHSCORE_H_

#include "main.h"

#define HIGHSCORE_MAX 10
#define HIGHSCORE_VALUE_MAX 999999999
#define HIGHSCORE_YPOS 108
#define HIGHSCORE_OFFSET_L 85
#define HIGHSCORE_OFFSET_R 150
#define HIGHSCORE_SPACING 12
#define HIGHSCORE_COLOR 30
#define HIGHSCORE_TIMER 500

#define CREDITS_XPOS 56
#define CREDITS_YPOS 108
#define CREDITS_WIDTH 208
#define CREDITS_HEIGHT 52

#define GREETS_MAX 11
#define GREETS_XPOS 32
#define GREETS_YPOS 108
#define GREETS_WIDTH 256
#define GREETS_HEIGHT 8
#define GREETS_COLOR 30

#define PULSE_COLOR 31
#define GRADIENT_LENGTH 7
#define PULSE_LENGTH 29

typedef struct _tHighScore {
    char cInitials[4];
    ULONG ulScore;
} tHighScore;

static void updatePalette(UBYTE ubIndex);
static void renderText(void);

#endif // _HIGHSCORE_H_

