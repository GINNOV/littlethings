#ifndef HCE_GFX_H
#define HCE_GFX_H

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
 *    Defines and Prototypes for Hce_Gfx.c
 *
 */

/* NOTE:  '(CH)'  below = value can be changed.
 *         Some comments related to pen colours may be incorrect as
 *         pen colours are changed quite frequently.
 */

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#define s_vp   &my_screen->ViewPort
#define s_rp   &my_screen->RastPort
#define c_rp   my_window->RPort
#define g_rp   g_window->RPort
#define gfx_rp gfx_window->RPort

#define W_TOPEDGE     14   /* Where con window top edge is. (CH).  */
#define W_LEFTEDGE     1   /* Where con window left edge is. (CH). */
#define W_WIDTH      639   /* Width of con window. (CH).   */
#define W_HEIGHT     147   /* Height of con window. (CH).  */
#define S_WIDTH      641   /* Width of main screen. (CH).  */
#define S_HEIGHT     254   /* Height of main screen. (CH). */
#define S_DEPTH        4   /* Don`t lower this, Intuition uses the 1st 8, */
                           /* colours. We use mainly the last 8. */
#define MENU_LEFTEDGE  4   /* MenuItem,SubItem text`s left edge. (CH). */

#define XOFFSET   18       /* Console Window x offset. (CH). */
#define YOFFSET   16       /* Console Window y offset. (CH). */

/* Index values for 'penshop[3]' array. */
#define CON_PEN    0       /* console pen colour.  */
#define CON_PAPER  1       /* console paper colour.*/
#define CON_MARKER 2       /* console marking out colour.*/

/* Used by Console window ,Graphics window and Intuition stuff. (CH) */
#define HITEXT_PEN 5   /* Usually White. Used for Highlight/Text. */
#define BACK_PEN   6   /* Usually Black. General use. */

/* Pens used by graphics window. (gfx_window). (CH) */
#define MAIN_PEN   8   /* Usually Grey. Used in most scr areas(+menu bar)*/
#define HI_PEN     9   /* Usually Light Blue. Used to highlight some edges.*/
#define MID_PEN    4   /* Usually Yellow. Used to make some texts stand out*/
#define DIM_PEN    3   /* Usually Med Blue. General use. */

/* These position the Status bar, Gadget bar and Message box. (CH) */
#define STATBAR_W  639
#define STATBAR_H  11
#define STATBAR_X  1
#define STATBAR_Y  0
#define GADBAR_W   STATBAR_W
#define GADBAR_H   181
#define GADBAR_X   STATBAR_X
#define GADBAR_Y   161
#define GADBAR_SX (STATBAR_X+39)
#define MBOX_W     STATBAR_W
#define MBOX_H     251
#define MBOX_X     STATBAR_X
#define MBOX_Y     180
#define MB_OFF     13

/* These control where and how long a Message Box Message can be. (CH) */
#define MB_SX  (MBOX_X+20)   /* Message x start position. */
#define MB_SY  (MBOX_Y+22)   /* Message y start position. */
#define MB_MX   75           /* Max length of a message.  */

/* These decide where Free/Col/Line and Edit will apear on status bar. (CH)*/
#define FREE_X   40
#define COL_X    202
#define LIN_X    305
#define EDIT_X   430

/* Used by palette functions.*/
struct any_RGB {
                UBYTE red;
                UBYTE green;
                UBYTE blue;
};

extern struct any_RGB pref_c[8];       /* Keep, 1st 8 colours of palette. */
extern struct NewScreen my_new_screen; /* Main and only Screen. */
extern struct NewWindow my_new_win;    /* Console new window struct. */
extern struct NewWindow gfx_new_win;   /* Covers Scr and is used for gfx. */
extern struct NewWindow g_new_window;  /* General purpose shared window.  */
extern struct Window *my_window;       /* (Console Window)  */
extern struct Window *g_window;        /* (Shared Window)   */
extern struct Window *gfx_window;      /* (Graphics Window) */
extern struct Screen *my_screen;       /* (Screen)          */

/********** PROTOTYPES **********/

int Do_ReqV1(), Do_ReqV2();
void Do_ReqV3();
void expand_CW(),retract_CW(),Scr_to_Front(),Scr_to_Back(), Set1_RGB4();
void Set_Graphics(), Redraw_GFX(), Shadow_BOX(), gfx_FPEN(), gfx_BPEN();
void Show_W_STAT(), Add_CRight(), Hce_Credits(), Hcc_Credits();
void Show_Col(), Show_Line(), Show_Status(), Show_StatV2(), Show_StatV3();
void Clear_MBL(), Clear_MBox(), Show_StatOK(), Show_FreeMem();
void Show_CurEdit(), Show_Xmsg(), Show_Val();
char *str_Rmost();

#endif
