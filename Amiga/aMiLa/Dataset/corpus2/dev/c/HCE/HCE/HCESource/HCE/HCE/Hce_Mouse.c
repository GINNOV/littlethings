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
 * Hce_Mouse.c:
 *             Mouse-Cursor control.
 *             Position cursor with mouse.
 *             Mark out with mouse.
 */

#include <intuition/intuition.h>
#include <clib/stdio.h>
#include <clib/string.h>
#include <clib/ctype.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"
#include "Hce_Block.h"

void Mouse_MARK(m)       /* Control marking out of 'BLOCK' with Mouse. */
struct IntuiMessage *m;
{
  WORD xpos,ypos,tmax,bmax;

 if(!Mouse_LEGAL(m))     /* Mouse not far enough inside console window.?*/
   return;

   xpos = Get_X_MOUSE(m->MouseX);   /* New x curs pos. */
   ypos = Get_Y_MOUSE(m->MouseY);   /* New y curs pos. */

/**** DEBUG ******
   printf("xpos = %d, ypos = %d\n", xpos, ypos);
******************/

 if((ypos > CURS_Y) || (m->MouseY >= Get_WY_MAX())) /* Mouse moved down. */
   {
    if(m->MouseY >= Get_WY_MAX()) { /* Bottom of win but not bottom of file*/
       do {                         /* so mark while MouseY >= ?. */
             Mouse_CDOWN(xpos);
           } while(my_window->MouseY >= Get_WY_MAX());
       }
      else                          /* Normal downword marking. */
           Mouse_CDOWN(xpos);
    }
  else                        /* Moved Up. */
    {
    if((LINE_Y && (ypos < CURS_Y )) || (LINE_Y && m->MouseY <= 2))
        {
           if(m->MouseY <= 2) {    /* Top of win but not top of file, */
               do {                /* so mark while MouseY <= 2. */
                     Mouse_CUP(xpos);
                   } while(LINE_Y && my_window->MouseY <= 2);
             }
             else                  /* Normal upword marking. */
                  Mouse_CUP(xpos);
         }
        else {
              if(xpos > LINE_X)     /* Moved Right. */
                 {
                  Mouse_CRIGHT();
                  }
                else 
                  {
                   if(xpos < LINE_X) {    /* Moved Left. */
                      Mouse_CLEFT();
                      }
                   }
              }
     }
}

void Mouse_CUP(xpos) /* Control Upword marking of BLOCK with Mouse*/
int xpos;
{
 int i,ly;
 ly = LINE_Y;

 if(LINE_Y < blk_SY) {       /* 'BLOCK[][]' buffer full?. */
    if((blk_SY - LINE_Y) > (B_MAXLINE-4)) {
       Show_StatV3("Block buffer is full - (Max %d lines)",B_MAXLINE-2);
       return;
       }
  }

    i=Get_SLEN((ly-1));
    
 if(xpos > i)    /* Keep curs within last char of line. */
      LINE_X=i;
    else
      LINE_X=xpos;

  if(!(c_LEGAL_TY()))                     /* Top of Wind ,scroll print. */
      {
         c_Command('T');                  /* Scroll text down 1. */
         CURS_Y++;
     if(ly <= blk_SY)                     /* Highlight cur/prev line. */
         HD_LINE(ly,CON_MARKER,ALL_UP);
       else
         HD_LINE(ly,CON_PAPER,ALL_UP);    /* Dehighlight cur/prev line.*/
         CURS_Y--;
       }
     else {
            if(ly <= blk_SY)
               HD_LINE(ly,CON_MARKER,ALL_UP);
             else
               HD_LINE(ly,CON_PAPER,ALL_UP);
               CURS_Y--;
           }
     c_PlaceCURS(LINE_X, CURS_Y);
    Show_Line(SUB,1);              /* Show set LINE_Y-1. */
  Show_Col(ABS, LINE_X);
}

void Mouse_CDOWN(xpos)   /* Down.. */
int xpos;
{
  int i,ly;
  ly = LINE_Y;

 if(LINE_Y > blk_SY) {       /* 'BLOCK[][]' buffer full?. */
    if((LINE_Y - blk_SY) > (B_MAXLINE-4)) {
       Show_StatV3("Block buffer is full - (Max %d lines)",B_MAXLINE-2);
       return;
     }
  }

  i=Get_SLEN(ly+1);

 if(LINE[ly+1][0] == '\0')      /* Line does not exist yet.? */
    return;
 if(xpos > i)
    LINE_X=i;
   else
    LINE_X=xpos;

    if(!(c_LEGAL_BY())) {     /* Bottom of Wind, scroll print. */
                c_Command('S');
                CURS_Y--;
            if(ly >= blk_SY)
                HD_LINE(ly, CON_MARKER, ALL_DOWN);  /* H. cur/next line. */
             else
                HD_LINE(ly, CON_PAPER, ALL_DOWN);   /* D. cur/next line. */
                CURS_Y++;
          }
        else {
             if(ly >= blk_SY)
                   HD_LINE(ly, CON_MARKER, ALL_DOWN);
                else
                   HD_LINE(ly, CON_PAPER, ALL_DOWN);
               CURS_Y++;
              }

  c_PlaceCURS(LINE_X, CURS_Y);
  Show_Line(ADD,1);       /* Show set LINE_Y+1.*/
  Show_Col(ABS,LINE_X);
}

void Mouse_CRIGHT()  /* Right.. */
{
 int ly,lx;
 ly = LINE_Y;
 lx = LINE_X;

  if((LINE[ly][lx] != '\n') && (LINE[ly][lx] != '\0') && (c_LEGAL_RX()))
     {
         HD_LINE(ly,NULL,RIGHT);  /* H/D. char. */
         c_MoveCURS(RIGHT,1);
         Show_Col(ADD,1);         /* Show/Set LINE_X+1*/
      }
}

void Mouse_CLEFT()  /* Left.. */
{
    if(LINE_X)
     {
      HD_LINE(LINE_Y,NULL,LEFT); /* H/D. char. */
      c_MoveCURS(LEFT,1);
      Show_Col(SUB,1);
      }
}

/* Get the second last pixel position of the last line available in the */
/* Console window. (aids scrolling of window with mouse). */
WORD Get_WY_MAX()
{
 WORD y;
   y = (my_window->Height % font_height);
   return((my_window->Height - ++y));
}

WORD Get_X_MOUSE(x) /* Work out Cursor x position from x mouse coords. */
WORD x;             /* Do not return value less than 0. */
{
 WORD i,r;

   i = (my_window->Width % font_width);
   r = (((my_window->Width) - (x+i)) / font_width);
   i = c_ConCols();

 return( ( ((i-r) < 0) ? 0 : (i-r) ) );
}

WORD Get_Y_MOUSE(y) /* Work out Cursor y position from y mouse coords. */
WORD y;             /* Do not return value less than 0. */
{
 WORD i,r;

   i = (my_window->Height % font_height);
   r = (((my_window->Height) - (y+i)) / font_height);
   i = c_ConRows();

 return( ( ((i-r) < 0) ? 0 : (i-r) ) );
}

void Place_MCURS(m)      /* Place cursor to new x/y mouse pointer */
struct IntuiMessage *m;  /* coords in the console window. */
{
   int i,ly,cy;
   WORD xpos,ypos;

   ly = LINE_Y;
   cy = CURS_Y;

   xpos = Get_X_MOUSE(m->MouseX);  /* New x curs pos. */
   ypos = Get_Y_MOUSE(m->MouseY);  /* New y curs pos. */

/* Get 'LINE[y][]' position by using old/new curs positions. */

   if(ypos > CURS_Y) {             /* If new curs pos greater than old. */
       ly += (ypos-CURS_Y);
    } else {                       /* If old curs pos greater than new. */
            if(CURS_Y > ypos) {
               ly -= (CURS_Y-ypos);
               }
           }

      i = Buf_Used();          /* Lines used in 'LINE[][]' */

    if(ly > i) {               /* New line position does not exist yet?. */
       ly = i;                 /* So use last line available. */
       CURS_Y += (ly-LINE_Y);
      }
     else {            /* New line pos ok, so just need set new curs pos.*/
            CURS_Y = ypos;
           }

       i=Get_SLEN(ly);

    if(xpos > i)       /* Keep within max chars used in new line. */
       xpos = i;

     c_PlaceCURS(xpos,CURS_Y);
       Show_Line(ABS,ly);
       Show_Col(ABS,xpos);
}

WORD Mouse_DIF(m,x,y,dif) /* Check if new mouse coords greater or lesser */
struct IntuiMessage *m;   /* than old coords by at least 'dif' size. */
WORD x,y;
int dif;
{
 WORD rv=0;

   if(m->MouseX > x) {         /* Mouse moved left.? */
      if((m->MouseX-x) > dif)
          rv++;
      }
   if(m->MouseX < x) {         /* Mouse moved right.? */
      if((x-m->MouseX) > dif)
          rv++;
      }
   if(m->MouseY > y) {         /* Mouse moved down.? */
      if((m->MouseY-y) > dif)
          rv++;
      }
   if(m->MouseY < y) {         /* Mouse moved up.? */
      if((y-m->MouseY) > dif)
          rv++;
      }
return(rv);
}

WORD Mouse_LEGAL(m)     /* Check mouse pointer is inside console window. */
struct IntuiMessage *m; /* TRUE=OK,FALSE=OUTSIDE. */
{
 if((m->MouseX >= 1) && (m->MouseX < my_window->Width-1))
    if((m->MouseY >= 1) && (m->MouseY < my_window->Height-1))
         return(TRUE);
return(FALSE);
}
