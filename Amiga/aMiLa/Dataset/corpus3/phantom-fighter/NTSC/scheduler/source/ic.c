/**********************************************************
 * Vertical blank interrupt generator for sys_time        *
 **********************************************************
 * Written by:						  *
 * ===========						  *
 * Billy Newport					  *
 *********************************************************/

 
#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/view.h>
#include <exec/interrupts.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>
#include <graphics/gfxmacros.h>
#include <stdio.h>
#include "view.h"
#include "interrupts.h"
#include "displist.h"
#include <graphics/sprite.h>
#include "debug.h"
#include "scheduler.h"
#include "game.h"
#include "wave.h"

#include "blits.h"
extern UWORD *Copper;
extern struct SimpleSprite Sprites[8];
extern SCH_PEQE CurrentEQE;
extern ULONG Intro_Color[2];
extern void IntroVBServer();

BLT_Object BLT_ObjectList[MAXBLITS];

extern UWORD MainCopper[];


unsigned short BLTListRead=0;
unsigned short BLTListWrite=0;

extern ULONG sys_time;

extern ULONG VBFunc;

extern void CopperServer();
extern void BLTServer();
ULONG BlitFlag;

extern void *AllocMem();
extern void *Remque();

extern void ScrollHTop(),ScrollHBot(),ScrollVTop(),ReloadBot();

/*
 * Bit assignments for VBFunc:
 * Bit No		Function
 *   0-2		None Must Be Zero
 *   3			Scroll Top Screen Vertical
 *   4			Scroll Top Horizontal
 *   5			Scroll Bottom Horizontal
 *   6			Reload Bottom Plane Pointers
 *   7-15		None
 *
 * And noe the array of functions. There is some redundancy
 * but in the interest of safety we will fill 'em all out
 * Need the extra one at the end so that we can end the last one
 * with a NULL
 */
 
void (* VFunctions[])()={
   /* 0000 */ NULL,NULL,NULL,NULL,
   /* 0001 */ ScrollVTop,NULL,NULL,NULL,
   /* 0010 */ ScrollHTop,NULL,NULL,NULL,
   /* 0011 */ ScrollVTop,ScrollHTop,NULL,NULL,
   /* 0100 */ ScrollHBot,NULL,NULL,NULL,
   /* 0101 */ ScrollHBot,ScrollVTop,NULL,NULL,
   /* 0110 */ ScrollHBot,ScrollHTop,NULL,NULL,
   /* 0111 */ ScrollHBot,ScrollVTop,ScrollHTop,NULL,
   /* 1000 */ ReloadBot,NULL,NULL,NULL,
   /* 1001 */ ReloadBot,ScrollVTop,NULL,NULL,
   /* 1010 */ ReloadBot,ScrollHTop,NULL,NULL,
   /* 1011 */ ReloadBot,ScrollVTop,ScrollHTop,NULL,
   /* 1100 */ ReloadBot,ScrollHBot,NULL,NULL,
   /* 1101 */ ReloadBot,ScrollHBot,ScrollVTop,NULL,
   /* 1110 */ ReloadBot,ScrollHBot,ScrollHTop,NULL,
   /* 1111 */ ReloadBot,ScrollHBot,ScrollVTop,ScrollHTop,
   /* oops */ NULL,NULL,NULL,NULL
};
void PrintSchedQ(Q)
SCH_PEQE Q;
{
   register SCH_PEQE EQE;
   EQE=Q;
   while((EQE=EQE->flink)!=Q)
      dprintf("         Time %6ld Name %s\n",EQE->expire,EQE->name);
}

extern DSP_PDLE DSP_DisplayList;

void PrintDLEQ(Q)
DSP_PDLE Q;
{
   register DSP_PDLE DLE;
   DLE=Q;
   while((DLE=DLE->flink)!=Q) {
      dprintf("         Name %8lx %s,",DLE->flags,DLE->name);
      if(DLE->flags&DLE_Token)
         dprintf("Token");
      if(DLE->flags&DLE_Eye)
         dprintf("Eye");
      if(DLE->flags&DLE_AlienParam)
         dprintf("Alien");
      if(DLE->flags&DLE_Bullet)
         dprintf("Bullet");
      dprintf("\n");
   }
}

extern ULONG PrevEQEPtr;
extern char *PrevEQENames[32];

void WaitLeftButton()
{
   while(*((char *)0xbfe001)&64);
}

extern WORD NumDLEsInQ;

void PrintStatus()
{
   SCH_PEQE EQE;
   register char *String;
   int i;
   
   dprintf("\n\nWatch Dog detected crash at time %d\n",sys_time);

   dprintf("Status:-\n");

   dprintf("   #DLEs %d\n",NumDLEsInQ);
   dprintf("   Display List:-\n");
      PrintDLEQ(DSP_DisplayList);
   dprintf("-------------------\n");
   WaitLeftButton();
   dprintf("   Scheduling:-\n");
   dprintf("      Current EQE :-\n");
   dprintf("          %s\n",CurrentEQE->name);
   dprintf("      Pending\n");
   for(i=0;i<NUMPARTITIONS;++i)
      PrintSchedQ(SCH_GQ_Event_Queue[i]);
   dprintf("----------------------------------\n");
   dprintf("Ship status :- Left %d Max %d\n",OurShip.BulletsLeft,
   					     OurShip.MaxBullets);
   if(OurShip.flags&OSD_Homers)dprintf("Homers ");
   if(OurShip.flags&OSD_SideLasers)dprintf("Sides ");
   dprintf("\n");
   dprintf("Press Left Mouse Button\n");
   WaitLeftButton();
   dprintf("\nLast EQE's used:\n");
   for(i=1;i<=32;++i) {
      String=PrevEQENames[(PrevEQEPtr-i)&31];
      if(String)
         dprintf("# %2d : %s\n",i,String);
   }
}

void MyDebug()
{
   PrintStatus();
   while(1);
}





/***************************************************
 * C function to wait till blitter finished        *
 ***************************************************
 * Written by -=BN=- May 88                        *
 *						   *
 **************************************************/
 
extern void Wait_Blit();


UWORD BottomSave[24];


void SaveBottomBPLPTRs()
{
  register int i;
  for(i=90*2;i<102*2;i++)
    BottomSave[i-180]=Copper[i];
}

void ReloadBot()
{
  register int i;
  return;
}

extern void ColorCycler();

void StartCycleInt()
{
   if(CurrentLevel->flags&LB_CycleOn)
      custom.intena=INTF_SETCLR|INTF_VERTB;
   
}

void SetUpInterrupt()
{
   Copper=MainCopper;
   InitialiseSprites();
   VBFunc=0;
   SaveBottomBPLPTRs();
   BlitFlag=0;
   BLTListRead=BLTListWrite=0;

   custom.intena=0x7fff;			/* none */
   SetAutoVector();
   custom.intreq=0x7fff;
   custom.intena=INTF_SETCLR|INTF_INTEN|INTF_COPER;	/* Gimme Copper */
   StartCycleInt();
}

void StopCycleInt()
{
   custom.intena=INTF_VERTB;
}

void RemoveInterrupt()
{
   int i;
   custom.intena=INTF_INTEN|INTF_COPER;			/* No more copper please */
   custom.intreq=0x7fff;			/* Nasty pending sound intertupt */
   custom.dmacon=0x000f;			/* Nasty sound my precious */

   ClearAutoVector();
   StopCycleInt();

   InterruptsOn;
}

extern UWORD LoadCopper[];
extern UWORD SPR_BlankSprite[];


/********************
 * Allocate memory for BLTOjbects
 */
 

void InitBLTObjects()
{
   BLTListRead=BLTListWrite=0;
}

extern struct BitMap *LBM;

void BlitFace(Object,x,y)
struct GraphObject *Object;
ULONG x,y;
{
   UWORD DstMod;
   ULONG DstOffset;
   UWORD Shift;
   ULONG ImageSize;
   int i;
   register ULONG Mask;
   register ULONG Temp;
   register char **Planes;
   register ULONG Image;
      
   /* Clip Bob wholly */
   
   /* Calculate moduloes first */

   x-=Object->HotX; y-=Object->HotY;
   
   Temp=((Object->Width+15)>>3)&~1;		/* Get width in bytes */
   DstMod=LBM->BytesPerRow-(Temp+2);	/* nn bytes across,
	   					   backup 2 for shift */
   ImageSize=Temp*Object->Height;		/* Get Size of a bob plane */
   DstOffset=y*LBM->BytesPerRow+(x>>3);	/* Get Plane offset of blit */
   Shift=x&15;
   
   custom.bltafwm=0xffff;
   custom.bltalwm=0;

   custom.bltcon0=SRCA|SRCB|SRCC|DEST|0xca|(Shift<<12);
   custom.bltcon1=Shift<<12;
   custom.bltamod=-2;
   custom.bltbmod=-2;
   custom.bltdmod=DstMod;
   custom.bltcmod=DstMod;
   /* Make blit one word wider coz' of shift */

   Temp=(Object->Height<<6)+(Temp>>1)+1;

   Image=(ULONG)Object->Image;
   Mask=Image+ImageSize*LBM->Depth;
   Planes=(char **)&LBM->Planes[0];

   for(i=0;i<LBM->Depth;++i) {
      custom.bltbpt=(APTR)(Image+ImageSize*i);
      custom.bltapt=(APTR)Mask;
      custom.bltdpt=custom.bltcpt=(APTR)((char *)*Planes+++DstOffset);
      custom.bltsize=Temp;
      WaitBlit();
   }
}

