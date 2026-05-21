#include "wave.h"
#include "iff.h"
#include <exec/types.h>

#ifndef PATHANM_H

#define PATHANM_H

typedef struct {
   ANM_PELEM PathTable;
   ANM_PELEM CurAnim;
   WORD Count;
} PathDescriptor;

typedef struct {
   struct SpriteImage *Image;
   WORD CurImage;
   WORD Delay,MaxDelay;
   BYTE First,Last;
} CyclicAnimation;

#endif
   
