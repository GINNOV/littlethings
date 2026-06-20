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
 * Hce_Block.c:
 *             Block menu functions. (Hce_MenuCtrl.c)
 *
 */

#include <clib/string.h>
#include <clib/stdio.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_Block.h"

char BLOCK[B_MAXLINE][T_LINELEN];  /* Block buffer. */
int BLOCK_ON = FALSE;              /* Block status. */
int MOUSE_MARKED = FALSE;          /* Block status. */

/* Block. (keep size/start and end positions) */
int blk_SY;
int blk_EY;
int blk_SX;
int blk_EX;


int Get_BSLEN(cy)   /* Get string length from 'BLOCK' at line cy. */
int cy;
{
 char *p;
 int l=0;
    p = BLOCK[cy];
 while((*p != '\n') && (*p++ != '\0'))  /* get line len. */
        l++;
 return (l);
}

void TEXT_UL(flg)  /* Make single line of marked text upper/lower case. */
WORD flg;          /* (flg=1; upper). */
{
  int l;
  WORD lx;

  lx = (blk_SX > LINE_X) ? (blk_SX-LINE_X)+1 : (LINE_X-blk_SX);

  if(blk_SY==LINE_Y && lx) {    /* Allow only one line to be effected. */
      c_BPen(penshop[CON_MARKER]);
      c_CursOff();
                l = (blk_SX < LINE_X) ? (blk_SX) : (LINE_X);
                c_PlaceCURS(l, CURS_Y);
         while((lx--) && (LINE[blk_SY][l] != '\n')) {
             if(flg)
                LINE[blk_SY][l] = toupper(LINE[blk_SY][l]);
              else
                LINE[blk_SY][l] = tolower(LINE[blk_SY][l]);

                writechar(LINE[blk_SY][l++]);
                }
      c_PlaceCURS(LINE_X, CURS_Y);
    }
}

void Clear_Block()  /* Clear the block buffer. */
{
 int i = 0;
 while(i <= (B_MAXLINE-1))
   BLOCK[i++][0] = '\0';
}

void B_Start()  /* Block start. */
{
  if(!BLOCK_ON) {
   blk_SY = LINE_Y;
   blk_SX = LINE_X;
   BLOCK_ON = TRUE;
   c_BPen(penshop[CON_MARKER]);
   }
}

void B_End()    /* Block end. */
{
  blk_EY = LINE_Y;
  blk_EX = LINE_X;
  c_BPen(penshop[CON_PAPER]);
}

void Check_MMARK()    /* Marked out BLOCK with Mouse,*/
{                     /* but never Cut/Copy. */
  if(MOUSE_MARKED)
     B_Hide();
}

void Check_KMARK()    /* Same as Check_MMARK except marked out */
{                     /* with keys. */
  if(BLOCK_ON)
     B_Hide();
}

void B_Hide()   /* Block Hide. */
{
   B_End();
   FixDisplay();
   c_PlaceCURS(LINE_X, CURS_Y);
   Show_Status("Block - Hidden...");
   BLOCK_ON = FALSE;
   MOUSE_MARKED = FALSE;
}

int B_Copy()          /* Block Copy. */
{                     /* Returns 0 on error else 1. */
  int sy,ey,i,b,r;

 if( blk_SY == blk_EY ) /* May only be one line!. */
 {
   if(blk_SX == blk_EX) {
      Show_Status("Need to mark out ,before - Cut/Copy!");
      return(0);
      }
      Clear_Block();                              /* Empty 'BLOCK[][]'  */
      i = (blk_SX < blk_EX) ? blk_SX : blk_EX;    /* Start char pos.    */
      r = (i == blk_SX) ? blk_EX-1 : blk_SX;      /* End char pos.      */
      str_be_cpy(BLOCK[0],LINE[blk_SY],i,r);      /* Get 'BLOCK' line 0.*/
      BLOCK[1][0] = '\0'; /* set end. */
   }
 else     /* More than one line. */
  {
    Clear_Block();

    /* Get first line first. */
    i = (blk_SY < blk_EY) ? blk_SX : blk_EX;   /* start char pos. */
    r = (blk_SY < blk_EY) ? blk_SY : blk_EY;   /* start line pos. */
    str_n_cpy(BLOCK[0],LINE[r],i);             /* Get 'BLOCK' line 0.*/

    sy = blk_SY;
    b = 1;              /* start at BLOCK line 1. */

   if(blk_SY < blk_EY)  /* Was normaly marked!!. */
     {
        sy++;           /* Pass first line.       */
                        /* Get normaly marked Block-Body. */
        do {
             strcpy(BLOCK[b],LINE[sy]);
            }
       while(sy++ < blk_EY && b++ < B_MAXLINE-3);

     if(blk_EX)    /* Last line not marked, don`t put anything in BLOCK. */ 
          str_be_cpy(BLOCK[b++],LINE[blk_EY],0,blk_EX-1);
      }
     else  /* Was marked in reverse!!. */
       {
            ey = blk_EY+1;  /* 'ey' becomes start line. */

            /* Get reverse marked Block-Body. */
        do {
            strcpy(BLOCK[b],LINE[ey]);
            }
       while(ey++ < blk_SY && b++ < B_MAXLINE-3); /* Must!! be B_MAXLINE'-3'*/

     if(blk_SX)   /* Last line not marked, don`t put anything in BLOCK. */ 
          str_be_cpy(BLOCK[b++],LINE[blk_SY],0,blk_SX);
        }
     BLOCK[b][0] = '\0'; /* Set end mark!. */
    }
  i=0;
/********** Debug Only ***************
  while(BLOCK[i][0] != '\0') {
       printf("%d: %s",i, BLOCK[i]);
       i++;
       }
**************************************/
return(1); /* OK! */
}

void Shift_UPV2(ly,n)   /* Shift all lines in buf up by 'n' lines. */
int ly,n;               /* Starting from line ly.  */
{
  register int i,r;
  i=ly;
  r=(ly+n);

       while(LINE[r][0])     /* Copy from (ly+n)++ to ly++. */
               {
                strcpy(LINE[i++], LINE[r++]);
                }
       while(LINE[i][0])     /* Blank unwanted characters. */
               {
                LINE[i++][0] = '\0';
                }
}

int B_Cut()   /* Block Cut. */
{             /* Returns 0 on error else 1. */
  int i,b;

      if(blk_SY == blk_EY) /* Cut down single line?. */
         {                 /* Deals with normal and reversed marked line.*/
        if(blk_SX == blk_EX) {
          Show_Status("Need to mark out ,before - Cut/Copy!");
          return(0);
          }
          i = (blk_SX < blk_EX) ? blk_SX : blk_EX;    /* Start char pos. */
          b = (i == blk_SX) ? blk_EX : blk_SX+1;      /* End char pos.   */

          str_n_cpy(PR_BUF,LINE[blk_SY], b);  /* Copy end part of blk_SY.*/
          str_n_add(LINE[blk_SY],PR_BUF, i);  /* Reposition it back on.  */

          HL_AllLine(blk_SY,CURS_Y,CON_PAPER); /* Print reduced line,  */
                                               /* and remove highlight.*/
          Show_Col(ABS, i);                    /* Show/Set LINE_X.    */
          }
     else
      {
        if(blk_SY < blk_EY)  /* Marked Normally. (more than 1 line) */
          {
              i = blk_SY;
              b = i;                          /* b = where body starts.  */
            if(blk_SX) {      /* If first line not marked don`t Inc i,b. */
              LINE[blk_SY][blk_SX] = '\n';    /* Cut down first line.    */
              LINE[blk_SY][blk_SX+1] = '\0';  /* Reset end for 1st line. */
              i++;                            /* Inc i,b */
              b++;
              }
          if(blk_EX) {  /* If end line was marked! cut it in advance. */
               str_n_cpy(PR_BUF, LINE[blk_EY], blk_EX); /* Cut end part  */
               strcpy(LINE[blk_EY],PR_BUF);             /* Reposition it.*/
               }
                                         /* Now deal with block body.   */
               Shift_UPV2(b,(blk_EY-i)); /* Remove body lines.('LINE'). */

               i = (blk_EY - blk_SY);
            if(i <= c_ConRows()) {       /* Reset cursor&line pos. */
               CURS_Y = ((CURS_Y - i) < 0) ? 0 : (CURS_Y - i);
               Show_Line(ABS, blk_SY);
               }
             else {  /* Block cut was bigger than wind size.*/
                  i = blk_SY;
                  CURS_Y = 0;
                Show_Line(ABS, i);           /* Show/Set Line: */
               }
             Show_Col(ABS, 0) ;              /* Show/Set Col:  */
           }
        if(blk_EY < blk_SY)  /* Marked In Reverse!!. (more than 1 line) */
          {
              i = blk_EY;    /* End y now becomes start y!. */
              b = i;
            if(blk_EX) {     /* If first line not marked don`t Inc i,b. */
              LINE[blk_EY][blk_EX] = '\n';    /* Cut down first line.    */
              LINE[blk_EY][blk_EX+1] = '\0';  /* Reset end for 1st line. */
              i++;                            /* Inc i,b. */
              b++;
              }
          if(blk_SX) {    /* If end line was marked! cut it in advance. */
              str_n_cpy(PR_BUF,LINE[blk_SY], blk_SX+1); /* Copy end part  */
              strcpy(LINE[blk_SY],PR_BUF);              /* Reposition it. */
              }
                                        /* Now deal with block body.   */
              Shift_UPV2(b,(blk_SY-i)); /* Remove body lines.('LINE'). */

               i = (blk_SY - blk_EY);
            if(i <= c_ConRows()) {      /* Reset cursor&line pos. */
               Show_Line(ABS, blk_EY);
               }
             else {                 /* Block cut was bigger than wind size.*/
                   i = blk_EY;
                   CURS_Y = 0;
                Show_Line(ABS, i);  /* Show/Set Line: */
               }
             Show_Col(ABS, 0) ;     /* Show/Set Col:  */
           }
        FixDisplay();
       }
   c_PlaceCURS(LINE_X, CURS_Y);    /* Reposition curs. */
return(1);   /* OK! */
}

void Shift_DOWNV2(ly,n)  /* Shift all lines in buf down by 'n' lines. */
int ly,n;                /* Starting from line ly. */
{                        /* 'n' must be at least 1.*/
  register int r,i;

       r=0;
       while(LINE[r][0])         /* Count used lines. */
             r++;
       i=r;
       r += n;
       while(i >= ly)            /* Copy from lines used to lines used + n.*/
            {
             strcpy(LINE[r--], LINE[i--]);
             }
       while(r >= ly)
            {
             LINE[r][0] = '\n';  /* Declare new lines available. */
             LINE[r--][1] = '\0';
             }
}

void B_Insert()      /* Insert any size block. */
{
 int r,b;
 int ly = LINE_Y;
 int lx = LINE_X;

   if(BLOCK[0][0] == '\0') {
      Show_Status("Block buffer is empty!");
      return;
      }

     b = Buf_Used();
     r = 0;
     while(BLOCK[r][0]) /* Get number of lines in BLOCK */
          r++;

   if((b+r) >= (T_MAXLINE-2)) {   /* No space to Insert. */
      Show_StatV3("Block won`t fit in text buffer! - (Max %d lines)",
                (T_MAXLINE-2));
      return;
      }

   if(!BLOCK[1][0])    /* May only be one line to Insert!. */
    {
        if(!LINE_X && ly < T_MAXLINE-2) {  /* Use blank line. */
           Shift_DOWNV2(ly,1);             /* Get blank line. */
           c_Command('L');                 /* Insert. */
           }
        if(!str_insert(BLOCK[0], lx, ly)) {  /* Insert BLOCK[0] in, */
           if(!c_LEGAL_BY()) {               /* LINE[ly] from 'lx'. */
                 c_Command('S');
                 CURS_Y--;
                 c_PlaceCURS(0, CURS_Y);
                 }                       /* If here ,went onto new line. */
               Print_LINE(ly);           /* Now need to print 2 lines.   */
               writechar((long)'\n');
               c_Command('L');
               Print_LINE(ly+1);
           } else {             /* Only used single line. */
                   Print_LINE(ly);
                   }
      c_PlaceCURS(LINE_X, CURS_Y);
     }
  else    /* More than one line to Insert. */
   {
     Shift_DOWNV2(ly,r);   /* Make new lines */
     r=0;
     while(BLOCK[r][0] && (r < B_MAXLINE-3))
          {                                /* Add as much of */
           strcpy(LINE[ly++],BLOCK[r++]);  /* BLOCK to LINE as possible.*/
         if(c_LEGAL_BY())
            CURS_Y++;
           }
         Show_Line(ABS, ly);
        Show_Col(ABS, 0);
      FixDisplay();
    c_PlaceCURS(LINE_X, CURS_Y);
   }
  Show_Status("Block Inserted...");
}

void B_Print() /* Send all lines in 'BLOCK' to the Printer. */
{              /* Uses workbench printer preferences, and   */
 BYTE err;     /* will look for the correct printer driver. */
 int i=0;

 if(BLOCK[0][0] == '\0') {
     Show_Status("Block buffer is empty!");
     return;
     }
 if(!Do_ReqV2("Print Block - Sure?"))
     return;

 if(BLOCK[0][0] == '\0') {
    Show_Status("Unable to Print - Block buffer is Empty!!");
   } else {
           Show_Status("Printing Block...");

            while(BLOCK[i][0] != '\0' && i < B_MAXLINE-3) {
                 err = (BYTE)DO_PrtText(BLOCK[i++]);
                 if(err) {
                  PrtError(err);  /* Show appropriate error message, */
                  return;         /* in message box. */
                  }
              }
            Show_StatOK(MIN_DELAY);
           }
}

/************** BLOCK MARKING FUNCTIONS ****************/

void High_LIGHT(ly,cy,x1,x2)   /* Highlight line 'ln' from 'x1' to x2, */
int ly,cy,x1,x2;               /* ly = line, cy = y curs. */
{                              /* Used by HD_LINE().      */
    register char *p,*z;

/* First, print line 'ly' in none highlited colours. */
    c_PlaceCURS(0, cy);
    c_BPen(penshop[CON_PAPER]);
    c_Command('K');
    Print_LINE(ly);

/* If x2 >= max columns, must erase to E.O.L with mark out colour. */
    c_PlaceCURS(x1, cy);
   if(x2 >= c_ConCols()-1) {
       c_WindColor(penshop[CON_MARKER]);
       c_Command('K');
       c_WindColor(penshop[CON_PAPER]);
       }
/* Then Highlight from 'x1' to 'x2'.*/
    c_BPen(penshop[CON_MARKER]);
    z=PR_BUF;
    p=LINE[ly];
    p += x1;
               while((*p != '\n') && (x1++ <= x2) && *p)
                      *z++ = *p++;
               while(x1++ < x2)
                      *z++ = ' ';
                      *z = '\0';
    nprint(PR_BUF);
}

/* Highlight/Dehighlight hole lines. Used by HD_LINE() and B_Cut().*/
void HL_AllLine(ly,cy,pen)
int ly,cy,pen;
{
       c_PlaceCURS(0, cy);
       c_BPen(penshop[pen]);
       c_WindColor(penshop[pen]);
       c_Command('K');
       c_WindColor(penshop[CON_PAPER]);
       Print_LINE(ly);
}

void HD_LINE(ly,pen,flg)  /* Show Highlighted/Dehighlighted line (or char),*/
int ly,pen,flg;           /* depending on flg, pen and XY positions.       */
{
  int i,r,l;
  int lx = LINE_X;
  int cy = CURS_Y;
  char *c;

  r = c_ConCols()-1;
  i = Get_SLEN((ly-1));
  c_BPen(penshop[CON_MARKER]);
  c_CursOff();

  switch(flg)
  {
      case RIGHT:         /* Cursor is moving right 1 place. */
             if((ly==blk_SY && lx < blk_SX) || (ly < blk_SY)) {
                      c_BPen(penshop[CON_PAPER]); /* Dehighlight? */
                      }
                      writechar((long)LINE[ly][lx]);
               break;
      case LEFT:          /* Cursor is moving left 1 place. */
                if((ly==blk_SY && lx > blk_SX) || (ly > blk_SY)) {
                      c_BPen(penshop[CON_PAPER]);
                      }
                if(LINE[ly][lx] == '\n')
                      writechar((long)8); /* must backspace. */
                    else
                      writechar((long)LINE[ly][lx]);
               break;
     case ALL_UP:      /* Straight up. (UP arrow key). */
             /* Deal with current line. */
                if(ly == blk_SY)       /* Highlight. 0 to blk_SX, */
                 {                     /* if block start line. */
                    if(blk_SX)
                       High_LIGHT(ly,cy,0,blk_SX);
                  }
                if(!(ly == blk_SY))    /* H/D all line, if not start line. */
                 {
                  HL_AllLine(ly,cy,pen);
                 }
             /* Prev line. */
              if((ly-1) == blk_SY && c_LEGAL_TY()) /* Prev line is block */
                {                                  /* start line.*/
                 if(LINE_X > blk_SX) {             /* H. x to x. */
                     High_LIGHT((ly-1),(cy-1),blk_SX,LINE_X);
                     }
                   else {   /* marked in reverse order. */
                     High_LIGHT((ly-1),(cy-1),LINE_X,blk_SX);
                     }
                 }
               if((ly-1) < blk_SY)  /* Above blk_SY moving upwind. */
                 {                  /* H. ly-1 from x to r. */
                   High_LIGHT((ly-1),(cy-1),LINE_X,r);
                  }
               if((ly-1) > blk_SY)  /* Below blk_SY moving upwind. */
                 {                  /* H. ly-1 from 0 to x. */     
                   High_LIGHT((ly-1),(cy-1),0,LINE_X);
                  }
               break;
     case ALL_DOWN:
            /* Deal with current line. */
            if(ly == blk_SY)            /* H. blk_SX to (i-r), */
               {                        /* if block start line.*/
                High_LIGHT(ly,cy,blk_SX,r);
                }
            if(!(ly == blk_SY))         /* H/D all line,if not start line.*/
               {
                HL_AllLine(ly,cy,pen);
                }
            /* next line. */
              if((ly+1) == blk_SY)      /* Next line is block */
                {                       /* start line. */
                if(LINE_X > blk_SX) {   /* H. x to x.  */
                     High_LIGHT((ly+1),(cy+1),blk_SX,LINE_X);
                     }
                   else {  /* marked in reverse order. */
                     High_LIGHT((ly+1),(cy+1),LINE_X, blk_SX);
                     }
                 }
               if((ly+1) < blk_SY)    /* Above blk_SY moving down wind. */
                 {                    /* H. ly+1 from x to r. */
                  High_LIGHT((ly+1),(cy+1),LINE_X,r);
                 }
               if((ly+1) > blk_SY)    /* Below blk_SY moving down wind. */
                 {                    /* H. ly+1 from 0 to x. */
                  High_LIGHT((ly+1),(cy+1),0,LINE_X);
                 }
               break;
     case ALL_LUP:       /* H/D - Cur/Prev line. (Left Arrow Key). */
              /* Deal with current line. */
              if(!(ly == blk_SY))  /* H/D all line, if not block start line.*/
                 {
                  HL_AllLine(ly,cy,pen);
                  }
              if(ly == blk_SY && !(c_LEGAL_TY())) { /* Block start line and*/
                  HL_AllLine(ly,cy,CON_MARKER);     /* top of wind. H-all. */
                 }
              /* previous line. */
              if((ly-1) == blk_SY && c_LEGAL_TY()) {     /* Block start line*/
                   High_LIGHT((ly-1),(cy-1),blk_SX,i-1); /* H. x to x. */
                 }
              if((ly-1) < blk_SY)      /* H. ly-1 from i to r. */
                 {
                   High_LIGHT((ly-1),(cy-1),i,r);
                  }
              if((ly-1) > blk_SY)      /* H. ly-1 from 0 to (i-1) */
                 {
                  High_LIGHT((ly-1),(cy-1),0,i-1);
                  }
               break;
     case ALL_RDOWN:  /* H/D line. (Right arrow Key). */
                      /* Deal with current line only. */

              if(ly == blk_SY) {         /* Highlight from blk_SX to r. */
                   High_LIGHT(ly,cy,blk_SX,r);
                 }
               else {                    /* H/D hole line. */
                   HL_AllLine(ly,cy,pen);
                 }
               break;
   }
 c_PlaceCURS(LINE_X, CURS_Y);   /* Reposition Cursor. */
}
