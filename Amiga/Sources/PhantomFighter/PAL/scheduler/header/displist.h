/*
 * Structures for Display List software
 *
 * Written by Billy Newport
 *
 * Modification List :
 * ===================
 * 05/04/88 BN  Created It!
 * 11/04/88 BN  Modified to Alert user on crashes
 */

#ifndef DISPLAYLISTH
#define DISPLAYLISTH

#include <exec/types.h>
#include "collision.h"
#include "iff.h"

/********************************************************************
 * This is the data structure used to buffer Screen Updates until
 * RenderDLIST flushes the queue. When you insert these into the
 * DisplayList you should set the -pending- bit in flags so that
 * if through collision detection the image is to be redisplayed
 * the queues integrity is preserved as before it is inserted this
 * bit is checked and if set the DLE is removed. If this did'nt happen
 * then we would Guru, and is thus considered a Good Thing!
 *
 */
 
struct DisplayListEntry {
  struct DisplayListEntry *flink,*blink; /* Queue pointers */
  DSP_PCOL COL;			/* For collisions */
  struct HitBox HitBox;		/* ditto */
  char *param;			/* Block for element */
  
  ULONG flags;			/* Flags */


#define DLE_DoCollision 1L
#define DLE_AlienParam  2L
#define DLE_OurShip     4L
#define DLE_collision	8L
#define DLE_Token	0x10L
#define DLE_Turret	0x20L
#define DLE_Bullet	0x40L
#define DLE_Satellite	0x80L
#define DLE_BigGuy	0x100L
#define DLE_SqueezyBug	0x200L
#define DLE_BabyBug	0x400L
#define DLE_Eye		0x800L
#define DLE_Iris	0x1000L
#define DLE_LavaEye	0x2000L
#define DLE_Bud		0x4000L
#define DLE_HangerBit	0x8000L

#define DLE_User3	      0x02000000L
#define DLE_User2	      0x04000000L
#define DLE_User1	      0x08000000L
#define DLE_User0	      0x10000000L
#define DLE_Mask	(long)0x2000000
#define DLE_Deadly	(long)0x4000000
#define DLE_pending     (long)0x8000000


  WORD  OldX,OldY;		/* Co-ords of image to be erased */
  BYTE OldClass;		/* Class of object to be erased here */
  BYTE *OldImage;		/* Image of object to be erased */
  WORD NewX,NewY;		/* Co-ords of image to be drawn */
  BYTE NewClass;		/* Class of object to be drawn */
  BYTE *NewImage;		/* Image of object to be drawn */
  WORD MaskOffset;		/* For Mask operations */
  char *name;			/* For Conversational debugging */
};

typedef struct DisplayListEntry DSP_DLE;
typedef struct DisplayListEntry *DSP_PDLE;

extern DSP_PDLE AllocDLE();
extern void FreeDLE();

extern DSP_PDLE DSP_DisplayList;
#define DisplaySprite(Spr) Move_Sprite(Spr->NewImage,Spr->NewX,Spr->NewY)
#define KillSprite(Spr) Move_Sprite(Spr->NewImage,-50,0)

#define DoCollisionCheckingOn(D) InsQue(DSP_DisplayList,D)
#define StopCollisionCheckingOn(D) (void)RemQue(D)

#define DisplayBob(DLE) \
   if((DLE)->OldClass)			\
      XORBlit((DLE)->OldImage,(DLE)->OldX,(DLE)->OldY);	\
   if((DLE)->NewClass)			\
      XORBlit((DLE)->NewImage,(DLE)->NewX,(DLE)->NewY);
   
#define DisplaySoftBob(DLE) \
   if((DLE)->OldClass)			\
      SmallBlit((DLE)->OldImage,(DLE)->OldX,(DLE)->OldY);	\
   if((DLE)->NewClass)			\
      SmallBlit((DLE)->NewImage,(DLE)->NewX,(DLE)->NewY);
   
#endif
