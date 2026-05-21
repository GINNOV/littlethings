#ifndef EYES_H
#define EYES_H

#include <exec/types.h>

#include "Scheduler.h"
#include "DispList.h"
#include "Animation.h"
#include "iff.h"

typedef struct {
   WORD x,y;
   void (*function)();
   struct SpriteImage *Image;
   BYTE Delay;
   BYTE First,Last;
} BackGroundObject;

typedef struct {
   WORD x,y;				/* BackGround x,y */
   CyclicAnimation CAnim;		/* For animationing it */
   DSP_DLE DLE;				/* For collision checking */
   WORD NumHits;			/* Number of hits */
   WORD *Parent;			/* Points to array */
} EyeDescriptor;

typedef struct {
   char *name;
   struct SpriteImage *Image;
} ObjectDescriptor;

#endif

