#ifndef BUG_H

#define BUG_H

#include <exec/types.h>
#include "displist.h"
#include "scheduler.h"
#include "Animation.h"

typedef struct {
   struct SCH_queue Q;
   DSP_PDLE DLE;		/* DLE for baby */
   CyclicAnimation CAnim;
   PathDescriptor Path;
   WORD NumHits;		/* Num hits left */
   ULONG flags;
#     define BABY_goingleft 1L

} BabyDescriptor;

typedef struct {
   struct SCH_queue Q;
   DSP_PDLE DLE;		/* DLE For body */
   CyclicAnimation CAnim;
   PathDescriptor Path;

   WORD NumHits;
   BabyDescriptor *Left;	/* Left Baby */
   BabyDescriptor *Right;	/* Right baby */
} BugSqueezeDescriptor;

#define ALLOCBABYBUG (BabyDescriptor *)RemQue(FreeBabyBugs->Q.flink)
#define ALLOCSQUEEZEBUG (BugSqueezeDescriptor *)RemQue(FreeSqueezeBugs->Q.flink)

#define FREEBABYBUG(a) InsQue(&FreeBabyBugs->Q,(a))
#define FREESQUEEZEBUG(a) InsQue(&FreeSqueezeBugs->Q,(a))
#endif

