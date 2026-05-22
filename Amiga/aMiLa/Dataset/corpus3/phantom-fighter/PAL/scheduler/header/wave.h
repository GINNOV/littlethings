/*
 * Wave data structures 
 *
 * Designed and coded by Billy Newport Apr 88
 *
 */
#include <exec/types.h>
#include "iff.h"
#include "scheduler.h"
#include "displist.h"

#ifndef WAVEDEFS
#define WAVEDEFS

struct anm_element {
  UBYTE Count;		/* Number of times element is repeated */
  BYTE FrameNo;		/* Frame number 0 to 7 for this */
  WORD Xoffset;
  WORD Yoffset;	/* X and Y offsets in pixels */
};

typedef struct anm_element ANM_ELEM;
typedef struct anm_element *ANM_PELEM;

#include "Animation.h"

struct WVE_DEF {
  struct WVE_DEF *flink,*blink;	/* queue stuff */
  ANM_PELEM pattern;		/* pattern to be used for this wave */
  ULONG flags;			/* Default flags for this */
  struct SpriteImage *Image;	/* type of alien */
  BYTE SizeWave;		/* Original Size of Wave */
  BYTE AliensDead;		/* Number of aliens killed in wave */
  BYTE Count;			/* Number of aliens currently in wave */
  WORD NumHitsToKill;
  WORD Score;
};

typedef struct WVE_DEF WVE_BLK;
typedef struct WVE_DEF *WVE_PBLK;

extern WVE_PBLK FreeWaveList;	/* Queue head for waves */


/*
 * Parameter blocks for the aliens
 *
 * Written by Billy Newport
 *
 */
struct AlienParam {
  struct AlienParam *flink,*blink;
  				/* queue pointers */
  ANM_PELEM CurAnim;		/* Points to current animation element */
  UBYTE Count;			/* Temporary count for counting elements */
  BYTE Class;			/* holds type of object */
  struct SpriteImage *FrameList;/* Ptr to Nx8 array of pointers ref`d as normal */
  		
		/* Accessed as FrameList[Y][X] 0<=Y<N 0<=X<2 */
  DSP_PDLE DLE;			/* holds an allocated DLE which holds CurX and Y */
  SCH_PEQE EQE;			/* EQE for this alien */
  WVE_PBLK WVE;			/* Pointer to parent wave */
  WORD NumHitsLeft;		/* Num hits left */
};

typedef struct AlienParam WVE_PARAM;
typedef struct AlienParam *WVE_PPARAM;


extern WVE_PPARAM FreeAlienList;/* Queue head for available Aliens */
extern WVE_PPARAM ActiveAlienList;	/* Head for active aliens */
extern WVE_PBLK   FreeWaveList;

extern struct SpriteImage JustMe;/* This is the good guy */
extern struct SpriteImage ScrollScreen;
extern struct SpriteImage TokenShape;

extern BYTE AliensAvailable;
#endif
