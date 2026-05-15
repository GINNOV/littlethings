/************************************************
 *
 * This is all the missile routines
 *
 */
 
#include <graphics/view.h>
#include <exec/memory.h>
#include "BulletData.h"

#include "GameParam.h"
#include "bullets.h"
#include "scheduler.h"
#include "bugs.h"
#include "displist.h"
#include <graphics/sprite.h>
#include "Eyes.h"
#include "wave.h"
#include "view.h"
#include "game.h"
#include "debug.h"
#include "BigGuys.h"
#include "iff.h"
#include "sprites.h"

#define BLT_Up		0
#define BLT_Down	1
#define BLT_Left	2
#define BLT_Right	3

extern void *AllocMem();

extern LONG rnd();
extern struct SpriteImage SweepMissileImage;
extern struct SpriteImage AlienBulletImage;
extern void *AllocMem();
extern BYTE AlienBulletsAvailable;

extern DSP_PCOL DSP_SpriteList;

#define Sprite_BlankH 1
UWORD Sprite_Blank[]={0,0,0,0,0,0};

extern WORD BLT_Direction[4][2];
extern BYTE BulletHeights[4];


#define Sprite_MyBulletH 16

/*----- bitmap : w = 16, h = 16 ------ */
/*------ plane # 0: --------*/
UWORD Sprite_RightBullet [36];
UWORD Sprite_LeftBullet  [36];
UWORD Sprite_DownBullet  [36];

UWORD Sprite_BRightBullet [36];
UWORD Sprite_BLeftBullet  [36];
UWORD Sprite_BDownBullet  [36];

extern UWORD Sprite_BUpBullet[36];

extern UWORD Sprite_UpBullet[36];

#define Sprite_RoundBulletH 6

extern UWORD Sprite_RoundBullet[16];

#define SATELLH 7

extern UWORD SatelliteSprite[36];

UWORD *MissileShapes[8];
UWORD *SatelliteShapes[8];
  
UWORD *UBulletShapes[8];
UWORD *LBulletShapes[8];
UWORD *RBulletShapes[8];
UWORD *DBulletShapes[8];

UWORD *UBulletShapes2[8];
UWORD *LBulletShapes2[8];
UWORD *RBulletShapes2[8];
UWORD *DBulletShapes2[8];

static BUL_PMissile SvrMissileQ0;
static BUL_PMissile SvrMissileQ1;

static BUL_PMissile SvrAMissileQ0;
static BUL_PMissile SvrAMissileQ1;

/*********************************************************
 * This will rotate a 16 x 16 Sprite Image by 90 Degrees * 
 *							 *
 *                       Written by			 *
 *                        -_=BK=_-			 *
 *							 *
 ********************************************************/
 
static void FlipMyBullet(Src,Dst)
UWORD *Src,*Dst;
{
   UWORD *p1,*p2;
   UWORD x,y,Temp;
   p1=&Src[2];
   p2=&Dst[2];
   p2[16*2]=0;		/* Don't reuse sprite channel please */
   p2[16*2+1]=0;
   for(x=0;x<16;x++){
      for(Temp=0,y=15;y<16;y--){
         Temp=(Temp<<1)|((p1[y*2]>>(15-x))&1);
      }
      p2[x*2]=Temp;
      for(Temp=0,y=15;y<16;y--){
         Temp=(Temp<<1)|((p1[y*2+1]>>(15-x))&1);
      }
      p2[x*2+1]=Temp;
   }
}

/******************
 *** AllocMissile *
 **************************************************************************
 * Returns a handle on a missile and gives a sprite if GIMMESPRITE passed *
 * as flag, none if NOSPRITE passed					  *
 *************************************************************************/

BUL_PMissile AllocMissile(flag)
int flag;
{
  register BUL_PMissile b;
  if(FreeMissiles->flink==FreeMissiles)
    return NULL;

  b=RemQue(FreeMissiles->flink);
  if(flag)
     b->Shape.Spr=AllocSprite();
  return b;
}

void FreeMissile(t,f)
BUL_PMissile t;
int f;
{
  if(f)
     Free_Sprite(t->Shape.Spr);

  InsQue(FreeMissiles,t);
}

/*********************************************************************
 * Function called when bullets collided with an object. DLE is the DLE
 * of the object collided with and cDLE is the DLE of the bullet
 * concerned.
 *********************************************************************
 *********** Written by _-=BN=-_ **** Date 17 May 88 *****************
 ********************************************************************/
 
void BulletCollisionRoutine(DLE,cDLE)
DSP_PDLE DLE,cDLE;
{
  register DSP_PDLE dle=DLE;
  register DSP_PDLE cdle=cDLE;
  register union {
     struct AlienParam *Alien;
     BigGuyDescriptor *BigGuy;
     BugSqueezeDescriptor *SBug;
     BabyDescriptor *BabyBug;
     EyeDescriptor *Eye;
     HangerGuy *Hanger;
  } Target;
  register union {
     BUL_PMissile Bullet;
  } Bullet;

  Bullet.Bullet=(BUL_PMissile)cdle->param;
  Target.Alien=(struct AlienParam *)dle->param;
  if(dle->flags&DLE_Token) {
     dle->flags|=DLE_User0;
     cdle->flags|=DLE_collision;	/* Bullet always hits */
     return;
  }
  if(dle->flags&DLE_HangerBit)
    if(!(dle->flags&DLE_collision))
       if(Target.Hanger->NumHits-Bullet.Bullet->PowImage.Power<=0) {
          OurShip.Score+=200;
          dle->flags|=DLE_collision;	/* Ok, your dead */
          --(Target.Hanger->Daddy->Count);	/* Tell daddy, I love him */
          if(Target.Hanger->NumHits==Bullet.Bullet->PowImage.Power)
             cdle->flags|=DLE_collision;
          else
             Bullet.Bullet->PowImage.Power-=Target.Hanger->NumHits;
          return;
       } else {
          MakeExplosion(NULL,NULL,cdle->NewX,cdle->NewY,0,0);
          Target.Hanger->NumHits-=Bullet.Bullet->PowImage.Power;
          cdle->flags|=DLE_collision;
          return;
       }
    else {
       cdle->flags|=DLE_collision;
       return;
    }

  if(dle->flags&DLE_AlienParam) 		/* Bullet struck home */
    if(Target.Alien->NumHitsLeft-Bullet.Bullet->PowImage.Power<=0) {
       OurShip.Score+=Target.Alien->WVE->Score;
       dle->flags|=DLE_collision;	/* Ok, your dead */
       dle->flags&=~DLE_AlienParam;	/* Don't hit again */
       if(Target.Alien->NumHitsLeft==Bullet.Bullet->PowImage.Power)
          cdle->flags|=DLE_collision;
       else
          Bullet.Bullet->PowImage.Power-=Target.Alien->NumHitsLeft;
       return;
    } else {
       Target.Alien->NumHitsLeft-=Bullet.Bullet->PowImage.Power;
       cdle->flags|=DLE_collision;
       return;
    }

  if(dle->flags&DLE_Eye) 		/* Bullet struck home */
    if(Target.Eye->CAnim.Image->Count-Target.Eye->CAnim.CurImage<=2)
       if(Target.Eye->NumHits-Bullet.Bullet->PowImage.Power<=0) {
          OurShip.Score+=100;
          dle->flags|=DLE_collision;
          dle->flags&=~DLE_Eye;
          if(Target.Eye->NumHits==Bullet.Bullet->PowImage.Power)
             cdle->flags|=DLE_collision;
          else
             Bullet.Bullet->PowImage.Power-=Target.Eye->NumHits;
          return;
       } else {
          Target.Eye->NumHits-=Bullet.Bullet->PowImage.Power;
          cdle->flags|=DLE_collision;
          return;
       }

  if((dle->flags&DLE_Bud)&&(CurrentLevel->flags&LB_HoldScroll)) 		/* Bullet struck home */ {
     MakeExplosion(NULL,NULL,dle->NewX+rnd(10),dle->NewY+rnd(10),0,0);
     if(Target.Eye->NumHits-Bullet.Bullet->PowImage.Power<=0) {
        OurShip.Score+=5000;
        dle->flags|=DLE_collision;
        dle->flags&=~DLE_Bud;
        if(Target.Eye->NumHits==Bullet.Bullet->PowImage.Power)
           cdle->flags|=DLE_collision;
        else
           Bullet.Bullet->PowImage.Power-=Target.Eye->NumHits;
     } else {
        Target.Eye->NumHits-=Bullet.Bullet->PowImage.Power;
        cdle->flags|=DLE_collision;
     }
     return;
  }

  if(dle->flags&DLE_LavaEye) 		/* Bullet struck home */
    if(Target.Eye->CAnim.CurImage==8)
       if(Target.Eye->NumHits-Bullet.Bullet->PowImage.Power<=0) {
          OurShip.Score+=50;
          dle->flags|=DLE_collision;
          dle->flags&=~DLE_LavaEye;
          if(Target.Eye->NumHits==Bullet.Bullet->PowImage.Power)
             cdle->flags|=DLE_collision;
          else
             Bullet.Bullet->PowImage.Power-=Target.Eye->NumHits;
          return;
       } else {
          Target.Eye->NumHits-=Bullet.Bullet->PowImage.Power;
          cdle->flags|=DLE_collision;
          return;
       }

  if(dle->flags&DLE_Iris) 		/* Bullet struck home */
    if(Target.Eye->CAnim.CurImage>=13)
       if(Target.Eye->NumHits-Bullet.Bullet->PowImage.Power<=0) {
          OurShip.Score+=100;
          dle->flags|=DLE_collision;
          dle->flags&=~DLE_Eye;
          if(Target.Eye->NumHits==Bullet.Bullet->PowImage.Power)
             cdle->flags|=DLE_collision;
          else
             Bullet.Bullet->PowImage.Power-=Target.Eye->NumHits;
          return;
       } else {
          Target.Eye->NumHits-=Bullet.Bullet->PowImage.Power;
          cdle->flags|=DLE_collision;
          return;
       }

  if(dle->flags&DLE_BigGuy) {
     if(Target.BigGuy->NumHits-Bullet.Bullet->PowImage.Power<=0) {
        dle->flags|=DLE_collision;
        OurShip.Score+=5000;
     } else
        Target.BigGuy->NumHits-=Bullet.Bullet->PowImage.Power;
     cdle->flags|=DLE_collision;
     return;
  }
     
  if(dle->flags&DLE_BabyBug) {
     if(Target.BabyBug->NumHits-Bullet.Bullet->PowImage.Power<=0) {
        dle->flags|=DLE_collision;
        OurShip.Score+=100;
     } else
        Target.BabyBug->NumHits-=Bullet.Bullet->PowImage.Power;
     cdle->flags|=DLE_collision;
     return;
  }

  if(dle->flags&DLE_SqueezyBug) {
     if(Target.SBug->NumHits-Bullet.Bullet->PowImage.Power<=0) {
        dle->flags|=DLE_collision;
        OurShip.Score+=1000;
     } else
        Target.SBug->NumHits-=Bullet.Bullet->PowImage.Power;
     cdle->flags|=DLE_collision;
     return;
  }

}

extern WVE_PPARAM ActiveAlienList;
extern WVE_PPARAM LockedAlienList;

/***************************************************************
 * Find an alien whose currently onscreen and has'nt already
 * being locked on to. Return a pointer to his DLE or NULL
 * if there isn't one
 *
 */
 
static DSP_PDLE LockOnEnemy()
{
   register WVE_PPARAM CurA=ActiveAlienList->flink;

   if(CurA!=ActiveAlienList) {
      InsQue(LockedAlienList,RemQue(CurA));
      return CurA->DLE;
   }
   return NULL;
}

/*********************************************************************
 * If Homer is locked on, and is still onscreen then place the alien
 * back in the UnLocked Queue.
 ********************************************************************/

static void UnLockAlien(Alien)
WVE_PPARAM Alien;
{
   if(Alien)
      if(Alien->DLE->NewClass!=CLS_none)
         InsQue(ActiveAlienList,(WVE_PPARAM)RemQue(Alien));
}

extern char *debug_buffer;

static int MoveHomer(hom)
BUL_PMissile hom;
{
   register int HisX,HisY;
   register DSP_PDLE DLE;
   register struct SimpleSprite *Sprite;
   register WVE_PPARAM t;

   Sprite=&hom->Shape.Spr->Sprite;
   DLE=hom->DLE;

   if(hom->Target.Enemy)
      t=(WVE_PPARAM)hom->Target.Enemy->param;	/* t points to Alien Param */
   else
      t=NULL;
      
   if(t->Class==CLS_none)		/* Alien is dead, get another */
      t=hom->Target.Enemy=NULL;

   if(!--hom->TimAnim.TimeOut)			/* Has homer timed out ? */
      DLE->flags|=DLE_collision;	/* Signal Homer dead for later */

   if(DLE->flags&DLE_collision) {		/* I'm a murderer ! */
      UnLockAlien(t);
      Move_Sprite(Sprite,-50,0);	/* Erase Homer */
      (*hom->Count)++;			/* Give player bullet back */
      (void)RemQue(DLE->COL);		/* Stop collision checking */
      return GIMMESPRITE;
   }

   if(hom->Target.Enemy) {
      HisX=hom->Target.Enemy->NewX;
      HisY=hom->Target.Enemy->NewY;
   } else {
      HisX=OurShip.DLE->NewX;
      HisY=OurShip.DLE->NewY;
      hom->Target.Enemy=LockOnEnemy();
   }
   
   if(HisY>DLE->NewY) {
      if(hom->Dy<hom->My) hom->Dy+=2;
   } else
      if(hom->Dy>-hom->My) hom->Dy-=2;

   if(HisX>DLE->NewX) {
      if(hom->Dx<hom->Mx) hom->Dx+=2;
   } else
       if(hom->Dx>-hom->Mx)hom->Dx-=2;

   DLE->NewX+=hom->Dx;
   DLE->NewY+=hom->Dy;

   DisplaySprite(DLE);

   return -1;
}

static int MoveMissile(param)
BUL_PMissile param;			/* Missiles */
{ /* MoveMissile */
  register DSP_PDLE DLE;
  register struct SimpleSprite *Sprite;
  register BUL_PMissile Missile=param;


  DLE=Missile->DLE;			/* For Speed */
  Sprite=&Missile->Shape.Spr->Sprite;
  DLE->NewX+=Missile->Dx;
  DLE->NewY+=Missile->Dy;
  if (DLE->NewX<0 || DLE->NewX>VIEW_WIDTH ||
      DLE->NewY<0 || DLE->NewY>VIEW_HEIGHT) /* then he's offscreen */
      DLE->flags|=DLE_collision;	/* So kill him */

  if(DLE->flags&DLE_collision) {	/* I'm dead */
    Move_Sprite(Sprite,-50,0);
    (*Missile->Count)++;			/* Give player bullet back */
    (void)RemQue(DLE->COL);
    return GIMMESPRITE;
  }

  DisplaySprite(DLE);		/* Update Screen */
  return -1;

}

/****
 **** Server for moveing out missiles
 ***/
         
void SvrMoveMissile(param,EQE)
BUL_PMissile param;
SCH_PEQE EQE;
{
   register BUL_PMissile Node;
   register BUL_PMissile Temp;
   register BUL_PMissile Head=param;
   register int flag;
   
   Node=Head->flink;
   while(Node!=Head) {
      flag=(*Node->function)(Node);		/* Move Missile */
      Temp=Node->flink;			/* Get next Missile */
      if(flag!=-1) {			/* If dead */
         (void)RemQue(Node);		/* Take from q */
         FreeMissile(Node,flag);	/* FreeMissile */
      }
      Node=Temp;			/* Advance */
   }
   ENQUEUEEVENT(EQE,EQE->period);	/* Reschedule Server */
}
         
static int MovePatternedMissile(param)
BUL_PMissile param;			/* Missiles */
{
  register DSP_PDLE DLE;
  register struct SimpleSprite *Sprite;
  register BUL_PMissile Bullet=param;

  DLE=Bullet->DLE;			/* For Speed */
  Sprite=&Bullet->Shape.Spr->Sprite;


  /* Move Missile */
  if(Bullet->flags&BUL_negatex)
     DLE->NewX-=Bullet->Target.CurAnim->Xoffset;
  else
     DLE->NewX+=Bullet->Target.CurAnim->Xoffset;

  DLE->NewY+=Bullet->Target.CurAnim->Yoffset;
  if(!--Bullet->TimAnim.AnimCount)
     if((++Bullet->Target.CurAnim)->Count)
        Bullet->TimAnim.AnimCount=Bullet->Target.CurAnim->Count;
     else
        DLE->flags|=DLE_collision;

  /* Kill missile if offscreen */
  if (DLE->NewX<0 || DLE->NewX>VIEW_WIDTH ||
      DLE->NewY<0 || DLE->NewY>VIEW_HEIGHT) /* then he's offscreen */
      DLE->flags|=DLE_collision;	/* So kill him */

  /* if missile dead clean up */
  if(DLE->flags&DLE_collision) {	/* I'm dead */
    Move_Sprite(Sprite,-50,0);
    (*Bullet->Count)++;			/* Give player bullet back */
    (void)RemQue(DLE->COL);
    return GIMMESPRITE;
  }

  /* otherwise carry on */
  DisplaySprite(DLE);		/* Update Screen */
  return -1;
}

int MoveAlienMissile(param)
BUL_PMissile param;			/* Missiles */
{ /* MoveMissile */
  register DSP_PDLE DLE;
  register struct SpriteImage *Sprite;

  DLE=param->DLE;			/* For Speed */
  Sprite=param->Shape.Bob;

  CopyDownDLE(DLE);

  DLE->NewClass=Sprite->Class;
  DLE->NewImage=Sprite->Frames[param->PowImage.CurImage++];

  SetUpHitBox(&DLE->HitBox,DLE->NewImage);

  if(param->PowImage.CurImage==Sprite->Count)
     param->PowImage.CurImage=0;
  DLE->NewX+=param->Dx;
  DLE->NewY+=param->Dy;

  if (DLE->NewX<-16 || DLE->NewX>VIEW_WIDTH ||
      DLE->NewY<-16 || DLE->NewY>VIEW_HEIGHT) /* then he's offscreen */
      DLE->flags|=DLE_collision;	/* So kill him */

  if(DLE->flags&DLE_collision) {	/* I'm dead */
    DLE->NewClass=CLS_none;		/* Erase bullet */
    StopCollisionCheckingOn(DLE);
    DisplaySoftBob(DLE);
    (*param->Count)++;			/* Give Aliens bullet back */
    return 1;
  }

  DisplaySoftBob(DLE);			/* Update Screen */
  return 0;
}

void MoveLavaMissile(param,EQE)
BUL_PMissile param;			/* Missiles */
SCH_PEQE EQE;
{ /* MoveMissile */
  register DSP_PDLE DLE;
  register struct SpriteImage *Sprite;
  struct GraphObject *Obj;

  DLE=param->DLE;			/* For Speed */
  Sprite=param->Shape.Bob;

  CopyDownDLE(DLE);

  if(DLE->OldClass!=CLS_none) {
     Obj=(struct GraphObject *)DLE->OldImage;
     DLE->NewX+=Obj->HotX; DLE->NewY+=Obj->HotY;
  }
     
  DLE->NewClass=Sprite->Class;

  if(++param->PowImage.CurImage==Sprite->Count-1)
     param->PowImage.CurImage=Sprite->Count-3;

  DLE->NewImage=Sprite->Frames[param->PowImage.CurImage];
  Obj=(struct GraphObject *)DLE->NewImage;
  DLE->NewX-=Obj->HotX; DLE->NewY-=Obj->HotY;

  SetUpHitBox(&DLE->HitBox,DLE->NewImage);

  DLE->NewX+=param->Dx;
  DLE->NewY+=param->Dy;

  if (DLE->NewY>VIEW_HEIGHT) /* then he's offscreen */
      DLE->flags|=DLE_collision;	/* So kill him */

  if(DLE->flags&DLE_collision) {	/* I'm dead */
    DLE->NewClass=CLS_none;		/* Erase bullet */
    StopCollisionCheckingOn(DLE);
    DisplayBob(DLE);
    PURGEEQE(EQE);
    FREEEQE(EQE);
    FreeMissile(param,NOSPRITE);
    return;
  }

  DisplayBob(DLE);			/* Update Screen */

  ENQUEUEEVENT(EQE,EQE->period);
}

void SvrMoveAlienMissile(param,EQE)
BUL_PMissile param;
SCH_PEQE EQE;
{
   register BUL_PMissile Node;
   register BUL_PMissile Temp;
   register BUL_PMissile Head=param;
   register int flag;
   
   Node=Head->flink;
   while(Node!=Head) {
      flag=MoveAlienMissile(Node);	/* Move Missile */
      Temp=Node->flink;			/* Get next Missile */
      if(flag) {			/* If dead */
         (void)RemQue(Node);		/* Take from q */
         FreeMissile(Node,NOSPRITE);	/* FreeMissile */
      }
      Node=Temp;			/* Advance */
   }
   ENQUEUEEVENT(EQE,EQE->period);	/* Reschedule Server */
}
   
void AllocateMissiles()
{
  int i;
  FlipMyBullet(Sprite_UpBullet,Sprite_RightBullet);
  FlipMyBullet(Sprite_RightBullet,Sprite_DownBullet);
  FlipMyBullet(Sprite_DownBullet,Sprite_LeftBullet);

  FlipMyBullet(Sprite_BUpBullet,Sprite_BRightBullet);
  FlipMyBullet(Sprite_BRightBullet,Sprite_BDownBullet);
  FlipMyBullet(Sprite_BDownBullet,Sprite_BLeftBullet);

  if(!(FreeMissiles=AllocMem((MAXBULLETS+1)*sizeof(struct Missile_Param),
  				MEMF_CHIP)))
      DoAnAlert("InitFM-F:No memory for Free Missile pool");

  for(i=0;i<8;i++) {
    if(!(UBulletShapes[i]=AllocMem(72,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for UBulletShapes");
    if(!(DBulletShapes[i]=AllocMem(72,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for DBulletShapes");
    if(!(LBulletShapes[i]=AllocMem(72,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for LBulletShapes");
    if(!(RBulletShapes[i]=AllocMem(72,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for RBulletShapes");

    if(!(UBulletShapes2[i]=AllocMem(72,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for UBulletShapes");
    if(!(DBulletShapes2[i]=AllocMem(72,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for DBulletShapes");
    if(!(LBulletShapes2[i]=AllocMem(72,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for LBulletShapes");
    if(!(RBulletShapes2[i]=AllocMem(72,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for RBulletShapes");
    if(!(MissileShapes[i]=AllocMem(32,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for MissileShapes");
    if(!(SatelliteShapes[i]=AllocMem(36,MEMF_CHIP)))
      DoAnAlert("InitFM-F: No memory for SatelliteShapes");
  }
}

static void StartMissileServer(ServerQ,ServerFunction,period,name)
BUL_PMissile *ServerQ;
void (*ServerFunction)();
ULONG period;
char *name;
{
  *ServerQ=AllocMissile(NOSPRITE);
  (*ServerQ)->flink=(*ServerQ)->blink=*ServerQ;
  CreateEvent(ServerFunction,*ServerQ,period,name);
}

void InitialiseFreeMissiles()
{ /* InitialiseFreeMissiles */
  BUL_PMissile temp;
  DSP_PCOL p;
  int h,i;
  FreeMissiles->flink=FreeMissiles->blink=FreeMissiles;
  temp=FreeMissiles;
  
  for(i=0;i<MAXBULLETS-1;i++)  {
    temp++;
    p=AllocCOL();
    temp->DLE=AllocDLE();
    temp->DLE->COL=p;
    temp->DLE->param=(char *)temp;
    temp->DLE->param=(char *)temp;    
    temp->COL=p;
    p->DLE=temp->DLE;
    p->function=BulletCollisionRoutine;
    InsQue(FreeMissiles,temp);
  }
  for(i=0;i<8;i++) {
    for(h=0;h<(Sprite_RoundBulletH+2)*2;h++)
       MissileShapes[i][h]=Sprite_RoundBullet[h];
    for(h=0;h<(SATELLH+2)*2;++h)
       SatelliteShapes[i][h]=SatelliteSprite[h];
    for(h=0;h<36;h++) {
       UBulletShapes[i][h]=Sprite_UpBullet[h];
       RBulletShapes[i][h]=Sprite_RightBullet[h];
       LBulletShapes[i][h]=Sprite_LeftBullet[h];
       DBulletShapes[i][h]=Sprite_DownBullet[h];

       UBulletShapes2[i][h]=Sprite_BUpBullet[h];
       RBulletShapes2[i][h]=Sprite_BRightBullet[h];
       LBulletShapes2[i][h]=Sprite_BLeftBullet[h];
       DBulletShapes2[i][h]=Sprite_BDownBullet[h];
    }
  }

/* Start Server Events */

  StartMissileServer(&SvrMissileQ0,SvrMoveMissile,1,"MoveMissile Server A");
  StartMissileServer(&SvrMissileQ1,SvrMoveMissile,2,"MoveMissile Server B");

  StartMissileServer(&SvrAMissileQ0,SvrMoveAlienMissile,AMISSILERATE,
                     "MoveAMissile Server A");
  StartMissileServer(&SvrAMissileQ1,SvrMoveAlienMissile,BMISSILERATE,
                     "MoveAMissile Server B");
} 
 
void ReturnAllMissiles()
{
  BUL_PMissile t;
  int i;
  if(!FreeMissiles)return;
  t=FreeMissiles;
  t++;

  for(i=0;i<8;i++) {
    FreeMem(UBulletShapes[i],72);
    FreeMem(DBulletShapes[i],72);
    FreeMem(LBulletShapes[i],72);
    FreeMem(RBulletShapes[i],72);
    FreeMem(MissileShapes[i],32);
    FreeMem(SatelliteShapes[i],36);
  }
  FreeMem(FreeMissiles,(MAXBULLETS+1)*sizeof(struct Missile_Param));
}

BUL_PMissile FreeMissiles;

extern BulletDescriptor BulletTypes[];

int BLT_HomVelocity[4][2]={
   { 0,-5},
   { 5, 0},
   { 0, 5},
   {-5, 0}
};

void StartSatellite(x,y)
WORD x,y;
{
   register BUL_PMissile t;
   register struct SimpleSprite *Sprite;
   register DSP_PDLE DLE;
   
   if(!AlienBulletsAvailable)return;
   --AlienBulletsAvailable;

   t=AllocMissile(GIMMESPRITE);
   Sprite=&t->Shape.Spr->Sprite;
   DLE=t->DLE;
   DLE->flags=DLE_Satellite|DLE_Deadly|DLE_DoCollision;
   DLE->NewImage=(char *)Sprite;

   DLE->NewX=x;
   DLE->NewY=y;

   DLE->NewClass=CLS_Sprite;
   DLE->OldClass=CLS_none;

   Sprite->height=SATELLH;
   Change_Sprite(Sprite->num,SatelliteShapes[Sprite->num]);

   DLE->HitBox.BXoff=5;
   DLE->HitBox.BYoff=5;
   DLE->HitBox.TXoff=0;
   DLE->HitBox.TYoff=0;

   t->Dx=0;
   t->Dy=0;

   t->Mx=2;		/* Set Maximum velocity */
   t->My=2;

   t->Target.Enemy=OurShip.DLE;
      
   t->Count=&AlienBulletsAvailable;
   t->TimAnim.TimeOut=0;
   t->PowImage.Power=0;
   
   Set_Spr_Color(Sprite->num,0x069,0x08b,0x3cf);

   DoCollisionCheckingOn(DLE);
   DisplaySprite(DLE);
  
   CreateEvent(MoveHomer,t,5,"MoveHomer");
}

void StartHomerMissile(Dir)
int Dir;
{
   register BUL_PMissile t;
   register struct SimpleSprite *Sprite;
   register DSP_PDLE DLE;
   
   t=AllocMissile(GIMMESPRITE);
   if(!t)return;
   Sprite=&t->Shape.Spr->Sprite;
   DLE=t->DLE;
   DLE->flags=DLE_Bullet;
   DLE->NewImage=(char *)Sprite;

   DLE->NewX=OurShip.DLE->NewX+BulletTypes[0].StartOffset[Dir][0];
   DLE->NewY=OurShip.DLE->NewY+BulletTypes[0].StartOffset[Dir][1];

   DLE->NewClass=CLS_Sprite;
   DLE->OldClass=CLS_none;
   InsQue(DSP_SpriteList,t->COL);

   Sprite->height=Sprite_RoundBulletH;
   Change_Sprite(Sprite->num,MissileShapes[Sprite->num]);

   DLE->HitBox.BXoff=5;
   DLE->HitBox.BYoff=5;
   DLE->HitBox.TXoff=0;
   DLE->HitBox.TYoff=0;

   t->Dx=BLT_HomVelocity[Dir][0];
   t->Dy=BLT_HomVelocity[Dir][1];

   t->My=t->Mx=10;

   t->Target.Enemy=LockOnEnemy();
      
   t->Count=&OurShip.BulletsLeft;
   t->TimAnim.TimeOut=125;	/* 5 seconds */
   t->PowImage.Power=OurShip.CurPower;
   
   Set_Spr_Color(Sprite->num,0x0f00,0x0f0,0x00f);

   DisplaySprite(DLE);

   OurShip.BulletsLeft--;
  
   t->function=MoveHomer;
   InsQue(SvrMissileQ1,t);

   StartLaserSound();
}

void StartMissile(Dir)
int Dir;
{
  register BUL_PMissile t;
  register struct SimpleSprite *Sprite;
  register int i;
  register DSP_PDLE DLE;
  struct GraphObject *Obj;
  UWORD **shape;
  WORD *HitBox;
  BulletDescriptor *Bullet=&BulletTypes[0];

  if(OurShip.CurPower==1)
     Bullet=&BulletTypes[0];
  else
     Bullet=&BulletTypes[1];

  t=AllocMissile(GIMMESPRITE);
  if(!t)return;
  Sprite=&t->Shape.Spr->Sprite;
  DLE=t->DLE;
  DLE->flags=DLE_Bullet;
  DLE->NewImage=(char *)Sprite;

  Obj=(struct GraphObject *)OurShip.DLE->NewImage;
  DLE->NewX=OurShip.DLE->NewX+Obj->HotX+Bullet->StartOffset[Dir][0];
  DLE->NewY=OurShip.DLE->NewY+Obj->HotY+Bullet->StartOffset[Dir][1];
  DLE->NewClass=CLS_Sprite;
  DLE->OldClass=CLS_none;

  InsQue(DSP_SpriteList,t->COL);

  Sprite->height=BulletHeights[Dir];
  shape=Bullet->Shape[Dir];
  Change_Sprite(Sprite->num,shape[Sprite->num]);

  HitBox=Bullet->HitBox[Dir];
  DLE->HitBox.TXoff=*HitBox++;
  DLE->HitBox.TYoff=*HitBox++;
  DLE->HitBox.BXoff=*HitBox++;
  DLE->HitBox.BYoff=*HitBox;

  t->Dx=BLT_Direction[Dir][0];
  t->Dy=BLT_Direction[Dir][1];
  
  t->Count=&OurShip.BulletsLeft;
  t->PowImage.Power=OurShip.CurPower;
  
  HitBox=(WORD *)Bullet->Color;
  Set_Spr_Color(Sprite->num,HitBox[0],HitBox[1],HitBox[2]);

  DisplaySprite(DLE);
  OurShip.BulletsLeft--;

  t->function=MoveMissile;
  InsQue(SvrMissileQ0,t);

  StartLaserSound();
}

void StartPatternedMissile(x,y,pattern,NegateX)
WORD x,y;
ANM_PELEM pattern;
WORD NegateX;
{
   register BUL_PMissile Bullet;
   register DSP_PDLE DLE;
   register struct SimpleSprite *Sprite;
   register WORD Dir;
   BulletDescriptor *BulletData=&BulletTypes[0];
   WORD *ptr;
   UWORD **shape;

   OurShip.BulletsLeft--;
   Bullet=AllocMissile(GIMMESPRITE);
   if(!Bullet)return;
   Sprite=&Bullet->Shape.Spr->Sprite;
   
   if(CurrentLevel->flags&LB_ScrollVert) {
      shape=BulletData->Shape[Dir=BLT_Up];
      Change_Sprite(Sprite->num,shape[Sprite->num]);
   } else {
      shape=BulletData->Shape[Dir=BLT_Right];
      Change_Sprite(Sprite->num,shape[Sprite->num]);
   }

   DLE=Bullet->DLE;
   
   DLE->flags=DLE_Bullet;

   Sprite->height=BulletHeights[Dir];

   ptr=BulletData->HitBox[Dir];
   DLE->HitBox.TXoff=*ptr++;
   DLE->HitBox.TYoff=*ptr++;
   DLE->HitBox.BXoff=*ptr++;
   DLE->HitBox.BYoff=*ptr;

   
   ptr=(WORD *)BulletData->Color;
   Set_Spr_Color(Sprite->num,ptr[0],ptr[1],ptr[2]);

   DLE->NewImage=(char *)Sprite;
   if(NegateX)
      Bullet->flags=BUL_negatex;
   else
      Bullet->flags=0;

   InsQue(DSP_SpriteList,Bullet->COL);

   Bullet->Target.CurAnim=pattern;
   Bullet->TimAnim.AnimCount=pattern->Count;
   
   DLE->NewX=x;
   DLE->NewY=y;
   DLE->NewClass=CLS_Sprite;

   Bullet->Count=&OurShip.BulletsLeft;

   StartLaserSound();

   Bullet->function=MovePatternedMissile;
   InsQue(SvrMissileQ0,Bullet);
}

static WORD BulletTable[8][2]={
   {-2, 0},
   {-2,-2},
   { 2,-2},
   { 0,-2},
   {-2, 2},
   { 0, 2},
   { 2, 0},
   { 2, 2}
};

void StartEnemyMissilePrim(x,y,period,dx,dy)
WORD x,y,period;
WORD dx,dy;
{
   register BUL_PMissile t;
   register DSP_PDLE DLE;
   
   if(AlienBulletsAvailable<=0)return;

   t=AllocMissile(NOSPRITE);
   if(!t)return;
   DLE=t->DLE;

   DLE->flags=DLE_Bullet|DLE_Deadly|DLE_DoCollision;

   t->Shape.Bob=&AlienBulletImage;
 
   t->PowImage.CurImage=0;

   DLE->OldClass=DLE->NewClass=CLS_none;
 
   t->Dx=dx;
   t->Dy=dy;
   
   DLE->NewX=x;
   DLE->NewY=y;

   DoCollisionCheckingOn(DLE);
   t->Count=&AlienBulletsAvailable;
   
   --AlienBulletsAvailable;
   
   if(period==AMISSILERATE)
      InsQue(SvrAMissileQ0,t);
   else
      InsQue(SvrAMissileQ1,t);

/*  StartAlienLaserSound();*/
}

void StartLavaMissile(x,y,Image)
WORD x,y;
struct SpriteImage *Image;
{
   register BUL_PMissile t;
   register DSP_PDLE DLE;
   
   if(!(CurrentLevel->flags&LB_HoldScroll))return;
   t=AllocMissile(NOSPRITE);
   if(!t)return;
   DLE=t->DLE;

   DLE->flags=DLE_Bullet|DLE_Deadly;

   t->Shape.Bob=Image;
 
   DLE->OldClass=DLE->NewClass=CLS_none;
   t->PowImage.CurImage=-1;
 
   t->Dx=0;
   t->Dy=8;
   
   DLE->NewX=x;
   DLE->NewY=y;

   DoCollisionCheckingOn(DLE);
   
   CreateEvent(MoveLavaMissile,t,2,"Move lava missile");
/*  StartAlienLaserSound();*/
}

void StartEnemyMissilePrim2(x,y,period,dx,dy,Count)
WORD x,y,period;
WORD dx,dy;
BYTE *Count;
{
   register BUL_PMissile t;
   register DSP_PDLE DLE;
   
   t=AllocMissile(NOSPRITE);
   if(!t)return;
   DLE=t->DLE;

   (*Count)--;

   DLE->flags=DLE_Bullet|DLE_Deadly|DLE_DoCollision;

   t->Shape.Bob=&AlienBulletImage;
 
   t->PowImage.CurImage=0;

   DLE->OldClass=DLE->NewClass=CLS_none;
 
   t->Dx=dx;
   t->Dy=dy;
   
   DLE->NewX=x;
   DLE->NewY=y;

   DoCollisionCheckingOn(DLE);
   t->Count=Count;
   
   if(period==AMISSILERATE)
      InsQue(SvrAMissileQ0,t);
   else
      InsQue(SvrAMissileQ1,t);

/*  StartAlienLaserSound();*/
}

void StartEnemyMissile(x,y,period)
WORD x,y,period;
{
   register DSP_PDLE DLE;
   register WORD *ptr;
   register WORD Index;
   
   Index=(((y<OurShip.DLE->NewY)&1)<<2) +
         (((x<OurShip.DLE->NewX)&1)<<1) +
         ((x-OurShip.DLE->NewX<y-OurShip.DLE->NewY)&1);

   ptr=&BulletTable[Index][0];
   StartEnemyMissilePrim(x,y,period,ptr[0],ptr[1]);

}



void StartAlienMissile(Alien)
struct AlienParam *Alien;
{
   register WORD x,y;
   register struct GraphObject *Obj;

   DSP_PDLE DLE=Alien->DLE;

   if(rnd(100)>=30) return;
 
   Obj=(struct GraphObject *)(DLE->NewImage);
   x=Alien->DLE->NewX+Obj->HotX;
   y=Alien->DLE->NewY+Obj->HotY;

   StartEnemyMissile(x,y,AMISSILERATE);
}

extern ANM_ELEM Pat_Sweep1[];
extern ANM_ELEM Pat_SweepUp[];
extern ANM_ELEM Pat_SweepRight[];
extern ANM_ELEM Pat_SweepUDiagR[];
extern ANM_ELEM Pat_SweepDDiagR[];
extern ANM_ELEM Pat_SweepUpDiagR[];
extern ANM_ELEM Pat_SweepUpDiagL[];

void DoSweepLasers()
{
   register WORD x=OurShip.DLE->NewX;
   register WORD y=OurShip.DLE->NewY;
   register struct GraphObject *Obj=(struct GraphObject *)OurShip.DLE->NewImage;

   x+=Obj->HotX;
   y+=Obj->HotY;
   if(OurShip.BulletsLeft>=6) {
      if(CurrentLevel->flags&LB_ScrollVert) {
         StartPatternedMissile(x-16,y,Pat_Sweep1,0);
         StartPatternedMissile(x+16,y,Pat_Sweep1,1);
         StartPatternedMissile(x-4,y-16,Pat_SweepUp,0);
         StartPatternedMissile(x+4,y-16,Pat_SweepUp,0);
         StartPatternedMissile(x-2,y,Pat_SweepUpDiagL);
         StartPatternedMissile(x+2,y,Pat_SweepUpDiagR);
      } else {
         StartPatternedMissile(x+4,y-2,Pat_SweepRight,0);
         StartPatternedMissile(x+4,y+2,Pat_SweepRight,0);
         StartPatternedMissile(x,y-4,Pat_SweepUDiagR,0);
         StartPatternedMissile(x,y+4,Pat_SweepDDiagR,0);
         StartMissile(BLT_Up);
         StartMissile(BLT_Down);
     }
  }
}

void DoSideLasers()
{
   if(CurrentLevel->flags&LB_ScrollVert) {
      StartMissile(BLT_Up);
      StartMissile(BLT_Left);
      StartMissile(BLT_Right);
   } else {
      StartMissile(BLT_Up);
      StartMissile(BLT_Right);
      StartMissile(BLT_Down);
   }
}

void StartShipBullet()
{
   if(OurShip.BulletsLeft<=0)
     return;

   if(OurShip.flags&OSD_SweepLasers) {
      DoSweepLasers();
      return;
   }
   
   if(OurShip.flags&OSD_SideLasers)
      if(OurShip.BulletsLeft<3)
         return;
      else {
         DoSideLasers();
         return;
      }
         
   if(CurrentLevel->flags&LB_ScrollVert)
      if(OurShip.flags&OSD_Homers)
         StartHomerMissile(BLT_Up);
      else
         StartMissile(BLT_Up);
   else
      if(OurShip.flags&OSD_Homers)
         StartHomerMissile(BLT_Right);
      else
         StartMissile(BLT_Right);
}

