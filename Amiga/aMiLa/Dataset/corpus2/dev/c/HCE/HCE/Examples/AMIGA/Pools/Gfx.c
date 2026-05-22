/*
 * Copyright (c) 1994. Author: Jason Petty.
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *
 *     Gfx.c:
 *
 *            Opens libraries/screen/window and printer device.
 *            Does all graphics related stuff.
 *            Does Help messages.
 *            Does all Printer related stuff.
 */

#include <exec/types.h>
#include <exec/errors.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <libraries/dos.h>
#include <devices/printer.h>

#ifndef  GRAPHICS_GFXBASE_H
#include <graphics/gfxbase.h>
#endif

#ifndef  INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#include <graphics/gfxmacros.h>

#ifndef STDIO_H
#include <clib/stdio.h>
#endif

#ifndef STRING_H
#include <clib/string.h>
#endif

#include "pools.h"

   /**** All Structure definitions start Here *****/

chip struct NewScreen my_new_screen=
{
  0,            /* LeftEdge */
  0,            /* TopEdge  */
  641,
  266,
  4,            /* 4 = 16 colours.   */
  1,            /* DetailPen Text should be printed with colour reg. 1   */
  5,            /* BlockPen  Blocks should be printed with colour reg. 0 */
  HIRES,        /* ViewModes.                            */
  CUSTOMSCREEN|SCREENQUIET, /* Type. Your own customized screen. */
  NULL,         /* Font      Default font.               */
  NULL,         /* UBYTE Pools-V1.0.  Title.               */
  NULL,         /* Gadget                                */
  NULL          /* BitMap    No special CustomBitMap.    */
};

/* Covers hole of screen and is used for graphics. */
struct NewWindow gfx_new_win=
{
  0,1,
  641, 259,                             /* Use screens sizes.   */
  1,0,                          /* Detailpen, Blockpen. */
  IDCMP_CLOSEWINDOW|IDCMP_CLOSEWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP,
  WFLG_CLOSEGADGET|WFLG_ACTIVATE|WFLG_GIMMEZEROZERO|WFLG_BORDERLESS,
  NULL,                                 /* First gadget.        */
  NULL,                                 /* Image checkmark.     */
  NULL,                                 /* Title.               */
  NULL,                                 /* Screen pointer.      */
  NULL,                                 /* Custom Bitmap.       */
  120,88,                         /* Min W,H sizes.       */
  641,259,                         /* Max W,H sizes.       */
  CUSTOMSCREEN                          /* Type.                */
};

/* This is a general purpose shared window. */
struct NewWindow g_new_window=
{
  0,             /* LeftEdge   */
  1,             /* TopEdge    */
  640,           /* Width      */
  200,           /* Height     */
  2,3,           /* DetailPen,BlockPen */
  IDCMP_CLOSEWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP,
  WFLG_SMART_REFRESH|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
  NULL,          /* FirstGadget */
  NULL,          /* CheckMark   */
  NULL,          /* Title.      */
  NULL,          /* Screen      */
  NULL,          /* BitMap      */
  20,            /* MinWidth    */
  20,            /* MinHeight   */
  641,           /* MaxWidth    */
  259,           /* MaxHeight   */
  CUSTOMSCREEN   /* Type        */
};

union printerIO             /* Printer Request Block. */
{
  struct IOStdReq ios;
  struct IODRPReq iodrp;
  struct IOPrtCmdReq iopc;
};


union printerIO *prt_req=0;
struct MsgPort *prt_reply=0;
UWORD prt_error=TRUE;             /* Printer Device error. */
extern struct Gadget *sl_gadlist; /* Head of 'choose league' Gadget list.*/
struct Window *g_window=0;        /* (Shared Window)   */
struct Window *gfx_window=0;      /* (graphics window) */
struct Screen *my_screen=0;
struct GfxBase *GfxBase=0;
long IntuitionBase=0;
long GadToolsBase=0;

  /**** Global Variables Here ****/

static WORD font_width, font_height;
char PR_BUF[90]; /* General purpose buffer. */

/********************** Rest of code = FUNCTIONS *********************/

 /* Start() must be called at beginning; returns window pointer - if 0,
  * program has failed ... everything already cleaned up here, main ()
  * must do its own cleaning up then exit */

struct Window *start ()
{
  /* Libraries. */
 if (!(GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0)))
  goto FAILED;
 if (!(IntuitionBase=(long)OpenLibrary("intuition.library",0)))
  goto FAILED;
        if (!(GadToolsBase=(long)OpenLibrary("gadtools.library", 36))) {
       /*  printf("Could not Open gadtools.library - V36 or Higher!!\n"); */
                goto FAILED;
                }

   /* Screen */
        if (!(my_screen = (struct Screen *)OpenScreen( &my_new_screen)))
                goto FAILED;

            g_new_window.Screen=my_screen;  /* Attach g Win to Screen.  */
            gfx_new_win.Screen=my_screen;   /* Attach gfx Win to Screen.*/

    /* GadTools */
        if (!(Alloc_VisualInfoA())) /* Get Visual info for gad tools. */
                 goto FAILED;
        if (!(Alloc_L_Gadgets()))   /* Alloc, League Gadgets */
                 goto FAILED;

            gfx_new_win.FirstGadget = (struct Gadget *)sl_gadlist;

    /* Gfx Window. */
       if (!(gfx_window = (struct Window *)OpenWindow(&gfx_new_win))) {
              /* printf("No gfx_window!!\n"); */
                 goto FAILED;
        }
    /* Set up 'my_screen' and 'gfx_window' Graphics. */
        (void)Set_Graphics();

       font_width=GfxBase->DefaultFont->tf_XSize; /* May need these. */
       font_height=GfxBase->DefaultFont->tf_YSize;

   /* Printer stuff (note: actual printer device only opened when needed) */
        if (!(prt_reply = (struct MsgPort *)CreatePort( NULL, 0))) {
               /* printf("Could not Open - Printer reply port!!\n"); */
                goto FAILED;
                }
        if (!(prt_req = (union printerIO *) 
                CreateExtIO(prt_reply, sizeof(union printerIO)))) {
             /* printf("Could not Create - Printer ExtIO!!\n");  */
                goto FAILED;
                }

        return (gfx_window);

FAILED:
        finish ();
        return (0L);
}

 /* Call finish() at end, if start() was successful. */
void finish ()
{
        if (!prt_error)                 /* Close printer device. */
                CloseDevice( prt_req );
        if (prt_req)
                DeleteExtIO( prt_req, sizeof(union printerIO) );
        if (prt_reply)
                DeletePort( prt_reply);
        if (gfx_window)
            CloseWindow (gfx_window);

         Close_GWind();      /* Close g window. (Tests for opened).      */
         Free_GT_Gadgets();  /* Free gad memory. (Tests if allocated).   */
         Free_VisualInfo();  /* Free visual memory. (Tests if allocated).*/

        if (my_screen)
                CloseScreen (my_screen);
        if (GadToolsBase)
                CloseLibrary(GadToolsBase);
 if (GfxBase)
  CloseLibrary (GfxBase);
 if (IntuitionBase)
  CloseLibrary (IntuitionBase);
}

/********** START OF PRINTER FUNCTIONS ******************/

void PrtError(error) /* Prints the appropriate printer error message.*/
BYTE error;          /* (g_window) result box */
{
  Clear_RBOX();

  switch( error ) /* Errors found in 'exec/errors.h' & 'devices/printer.h' */
  {
  case IOERR_ABORTED:
          RB_Msg("ERROR: The printer request was aborted!",0);
          break;
  case IOERR_NOCMD:
          RB_Msg("ERROR: Unknown printer command was sent!",0);
          break;
  case IOERR_BADLENGTH:
          RB_Msg("ERROR: Bad length in the printer CMD - DATA!",0);
          break;
  case PDERR_CANCEL:
          RB_Msg("All Printing Cancelled!",0);
          break;
  case PDERR_NOTGRAPHICS:
          RB_Msg("ERROR: Printer doesn`t support Graphics!.",0);
          break;
  case PDERR_BADDIMENSION:
          RB_Msg("ERROR: Printer dimension is not valid!",0);
          break;
  case PDERR_INTERNALMEMORY:
          RB_Msg("No memory for internal printer functions!",0);
          break;
  case PDERR_BUFFERMEMORY:
          RB_Msg("No memory for the printer buffer!",0);
          break;
  default:
          RB_Msg("ERROR: Unkown printer error received!",0);
          break;
  }
}

BYTE DO_PrtText(data)      /* Sends translated Text to the printer. */
char *data;                /* Pointer to text. (Uses WB prefs).     */
{
 if(prt_error) {           /* Printer device not open?. */
     if ((prt_error = OpenDevice("printer.device", 0, prt_req, 0))) {
              return((BYTE)prt_error);
              }
   }
  prt_req->ios.io_Command = CMD_WRITE;
  prt_req->ios.io_Data = (APTR)data;
  prt_req->ios.io_Length = -1;
  return( (BYTE) DoIO( prt_req ) ); /* return, 0 = Ok else error. */
}

/********* END OF PRINTER FUNCTIONS *******************/


/********* GRAPHICS FUNCTIONS ***********/

void Set_Graphics()
{
  SetRGB4( s_vp,  0, 0x0, 0x0, 0x0 );   /* black.        */
  SetRGB4( s_vp,  1, 0xF, 0xF, 0xF );   /* white.        */
  SetRGB4( s_vp,  2, 0xF, 0xF, 0x0 );   /* Light Yellow. */
  SetRGB4( s_vp,  3, 0xF, 0x3, 0x2 );   /* Red.          */
  SetRGB4( s_vp,  4, 0x5, 0x8, 0xD );   /* Med blue.     */
  SetRGB4( s_vp,  5, 0x9, 0xC, 0xF );   /* Light blue.   */
  SetRGB4( s_vp,  6, 0x9, 0xF, 0x9 );   /* light-green.  */
  SetRGB4( s_vp,  7, 0x4, 0x4, 0x4 );   /* Dark-grey.    */
  SetRGB4( s_vp,  8, 0x5, 0x5, 0x5 );   /* .........     */
  SetRGB4( s_vp,  9, 0x6, 0x6, 0x6 );   /* .........     */
  SetRGB4( s_vp,  10, 0x7, 0x7, 0x7 );  /* .........     */
  SetRGB4( s_vp,  11, 0x8, 0x8, 0x8 );  /* .........     */
  SetRGB4( s_vp,  12, 0x9, 0x9, 0x9 );  /* .........     */
  SetRGB4( s_vp,  13, 0xA, 0xA, 0xa );  /* .........     */
  SetRGB4( s_vp,  14, 0xB, 0xB, 0xB );  /* .........     */
  SetRGB4( s_vp,  15, 0xC, 0xC, 0xC );  /* Light-grey.   */

  SetDrMd( gfx_rp, JAM2);
  SetDrMd( g_rp, JAM2);
}

/* GFX WINDOW FUNCS. */
void gfx_TXT(s,x,y)  /* Simple text printing func. */
char *s;
{
  Move(gfx_rp,x,y);
  Text(gfx_rp,s,strlen(s));
}

void gfx_FPEN(p) /* Set front pen */
int p;
{
 SetAPen(gfx_rp,p);
}

void gfx_BPEN(p) /* Set back pen */
int p;
{
 SetBPen(gfx_rp,p);
}

/* G WINDOW FUNCS. */
void g_TXT(s,x,y)  /* Simple text printing func. */
char *s;
{
  Move(g_rp,x,y);
  Text(g_rp,s,strlen(s));
}

void g_FPEN(p) /* Set front pen */
int p;
{
 SetAPen(g_rp,p);
}

void g_BPEN(p) /* Set back pen */
int p;
{
 SetBPen(g_rp,p);
}

void Draw_RBOX()  /* Draw a box to put pools results in. */
{
  g_FPEN(10);
  g_BPEN(10);
  RectFill(g_rp, 2, RS_Y-30, 638, 253);  /* Result box.*/

  g_FPEN(0);
/* These make up an inside black border to box. */
  Move(g_rp, 30, RS_Y-20);
  Draw(g_rp, 30, RS_Y+60);     /* line bottom left side of wind.*/
  Move(g_rp, 610, RS_Y-20);
  Draw(g_rp, 610, RS_Y+60);    /* line bottom right side of wind.*/
  Move(g_rp, 30, RS_Y-20);
  Draw(g_rp, 610, RS_Y-20);    /* line at bottom edge of gads. */
  Move(g_rp, 30, RS_Y+60);
  Draw(g_rp, 610, RS_Y+60);    /* line near bottom of wind.*/

  g_TXT(" Results ",284, RS_Y-16); /* Box Title. */
  g_FPEN(5);
  g_BPEN(0);
  Move(g_rp, 0, RS_Y-31);
  Draw(g_rp, 640, RS_Y-31);    /* Add strip of light to top of box */

  Move(g_rp, 0, RS_Y-42);
  Draw(g_rp, 640, RS_Y-42);    /* Line underneath league Gads.*/
  g_FPEN(1);
  g_BPEN(10);
}

void Help() /* Simple help message. */
{
  RB_Msg("USE THE MOUSE TO INPUT FIXTURES FROM YOUR COUPON.",0);
  RB_Msg("THE 'Printer' GADGET SENDS EACH RESULT TO THE PRINTER WHEN IN",2);
  RB_Msg("THE 'ON' POSITION.",3);
  RB_Msg("THE 'Print-Heading' GADGET PRINTS THE POOLS HEADING, READY",4);
  RB_Msg("FOR THE RESULTS TO FOLLOW.(Only if 'printer' gad is 'ON')",5);
}

void RB_Msg(msg,line)  /* Print message in Result box area. */
char *msg;             /* line is 0-5. */
int line;
{
 int off=0;
          switch(line) {    /* Max of 6 lines to print on. */
                 case 0:
                        break;
                 case 1:
                        off = 10;
                        break;
                 case 2:
                        off = 20;
                        break;
                 case 3:
                        off = 30;
                        break;
                 case 4:
                        off = 40;
                        break;
                 case 5:
                        off = 50;
                        break;
                 default:
                        break;
                 }
 g_FPEN(1);
 g_BPEN(10);
 g_TXT(msg, RS_X, RS_Y+off);
}

void Clear_RBOX()     /* Clear the result box area.*/
{                     /* 6 lines.  */
int i;
    g_BPEN(10);
   for(i=0;i<68;i++)
    PR_BUF[i] = ' ';
    PR_BUF[i] = '\0';

    g_TXT(PR_BUF,RS_X,RS_Y);
    g_TXT(PR_BUF,RS_X,RS_Y+10);
    g_TXT(PR_BUF,RS_X,RS_Y+20);
    g_TXT(PR_BUF,RS_X,RS_Y+30); 
    g_TXT(PR_BUF,RS_X,RS_Y+40);
    g_TXT(PR_BUF,RS_X,RS_Y+50);
}

/********** END OF GRAPHICS FUNCTIONS **************/
