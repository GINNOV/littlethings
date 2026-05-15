#include "Scheduler.h"
#include "Displist.h"
#include "GameParam.h"
#include "Eyes.h"
#include "Game.h"
#include "iff.h"
#include "view.h"
#include <graphics/view.h>

extern void CleanUpEvent();
extern WORD LastLevelLoaded;

extern struct RasInfo RasInfo2;

extern struct SpriteImage Spare1Image;
extern struct SpriteImage Spare2Image;
extern struct SpriteImage Spare3Image;
extern struct SpriteImage Spare4Image;
extern struct SpriteImage Spare5Image;
extern struct SpriteImage Spare6Image;
extern struct SpriteImage Spare7Image;
extern struct SpriteImage Spare8Image;
extern struct SpriteImage Spare9Image;
extern struct SpriteImage Spare10Image;
extern struct SpriteImage Spare11Image;
extern struct SpriteImage Spare12Image;

extern struct SpriteImage EyeImage;
extern struct SpriteImage FireBall_16;
extern struct SpriteImage ClockWork;

extern BYTE AlienBulletsAvailable;
extern struct SpriteImage DeadEyeImage;
extern BYTE OKToDoWave;

EyeDescriptor ActiveEyes[NUMEYES];
WORD ActiveEyePtr=0;
WORD NextDueEye;

extern void StartBud();
extern void AnimateBud();
extern void StartEye();
extern void StartLavaEye();
extern void StartIris();
extern void StartBackGroundObject();
extern void StartBackGroundObjectB();
extern void StartBoundedGroundObject();
extern void StartBoundedObject();
extern void StartLavaBubble();
extern void StartHexGun();

ObjectDescriptor CheeseObjectList[]={
   {"Star-Bobs",&ClockWork},
   {"Plant-a"	,&Spare1Image},
   {"Plant-b"	,&Spare2Image},
   {"Plant-c"	,&Spare3Image},
   {"Plant-d"	,&Spare4Image},
   {"Plant-e"	,&Spare5Image},
   {NULL,NULL}
};

ObjectDescriptor LavaObjectList[]={
   {"Iris-3D",&Spare1Image},
   {"BullsEye",&Spare2Image},
   {"Lava-Eye",&Spare4Image},
   {"FireBall-16"	,&FireBall_16},
   {"Lava-FireBall",&Spare3Image},
   {NULL,NULL}
};

ObjectDescriptor SandStormObjectList[]={
   {"Eye"	,&EyeImage},
   {"DeadEye"	,&DeadEyeImage},
   {"clockwork-bug",&ClockWork},
   {NULL,NULL}
};

ObjectDescriptor CavernObjectList[]={
   {"clockwork-bug",&ClockWork},
   {NULL,NULL}
};

ObjectDescriptor HangarObjectList[]={
   {"Hex-Gun",&Spare4Image},
   {"Iris-3D",&Spare3Image},
   {"HangerTL",&Spare5Image},
   {"HangerTR",&Spare6Image},
   {"HangerBL",&Spare7Image},
   {"HangerBR",&Spare8Image},
   {"HangerIris",&Spare9Image},
   {"HangerBall",&Spare10Image},
#ifdef qwerty
   {"Cone-a",&Spare1Image},
   {"Cone-b",&Spare2Image},
#else
   {"clockwork-bug",&ClockWork},
#endif
   {NULL,NULL}
};

ObjectDescriptor *ObjectListForLevel[]={
   CavernObjectList,
   SandStormObjectList,
   CheeseObjectList,
   LavaObjectList,
   HangarObjectList
};

BackGroundObject CheeseObjects[]={
   { 377, 65,	StartBoundedGroundObject,&Spare5Image,3,	0,	7},
   { 493,148,	StartBoundedGroundObject,&Spare1Image,3,	21,	24},
   { 532, 23,	StartBoundedGroundObject,&Spare4Image,2,	8,	19},
   { 564,155,	StartBoundedGroundObject,&Spare5Image,2,	8,	13},
   { 774,141,	StartBoundedGroundObject,&Spare4Image,5,	0,	7},
   { 962, 92,	StartBoundedGroundObject,&Spare4Image,5,	20,	25},
   {1005,104,	StartBoundedGroundObject,&Spare1Image,5,	17,	20},
   {1021, 66,	StartBoundedGroundObject,&Spare3Image,4,	10,	17},
   {1036,148,	StartBoundedGroundObject,&Spare1Image,3,	11,	16},
   {1084, 16,	StartBoundedGroundObject,&Spare2Image,4,	16,     21},
   {1093,184,	StartBoundedGroundObject,&Spare1Image,4,	25,     30},
   {1095, 62,	StartBoundedGroundObject,&Spare1Image,6,	5,	10},
   {1109,129,	StartBoundedGroundObject,&Spare1Image,5,	0,	4},
   {1125,184,	StartBoundedGroundObject,&Spare2Image,3,	0,	5},
   {1130, 99,	StartBoundedGroundObject,&Spare5Image,2,	14,	28},
   {1157,184,	StartBoundedGroundObject,&Spare2Image,4,	6,	15},
   {1164,113,	StartBoundedGroundObject,&Spare3Image,5,	0,	9},
   {1176, 28,	StartBoundedGroundObject,&Spare2Image,4,	22,	25},
   {1199,184,	StartBoundedGroundObject,&Spare3Image,5,	18,	23},
   {1208,110,	StartBoundedGroundObject,&Spare2Image,3,	26,	29},
   {-10000,0,	NULL,			NULL,0,			0,	0}
};
  
BackGroundObject LavaObjects[]={
   {149, 50,StartLavaBubble,&Spare2Image,1,	0,	22},
   {111,59,StartLavaEye,&Spare4Image,2,0,0},
   {188,59,StartLavaEye,&Spare4Image,2,0,0},
   {253,692,StartIris,&Spare1Image,2,0,0},
   { 72,697,StartIris,&Spare1Image,2,0,0},
   {216,860,StartIris,&Spare1Image,2,0,0},
   { 19,905,StartIris,&Spare1Image,2,0,0},
   {175,1071,StartIris,&Spare1Image,2,0,0},
   {-10000,0,NULL,NULL,0,0,0}
};

BackGroundObject SandStormObjects[]={
   {228,354,StartEye,NULL,0,0,0},	/* x,y,function,image,delay,first,last */
   {109,616,StartEye,NULL,0,0,0},
   {267,718,StartEye,NULL,0,0,0},
   { 90,823,StartEye,NULL,0,0,0},
   {186,974,StartEye,NULL,0,0,0},
   {-10000,0,NULL,NULL,0,0,0}
};

BackGroundObject HangarObjects[]={
   { 161,91,StartIris,&Spare3Image,2,0,0},
   { 259,71,StartHexGun,&Spare4Image,1,0,0},
   { 314,122,StartHexGun,&Spare4Image,1,0,0},
   { 335,31,StartHexGun,&Spare4Image,1,0,0},
   { 429,102,StartHexGun,&Spare4Image,1,0,0},
   { 562,33,StartHexGun,&Spare4Image,1,0,0},
   { 618,63,StartHexGun,&Spare4Image,1,0,0},
   { 618,101,StartHexGun,&Spare4Image,1,0,0},
   { 917,41,StartIris,&Spare3Image,2,0,0},
   { 917,100,StartIris,&Spare3Image,2,0,0},
   { 917,162,StartIris,&Spare3Image,2,0,0},
   {1037,99,StartBackGroundObjectB,&Spare9Image,3,0,9},
   {1119,159,StartBackGroundObject,&Spare10Image,4,0,15},
   {1118, 39,StartBackGroundObjectB,&Spare10Image,1,0,15},
#ifdef qwerty
   {1129, 59,StartBoundedObject,&Spare1Image,2,0,5},
   {1130,140,StartBoundedObject,&Spare2Image,2,0,5},
   {1149, 87,StartBoundedObject,&Spare1Image,2,8,15},
   {1149,118,StartBoundedObject,&Spare1Image,2,18,25},
#endif
   {1154,138,StartBackGroundObject,&Spare10Image,2,0,15},
   {1154,62,StartBackGroundObjectB,&Spare10Image,1,0,15},
   {1169,100,StartBackGroundObject,&Spare10Image,2,0,15},
   {-10000,0,NULL,NULL,0,0,0}
};

extern void CheckUpOnEyes();
extern void CheckUpOnHorizEyes();

void (*CheckUpFunction)();

void (*CheckUpTable[])()={
   NULL,
   CheckUpOnEyes,
   CheckUpOnHorizEyes,
   CheckUpOnEyes,
   CheckUpOnHorizEyes
};

BackGroundObject *BackGroundObjectTable;

BackGroundObject *ObjectsOnLevels[]={
   NULL,
   SandStormObjects,
   CheeseObjects,
   LavaObjects,
   HangarObjects
};

/*************************************************
 * This Animates an Eye */

extern void AnimateEyeClosing();

void AnimateEyeDying(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register EyeDescriptor *Eye=param;
   register DSP_PDLE DLE=&param->DLE;
   register CyclicAnimation *CAnim=&param->CAnim;
   struct GraphObject *Obj;
   
   if(!--CAnim->Delay) {		/* Time to change frame */
      CAnim->Delay=CAnim->MaxDelay;
      if(++CAnim->CurImage>=CAnim->Image->Count) {
         PURGEEQE(EQE);
         FREEEQE(EQE);
         return;
      }
      Obj=(struct GraphObject *)DLE->NewImage;
      Eye->x+=Obj->HotX; Eye->y+=Obj->HotY;
      DLE->NewImage=CAnim->Image->Frames[CAnim->CurImage];
      Obj=(struct GraphObject *)DLE->NewImage;
      Eye->x-=Obj->HotX; Eye->y-=Obj->HotY;
      BlitBackGroundBob(DLE->NewImage,Eye->x,Eye->y);
   }
   
   ENQUEUEEVENT(EQE,EQE->period);
}

 
void AnimateEyeOpening(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register EyeDescriptor *Eye=param;
   register DSP_PDLE DLE=&param->DLE;
   register CyclicAnimation *CAnim=&param->CAnim;
   register struct GraphObject *Obj;
   
   Obj=(struct GraphObject *)DLE->NewImage;

   if(DLE->flags&DLE_collision) {
      StopCollisionCheckingOn(DLE);
      *(Eye->Parent)=-*(Eye->Parent);
      EQE->function=AnimateEyeDying;
      CAnim->Image=&DeadEyeImage;
      CAnim->CurImage=-1;
      EQE->period=2;
      ENQUEUEEVENT(EQE,EQE->period);
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      MakeExplosion(NULL,NULL,DLE->NewX+Obj->HotX,
      			      DLE->NewY+Obj->HotY,0,0);
      return;
   }
   
   if(!--CAnim->Delay) {		/* Time to change frame */
      CAnim->Delay=CAnim->MaxDelay;
      if(++CAnim->CurImage>=CAnim->Image->Count) {
          EQE->function=AnimateEyeClosing;
          ENQUEUEEVENT(EQE,EQE->period);
          return;
      }
      if(DLE->NewClass!=CLS_none) {
         Eye->x+=Obj->HotX;
         Eye->y+=Obj->HotY;
      }
      DLE->NewImage=CAnim->Image->Frames[CAnim->CurImage];
      Obj=(struct GraphObject *)DLE->NewImage;
      SetUpHitBox(&DLE->HitBox,DLE->NewImage);
      Eye->x-=Obj->HotX;
      Eye->y-=Obj->HotY;
      DLE->NewClass=CLS_Bob;
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      BlitBackGroundBob(DLE->NewImage,Eye->x,Eye->y);
   }
   
   if(CAnim->Image->Count-CAnim->CurImage<=4)
       StartEnemyMissile(DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY,BMISSILERATE);
   
   if(DLE->NewX<-32||DLE->NewY>VIEW_HEIGHT) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      StopCollisionCheckingOn(DLE);
   } else
      ENQUEUEEVENT(EQE,EQE->period);
}

void AnimateEyeClosing(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register EyeDescriptor *Eye=param;
   register DSP_PDLE DLE=&param->DLE;
   register CyclicAnimation *CAnim=&param->CAnim;
   register struct GraphObject *Obj;
   
   Obj=(struct GraphObject *)DLE->NewImage;

   if(DLE->flags&DLE_collision) {
      StopCollisionCheckingOn(DLE);
      *(Eye->Parent)=-*(Eye->Parent);
      EQE->function=AnimateEyeDying;
      CAnim->Image=&DeadEyeImage;
      CAnim->CurImage=-1;
      ENQUEUEEVENT(EQE,EQE->period);
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      MakeExplosion(NULL,NULL,DLE->NewX+Obj->HotX,
      			      DLE->NewY+Obj->HotY,0,0);
      return;
   }
   
   if(!--CAnim->Delay) {		/* Time to change frame */
      CAnim->Delay=CAnim->MaxDelay;
      if(--CAnim->CurImage<0) {
         EQE->function=AnimateEyeOpening;
         ENQUEUEEVENT(EQE,EQE->period);
         return;
      }
      if(DLE->NewClass!=CLS_none) {
         Eye->x+=Obj->HotX;
         Eye->y+=Obj->HotY;
      }
      DLE->NewImage=CAnim->Image->Frames[CAnim->CurImage];
      Obj=(struct GraphObject *)DLE->NewImage;
      SetUpHitBox(&DLE->HitBox,DLE->NewImage);
      Eye->x-=Obj->HotX;
      Eye->y-=Obj->HotY;
      DLE->NewClass=CLS_Bob;
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      BlitBackGroundBob(DLE->NewImage,Eye->x,Eye->y);
   }
   
   if(CAnim->Image->Count-CAnim->CurImage<=4)
       StartEnemyMissile(DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY,BMISSILERATE);
   
   if(DLE->NewX<-32||DLE->NewY>VIEW_HEIGHT) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      StopCollisionCheckingOn(DLE);
   } else
      ENQUEUEEVENT(EQE,EQE->period);
}

extern void AnimateIrisClosing();
 
void AnimateIrisOpening(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register EyeDescriptor *Eye=param;
   register DSP_PDLE DLE=&param->DLE;
   register CyclicAnimation *CAnim=&param->CAnim;
   register struct GraphObject *Obj;
   
   Obj=(struct GraphObject *)DLE->NewImage;

   if(DLE->flags&DLE_collision) {
      StopCollisionCheckingOn(DLE);
      *(Eye->Parent)=-*(Eye->Parent);
    		      /* Print Dead Iris */
      BlitBackGroundBob(Eye->CAnim.Image->Frames[15],Eye->x,Eye->y);
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      MakeExplosion(NULL,NULL,DLE->NewX+Obj->HotX,
      			      DLE->NewY+Obj->HotY,0,0);
      PURGEEQE(EQE);
      FREEEQE(EQE);
      return;
   }
   
   if(!--CAnim->Delay) {		/* Time to change frame */
      CAnim->Delay=CAnim->MaxDelay;
      if(++CAnim->CurImage>=15) {
          EQE->function=AnimateIrisClosing;
          ENQUEUEEVENT(EQE,EQE->period);
          return;
      }
      if(DLE->NewClass!=CLS_none) {
         Eye->x+=Obj->HotX;
         Eye->y+=Obj->HotY;
      }
      DLE->NewImage=CAnim->Image->Frames[CAnim->CurImage];
      Obj=(struct GraphObject *)DLE->NewImage;
      SetUpHitBox(&DLE->HitBox,DLE->NewImage);
      Eye->x-=Obj->HotX;
      Eye->y-=Obj->HotY;
      DLE->NewClass=CLS_Bob;
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      BlitBackGroundBob(DLE->NewImage,Eye->x,Eye->y);
   }
   
   if(CAnim->CurImage>=13)
       StartEnemyMissile(DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY,BMISSILERATE);
   
   if(DLE->NewX<-32||DLE->NewY>VIEW_HEIGHT) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      StopCollisionCheckingOn(DLE);
   } else
      ENQUEUEEVENT(EQE,EQE->period);
}

void AnimateIrisClosing(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register EyeDescriptor *Eye=param;
   register DSP_PDLE DLE=&param->DLE;
   register CyclicAnimation *CAnim=&param->CAnim;
   register struct GraphObject *Obj;
   
   Obj=(struct GraphObject *)DLE->NewImage;

   if(DLE->flags&DLE_collision) {
      StopCollisionCheckingOn(DLE);
      *(Eye->Parent)=-*(Eye->Parent);
      BlitBackGroundBob(Eye->CAnim.Image->Frames[15],Eye->x,Eye->y);
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      MakeExplosion(NULL,NULL,DLE->NewX+Obj->HotX,
      			      DLE->NewY+Obj->HotY,0,0);
      PURGEEQE(EQE);
      FREEEQE(EQE);
      return;
   }
   
   if(!--CAnim->Delay) {		/* Time to change frame */
      CAnim->Delay=CAnim->MaxDelay;
      if(--CAnim->CurImage<0) {
         EQE->function=AnimateIrisOpening;
         ENQUEUEEVENT(EQE,EQE->period);
         return;
      }
      if(DLE->NewClass!=CLS_none) {
         Eye->x+=Obj->HotX;
         Eye->y+=Obj->HotY;
      }
      DLE->NewImage=CAnim->Image->Frames[CAnim->CurImage];
      Obj=(struct GraphObject *)DLE->NewImage;
      SetUpHitBox(&DLE->HitBox,DLE->NewImage);
      Eye->x-=Obj->HotX;
      Eye->y-=Obj->HotY;
      DLE->NewClass=CLS_Bob;
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      BlitBackGroundBob(DLE->NewImage,Eye->x,Eye->y);
   }
   
   if(CAnim->CurImage>13)
       StartEnemyMissile(DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY,BMISSILERATE);
   
   if(DLE->NewX<-32||DLE->NewY>VIEW_HEIGHT) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      StopCollisionCheckingOn(DLE);
   } else
      ENQUEUEEVENT(EQE,EQE->period);
}

void StartIris(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Iris;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   if(ptr->x<0) {
     struct GraphObject *Obj;
     Obj=(struct GraphObject *)ptr->Image->Frames[ptr->Image->Count-1];

     BlitBackGroundBob(Obj,-ptr->x-Obj->HotX,
     			ptr->y-Obj->HotY);
     return;
   }

   Iris=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   Iris->x=ptr->x; Iris->y=ptr->y;
   Iris->NumHits=6;

   Iris->Parent=&(ptr->x);
   
   DLE=&Iris->DLE;
   DLE->param=(char *)Iris;
   
   DLE->flags=0;
   DLE->NewX=-100;
   SetUpHitBox(&DLE->HitBox,ptr->Image->Frames[0]);
   DoGroundCheckingOn(DLE);
   DLE->NewClass=CLS_none;
   DLE->flags|=DLE_Iris|DLE_DoCollision;
   
   CAnim=&Iris->CAnim;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=1;			/* Changes frame every 6 ticks */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateIrisOpening,Iris,SCROLLTICKS,"Animate Iris",
   			ActiveEyePtr&3);
}

void StartEye(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   if(ptr->x<0) {
     struct GraphObject *Obj;
     Obj=(struct GraphObject *)DeadEyeImage.Frames[DeadEyeImage.Count-1];
     BlitBackGroundBob(Obj,-ptr->x-Obj->HotX,
     			ptr->y-Obj->HotY);
     return;
   }

   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   Eye->x=ptr->x; Eye->y=ptr->y;
   Eye->NumHits=4;
   Eye->Parent=&(ptr->x);
   
   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   DLE->flags=0;
   DLE->NewX=-100;
   SetUpHitBox(&DLE->HitBox,EyeImage.Frames[0]);
   DoGroundCheckingOn(DLE);
   DLE->flags|=DLE_Eye|DLE_DoCollision;
   DLE->NewClass=CLS_none;
   
   CAnim=&Eye->CAnim;
   CAnim->Image=&EyeImage;
   CAnim->MaxDelay=2;			/* Changes frame every 6 ticks */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateEyeOpening,Eye,SCROLLTICKS,"Animate Eye",
   			ActiveEyePtr&3);
}

void AnimateBackGroundObject(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&param->DLE;

   CyclicAnimateBackGroundObject(&param->CAnim,DLE);

   param->x=DLE->NewX-RasInfo2.RxOffset;
   param->y=DLE->NewY-RasInfo2.RyOffset;
   if(param->x<-32||param->y>VIEW_HEIGHT) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
   } else
      ENQUEUEEVENT(EQE,EQE->period);
}

extern int AnimateBackGroundObjectBackwards();

extern void AnimateBackGroundObjectC();

void AnimateBackGroundObjectB(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&param->DLE;

   if(AnimateBackGroundObjectForward(&param->CAnim,DLE))
      EQE->function=AnimateBackGroundObjectC;

   param->x=DLE->NewX-RasInfo2.RxOffset;
   param->y=DLE->NewY-RasInfo2.RyOffset;
   if(param->x<-32||param->y>VIEW_HEIGHT) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
   } else
      ENQUEUEEVENT(EQE,EQE->period);
}

void AnimateBackGroundObjectC(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&param->DLE;

   if(AnimateBackGroundObjectBackwards(&param->CAnim,DLE))
      EQE->function=AnimateBackGroundObjectB;

   param->x=DLE->NewX-RasInfo2.RxOffset;
   param->y=DLE->NewY-RasInfo2.RyOffset;
   if(param->x<-32||param->y>VIEW_HEIGHT) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
   } else
      ENQUEUEEVENT(EQE,EQE->period);
}

void AnimateHexGun(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&param->DLE;
   register struct GraphObject *Obj;

   CyclicAnimateBackGroundObject(&param->CAnim,DLE);

   Obj=(struct GraphObject *)DLE->NewImage;
   param->x=DLE->NewX-RasInfo2.RxOffset;
   param->y=DLE->NewY-RasInfo2.RyOffset;

   if((param->CAnim.Delay==1)&&(param->CAnim.CurImage==7))
      StartEnemyMissile(param->x+Obj->HotX,param->y+Obj->HotY,AMISSILERATE);

   if((param->CAnim.Delay==param->CAnim.MaxDelay)&&
      (param->CAnim.CurImage==param->CAnim.Image->Count-1))
      ENQUEUEEVENT(EQE,100+rnd(50));
   else
      if(param->x<-32||param->y>VIEW_HEIGHT) {
         PURGEEQE(EQE);
         FREEEQE(EQE);
      } else
         ENQUEUEEVENT(EQE,EQE->period);
}

void AnimateBoundedGroundObject(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&param->DLE;

   CyclicAnimateBoundedGroundObject(&param->CAnim,DLE);

   param->x=DLE->NewX-RasInfo2.RxOffset;
   param->y=DLE->NewY-RasInfo2.RyOffset;
   if(param->x<-32||param->y>VIEW_HEIGHT) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
   } else
      ENQUEUEEVENT(EQE,EQE->period);
}

void AnimateBoundedObject(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&param->DLE;
   register struct GraphObject *Obj;

   CyclicBoundedObject(&param->CAnim,DLE,param);

   
   ENQUEUEEVENT(EQE,EQE->period);
}

void StartBackGroundObject(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   DLE->NewX=ptr->x; DLE->NewY=ptr->y;
   
   DLE->NewClass=DLE->OldClass=CLS_none;
   CAnim=&Eye->CAnim;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=ptr->Delay;		/* Suit image */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateBackGroundObject,Eye,SCROLLTICKS,"Animate Eye",
                    ActiveEyePtr&3);
}

void StartBackGroundObjectB(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   DLE->NewX=ptr->x; DLE->NewY=ptr->y;
   
   DLE->NewClass=DLE->OldClass=CLS_none;
   CAnim=&Eye->CAnim;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=ptr->Delay;		/* Suit image */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateBackGroundObjectB,Eye,SCROLLTICKS,"Animate EyeB",
                    ActiveEyePtr&3);
}

void StartHexGun(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   DLE->NewX=ptr->x; DLE->NewY=ptr->y;
   
   DLE->NewClass=DLE->OldClass=CLS_none;
   CAnim=&Eye->CAnim;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=ptr->Delay;		/* Suit image */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateHexGun,Eye,2,"Animate HexGun",
                    ActiveEyePtr&3);
}

void StartBoundedGroundObject(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   DLE->NewX=ptr->x; DLE->NewY=ptr->y;
   
   DLE->NewClass=DLE->OldClass=CLS_none;
   CAnim=&Eye->CAnim;
   CAnim->First=ptr->First;
   CAnim->Last=ptr->Last;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=ptr->Delay;		/* Suit image */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=ptr->First-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateBoundedGroundObject,Eye,SCROLLTICKS,"Animate Eye",
                    ActiveEyePtr&3);
}

void StartBoundedObject(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   Eye->x=ptr->x;
   Eye->y=ptr->y;

   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   DLE->NewX=ptr->x-RasInfo2.RxOffset; DLE->NewY=ptr->y-RasInfo2.RyOffset;
   
   DLE->NewClass=DLE->OldClass=CLS_none;
   CAnim=&Eye->CAnim;
   CAnim->First=ptr->First;
   CAnim->Last=ptr->Last;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=ptr->Delay;		/* Suit image */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=ptr->First-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateBoundedObject,Eye,SCROLLTICKS,"Animate Eye",
                    ActiveEyePtr&3);
}

void AnimateLavaBubble(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE=&param->DLE;
   struct GraphObject *Obj;

   if(DLE->flags&DLE_collision) {	/* He's dead */
      Obj=(struct GraphObject *)DLE->NewImage;
      StartRandomExplosion(DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY,40);
      if(!(CurrentLevel->flags&LB_NewLevel)) {
         CreateEvent(CleanUpEvent,NULL,200,"CleanUpS");
         DoBonusScore(BONUS_5000,DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY);
         StopCollisionCheckingOn(DLE);	/* Stop collisioning */
      }
      CurrentLevel->flags|=LB_NewLevel;
      ENQUEUEEVENT(EQE,2);
      return;
   }
      
   BCyclicAnimateBoundedGroundObject(&param->CAnim,DLE,param);

   DLE->NewX=param->x-RasInfo2.RxOffset;
   DLE->NewY=param->y-RasInfo2.RyOffset;

   if(param->CAnim.Delay==param->CAnim.MaxDelay&&
      param->CAnim.CurImage==param->CAnim.Image->Count-1) {
      Obj=(struct GraphObject *)DLE->NewImage;
      StartLavaMissile(DLE->NewX+Obj->HotX,
      			DLE->NewY+Obj->Height,
                        &Spare3Image);
   }

   ENQUEUEEVENT(EQE,EQE->period);
}

void StartLavaBubble(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   Eye->x=ptr->x; Eye->y=ptr->y;
   

   DLE->NewClass=DLE->OldClass=CLS_none;
   DLE->NewX=-100;

   DLE->flags=0;
   DoGroundCheckingOn(DLE);
   DLE->flags|=DLE_Bud;
   Eye->NumHits=60;

   CAnim=&Eye->CAnim;
   CAnim->First=ptr->First;
   CAnim->Last=ptr->Last;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=ptr->Delay;		/* Suit image */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=ptr->First-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateLavaBubble,Eye,SCROLLTICKS,"Animate LavaBubble",
                    ActiveEyePtr&3);
}

void StartBud(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   
   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   DLE->NewX=-100;
   
   DLE->flags=0;
   DoGroundCheckingOn(DLE);
   DLE->flags|=DLE_Bud;
   DLE->NewClass=DLE->OldClass=CLS_none;
   CAnim=&Eye->CAnim;
   Eye->x=ptr->x;
   Eye->y=ptr->y;
   Eye->NumHits=60;
   CAnim->First=ptr->First;
   CAnim->Last=ptr->Last;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=ptr->Delay;		/* Suit image */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=ptr->First-1;			/* Start at First Image */
   
   DoAfterAndRepeat(AnimateBud,Eye,2,"Animate Bud",
                    ActiveEyePtr&3);
}

void AnimateLavaEye(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   register struct GraphObject *Obj;
   
   DLE=&param->DLE;
   CAnim=&param->CAnim;
   
   CAnim->CurImage=8;

   if(DLE->flags&DLE_collision||CurrentLevel->flags&LB_NewLevel) {
      Obj=(struct GraphObject *)DLE->NewImage;
      param->x+=Obj->HotX; param->y+=Obj->HotY;
      Obj=(struct GraphObject *)CAnim->Image->Frames[0];
      BlitBackGroundBob(Obj,param->x-Obj->HotX,param->y-Obj->HotY);
      MakeExplosion(NULL,NULL,DLE->NewX+Obj->HotX,DLE->NewY+Obj->HotY,0,0);
      StopCollisionCheckingOn(DLE);
      PURGEEQE(EQE);
      FREEEQE(EQE);
      return;
   }

   if(CAnim->First==8) {
      Obj=(struct GraphObject *)DLE->NewImage;
      DLE->NewX+=Obj->HotX; DLE->NewY+=Obj->HotY;
      StartEnemyMissilePrim2(DLE->NewX,DLE->NewY,
           AMISSILERATE,+0,-2,&CAnim->First);
      StartEnemyMissilePrim2(DLE->NewX,DLE->NewY,
           BMISSILERATE,+2,-2,&CAnim->First);
      StartEnemyMissilePrim2(DLE->NewX,DLE->NewY,
           AMISSILERATE,+2,+0,&CAnim->First);
      StartEnemyMissilePrim2(DLE->NewX,DLE->NewY,
           BMISSILERATE,+2,+2,&CAnim->First);
      StartEnemyMissilePrim2(DLE->NewX,DLE->NewY,
           AMISSILERATE,+0,+2,&CAnim->First);
      StartEnemyMissilePrim2(DLE->NewX,DLE->NewY,
           BMISSILERATE,-2,-2,&CAnim->First);
      StartEnemyMissilePrim2(DLE->NewX,DLE->NewY,
           AMISSILERATE,-2,+0,&CAnim->First);
      StartEnemyMissilePrim2(DLE->NewX,DLE->NewY,
           BMISSILERATE,-2,+2,&CAnim->First);
      DLE->NewX-=Obj->HotX; DLE->NewY-=Obj->HotY;
   }
   ENQUEUEEVENT(EQE,EQE->period);
}
      
void OpenLavaEye(param,EQE)
EyeDescriptor *param;
SCH_PEQE EQE;
{
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   register EyeDescriptor *Eye;
   struct GraphObject *Obj;

   Eye=param;
   DLE=&Eye->DLE;
   CAnim=&Eye->CAnim;
   
   if(OKToDoWave||AlienBulletsAvailable!=CurrentLevel->NumAlienBullets) {
      ENQUEUEEVENT(EQE,SCROLLTICKS);
      return;
   }

   Obj=(struct GraphObject *)DLE->NewImage;
   if(!--CAnim->Delay) {
      CAnim->Delay=CAnim->MaxDelay;
      if(++CAnim->CurImage==8) {
         EQE->function=AnimateLavaEye;
         EQE->period=2;
         CAnim->First=8;
         ENQUEUEEVENT(EQE,EQE->period);
         return;
      }
      if(DLE->NewClass!=CLS_none) {
         Eye->x+=Obj->HotX; Eye->y+=Obj->HotY;
      }
      DLE->NewImage=CAnim->Image->Frames[CAnim->CurImage];
      SetUpHitBox(&DLE->HitBox,DLE->NewImage);
      Obj=(struct GraphObject *)DLE->NewImage;
      DLE->NewClass=CLS_Bob;
      Eye->x-=Obj->HotX; Eye->y-=Obj->HotY;
      DLE->NewX=Eye->x-RasInfo2.RxOffset;
      DLE->NewY=Eye->y-RasInfo2.RyOffset;
      BlitBackGroundBob(DLE->NewImage,Eye->x,Eye->y);
   }
   ENQUEUEEVENT(EQE,EQE->period);
}
   
void StartLavaEye(ptr)
BackGroundObject *ptr;
{
   register EyeDescriptor *Eye;
   register DSP_PDLE DLE;
   register CyclicAnimation *CAnim;
   struct GraphObject *Obj;
   
   Eye=&ActiveEyes[ActiveEyePtr];
   ActiveEyePtr=(ActiveEyePtr+1)&(NUMEYES-1);
   
   Obj=(struct GraphObject *)ptr->Image->Frames[0];
   BlitBackGroundBob(Obj,ptr->x-Obj->HotX,ptr->y-Obj->HotY);
   
   DLE=&Eye->DLE;
   DLE->param=(char *)Eye;
   
   DLE->NewX=-100;
   
   DLE->NewClass=DLE->OldClass=CLS_none;
   Eye->x=ptr->x;
   Eye->y=ptr->y;
   Eye->NumHits=8;
   CAnim=&Eye->CAnim;

   CAnim->First=0;
   CAnim->Last=ptr->Image->Count-1;
   CAnim->Image=ptr->Image;
   CAnim->MaxDelay=ptr->Delay;		/* Suit image */
   CAnim->Delay=1;			/* Force Image load */
   CAnim->CurImage=-1;			/* Start at First Image */
   
   DLE->flags=0;
   DoGroundCheckingOn(DLE);
   DLE->flags|=DLE_LavaEye;

   DoAfterAndRepeat(OpenLavaEye,Eye,2,"Animate LavaEye",
                    ActiveEyePtr&3);
}

void CheckUpOnEyes(param,EQE)
char *param;
SCH_PEQE EQE;
{
   register BackGroundObject *ptr=&BackGroundObjectTable[NextDueEye];

   (*ptr->function)(ptr);
            
   if(--NextDueEye<0) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
   } else {
      EQE->period=RasInfo2.RyOffset-(ptr->y)-32;
      EQE->period*=SCROLLTICKS;
      ENQUEUEEVENT(EQE,EQE->period);
   }
}

void CheckUpOnHorizEyes(param,EQE)
char *param;
SCH_PEQE EQE;
{
   register BackGroundObject *ptr=&BackGroundObjectTable[NextDueEye++];

   if(ptr->x==-10000) {
      PURGEEQE(EQE);
      FREEEQE(EQE);
      return;
   }
   (*ptr->function)(ptr);
            
   EQE->period=ptr->x-(RasInfo2.RxOffset+320);
   EQE->period*=SCROLLTICKS;
   ENQUEUEEVENT(EQE,EQE->period);

}

void PrepareEyeListsForNewGame()
{
   BackGroundObject *i;
   WORD j;
   for(j=0;j<5;++j)
      if(i=ObjectsOnLevels[j]) 
         while(1) {
            if(i->x==-10000)break;
            if(i->x<0)i->x=-i->x;
            i++;
         }
}
      
void InitialiseEyes()
{
   WORD i;
   WORD x,y;
   BackGroundObject *ptr;
   
   ActiveEyePtr=0;
   
   if(!ObjectsOnLevels[CurrentLevel->LevelNum])return;

   CheckUpFunction=CheckUpTable[CurrentLevel->LevelNum];

   BackGroundObjectTable=ObjectsOnLevels[CurrentLevel->LevelNum];

   i=0;
   if(CurrentLevel->flags&LB_ScrollVert) {
      while(BackGroundObjectTable[i].x!=-10000)
         ++i;
      --i;
      while(1) {
         if(i<0)return;
         y=BackGroundObjectTable[i].y;
         if(y>=RasInfo2.RyOffset-32&&y<RasInfo2.RyOffset+VIEW_HEIGHT) {
            ptr=BackGroundObjectTable+i;
            (*ptr->function)(ptr);
         } else
            if(y<RasInfo2.RyOffset) {
               NextDueEye=i;
               i=RasInfo2.RyOffset-y-32;
               i*=SCROLLTICKS;
               CreateEvent(CheckUpFunction,NULL,i,"Check on eyes");
               return;
            }
         --i;
      }
   } else {
      i=0;
      while(1) {
         if(BackGroundObjectTable[i].x==-10000)return;
         x=BackGroundObjectTable[i].x;
         if(x>=RasInfo2.RxOffset&&x<32+RasInfo2.RxOffset+VIEW_WIDTH) {
            ptr=BackGroundObjectTable+i;
            (*ptr->function)(ptr);
         } else
            if(x>RasInfo2.RxOffset+320) {
               NextDueEye=i;
               i=x-(RasInfo2.RxOffset+320)-32;
               i*=SCROLLTICKS;
               CreateEvent(CheckUpFunction,NULL,i,"Check on eyes");
               return;
            }
         ++i;
      }
   }
}

void LoadObjectsForLevel()
{
   ObjectDescriptor *ObjectPtr;
   ObjectPtr=ObjectListForLevel[CurrentLevel->LevelNum];
   if(!ObjectPtr)return;
   
   while(ObjectPtr->name) {
      LoadImages(ObjectPtr->name,ObjectPtr->Image,NULL);
      ++ObjectPtr;
   }
}

void UnLoadObjectsForLevel()
{
   ObjectDescriptor *ObjectPtr;
   if(LastLevelLoaded==-1)return;
   ObjectPtr=ObjectListForLevel[LastLevelLoaded];
   if(!ObjectPtr)return;
   
   while(ObjectPtr->name)
      FreeSpriteImage(ObjectPtr++->Image);
}

