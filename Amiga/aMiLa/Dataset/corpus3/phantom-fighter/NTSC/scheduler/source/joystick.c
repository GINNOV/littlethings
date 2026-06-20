
#include <hardware/custom.h>
#include <exec/types.h>
#include <graphics/view.h>
#include <hardware/cia.h>
#include "joystick.h"
#include "displist.h"
#include "collision.h"
#include "scheduler.h"
#include "wave.h"
#include "game.h"
#include "view.h"
#include "copperfunc.h"
#include "token.h"

#define J_FRONT       0x100
#define J_BACK        0x001
#define J_RIGHT       0x003
#define J_LEFT        0x300
#define J_RIGHT_BACK  0x002
#define J_LEFT_BACK   0x301
#define J_RIGHT_FRONT 0x103
#define J_LEFT_FRONT  0x200

extern WORD CheatFlag;
extern struct SpriteImage Stuff1Image;
extern struct BitMap *bm2;
extern struct RasInfo RasInfo2;
#define MAXSPEEDUP 3

BYTE MotionSpeedUp[MAXSPEEDUP][2]={
   {2,1},				/* Slow */
   {3,2},				/* Medium */
   {4,3}
};

extern void CleanUpEvent();
extern void PrintScore();
struct OurShipData OurShip;


struct FIRE
   {
   UBYTE fire;
   };
#define FIRE1 (*((struct FIRE *)0xBFE0FF))
int JoyTable[16]={
   0x0,0x8,0xa,0x2,0x4,0x0,0x0,0x6,
   0x5,0x0,0x0,0x0,0x1,0x9,0x0,0x0
};

int ReadJoyStick()
{
   register UWORD a;
   register int b;
   a = custom.joy1dat & 0x0303;
   if(!(FIRE1.fire&0x80))
      b=jy_fire;
   else
      b=0;
   return JoyTable[((a&0x0300)>>6)|(a&0x3)]|b;
}

void MoveOurShipLR(Ship,EQE)
struct OurShipData *Ship;
SCH_PEQE EQE;
{
  register DSP_PDLE DLE;
  register struct GraphObject *Obj;
  register struct OurShipData *param=Ship;
  int JoyStick,flag;

  DLE=param->DLE;		/* Get fast DLE */
  Obj=(struct GraphObject *)DLE->NewImage;
  if(DLE->NewClass==CLS_none) {
     DLE->NewClass=CLS_Bob;
     SetUpHitBoxForShip(&DLE->HitBox,DLE->NewImage);
     XORBlit(DLE->NewImage,DLE->NewX,DLE->NewY);
     ENQUEUEEVENT(EQE,EQE->period);
     return;
  }
  
  CopyDownDLE(DLE);
  if(DLE->flags&DLE_collision) {
    XORBlit(DLE->NewImage,DLE->NewX,DLE->NewY);	/* Erase ship */
    PURGEEQE(EQE);
    RemQue(param->COL);
    return;
  }
  flag=0;
  JoyStick=(*param->mover)();	/* Read joystick */

  if(JoyStick&jy_fire) {
     if(OurShip.flags&OSD_FireUp) {
        OurShip.flags&=~OSD_FireUp;
        StartShipBullet();
     }
  } else
     OurShip.flags|=OSD_FireUp;

  if((JoyStick&jy_left)&&(DLE->NewX>OurShip.HorizSpeed)) {
    flag=1;
    DLE->NewX-=param->HorizSpeed;
    if(!param->Delay) {
      if((--param->CurImage)<0)param->CurImage=0;
      param->Delay=param->MaxDelay;
    }
  } else
    if((JoyStick&jy_right)&&(DLE->NewX+OurShip.HorizSpeed<295)) {
      flag=1;
      DLE->NewX+=param->HorizSpeed;
      if(!param->Delay) {
        if((++param->CurImage)==7)param->CurImage=6;
        param->Delay=param->MaxDelay;
      }
    }
  if(flag) {
     DLE->NewX+=Obj->HotX; DLE->NewY+=Obj->HotY;
     Obj=(struct GraphObject *)(DLE->NewImage=JustMe.Frames[param->CurImage]);
     DLE->NewX-=Obj->HotX; DLE->NewY-=Obj->HotY;
     SetUpHitBoxForShip(&DLE->HitBox,DLE->NewImage);
     DLE->NewClass=CLS_Bob;
  }
  if((JoyStick&jy_up)&&(DLE->NewY-OurShip.VertSpeed>0)) {
    flag=1;
    DLE->NewY-=param->VertSpeed;
  } else
    if((JoyStick&jy_down)&&(DLE->NewY+OurShip.VertSpeed<VIEW_HEIGHT-24)) {
      flag=1;
      DLE->NewY+=param->VertSpeed;
    }

  if(!flag&&param->CurImage!=3&&!param->Delay) {
     param->Delay=param->MaxDelay;
     if(param->CurImage<3)
       param->CurImage++;
     else
       param->CurImage--;
       
     DLE->NewImage=JustMe.Frames[param->CurImage];
     SetUpHitBoxForShip(&DLE->HitBox,DLE->NewImage);
     DLE->NewClass=CLS_Bob;
  }

  if(param->Delay)--param->Delay;

  DisplayBob(DLE);

  ENQUEUEEVENT(EQE,EQE->period);

}

void MoveOurShipUD(param,EQE)
struct OurShipData *param;
SCH_PEQE EQE;
{
  register DSP_PDLE DLE=param->DLE;
  register int JoyStick;
  register struct GraphObject *Obj;

  Obj=(struct GraphObject *)DLE->NewImage;

  CopyDownDLE(DLE);
  if(DLE->flags&DLE_collision) {
    DLE->NewClass=CLS_none;
    DisplayBob(DLE);
    PurgeEvent(EQE);
    FreeEQE(EQE);
    RemQue(param->COL);
    return;
  }
   
  JoyStick=(*param->mover)();	/* Read joystick */

  if(JoyStick&jy_fire&&OurShip.flags&OSD_FireUp) {
    OurShip.flags&=~OSD_FireUp;
    StartShipBullet();
  }
  if(!(JoyStick&jy_fire))
     OurShip.flags|=OSD_FireUp;

  if(JoyStick&jy_left) {
     DLE->NewX-=param->HorizSpeed;
     if(DLE->NewX<0)DLE->NewX=0;
  } else if(JoyStick&jy_right) {
     DLE->NewX+=param->HorizSpeed;
     if(DLE->NewX>285)DLE->NewX=285;
  }
  if(JoyStick&jy_up) {
     DLE->NewY-=param->VertSpeed;
     if(DLE->NewY<0)DLE->NewY=0;
  } else if(JoyStick&jy_down) {
     DLE->NewY+=param->VertSpeed;
     if(DLE->NewY>VIEW_HEIGHT-24)DLE->NewY=VIEW_HEIGHT-24;
  }
  if(!--param->Delay) {
     if(JoyStick&jy_up)
        param->CurImage=10;
     else if(JoyStick&jy_down)
           param->CurImage=8;
     else
        param->CurImage=9;
     param->Delay=param->MaxDelay;
     DLE->NewX+=Obj->HotX; DLE->NewY+=Obj->HotY;
     Obj=(struct GraphObject *)
         (DLE->NewImage=JustMe.Frames[param->CurImage]);
     DLE->NewX-=Obj->HotX; DLE->NewY-=Obj->HotY;
     DLE->NewClass=CLS_Bob;
     SetUpHitBoxForShip(&DLE->HitBox,DLE->NewImage);
  }
  DisplayBob(DLE);
  ENQUEUEEVENT(EQE,EQE->period);
}

void CollidedWithShip(DLE,cDLE)
DSP_PDLE DLE,cDLE;
{
    register TokenDescriptor *Token;
    register struct GraphObject *Obj;

    if(DLE->flags&DLE_OurShip) return;
    if(DLE->flags&DLE_AlienParam||DLE->flags&DLE_Token)
       DLE->flags|=DLE_collision;		/* Alien is dead */
    if(DLE->flags&DLE_Token) {
       Token=(TokenDescriptor *)DLE->param;
       OurShip.Score+=50;
       StartTokenSound();
       switch(Token->CurImage) {
          case TOK_HOMER:
                OurShip.NumTokens=Token->CurImage;
                OurShip.flags|=OSD_Homers;
                OurShip.flags&=~(OSD_SideLasers|OSD_SweepLasers);
		if(OurShip.MaxBullets<=6)
                   OurShip.BulletsLeft+=(6-OurShip.MaxBullets);
                OurShip.MaxBullets=6;
             break;
	  case TOK_DOUBLE:
                if(OurShip.CurPower<20)
                   ++OurShip.CurPower;
                break;
          case TOK_FASTER:
             if((OurShip.CurMSpeedUp+1)<MAXSPEEDUP) {
                ++OurShip.CurMSpeedUp;
                OurShip.HorizSpeed=MotionSpeedUp[OurShip.CurMSpeedUp][0];
                OurShip.VertSpeed=MotionSpeedUp[OurShip.CurMSpeedUp][1];
             }
             break;
          case TOK_LASER:
             OurShip.NumTokens=Token->CurImage;
	     OurShip.flags&=~(OSD_SideLasers|OSD_Homers|OSD_SweepLasers);
             if(OurShip.MaxBullets<6) {
                ++OurShip.MaxBullets;
                ++OurShip.BulletsLeft;
             }
             break;
          case TOK_SIDE:
             OurShip.NumTokens=Token->CurImage;
             if(OurShip.MaxBullets<6)
                OurShip.BulletsLeft+=(6-OurShip.MaxBullets);
             OurShip.MaxBullets=6;
             OurShip.flags|=OSD_SideLasers;
             OurShip.flags&=~(OSD_Homers|OSD_SweepLasers);
             break;
          case TOK_PLASMA:
               OurShip.NumTokens=Token->CurImage;
               OurShip.flags&=~(OSD_SideLasers|OSD_Homers);
               OurShip.flags|=OSD_SweepLasers;
               OurShip.BulletsLeft+=(6-OurShip.MaxBullets);
               OurShip.MaxBullets=6;
             break;
       }
       UpDateTokenWindow(OurShip.NumTokens);
       return;
    }
    if((DLE->flags&DLE_Deadly)&&0) {	/* Alien was deadly */
      CreateEvent(CleanUpEvent,NULL,150,"CleanUp");

      Obj=(struct GraphObject *)OurShip.DLE->NewImage;
      MakeExplosion(NULL,NULL,OurShip.DLE->NewX+Obj->HotX+8,
      			      OurShip.DLE->NewY+Obj->HotY-8,
                              2,-2);
      MakeExplosion(NULL,NULL,OurShip.DLE->NewX+Obj->HotX+8,
      			      OurShip.DLE->NewY+Obj->HotY+8,
                              2,2);
      MakeExplosion(NULL,NULL,OurShip.DLE->NewX+Obj->HotX-8,
      			      OurShip.DLE->NewY+Obj->HotY+8,
                              -2,2);
      MakeExplosion(NULL,NULL,OurShip.DLE->NewX+Obj->HotX-8,
      			      OurShip.DLE->NewY+Obj->HotY-8,
                              -2,-2);

      MakeExplosion(NULL,NULL,OurShip.DLE->NewX+Obj->HotX,
      			      OurShip.DLE->NewY+Obj->HotY,
                              0,0);
      if(OurShip.CurMSpeedUp>0)
         OurShip.CurMSpeedUp=1;
      else
         OurShip.CurMSpeedUp=0;

      OurShip.CurPower=1;
      OurShip.flags&=~(OSD_Homers|OSD_SideLasers|OSD_SweepLasers);
      OurShip.NumTokens=TOK_FASTER;
      if(OurShip.MaxBullets>1)
         OurShip.MaxBullets=2;
      else
         OurShip.MaxBullets=1;
      OurShip.BulletsLeft=OurShip.MaxBullets;
      CurrentLevel->flags|=LB_ShipDead;
      cDLE->flags|=DLE_collision;			/* Tell man hes dead */
      if(CurrentLevel->flags&LB_ScrollHoriz) {
        OurShip.Penetration=RasInfo2.RxOffset-100;
        if(OurShip.Penetration<0)OurShip.Penetration=0;
      } else {
        OurShip.Penetration=RasInfo2.RyOffset+100;
        if(OurShip.Penetration>=bm2->Rows-VIEW_HEIGHT)OurShip.Penetration=
        		bm2->Rows-1-VIEW_HEIGHT;
      }
    }
}

extern ULONG LastScore;

void InitialiseOurShip()
{
  OurShip.NumTokens=0;
  OurShip.CurMSpeedUp=1;
  OurShip.MaxBullets=2;
  OurShip.CurPower=1;
  LastScore=0;

  OurShip.mover=ReadJoyStick;		/* Joystick routine */
  OurShip.Penetration=0;
  OurShip.flags=0;
  OurShip.Lives=5;			/* up to 9 lives */
  OurShip.Score=0;			/* Score is zero */
  OurShip.Level=-1;
  OurShip.ExtraLifeScore=10000;		/* First extra life at 10000 */
}

void StartOurShip()
{
  DSP_PCOL p;
  OurShip.DLE=AllocDLE();		/* Get DLE for ship */
  OurShip.DLE->HitBox.TXoff=0;
  OurShip.DLE->HitBox.TYoff=0;
  OurShip.DLE->HitBox.BXoff=23;
  OurShip.DLE->HitBox.BYoff=23;
  OurShip.BulletsLeft=OurShip.MaxBullets;
  p=AllocCOL();				/* Get Collision Object */
  OurShip.COL=p;
  p->DLE=OurShip.DLE;			/* Link DLE to COL */

/* A routine to call if collision detected */

  p->function=CollidedWithShip;

/* We're one of the Good Guys, so put in Good Guys List */

  InsQue(DSP_GoodCollisions,p);

  OurShip.DLE->OldClass=CLS_none;
  OurShip.DLE->flags=DLE_OurShip|DLE_Mask;
  OurShip.DLE->param=(char *)&OurShip;
  OurShip.DLE->NewClass=CLS_none;	/* For now! */
  OurShip.DLE->NewX=150;
  OurShip.DLE->NewY=140;		/* Position Ship */
  if(CurrentLevel->flags&LB_ScrollHoriz) {
    OurShip.DLE->NewY=(VIEW_HEIGHT>>1)-8;
    OurShip.DLE->NewX=10;
    OurShip.CurImage=0;
    OurShip.DLE->NewImage=JustMe.Frames[7];
  } else {
    OurShip.CurImage=2;
    OurShip.DLE->NewImage=JustMe.Frames[3];
  }

  OurShip.mover=ReadJoyStick;		/* Joystick routine */
  OurShip.HorizSpeed=MotionSpeedUp[OurShip.CurMSpeedUp][0];	/* Horizontal speed */
  OurShip.VertSpeed=MotionSpeedUp[OurShip.CurMSpeedUp][1];	/* Vertical Speed */
  OurShip.Delay=1;			/* Bank immeadiately */
  OurShip.MaxDelay=6;			/* Max delay */

  OurShip.flags|=OSD_FireUp;

  if(CurrentLevel->flags&LB_ScrollHoriz)
    CreateEvent(MoveOurShipUD,&OurShip,1,"PlayerU");
  else
    CreateEvent(MoveOurShipLR,&OurShip,1,"PlayerL"); /* start ship ctrl */

  DoNextAndRepeat(PrintScore,&OurShip.Score,50,"Score");
}

