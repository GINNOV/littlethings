#include "Animation.h"
#include "displist.h"
#include "iff.h"
#include "eyes.h"
#include <graphics/view.h>

extern struct SpriteImage FireBall_16;
extern struct RasInfo RasInfo2;

void CyclicAnimate(Anim,DLE)
CyclicAnimation *Anim;
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   register CyclicAnimation *C=Anim;
   register struct GraphObject *Obj;

   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(++C->CurImage>=C->Image->Count)
         C->CurImage=0;
      D->NewImage=C->Image->Frames[C->CurImage];
      Obj=(struct GraphObject *)D->NewImage;
      SetUpHitBox(&D->HitBox,D->NewImage);
      D->NewClass=CLS_Bob;
      if(DLE->OldClass!=CLS_none) {
         D->NewX-=Obj->HotX; D->NewY-=Obj->HotY;
         Obj=(struct GraphObject *)D->OldImage;
         D->NewX+=Obj->HotX; D->NewY+=Obj->HotY;
      }
   }

   DisplayBob(D);
}

int AnimateBackGroundObjectForward(Anim,DLE)
CyclicAnimation *Anim;
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   register CyclicAnimation *C=Anim;
   register struct GraphObject *Obj;
   int result=0;

   CopyDownDLE(D);
   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(++C->CurImage>=C->Image->Count) {
         C->CurImage=C->Image->Count-1;
         result=1;
      }
      D->NewImage=C->Image->Frames[C->CurImage];
      Obj=(struct GraphObject *)D->NewImage;
      SetUpHitBox(&D->HitBox,Obj);
      D->NewClass=CLS_Bob;
      D->NewX-=Obj->HotX; D->NewY-=Obj->HotY;
      if(DLE->OldClass!=CLS_none) {
         Obj=(struct GraphObject *)D->OldImage;
         D->NewX+=Obj->HotX; D->NewY+=Obj->HotY;
      }
   }
   BlitBackGroundBob(D->NewImage,D->NewX,D->NewY);
   return result;
}

void CyclicAnimateBackGroundObject(Anim,DLE)
CyclicAnimation *Anim;
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   register CyclicAnimation *C=Anim;
   register struct GraphObject *Obj;

   CopyDownDLE(D);
   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(++C->CurImage>=C->Image->Count)
         C->CurImage=0;
      D->NewImage=C->Image->Frames[C->CurImage];
      Obj=(struct GraphObject *)D->NewImage;
      SetUpHitBox(&D->HitBox,Obj);
      D->NewClass=CLS_Bob;
      D->NewX-=Obj->HotX; D->NewY-=Obj->HotY;
      if(DLE->OldClass!=CLS_none) {
         Obj=(struct GraphObject *)D->OldImage;
         D->NewX+=Obj->HotX; D->NewY+=Obj->HotY;
      }
   }
   BlitBackGroundBob(D->NewImage,D->NewX,D->NewY);
}

int AnimateBackGroundObjectBackwards(Anim,DLE)
CyclicAnimation *Anim;
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   register CyclicAnimation *C=Anim;
   register struct GraphObject *Obj;
   int result=0;

   CopyDownDLE(D);
   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(--C->CurImage<0) {
         C->CurImage=0;
         result=1;
      }
      D->NewImage=C->Image->Frames[C->CurImage];
      Obj=(struct GraphObject *)D->NewImage;
      SetUpHitBox(&D->HitBox,Obj);
      D->NewClass=CLS_Bob;
      D->NewX-=Obj->HotX; D->NewY-=Obj->HotY;
      if(DLE->OldClass!=CLS_none) {
         Obj=(struct GraphObject *)D->OldImage;
         D->NewX+=Obj->HotX; D->NewY+=Obj->HotY;
      }
   }
   BlitBackGroundBob(D->NewImage,D->NewX,D->NewY);
   return result;
}

void CyclicAnimateBoundedGroundObject(Anim,DLE)
CyclicAnimation *Anim;
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   register CyclicAnimation *C=Anim;
   register struct GraphObject *Obj;

   CopyDownDLE(D);
   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(++C->CurImage>C->Last)
         C->CurImage=C->First;
      D->NewImage=C->Image->Frames[C->CurImage];
      SetUpHitBox(&D->HitBox,D->NewImage);
      Obj=(struct GraphObject *)D->NewImage;
      D->NewClass=CLS_Bob;
      D->NewX-=Obj->HotX; D->NewY-=Obj->HotY;
      if(DLE->OldClass!=CLS_none) {
         Obj=(struct GraphObject *)D->OldImage;
         D->NewX+=Obj->HotX; D->NewY+=Obj->HotY;
      }
   }
   BlitBackGroundBob(D->NewImage,D->NewX,D->NewY);
}

void CyclicBoundedObject(Anim,DLE,Eye)
CyclicAnimation *Anim;
DSP_PDLE DLE;
EyeDescriptor *Eye;
{
   register DSP_PDLE D=DLE;
   register CyclicAnimation *C=Anim;
   register struct GraphObject *Obj;

   CopyDownDLE(D);
   Obj=(struct GraphObject *)D->NewImage;
   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(++C->CurImage>C->Last)
         C->CurImage=C->First;
      D->NewImage=C->Image->Frames[C->CurImage];
      SetUpHitBox(&D->HitBox,D->NewImage);
      Obj=(struct GraphObject *)D->NewImage;
      D->NewClass=CLS_Bob;
   }
   D->NewX=Eye->x-RasInfo2.RxOffset;
   D->NewY=Eye->y-RasInfo2.RyOffset;
   D->NewX-=Obj->HotX; D->NewY-=Obj->HotY;

   DisplayBob(D);
}

void CyclicAnimateBoundedObject(Anim,DLE)
CyclicAnimation *Anim;
DSP_PDLE DLE;
{
   register DSP_PDLE D=DLE;
   register CyclicAnimation *C=Anim;
   register struct GraphObject *Obj;

   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(++C->CurImage>C->Last)
         C->CurImage=C->First;
      D->NewImage=C->Image->Frames[C->CurImage];
      SetUpHitBox(&D->HitBox,D->NewImage);
   }
   Obj=(struct GraphObject *)D->NewImage;
   D->NewClass=CLS_Bob;
   D->NewX-=Obj->HotX; D->NewY-=Obj->HotY;
   DisplayBob(D);
}

void BCyclicAnimateBoundedGroundObject(Anim,DLE,Eye)
CyclicAnimation *Anim;
DSP_PDLE DLE;
EyeDescriptor *Eye;
{
   register DSP_PDLE D=DLE;
   register CyclicAnimation *C=Anim;
   register struct GraphObject *Obj;

   CopyDownDLE(D);
   if(!--C->Delay) {
      C->Delay=C->MaxDelay;
      if(++C->CurImage>C->Last)
         C->CurImage=C->First;
      D->NewImage=C->Image->Frames[C->CurImage];
      Obj=(struct GraphObject *)D->NewImage;
      SetUpHitBox(&D->HitBox,Obj);
      D->NewClass=CLS_Bob;
      Eye->x-=Obj->HotX; Eye->y-=Obj->HotY;
      if(DLE->OldClass!=CLS_none) {
         Obj=(struct GraphObject *)D->OldImage;
         Eye->x+=Obj->HotX; Eye->y+=Obj->HotY;
      }
   }
   BlitBackGroundBob(D->NewImage,Eye->x,Eye->y);
}

void MoveOnPath(param,D)
PathDescriptor *param;
DSP_PDLE D;
{
   register PathDescriptor *Path=param;
   register DSP_PDLE DLE=D;
   register ANM_PELEM ANM=param->CurAnim;

   if(!ANM) {
      ANM=Path->PathTable;
      DLE->NewX=ANM->Xoffset;
      DLE->NewY=(ANM++)->Yoffset;
      Path->Count=ANM->Count;
   }
   if(--Path->Count) {
      DLE->NewX+=ANM->Xoffset;
      DLE->NewY+=ANM->Yoffset;
   } else
      if((++ANM)->Count)
         Path->Count=ANM->Count;
      else
         ANM=NULL;
   
   Path->CurAnim=ANM;
}

void MoveAlongPath(param,D)
PathDescriptor *param;
DSP_PDLE D;
{
   register PathDescriptor *Path=param;
   register DSP_PDLE DLE=D;
   register ANM_PELEM ANM=param->CurAnim;
   struct GraphObject *Obj;

   CopyDownDLE(DLE);
   Obj=(struct GraphObject *)DLE->OldImage;

   if(!ANM) {
      ANM=Path->PathTable;

      DLE->NewX=ANM->Xoffset;
      DLE->NewY=(ANM++)->Yoffset;
      Path->Count=ANM->Count;
   } else {
      DLE->NewX+=Obj->HotX;
      DLE->NewY+=Obj->HotY;
   }
   DLE->NewImage=FireBall_16.Frames[ANM->FrameNo];
   DLE->NewClass=CLS_Bob;
   Obj=(struct GraphObject *)DLE->NewImage;
   DLE->NewX+=ANM->Xoffset-Obj->HotX;
   DLE->NewY+=ANM->Yoffset-Obj->HotY;
   if(!(--Path->Count))
      if((++ANM)->Count)
         Path->Count=ANM->Count;
      else
         ANM=NULL;
   
   DisplayBob(DLE);
   Path->CurAnim=ANM;
}
