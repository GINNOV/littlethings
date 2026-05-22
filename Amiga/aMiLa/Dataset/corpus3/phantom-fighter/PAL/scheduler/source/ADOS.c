#include <exec/types.h>
#include <graphics/gfx.h>
#include <graphics/view.h>
#include <hardware/custom.h>
#include <graphics/gfxmacros.h>
#include "iff.h"

#include <exec/memory.h>

extern void *AllocMem();

extern struct SpriteImage Stuff1Image;

extern UWORD LunarCMap[16];

extern UWORD MainCopper[];
extern UWORD LoadCopper[];
extern UWORD TitleCopper[];

extern struct ViewPort VPort;
extern struct ViewPort LVPort;
extern struct ViewPort VP_Top;
extern struct ViewPort VP_bottom;

#asm
		include	"header:custom.i"
		xdef	_BltClear

BltClearRegs	reg	d1-d7/a1-a6
                
_BltClear:	move.l	4(sp),a0
		move.l	8(sp),d0
		lsr.l	#1,d0

                subi.w	#1,d0

10$:		clr.w	(a0)+
		dbf	d0,10$
                rts

		xdef	_WaitTOF
                
_WaitTOF:
		move.w	_custom+vposr,d0
		andi.l	#1,d0
                
                move.w	_custom+vhposr,d1
                lsr.w	#4,d1
                lsr.w	#4,d1
                andi.l	#$ff,d1
                lsl.w	#5,d0
                lsl.w	#4,d0
                or.w	d1,d0
                
		cmpi.w	#2,d0
                bcc	_WaitTOF
                rts                
#endasm

void SYS_MakeVPort(VPort,Copper)
struct ViewPort *VPort;
UWORD *Copper;
{
   struct BitMap *bm,*oldbm;
   struct RasInfo *Ras;
   ULONG plane;
   int i;
   
   Ras=VPort->RasInfo;
   bm=Ras->BitMap;
   if(!(VPort->Modes&DUALPF))
      for(i=0;i<bm->Depth;++i) {
         plane=(ULONG)bm->Planes[i];
         if(plane) {
            plane+=bm->BytesPerRow*Ras->RyOffset;
            plane+=(Ras->RxOffset&0xfff0)>>3;
            Copper[i*4]=plane>>16;
            Copper[i*4+2]=plane&0xffff;
         }
      }
   else {
      for(i=0;i<bm->Depth;++i) {
         plane=(ULONG)bm->Planes[i];
         if(Ras->Next->RxOffset&1) 
            plane-=2;
         plane+=bm->BytesPerRow*Ras->RyOffset;
         plane+=(Ras->RxOffset&0xfff0)>>3;
         Copper[i*8]=plane>>16;
         Copper[i*8+2]=plane&0xffff;
      }
      Ras=Ras->Next;
      oldbm=bm;
      bm=Ras->BitMap;
      for(i=0;i<bm->Depth;++i) {
         plane=(ULONG)bm->Planes[i];
         plane+=bm->BytesPerRow*Ras->RyOffset;
         plane+=(Ras->RxOffset&0xfff0)>>3;
         Copper[i*8+4]=plane>>16;
         Copper[i*8+6]=plane&0xffff;
      }
      if(Ras->RxOffset&15)
         *(Copper-6)=((Ras->RxOffset&15)^15)<<4;
      else
         *(Copper-6)=0;
      if(Ras->RxOffset&1) {
         *(Copper-10)=0x30;			/* Data Fetch */
         *(Copper-4)=oldbm->BytesPerRow-42;	/* Even Modulo */
         *(Copper-2)=bm->BytesPerRow-42;	/* Odd modulo */
      } else {
         *(Copper-10)=0x38;			/* Data Fetch */
         *(Copper-4)=oldbm->BytesPerRow-40;	/* Even Modulo */
         *(Copper-2)=bm->BytesPerRow-40;	/* Odd modulo */
      }
   }   
}

extern struct RasInfo RasInfo2;

void SYS_ScrollHoriz(Copper)
UWORD *Copper;
{
struct BitMap *bm;
int i;
ULONG plane;
   bm=RasInfo2.BitMap;
   for(i=0;i<bm->Depth;++i) {
      plane=(ULONG)bm->Planes[i];
      plane+=(RasInfo2.RxOffset&0xfff0)>>3;
      Copper[i*8+4]=plane>>16;
      Copper[i*8+6]=plane&0xffff;
   }
   *(Copper-6)=((RasInfo2.RxOffset&15)^15)<<4;
}   

void SYS_SetRGB4(VP,Color,R,G,B)
struct ViewPort *VP;
int Color;
int R,G,B;
{
   UWORD RGB;
   ULONG Offset;
   
   Offset=(Color<<1)|1;
   RGB=(R<<8)|(G<<4)|B;
   if(VP==&VPort)
      if(VP->Modes&DUALPF)
         MainCopper[33*2+Offset]=RGB;
      else
         if(Color<=15)
            TitleCopper[2+Offset]=RGB;

   if (VP==&VP_bottom)
      MainCopper[75*2+Offset]=RGB;

   if (VP==&LVPort&&Color<=15)
      LoadCopper[2+Offset]=RGB;

}

void SYS_LoadRGB4(VPort,Table,NumColors)
struct ViewPort *VPort;
UWORD *Table;
int NumColors;
{
   int i;
   for(i=0;i<NumColors;++i)
      SYS_SetRGB4(VPort,i,Table[i]>>8,(Table[i]>>4)&0xf,Table[i]&0xf);
}

extern struct BitMap *bm;

void ClearBM()
{
   int i;
   UWORD TempCMap[8];
   for(i=0;i<8;++i) TempCMap[i]=LunarCMap[0];

   SYS_LoadRGB4(&VPort,TempCMap,8);
   ClearMainSprites();
   for(i=0;i<1<<bm->Depth;++i)
      if(bm->Planes[i])
         BltClear(bm->Planes[i],bm->BytesPerRow*bm->Rows);
   SYS_LoadRGB4(&VPort,LunarCMap,8);
}

ULONG AllocZero(num)
ULONG num;
{
   ULONG temp;
   if(num&1)++num;
   temp=(ULONG)AllocMem(num);
   BltClear(temp,num);
   return temp;
}
   
void *AllocRaster(w,h)
WORD w,h;
{
   return (void *)AllocMem(RASSIZE(w,h),MEMF_CHIP);
}

void FreeRaster(p,w,h)
char *p;
WORD w,h;
{
   FreeMem(p,RASSIZE(w,h));
}

void InitBitMap(bm,d,w,h)
struct BitMap *bm;
WORD d,w,h;
{
   int i;
   bm->Depth=d;
   bm->BytesPerRow=RASSIZE(w,1);
   bm->Flags=0;
   bm->Rows=h;
   for(i=0;i<8;++i) bm->Planes[i]=0L;
}

WORD TextX,TextY;
WORD TextColor;

void Move(x,y)
WORD x,y;
{
   TextX=x>>3;
   TextY=y-7;
}

void SetAPen(Color)
WORD Color;
{
   TextColor=Color;
}

void SetDrMd()
{
}

void SetBPen()
{
}

void Text(bm,string,NumC)
struct BitMap *bm;
char *string;
WORD NumC;
{
   register WORD row;
   register UBYTE *ptr1;
   register UBYTE *ptr2;
   WORD plane;
   ULONG Offset;
   UBYTE ch;
   WORD Count;
   struct GraphObject *DigitImage=(struct GraphObject *)Stuff1Image.Frames[1];
   
   for(Count=0;Count<NumC;++Count) {
      Offset=bm->BytesPerRow*TextY+TextX++;
   
      ch=*string++;
     
      if(ch>='0'&&ch<='9')
         ch-='0';
      else
         if(ch>='A'&&ch<='Z')
            ch=ch-'A'+10;
         else
            if(ch>='a'&&ch<='z')
               ch=ch-'a'+10;
            else
               ch=127;

      for(plane=0;plane<1<<bm->Depth;++plane)
         if(bm->Planes[plane]) {
            ptr1=(UBYTE *)bm->Planes[plane]+Offset;
            ptr2=(UBYTE *)DigitImage->Image+ch;
            if(TextColor&(1<<plane)&&ch!=127)
               for(row=0;row<DigitImage->Height;++row) {
                     *ptr1=*ptr2;
                     ptr1+=bm->BytesPerRow;
                     ptr2+=RASSIZE(DigitImage->Width,1);
               }
            else
               for(row=0;row<DigitImage->Height;++row) {
                     *ptr1=0;
                     ptr1+=bm->BytesPerRow;
               }
         }
•  }
}               
                  
void fread(Where,BlkSize,BlkNo,fp)
ULONG Where,BlkSize,BlkNo,fp;
{
   Mefread(Where,BlkNo*BlkSize);
}

#asm
		XDEF	_AllocMem,_FreeMem,_AvailMem
                XDEF	_fopen,_fclose,_Mefread,_fseek,_kprintf
                XREF	_ShowMemList
                
_AllocMem	move.l	4(sp),d0
		movem.l	d1-d7/a0-a6,-(sp)
                moveq	#0,d1
                trap	#0
		movem.l	(sp)+,d1-d7/a0-a6
                cmpi.l	#-1,d0
                bne.s	10$
                move.l	#1,-(sp)
                bsr	_ShowMemList
10$             rts
_FreeMem	move.l	a0,-(sp)
		lea.l	4(sp),a0
		move.l	8(a0),d0
		movea.l	4(a0),a0
		movem.l	d1-d7/a1-a6,-(sp)
                moveq	#1,d1
                trap	#0
		movem.l	(sp)+,d1-d7/a1-a6
                movea.l	(sp)+,a0
                rts
_AvailMem	movem.l	d1-d7/a1-a6,-(sp)
                moveq	#2,d1
                trap	#0
		movem.l	(sp)+,d1-d7/a1-a6
                rts
_fopen		movea.l	4(sp),a0
		movem.l	d1-d7/a1-a6,-(sp)
            	moveq	#3,d1
                trap	#0
		movem.l	(sp)+,d1-d7/a1-a6
                rts
_fclose		movem.l	d1-d7/a1-a6,-(sp)
                moveq	#4,d1
                trap	#0
		movem.l	(sp)+,d1-d7/a1-a6
                rts
_Mefread	movea.l	4(sp),a0
		move.l	8(sp),d0
		movem.l	d1-d7/a1-a6,-(sp)
                moveq	#5,d1
                trap	#0
		movem.l	(sp)+,d1-d7/a1-a6
                rts
_fseek		move.l	8(sp),d0
		movem.l	d1-d7/a1-a6,-(sp)
                moveq	#6,d1
                trap	#0
		movem.l	(sp)+,d1-d7/a1-a6
                rts
_kprintf	movea.l	4(sp),a0
		move.l	a0,d0
		movem.l	d1-d7/a1-a6,-(sp)
                moveq	#7,d1
                trap	#0
		movem.l	(sp)+,d1-d7/a1-a6
                rts


#endasm

   extern ULONG *GetMemBase();
   ShowMemList(Flag)
   ULONG Flag;
   {
      ULONG *Ptr;
      Ptr=GetMemBase();
      DPRINTF("AllocMem failed\n");
      DPRINTF("Free Memory List\n");
      while(Ptr){
         DPRINTF("   At $%08lx   %8ld bytes\n",Ptr,Ptr[2]-12);
         Ptr=(ULONG *)Ptr[0];
      }
      while(Flag) { *(UWORD *)0xdff180=0xfff; *(UWORD *)0xdff180=333;};
   }

#   asm
		XDEF	_GetMemBase
_GetMemBase	moveq	#8,d1
		trap	#0
                rts

		XDEF	_WaitBlit
_WaitBlit:	lea.l	_custom,a0
10$:		btst	#BBUSYBIT-8,dmaconr(a0)
                bne.s	10$
                rts
#   endasm


