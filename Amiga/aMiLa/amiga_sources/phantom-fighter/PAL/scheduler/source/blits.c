
/*---- These are the include files needed for these routines ------*/
#include <exec/types.h>
#include <clib/macros.h>
#include <hardware/custom.h>
#include <hardware/blit.h>
#include <graphics/gfx.h>

#include "header:view.h"
#include "header:iff.h"
#include "header:blits.h"

extern struct BitMap *view_bm,*bm2;
extern struct SpriteImage ScreenMask;

#ifdef qwerty
void XORBlit(Object,x,y)
struct GraphObject *Object;
WORD x,y;
{
   UWORD DstMod;
   ULONG DstOffset;
   UWORD Shift;
   ULONG ImageSize;
   register WORD loop;
   register ULONG Temp;
   register char **Planes;
   register BLT_PObject t;
   ULONG Image;
      
   /* Clip Bob wholly */
   
   if(x<=-32||
      y<=-32||
      x+Object->Width>=VIEW_WIDTH+32||
      y+Object->Height>=VIEW_HEIGHT+32)
      return;

   /* Calculate moduloes first */
   
   x+=32;
   y+=32;

   Temp=((Object->Width+15)>>3)&~1;		/* Get width in bytes */
   DstMod=view_bm->BytesPerRow-(Temp+2);	/* 44 bytes across,
	   					   backup 2 for shift */
   ImageSize=Temp*Object->Height;		/* Get Size of a bob plane */
   DstOffset=y*view_bm->BytesPerRow+(x>>3);	/* Get Plane offset of blit */
   Shift=x&15;
   
   t=&BLT_ObjectList[BLTListWrite&127];
   t->bltafwm=0xffff;
   t->bltalwm=0;

   t->bltcon0=SRCA|SRCC|DEST|0x5a|(Shift<<12);
   t->bltcon1=0;
   t->bltamod=-2;
   t->bltdmod=t->bltcmod=DstMod;
   t->bltafwm=0xffff;
   t->bltalwm=0;
   /* Make blit one word wider coz' of shift */

   t->bltsize=(Object->Height<<6)+(Temp>>1)+1;

   Image=(ULONG)Object->Image;
   Planes=(char **)&view_bm->Planes[0];

   t->Ptr[0].bltapt=(char *)Image;
   t->Ptr[0].bltdpt=t->Ptr[0].bltcpt=(char *)*Planes+++DstOffset;

   t->Ptr[1].bltapt=(char *)(Image+=ImageSize);
   t->Ptr[1].bltdpt=t->Ptr[1].bltcpt=(char *)*Planes+++DstOffset;

   t->Ptr[2].bltapt=(char *)(Image+=ImageSize);
   t->Ptr[2].bltdpt=t->Ptr[2].bltcpt=(char *)*Planes+++DstOffset;

   while(!(((BLTListWrite+2)-BLTListRead)&127));
   ++BLTListWrite;
}

void BlitBackGroundBob(Object,x,y)
struct GraphObject *Object;
WORD x,y;
{
   UWORD DstMod;
   ULONG DstOffset;
   UWORD Shift;
   ULONG ImageSize;
   register ULONG Mask;
   register ULONG Temp;
   register char **Planes;
   register BLT_PObject t;
   ULONG Image;
      
   /* Clip Bob wholly */
   
   /* Calculate moduloes first */
   
   Temp=((Object->Width+15)>>3)&~1;		/* Get width in bytes */
   DstMod=bm2->BytesPerRow-(Temp+2);	/* nn bytes across,
	   					   backup 2 for shift */
   ImageSize=Temp*Object->Height;		/* Get Size of a bob plane */
   DstOffset=y*bm2->BytesPerRow+(x>>3);	/* Get Plane offset of blit */
   Shift=x&15;
   
   t=&BLT_ObjectList[BLTListWrite&127];
   t->bltafwm=0xffff;
   t->bltalwm=0;

   t->bltcon0=SRCA|SRCB|SRCC|DEST|0xca|(Shift<<12);
   t->bltcon1=Shift<<12;
   t->bltamod=t->bltbmod=-2;
   t->bltdmod=t->bltcmod=DstMod;
   t->bltafwm=0xffff;
   t->bltalwm=0;
   /* Make blit one word wider coz' of shift */

   t->bltsize=(Object->Height<<6)+(Temp>>1)+1;

   Image=(ULONG)Object->Image;
   Mask=(ULONG)Object->Image+ImageSize*3;
   Planes=(char **)&bm2->Planes[0];

   t->Ptr[0].bltbpt=(char *)Image;
   t->Ptr[0].bltapt=(char *)Mask;
   t->Ptr[0].bltdpt=t->Ptr[0].bltcpt=(char *)*Planes+++DstOffset;

   t->Ptr[1].bltbpt=(char *)(Image+=ImageSize);
   t->Ptr[1].bltapt=(char *)Mask;
   t->Ptr[1].bltdpt=t->Ptr[1].bltcpt=(char *)*Planes+++DstOffset;

   t->Ptr[2].bltbpt=(char *)(Image+=ImageSize);
   t->Ptr[2].bltapt=(char *)Mask;
   t->Ptr[2].bltdpt=t->Ptr[2].bltcpt=(char *)*Planes+++DstOffset;

   while(!(((BLTListWrite+2)-BLTListRead)&127));
   ++BLTListWrite;
}

void XORBlitWithMask(Obj,x,y,offset)
struct GraphObject *Obj;
WORD x,y,offset;
{
   UWORD DstMod;
   ULONG DstOffset;
   ULONG MaskOffset;
   UWORD Shift;
   ULONG ImageSize;
   register struct GraphObject *Object=Obj;
   register WORD loop;
   register ULONG Temp;
   register char **Planes;
   register BLT_PObject t;
   struct BitMap *bm_mask=(struct BitMap *)ScreenMask.Frames[0];
   static BLT_Object BLT;
   ULONG Image;
      
   /* Clip Bob wholly */
   
   if(!(CurrentLevel->flags&LB_ScreenMask)) {
      XORBlit(Object,x,y);
      return;
   }


   /* Calculate moduloes first */
   
   x+=32;
   y+=32;
   if(x<0||x+Object->Width>VIEW_WIDTH+63)return;
   if(y<0||y+Object->Height>VIEW_HEIGHT+63)return;

   Temp=((Object->Width+15)>>3)&~1;		/* Get width in bytes */
   BLT.bltbmod=bm2->BytesPerRow-(Temp+2);
   DstMod=view_bm->BytesPerRow-(Temp+2);	/* 44 bytes across,
	   					   backup 2 for shift */
   ImageSize=Temp*Object->Height;		/* Get Size of a bob plane */
   DstOffset=y*view_bm->BytesPerRow+(x>>3);	/* Get Plane offset of blit */

   
   if(CurrentLevel->flags&LB_ScrollHoriz)
      MaskOffset=y*view_bm->BytesPerRow+(offset>>3);
   else
      MaskOffset=offset*view_bm->BytesPerRow+(x>>3);

   Shift=x&15;
   
   BLT.bltafwm=0xffff;
   BLT.bltalwm=0;

   BLT.bltcon0=SRCA|SRCB|SRCC|DEST|0x12|(Shift<<12);
   BLT.bltcmod=DstMod;
   BLT.bltdmod=DstMod;
   
   BLT.Ptr.bltbpt=(char *)bm_mask->Planes[0]+MaskOffset;

   /* Make blit one word wider coz' of shift */
   BLT.bltsize=(Object->Height<<6)+(Temp>>1)+1;

   Image=(ULONG)Object->Image;
   Planes=(char **)&view_bm->Planes[0];

   for(loop=0;loop<VIEW_DEPTH;++loop) {
      t=&BLT_ObjectList[BLTListWrite&127];
      t->bltcon0=BLT.bltcon0;
      t->bltcon1=0;
      t->bltamod=-2;
      t->bltbmod=BLT.bltbmod;
      t->bltcmod=BLT.bltcmod;
      t->bltdmod=BLT.bltdmod;
      t->bltafwm=BLT.bltafwm;
      t->bltalwm=BLT.bltalwm;
      t->bltsize=BLT.bltsize;
      Temp=(ULONG)*Planes+++DstOffset;
      t->Ptr.bltbpt=BLT.Ptr.bltbpt;
      t->Ptr.bltcpt=(char *)Temp;
      t->Ptr.bltdpt=(char *)Temp;
      t->Ptr.bltapt=(char *)Image;
      Image+=ImageSize;
      while(!(((BLTListWrite+2)-BLTListRead)&127));
      ++BLTListWrite;
   }
}
#endif
#ifdef qwerrty
void SmallBlit(Obj,x,y)
struct GraphObject *Obj;
WORD x,y;
{
   register ULONG DstOffset;
   register char **Planes;
   register ULONG Image;
   register struct GraphObject *Object=Obj;
   register UWORD Shift;
      
   /* Clip Bob wholly */
   
   x+=32;
   y+=32;

   if(x<0||x+Object->Width>VIEW_WIDTH+63)return;
   if(y<0||y+Object->Height>VIEW_HEIGHT+63)return;

   DstOffset=y*view_bm->BytesPerRow+((x>>3)&~1);	/* Get Plane offset of blit */
   Image=(ULONG)Object->Image;
   Planes=(char **)&view_bm->Planes[0];
   Shift=x&15;
   SoftBlit(Image,(*Planes++)+DstOffset,view_bm->BytesPerRow,
   				Object->Height,Shift);
   Image+=Object->Height<<1;
   SoftBlit(Image,(*Planes++)+DstOffset,view_bm->BytesPerRow,
   				Object->Height,Shift);
   Image+=Object->Height<<1;
   SoftBlit(Image,*Planes+DstOffset,view_bm->BytesPerRow,
   				Object->Height,Shift);
}   



#endif
