#include "Eyes.h"
#include "wave.h"
#include "BigGuys.h"
#include "displist.h"
#include "scheduler.h"
#include "game.h"
#include "GameParam.h"
#include "iff.h"
#include "Animation.h"

extern int rnd();

extern struct SpriteImage ClockWork;

#define SCALE_FACTOR 256
#define SCALE_SHIFT 8

BigGuyDescriptor TheGuys[MAXBIGGUYS];
extern struct SpriteImage FireBall_16;

HangerGuy HangerGuyPool[NUMSEGHANGER];
MajorHangerDescriptor HangerXY[NUMSEGHANGER*2];

void StartMajorHangerGuy();
void StartMajorCircleGuy();

WORD HangerPtr=0;
WORD HangerXYPtr=0;

WORD TheGuysPtr=0;
WORD BigGuysOnScreen;
   
extern BYTE AlienBulletsAvailable;
extern void CleanUpEvent();

extern ANM_ELEM GuyLev_0[];
extern ANM_ELEM GuyLev_1a[];
extern ANM_ELEM GuyLev_1b[];

extern ANM_ELEM LavaBallLeft[];
extern ANM_ELEM LavaBallRight[];

void AnimateALavaBall(param,EQE)
BigGuyDescriptor *param;
SCH_PEQE EQE;
{
   register BigGuyDescriptor *Guy=param;

   MoveAlongPath(&Guy->Path,Guy->DLE);
   EnqueueEvent(EQE,EQE->period);
}

void MakeLavaBall(pattern)
ANM_PELEM pattern;
{
   register BigGuyDescriptor *Guy;
   register DSP_PDLE DLE;

   TheGuysPtr=(TheGuysPtr+1)&(MAXBIGGUYS-1);
   Guy=&TheGuys[TheGuysPtr];
   DLE=Guy->DLE=AllocDLE();
   DLE->param=(char *)Guy;
   DLE->flags=0;
   DoCollisionCheckingOn(DLE);
   DLE->flags|=DLE_Deadly;
   DLE->NewClass=DLE->OldClass=CLS_none;
   DLE->NewX=-100;
   DLE->NewY=-100;
   Guy->Path.PathTable=pattern;
   Guy->Path.CurAnim=NULL;		/* Force x y load */
   DoAfterAndRepeat(AnimateALavaBall,Guy,2,
              "Animate LavaBall",TheGuysPtr&1+1);
}

void AnimateAGuy(param,EQE)
BigGuyDescriptor *param;
SCH_PEQE EQE;
{
   register BigGuyDescriptor *Guy=param;
   register DSP_PDLE DLE;
   register struct GraphObject *Obj;

   DLE=Guy->DLE;
   
   CopyDownDLE(DLE);

   if(DLE->flags&DLE_collision) {	/* He's dead */

      --BigGuysOnScreen;
      DLE->NewClass=CLS_none;		/* Erase him */
      DisplayBob(DLE);			
      PURGEEQE(EQE);			/* Take out of scheduler */
      FREEEQE(EQE);
      StopCollisionCheckingOn(DLE);	/* Stop collisioning */
      Obj=(struct GraphObject *)DLE->NewImage;
      ExplodeSquare(DLE->NewX,DLE->NewY,Obj->Width,Obj->Height,30,30);
      DoBonusScore(BONUS_5000,DLE->NewX+30,DLE->NewY+30);
      FreeDLE(DLE);			/* Give back DLE */
      return;				/* ok. */
   }
      
   MoveOnPath(&Guy->Path,DLE);
   CyclicAnimate(&Guy->CAnim,DLE);

   Obj=(struct GraphObject *)DLE->NewImage;

   if(rnd(1000)<100) {
      if(OurShip.DLE->NewX<DLE->NewX) {
         StartEnemyMissile(DLE->NewX,DLE->NewY,BMISSILERATE);
         StartEnemyMissile(DLE->NewX,DLE->NewY+Obj->Height,BMISSILERATE);
      } else if (OurShip.DLE->NewX>DLE->NewX+Obj->Width) {
         StartEnemyMissile(DLE->NewX+Obj->Width,DLE->NewY,BMISSILERATE);
         StartEnemyMissile(DLE->NewX+Obj->Width,DLE->NewY+Obj->Height
         					,BMISSILERATE);
      } else if (OurShip.DLE->NewY<DLE->NewY) {
         StartEnemyMissile(DLE->NewX,DLE->NewY,BMISSILERATE);
         StartEnemyMissile(DLE->NewX+Obj->Width,DLE->NewY,BMISSILERATE);
      } else {
         StartEnemyMissile(DLE->NewX,DLE->NewY+Obj->Height,BMISSILERATE);
         StartEnemyMissile(DLE->NewX+Obj->Width,DLE->NewY+Obj->Height,BMISSILERATE);
      }   
   }      

   EnqueueEvent(EQE,EQE->period);
}

void MakeABigGuy(pattern,period,NumHits,MaxDelay)
ANM_PELEM pattern;
ULONG period;
ULONG NumHits;
ULONG MaxDelay;
{
   register BigGuyDescriptor *Guy;
   register DSP_PDLE DLE;

   TheGuysPtr=(TheGuysPtr+1)&(MAXBIGGUYS-1);
   ++BigGuysOnScreen;
   Guy=&TheGuys[TheGuysPtr];
   DLE=Guy->DLE=AllocDLE();
   DLE->param=(char *)Guy;
   Guy->CAnim.Image=&ClockWork;
   DLE->flags=0;
   DoCollisionCheckingOn(DLE);
   DLE->flags|=DLE_DoCollision|DLE_Deadly|DLE_BigGuy;
   DLE->NewClass=DLE->OldClass=CLS_none;
   DLE->NewX=-100;
   DLE->NewY=-100;
   Guy->CAnim.CurImage=0;
   Guy->CAnim.Delay=1;			/* Force image load */
   Guy->CAnim.MaxDelay=MaxDelay;
   Guy->Path.PathTable=pattern;
   Guy->Path.CurAnim=NULL;		/* Force x y load */
   Guy->NumHits=NumHits;			/* 50 hits to kill */
   DoAfterAndRepeat(AnimateAGuy,Guy,period,"Animate Guys",TheGuysPtr&1+1);
}

void StartNextLevelWhenBigGuysGone(param,EQE)
char *param;
SCH_PEQE EQE;
{
   if(BigGuysOnScreen==0) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      CurrentLevel->flags|=LB_NewLevel;
      CreateEvent(CleanUpEvent,NULL,200,"CleanUpB");
   } else
      EnqueueEvent(EQE,EQE->period);
}

void StartBigGuy(param,EQE)
char *param;
SCH_PEQE EQE;
{
   if(AliensAvailable==CurrentLevel->NumAliens&&
      AlienBulletsAvailable==CurrentLevel->NumAlienBullets) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      BigGuysOnScreen=0;
      switch(CurrentLevel->LevelNum) {
         case 0 /* Cavern */:
            AlienBulletsAvailable=10;
            MakeABigGuy(GuyLev_0,1,40,4);
            CreateEvent(StartNextLevelWhenBigGuysGone,NULL,100,"SNLWBGG");
            break;
         case 1 /* SandStorm */:
            MakeABigGuy(GuyLev_1a,2,30,2);
            MakeABigGuy(GuyLev_1b,2,30,2);
            AlienBulletsAvailable=15;
            CreateEvent(StartNextLevelWhenBigGuysGone,NULL,100,"SNLWBGG");
            break;
         case 2 /* Cheese */:
            StartMajorCircleGuy(500,100);
            break;
         case 3 /* Lava */:
            MakeLavaBall(LavaBallLeft);
            MakeLavaBall(LavaBallRight);
            break;
         case 4 /* Hangar */:
	    StartMajorHangerGuy(400,100);
            break;
         default:
	 break;
      }
      PURGEEQE(EQE);
      FREEEQE(EQE);
   }
   else
      ENQUEUEEVENT(EQE,EQE->period);
}

extern struct RasInfo RasInfo2;

void AnimateBud(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&param->DLE;
   register CyclicAnimation *C=&param->CAnim;
   register EyeDescriptor *Eye=param;
   register struct GraphObject *Obj;

   Obj=(struct GraphObject *)DLE->NewImage;

   
   if(DLE->flags&DLE_collision) {	/* He's dead */

      PURGEEQE(EQE);			/* Take out of scheduler */
      FREEEQE(EQE);
      StopCollisionCheckingOn(DLE);	/* Stop collisioning */
      Obj=(struct GraphObject *)DLE->NewImage;
      ExplodeSquare(DLE->NewX,DLE->NewY,Obj->Width,Obj->Height,30,30);
      DoBonusScore(BONUS_5000,DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY);
      CurrentLevel->flags|=LB_NewLevel;
      CreateEvent(CleanUpEvent,NULL,200,"CleanUpS");
      return;				/* ok. */
   }
      
   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(++C->CurImage>C->Last)
         C->CurImage=C->First;
      if(DLE->NewClass!=CLS_none) {
         Eye->x+=Obj->HotX; Eye->y+=Obj->HotY;
      }
      DLE->NewImage=C->Image->Frames[C->CurImage];
      SetUpHitBox(&DLE->HitBox,DLE->NewImage);
      Obj=(struct GraphObject *)DLE->NewImage;
      DLE->NewClass=CLS_Bob;
      Eye->x-=Obj->HotX; Eye->y-=Obj->HotY;
   }

   BlitBackGroundBob(DLE->NewImage,Eye->x,Eye->y);

   DLE->NewX=Eye->x-RasInfo2.RxOffset;
   DLE->NewY=Eye->y-RasInfo2.RyOffset;

   if((rnd(1000)<200)&&(CurrentLevel->flags&LB_HoldScroll))
      if(C->CurImage>=5+14&&C->CurImage<=9+14) {
         StartEnemyMissilePrim(DLE->NewX+Obj->HotX,
         			DLE->NewY+Obj->HotY,
                           2,
                           -4,0);
         StartEnemyMissilePrim(DLE->NewX+Obj->HotX,
         			DLE->NewY+Obj->HotY,
                           2,
                           -3,-1);
         StartEnemyMissilePrim(DLE->NewX+Obj->HotX,
         			DLE->NewY+Obj->HotY,
                           2,
                           -3,1);
         StartEnemyMissilePrim(DLE->NewX+Obj->HotX,
         			DLE->NewY+Obj->HotY,
                           2,
                           0,-3);
         StartEnemyMissilePrim(DLE->NewX+Obj->HotX,
         			DLE->NewY+Obj->HotY,
                           2,
                           0,3);
         StartEnemyMissilePrim(DLE->NewX+Obj->HotX,
         			DLE->NewY+Obj->HotY,
                           2,
                           -1,-2);
         StartEnemyMissilePrim(DLE->NewX+Obj->HotX,
         			DLE->NewY+Obj->HotY,
                           2,
                           -1,2);
      }

   ENQUEUEEVENT(EQE,EQE->period);
}   

void AnimateHangerBit(Seg,EQE)
HangerGuy *Seg;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&Seg->DLE;
   register struct GraphObject *Obj;

   CopyDownDLE(DLE);

   if(Seg->Daddy->flags&MAJSEG_SelfDestruct) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      StopCollisionCheckingOn(DLE);
      DLE->NewClass=CLS_none;
      DisplayBob(DLE);
      return;
   }

   DLE->NewX=Seg->Daddy->DLE.NewX;
   DLE->NewY=Seg->Daddy->DLE.NewY;

   if(DLE->flags&DLE_collision) {
      DLE->NewImage=
            Seg->CAnim.Image->Frames[Seg->CAnim.Image->Count-1];
      Obj=(struct GraphObject *)DLE->NewImage;
      DLE->NewX-=Obj->HotX; DLE->NewY-=Obj->HotY;
      DisplayBob(DLE);
   } else
      CyclicAnimateBoundedObject(&Seg->CAnim,DLE);
   
   ENQUEUEEVENT(EQE,EQE->period);
}

—void AnimateCircularGuy(Seg,EQE)
HangerGuy *Seg;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&Seg->DLE;
   register struct GraphObject *Obj;
   register LONG x,y;

   CopyDownDLE(DLE);

   if(Seg->Daddy->flags&MAJSEG_SelfDestruct) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      StopCollisionCheckingOn(DLE);
      DLE->NewClass=CLS_none;
      DisplayBob(DLE);
      return;
   }

   x=Seg->Px; y=Seg->Py;
   
   if(x<0)
      Seg->Dx++;
   else
      Seg->Dx--;;

   if(y<0)
      Seg->Dy++;
   else
      Seg->Dy--;

   x+=Seg->Dx;
   y+=Seg->Dy;

   Seg->Px=x; Seg->Py=y;

   DLE->NewX=x+Seg->Daddy->DLE.NewX;
   DLE->NewY=y+Seg->Daddy->DLE.NewY;

   if(DLE->flags&DLE_collision) {
      DLE->NewImage=
            Seg->CAnim.Image->Frames[Seg->CAnim.Image->Count-1];
      Obj=(struct GraphObject *)DLE->NewImage;
      DLE->NewX-=Obj->HotX; DLE->NewY-=Obj->HotY;
      DisplayBob(DLE);
   } else
      CyclicAnimateBoundedObject(&Seg->CAnim,DLE);
   
   ENQUEUEEVENT(EQE,EQE->period);
}

void StartCircularGuy(Daddy,Image,Delay,NumHits,X,Y,Dx,Dy)
MajorHangerDescriptor *Daddy;
struct SpriteImage *Image;
WORD Delay;
WORD NumHits;
WORD X,Y;
WORD Dx,Dy;
{
   register HangerGuy *Hanger;
   register CyclicAnimation *CAnim;

   HangerPtr=(HangerPtr+1)&(NUMSEGHANGER-1);
   Hanger=&HangerGuyPool[HangerPtr];
   Hanger->Daddy=Daddy;

   ++(Daddy->Count);
   
   CAnim=&Hanger->CAnim;

   Hanger->DLE.NewClass=Hanger->DLE.OldClass=CLS_none;
   Hanger->DLE.flags=DLE_Deadly|DLE_HangerBit;
   Hanger->DLE.param=(char *)Hanger;

   DoCollisionCheckingOn(&Hanger->DLE);
   
   Hanger->DLE.NewX=-100;
   Hanger->Px=X; Hanger->Py=Y;
   Hanger->Dx=Dx; Hanger->Dy=Dy;

   Hanger->NumHits=NumHits;
   
   CAnim->Image=Image;
   CAnim->First=0;
   CAnim->Last=Image->Count-2;
   CAnim->Delay=1;
   CAnim->MaxDelay=Delay;
   CAnim->CurImage=-1;
   
   CreateEvent(AnimateCircularGuy,Hanger,2,"Animate Circle");
}

void StartHangerBit(Daddy,Image,Delay,NumHits)
MajorHangerDescriptor *Daddy;
struct SpriteImage *Image;
WORD Delay;
WORD NumHits;
{
   register HangerGuy *Hanger;
   register CyclicAnimation *CAnim;

   HangerPtr=(HangerPtr+1)&(NUMSEGHANGER-1);
   Hanger=&HangerGuyPool[HangerPtr];
   Hanger->Daddy=Daddy;

   ++(Daddy->Count);
   
   CAnim=&Hanger->CAnim;

   Hanger->DLE.NewClass=Hanger->DLE.OldClass=CLS_none;
   Hanger->DLE.flags=DLE_Deadly|DLE_HangerBit;
   Hanger->DLE.param=(char *)Hanger;

   DoCollisionCheckingOn(&Hanger->DLE);
   
   Hanger->DLE.NewX=-100;
   Hanger->NumHits=NumHits;
   
   CAnim->Image=Image;
   CAnim->First=0;
   CAnim->Last=Image->Count-2;
   CAnim->Delay=1;
   CAnim->MaxDelay=Delay;
   CAnim->CurImage=-1;
   
   CreateEvent(AnimateHangerBit,Hanger,2,"Animate HangerBit");
}

void MoveHangerController(param,EQE)
MajorHangerDescriptor *param;
SCH_PEQE EQE;
{
   register MajorHangerDescriptor *Daddy=param;
   register int HisX,HisY;
   register DSP_PDLE DLE;
   struct GraphObject *Obj;
   

   DLE=&Daddy->DLE;

   Obj=(struct GraphObject *)OurShip.DLE->NewImage;

   if(!(Daddy->Count)) {		/* All kids Dead */
      if(rnd(1000)>500)
         HisX=rnd(32)+DLE->NewX;
      else
         HisX=-rnd(32)+DLE->NewX;
      if(rnd(1000)>500)
         HisY=rnd(32)+DLE->NewY;
      else
         HisY=-rnd(32)+DLE->NewY;
      MakeExplosion(NULL,NULL,HisX,HisY,0,0);
      HisX=OurShip.DLE->NewX-40+Obj->HotX;
      HisY=400;
   } else {
      HisX=OurShip.DLE->NewX+90+Obj->HotX;	/* Centre of my man */
      HisY=OurShip.DLE->NewY+Obj->HotY;
   }
   
   if(DLE->NewY>250) {
      Daddy->flags|=MAJSEG_SelfDestruct;	/* Kiddys, commit suicide */
      PURGEEQE(EQE);
      FREEEQE(EQE);
      CurrentLevel->flags&=~LB_HoldScroll;	/* Start Scroll Again */
      if(RasInfo2.RxOffset>800) {
         CurrentLevel->flags|=LB_NewLevel;
         CreateEvent(CleanUpEvent,NULL,2,"CleanUp");
      }
      return;
   }

   if(HisY>DLE->NewY) {
      if(Daddy->Dy<5*SCALE_FACTOR) Daddy->Dy+=96;
   } else
      if(Daddy->Dy>-5*SCALE_FACTOR) Daddy->Dy-=96;

   if(HisX>DLE->NewX) {
      if(Daddy->Dx<5*SCALE_FACTOR) Daddy->Dx+=96;
   } else
       if(Daddy->Dx>-5*SCALE_FACTOR)Daddy->Dx-=96;

   DLE->NewX+=Daddy->Dx/SCALE_FACTOR;
   DLE->NewY+=Daddy->Dy/SCALE_FACTOR;

   ENQUEUEEVENT(EQE,EQE->period);
}

extern struct SpriteImage Spare5Image;
extern struct SpriteImage Spare6Image;
extern struct SpriteImage Spare7Image;
extern struct SpriteImage Spare8Image;

void StartMajorHangerGuy(x,y)
WORD x,y;
{
   MajorHangerDescriptor *XY;
   HangerXYPtr=(HangerXYPtr+1)&(NUMSEGHANGER-1);
   XY=&HangerXY[HangerXYPtr];
   XY->DLE.NewX=x;
   XY->DLE.NewY=y;
   
   XY->Dx=2*SCALE_FACTOR;
   XY->Dy=-2*SCALE_FACTOR;
   
   XY->flags=0;
   XY->Count=0;

   StartHangerBit(XY,&Spare5Image,4,10*OurShip.CurPower);
   StartHangerBit(XY,&Spare6Image,4,10*OurShip.CurPower);
   StartHangerBit(XY,&Spare7Image,6,10*OurShip.CurPower);
   StartHangerBit(XY,&Spare8Image,200,20*OurShip.CurPower);

   CreateEvent(MoveHangerController,XY,2,"Move Hanger Controller");
}

void StartMajorCircleGuy(x,y)
WORD x,y;
{
   MajorHangerDescriptor *XY;
   HangerXYPtr=(HangerXYPtr+1)&(NUMSEGHANGER-1);
   XY=&HangerXY[HangerXYPtr];
   XY->DLE.NewX=x;
   XY->DLE.NewY=y;
   
   XY->Dx=2*SCALE_FACTOR;
   XY->Dy=-2*SCALE_FACTOR;
   
   XY->flags=0;
   XY->Count=0;

   StartCircularGuy(XY,&ClockWork,2,10*OurShip.CurPower,-32,-4,
   							    0,7);
   StartCircularGuy(XY,&ClockWork,2,10*OurShip.CurPower,32,4,
   							    0,-7);

   CreateEvent(MoveHangerController,XY,4,"Move Hanger Controller");
}
