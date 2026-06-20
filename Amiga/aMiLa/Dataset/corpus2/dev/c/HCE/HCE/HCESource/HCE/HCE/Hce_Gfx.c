/* Copyright (c) 1994, by Jason Petty.
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
 * Hce_Gfx.c:
 *            Requester and Graphics related functions.
 *            Window, Screen, and other structures.
 *
 */

/*
 * note: some comments related to pen colours may be incorrect,
 *       pen colours are changed quite frequently.
 */

#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <exec/errors.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <devices/printer.h>
#include <graphics/gfxmacros.h>

#include <clib/stdio.h>
#include <clib/string.h>
#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"

/***************  Structure Definitions ***************/

chip struct NewScreen my_new_screen=
{
  0,            /* LeftEdge */
  0,            /* TopEdge  */
  S_WIDTH,
  S_HEIGHT,
  S_DEPTH,      /* Min = 4. (16 colours)*/
  HITEXT_PEN,   /* DetailPen.  */
  HI_PEN,       /* BlockPen.   */
  HIRES,        /* ViewModes.  */
  CUSTOMSCREEN,
  NULL,         /* Font.       */
  NULL,
  NULL,         /* Gadget.     */
  NULL          /* BitMap.     */
};

/* Console window.(goes on top of gfx_window) */
struct NewWindow my_new_win=
{
  W_LEFTEDGE, W_TOPEDGE,
  W_WIDTH, W_HEIGHT,
  MID_PEN,MAIN_PEN,                     /* Detailpen, Blockpen. */
  IDCMP_MENUPICK|IDCMP_ACTIVEWINDOW|IDCMP_INACTIVEWINDOW|
  IDCMP_NEWSIZE|IDCMP_MOUSEBUTTONS|IDCMP_MOUSEMOVE,
  WFLG_ACTIVATE|WFLG_GIMMEZEROZERO|WFLG_BORDERLESS|WFLG_REPORTMOUSE,
  NULL,                                 /* First gadget.    */
  NULL,                                 /* Image checkmark. */
  NULL,                                 /* Title.           */
  NULL,                                 /* Screen pointer.  */
  NULL,                                 /* Custom Bitmap.   */
  120,88,	                        /* Min W,H sizes.   */
  641,257,	                        /* Max W,H sizes.   */
  CUSTOMSCREEN                          /* Type.            */
};

/* Covers hole of screen and is used mainly for graphics. */
struct NewWindow gfx_new_win=
{
  0,1,
  S_WIDTH, S_HEIGHT-1,                  /* Use screen sizes!.   */
  MID_PEN,MAIN_PEN,	                /* Detailpen, Blockpen. */
  IDCMP_GADGETDOWN|IDCMP_GADGETUP,
  WFLG_ACTIVATE|WFLG_GIMMEZEROZERO|WFLG_BORDERLESS,
  NULL,                                 /* First gadget.    */
  NULL,                                 /* Image checkmark. */
  NULL,                                 /* Title.           */
  NULL,                                 /* Screen pointer.  */
  NULL,                                 /* Custom Bitmap.   */
  120,88,	                        /* Min W,H sizes.   */
  641,257,	                        /* Max W,H sizes.   */
  CUSTOMSCREEN                          /* Type.            */
};

/* This is a general purpose shared window. */
struct NewWindow g_new_window=
{
  0,             /* LeftEdge   */
  0,             /* TopEdge    */
  640,           /* Width      */
  200,           /* Height     */
  MID_PEN,MAIN_PEN,
  IDCMP_CLOSEWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP|IDCMP_ACTIVEWINDOW|
  IDCMP_MOUSEMOVE|IDCMP_RAWKEY,
  WFLG_SMART_REFRESH|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
  NULL,          /* FirstGadget */
  NULL,          /* CheckMark   */
  NULL,          /* Title.      */
  NULL,          /* Screen      */
  NULL,          /* BitMap      */
  20,            /* MinWidth    */
  20,            /* MinHeight   */
  641,           /* MaxWidth    */
  257,           /* MaxHeight   */
  CUSTOMSCREEN   /* Type        */
};

/* Keep a record of first 8 colours of palette. */
struct any_RGB pref_c[8];

struct Window *my_window=0;   /* (Console Window)  */
struct Window *g_window=0;    /* (Shared Window)   */
struct Window *gfx_window=0;  /* (Graphics Window) */
struct Screen *my_screen=0;   /* (Only Screen)     */


/******************** FUNCTIONS FROM HERE ***********************/

void Scr_to_Front()
{
 (void) ScreenToFront(my_screen);
}

void Scr_to_Back()
{
 (void) ScreenToBack(my_screen);
}

/* Expand console window to full size of screen. (V36-WB2.0) */
void expand_CW()
{
  (void)ChangeWindowBox(my_window,W_LEFTEDGE,W_TOPEDGE,
                        W_WIDTH,(S_HEIGHT-W_TOPEDGE)-5);
}

/* Put console window back to default size. Only if expand_CW() was called.*/
void retract_CW()
{
  (void)ChangeWindowBox(my_window,W_LEFTEDGE,W_TOPEDGE,W_WIDTH,W_HEIGHT);
}

int Do_ReqV1(string) /* Open an intuition requester which requires the */
char *string;        /* 'OK' gadget to be selected. */
{
  struct IntuiText it[2];
  int rv=0;

  it[0].FrontPen=0;      /* Body text. */
  it[0].BackPen=0;
  it[0].DrawMode=JAM1;
  it[0].LeftEdge=10;
  it[0].TopEdge=5;
  it[0].ITextFont=NULL;
  it[0].IText=(UBYTE *)string;
  it[0].NextText=NULL;

  it[1].FrontPen=0;      /* Middle gad text. 'OK'*/
  it[1].BackPen=0;
  it[1].DrawMode=JAM1;
  it[1].LeftEdge=0;
  it[1].TopEdge=2;
  it[1].ITextFont=NULL;
  it[1].IText=(UBYTE *)"OK";
  it[1].NextText=NULL;

  rv=AutoRequest(my_window, &it[0], NULL, &it[1], NULL, NULL, 0, 0);

  return(rv);
}

int Do_ReqV2(string) /* Open an intuition requester which requires yes or no*/
char *string;        /* information. 0=No,1=Yes. */
{
  struct IntuiText it[3];
  int rv=0;

  it[0].FrontPen=0;     /* Requester body text. */
  it[0].BackPen=0;
  it[0].DrawMode=JAM1;
  it[0].LeftEdge=10;
  it[0].TopEdge=5;
  it[0].ITextFont=NULL;
  it[0].IText=(UBYTE *)string;
  it[0].NextText=NULL;

  it[1].FrontPen=0;     /* Left side text. 'Yes'*/
  it[1].BackPen=0;
  it[1].DrawMode=JAM1;
  it[1].LeftEdge=5;
  it[1].TopEdge=2;
  it[1].ITextFont=NULL;
  it[1].IText=(UBYTE *)"Yes";
  it[1].NextText=NULL;

  it[2].FrontPen=0;     /* Right side text. 'No'*/
  it[2].BackPen=0;
  it[2].DrawMode=JAM1;
  it[2].LeftEdge = -5;
  it[2].TopEdge=2;
  it[2].ITextFont=NULL;
  it[2].IText=(UBYTE *)"No";
  it[2].NextText=NULL;

  rv=AutoRequest(my_window, &it[0], &it[1], &it[2], NULL, NULL, 0, 0);
  return(rv);
}

/* Call 'Do_ReqV1()' with 'sprintf()' type syntax.(max 1 'arg'). */
void Do_ReqV3(buf,fmt,arg)
char *buf,*fmt;
int arg;
{
  sprintf(buf,fmt,arg);
  Do_ReqV1(buf);
}

void Set_Graphics()  /* Called on startup. */
{
 /* Colours Generally used by Intuition. */
  SetRGB4( s_vp,  0, 0x9, 0x9, 0x9 );   /* Light Grey. W/Screen BGROUND.*/
  SetRGB4( s_vp,  1, 0x0, 0x0, 0x0 );   /* Black.    DARK EDGES.  */
  SetRGB4( s_vp,  2, 0xF, 0xF, 0xF );   /* White.    LIGHT EDGES. */
  SetRGB4( s_vp,  3, 0x4, 0x6, 0xA );   /* Med Blue. TITLE BARS.  */
  SetRGB4( s_vp,  7, 0xF, 0xF, 0xF );   /* White.    Menu Back HiLight.*/
  SetRGB4( s_vp,  10, 0x5, 0x7, 0xC );  /* Med Blue. Console Curs colour.*/
  SetRGB4( s_vp,  11, 0x4, 0x6, 0xA );  /* Med Blue. Menu text colour*/
  SetRGB4( s_vp,  12, 0xF, 0xF, 0x0 );  /* Yellow.   Menu Edges.     */
  SetRGB4( s_vp,  13, 0x0, 0x0, 0x0 );  /* Black.    Menu-Item,      */
                                        /*           HiLight text.   */
  SetRGB4( s_vp,  14, 0xF, 0xF, 0xF );  /* White.    Menu-Item,      */
                                        /*           HiLight backpen txt. */
  SetRGB4( s_vp,  15, 0x4, 0x6, 0xA );  /* Med blue. Menu Comseq HiLight. */

/* Used by us. */
  SetRGB4( s_vp,  4, 0xF, 0xF, 0x0 );   /* Yellow.     */
  SetRGB4( s_vp,  5, 0xF, 0xF, 0xF );   /* White.      */
  SetRGB4( s_vp,  6, 0x0, 0x0, 0x0 );   /* Black.      */
  SetRGB4( s_vp,  9, 0x9, 0xC, 0xF );   /* Light Blue. */

  /* NOTE: This colour reg does 2 jobs. */
  /* 1. INTUI Menu Back colour.*/
  /* 2. Main screen colouring. (msg box,status bar etc)*/
  SetRGB4( s_vp,  8, 0x8, 0x8, 0x8 );    /* Med Grey. */

/* KEEP A RECORD OF FIRST 8 COLOURS. */
  pref_c[0].red = 0x9;
  pref_c[0].green = 0x9;
  pref_c[0].blue = 0x9;
  pref_c[1].red = 0x0;
  pref_c[1].green = 0x0;
  pref_c[1].blue = 0x0;
  pref_c[2].red = 0xF;
  pref_c[2].green = 0xF;
  pref_c[2].blue = 0xF;
  pref_c[3].red = 0x4;
  pref_c[3].green = 0x6;
  pref_c[3].blue = 0xA;
  pref_c[4].red = 0xF;
  pref_c[4].green = 0xF;
  pref_c[4].blue = 0x0;
  pref_c[5].red = 0xF;
  pref_c[5].green = 0xF;
  pref_c[5].blue = 0xF;
  pref_c[6].red = 0x0;
  pref_c[6].green = 0x0;
  pref_c[6].blue = 0x0;
  pref_c[7].red = 0xF;
  pref_c[7].green = 0xF;
  pref_c[7].blue = 0xF;

  SetRast(gfx_rp, BACK_PEN); /* Set back ground Black. */
  SetDrMd(gfx_rp, JAM2);
  Redraw_GFX();
  Show_W_STAT(1);
}

/* Set a single R/G or B value of a colour. (See Hce_GadCtrl.c) */
/* Note: can only accept colours 0-7 with R.G.B values of 0-15.. */
void Set1_RGB4(colour,index,new_ic)
WORD colour,index;
UBYTE new_ic;
{
  switch(index) {
   case 0: /* Red. */
     SetRGB4(s_vp, colour,new_ic, pref_c[colour].green, pref_c[colour].blue);
     pref_c[colour].red = new_ic;
   break;
   case 1: /* Green. */
     SetRGB4(s_vp, colour,pref_c[colour].red, new_ic, pref_c[colour].blue);
     pref_c[colour].green = new_ic;
   break;
   case 2: /* Blue. */
     SetRGB4(s_vp, colour,pref_c[colour].red, pref_c[colour].green, new_ic);
     pref_c[colour].blue = new_ic;
   break;
   }
}

/* GRAPHICS LAYOUT: the following items cover the main graphics window */
/*                  and are what is seen when editor is first opened.  */
/*                  1. STATUS BAR.     */
/*                  2. CONSOLE WINDOW. */
/*                  3. GADGET BAR.     */
/*                  4. MESSAGE BOX.    */

void Redraw_GFX()  /* Draw/Redraw  - 'gfx_window' graphics. */
{
 WORD sx = (GADBAR_SX - 2);

/****** Status bar. *******/

   gfx_FPEN(MAIN_PEN);                  /* grey.  */
   gfx_BPEN(MAIN_PEN);
   RectFill(gfx_rp,STATBAR_X,STATBAR_Y,STATBAR_W,STATBAR_H);

   gfx_FPEN(MID_PEN);                   /* yellow.*/
   Move(gfx_rp, FREE_X, STATBAR_Y+8);   /* Free:  */
   Text(gfx_rp, "Free: ", 6);
   Move(gfx_rp, COL_X, STATBAR_Y+8);    /* Col:   */
   Text(gfx_rp, "Col:", 4);
   Move(gfx_rp, LIN_X, STATBAR_Y+8);    /* Line:  */
   Text(gfx_rp, "Line:", 5);
   Move(gfx_rp, EDIT_X, STATBAR_Y+8);   /* Edit:  */
   Text(gfx_rp, "Edit: ", 6);

   gfx_FPEN(HI_PEN);                    /* Light blue. */
   Move(gfx_rp,STATBAR_X,STATBAR_Y);
   Draw(gfx_rp,STATBAR_X,STATBAR_H);    /* Add strip of light to left side*/

/****** Gadget bar. *******/

   gfx_FPEN(MAIN_PEN);                 /* grey.  */
   RectFill(gfx_rp,GADBAR_X,GADBAR_Y,GADBAR_W,GADBAR_H);

  /* Draw a shadow border to outline the gadbar area. */
   Shadow_BOX(GADBAR_X+1,GADBAR_Y,GADBAR_W-2,18,HI_PEN,BACK_PEN);

  /* Create shadow effect round gadgets.*/

                                                           /* Test.   */
   Shadow_BOX(sx,GADBAR_Y+3,45,11,
               HI_PEN, BACK_PEN);
                                                           /* C+O+Assem.*/
   Shadow_BOX(set_GadX(&sx,32,14),GADBAR_Y+3,(200+13),11,
              HI_PEN,BACK_PEN);
                                                           /* C+O+A+Link*/
   Shadow_BOX(set_GadX(&sx,200,14),GADBAR_Y+3,(128+13),11,
              HI_PEN,BACK_PEN);
                                                           /* Link.   */
   Shadow_BOX(set_GadX(&sx,128,14),GADBAR_Y+3,(32+13),11,
              HI_PEN, BACK_PEN);
                                                           /* Run.    */    
   Shadow_BOX(set_GadX(&sx,32,14),GADBAR_Y+3,(24+13),11,
              HI_PEN,BACK_PEN);
                                                           /* Esc.    */
   Shadow_BOX(set_GadX(&sx,24,14),GADBAR_Y+3,(24+13),11,
              HI_PEN,BACK_PEN);
                                                           /* Cleanup.*/
   Shadow_BOX(set_GadX(&sx,24,14),GADBAR_Y+3,(56+13),11,
              HI_PEN,BACK_PEN);

  /* Active/Inactive simble box */
   Shadow_BOX(MB_OFF-3,GADBAR_Y+3,21,11,BACK_PEN,HI_PEN);

/****** Message box. *******/

   gfx_FPEN(MAIN_PEN);
   RectFill(gfx_rp, MBOX_X,MBOX_Y,MBOX_W,MBOX_H);

  /* Draw a border inside the message box to outline the message area. */
   Shadow_BOX(MB_OFF,MBOX_Y+7,(MBOX_W-(2*MB_OFF)),57,BACK_PEN,HI_PEN);

   gfx_BPEN(MAIN_PEN);
   gfx_FPEN(BACK_PEN);
   Move(gfx_rp, MB_SX+255, MBOX_Y+10);  /* Title to Message Box. */
   Text(gfx_rp, " Message ", 9);

   Show_StatOK(0);                      /* Normal Status. */
   Show_Col(ABS, LINE_X);               /* x curs pos. */
   Show_Line(ABS, LINE_Y);              /* y curs pos. */

   /* Redraw gadgets. */
   RefreshGList(gb_gadlist, gfx_window, NULL, -1); 
}

void Shadow_BOX(x,y,w,h,p1,p2) /* Draw an unfilled box with Left and Top */
int x,y,w,h,p1,p2;         /* sides one colour, and with Right and       */
{                          /* Bottom sides another colour. (gfx_window)  */
  SetDrMd( gfx_rp, JAM1);
  gfx_FPEN(p1);            /* Light Blue?. */
  Move(gfx_rp,x,y);
  Draw(gfx_rp,x,y+h);      /* Left side line. */
  Move(gfx_rp,x,y);
  Draw(gfx_rp,x+w,y);      /* Top line. */

  gfx_FPEN(p2);            /* Black?. */
  Move(gfx_rp,x+w,y);
  Draw(gfx_rp,x+w,y+h);    /* Right side line. */
  Move(gfx_rp,x,y+h);
  Draw(gfx_rp,x+w,y+h);    /* Bottom line. */

  SetDrMd( gfx_rp, JAM2);
}

void gfx_FPEN(p)   /* Set gfx_window front pen */
int p;
{
  SetAPen( gfx_rp, p);
}

void gfx_BPEN(p)   /* Backpen. */
int p;
{
  SetBPen( gfx_rp, p);
}

void Show_W_STAT(flg)  /* Show window Active/Inactive simble. (Gadget Bar)*/
int flg;
{
   gfx_BPEN(MAIN_PEN);     /* Grey. */
   Move(gfx_rp,MB_OFF+4,GADBAR_Y+11);

  if(flg)
      Text(gfx_rp,"A",1);  /* Active. */
     else
      Text(gfx_rp,"I",1);  /* Inactive. */

   gfx_BPEN(MAIN_PEN);     /* Reset Backpen to Default. (Light-Grey).*/
}

void Add_CRight(s,p) /* Copies p to s then appends CopyRight symbol. */
char *s,*p;
{
  int i;
  strcpy(s,p);
  i=strlen(s);
  s[i++] = 0xA9;     /* Copright symbol. */
  s[i] = '\0';
}

void Hce_Credits() /* Author. (Must keep within max of 5 lines/77 chars).*/
{
 int h = font_height+1;
 gfx_FPEN(HITEXT_PEN);
 gfx_BPEN(MAIN_PEN);

 Add_CRight(PR_OTHER,"    Hce Version 1.0 - ");
 strcat(PR_OTHER," Copyright 1994, by Jason Petty.");
 Show_Status(PR_OTHER);

 Show_StatV2(
 "    For Bugs/Comments please contact me at:   32 Balder Road, Norton,",2);

 Move(gfx_rp, MB_SX+369, MB_SY+(h*3));
 Text(gfx_rp,"Stockton-On-Tees,", 17);

 Show_StatV2(
 "                                              Cleveland. TS20 1BE.", 4);
}

void Hcc_Credits()   /* Compiler Authors. */
{
 gfx_FPEN(HITEXT_PEN);
 gfx_BPEN(MAIN_PEN);

 Add_CRight(PR_OTHER,"     Top - ");   /* Add Copyright symbol. */
 strcat(PR_OTHER," Copyright 1988-1991 by Sozobon Limited. Author J.Ruegg");
 Show_Status(PR_OTHER);

 Add_CRight(PR_OTHER,"     Hcc - ");
 strcat(PR_OTHER," Copyright 1988-1991 by Sozobon Limited. Author T.Andrews");
 Show_StatV2(PR_OTHER,1);

 Add_CRight(PR_OTHER,"     Top 2.0 - Amiga Version 1.1 ");
 strcat(PR_OTHER," Copyright 1991 by Detlef Wuerkner");
 Show_StatV2(PR_OTHER,3);

 Add_CRight(PR_OTHER,"     Hcc 2.0 - Amiga Version 1.1 ");
 strcat(PR_OTHER," Copyright 1991 by Detlef Wuerkner");
 Show_StatV2(PR_OTHER,4);
}

void Show_Col(op,c)        /* Show current LINE_X pos. (status bar)   */
int op,c;                  /* Used `TBuf[10]` intead of `TRep` as     */ 
{                          /* Other functions which use `TRep` may    */
  switch(op) {             /* call this.(causes wrong console output).*/ 
        case ABS: LINE_X = c;  break;
        case ADD: LINE_X += c; break;
        case SUB: LINE_X -= c; break;
    }
  if(LINE_X < 0)  LINE_X = 0;

                      /* LINE_X+1. Do not show Col 0. */
  itoa(LINE_X+1, TBuf, 10);
  strcat(TBuf," ");
  Move(gfx_rp, COL_X+40, STATBAR_Y+8);
  Text(gfx_rp, TBuf, strlen(TBuf));
}

void Show_Line(op,l)  /* Show current LINE_Y pos. (status bar)*/
int op,l;             /* Also uses `TBuf` same as `Show_Col`. */
{
  switch(op) {
        case ABS: LINE_Y = l;  break;
        case ADD: LINE_Y += l; break;
        case SUB: LINE_Y -= l; break;
    }
  if(LINE_Y < 0)  LINE_Y = 0;

            /* LINE_Y+1. Do not show Line 0. */
  itoa(LINE_Y+1, TBuf, 10);
  strcat(TBuf,"   ");
  Move(gfx_rp, LIN_X+50, STATBAR_Y+8);
  Text(gfx_rp, TBuf, strlen(TBuf));
}

void Show_Status(s)  /* Show current status of program. */
char *s;             /* (Messsage Box). (USE 'PR_OTHER' with this).   */
{
  char *p;
  int i;

  Clear_MBox();
  gfx_FPEN(HITEXT_PEN);
  i = strlen(s);

  Move(gfx_rp, MB_SX, MB_SY);
  
  if(i > MB_MX) {           /* If greater than max x go onto next line. */
     Text(gfx_rp, s, MB_MX);
     i -= MB_MX;
     p = str_Rmost(s,i);
     Move(gfx_rp, MB_SX, MB_SY + (font_height+1));
     Text(gfx_rp, p, strlen(p));
    }
  else {
        Text(gfx_rp, s, strlen(s));
        }
}

void Show_StatV2(s,l)  /* Same as Show_Status above except allows, */
char *s;               /* optional line numbers - 0 to 4.          */
int l;                 /* note: only clears line to be printed on. */
{
  int off=0;
  int h = font_height+1;
  int i;
  char *p;
  i = strlen(s);
  Clear_MBL(l);

  switch(l) {        /* Max of 5 lines to print on. (0-4) */
       case 0:
              break;
       case 1:
              off=h;
              break;
       case 2:
              off=(h*2);
              break;
       case 3:
              off=(h*3);
              break;
       case 4:
              off=(h*4);
              break;
       default:
              break;
      }

  gfx_FPEN(HITEXT_PEN);
  Move(gfx_rp, MB_SX, MB_SY+off);

  if(i > MB_MX ) {          /* If greater than max x go onto next line*/
        Text(gfx_rp, s, MB_MX);
     if(off >= (h*4))
        return;
        i -= MB_MX;
        p = str_Rmost(s,i);
        Move(gfx_rp, MB_SX, MB_SY + off + h);
        Text(gfx_rp, p, strlen(p));
    }
  else {
        Text(gfx_rp, s, strlen(s));
        }
}

void Show_StatV3(s,t)  /* Same as Show_Status except allows printf type */
char *s;               /* string formatting.   */
int t;                 /* note: use of PR_BUF. */
{
  char *p;
  int i;

  Clear_MBox();
  gfx_FPEN(HITEXT_PEN);

  sprintf(PR_BUF,s,t);
  i = strlen(PR_BUF);

  Move(gfx_rp, MB_SX, MB_SY);
  
  if(i > MB_MX) {           /* If greater than max x go onto next line. */
     Text(gfx_rp, PR_BUF, MB_MX);
     i -= MB_MX;
     p = str_Rmost(PR_BUF,i);
     Move(gfx_rp, MB_SX, MB_SY + (font_height+1));
     Text(gfx_rp, p, strlen(p));
    }
  else {      /* Length Ok */
        Text(gfx_rp, PR_BUF, strlen(PR_BUF));
        }
}

void Clear_MBL(l)  /* Clears a line in Msg Box. line depends on 'l'. (0-4)*/ 
int l;
{
 WORD i=0;

 while(i <= MB_MX)        /* Blank 'MB_MX' chars of PR_BUF. */
    PR_BUF[i++] = ' ';
    PR_BUF[i] = '\0';
 if(l)
    l *= (font_height+1);
    gfx_BPEN(MAIN_PEN);
    Move(gfx_rp, MB_SX, (MB_SY+l));
    Text(gfx_rp, PR_BUF, MB_MX);
}

void Clear_MBox()  /* Clear entire Message Box. (5 lines,0-4). */
{                  /* NOTE: Uses 'PR_BUF' */
 int i=0;

 while(i < 5)
       Clear_MBL(i++);
}

void Show_StatOK(stm)   /* Does optional delay & shows normal Status.       */
int stm;                /* Also always shows Free mem and current file edit.*/
{
  if(stm) {
    Delay(stm);
    Show_Status("OK...");   /* Normal status. */
    }
    gfx_FPEN(HITEXT_PEN);   /* white?.*/
    Show_FreeMem();
    Show_CurEdit();
}

void Show_FreeMem()   /* Shows current amount of free memory.(status bar). */
{
  ltoa( TotalMemB(), TBuf, 10);
  Move(gfx_rp, FREE_X+48, STATBAR_Y+8); /* Blank last. */
  Text(gfx_rp,"          ",10);
  Move(gfx_rp, FREE_X+48, STATBAR_Y+8); /* Show new. */
  Text(gfx_rp, TBuf, strlen(TBuf));
}

char *str_Rmost(s,len)  /* Return pointer to right most part of string, */
char *s;                /* inword from size len. */
int len;
{
  return((s += (strlen(s)-len)));
}

void Show_CurEdit()   /* Show Current file - Edit. (status bar). */
{
 char *s;
  Move(gfx_rp, EDIT_X+48, STATBAR_Y+8);
  Text(gfx_rp, "                   ", 19);
  Move(gfx_rp, EDIT_X+48, STATBAR_Y+8);

 if(IO_FileName[0] != '\0') {
     if(strlen(IO_FileName) > 19) {       /* To big to fit in space? */
             s = str_Rmost(IO_FileName,19);
             Text(gfx_rp, s, strlen(s));
        } else {
               Text(gfx_rp, IO_FileName, strlen(IO_FileName)); /* Ok! */
              }
  } else {
          Text(gfx_rp, "(Untitled)",10);  /* Dummy Heading. */
          }
}

void Show_Xmsg(s,x)  /* Show in msg box on line 0 at x pos, *s */
char *s;             /* note: 'x' is a char position not a window coord. */
int x;
{
  x = x * (font_width);
  gfx_FPEN(HITEXT_PEN);
  Move(gfx_rp, MB_SX+x, MB_SY);
  Text(gfx_rp, s, strlen(s));
}

void Show_Val(l,x,y) /* Show in msg box on line y at x pos, val l. */
ULONG l;             /* note: 'x,y' are char positions not window coords.*/
int x,y;
{
    gfx_FPEN(HITEXT_PEN);
    ltoa(l, TBuf, 10);

    x *= (font_width);
    y *= (font_height+1);

    Move(gfx_rp, MB_SX+x, MB_SY+y);
    Text(gfx_rp, "               ", 15);

    Move(gfx_rp, MB_SX+x, MB_SY+y);
    Text(gfx_rp, TBuf, strlen(TBuf));
}
