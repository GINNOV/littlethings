/**************************************************************************
*                                                                         *
*                   !! This IS a Nasty Copper Hack!!                      *
*                                                                         *
*  By stealing other peoples code and nutting out the AMIGA Manuals       *
*  I have put something of little value together.                         *
*                                                                         *
*  Oh well, next time those sprites might bite.                           *
*                                                                         *
*  Phil Robertson. At the end of '87                                      *
*                                                                         *
***************************************************************************
*                                                                         *
* 1994 - Minor changes made by Jason Petty to work with HCE.              *
*        Now uses the left mouse button to stop the demo.                 *
*        Changes marked, VANSOFT.                                         *
*                                                                         *
*        NOTE: When linking the object files to make 'Dark' an            *
*              undefined symbol (custom) message is displayed in          *
*              the CLI by the linker. This is because the external        *
*              reference to 'custom' is not present in the Amiga          *
*              library and is not resolved until runtime.                 *
*              This is normal!.                                           *
*        ALSO NOTE:                                                       *
*              This demo was originally made for an older version of the  *
*              Amiga's operating system (1.2-1.3) and may not work        *
*              correctly on newer versions.                               *
*                                                                         *
**************************************************************************/

/* Added  '#include's. VANSOFT. */
#include <intuition/intuition.h>
#include <exec/memory.h>
#include <graphics/sprite.h>
#include <graphics/copper.h>
#include <graphics/gfx.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>
#include <hardware/custom.h>
#include <hardware/cia.h>
#include <proto/all.h>
#include <stdio.h>

#define AllocChip(size) AllocMem((ULONG)size,(ULONG)(MEMF_CHIP|MEMF_CLEAR))
#define REV        0L
#define DEPTH      3
#define DEPTH2     3
#define WIDTH      640L
#define HEIGHT     400L
#define DWIDTH     320
#define DHEIGHT    200
#define MODES      SPRITES | DUALPF
#define ever       (;;)
#define MTCU       0x00CCL
#define joy        custom.joy1dat

UWORD Palette[16] = {
   0x0000,
   0x0444,
   0x0777,
   0x0BBB,
   0x0D26,
   0x0960,
   0x0750,
   0x0650,
   0x0000,
   0x0DA0,
   0x0FC0,
   0x0DA0,
   0x0B90,
   0x0B90,
   0x0DA0,
   0x0FC0
};


#define COLOURCOUNT 16L

/* Added 'custom' and 'ciaa'. VANSOFT. */
extern struct Custom far custom;
struct CIA *ciaa = (struct CIA *) CIAAPRA;

extern UWORD HeyData[];
extern UWORD WowData[];
extern UWORD DoorDownData[];
extern UWORD DoorUpData[];
extern UWORD GateData[];
extern UWORD AWData[];
extern UWORD ship_col[];
extern UWORD ship1_dat[];
extern UWORD ship2_dat[];
extern UWORD ship3_dat[];
extern UWORD ship4_dat[];
extern WORD   sound[];

struct SimpleSprite Sprites[5];

/* Added 'chip'. VANSOFT. */
chip struct Image AW = {
   0,0,
   243,53,
   3,
   AWData,
   0x0007,0x0000,
   NULL
};

struct Image Gate = {
   0,0,
   79,187,
   3,
   GateData,
   0x0003,0x0000,
   NULL
};

struct Image DoorDown = {
   0,0,
   26,34,
   3,
   DoorDownData,
   0x0007,0x0000,
   NULL
};

struct Image DoorUp = {
   0,0,
   26,34,
   3,
   DoorUpData,
   0x0007,0x0000,
   NULL
};

/* Changed IntuitionBase to long. VANSOFT. */
long IntuitionBase=NULL;
struct GfxBase *GfxBase=NULL;

/* Added. VANSOFT. */
BOOL JoyStick();

struct UCopList   *cl;
struct View   v,  *oldview;
struct ViewPort    vp;
struct ColorMap   *cm;
struct RasInfo     ri,ri2;
struct BitMap     *bm[2]={NULL,NULL};
struct RastPort    rp, rp2;

WORD Wrp = 0;
long  WX = 370; HX = 420;
WORD X = 2,Y = 2;
long Frq = 700;
long DY1 = 22, DY2 = 141, DY3 = 22, DY4 = 141;
BOOL SFlag = FALSE;


main()

{
   openstuff ();
   makescreen ();
   DrawObjects();
   SetSprites();
   SetColour();
   SoundOn();
   for ever {
      MoveSprites();
      ShipSprite();
      MakeVPort (&v, &vp);
      MrgCop(&v);
      LoadView (&v);
      if (JoyStick()) {
          break;
          }
   }
bye:
   closeeverything ();
}


openstuff ()
{
   long err;

   if (!(IntuitionBase = (long)OpenLibrary("intuition.library",REV)))
      die ("What the F...???!!!\n");

   if (!(GfxBase = (struct GfxBase *)OpenLibrary ("graphics.library", REV)))
      die ("Art shop closed.\n");

   if (!(bm[0] = AllocChip(sizeof(struct BitMap))))
      die ("Can't allocate BitMap 0.\n");

   if (!(bm[1] = AllocChip(sizeof(struct BitMap))))
      die ("Can't allocate BitMap 1.\n");
}

makescreen ()
{
   register int i;

   InitView (&v);
   InitVPort (&vp);
   InitBitMap (bm[0], (long) DEPTH, WIDTH, HEIGHT);
   InitBitMap (bm[1], (long) DEPTH2, WIDTH, HEIGHT);
   InitRastPort (&rp);
   InitRastPort (&rp2);

   v.ViewPort = &vp;

   ri.BitMap = bm[0];    ri2.BitMap = bm[1];
   ri.RxOffset = 0;      ri.RyOffset = 0; ri.Next = &ri2;
   ri2.RxOffset = 0;     ri2.RyOffset = 0; ri2.Next = NULL;
   rp.BitMap = bm[0];    rp2.BitMap = bm[1];

   for (i=0; i<DEPTH; i++)   /* Added PLANEPTR. VANSOFT */
      if (!(bm[0]->Planes[i] = (PLANEPTR)AllocRaster (WIDTH, HEIGHT)))
         die ("Can't allocate memory for plane (bm 0).\n");

   for (i=0; i<DEPTH2; i++)  /* Added PLANEPTR. VANSOFT */
      if (!(bm[1]->Planes[i] = (PLANEPTR)AllocRaster (WIDTH, HEIGHT)))
         die ("Can't allocate memory for plane (bm 1).\n");

   oldview = GfxBase->ActiView;
   vp.DWidth = DWIDTH;
   vp.DHeight = DHEIGHT;
   vp.RasInfo = &ri;
   vp.ColorMap = GetColorMap(COLOURCOUNT);
   vp.Modes = MODES;
}

closeeverything ()
{
   register int i;

   SoundOff();
   FreeSprite(2L);
   FreeSprite(3L);
   FreeSprite(4L);

   if (oldview) {
      LoadView (oldview);
      WaitTOF ();
      FreeVPortCopLists (&vp);
      FreeCprList (v.LOFCprList);
   }

   if (vp.ColorMap)
      FreeColorMap (vp.ColorMap);

   for (i=0; i<DEPTH; i++)
      if ((bm[0]->Planes[i]) != NULL)
         FreeRaster(bm[0]->Planes[i],WIDTH,HEIGHT);

   for (i=0; i<DEPTH2; i++)
      if ((bm[1]->Planes[i]) != NULL)
         FreeRaster(bm[1]->Planes[i],WIDTH,HEIGHT);

   if (GfxBase) CloseLibrary (GfxBase);
   if (IntuitionBase) CloseLibrary (IntuitionBase);
}

die (str)
char *str;
{
   puts (str);
   closeeverything ();
   exit (100);
}

DrawObjects()
{
   SetRast (&rp2, 0L);
   SetRast (&rp, 0L);

   DrawImage(&rp, &Gate, 1L, 5L);
   DrawImage(&rp, &Gate, 240L, 5L);
   DrawImage(&rp, &Gate, 500L, 5L);

   DrawImage(&rp2, &AW, 45L, 147L);
   DrawImage(&rp, &DoorDown, 400L, 42L);
   DrawImage(&rp, &DoorUp, 430L, 141L);
}

short getbit(num,bit)    /* extract a bit */
  short num,bit;
{ return (num>>bit & 1); }


BOOL JoyStick() /* Changed, now checks gameport 0 for left mouse button. */
{               /* VANSOFT. */
   short button,up,down,left,right;

                           /* Added CIAB_GAMEPORT0, VANSOFT. */
 button = !getbit((UWORD)ciaa->ciapra,CIAB_GAMEPORT0);  /* 0 for closed */
 up = getbit(joy,8) ^ getbit(joy,9);                    /* xor of bits 8,9 */
 down = getbit(joy,0) ^ getbit(joy,1);                  /* xor of bits 0,1*/
 left = getbit(joy,9);
 right = getbit(joy,1);
 return(button);
}

SetSprites()

{
   short sgot;
   register int i;

   if (sgot = GetSprite(&Sprites[0],2L)==0) die("Sprites Failed\n");
   Sprites[0].x=30;
   Sprites[0].y=92;
   Sprites[0].height = 16;
   if (sgot = GetSprite(&Sprites[1],3L)==0) die("Sprites Failed\n");
   Sprites[1].x=270;
   Sprites[1].y=92;
   Sprites[1].height = 16;

   if (sgot = GetSprite(&Sprites[2],4L)==0) die("Sprites Failed\n");
   Sprites[2].height = 16;
   Sprites[2].x = 152;
   Sprites[2].y = 182;

   ChangeSprite(&vp,&Sprites[0],HeyData);
   ChangeSprite(&vp,&Sprites[1],WowData);
}

ShipSprite(x,y)
UWORD x,y;
{
   static int i=0;

   Sprites[2].y--;
   if (Sprites[2].y == -15) Sprites[2].y = 182;

   switch(i) {
      case 0 :
         ChangeSprite(&vp,&Sprites[2],ship1_dat);
         break;
      case 5 :
         ChangeSprite(&vp,&Sprites[2],ship2_dat);
         break;
      case 10:
         ChangeSprite(&vp,&Sprites[2],ship3_dat);
         break;
      case 15:
         ChangeSprite(&vp,&Sprites[2],ship4_dat);
         break;
      default:
         break;
   }
   MoveSprite(&vp,&Sprites[2],(long)Sprites[2].x,(long)Sprites[2].y);
   i ++;
   if (i > 20) i = 0;
}


ColourControl()
{
   static int count = 3, UPDOWN = -1;
   int temp,i;

        ri2.RyOffset -= UPDOWN;
   if(ri2.RyOffset == 0 || ri2.RyOffset == 147)
        UPDOWN = 0-UPDOWN;

   if(!(cl = AllocChip(sizeof(struct UCopList))))
        die ("Copper Allocation Failed.\n");

        CWAIT(cl,1L,0L);
   if(SFlag) 
        CMOVE(cl,custom.bplcon2,36L);
   if(!(SFlag)) 
        CMOVE(cl,custom.bplcon2,32L);

        CMOVE(cl,custom.color[20],0x055FL);
        CMOVE(cl,custom.color[21],0x0F80L);
        CMOVE(cl,custom.color[22],0x0E11L);
        CMOVE(cl,custom.color[24],(long)ship_col[0]);
        CMOVE(cl,custom.color[25],(long)ship_col[1]);
        CMOVE(cl,custom.color[26],(long)ship_col[2]);

   count--;

   if(!(count)) {
        temp = Palette[15];

       for(i=15;i>9;i--) 
           Palette[i] = Palette[i-1];

        Palette[10] = temp;
        count = 3;
     }
   for(i=9;i<16;i++) 
        CMOVE(cl,custom.color[i],(long)Palette[i]);

   CEND(cl);
   ShowView(1);
}

MoveSprites()
{
   static int y1 = 2, y2 = -2;
   static int MOVELEFT = -1, LOS = 0;

   if(Sprites[0].y < 25 || Sprites[0].y > 159) {
      if(SFlag) 
         SFlag = FALSE; 
       else 
         SFlag = TRUE;

      y1 = 0-y1; y2 = 0-y2;
    }

   ColourControl();

   Sprites[0].y += y1;
   Sprites[1].y += y2;
   MoveSprite(&vp,&Sprites[0],(long)Sprites[0].x,(long)Sprites[0].y);
   MoveSprite(&vp,&Sprites[1],(long)Sprites[1].x,(long)Sprites[1].y);

   if(Sprites[0].y < 64 && y1 < 0) { 
       DY1 -= 2; DY4 += 2; 
       }
   if(Sprites[0].y <= 65 && y1 > 0) { 
       DY1 += 2; DY4 -= 2; 
       }
   if(Sprites[0].y > 120 && y1 > 0) { 
       DY2 += 2; DY3 -= 2; 
       }
   if(Sprites[0].y >= 120 && y1 < 0) { 
      DY2 -= 2; DY3 += 2; 
      }

   ClipBlit(&rp,499L,73L,&rp, (long)LOS,73L,81L,51L,MTCU);
   ClipBlit(&rp,499L,73L,&rp, (long)239-LOS,73L,81L,51L,MTCU);

   ClipBlit(&rp,400L,DY1+20L,&rp, 27L,22L,26L,34L,MTCU);
   ClipBlit(&rp,430L,DY2,&rp, 27L,141L,26L,34L,MTCU);
   ClipBlit(&rp,400L,DY3+20L,&rp,266L,22L,26L,34L,MTCU);
   ClipBlit(&rp,430L,DY4,&rp,266L,141L,26L,34L,MTCU);

   if(LOS==80 || LOS == 0)
      MOVELEFT = 0-MOVELEFT;

LOS += MOVELEFT;
}

SetColour()
{
   int i,n;

   for (n = 3; n < 99; n++) {

      if(!(cl = AllocChip(sizeof(struct UCopList))))
           die("Copper Allocation Failed.\n");

          CWAIT(cl,(long)1L,0L);
          CMOVE(cl,custom.bplcon2,32L);

      for(i=0;i<16;i++) 
          CMOVE(cl,custom.color[i],0L);
          CWAIT(cl,(long)99-n,0L);
      for(i=0;i<16;i++) 
          CMOVE(cl,custom.color[i],(long)Palette[i]);
          CWAIT(cl,(long)99+n,0L);
      for(i=0;i<16;i++) 
          CMOVE(cl,custom.color[i],0L);
          CEND(cl);

      ShowView(0);
   }

 LoadRGB4(&vp,Palette,COLOURCOUNT);
}

SoundOff()
{
   if(!(cl = AllocChip(sizeof(struct UCopList))))
        die("Copper Allocation Failed.\n");

   CWAIT(cl,1L,0L);
   CMOVE(cl,custom.aud[0].ac_ptr,(long)NULL);
   CMOVE(cl,custom.aud[0].ac_len,0L);
   CMOVE(cl,custom.aud[0].ac_vol,0L);
   CMOVE(cl,custom.aud[0].ac_per,0L);
   CMOVE(cl,custom.dmacon,15L);
   CEND(cl);
   ShowView(0);
   WaitTOF();
}


SoundOn()
{
   if(!(cl = (struct UCopList *)AllocChip(sizeof(struct UCopList))))
      die ("Copper Allocation Failed.\n");

   CWAIT(cl,1L,0L);
   CMOVE(cl,custom.aud[0].ac_ptr,(long)sound);
   CMOVE(cl,custom.aud[0].ac_len,2988L);
   CMOVE(cl,custom.aud[0].ac_vol,64L);
   CMOVE(cl,custom.aud[0].ac_per,3006L/8L);
   CMOVE(cl,custom.dmacon,0x08201L);
   CEND(cl);
   ShowView(0);
   WaitTOF();
}

ShowView(typ)
int typ;
{  /* Changed 'void *' to 'struct CopList'. VANSOFT. */
   struct CopList *dspins,*sprins,*clrins;

   dspins=(struct CopList *)vp.DspIns; 
   sprins=(struct CopList *)vp.SprIns; 
   clrins=(struct CopList *)vp.ClrIns;

   Forbid();
   vp.DspIns = vp.SprIns = vp.ClrIns = 0;
   FreeVPortCopLists(&vp);

   vp.DspIns=(struct CopList *)dspins; 
   vp.SprIns=(struct CopList *)sprins; 
   vp.ClrIns=(struct CopList *)clrins;
   vp.UCopIns=cl;

   Permit();
 if(typ)
   return;
         
   MakeVPort (&v, &vp);
   MrgCop(&v);
   LoadView (&v);
}

