
/* Program for test of Maker.lib */
/* By Lars Thuring */

/* 880920 V1.0  First */

   /****************************************************************\
   *                                                                *
   * Since the main purpose of this program is to demonstrate the   *
   * MakeXxxx() routines very little response is given to user      *
   * activities.                                                    *
   *                                                                *
   * It also reveals some cosmetical misshaps which will be removed *
   * in the mark 2 version. Real soon now.                          *
   *                                                                *
   \****************************************************************/

#include <exec/types.h>
#include <intuition/intuition.h>
#include "MakeName.h"

extern struct Window *OpenWindow();
extern VOID MakeMenu();
extern int MakeAutoRequest();

struct IntuitionBase *IntuitionBase; /* libraries */
struct GfxBase *GfxBase;
struct Screen *CustScr;              /* graphics */
struct Window *Window;
struct RastPort *Rp;
struct IntuiMessage *message,*GetMsg();

UBYTE gname[9][50],
      bname[9][50];

struct NewWindow NewWindow = {
   0,0,640,200,2,1,
   MENUPICK,
   ACTIVATE|WINDOWSIZING|WINDOWDRAG|WINDOWDEPTH|SMART_REFRESH,
   NULL,NULL,">!<",
   NULL,NULL,
   200,50,640,256,WBENCHSCREEN
   };

static UBYTE *What[] = {      /* What's on the menu ? */
   "[M]Project",
   "[ I]About",
   "[ I]Quit",
   "[M]Menu",
   "[ I]MenuItem 1",
   "[  S]SubItem 1a",
   "[  S]SubItem 1b",
   "[ IJ]MenuItem 2",
   "[  SJ]SubItem 2a",
   "[  SJ]SubItem 2b",
   "[ IN]UnMoved",
   "[ IJ]Alternate text",
   "[ IJA]when selected!",
   "[M]Another",
   "[ IB]Neither mctrash",
   "[ IB]nor pctrash.",
   "[ IVde]  Deselect item 4 & 5",
   "[ ICce]  Deselect item 3 & 5",
   "[ ICcd]  Deselect item 3 & 4",
   "[ I]nothing",
   "[  SD]NOT ENABLED",
   "[  SD]DITO",
   "[ I]right amiga",
   "[  SC_z]  Zap     ",
   "[  SC_w]  Wam     ",
   "[M]COLUMNS",
   "[ I]a1",
   "[ I]a2",
   "[ I]a3",
   "[ IH]b1",
   "[ I]b2",
   "[ I]b3",
   "[M]Some",
   "[ I]Check two:  ",              /* The following array is filled in */
   &gname[0][0],                    /* later to show that nothing have  */
   &gname[1][0],                    /* to be fixed at start.            */
   &gname[2][0],
   &gname[3][0],
   &gname[4][0],
   &gname[5][0],
   &gname[6][0],
   &gname[7][0],
   &gname[8][0],
   NULL
   };

   /* Defines for menu op's */

#define MPROJECT     0
#define IABOUT          0
#define IQUIT           1



static struct Menu Head[9];         /* The Menu structs */
static struct MenuItem Body[59],    /* and the MenuItem structs */
                       *ItemAddress();
static struct IntuiText Text[59];   /* The IntuiText structs */
struct Menu *MenuStrip = &Head[0];

   /* Simple messages: */

UBYTE *AboutText[] = {
      "[J2TB2]                                                     ",
      "[] This program shows the various maker.lib functions. ",
      "[]                                                     ",
      "[F3] (C)Copyright 14 sep 1988 by Lars Thuring            ",
      "[NB0] OK ",
      NULL
      };

UBYTE *QuitText[] = {
      "[T]",
      "[] Are you sure you really want to quit ?? ",
      "[]",
      "[P] sure !",
      "[N] CANCEL ",
      NULL
      };


ULONG mClass;          /* Returns from HandleEvent */
USHORT code;
APTR address;
SHORT mX,mY;

VOID main(),TheEnd();
VOID GetIDCMP(),
     HandleMenu();
int MyInit();

VOID main()
   {
int i;                                 /* trash */
SHORT x,y;                             /* For boxes */

   for(i=0;i<9;i++)                    /* Init name arrays */
      {
      strcpy(&bname[i][0],"[C0F2J1C]");
      MakeName(&bname[i][9], TITLENAME|FULLNAME, BOYNAME);
      strcpy(&gname[i][0],"[ SC]  ");
      MakeName(&gname[i][7], FIRSTNAME, GIRLNAME);
      }


   MyInit();                           /* Sets up environment */


   /* Draw some things */

   x=11;

   MakeBox(Rp,x,20,0,0,"[JF2]MakeBox parts:");

   MakeBox(Rp,x, 35,50,10,"[C0]");
   MakeBox(Rp,x, 55,50,10,"[C1]");
   MakeBox(Rp,x, 75,50,10,"[C2]");
   MakeBox(Rp,x, 95,50,10,"[C3]");

   MakeBox(Rp,x,115,0,0,"[JF2]combinations:");

   MakeBox(Rp,x,135,50,10,"[C0C1]");
   MakeBox(Rp,x,155,50,10,"[C0C2]");
   MakeBox(Rp,x,175,50,10,"[C0C3]");

   x=200;

   MakeBox(Rp,x, 20,0,0,"[JF2]and so on...");

   MakeBox(Rp,x, 45,75,35,"[SF2J0C2]");
   MakeBox(Rp,x,100,75,35,"[SF1J0C3]");

   x = 370;
   y = 20;

   for(i=0;i<9;i++)
      {
      MakeBox(Rp,x,y,0,0,&bname[i][0]);
      y+=19;
      }


   while (mClass NOT= CLOSEWINDOW)
      {
      GetIDCMP(Window);       /* Wait for something to happen */

      switch(mClass)
         {
         case MENUPICK:       /* If menu selection */
            HandleMenu();
            break;
         default:             /* If something unidentified */
            break;
         }
      }


   TheEnd();
   }          /* E N D  O F  M A I N */

int MyInit()
   {

   /* Open libs, get pointer and check if succes */

   IntuitionBase = (struct IntuitionBase *)
      OpenLibrary("intuition.library",LIBRARY_VERSION);
   if (IntuitionBase == NULL) exit(FALSE);

   GfxBase = (struct GfxBase *)
      OpenLibrary("graphics.library",LIBRARY_VERSION);
   if (GfxBase == NULL) exit(FALSE);

   /* Ok, open window */

   if ((Window = OpenWindow(&NewWindow)) == NULL)
      exit(FALSE);

   Rp=Window->RPort;

   MakeMenu(&What[0], &Head[0], &Body[0], &Text[0]);
   SetMenuStrip(Window, MenuStrip);

   return(NULL);
   }


VOID TheEnd()
   {
   if (Window) CloseWindow(Window);
   if (GfxBase) CloseLibrary(GfxBase);
   if (IntuitionBase) CloseLibrary(IntuitionBase);
   }


VOID GetIDCMP(w)     /* Get commo flags */
struct Window *w;    /* For this window */
   {
   Wait(1<<w->UserPort->mp_SigBit);  /* Wait nicely */

   message = GetMsg(w->UserPort);

   mClass  = message-> Class;  /* Make copy of message description */
   code    = message-> Code;
   address = message-> IAddress;
   mX      = message-> MouseX;
   mY      = message-> MouseY;

   ReplyMsg(message);   /* Let intuition know message acknowledged */
   }

VOID HandleMenu()       /* Checks for multiple selects by user */
   {
USHORT MenuNumber = code;  /* From IDCMP */
USHORT Mnum, Inum, Snum;   /* Derived from ordinal number(s) */
struct MenuItem *pItem;

   while (MenuNumber NOT= MENUNULL)   /* Untill done */
      {
      Mnum = MENUNUM(MenuNumber);      /* Make numbers */
      Inum = ITEMNUM(MenuNumber);
      Snum = SUBNUM(MenuNumber);
      pItem = ItemAddress( MenuStrip, MenuNumber);

      switch (Mnum)
         {
         case MPROJECT:
            switch (Inum)
               {
               case IABOUT:
                  MakeAutoRequest(Window, AboutText);
                  break;

               case IQUIT:
                  if (MakeAutoRequest(Window, QuitText))
                     mClass=CLOSEWINDOW;
                  break;

               default:
                  break;
               }


         default:
            break;
         }

      MenuNumber = pItem->NextSelect;     /* Looping */
      }
   }     /*  End of HandleMenu() */



