#include "GameParam.h"

#include "token.h"  
#include <intuition/intuitionbase.h>
#include <hardware/custom.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <graphics/copper.h>
#include <stdio.h>
#include "view.h"
#include "scheduler.h"
#include "game.h"
#include "debug.h"
#include "copperfunc.h"
#include "iff.h"
#include "wave.h"

#define FACEX 164
#define FACEY 139

extern struct SpriteImage LoadingScreen;
extern struct SpriteImage Stuff1Image;

UWORD LoadingColors[32];

struct BitMap *LBM=NULL;
struct ViewPort LVPort;
struct RasInfo LRS;

extern void StartBugLauncher();

extern struct SpriteImage FaceImage;

extern UWORD MainCopper[];
extern UWORD TitleCopper[];
extern UWORD LoadCopper[];

/*#define NODUALPF*/

extern struct SpriteImage PanelImage;
extern UWORD PanelColors[32];

extern void DisplayLoadingScreen();
extern struct SpriteImage ScreenMask;
extern void StartBigGuy();

WORD LastLevelLoaded=-1;
ULONG LastScore;

extern BYTE OKToDoWave;
extern void *AllocBitMap();
extern void *AllocMem();
extern ULONG HiScores[];
extern char *HiScoreName[9];
extern struct SpriteImage ScrollScreen;


ULONG CurVMod;

UWORD *Copper;
ULONG XOffset;
ULONG VBFunc;		/* 1 === VScroll 2 === HScroll 0 === Nout */


char *BackDropNames[5]={
  "back0",
  "back1",
  "back2",
  "back3",
  "back4",
};

#ifdef Hell_Has_Frozen_Over
struct IntuitionBase *IntuitionBase;  /* For opening Intuition library */
struct GfxBase *GfxBase;              /* For opening Graphics library */
#endif

struct ViewPort VPort;
struct RasInfo  RasInfo1;
struct ViewPort VP_bottom;
struct RasInfo  RS_bottom,RS_bottom1;
struct BitMap   *bm;
struct BitMap *bm_bottom=NULL;
struct BitMap *bm_bottom1;
struct BitMap   *view_bm;   /* The blitroutines are going to draw on this */

extern void CleanUpEvent();


/* Now dual playfield stuff */
struct RasInfo  RasInfo2;
struct BitMap   *bm2=NULL;

UWORD LunarCMap[16] = {
   0x0443, 0x0820, 0x0d50, 0x0f95, 
   0x0fff, 0x0fd7, 0x0860, 0x0302, 
   0x0732, 0x0775, 0x0AA8, 0x0DDA, 
   0x0430, 0x0963, 0x0DA6, 0x0FC8
};     

extern struct LevelBlock *CurrentLevel;

void PrintOutBottom()
{
  char buff[80];
  struct GraphObject *Gobj=(struct GraphObject *)Stuff1Image.Frames[1];

  PrintTokensOut();
  
  if(OurShip.Lives>9)OurShip.Lives=9;

  PrintDigit((char *)bm_bottom->Planes[0]+552,(char *)Gobj->Image+
       OurShip.Lives);
}


extern void ScrollVTop();                

void ScrollBackRoundDown(param,EQE)
char *param;
SCH_PEQE EQE;
{
  
  if(!(CurrentLevel->flags&LB_HoldScroll)) {
     if(RasInfo2.RyOffset>0){
        RasInfo2.RyOffset--;
        Copper=MainCopper;
        VBFunc|=SCROLLVTOP;		/* Signal to VBServer */
     } else {
        PURGEEQE(EQE);
        FREEEQE(EQE);
        OKToDoWave=0;
        CurrentLevel->flags|=LB_HoldScroll;
        CreateEvent(StartBigGuy,NULL,1,"StartBigGuy");
        return;
     }
     if((RasInfo2.RyOffset&511)==511) {
        CurrentLevel->flags|=LB_HoldScroll;
        CreateEvent(StartBugLauncher,NULL,1,"Start Bug Launcher");
     }
  }
    
  ENQUEUEEVENT(EQE,EQE->period);
}  

ULONG XBOffset;

char *BPlanes;

void ScrollBackRoundLeft(param,EQE)
char *param;
SCH_PEQE EQE;
{
  if(!(CurrentLevel->flags&LB_HoldScroll)) {
     if(RasInfo2.RxOffset<(bm2->BytesPerRow*8-VIEW_WIDTH)){
        Copper=(USHORT *)MainCopper;
        XOffset=(ULONG)(++RasInfo2.RxOffset);
        VBFunc|=SCROLLHTOP;				/* Signal to VBServer */
     }
     else {
        PURGEEQE(EQE);
        FREEEQE(EQE);
        OKToDoWave=0;
        CurrentLevel->flags|=LB_HoldScroll;
        CreateEvent(StartBigGuy,NULL,1,"StartBigGuy");
        return;
     }
     if((RasInfo2.RxOffset==618)&&(CurrentLevel->LevelNum==4)) {
        CurrentLevel->flags|=LB_HoldScroll;
        StartMajorHangerGuy(-100,40);
     }
  }
  ENQUEUEEVENT(EQE,EQE->period);
}  

UWORD BackDropCMap[32];
extern void SetUpVBI();

extern void RemoveLoadingScreen();

void LoadBitMap()
{
  ULONG Temp;
  UWORD i;
  char MaskName[50];
  int p;
  WORD row;
  WORD flag=0;

  ClearBM();
  if(CurrentLevel->flags&LB_NewLevel||(OurShip.Level==-1)) {
    
    flag=1;
    CurrentLevel->flags&=~LB_NewLevel;	/* Clear flag */

    if(OurShip.Level++==4)
       OurShip.Level=0;

    CurrentLevel=&LevelBlk[OurShip.Level];

    ScrollScreen.Frames[0]=(void *)bm2;

    sprintf(MaskName,"Mask%d",CurrentLevel->LevelNum);

    if(LastLevelLoaded!=OurShip.Level) {
/* Show loading screen */
       DisplayLoadingScreen();

/* Print out Score this Stage, LastScore set to sero in joystick.c */

/* Free LEvel memories */
       UnLoadObjectsForLevel();
       if(bm2) DeAllocBitMap(bm2);

       if(ScreenMask.Frames[0]) DeAllocBitMap(ScreenMask.Frames[0]);

/* Load BackDrop + Mask if required */
       if(CurrentLevel->flags&LB_ScreenMask)
          LoadImages(MaskName,&ScreenMask,BackDropCMap);

       LoadImages(BackDropNames[CurrentLevel->LevelNum],
              &ScrollScreen,BackDropCMap);


/* Load special level graphics, (eyes.c) */
       LoadObjectsForLevel();

       bm2=(struct BitMap *)ScrollScreen.Frames[0];

       LastLevelLoaded=OurShip.Level;

       RemoveLoadingScreen();

    }

/* Set moduloes, used in ScrollVTop (isrs.asm) */
    if(CurrentLevel->flags&LB_ScrollVert)
       CurVMod=40;
    else
       CurVMod=38;

    for(p=0;p<8;p++)
       LunarCMap[p+8]=BackDropCMap[p];

/* Make Background color BackDrops color 0 */
    LunarCMap[0]=LunarCMap[8];
    SYS_LoadRGB4(&VPort,LunarCMap,16);
    OurShip.Penetration=
       (CurrentLevel->flags&LB_ScrollVert)?(bm2->Rows-VIEW_HEIGHT)
    					   :0L;
  } else {
    if(CurrentLevel->flags&LB_ScrollVert) {
       p=RasInfo2.RyOffset;
       for(row=p&~1;row<OurShip.Penetration;row+=2) {
          RasInfo2.RyOffset=row;
          SYS_MakeVPort(&VPort,MainCopper+58*2+1);
          WaitTOF();
       }
    } else {
       p=RasInfo2.RxOffset;
       for(row=p&~1;row>=OurShip.Penetration;row-=2) {
          RasInfo2.RxOffset=row;
          SYS_ScrollHoriz(MainCopper+58*2+1);
	  WaitTOF();
       }
    }
  }

  RasInfo1.BitMap=bm;

/* Inset Blit bitmap for clipping */
/* 32 pixel border around it, for hard-clipping of bobs */

  RasInfo1.RxOffset=RasInfo1.RyOffset=32L;
  RasInfo2.BitMap=bm2;
  if(CurrentLevel->flags&LB_ScrollHoriz)
     RasInfo2.RxOffset=1L;
  else
     RasInfo2.RxOffset=0L;
  RasInfo2.RyOffset=0L;

  if(CurrentLevel->flags&LB_ScrollVert) /* Start at bottom for up/down scroll */
    RasInfo2.RyOffset=OurShip.Penetration;
  if(CurrentLevel->flags&LB_ScrollHoriz)
    RasInfo2.RxOffset=1|OurShip.Penetration;

  RasInfo1.Next=&RasInfo2;
  VPort.Modes|=DUALPF;
  RS_bottom1.RxOffset=OurShip.NumTokens*80+33;

  SYS_MakeVPort(&VPort,MainCopper+58*2+1);
  SYS_MakeVPort(&VP_bottom,MainCopper+100*2+1);

  if(flag) {
     if(CurrentLevel->flags&LB_ScrollVert)
        row=0;
     else
        row=bm2->BytesPerRow*8-1-VIEW_WIDTH;

     SYS_UseCopper(MainCopper);
     ON_SPRITE

     while(1)
        if(CurrentLevel->flags&LB_ScrollVert) {
           RasInfo2.RyOffset=row;
           SYS_MakeVPort(&VPort,MainCopper+58*2+1);
           WaitTOF();
           row+=16;
           if(row>=bm2->Rows-VIEW_HEIGHT)break;
        } else {
           RasInfo2.RxOffset=row;
           SYS_ScrollHoriz(MainCopper+58*2+1);
           WaitTOF();
           row-=16;
           if(row<0) break;
        }

     if(CurrentLevel->flags&LB_ScrollVert)
        RasInfo2.RyOffset=bm2->Rows-VIEW_HEIGHT;
     else
        RasInfo2.RxOffset=1;
     SYS_MakeVPort(&VPort,MainCopper+58*2+1);
  }

/*  RasInfo2.RxOffset=801;*/

  SYS_MakeVPort(&VPort,MainCopper+58*2+1);
  SYS_MakeVPort(&VP_bottom,MainCopper+100*2+1);

  SYS_UseCopper(MainCopper);
  ON_SPRITE

}

/**************************************************************
 * This Initialises scrolling for the current Level
 *
 */

void InitialiseScrolling()
{
  PrintOutBottom();

/* Load next backdrop if needed, and scroll back backdrop when
   you, die */
  LoadBitMap();

/* Clear HoldScroll, when set Scroll events don't scroll the screen */
  CurrentLevel->flags&=~LB_HoldScroll;

/* Create Scroll Event */
  if(CurrentLevel->flags&LB_ScrollHoriz) {
    sys_time=0;
    CreateEvent(ScrollBackRoundLeft,NULL,SCROLLTICKS,"ScrollL");
  }
  if(CurrentLevel->flags&LB_ScrollVert) {
    sys_time=0;
    CreateEvent(ScrollBackRoundDown,NULL,SCROLLTICKS,"ScrollD");
  }

  ClearBM();	/* Clear screen again */
}

int OpenLibraries()
{
return(TRUE);
}

extern ANM_ELEM SpacePortSeq[];

void AllocView()
{
/* Add dx and dyoffsets to Spaceport sequence */
  SpacePortSeq[0].Xoffset+=118+14;
  SpacePortSeq[0].Yoffset+=30+2;
  
/*------ Get a BitMap ---------*/
  bm  = AllocBitMap(VIEW_WIDTH+64,VIEW_HEIGHT+96,VIEW_DEPTH,0Xff);
  bm2 = AllocBitMap(VIEW_WIDTH,500,VIEW_DEPTH,0Xff);

bm_bottom = (struct BitMap *)PanelImage.Frames[0];
bm_bottom1= AllocBitMap(32+(MAXTOKENS+1)*80,32,1,0xff);
bm_bottom1->Planes[1]=bm_bottom1->Planes[0];
bm_bottom1->Depth=2;
BPlanes=(char *)&bm_bottom1->Planes[0];

view_bm = bm;		/* For blits */

VPort.Modes      = DUALPF;
VPort.RasInfo    = &RasInfo1;

/*--- set the  ViewPort to the define settings ---*/
VP_bottom.Modes      = DUALPF;
VP_bottom.RasInfo    = &RS_bottom;

/* Prepare the RasInfo's */
RasInfo1.BitMap   = bm;
RasInfo1.RxOffset = 32L;
RasInfo1.RyOffset = 32L;

RasInfo1.Next     = &RasInfo2;

RasInfo2.BitMap   = bm2;
RasInfo2.RxOffset = 0L;
RasInfo2.RyOffset = 0L;
RasInfo2.Next     = NULL;

RS_bottom.BitMap   = bm_bottom;		/* Tokens ViewPort */
RS_bottom.RxOffset = 0L;
RS_bottom.RyOffset = 0L;
RS_bottom.Next     = &RS_bottom1;

RS_bottom1.BitMap   = bm_bottom1;		/* Tokens ViewPort */
RS_bottom1.RxOffset = 33L;
RS_bottom1.RyOffset = 0L;
RS_bottom1.Next     = NULL;

/* Display the screens */
ClearBM();
SYS_MakeVPort(&VPort,MainCopper+58*2+1);
SYS_MakeVPort(&VP_bottom,MainCopper+100*2+1);
SYS_LoadRGB4(&VP_bottom,PanelColors,8);

}


struct SpriteImage TitleScreen;
UWORD TitleCMap[32];

void DisplayTitleScreen()
{
   WORD i;
  
   OFF_DISPLAY
   LoadImages("Title-Screen",&TitleScreen,TitleCMap);
   bm=(struct BitMap *)TitleScreen.Frames[0];
   VPort.Modes      = SPRITES;
   VPort.RasInfo    = &RasInfo1;
   RasInfo1.BitMap   = bm;
   RasInfo1.RxOffset = 0L;
   RasInfo1.RyOffset = 0L;
   RasInfo1.Next     = NULL;
   SYS_MakeVPort(&VPort,TitleCopper+26*2+1);
   SYS_UseCopper(TitleCopper);

   SYS_LoadRGB4(&VPort,TitleCMap,16);      
   ON_DISPLAY
   WaitTOF();
   OFF_SPRITE
}

void FreeUpTitleScreen()
{
OFF_DISPLAY
DeAllocBitMap(bm);
}

UWORD BlankColors[32]={
   0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0
};

extern void FadeInLoadingScreen();

void InitialiseLoadingScreen()
{

   int i;

   LBM=(struct BitMap *)LoadingScreen.Frames[0];

   LVPort.Modes      = SPRITES;
   
   LVPort.RasInfo    = &LRS;
   
   LRS.BitMap   = LBM;
   LRS.RxOffset = 0L;
   LRS.RyOffset = 0L;
   
   LRS.Next     = NULL;
   
   /* Display the screens */
   SYS_MakeVPort(&LVPort,LoadCopper+26*2+1);
   
   SYS_LoadRGB4(&LVPort,LoadingColors,16);
}

void DisplayLoadingScreen()
{
   int i;

   SYS_LoadRGB4(&LVPort,BlankColors,16);
   
   BlitFace(FaceImage.Frames[0],FACEX,FACEY);

   SYS_UseCopper(LoadCopper);
   for(i=0;i<16;++i) LoadCopper[2+i+i]=0x180+i+i;	/* Kludge ughhh */
   ON_DISPLAY
   SetUpVBI();
   FadeInLoadingScreen(0);
}

void RemoveLoadingScreen()
{
   custom.intena=0x7fff;
}

UWORD LessenColor(RGB,Factor)
UWORD RGB;
{
   UBYTE R,G,B;
   R=(RGB>>8);
   G=(RGB>>4)&15;
   B=RGB&15;
   R=(R*Factor)>>8;
   G=(G*Factor)>>8;
   B=(B*Factor)>>8;
   return (R<<8)+(G<<4)+B;
}

void FadeDownBackDrop(Amount)
int Amount;
{
   UWORD TonedColors[16];
   int i,j;
   for(i=0;i<16;++i)
      TonedColors[i]=LunarCMap[i];

   for(i=256;i>Amount;i-=3) {
      for(j=8;j<16;++j)
         TonedColors[j]=LessenColor(LunarCMap[j],i);
      SYS_LoadRGB4(&VPort,TonedColors,16);
   }
}

void FadeInBackDrop(Amount)
int Amount;
{
   UWORD TonedColors[16];
   int i,j;
   for(i=0;i<16;++i)
      TonedColors[i]=LunarCMap[i];

   for(i=Amount;i<257;i+=3) {
      for(j=8;j<16;++j)
         TonedColors[j]=LessenColor(LunarCMap[j],i);
      SYS_LoadRGB4(&VPort,TonedColors,16);
   }
   SYS_LoadRGB4(&VPort,LunarCMap,16);
}

void FadeInLoadingScreen(Amount)
int Amount;
{
   UWORD TonedColors[16];
   int i,j;

   for(i=Amount;i<257;i+=3) {
      for(j=0;j<16;++j)
         TonedColors[j]=LessenColor(LoadingColors[j],i);
      SYS_LoadRGB4(&LVPort,TonedColors,16);
   }
   SYS_LoadRGB4(&LVPort,LoadingColors,16);
}

UWORD LVB_Delay1;
UWORD LVB_Frame;

void (*LVB_Function)();
extern void LVB_BlitFace();

void LVB_BlitFace2()
{
   register UWORD Temp;
   if(LVB_Delay1==1||LVB_Delay1==6) {
      Temp=LoadCopper[27];
      LoadCopper[27]=LoadCopper[25];
      LoadCopper[25]=LoadCopper[23];
      LoadCopper[23]=LoadCopper[21];
      LoadCopper[21]=LoadCopper[19];
      LoadCopper[19]=Temp;
   }
   if(!--LVB_Delay1) {
      LVB_Delay1=8;
      if(LVB_Frame==0) {
         LVB_Delay1=1;
         LVB_Function=LVB_BlitFace;
      }
      else
         BlitFace(FaceImage.Frames[--LVB_Frame],FACEX,FACEY);
   }
}


void LVB_BlitFace()
{
   register UWORD Temp;
   if(LVB_Delay1==1||LVB_Delay1==6) {
      Temp=LoadCopper[27];
      LoadCopper[27]=LoadCopper[25];
      LoadCopper[25]=LoadCopper[23];
      LoadCopper[23]=LoadCopper[21];
      LoadCopper[21]=LoadCopper[19];
      LoadCopper[19]=Temp;
   }
   if(!--LVB_Delay1) {
      LVB_Delay1=8;
      BlitFace(FaceImage.Frames[LVB_Frame++],FACEX,FACEY);
      if(LVB_Frame==FaceImage.Count) {
	 LVB_Delay1=1;
         LVB_Function=LVB_BlitFace2;
      }
   }
}

void LVB_DelayRoutine()
{
      LVB_Function=LVB_BlitFace;
      LVB_Frame=0;
      LVB_Delay1=8;
}

extern UWORD SPR_BlankSprite[];

void LVB_Server()
{
   register int i;
   UWORD Temp;
   for(i=0;i<8;++i)
      custom.sprpt[i]=(APTR)SPR_BlankSprite;
   if(LVB_Function) (*LVB_Function)();
}

void SetUpVBI()
{
   SetUpLoadVectors();
   LVB_Delay1=10;
   LVB_Function=LVB_DelayRoutine;

   custom.intena=INTF_SETCLR|INTF_INTEN|INTF_VERTB;
}

