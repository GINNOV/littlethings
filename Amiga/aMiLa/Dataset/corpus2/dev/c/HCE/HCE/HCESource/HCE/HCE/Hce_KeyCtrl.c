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
 * Hce_KeyCtrl.c:
 *
 *           Deals with, Backspace/Delete/Return/Function and Arrow Keys.
 *
 */
 
#include <intuition/intuition.h>
#include <clib/string.h>
#include <clib/stdio.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"
#include "Hce_Block.h"


void Do_UP() /* Take care of Up cursor control.*/
{            /* Called after UP ARROW KEY or in conection with MOUSE.*/
  int c,ly;
  ly = (LINE_Y - 1);            /* Get prev line. */

 if(LINE_Y > 0)
  {
    c = Get_SLEN(ly);           /* Get prev line len.   */
         if(c < LINE_X)         /* If prev line shorter,*/
             Show_Col(ABS,c);   /* Reajust x position.  */
            if(BLOCK_ON)
                {
                 if(!(c_LEGAL_TY())) {  /* Top of wind so scroll.. */
                    c_Command('T');
                    c_MoveCURS(DOWN,1);
                    CURS_Y++;
                    }
                if(LINE_Y <= blk_SY)
                    HD_LINE((ly+1),CON_MARKER,ALL_UP); /* H: cur/prev */
                  else
                    HD_LINE((ly+1),CON_PAPER,ALL_UP); /* D. cur/prev line. */
                 }
              else {
                   if(!(c_LEGAL_TY())){   /* Top of wind so scroll.. */
                       c_Command('T');
                       Print_LINE(ly);
                       }
                    }
      if((c_LEGAL_TY()))         /* Dec cursor pos.    */
            CURS_Y--;
         Show_Line(SUB,1);       /* Show set LINE_Y-1. */
      c_PlaceCURS(LINE_X, CURS_Y);
   }
}


void Do_DOWN()  /* Take care of Down cursor control. */
{
 int ly = (LINE_Y + 1);    /* Get next line. */
 int c;

 if(LINE[ly][0] && ly < (T_MAXLINE-2)) /* Check not blank or end of buf.1st*/
  {
      c = Get_SLEN(ly);         /* Get next line len.   */
         if(c < LINE_X)         /* If next line shorter,*/
             Show_Col(ABS,c);   /* Reajust x position.  */

              if(BLOCK_ON)
                {
                 if(!(c_LEGAL_BY())) {  /* BTM of wind so scroll.. */
                    c_Command('S');
                    c_MoveCURS(UP,1);
                    CURS_Y--;
                    }
                 if(LINE_Y >= blk_SY)
                   HD_LINE((ly-1),CON_MARKER,ALL_DOWN);  /* H. cur/next. */
                 else
                   HD_LINE((ly-1),CON_PAPER,ALL_DOWN); /* D. cur/next line. */
                 }
               else {
                   if(!(c_LEGAL_BY())){   /* BTM of wind so scroll.. */
                       c_Command('S');
                       Print_LINE(ly);
                       }
                     }
       if((c_LEGAL_BY()))
         CURS_Y++;                    /* Inc cursor pos. */
         Show_Line(ADD,1);            /* Show set LINE_Y+1.*/
         c_PlaceCURS(LINE_X, CURS_Y);
   }
}

void Do_RIGHT()  /* Take care of Right cursor control. */
{
 int ly = LINE_Y;    /* Get line.     */
 int lx = LINE_X;    /* Get col.      */


  if((LINE[ly][lx] != '\n') && (LINE[ly][lx] != '\0') && (c_LEGAL_RX()))
     {
      if(BLOCK_ON)                /* Highlight/Dehighlight char. */
         HD_LINE(ly,NULL,RIGHT);
         c_MoveCURS(RIGHT,1);
         Show_Col(ADD,1);         /* Show set LINE_X+1*/
       }
    else        /* End of line, go onto next. */
     {
       ly++;
       if(LINE[ly][0] != '\0') /*blank?.*/
        {
            if(BLOCK_ON)
               {
                if(LINE_Y >= blk_SY) {                /* Highlight line */
                 if((LINE_Y-blk_SY) >= (B_MAXLINE-3)) /* BLOCK buffer full?*/
                    return;
                    HD_LINE((ly-1),CON_MARKER,ALL_RDOWN);
                    }
                 else {
                  if((blk_SY-LINE_Y) >= (B_MAXLINE-3))
                    return;
                    HD_LINE((ly-1),CON_PAPER,ALL_RDOWN); /* Dehighlight line*/
                    }
                }
                writechar((long)'\n');

         if(!(c_LEGAL_BY())) {         /* Bottom of Wind? ,print Next. */
                Print_LINE(ly);
                writechar((long)'\r'); /* Repos curs. */
                }
             else
                CURS_Y++;              /* In curs pos. */              
                Show_Col(ABS,0);       /* Show set 'LINE_X' */
                Show_Line(ADD,1);      /* LINE_Y+1.  */
        }
     }
}

void Do_LEFT()  /* Take care of Left cursor control. */
{
 int ly = LINE_Y-1;  /* Get prev line. */
 int lx = LINE_X;    /* Get col.       */

 
    if(LINE_X) {             /* Move left until LINE_X=0. */
        if(BLOCK_ON)         /* H/D Line. */
             HD_LINE((ly+1),NULL,LEFT);
             c_MoveCURS(LEFT,1);
             Show_Col(SUB,1);
     }
  else                       /* Move to prev line. */
    { 
      if(LINE_Y > 0)
       {
         if(BLOCK_ON) {
               if(!(c_LEGAL_TY())) {  /* Top of wind so scroll.. */
                 c_Command('T');
                 c_MoveCURS(DOWN,1);
                 CURS_Y++;
                 }
               if(LINE_Y <= blk_SY)
                 HD_LINE((ly+1),CON_MARKER,ALL_LUP);  /* H. cur/prev line. */
                else
                 HD_LINE((ly+1),CON_PAPER,ALL_LUP);   /* D. cur/prev line. */
                }
              else {
                   if(!(c_LEGAL_TY())){   /* Top of wind so scroll.. */
                       c_Command('T');
                       Print_LINE(ly);
                       }
                    }
              LINE_Y--;
           if((c_LEGAL_TY()))
              CURS_Y--;         /* Dec curs pos. */
              Curs_TEOL(NULL);  /* NULL = current line.*/
        }
     }
}

void Do_RETURN()  /* Do return key and fix buf. */
{
  int ly = LINE_Y;
  int lx = LINE_X;

  if(!(Buf_Used() >= (T_MAXLINE-3)))  /* Check line limmit. must be '-3'*/
   {
    if(LINE[ly][lx] != '\n' && LINE[ly][lx] != '\0') /* EOF?*/
      {
       if(!(lx)) {          /* x=0. Shift current line down 1. */
                  Shift_DOWNV2(ly,1);     /* Fix buf.('LINE'). */
                if((c_LEGAL_BY())) {      /* Bottom of wind?.  */
                      c_Command('L');     /* Insert line.      */
                      CURS_Y++;
                      writechar((long)'\n');
                  }
                else {       /* Is bottom of wind. */
                      c_Command('K');  /* Erase current line on wind. */
                      c_Command('S');  /* Scroll up 1. */
                      Print_LINE(ly+1);
                      writechar((long)'\r');
                      }
          }
        else {      /* Add rest of current line to next, during 'return'. */
           Shift_DOWNV2(ly+1,1);    /* Fix buf in advance!. */
           ACX_to_NL(lx,ly);        /* Add str from [ly][lx] to [ly+1][0]. */
           c_Command('K');          /* Erase current line on wind. */
           Print_LINE(ly);          /* Reprint current line. */
           writechar((long)'\n');   /* Onto next line. */
        if((c_LEGAL_BY())) {        /* Bottom of wind!, don`t insert.*/
           c_Command('L');          /* Insert line. */
           CURS_Y++;
           }
           Print_LINE(ly+1);        /* Print next line. */
           c_PlaceCURS(0, CURS_Y);
         }
       }
     else  /* Either end of line or line is blank. Just shift down 1. */
      {
         writechar((long)'\n');   /* Next line.   */
         c_Command('L');          /* Insert line. */
         Shift_DOWNV2(ly+1,1);    /* Fix buf. */
        if((c_LEGAL_BY()))
         CURS_Y++;
       }
        Show_Col(ABS, 0);
       Show_Line(ADD, 1);
   }
}

void Do_BACKSPACE() /* Do back space key and fix buf. */
{
  char *p;
  int c,l,v,ln;
  int ly = LINE_Y;
  p=LINE[ly];

  if(LINE_X) {  /* x>0. Just remove single character. */
       Show_Col(SUB,1);      /* LINE_X-1.  */
       writechar((long)8);   /* Backspace. */
       c_Command('P');       /* Del char.  */
       ln = Get_SLEN(ly);    /* Get line len. */

    for(l = LINE_X; l <= ln; l++)   /* Remove char from buf. */
       LINE[ly][l] = LINE[ly][l+1];
       LINE[ly][ln-1] = '\n';
       LINE[ly][ln] = '\0';
     }
  else {           /* Line may be blank so remove it. */
        if(LINE_Y)
          {
             ln = Get_SLEN((ly-1));         /* Get prev line len.  */
              c = AC_to_PL(ly);             /* Try add ly to ly-1. */
             ly = c_ConRows();              /* Max rows.*/
              v = (ly - CURS_Y) + (LINE_Y); /* Get line at bottom of win. */

             if(!c_LEGAL_TY()) {  /* Top of wind?. */
                c_Command('T');   /* Scroll.. */
                Print_LINE(LINE_Y-1);
                c_MoveCURS(DOWN,1);
                CURS_Y++;
                }

                switch(c)   /* Act on result from AC_to_PL(). */
                   {
                  case 0:      /* ALL COPIED!. */
                      c_Command('M');           /* Del line. */
                    if(v <= (T_MAXLINE-2))
                      {
                      if(LINE[v][0] != '\0') {  /* Need to print line at, */
                         c_PlaceCURS(0,ly);     /* bottom of Window?. */
                         Print_LINE(v);
                         }
                      }
                      Show_Col(ABS, ln);        /* Show/Set LINE_X. */
                      Show_Line(SUB, 1);        /* Dec LINE_Y. */
                      CURS_Y--;
                      c_PlaceCURS(0, CURS_Y);
                      Print_LINE(LINE_Y);
                      c_PlaceCURS(ln, CURS_Y);
                      break;
                  case 1:      /* Part Copied!. */
                      c_PlaceCURS(0,(CURS_Y-1)); /* Place curs.   */
                      c_Command('K');            /* Blank line.   */
                      Print_LINE((LINE_Y-1));    /* Reprint line. */
                      c_PlaceCURS(0,CURS_Y);     /* Place curs.   */
                      c_Command('K');            /* Blank line.   */
                      Print_LINE(LINE_Y);        /* Reprint line. */
                      c_PlaceCURS(ln, (CURS_Y-1));
                      Show_Col(ABS, ln);
                      Show_Line(ABS,(LINE_Y-1));
                      CURS_Y--;
                      break;
                 case 2:      /* None copied. Just pos curs. */
                     if(*p != '\n' && *p != '\0') {
                      Curs_TEOL(UP);
                      CURS_Y--;
                      }
                      else {   /* Current line blank so remove it. */
                              Shift_UPV2(LINE_Y,1);
                              c_Command('M');
                           if(v <= (T_MAXLINE-2))
                             {
                              if(LINE[v][0] != '\0') {
                                 c_PlaceCURS(0,ly);
                                 Print_LINE(v);
                                 c_PlaceCURS(0,(CURS_Y-1));
                                 }
                              }
                             Curs_TEOL(UP);
                             CURS_Y--;
                            }
                      break;
                  default:
                      break;
                   }
            }
        }
}

void Do_DELETE() /* Do delete in wind and fix buf. */
{
 char *p;
 int ly = LINE_Y;
 int lx = LINE_X;
 int c,l,v,ln,r;
 p = LINE[ly];
 
        /* Check line not blank or curs not at end of str 1st. */

 if(((LINE[ly][lx] != '\n') && (LINE[ly][lx] != '\0')) &&
   ((*p != '\n') && (*p != '\0')))
   {
      if((LINE[ly][lx] != '\n') && (LINE[ly][lx] != '\0'))
         {
          c_Command('P');               /* Delete in wind. */
          ln = Get_SLEN(ly);            /* get line len. */

       for(l = lx; l <= ln; l++)      /* Remove char from buf. */
          LINE[ly][l] = LINE[ly][l+1];

          LINE[ly][ln-1] = '\n';
          LINE[ly][ln] = '\0';         /* set end. */
          /* printf("L3: %s", LINE[ly]); */
          }
    }
   else {    /* Line maybe blank so try to remove it. */
             ln = Get_SLEN(ly);             /* Get line len. */
              r = c_ConRows();              /* Max rows.*/
              v = (r - CURS_Y) + (LINE_Y);  /* Get line at bottom of win. */

         if(!(lx) && (ly >= 0))
            {
           if((ly==0) && (LINE[ly+1][0] == '\0')) {
                return;                      /* 'LINE[][]' now empty?.*/
                }
                c_Command('M');              /* Delete line in win. */
                Shift_UPV2(ly,1);            /* Shift buf up 1.     */
             if(v <= (T_MAXLINE-2))
                {
                if(LINE[v][0] != '\0') {     /* Need to print line at, */
                   c_PlaceCURS(0, r);        /* bottom of win?. */
                   Print_LINE(v);
                   c_PlaceCURS(0, CURS_Y);
                   }
                 }
             if(ly && LINE[ly][0] == '\0') { /* Last line?. */
                c_MoveCURS(UP,1);
                Show_Line(SUB,1);            /* LINE_Y-1.   */
                if(!(CURS_Y)) {              /* Top of win?.*/
                   Print_LINE(LINE_Y);
                   writechar((long)'\r');
                   }
               if((c_LEGAL_TY()))
                 CURS_Y--;                   /* Dec curs pos.   */
                }
            }
        else   /* Curs at end of line, and line not blank!. */
           {   c = AN_to_CL(ly);      /* Try add ly+1 to ly,  */
                                      /* then act on results. */
               /* printf("Del second if. c = %d\n", c); */
           if(ly >= 0)
             {
               switch(c)  /* 0=ALL, 1=part, 2=None ..copied.*/
                 {
                    case 0:  /* All copied!. */
                           c_PlaceCURS(0,(CURS_Y+1));
                           c_Command('M');       /* Del copied line. */
                        if(v <= (T_MAXLINE-2))
                          {
                           if(LINE[v][0] != '\0') { /* Print line at   */
                              c_PlaceCURS(0,r);     /* bottom of win?. */
                              Print_LINE(v);
                              }
                           }
                           c_PlaceCURS(0, CURS_Y);
                           c_Command('K');
                           Print_LINE(ly);
                           c_PlaceCURS(ln, CURS_Y);  /* Repos curs. */
                           break;
                    case 1:  /* Part copied!. */
                           c_PlaceCURS(0,(CURS_Y+1));
                           c_Command('K');         /* ETEOL. */
                           Print_LINE(ly+1);       /* Reprint next line.*/
                           c_PlaceCURS(0, CURS_Y);
                           c_Command('K');
                           Print_LINE(ly);         /* Reprint current line. */
                           c_PlaceCURS(ln, CURS_Y);
                           break;
                    case 2:  /* None copied!. */
                           break;
                    default:
                           break;
                  }
               }
            }
        }
}

void Do_KEYPRESS(i) /* Show users key press in window and fix buf. */
int i;              /* NOTE: Checks are made in Hce.c to see if end*/
{                   /*       of line or buffer is full.            */
  char *p, s;
  int c,l;
  int ly = LINE_Y;
  int lx = LINE_X;

  c = Get_SLEN(ly);

  if(c >= c_ConCols())   /* If LINE[ly] >= max x chars, go onto next line. */
   {
     if((Buf_Used()+1) > (T_MAXLINE-3)) /* Out of buffer space!. */
          return;
     if((Get_SLEN(ly+1)) >= (c_ConCols()))
          return;               /* Next line full??. */
     c--;
     c_PlaceCURS(c, CURS_Y);
     writechar((long)' ');

     s = LINE[ly][c];       /* Get last char of cur line. */
     LINE[ly][c] = '\n';    /* Write over last char. */
     LINE[ly][c+1] = '\0';  /* Set new end. */

     p = LINE[ly+1];

    if(*p == '\n' || *p == '\0') { /* Is next line blank?. */
        *p++ = s;
        *p++ = '\n';
        *p = '\0';
       }
      else {                      /* Next line not blank. */
             c = Get_SLEN(ly+1);

           for(l = c;l >= 0; l--)  /* Make 1 char space at beg of line. */
               LINE[ly+1][l+1] = LINE[ly+1][l];

               LINE[ly+1][0] = s;  /* Add new char. */
               c++;                /* Skipp last char. */
               LINE[ly+1][c++] = '\n';
               LINE[ly+1][c] = '\0';
            }
            c_MoveCURS(DOWN,1);
            Print_LINE(ly+1);      /* Show altered line. */
        if(!(c_LEGAL_BY()))        /* Need to adjust if bottom of wind. */
            CURS_Y--;
        c_PlaceCURS(lx, CURS_Y);   /* Reposition curs. */
    }

  c_Command('@');          /* Insert on current line.    */
  writechar((char)i);      /* Show char on current line. */
  p = LINE[LINE_Y];
  c = 0;

  if(*p != '\0')           /* Insert next char in current line. */
   {
   while((*p != '\n') && (*p++ != '\0')) /* (Don`t use Get_SLEN here!). */
   c++;
   *++p = '\n';
   *++p = '\0';            /* Set end in advance. */
 
    if(!(LINE[LINE_Y][LINE_X] == '\n' || LINE[LINE_Y][LINE_X] == '\0')) {
         for(l = c; l >= LINE_X; l--)             /* If not end of str, */
            LINE[LINE_Y][l+1] = LINE[LINE_Y][l];  /* make space. */
         }
     LINE[LINE_Y][LINE_X]=i;  /* Add char to buf. */
   }
  else {                      /* First char on line. */
     LINE[LINE_Y][0] = i;
     LINE[LINE_Y][1] = '\n';
     LINE[LINE_Y][2] = '\0';  /* Set end. */
    }

   Show_Col(ADD,1);           /* Inc LINE_X. */
}

void Do_FuncKey(i) /* Call the appropriate routine for a function key. */
WORD i;            /* This is called by 'hce.c' only. */
{
    switch(i) {
           case 48:            /* F1.Compile only.(test) */
                  ME_Menu2(0);
                  break;
           case 49:            /* F2.Compile+optimize. */
                  ME_Menu2(1);
                  break;
           case 50:            /* F3.Compile+Opt+Assemble. */
                  ME_Menu2(2);
                  break;
           case 51:            /* F4.Compile+Opt+Assem List. */
                  ME_Menu2(3);
                  break;
           case 52:            /* F5.Compile+Opt+Assem+Link. */
                  ME_Menu2(4);
                  break;
           case 53:            /* F6.Assemble this file. */
                  ME_Menu3(0);
                  break;
           case 54:            /* F7.Assemble compiled. */
                  ME_Menu3(1);
                  break;
           case 55:            /* F8.Assemble selected. */
                  ME_Menu3(2);
                  break;
           case 56:            /* F9.Assemble + Link. */
                  ME_Menu3(3);
                  break;
           case 57:            /* F10.Link Assembled. */
                  ME_Menu4(0);
                  break;
           default:
                  break;
     }
  Show_FreeMem();
}
