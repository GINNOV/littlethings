#ifndef _INTRO_H_
#define _INTRO_H_

#include "main.h"

#define INTRO_WAIT_TIME 100

typedef enum _tIntroStage {
    INTRO_BRAINS,
    INTRO_ACE,
    INTRO_TITLE,
    INTRO_TEXT,
    INTRO_FINISHED,
} tIntroStage;

static void updatePalette(UBYTE ubIndex);

#endif // _INTRO_H_
