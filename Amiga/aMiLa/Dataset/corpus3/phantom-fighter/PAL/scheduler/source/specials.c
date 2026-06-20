/****************************************************************
 * Source for special objects in the game			*
 ****************************************************************
 *								*
 * 1. Turrets							*
 * 2. Explosions
 * 3. Tokens							*
 * 4. Satellites
 * June 7, another day goes by and still no ......		*
 ****************************************************************/
 
#include "GameParam.h"

#include <exec/memory.h>
#include <graphics/view.h>
#include "Animation.h"
#include "game.h"
#include "displist.h"
#include "scheduler.h"
#include "collision.h"
#include "wave.h"
#include "copperfunc.h"
#include "token.h"
#include "debug.h"

extern ULONG rnd();

extern void CleanUpEvent();
extern BYTE AlienBulletsAvailable;
extern ULONG XBOffset;
extern struct RasInfo RS_bottom1;

extern WVE_PPARAM AllocAlien();
extern void FreeAlien();

TokenDescriptor Tokens[MAXTOKENS];
int TokenSP=0;


BYTE DoTokenNextWave;
BYTE BScroll2Go;
extern ULONG VBFunc;

WORD SatellitesAvailable;
extern struct SpriteImage TokenImage;
extern void *AllocMem();
extern char Sched_Alive;
extern struct SpriteImage ExplosionImage[2];
extern void StartToken();


/********************************************************
 * Allocate pool for explosions				*
 ********************************************************
 * Written by _-=BN=-_ May 88				*
 *******************************************************/
 
SPC_PExplosion FreeExplosions=NULL;


void AllocateExplosions()
{
  FreeExplosions=AllocMem(sizeof(SPC_Explosion)*(1+MAXEXPLOSIONS),MEMF_CLEAR);
  if(!FreeExplosions)
     DoAnAlert("AllocateExplosions-F: No memory for explosions");
}

void EmptyFreeExplosions()
{
  SPC_PExplosion p;
  int i;
  p=FreeExplosions->flink=FreeExplosions->blink=FreeExplosions;
  for(i=0;i<MAXEXPLOSIONS;i++)
     InsQue(FreeExplosions,++p);
}

void InitialiseExplosions()
{
  SPC_PExplosion t;
  EmptyFreeExplosions();
  t=FreeExplosions->flink;
  while(t!=FreeExplosions) {
    t->DLE=AllocDLE();
    t->DLE->param=(char *)t;
    t=t->flink;
  }
}
    
void FreeExplosionPool()
{
  if(FreeExplosions)
     FreeMem(FreeExplosions,sizeof(SPC_Explosion)*(1+MAXEXPLOSIONS));
}

static SPC_PExplosion AllocExplosion()
{
  if(FreeExplosions->flink==FreeExplosions)
     return NULL;
  return (SPC_PExplosion)RemQue(FreeExplosions->flink);
}

static void FreeExplosion(a)
SPC_PExplosion a;
{
  InsQue(FreeExplosions,a);
}

/*************************************************
 * This handles the explosion animation          *
 ************************************************/
 
static void DoExplosion(param,EQE)
SPC_PExplosion param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE;
   /******************************************************
    * Stop explosion when I run out of frames to display*/

   DLE=param->DLE;
   
   if((++param->CurImage)==param->Image->Count) {
      PURGEEQE(EQE);			/* Take out of scheduler */
      FREEEQE(EQE);			/* Give back EQE */
      CopyDownDLE(DLE);
      DLE->NewClass=CLS_none;
      DisplayBob(DLE);	/* Erase explosion */
      if(param->function)
         (*param->function)(param->param);	/* Call cleanup */
      FreeExplosion(param);		/* Give back explosion */
      return;
   }

   CopyDownDLE(DLE);
   DLE->NewX+=param->Dx;
   DLE->NewY+=param->Dy;
   DLE->NewImage=(char *)param->Image->Frames[param->CurImage];

   DisplayBob(DLE);

   /******************************************************
    * Reshedule Explosion				*/
 
   ENQUEUEEVENT(EQE,EQE->period);
}

void SysMakeExplosion(function,param,x,y,dx,dy,Image,period)
void (*function)();
char *param;
WORD x,y;
WORD dx,dy;
struct SpriteImage *Image;
WORD period;
{
  register SPC_PExplosion t;
  register DSP_PDLE DLE;
  register struct GraphObject *Obj;

  t=AllocExplosion();			/* Get explosion object */
  if(!t)return;				/* No explosions left */
  t->param=param;
  t->function=function;			/* Clean Up routine */

  t->CurImage=0;      

  t->Image=Image;		/* Big / small explosions */
  DLE=t->DLE;
  
  t->Dx=dx;
  t->Dy=dx;
  DLE->NewClass=t->Image->Class;
  DLE->NewImage=t->Image->Frames[0];	/* Print first explosion */
  Obj=(struct GraphObject *)DLE->NewImage;
  DLE->NewX=x-Obj->HotX;
  DLE->NewY=y-Obj->HotY;			/* Position explosion */
  DLE->OldClass=CLS_none;		/* Keep displaylist happy ! */
  
  DLE->flags=0;
  DisplayBob(DLE);		/* Print first frame */

  CreateEvent(DoExplosion,t,period,"DoExplosion");	/* Start Explosion */
  StartExplosionSound();		/* Start sound */

}

void ExplodeSquare(x,y,w,h,sx,sy)
WORD x,y,w,h,sx,sy;
{
   WORD i,j;
   for(i=x;i<x+w;i+=sx)
      for(j=y;j<y+h;j+=sy)
         SysMakeExplosion(NULL,NULL,i,j,0,0,&ExplosionImage[0],3);
}

/******************************************************************
 * Token software starts here    *
 ********************************/

static void TokenEvent(param,EQE)
char *param;
SCH_PEQE EQE;
{
   DoTokenNextWave=1;
   ENQUEUEEVENT(EQE,EQE->period);
}

/******************************************************************
 * This event moves the token    *
 ********************************/

static void AnimateToken(param,EQE)
TokenDescriptor *param;
SCH_PEQE EQE;
{
   register TokenDescriptor *Token=param;
   register WORD delta=1;
   register DSP_PDLE DLE=&param->DLE;

   CopyDownDLE(DLE);

   if(DLE->flags&DLE_collision) {
      DLE->flags&=~DLE_Token;
      delta=4;
      EQE->period=1;
   }

   if(CurrentLevel->flags&LB_ScrollVert)
      DLE->NewY+=delta;			/* Move with scroll */
   else
      DLE->NewX-=delta;

   if(DLE->flags&DLE_User0) {
      if(++Token->CurImage==TokenImage.Count)
         Token->CurImage=0;
      DLE->NewImage=TokenImage.Frames[Token->CurImage];
      SetUpHitBox(&DLE->HitBox,DLE->NewImage);
      DLE->flags&=~DLE_User0;
   }

   if(DLE->NewX<-32||DLE->NewY>VIEW_HEIGHT) {
      PURGEEQE(EQE);			/* Take out of scheduler */
      FREEEQE(EQE);
      DLE->NewClass=CLS_none;
      StopCollisionCheckingOn(DLE);
      DisplayBob(DLE);	/* ERASE it! */
      return;
   }
   DisplayBob(DLE);
   ENQUEUEEVENT(EQE,EQE->period);
}

void StartToken(x,y)
int x,y;
{

   register TokenDescriptor *Token;

   TokenSP=(TokenSP+1)&(MAXTOKENS-1);
   
   Token=&Tokens[TokenSP];
   Token->DLE.NewX=x;
   Token->DLE.NewY=y;
   Token->DLE.OldClass=CLS_none;
   Token->DLE.param=(char *)Token;
   Token->DLE.flags=DLE_DoCollision|DLE_Token;
   Token->Delay=Token->MaxDelay=33;
   Token->CurImage=0;
   Token->DLE.NewImage=(char *)TokenImage.Frames[0];
   SetUpHitBox(&Token->DLE.HitBox,TokenImage.Frames[0]);
   Token->DLE.NewClass=TokenImage.Class;
   DoCollisionCheckingOn(&Token->DLE);
   DisplayBob(&Token->DLE);
   CreateEvent(AnimateToken,Token,3,"AnimateToken");
}

LONG BotDirection;

void ScrollTheBottom(param,EQE)
char *param;
SCH_PEQE EQE;
{
   register int WantedPixel;
   WantedPixel=OurShip.NumTokens*80+33;

   if(WantedPixel!=RS_bottom1.RxOffset) {
      if(WantedPixel>RS_bottom1.RxOffset) {
         XBOffset=(RS_bottom1.RxOffset+=2);
         BotDirection=2;
      } else {
         XBOffset=(RS_bottom1.RxOffset-=2);
         BotDirection=-2;
      }
      VBFunc|=SCROLLHBOT;
   }

   ENQUEUEEVENT(EQE,EQE->period);
}

extern struct BitMap *bm_bottom1;

void PrintToken(a,str)
int a;
char *str;
{
   Move(48+80*a+((80-strlen(str))>>1),21);
   SetAPen(7);
   Text(bm_bottom1,str,strlen(str));
}

void PrintTokensOut()
{
   PrintToken(TOK_FASTER,"FASTER");
   PrintToken(TOK_LASER,"LASER");
   PrintToken(TOK_DOUBLE,"DOUBLE");
   PrintToken(TOK_PLASMA,"PLASMA");
   PrintToken(TOK_SIDE,"SIDES");
   PrintToken(TOK_HOMER,"HOMERS");
}

WORD Sat_VPos[2][2]={
   {-40,20},
   {360,20}
};

WORD Sat_HPos[2][2]={
   {300,-40},
   {300,200}
};

/***********************************************************
 * Launch vehicle for satellites can only be initialised   *
 * while Sprite machine is running.			   *
 *=========================================================*
 * Written by _-=BN=-_ June 88				   *
 **********************************************************/
 
static void LaunchSatellite(Pos,EQE)
WORD Pos[2];
SCH_PEQE EQE;
{
   StartSatellite(Pos[0],Pos[1]);
   PURGEEQE(EQE);
   FREEEQE(EQE);
}

void InitialiseSatellites()
{
   WORD i;
   
   for(i=0;i<CurrentLevel->NumSatellites;i++)
      if(CurrentLevel->flags&LB_ScrollVert)
         CreateEvent(LaunchSatellite,&Sat_VPos[i][0],2,"LaunchSatellite");
      else
         CreateEvent(LaunchSatellite,&Sat_HPos[i][0],2,"LaunchSatellite");
}      
  
void InitialiseTokens()
{
   DoTokenNextWave=0;
   CreateEvent(TokenEvent,NULL,50*10,"TokenEvent");	/* 5 seconds between tokens */
   CreateEvent(ScrollTheBottom,NULL,1,"ScrollBottom");
}


