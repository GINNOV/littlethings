
#ifndef GAMEH
#define GAMEH

#include "displist.h"
#include "scheduler.h"
#include "iff.h"

struct OurShipData {
  DSP_PDLE DLE;			/* Holds Cur X etc. */
  DSP_PCOL COL;			/* Pointer to COL block */
  ULONG flags;			/* Flags */

#define OSD_NewGame		1L
#define OSD_FireUp		2L
#define OSD_Homers		4L
#define OSD_SideLasers		8L
#define OSD_SweepLasers	       16L

  int (*mover)();		/* function to move object */
  int HorizSpeed;		/* Pixels left and right */
  int VertSpeed;		/* Pixels up and down */
  BYTE CurMSpeedUp;		/* Current Motion Speed Up */
  BYTE MaxBullets;
  BYTE BulletsLeft;		/* When zero can fire no more bullets */
  BYTE CurPower;		/* How many aliens he zaps in 1 bullet */
  BYTE Lives;			/* Number lives left */
  BYTE MaxDelay;		/* How long you wait for the ship to bank */
  BYTE Delay;			/* So you see the ship banking */
  BYTE CurImage;		/* Frame no of current ship */
  ULONG Score;			/* Score in game */
  BYTE Level;			/* Current Level of Game */
  short Penetration;		/* How far in the current level is she ?*/
  BYTE NumTokens;		/* Number of tokens */
  ULONG ExtraLifeScore;		/* Score at which next free life is given */
};

struct TurretBlock {
  struct TurretBlock *flink,*blink;
  DSP_PDLE DLE;			/* Holds Cur X Y etc. */
  DSP_PCOL COL;			/* Collision block for object */
  SCH_PEQE EQE;			/* EQE for token */
  BYTE Busy;			/* 1 if token on screen */
  BYTE flags;			/* flags */
#   define TUR_Swingleft 1

  BYTE MaxFDelay;		/* Speed of movement in frames */
  BYTE CurFDelay;		/* Counter for above */
  BYTE MaxIDelay;		/* Delay for animation delays */
  BYTE CurIDelay;		/* Counter for above */
  BYTE CurImage;		/* Current Image */
};

typedef struct TurretBlock SPC_Turret;
typedef struct TurretBlock *SPC_PTurret;

struct LevelBlock {
  BYTE LevelNum;		/* Level number */
  BYTE NumAliens;		/* Number of aliens on screen at once */
  BYTE MinAliens;		/* Minimum #aliens per wave */
  BYTE MaxAliens;		/* Maximum #laiens per wave */
  ULONG flags;
  
#define LB_SmallAliens			 1L
#define LB_BigAliens    		 2L
#define LB_Turrets         		 4L
#define LB_TurretHomers    		 8L
#define LB_IntelliPattern 		16L
#define LB_Satellite			32L
#define LB_ScrollHoriz			64L
#define LB_ScrollVert			128L
#define LB_FireAlways			256L

#define LB_HoldScroll			0x08000000L
#define LB_CycleOn			0x10000000L
#define LB_ScreenMask			0x20000000L
#define LB_ShipDead			0x80000000L
#define LB_NewLevel			0x40000000L

  BYTE NumSatellites;		/* Max #s on screen */
  BYTE NumTurrets;		/* Max #t on screen */
  BYTE NumAlienBullets;		/* Max #bullets on screen */
};

struct TurretMapBlock {
  short x;			/* Initial X */
  short y;			/* Initial y */
  short next;			/* How long till next one */
};

struct ExplosionDescr {
  struct ExplosionDescr *flink,*blink;
  DSP_PDLE DLE;			/* Holds X and Y */
  struct SpriteImage *Image;	/* Holds Explosion Image */
  char *param;			/* param to pass to below */
  void (*function)();		/* Function to call when explosion done */
  BYTE CurImage;		/* Holds current frame */
  BYTE Dx,Dy;
};

typedef struct ExplosionDescr SPC_Explosion;
typedef struct ExplosionDescr *SPC_PExplosion;

typedef struct {
   WORD x,y;
   WORD num;
} BonusDescriptor;

#define BONUS_200 0
#define BONUS_5000 1

extern struct TurretMapBlock Level_0[];

extern struct LevelBlock *CurrentLevel;
extern struct LevelBlock LevelBlk[5];
extern BYTE DoTokenNextWave;

extern struct OurShipData OurShip;
extern SPC_PTurret  FreeTurretList;
extern SPC_PExplosion FreeExplosions;
extern struct SpriteImage ExplosionImage[2];

#define MakeExplosion(f,p,x,y,dx,dy) SysMakeExplosion(f,p,x,y,dx,dy,&ExplosionImage[0],3)
#endif
