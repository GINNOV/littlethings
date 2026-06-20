/*
 * Structures for Collision software
 *
 * Written by Billy Newport
 *
 * Modification List :
 * ===================
 * 05/04/88 BN  Created It!
 * 11/04/88 BN  Modified to Alert user on crashes
 */

#ifndef COLLISIONH
#define COLLISIONH

#include <exec/types.h>
#include "displist.h"
 
struct HitBox {
  WORD TXoff,TYoff,BXoff,BYoff;
};

struct CollisionEntry {
  struct CollisionEntry *flink,*blink;  /* Queue pointers */
  struct DisplayListEntry *DLE;		/* Pointer to Display Object */
  void (*function)();			/* Routine to call on collision */
  char *name;				/* For conversational debugging */
};

typedef struct CollisionEntry DSP_COL;
typedef struct CollisionEntry *DSP_PCOL;

extern DSP_PCOL AllocCOL();
extern void FreeCOL();

extern DSP_PCOL DSP_GoodCollisions;	/* Queue head for Good Guys */
extern DSP_PCOL DSP_FreeCOLs;		/* Queue head for free COLs */

#endif
