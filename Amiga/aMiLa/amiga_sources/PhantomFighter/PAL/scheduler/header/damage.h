#ifndef DAMAGE_H
#define DAMAGE_H

#include "scheduler.h"
#include <exec/types.h>

typedef struct {
   struct SCH_queue Q;
   WORD x,y;			/* Position on bitmap */
   WORD Width,Height;		/* Actual size */
   UWORD Plane[4][128];		/* Up to 32 x 32 */
} DamageBlock;

#define AllocDamageBlock() (DamageBlock *)RemQue(FreeDamageList->Q.flink)
#define FreeDamageBlock(d) InsQue(FreeDamageList,d)

#endif

