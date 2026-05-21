/****************************************************
 *                KNIGHTLORE.C
 *
 * An attempt to implement a "KnightLore" type scene
 * rendering system on the Amiga.
 *
 *
 * Written by Kel & Billy 8-Apr-88
 *
 */

#include "header:knightlore.h"
#include "header:knightmemory.h"
#include "header:knightblit.h"

#define WIDTH SCREENWIDTH
#define HEIGHT SCREENHEIGHT
#define DEPTH 2

int Movements[]={
    16, 1, 0, 0,
    16, 0, 1, 0,
    16,-1, 0, 0,
    16, 0,-1, 0,
     8, 0, 0, 1,
    16, 0,-1, 0,
     8, 0, 0,-1,
    32, 1, 0, 0,
    48, 0, 1, 0,
    48,-1, 0, 0,
    32, 0,-1, 0,
     8, 0, 0,-1,
    16, 1, 0, 0,
    16, 0, 0, 1,
    24, 1, 1, 0,
    16, 0, 0,-1,
    32,-1,-1, 0,
    16, 0, 0, 1,
     8, 1, 1, 0,
    16, 0, 0,-1,
     8,-1,-1, 0,
    16, 0, 0, 1,
     8, 1, 1, 0,
     8, 0, 0,-1,
    16, 0, 1, 0,
     8, 0, 0,-1,
     8,-1, 1, 0,
    16, 0, 0, 1,
     8, 1,-1, 0,
    16, 0, 0,-1,
     8,-1, 1, 0,
    16, 0, 0, 1,
     8, 1,-1, 0,
    16, 0, 0,-1,
     8,-1, 1, 0,
    16, 0, 0, 1,
    32, 1,-1, 0,
    16, 0, 0,-1,
     8,-1, 1, 0,
    16, 0, 0, 1,
     8, 1,-1, 0,
    16, 0, 0,-1,
    16,-1, 1, 0,
     0, 0, 0, 0
};

extern void RefreshWorld();
extern struct Window *OpenWindow(); /* function to open a window */
extern struct ViewPort *ViewPortAddress(); /* function to get ViewPort add. */
extern struct IntuiMessage *GetMsg(); /* function to retrieve IntuiMessage */


struct GfxBase *GfxBase;        /* pointer to Graphics library */
struct IntuitionBase *IntuitionBase; /* pointer to Intuition library */

struct Window *window;          /* pointer to window */
struct RastPort *rport;         /* pointer to window's RastPort */
struct ViewPort *vport;         /* pointer to window's ViewPort */

struct IntuiMessage *message;   /* pointer to window IDCMP messages */

#  include "myspr.h"

struct NewWindow nw = {         /* titler-window definition */
    0, 0,               /* LeftEdge, TopEdge */
    WIDTH, HEIGHT,      /* Width, Heigth */
    -1, -1,             /* DetailPen, BlockPen */
    /* IDCMPFlags */
    CLOSEWINDOW,
    /* Flags */
    ACTIVATE|REPORTMOUSE|SIZEBBOTTOM|WINDOWCLOSE|WINDOWDEPTH
        |WINDOWDRAG|WINDOWSIZING,
    NULL,               /* FirstGadget */
    NULL,               /* CheckMark */
    "==->KnightLore<-==",  /* Title */
    NULL,               /* Screen */
    NULL,               /* BitMap */
    80, 25,             /* MinWidth, MinHeight */
    640, 200,           /* MaxWidth, MaxHeight */
    WBENCHSCREEN        /* Type */
};


void SplatOnWorld()
{
   register struct KnightAtom *Temp;
   EraseOurBitMaps();
   for(Temp=KnightList->blink;Temp!=KnightList;Temp=Temp->blink)
      BlitBrick(Temp->Xl,Temp->Yt);
   DumpOurBitMaps();
}
void RefreshWorld(Xl,Yt,Xr,Yb)
int Xl,Yt,Xr,Yb;
{
   register struct KnightAtom *Temp;
   EraseRectangle(Xl,Yt,Xr-Xl,Yb-Yt);
   for(Temp=KnightList->blink;Temp!=KnightList;Temp=Temp->blink){
      if(!(Temp->Xr<Xl || Temp->Xl>Xr || Temp->Yb<Yt || Temp->Yt>Yb)){
         BlitBrick(Temp->Xl,Temp->Yt);
      }
   }
   DumpRectangle(Xl,Yt,Xr-Xl,Yb-Yt);
}

struct KnightAtom *GimmeAtom(x,y,z,Name)
int x,y,z;
char *Name;
{
   struct KnightAtom *Atom;
   Atom=GetAnAtom();			/* Fetch one */
   Atom->nX=x;
   Atom->ID=Name;
   Atom->nY=y;
   Atom->nZ=z;
   Atom->fX=Atom->nX+8;
   Atom->fY=Atom->nY+8;
   Atom->fZ=Atom->nZ-8;
   Atom->Xl=TWODX(Atom->nX,Atom->nY,Atom->nZ);
   Atom->Yt=TWODY(Atom->nX,Atom->nY,Atom->nZ);
   Atom->Xr=Atom->Xl+BOXWIDTH;
   Atom->Yb=Atom->Yt+BOXHEIGHT;
   return Atom;
}
void MoveAtom(Atom,dx,dy,dz,Flag)
struct KnightAtom *Atom;
int dx,dy,dz;
int Flag;
{
   int Xl,Yt,Xr,Yb;
   Xl=Atom->Xl;
   Yt=Atom->Yt;
   Xr=Atom->Xr;
   Yb=Atom->Yb;
   Atom->nX+=dx;
   Atom->nY+=dy;
   Atom->nZ+=dz;
   Atom->fX=Atom->nX+8;
   Atom->fY=Atom->nY+8;
   Atom->fZ=Atom->nZ-8;
   Atom->Xl=TWODX(Atom->nX,Atom->nY,Atom->nZ);
   Atom->Yt=TWODY(Atom->nX,Atom->nY,Atom->nZ);
   Atom->Xr=Atom->Xl+BOXWIDTH;
   Atom->Yb=Atom->Yt+BOXHEIGHT;
   if(Xl>Atom->Xl)Xl=Atom->Xl;
   if(Yt>Atom->Yt)Yt=Atom->Yt;
   if(Xr<Atom->Xr)Xr=Atom->Xr;
   if(Yb<Atom->Yb)Yb=Atom->Yb;
   (void)RemQue(Atom);
   PrimeList(Atom);
   if(Flag) RefreshWorld(Xl,Yt,Xr,Yb);
}   
main()
{       
    struct KnightAtom *(Atom[32]);
    BOOL MouseMoved;
    UWORD i;                    /* general purpose index variable */
    UWORD x, y;

    /* open libraries, bail out if there is a problem */
    if((IntuitionBase = (struct IntuitionBase *)
        OpenLibrary("intuition.library", 0)) == NULL)printf("Panic No Libz\n");;
    if((GfxBase = (struct GfxBase *)
        OpenLibrary("graphics.library", 0)) == NULL)printf("Panic No Libz\n");

    /* open window, abort if unable */
    if((window = OpenWindow(&nw)) == NULL) printf("Panic No wo\indow\n");
    rport = window->RPort;
    vport = ViewPortAddress(window);

    InitOurPorts();
    AllocateAtoms();
    Atom[0]=GimmeAtom(32,32,24,"E");
    PrimeList(Atom[0]);			/* Bear him into the world */
    Atom[1]=GimmeAtom(48,24,24,"B");
    PrimeList(Atom[1]);			/* Bear him into the world */
    Atom[2]=GimmeAtom(48,40,24,"C");
    PrimeList(Atom[2]);			/* Bear him into the world */
    Atom[3]=GimmeAtom(16,40,24,"D");
    PrimeList(Atom[3]);			/* Bear him into the world */
    Atom[4]=GimmeAtom(16,24,24,"A");
    PrimeList(Atom[4]);			/* Bear him into the world */
    Atom[5]=GimmeAtom(16,32,24,"1");
    PrimeList(Atom[5]);			/* Bear him into the world */
    Atom[6]=GimmeAtom(48,32,24,"2");
    PrimeList(Atom[6]);			/* Bear him into the world */
    Atom[7]=GimmeAtom(24,48,24,"3");
    PrimeList(Atom[7]);			/* Bear him into the world */
    Atom[8]=GimmeAtom(32,48,24,"4");
    PrimeList(Atom[8]);			/* Bear him into the world */
    Atom[9]=GimmeAtom(40,48,24,"5");
    PrimeList(Atom[9]);			/* Bear him into the world */
    Atom[10]=GimmeAtom(24,16,24,"6");
    PrimeList(Atom[10]);		/* Bear him into the world */
    Atom[11]=GimmeAtom(32,16,24,"7");
    PrimeList(Atom[11]);		/* Bear him into the world */
    Atom[12]=GimmeAtom(40,16,24,"8");
    PrimeList(Atom[12]);		/* Bear him into the world */
    
    SplatOnWorld();
    Atom[13]=GimmeAtom(24,24,24,"Marvin");
    PrimeList(Atom[13]);			/* Bear him into the world */
    {
       int i,j,*IPtr;
       IPtr=Movements;
       for(IPtr=Movements;IPtr[0]!=0;IPtr+=4){
          while(IPtr[0]-->0) MoveAtom(Atom[13],IPtr[1],IPtr[2],IPtr[3],1);
       }
       for(i=0;i<8;i++){
          MoveAtom(Atom[5], 0, 0, 1, 0);
          MoveAtom(Atom[6], 0, 0, 1, 0);
          MoveAtom(Atom[11], 0, 0, 1, 0);
          MoveAtom(Atom[8], 0, 0, 1, 0);
          SplatOnWorld();
       }
       for(i=0;i<8;i++){
          MoveAtom(Atom[5], 0, 0,-1, 0);
          MoveAtom(Atom[6], 0, 0,-1, 0);
          MoveAtom(Atom[11], 0, 0,-1, 0);
          MoveAtom(Atom[8], 0, 0,-1, 0);
          SplatOnWorld();
       }
       for(i=0;i<8;i++){
          MoveAtom(Atom[5], 1, 0, 0, 0);
          MoveAtom(Atom[6],-1, 0, 0, 0);
          MoveAtom(Atom[11], 0, 1, 0, 0);
          MoveAtom(Atom[8], 0,-1, 0, 0);
          SplatOnWorld();
       }
       for(i=0;i<24;i++){
          MoveAtom(Atom[0],  0, 0, 1, 0);
          MoveAtom(Atom[13], 0, 0, 1, 0);
          SplatOnWorld();
       }
       for(i=0;i<8;i++){
          MoveAtom(Atom[0],  0, 0, 1, 0);
          MoveAtom(Atom[13], 0, 0,-3, 0);
          SplatOnWorld();
       }
    }
    for(message->Class=0;message->Class!=CLOSEWINDOW;){
       Wait(1 << window->UserPort->mp_SigBit);
       MouseMoved = FALSE;
       message = GetMsg(window->UserPort);
       switch(message->Class){
          case CLOSEWINDOW:
             ReplyMsg(message);
          break;
          default:
             ReplyMsg(message);
          break;
       }
   }
   FreeAtoms();
   FreeOurPorts();
   if(window != NULL)
       CloseWindow(window);

   /* Close any open libraries */
   if(GfxBase != NULL)
       CloseLibrary(GfxBase);
   if(IntuitionBase != NULL)
       CloseLibrary(IntuitionBase);

   exit(0);
}


