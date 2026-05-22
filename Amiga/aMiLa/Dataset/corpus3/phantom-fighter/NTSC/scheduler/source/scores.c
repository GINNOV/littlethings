/*******************************************************************
 *
 * Score routines for Phantom Fighter
 *
 * Written by Billy Newport 1988
 *
 */
 
#include "joystick.h"
#include <stdio.h>
#include <graphics/view.h>
#include <graphics/gfxmacros.h>
#include "scheduler.h"
#include "view.h"
#include "game.h"
#include "iff.h"

extern struct LevelBlock DemoLevel;
extern struct SpriteImage Stuff1Image;
extern struct BitMap *AllocBitMap(),*bm2;
extern struct RasInfo RasInfo1;
extern UWORD LunarCMap[32];
extern struct BitMap *bm;
extern struct RasInfo RasInfo2;
extern struct ViewPort VPort;
extern UWORD MainCopper[];


extern struct BitMap *bm_bottom;

extern struct SpriteImage BonusDigits;

char *HiScoreName[9]={
  "BIL","KEL","BAG","BOB","FRN",
  "MIK","DAM","JER","BIL"
};


ULONG HiScores[9]={100000,90000,80000,70000,60000,
		    20000,10000,5000,1000};

char *HiScoreFile="HiScore.dat";

char *HiScoreChars="ABCDEFGHIJKLMNOPQRSTUVWXYZ";

void LoadHighScores()
{
#ifdef qwerty
   FILE *fp;
   int i;
   if(!(fp=fopen(HiScoreFile,"r")))
      DoAnAlert("LoadHighScores-F: Could'nt open high score table");
#ifdef DEBUG
   dprintf("LoadHiScore-I: File open\n");
#endif
   for(i=0;i<9;i++) {
      fread(HiScoreName[i],1,4,fp);
      fread(&HiScores[i],1,4,fp);
   }
   fclose(fp);
#ifdef DEBUG
   dprintf("LoadHiScore-I: High Score File Loaded\n");
#endif
#endif
}

void SaveHighScores()
{
#ifdef qwerty
   FILE *fp;
   int i;
   fp=fopen(HiScoreFile,"w");
   for(i=0;i<9;i++) {
      fwrite(HiScoreName[i],1,4,fp);
      fwrite(&HiScores[i],1,4,fp);
   }
   fclose(fp);
#endif
}

ULONG divisors[]={1,10,100,1000,10000,100000};

/*******************************************
 * Print out a score at column Xoff
 */

extern void PrintDigit();
#asm
		public	_PrintDigit
                xref	_Stuff1Image

		include	"header:iff.i"
                
PrintLine	Macro                
		move.b	(a1),d0
                move.b	d0,(a0)		;Move a line
		lea.l	40(a0),a0	;Next line on screen
		adda.l	d1,a1		;Add bytesperrow
		endm
_PrintDigit:
                move.l	_Stuff1Image+4+SPRI_frames,a0
		moveq.l	#0,d1
                move.w	GOBJ_width(a0),d1		;BytesPerRow
		add.w	#15,d1
                lsr.w	#3,d1
                andi.w	#$fffe,d1
;
		move.l	4(sp),a0	;Screen
		move.l	8(sp),a1	;Digit
		PrintLine
		PrintLine
		PrintLine
		PrintLine
		PrintLine
		PrintLine
                rts
#endasm
 
void PrintScoreAt(Off,Score)
int Off;
ULONG Score;
{
   register char *Screen,*Digit;
   int tScore;
   struct GraphObject *Gobj=(struct GraphObject *)Stuff1Image.Frames[1];
   register int loop,rowloop;
   Screen=(char *)(bm_bottom->Planes[0])+Off;
   for(loop=5;loop>=0;loop--) {
      tScore=Score/divisors[loop];
      Score-=tScore*divisors[loop];
      Digit=(char *)Gobj->Image+tScore;
      PrintDigit(Screen++,Digit);
   }
}

void PrintScore(param,EQE)
ULONG *param;
SCH_PEQE EQE;
{
   struct GraphObject *Gobj=(struct GraphObject *)Stuff1Image.Frames[1];
   PrintScoreAt(25,*param);
   if(OurShip.Score>=OurShip.ExtraLifeScore) {
      if(++OurShip.Lives>9)OurShip.Lives=9;
      OurShip.ExtraLifeScore+=20000;
      PrintDigit((char *)bm_bottom->Planes[0]+38,(char *)Gobj->Image+
          OurShip.Lives);
   }
   ENQUEUEEVENT(EQE,EQE->period);
}

char AsciiStringForDigit[]="0123456789";

/*************************************************
 * Clear Playfield to black
 */

char TempBuffer[7]; 

void Cls()
{
  ClearBM();
}

void PrintHiScoreLine(i)
int i;
{
   SetAPen(4);			/* Green */
   Move(126+32,32+51+10*i);
   Text(bm,&AsciiStringForDigit[i+1],1);
   Text(bm,". ",2);
   Text(bm,HiScoreName[i],3);
   Text(bm," ",1);
   sprintf(TempBuffer,"%6d",HiScores[i]);
   Text(bm,TempBuffer,6);
}

/*************************************************
 * Routine to print out Hi-Score table
 *
 */

void PrintHiScoreTable()
{
  int i;
  Cls();
  SetAPen(1);				/* Yellow */
  Move(32+126,32+26);
  Text(bm,"HALL OF FAME",12);
  for(i=0;i<9;i++)
    PrintHiScoreLine(i);
} 

/*************************************
 * This returns the line he has achieved and shifts the others down
 *
 */
 
int GetHisLine(Score)
ULONG Score;
{
   int i,j;
   for(i=8;i>=0;i--)
     if(HiScores[i]>Score) break;
   i++;
   for(j=7;j>=i;j--) {
     strcpy(HiScoreName[j+1],HiScoreName[j]);
     HiScores[j+1]=HiScores[j];
   }
   strcpy(HiScoreName[i],"AAA");
   HiScores[i]=Score;
   return i;
}
   
/******************************************************
 * End of game routine
 *
 */
extern int ReadJoyStick();
extern struct RasInfo RasInfo2;
WORD ScoreDir;

void ScrollScoreScreen()
{
   if(CurrentLevel->flags&LB_ScrollVert) {
      if(RasInfo2.RyOffset==0||RasInfo2.RyOffset==bm2->Rows-1-VIEW_HEIGHT)
         ScoreDir=-ScoreDir;
      RasInfo2.RyOffset+=ScoreDir;
      SYS_MakeVPort(&VPort,MainCopper+58*2+1);
   } else {
      if(RasInfo2.RxOffset==0||RasInfo2.RxOffset==
      		bm2->BytesPerRow*8-1-VIEW_WIDTH)
         ScoreDir=-ScoreDir;
      RasInfo2.RxOffset+=ScoreDir;
      SYS_ScrollHoriz(MainCopper+58*2+1);
   }
}


void ReadInName(Line)
int Line;
{ /* ReadInName */
  int i;
  int CurCh;
  int CurPos;
  int JoyStk;
  CurPos=0;
  CurCh=HiScoreName[Line][CurPos]-'A';
  PrintHiScoreLine(Line);
  while(1) {
    SetAPen(2);
    Move(32+150+CurPos*8,32+51+10*Line);
    Text(bm,&HiScoreChars[CurCh],1);
    while(ReadJoyStick()) {
      WaitTOF();
      ScrollScoreScreen();
    }

    while(!(JoyStk=ReadJoyStick())) {
      WaitTOF();
      ScrollScoreScreen();
    }

    if(JoyStk&jy_left) {
      if(-1==(--CurCh))CurCh=25;
    }
    if(JoyStk&jy_right) {
      if(26==(++CurCh))CurCh=0;
    }
    if(JoyStk&jy_fire) {
      HiScoreName[Line][CurPos]=HiScoreChars[CurCh];
      Move(32+150+CurPos*8,32+51+10*Line);
      Text(bm,&HiScoreChars[CurCh],1);
      if(3==(++CurPos))break;
      CurCh=HiScoreName[Line][CurPos]-'A';
    }
  }
}

UWORD EndOfGameColors[16]={
   0x443, 0xff0, 0xf00, 0x0f0,
   0x00f, 0xfff, 0xf00, 0x0f0,
   0x443, 0x443, 0x443, 0x443,
   0x443, 0x443, 0x443, 0x443
};

void PrintOutPlug()
{
   Move(0,7);
   SetAPen(1);
   Text(bm_bottom,"PHANTOM FIGHTER",15);
   SetAPen(3);
   Text(bm_bottom,"         CODED BY ",18);
   SetAPen(2);
   Text(bm_bottom,"EMERALD",7);
}

void DoEndOfGame()
{
   int HisLine;
   char ScoreBuffer[80];
 
   Cls();				/* Clear Screen */

   PrintOutPlug();
   OFF_SPRITE
   SYS_LoadRGB4(&VPort,EndOfGameColors,16);
   if(OurShip.Level==4) {
      SetAPen(2);
      Move(100+32,70+32);
      Text(bm,"CONGRATULATIONS",15);
      SetAPen(1);
      Move(52+32,86+32);
      Text(bm,"YOU HAVE COMPLETED THE GAME",27);
      SetAPen(4);
      Move(56+32,102+32);
      Text(bm,"WAIT FOR PHANTOM FIGHTER 2",26);
      Move(84+32,110+32);
      SetAPen(5);
      Text(bm,"IT WILL BE THE GAME",19);
      HisLine=15*50;
   } else {
      SetAPen(1);
      Move(88+32,80+32);
      Text(bm,"G A M E    O V E R",18);
      sprintf(ScoreBuffer,"YOU SCORED :%06ld",OurShip.Score);
      Move(88+32,96+32);
      Text(bm,ScoreBuffer,18);
      HisLine=50*5;
   }
   
   for(;HisLine>0;--HisLine) WaitTOF();
   Cls();
   FadeInBackDrop(64);
   SYS_LoadRGB4(&VPort,EndOfGameColors,8);

   if(CurrentLevel->flags&LB_ScrollVert) {
      RasInfo2.RyOffset=bm2->Rows-1-VIEW_HEIGHT;
      ScoreDir=1;
   } else {
      RasInfo2.RxOffset=0;
      ScoreDir=-1;
   }

   PrintHiScoreTable();			/* Hi scores */
   if(OurShip.Score>HiScores[8]) {	/* Then a high score */
      HisLine=GetHisLine(OurShip.Score);
      PrintHiScoreTable();
      ReadInName(HisLine);
      SaveHighScores();
   }
   else
      for(HisLine=0;HisLine<200;++HisLine) {
         WaitTOF();
         ScrollScoreScreen();
      }

   Cls();
   FadeInBackDrop(64);
   ON_SPRITE
}

extern UWORD EmeraldLogoColors[];
extern struct SpriteImage EmeraldLogo;
extern struct BitMap *LBM;
extern struct ViewPort VP_bottom;

void StopIntroScreen(param,EQE)
char *param;
SCH_PEQE EQE;
{
   if(ReadJoyStick()&16)
      Sched_Alive=(char)0;
   else
      ENQUEUEEVENT(EQE,EQE->period);
}

void DoStartOfGame()
{
   WORD x;
   Cls();				/* Clear Screen */
   
   RasInfo2.RyOffset=0;
   RasInfo2.RxOffset=0;
   RasInfo2.BitMap=(struct BitMap *)EmeraldLogo.Frames[0];

   MainCopper[53*2+1]=0x38;		/* Normal width */
   MainCopper[55*2+1]=0x00;		/* ScrollCode 0 */
   MainCopper[56*2+1]=0x08;		/* Modulo 8 */
   MainCopper[57*2+1]=0x00;		/* Modulo -2 */

   SYS_MakeVPort(&VPort,MainCopper+58*2+1);

   EmeraldLogoColors[0]=0x443;
   for(x=0;x<8;++x) LunarCMap[x+8]=EmeraldLogoColors[x];
   SYS_LoadRGB4(&VPort,LunarCMap,16);

   PrintOutPlug();

   ON_DISPLAY
   SYS_UseCopper(MainCopper);
   OFF_SPRITE

   SetUpStartOfLevel();
   SetUpStartOfLevel();
   SetUpStartOfLevel();
   CurrentLevel=&DemoLevel;
/*   InitialiseWaves();
   InitialiseTokens();*/
   CreateEvent(StopIntroScreen,NULL,1,"Stop Demo");
   DoMainLoop();
   Cls();
   ON_SPRITE
}

/********************************************************
 * Score graphics onscreen			        *
 *****************************************_-=BN=-_******/

BonusDescriptor ScoreQueue[16];
ULONG ScoreQueuePtr=0;

void EraseBonusScore(Dsc,EQE)
BonusDescriptor *Dsc;
SCH_PEQE EQE;
{
   register BonusDescriptor *D=Dsc;
   register struct GraphObject *Obj;
   Obj=(struct GraphObject *)BonusDigits.Frames[D->num];
   XORBlit(BonusDigits.Frames[D->num],D->x-Obj->HotX,D->y-Obj->HotY);
   PURGEEQE(EQE);
   FREEEQE(EQE);
}

void DoBonusScore(num,x,y)
WORD num,x,y;
{
   register BonusDescriptor *Dsc;
   register struct GraphObject *Obj;
   Obj=(struct GraphObject *)BonusDigits.Frames[num];
   XORBlit(BonusDigits.Frames[num],x-Obj->HotX,y-Obj->HotY);
   ScoreQueuePtr=(ScoreQueuePtr+1)&15;
   Dsc=&ScoreQueue[ScoreQueuePtr];
   Dsc->num=num;
   Dsc->x=x;
   Dsc->y=y;
   CreateEvent(EraseBonusScore,Dsc,75,"Erase Bonus Score");
}
         
