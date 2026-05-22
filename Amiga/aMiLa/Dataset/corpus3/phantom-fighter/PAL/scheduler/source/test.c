#include <hardware/custom.h>
#include <exec/types.h>
#include <graphics/view.h>
#include <graphics/gfxmacros.h>

#include <exec/memory.h>
#include "iff.h"

/* Thrown to-gether in a hurry, so sorry about its layout */

   extern void main();
   _main()
   {
      ULONG i;
      i=0x1000;
#   asm
   		include	'header:custom.i'
		move.w	#$7fff,_custom+dmacon
		move.w	#SETBIT+DMAEN+DSKEN,_custom+dmacon
   		move.w	#$7fff,_custom+intena
                move.w	_custom+intreqr,d0
                ori.w	#$8000,d0
                move.w	d0,_custom+intreq
                andi.w	#$7fff,d0
                move.w	d0,_custom+intreq
                move.w	#$2000,SR
                move.w	#$7fff,_custom+intena
#   endasm
      main();
   }

#include <hardware/dmabits.h>

char DebugBuffer[128];

void DPRINTF(p1,p2,p3,p4,p5,p6,p7,p8,p9)
char *p1,*p2,*p3,*p4,*p5,*p6,*p7,*p8,*p9;
{
   sprintf(DebugBuffer,p1,p2,p3,p4,p5,p6,p7,p8,p9);
   kprintf(DebugBuffer);
}

extern struct BitMap *LBM;
extern struct BitMap *bm_bottom;

void dprintf(p1,p2,p3,p4,p5,p6,p7,p8,p9)
char *p1,*p2,*p3,*p4,*p5,*p6,*p7,*p8,*p9;
{
   sprintf(DebugBuffer,p1,p2,p3,p4,p5,p6,p7,p8,p9);
   kprintf(DebugBuffer);
}
   
extern void *AllocMem();
void *AllocRaster(w,h)
WORD w,h;
{
   return (void *)AllocMem(RASSIZE(w,h),MEMF_CHIP);
}

UWORD SPR_BlankSprite[]={0,0};

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

void SYS_UseCopper(Copper)
ULONG Copper;
{
   custom.cop1lc=(ULONG)Copper;
   custom.dmacon=BITSET|DMAF_COPPER|DMAF_BLITTER|DMAF_MASTER;
}

UWORD LessenColor(RGB,Factor)
UWORD RGB;
{
   UBYTE R,G,B;
   R=(RGB>>8);
   G=(RGB>>4)&15;
   B=RGB&15;
   R=(R*Factor)>>8;
   G=(G*Factor)>>8;
   B=(B*Factor)>>8;
   return (R<<8)+(G<<4)+B;
}

struct SpriteImage LoadingScreen;
UWORD BlankColors[32]={
   0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0
};

UWORD LoadingColors[32];

UWORD LoadCopper[]={
#ifdef SmallScreen
   0x1f01,0xfffe, /* $1f01 $fffe   00 WAIT ($0 ,$7f) ($1f,$7f)     */
#else
   0x2701,0xfffe, /* $2701 $fffe  WAIT ($0 ,$7f) ($27,$7f)     */
#endif

   0x180 ,0x443 , /* $180  $443    01 MOVE $180 ,$443   */
   0x182 ,0x820 , /* $182  $820    02 MOVE $182 ,$820   */
   0x184 ,0xd50 , /* $184  $d50    03 MOVE $184 ,$d50   */
   0x186 ,0xf95 , /* $186  $f95    04 MOVE $186 ,$f95   */
   0x188 ,0xfff , /* $188  $fff    05 MOVE $188 ,$fff   */
   0x18a ,0xfd7 , /* $18a  $fd7    06 MOVE $18a ,$fd7   */
   0x18c ,0x860 , /* $18c  $860    07 MOVE $18c ,$860   */
   0x18e ,0x302 , /* $18e  $302    08 MOVE $18e ,$302   */
   0x190 ,0x443 , /* $190  $443    09 MOVE $190 ,$443   */
   0x192 ,0x820 , /* $192  $820    10 MOVE $192 ,$820   */
   0x194 ,0xd50 , /* $194  $d50    11 MOVE $194 ,$d50   */
   0x196 ,0xf95 , /* $196  $f95    12 MOVE $196 ,$f95   */
   0x198 ,0xfff , /* $198  $fff    13 MOVE $198 ,$fff   */
   0x19a ,0xfd7 , /* $19a  $fd7    14 MOVE $19a ,$fd7   */
   0x19c ,0x860 , /* $19c  $860    15 MOVE $19c ,$860   */
   0x19e ,0x302 , /* $19e  $302    16 MOVE $19e ,$302   */

   0x8e  ,0x584 , /* $8e   $584    17 MOVE $8e  ,$584   */
   0x100 ,0x200 , /* $100  $200    18 MOVE $100 ,$200   */
   0x104 ,0x24  , /* $104  $24     19 MOVE $104 ,$24   */
   0x90  ,0x40c4, /* $90   $40c4   20 MOVE $90  ,$40c4   */
   0x92  ,0x38  , /* $92   $38     21 MOVE $92  ,$38   */
   0x94  ,0xd0  , /* $94   $d0     22 MOVE $94  ,$d0   */
   0x102 ,0x33  , /* $102  $33     23 MOVE $102 ,$33   */
   0x108 ,0x0   , /* $108  $0      24 MOVE $108 ,$0    */
   0x10a ,0x0   , /* $10a  $0      25 MOVE $10a ,$0    */
   0xe0  ,0x2   , /* $e0   $2      26 MOVE $e0  ,$2    */
   0xe2  ,0x2598, /* $e2   $2598   27 MOVE $e2  ,$2598   */
   0xe4  ,0x2   , /* $e4   $2      28 MOVE $e4  ,$2    */
   0xe6  ,0x44d8, /* $e6   $44d8   29 MOVE $e6  ,$44d8   */
   0xe8  ,0x2   , /* $e8   $2      30 MOVE $e8  ,$2    */
   0xea  ,0x6418, /* $ea   $6418   31 MOVE $ea  ,$6418   */
   0xec  ,0x2   , /* $ec   $2      32 MOVE $ec  ,$2    */
   0xee  ,0x6418, /* $ee   $6418   33 MOVE $ee  ,$6418   */
   
#ifdef SmallScreen
   0x2001,0xfffe, /* $2001 $fffe   34 WAIT ($0 ,$7f) ($20,$7f)     */
#else
   0x2901,0xfffe, /* $2901 $fffe  WAIT ($0 ,$7f) ($29,$7f)     */
#endif
   0x100 ,0x4200, /* $100  $4200   35 MOVE $100 ,$4200   */
/* 256 line screen */
#ifdef SmallScreen
   0xe801,0xfffe, /* $e801 $fffe   36 WAIT ($0 ,$7f) ($e8,$7f)     */
#else
   0xffdf,0xfffe, /* $ffdf $fffe  WAIT ($6f,$7f) ($ff,$7f)     */
   0x2901,0xfffe, /* $2901 $fffe  WAIT ($0 ,$7f) ($29,$7f)     */
#endif
   0x100 ,0x200 , /* $100  $200    37 MOVE $100 ,$200   */
   0xffff,0xfffe, /* $ffff $fffe   38 WAIT ($7f,$7f) ($ff,$7f)     */
};

                  
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
   for(i=0;i<bm->Depth;++i) {
      plane=(ULONG)bm->Planes[i];
      if(plane) {
         plane+=bm->BytesPerRow*Ras->RyOffset;
         plane+=(Ras->RxOffset&0xfff0)>>3;
         Copper[i*4]=plane>>16;
         Copper[i*4+2]=plane&0xffff;
      }
   }
}

struct ViewPort LVPort;
struct RasInfo LRS;
struct BitMap *LBM;

void SYS_SetRGB4(VP,Color,R,G,B)
struct ViewPort *VP;
int Color;
int R,G,B;
{
   UWORD RGB;
   ULONG Offset;
   
   Offset=(Color<<1)|1;
   RGB=(R<<8)|(G<<4)|B;

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

void FadeInLoadingScreen(Amount)
int Amount;
{
   UWORD TonedColors[16];
   int i,j;

   for(i=Amount;i<257;i+=3) {
      for(j=0;j<16;++j)
         TonedColors[j]=LessenColor(LoadingColors[j],i);
      SYS_LoadRGB4(&LVPort,TonedColors,16);
   }
   SYS_LoadRGB4(&LVPort,LoadingColors,16);
}

void WaitLeftButton()
{
   while(*((char *)0xbfe001)&64);
}

int MouseButtonUp()
{
   return(*((char *)0xbfe001)&64);
}

void main()
{
   int i;
   UWORD TimeOut;
   UWORD Temp;
   UWORD LVB_Delay1;
   LoadImages("Legals",&LoadingScreen,LoadingColors);
   
   LBM=(struct BitMap *)LoadingScreen.Frames[0];

   LVPort.Modes      = SPRITES;
   
   LVPort.RasInfo    = &LRS;
   
   LRS.BitMap   = LBM;
   LRS.RxOffset = 0L;
   LRS.RyOffset = 0L;
   
   LRS.Next     = NULL;
   
   /* Display the screens */
   SYS_MakeVPort(&LVPort,LoadCopper+26*2+1);
   
   SYS_LoadRGB4(&LVPort,BlankColors,16);
   
   SYS_UseCopper(LoadCopper);
   ON_DISPLAY
   FadeInLoadingScreen(0);
   LVB_Delay1=8;
   TimeOut=50*10;
   while(--TimeOut&&MouseButtonUp()) {
      WaitTOF();
      for(i=0;i<8;++i)
         custom.sprpt[i]=(APTR)SPR_BlankSprite;

      if(LVB_Delay1==1||LVB_Delay1==6) {
         Temp=LoadCopper[27];
         LoadCopper[27]=LoadCopper[25];
         LoadCopper[25]=LoadCopper[23];
         LoadCopper[23]=LoadCopper[21];
         LoadCopper[21]=LoadCopper[19];
         LoadCopper[19]=Temp;
      }
      if(!--LVB_Delay1)
         LVB_Delay1=8;
   }
      
   OFF_COPPER OFF_DISPLAY
   DeAllocBitMap(LBM);
}


