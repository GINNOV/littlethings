/*********************************************************************
 * Routines for Bringing bugs into the world                         *
 ********************************************************************/



#include "scheduler.h"
#include "GameParam.h"
#include "bugs.h"
#include "view.h"
#include "game.h"

#include <exec/types.h>
#include <exec/memory.h>

extern void *RemQue();

extern ULONG rnd();
extern BYTE AlienBulletsAvailable;

extern void *AllocMem();

extern ANM_ELEM BillysTable[];

BugSqueezeDescriptor *FreeSqueezeBugs;
BabyDescriptor *FreeBabyBugs;

WORD BabyBugsLeft;
WORD SqueezyBugsLeft;

extern struct SpriteImage SpitBugImage;
extern struct SpriteImage SqueezyVBug;
extern struct SpriteImage SqueezyHBug;
extern struct SpriteImage BugBornLeft;
extern struct SpriteImage BugBornRight;

BabyDescriptor BabyDescriptorPool[MAXBABYBUGS];
BugSqueezeDescriptor BugSqueezePoolDescriptor[MAXSQUEEZEBUGS];

void AllocateBugs()
{
   FreeBabyBugs=BabyDescriptorPool;

   FreeSqueezeBugs=BugSqueezePoolDescriptor;

}

void EmptyFreeBugs()
{
   BabyDescriptor *t;
   BugSqueezeDescriptor *u;
   WORD i;
   FreeBabyBugs->Q.flink=FreeBabyBugs->Q.blink=
             (struct SCH_queue *)(t=FreeBabyBugs);
   
   for(i=1;i<MAXBABYBUGS;++i)
      FREEBABYBUG(++t);

   FreeSqueezeBugs->Q.flink=FreeSqueezeBugs->Q.blink=
             (struct SCH_queue *)(u=FreeSqueezeBugs);
   
   for(i=1;i<MAXSQUEEZEBUGS;++i)
      FREESQUEEZEBUG(++u);
}

void KillBabyBug(Baby,Owner)
BabyDescriptor *Baby;
BugSqueezeDescriptor *Owner;
{
   register DSP_PDLE SmallDLE=Baby->DLE;
   CopyDownDLE(SmallDLE);
   SmallDLE->NewClass=CLS_none;
   DisplayBob(SmallDLE);
   StopCollisionCheckingOn(SmallDLE);
   FreeDLE(SmallDLE);
   FREEBABYBUG(SmallDLE->param);
   ++BabyBugsLeft;
   if(Owner)
      if(Baby->flags^BABY_goingleft)		/* going right ? */
         Owner->Right=NULL;
      else
         Owner->Left=NULL;
} 

void AnimateSpitBug(param,EQE)
BabyDescriptor *param;
SCH_PEQE EQE;
{
   register BabyDescriptor *Bug=param;
   register DSP_PDLE DLE=param->DLE;
   register struct GraphObject *Obj;
   
   CopyDownDLE(DLE);

   if(DLE->flags&DLE_collision) {
      Obj=(struct GraphObject *)DLE->NewImage;
      MakeExplosion(NULL,NULL,
                    DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY,
                    0,0);
      KillBabyBug(Bug,NULL);
      PURGEEQE(EQE);
      FREEEQE(EQE);
      return;
   }
      
   if(DLE->NewX<-16||DLE->NewX>320||DLE->NewY<-16||DLE->NewY>VIEW_HEIGHT) {
      KillBabyBug(Bug,NULL);
      PURGEEQE(EQE);
      FREEEQE(EQE);
      return;
   }

   MoveOnPath(&Bug->Path,DLE);
   CyclicAnimate(&Bug->CAnim,DLE);
   Obj=(struct GraphObject *)DLE->NewImage;
   if(rnd(1000)<50)
      StartEnemyMissile(DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY,
      			AMISSILERATE);
   
   ENQUEUEEVENT(EQE,EQE->period);
}

extern ANM_ELEM SpitBugGoesLeft[];
extern ANM_ELEM SpitBugGoesBack[];
extern ANM_ELEM SpitBugGoesRight[];

void StartSpitBug(Baby,Owner)
BabyDescriptor *Baby;
BugSqueezeDescriptor *Owner;
{
   register DSP_PDLE SmallDLE=Baby->DLE;
   register BabyDescriptor *Bug=Baby;
   register struct GraphObject *Obj;

   if(CurrentLevel->flags&LB_ScrollHoriz) {
      Owner->Right=NULL;
      Bug->Path.CurAnim=SpitBugGoesBack;
   } else
      if(Bug->flags^BABY_goingleft) {
         Owner->Right=NULL;
         Bug->Path.CurAnim=SpitBugGoesRight;
      } else {
         Owner->Left=NULL;
         Bug->Path.CurAnim=SpitBugGoesLeft;
      }
   
   Bug->CAnim.Image=&SpitBugImage;
   Bug->CAnim.CurImage=-1;	/* Start at image 1 */
   Bug->CAnim.Delay=1;		/* Force image load */
   Bug->CAnim.MaxDelay=3;

   Bug->Path.Count=Bug->Path.CurAnim->Count;

   CreateEvent(AnimateSpitBug,Bug,Bug->Path.CurAnim->FrameNo,"Spit Bug");
}


void DoBornBug(baby,dle)
BabyDescriptor *baby;
DSP_PDLE dle;
{
   register BabyDescriptor *Baby=baby;
   register DSP_PDLE BigDLE=dle;
   register DSP_PDLE SmallDLE;
   struct GraphObject *Obj,*Me;
   BugSqueezeDescriptor *BigBug;
   
   BigBug=(BugSqueezeDescriptor *)BigDLE->param;
   
   Obj=(struct GraphObject *)BigDLE->NewImage;

   if(Baby==NULL)
      if(BabyBugsLeft>0) {
         Baby=ALLOCBABYBUG;
         --BabyBugsLeft;
         Baby->NumHits=5;
         SmallDLE=Baby->DLE=AllocDLE();		/* Fewtch DLE */
         SmallDLE->flags=0;
         SmallDLE->NewX=-200;			/* Prevent premeture death */
         DoCollisionCheckingOn(SmallDLE);
         SmallDLE->flags|=(DLE_Deadly|DLE_BabyBug|DLE_DoCollision);
         SmallDLE->param=(char *)Baby;
         SmallDLE->OldClass=SmallDLE->NewClass=CLS_none;
         if(BigBug->Left) {			/* Left bug exists */
            BigBug->Right=Baby;
            Baby->CAnim.Image=&BugBornRight;
            Baby->flags=0;
         } else {				/* Put in left bug */
            BigBug->Left=Baby;
            Baby->CAnim.Image=&BugBornLeft;
            Baby->flags=BABY_goingleft;
         }
         Baby->CAnim.CurImage=-1;
         Baby->CAnim.Delay=1;
         Baby->CAnim.MaxDelay=3;

     } else return;

   SmallDLE=Baby->DLE;
   CopyDownDLE(SmallDLE);

   if(SmallDLE->flags&DLE_collision) {
      MakeExplosion(NULL,NULL,
      		    SmallDLE->NewX+4,SmallDLE->NewY+4,
                    0,0);
      KillBabyBug(Baby,BigBug);
      return;
   }

   if(!--Baby->CAnim.Delay) {
      Baby->CAnim.Delay=Baby->CAnim.MaxDelay;
      Baby->CAnim.CurImage++;
      if(Baby->CAnim.CurImage==Baby->CAnim.Image->Count) {
         StartSpitBug(Baby,BigBug);
         return;
      }
      SmallDLE->NewImage=Baby->CAnim.Image->Frames[Baby->CAnim.CurImage];
      SetUpHitBox(&SmallDLE->HitBox,SmallDLE->NewImage);
   }

   SmallDLE->NewClass=Baby->CAnim.Image->Class;
   Me=(struct GraphObject *)SmallDLE->NewImage;
   SmallDLE->NewY=BigDLE->NewY+Obj->HotY-Me->HotY;
   if(Baby->flags^BABY_goingleft)
      SmallDLE->NewX=BigDLE->NewX+Obj->HotX+22-Me->HotX;
   else
      SmallDLE->NewX=BigDLE->NewX+Obj->HotX-22-Me->HotX;

   DisplayBob(SmallDLE);
   
}


extern void StartBugLauncher();
   
/**
 ** This animates a Squeezy bug launcher 
 **
 **/
 
void AnimateVertSqueezyBug(param,EQE)
BugSqueezeDescriptor *param;
SCH_PEQE EQE;
{
   register BugSqueezeDescriptor *Bug=param;
   register DSP_PDLE DLE=param->DLE;
   
   CopyDownDLE(DLE);
   MoveOnPath(&Bug->Path,DLE);

   if(DLE->flags&DLE_collision)
      MakeExplosion(NULL,NULL,
                    DLE->NewX+10,DLE->NewY+10,
                    0,0);

   if(DLE->NewY>VIEW_HEIGHT||DLE->flags&DLE_collision) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      
      DLE->NewClass=CLS_none;		/* Erase him */
      DisplayBob(DLE);			
      StopCollisionCheckingOn(DLE);	/* Stop collisioning */
      FreeDLE(DLE);			/* Give back DLE */
      FREESQUEEZEBUG(Bug);
      ++SqueezyBugsLeft;
      if(Bug->Left)
         KillBabyBug(Bug->Left,Bug);
      if(Bug->Right)
         KillBabyBug(Bug->Right,Bug);
      CurrentLevel->flags&=~LB_HoldScroll;
      return;				/* ok. */
   }

   CyclicAnimate(&Bug->CAnim,DLE);

   DoBornBug(Bug->Left,DLE);
   DoBornBug(Bug->Right,DLE);

   ENQUEUEEVENT(EQE,EQE->period);
}

void AnimateHorizSqueezyBug(param,EQE)
BugSqueezeDescriptor *param;
SCH_PEQE EQE;
{
   register BugSqueezeDescriptor *Bug=param;
   register DSP_PDLE DLE=param->DLE;
   
   CopyDownDLE(DLE);
   MoveOnPath(&Bug->Path,DLE);

   if(DLE->flags&DLE_collision)
      MakeExplosion(NULL,NULL,
                    DLE->NewX+10,DLE->NewY+10,
                    0,0);

   if(DLE->NewX<-32||DLE->flags&DLE_collision) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      
      DLE->NewClass=CLS_none;		/* Erase him */
      DisplayBob(DLE);			
      StopCollisionCheckingOn(DLE);	/* Stop collisioning */
      FreeDLE(DLE);			/* Give back DLE */
      FREESQUEEZEBUG(Bug);
      ++SqueezyBugsLeft;
      Bug->Left=NULL;
      if(Bug->Right)
         KillBabyBug(Bug->Right,Bug);
      CurrentLevel->flags&=~LB_HoldScroll;
      return;				/* ok. */
   }

   CyclicAnimate(&Bug->CAnim,DLE);

   DoBornBug(Bug->Right,DLE);

   ENQUEUEEVENT(EQE,EQE->period);
}

void StartVSqueezyBug(bug,pattern)
BugSqueezeDescriptor *bug;
ANM_PELEM pattern;
{
   register DSP_PDLE DLE;
   register BugSqueezeDescriptor *Bug=bug;

   DLE=Bug->DLE=AllocDLE();
   DLE->param=(char *)Bug;
   DLE->flags=0;
   DoCollisionCheckingOn(DLE);
   DLE->flags|=DLE_DoCollision|DLE_Deadly|DLE_SqueezyBug;
   DLE->NewClass=DLE->OldClass=CLS_none;
   DLE->NewX=-100;
   DLE->NewY=-100;

   Bug->NumHits=30;
   Bug->Left=Bug->Right=NULL;		/* Start two bugs */
   Bug->CAnim.Image=&SqueezyVBug;
   Bug->CAnim.CurImage=0;
   Bug->CAnim.Delay=1;			/* Force image load */
   Bug->CAnim.MaxDelay=4;

   Bug->Path.PathTable=pattern;
   Bug->Path.CurAnim=NULL;		/* Force x y load */

   CreateEvent(AnimateVertSqueezyBug,Bug,pattern->FrameNo,"AnimateSqueezy");
   --SqueezyBugsLeft;
}

void StartHSqueezyBug(bug,pattern)
BugSqueezeDescriptor *bug;
ANM_PELEM pattern;
{
   register DSP_PDLE DLE;
   register BugSqueezeDescriptor *Bug=bug;

   DLE=Bug->DLE=AllocDLE();
   DLE->param=(char *)Bug;
   DLE->flags=0;
   DoCollisionCheckingOn(DLE);
   DLE->flags|=DLE_DoCollision|DLE_Deadly|DLE_SqueezyBug;
   DLE->NewClass=DLE->OldClass=CLS_none;
   DLE->NewX=-100;
   DLE->NewY=-100;

   Bug->NumHits=30;
   Bug->Left=1;
   Bug->Right=NULL;		/* Start one bug */
   Bug->CAnim.Image=&SqueezyHBug;
   Bug->CAnim.CurImage=0;
   Bug->CAnim.Delay=1;			/* Force image load */
   Bug->CAnim.MaxDelay=4;

   Bug->Path.PathTable=pattern;
   Bug->Path.CurAnim=NULL;		/* Force x y load */

   CreateEvent(AnimateHorizSqueezyBug,Bug,pattern->FrameNo,"AnimateSqueezy");
   --SqueezyBugsLeft;
}

extern ANM_ELEM BugS_Down[];
extern ANM_ELEM BugS_Across[];

void StartBugLauncher(param,EQE)
char *param;
SCH_PEQE EQE;
{
   if(AliensAvailable!=CurrentLevel->NumAliens) {
      ENQUEUEEVENT(EQE,5);
   } else {
      if(CurrentLevel->flags&LB_ScrollVert)
         StartVSqueezyBug(ALLOCSQUEEZEBUG,BugS_Down);
      else
         StartHSqueezyBug(ALLOCSQUEEZEBUG,BugS_Across);
      PURGEEQE(EQE);
      FREEEQE(EQE);
   }
}
   
void InitialiseBugs()
{
   EmptyFreeBugs();
   SqueezyBugsLeft=MAXSQUEEZEBUGS-2;
   BabyBugsLeft=MAXBABYBUGS-2;
}
