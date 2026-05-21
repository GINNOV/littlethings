#ifndef BIGGUY_H

#define BIGGUY_H

#include "scheduler.h"
#include "displist.h"
#include "animation.h"
#include <exec/types.h>

typedef struct {
   struct SCH_queue Q;
   DSP_PDLE DLE;
  
   CyclicAnimation CAnim;
   PathDescriptor Path;

   BYTE NumHits;
} BigGuyDescriptor;

typedef struct {
   ULONG flags;
#define MAJSEG_SelfDestruct 1L
   WORD Count;
   DSP_DLE DLE;
   WORD Dx,Dy;
} MajorHangerDescriptor;

typedef struct {
   DSP_DLE DLE;
   CyclicAnimation CAnim;
   MajorHangerDescriptor *Daddy;
   WORD NumHits;
   WORD Px,Py;
   WORD Dx,Dy;
} HangerGuy;

#endif
