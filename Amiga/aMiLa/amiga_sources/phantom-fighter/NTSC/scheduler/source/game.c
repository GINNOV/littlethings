
/* Main Game routines */

#include "game.h"
#include "scheduler.h"
#include "debug.h"

#include <exec/types.h>
#include <exec/memory.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>

extern UWORD MainCopper[];
extern void ScrollTheBottom();
extern void StartBigGuy();
extern ULONG sys_time;

struct LevelBlock DemoLevel={
   0,				/* Level no. */ /* Cavern */
   4,				/* Num Aliens */
   4,				/* Min aliens */
   4,				/* Max aliens */
    LB_BigAliens|
    LB_ScrollHoriz,		/* flags */
   0,				/* #Satellites */
   0,				/* #Turrets */
   0				/* Max #Alien Bullets */
};
  
struct LevelBlock LevelBlk[5]={
  {
    0,				/* Level no. */ /* Cavern */
    4,				/* Num Aliens */
    4,				/* Min aliens */
    4,				/* Max aliens */
     LB_BigAliens|
     LB_ScrollHoriz,		/* flags */
    0,				/* #Satellites */
    0,				/* #Turrets */
    2				/* Max #Alien Bullets */
  },
  {
    1,
    6,				/* Num Aliens */ /* SandStorm */
    5,				/* Min aliens */
    6,				/* Max aliens */
     LB_BigAliens|
     LB_FireAlways|
     LB_Turrets|
     LB_Satellite|
     LB_CycleOn|
     LB_ScrollVert,		/* flags */
    1,				/* #Satellites */
    2,				/* #Turrets */
    3				/* Max #Alien Bullets */
  },
  {
    2,						 /* Cheese */
    6,				/* Num Aliens */
    3,				/* Min aliens */
    6,				/* Max aliens */
     LB_SmallAliens|
     LB_BigAliens|
     LB_Turrets|
     LB_ScrollHoriz,		/* flags */
    0,				/* #Satellites */
    4,				/* #Turrets */
    3				/* Max #Alien bullets */
  },
  {
    3,				/* LAVA */
    6,
    3,
    6,
     LB_SmallAliens|
     LB_BigAliens|
     LB_Turrets|
     LB_CycleOn|
     LB_TurretHomers|
     LB_ScrollVert,		/* flags */
    0,				/* #Satellites */
    4,				/* #Turrets */
    3				/* Max #Alien bullets */
  },
  {
    4,				/* Hangar */
    8,
    3,				/* Min aliens */
    8,				/* Max aliens */
    LB_ScrollHoriz,		/* flags */
    0,				/* #Satellites */
    4,				/* #Turrets */
    4				/* Max #Alien bullets */
  }
};


struct LevelBlock *CurrentLevel;	/* Current Level Block */

extern ULONG sys_time;

ULONG MemoryFree;
extern ULONG AvailMem();

char Hug_Me[80];
extern ULONG WatchDog;
extern LONG ReadKeyboard();
extern WORD ReadJoyStick();
extern void CleanUpEvent();

#define LMOUSE 0
#define JFIRE  1
#define JCHEAT -1

WORD CheatFlag=0;

WORD CheatCodes[]={JFIRE,LMOUSE,JFIRE,LMOUSE,JCHEAT};

void KeyBoardTask(param,EQE)
char *param;
SCH_PEQE EQE;
{
  register ULONG a;
  WORD CheatPos=0;
  WORD Code;

  if(!(*(BYTE *)0xbfe001&64)) {
#ifdef qwerty
     custom.intena=INTF_COPER;		/* Stop Game */
     custom.dmacon=15;			/* Stop sound */
     while(!(ReadJoyStick()&15));	/* Move JoyStick to start again */

     custom.intena=INTF_SETCLR|INTF_COPER;	/* Start Game */
#endif
     if(!(CurrentLevel->flags&LB_NewLevel)) {
        CurrentLevel->flags|=LB_NewLevel;
        CreateEvent(CleanUpEvent,NULL,1,"Cheat Mode");
     }
  }
  ENQUEUEEVENT(EQE,EQE->period);
}

void SetUpLevel()
{
  if(OurShip.Level!=-1)
    CurrentLevel=&LevelBlk[OurShip.Level];
  else
    CurrentLevel=&LevelBlk[0];
  sys_time=0;
  InitBLTObjects();
  InitialiseScheduling();			/* Do this */
  InitialiseSound();
  InitialiseScrolling();
  InitialiseRenderList();
  InitialiseFreeMissiles();
  StartOurShip();
  InitialiseWaves();
  InitialiseBugs();
  InitialiseTokens();
  InitialiseExplosions();

  MemoryFree=AvailMem(MEMF_CHIP);
  StartMusic();
  InitialiseEyes();
  CreateEvent(KeyBoardTask,NULL,7,"Check Keyboard");
}

void SetUpStartOfLevel()
{
  sys_time=0;
  InitBLTObjects();
  InitialiseScheduling();	/* Do this */
  InitialiseSound();
  InitialiseRenderList();	/* For collision detection */
  InitialiseFreeMissiles();
  StartMusic();
}
