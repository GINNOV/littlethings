/***********************************************************
 * Bullet header files
 *
 * (C) Billy Newport
 *
 */

#ifndef BULLETHDR
#define BULLETHDR

#include <exec/types.h> 
#include "displist.h"
#include "scheduler.h"
#include "sprites.h"
#include "wave.h"

#define GIMMESPRITE 1
#define NOSPRITE    0

struct Missile_Param {
  struct Missile_Param *flink,*blink;
  DSP_PDLE DLE;				/* Used only for collision detection */
  DSP_PCOL COL;
  union {
     SpriteDescriptor *Spr;
     struct SpriteImage  *Bob;
  } Shape;
  union {
    WORD TimeOut;
    WORD AnimCount;
  } TimAnim;
  union {
    WORD Power;
    WORD CurImage;
  } PowImage;
  WORD Dx,Dy;
  WORD Mx,My;
  BYTE *Count;
  ULONG flags;

#define BUL_enemy 1L
#define BUL_homing 2L
#define BUL_parabola 4L
#define BUL_negatex 8L

  union {
     DSP_PDLE Enemy;			/* Enemy for homer */
     ANM_PELEM CurAnim;			/* For Patterned Bullets, CurOff */
  } Target;
  int (*function)();
};

typedef struct Missile_Param BUL_Missile;
typedef struct Missile_Param *BUL_PMissile;

extern BUL_PMissile FreeMissiles;	/* Queue Head for bullets */


#endif
