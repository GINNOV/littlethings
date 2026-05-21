
#ifndef ROVER_H

#define ROVER_H

#include "header:bullets.h"
#include <exec/types.h>

struct _RoverDescriptor {
   struct _RoverDescriptor *flink,*blink;
   DSP_PDLE DLE;
   DSP_PCOL COL;
   BUL_PMissile Missile;	/* Missile for Rover */
   WORD XDir;			/* X Direction */
   WORD CurFrame;		/* Current frame */
   WORD Delay;			/* No frames between animating */
   WORD MaxDelay;
   WORD BulletsLeft;
   WORD HitsRequired;		/* Hits to kill Rover */
};

typedef struct _RoverDescriptor RoverDescriptor;

extern RoverDescriptor *FreeRovers;
extern RoverDescriptor *ActiveRovers;
   
#endif
