/*
 * Display List Demo routine
 *
 * Written and Designed by BN
 *
 */

#include "GameParam.h"

#asm
		include	"header:displist.i"
		include	"header:iff.i"
		include	"header:collision.i"

		XREF	_RemQue,_InsQue
		public	_CopyDownDLE
		public	_SetUpHitBox

;; CopyDownDLE(DSP_PDLE DLE)
;; ===========
;; This copies down the current Bob for erasing
;;

_CopyDownDLE:	move.l	4(sp),a0
		lea.l	DLE_newx(a0),a1
                lea.l	DLE_oldx(a0),a0
		move.l	(a1)+,(a0)+	;X
                move.w	(a1)+,(a0)+	;Class
                move.l	(a1)+,(a0)+	;Image
		rts

;; SetUpHitBox(struct HitBox *HB,struct GraphObject *GOBJ)
;; ===========
;; Call this to set up a hitbox for the given GraphObject
;;

_SetUpHitBox:	
		move.l	4(sp),a0	;Get HitBox
                move.l	8(sp),a1	;Get Image
                clr.l	(a0)+	;and yoff
		move.w	GOBJ_width(a1),d0
                move.w	d0,(a0)+
                move.w	GOBJ_height(a1),(a0)
		subi.w	#1,(a0)
                subi.w	#1,-(a0)
		rts
#endasm
        
#include <hardware/custom.h>         
#include "scheduler.h"
#include "displist.h"
#include "collision.h"
#include "wave.h"
#include "view.h"

#include <graphics/view.h>
#include <exec/memory.h>
#include <graphics/gfxbase.h>
#include <graphics/text.h>
#include <graphics/sprite.h>
#include <graphics/gfx.h>

extern char Sched_Alive;

#undef StopCollisionCheckingOn
#undef DoCollisionCheckingOn
#undef DisplaySprite

WORD NumDLEsInQ;


#ifdef DEEP_DEBUG
#  undef DEEP_DEBUG
#endif

#ifdef P_CHECK
ULONG per_avg_displ_sum=0;
ULONG per_avg_displ_cnt=0;
#endif

/********************************
 * This is the Head for the 
 * Display List
 */

DSP_PDLE DSP_DisplayList;

DSP_PDLE DSP_GroundObjects;

/********************************
 * This holds the COL blocks for
 * all the good guys (us and bullets)
 */

DSP_PCOL DSP_GoodCollisions;
DSP_PCOL DSP_SpriteList;

/*
 * This file is placed on the CurrentQ and is never taken off
 *
 */

/**
 ** This routine is similar to setuphitbox except it sets the hit box
 ** to the area of the bob from the top left to its hot-spot, this
 ** allows shadows to be part of the bob easily.
 */
 
void SetUpHitBoxWithShadow(HB,Obj)
struct HitBox *HB;
struct GraphObject *Obj;
{
   register struct HitBox *RHitBox=HB;
   register struct GraphObject *RegObj=Obj;
   
   RHitBox->TXoff=RHitBox->TYoff=0;
   RHitBox->BXoff=RegObj->HotX;
   RHitBox->BYoff=RegObj->HotY;
}

void SetUpHitBoxForShip(HB,Obj)
struct HitBox *HB;
struct GraphObject *Obj;
{
   register struct HitBox *RHitBox=HB;
   register struct GraphObject *RegObj=Obj;
   
   RHitBox->TXoff=2;
   RHitBox->TYoff=2;
   RHitBox->BXoff=RegObj->Width-2;
   RHitBox->BYoff=RegObj->Height-2;
}

/**
 ** This is the actual collision check routine. It calls CollisionCheck for
 ** each DLE currently in the DisplayList. It is called from DoMainLoop
 ** when ever there in idle time every tick.
 **
 ** Note:
 ** Currently, no collision-checking should be done if scheduler delays
 ** begin. A watch-dog on it will prevent this.
 */

/**
 ** Call this to stop collision checking againts the Display Object
 ** when you remove it from the screen.
 */
 
void StopCollisionCheckingOn(DLE)
DSP_PDLE DLE;
{
   register DSP_PDLE d=DLE;
   if(d->flags&DLE_pending)
      (void)RemQue(d);
   d->flags&=~DLE_pending;
   d->name="Collision Off DLE";
}

/**
 ** Call this to enable collision checking against the display object
 ** DLE. This is done for all aliens and alien bullets and tokens.
 */
 
void DoCollisionCheckingOn(DLE)
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   if(D->flags&DLE_pending)
      (void)RemQue(D);
   D->flags|=DLE_pending;
   InsQue(DSP_DisplayList,D);
   D->name="Collision On DLE";
}

void DoGroundCheckingOn(DLE)
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   if(D->flags&DLE_pending)
      (void)RemQue(D);
   D->flags|=DLE_pending;
   InsQue(DSP_GroundObjects,D);
   D->name="Collision On DLE";
}

/**
 ** Call this to display a Bob onscreen.
 */
 
#undef DisplayBob
void DisplayBob(DLE)
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   if(D->OldClass!=CLS_none)
      XORBlit(D->OldImage,D->OldX,D->OldY);
   if(D->NewClass!=CLS_none)
      XORBlit(D->NewImage,D->NewX,D->NewY);
}

/** Call this to display a Sprite
 */

void DisplaySprite(DLE)
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   if(D->NewClass==CLS_Sprite)
      Move_Sprite(D->NewImage,D->NewX,D->NewY);
   else
      Move_Sprite(D->NewImage,-50,0);
}

/*
 * This routine initialises the above DisplayList
 *
 */
 
extern void EmptyFreeDLEQueue();
extern void EmptyFreeCOLQueue();

void GimmeQ(Q,alloc)
struct SCH_queue **Q;
struct SCH_queue *(*alloc)();
{
  if(!(*Q=(*alloc)()))dprintf("Can't get INRDL DLE");
  (*Q)->flink=*Q;
  (*Q)->blink=*Q;
}

void InitialiseRenderList()
{

  SCH_PEQE EQE;

  NumDLEsInQ=0;

/*
 * Put in CurrentQ
 *
 */

  EmptyFreeDLEQueue();
  EmptyFreeCOLQueue();

  GimmeQ(&DSP_DisplayList,AllocDLE);
  GimmeQ(&DSP_GroundObjects,AllocDLE);
  GimmeQ(&DSP_GoodCollisions,AllocCOL);
  GimmeQ(&DSP_SpriteList,AllocCOL);

}

/*
 * Scheduler memory routines
 *
 * Display List stuff
 */
 


extern void *AllocMem();

static DSP_PDLE DSP_FreeDLEs;

static void EmptyFreeDLEQueue()
{
  int j;
  DSP_PDLE t;
  DSP_FreeDLEs->flink=DSP_FreeDLEs;
  DSP_FreeDLEs->blink=DSP_FreeDLEs;
  t=DSP_FreeDLEs;
  for(j=1;j<MAXDLE;j++)
    InsQue(DSP_FreeDLEs,++t);
}

/* Allocate and intialise the EQE pool */

void AllocateFreeDLEQueue()
{ /* AllocateFreeDLEQueue */
  DSP_PDLE start;
  int j;
  start=(DSP_PDLE)AllocMem(sizeof(struct DisplayListEntry)*MAXDLE,0L);
  if(!start)
    DoAlert("InitFDQ-F: No memory for DLE's, decrease MAXDLE");
  DSP_FreeDLEs=start;
  EmptyFreeDLEQueue();
}

/* Free up the DLE pool */

void ReturnAllDLEs()
{
  if(DSP_FreeDLEs)
    FreeMem(DSP_FreeDLEs,sizeof(struct DisplayListEntry)*MAXDLE);
}

/* This checks to see if a DLE is active, should always be done prior
   to assigning DLE->flags */
   
/* This allocates a Display List Entry and returns its address */

DSP_PDLE AllocDLE()
{
  register DSP_PDLE DLE;
  /* Queue Empty */
  if (DSP_FreeDLEs->flink==DSP_FreeDLEs)
    DoAlert("AllocDLE-F: Can't Alloc DLE , increase MAXDLE");

  (DLE=(DSP_PDLE)RemQue(DSP_FreeDLEs->flink))->flags=0;
  return DLE;
}

/* Return the DLE to the free list
 * WARNING: Make sure you remove the DLE first before Freeing it! */

void FreeDLE(q)
DSP_PDLE q;
{
  InsQue(DSP_FreeDLEs,q);
  q->flags=0;
  q->name="Freed DLE";
}

/*
 * Scheduler memory routines
 *
 * Display List stuff
 */
 

DSP_PCOL DSP_FreeCOLs;


static void EmptyFreeCOLQueue()
{
  int j;
  DSP_PCOL t;
  DSP_FreeCOLs->flink=DSP_FreeCOLs;
  DSP_FreeCOLs->blink=DSP_FreeCOLs;
  t=DSP_FreeCOLs;
  for(j=1;j<MAXCOL;j++)
    InsQue(DSP_FreeCOLs,++t);
}

/* Allocate and intialise the CLP pool */

void AllocateFreeCOLQueue()
{ /* AllocateFreeCOLQueue */
  DSP_PCOL start;
  int j;
  start=(DSP_PCOL)AllocMem(sizeof(struct CollisionEntry)*MAXCOL,0L);
  if(!start)
    DoAlert("InitFCQ-F: No memory for COL blocks, decrase MAXCOL");

  DSP_FreeCOLs=start;
}

/* Free up the COL pool */

void ReturnAllCOLs()
{
  if(DSP_FreeCOLs)
    FreeMem(DSP_FreeCOLs,sizeof(struct CollisionEntry)*MAXCOL);
}

/* This allocates a Display List Entry and returns its address */

DSP_PCOL AllocCOL()
{
  /* Queue Empty */
  if (DSP_FreeCOLs->flink==DSP_FreeCOLs)
    DoAlert("AllocCOL-F: Can't alloc COL, increase MAXCOL");

  return RemQue(DSP_FreeCOLs->flink);
}

/* Return the COL to the free list
 * WARNING: Make sure you remove the COL first before Freeing it! */

void FreeCOL(q)
DSP_PCOL q;
{
  InsQue(DSP_FreeCOLs,q);
}
