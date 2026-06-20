#include <exec/types.h>
#include <graphics/view.h>
#include <graphics/sprite.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <exec/tasks.h>
#include <hardware/custom.h>

#include <exec/memory.h>
#include "scheduler.h"
#include "displist.h"
#include <stdio.h>
#include "game.h"
#include "debug.h"
#include "wave.h"


   extern void main();
   _main()
   {
      ULONG i;
      i=0x1000;
#   asm
   		include	'header:custom.i'
		move.w	#$7fff,_custom+dmacon
		move.w	#SETBIT+DMAEN+DSKEN,_custom+dmacon
   		move.w	#$7fff,_custom+intena
                move.w	_custom+intreqr,d0
                ori.w	#$8000,d0
                move.w	d0,_custom+intreq
                andi.w	#$7fff,d0
                move.w	d0,_custom+intreq
                move.w	#$2000,SR
                move.w	#$7fff,_custom+intena
#   endasm
      main();
   }


extern UWORD MainCopper[];
extern UWORD EndOfGameColors[];
extern struct ViewPort VPort;
extern int OpenLibraries();

/*extern struct Task *FindTask();*/


ULONG Mem;

void CleanUpEvent(param,EQE)
char *param;
SCH_PEQE EQE;
{
  Sched_Alive=(char)0;
}

extern void *AllocMem();



char d_buff[100];

void main()
{
  int as;
  SCH_PEQE p;
  DSP_PDLE q;
  OpenLibraries();

  dprintf("Phantom Fighter Goes BALLISTIC\n");
  dprintf("Written by Me (a rather serious person)\n");

  DisplayTitleScreen();

/*  LoadHighScores();*/
  LoadSideScreens();
  InitialiseLoadingScreen();
  LoadMusic();

  LoadAny();				/* Load alien shapes */
  LoadSounds();
  AllocateBugs();
  AllocateMissiles();
  AllocateSpriteList();
  AllocateExplosions();
  AllocateWVEBLK();
  AllocateWVEPARAM();
  AllocateFreeEventQueue();
  AllocateFreeDLEQueue();
  AllocateFreeCOLQueue();

  
  FreeUpTitleScreen();
  
  AllocView();
  
/*****************************************************************
 * Note: You must'nt use the scheduler before you can SetUpLevel *
 ****************************************************************/

  while(1) {
     InitialiseOurShip();			/* Setup our ship */
     PrepareEyeListsForNewGame();		/* All eyes active */
     DoStartOfGame();

     SYS_LoadRGB4(&VPort,EndOfGameColors,16);
     MainCopper[53*2+1]=0x30;		/* Normal width */
     MainCopper[55*2+1]=0xF0;		/* ScrollCode 0 */
     MainCopper[56*2+1]=0x06;		/* Modulo */
     MainCopper[57*2+1]=0x6e;		/* Modulo 0 */

     for(;;) {
        SetUpLevel();
        DoMainLoop();				/* case of doom */
        if(CurrentLevel->flags&LB_ShipDead) {
          CurrentLevel->flags&=~(LB_ShipDead|LB_NewLevel);
          if(!--OurShip.Lives)
            break;
        }
        if(CurrentLevel->flags&LB_NewLevel&&OurShip.Level==4)
          break;	/* Clearedit routine */
     }
     DoEndOfGame();
  }

}


