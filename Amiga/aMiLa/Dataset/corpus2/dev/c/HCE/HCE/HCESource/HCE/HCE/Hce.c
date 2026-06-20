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
 *    main:
 *          Call 'start()' (Hce_Con.c) to open libraries/windows/screens etc.
 *          Direct menu and gadget events.
 *          Call routine related to a key press.
 *          exit().
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

chip char LINE[T_MAXLINE][T_LINELEN]; /* Text Buffer.                      */
char PR_BUF[T_MAXSTR];                /* Temp buffer for general use.      */
char PR_OTHER[T_MAXSTR];              /* Used when 'PR_BUF' unavailable.   */

int LINE_X = 0;                       /* X pos in 'LINE[][x]' and in window*/
int LINE_Y = 0;                       /* Y pos in 'LINE[y][]' (only).      */
int CURS_Y = 0;                       /* Y pos in wind. (0 to Win Height). */
int TXT_CHANGED=FALSE;                /* Monitor text changes.             */
struct U_del udel;                    /* Used for undeletion of a line.    */
static int old_maxY=0;                /* Keep max y pos before win expand. */

void setup ()  /* Open console device/screen/windows and do gfx stuff.*/
{              /* Call 'finish()' at end if 'start()' worked ok!. */ 

   if (!((long)start())) {  /* start().returns con win pointer or NULL.*/
	DisplayBeep (0L);
	exit(10);           /* 10.error */
    }
    LINE[0][0] = '\n';      /* Declare 'LINE[0]' as available.*/
    LINE[0][1] = '\0';
                            /* Nothing to undelete. */
    udel.ud_buff[0] = '\0';
    udel.ud_line = 0;
    udel.ud_flag = UD_NONE;
}

void rem_CHAR(buf,x)        /* Remove char from string at 'x'. */
char *buf;
int x;
{
   char *p;
   buf += x;
   p = buf;
   while((*buf++ = *++p));
}

void main()
{
  long i;
  UWORD mcode;
  WORD curs_on = TRUE;

        setup ();           /* Must be called first!!. */

  do {
        i = checkinput();   /* Get key Input, Menu Event etc. (con wind). */
/*
     if(i)
        printf("main, i = %ld\n",i);
*/
     if(i==IDCMP_ACTIVEWINDOW) {
        Show_W_STAT(1);     /* Show window Active simble. */
        i=0;
        }
     if(i==IDCMP_INACTIVEWINDOW) {
        Show_W_STAT(0);     /* Show window Inactive simble. */
        i=0;
        }
     if(i == 155) {         /* 155 = Func/Arrow/Shifted-Tab key. */
        Do_155();
        i=0;
        }
     if(BLOCK_ON || MOUSE_MARKED) {  /* Change marked text to up/lower case*/
        if(i == 'u') {
           TEXT_UL(1);
           i=0;
           }
        if(i == 'l') {
           TEXT_UL(0);
           i=0;
           }
        if(i == 'h') {       /* Hide block. */
           Check_MMARK();
           Check_KMARK();
           i=0;
           }
        }
                             /* Backspace/Tab/Return/Delete and key press.*/
     if((i > 7 && i < 128) || (i == 163)) {
        Do_SpecialKey(i);
        }
     if(i && i < 47) {       /* Ctrl-Key. Option screens/delete line etc. */
        Do_Ctrl(i);
        }

     if((i > 500) && (i != 1000))     /* Menu pick.  */
        {
           mcode = (UWORD)i - 500;
        if(MenuEvents(mcode)) {
              i = 1000;               /* Quit. */
           if(TXT_CHANGED) {
              if(!Do_ReqV2("Confirm - File Modified!"))
                 i=0;
                 }
               else {
                  if(!Do_ReqV2("Quit Hce - Sure?"))
                      i=0;
                      }
             }
          }

     if(CheckTL((long)FLASHTIME)) {   /* Flash Cursor On/Off. (1/2 sec)*/
               if(curs_on) {
                    c_CursOff();
                    curs_on = FALSE;
                  } else {
                          c_CursOn();
                          curs_on = TRUE;
                          }
          }
     if(i == 27)   /* Escape Key. Expand/Retract console window. */
        {
              Check_MMARK();
              Check_KMARK();
         if(!(old_maxY)) {     /* EXPAND. */
            old_maxY = c_ConRows();
            expand_CW();
            while(i != 1001)   /* Wait for expand to complete.*/
                  i = checkinput();
            FixDisplay();
            c_PlaceCURS(LINE_X, CURS_Y);
            }
          else {               /* RETRACT. */
               if(CURS_Y > old_maxY)    /* Cursor was in expanded area, */
                 {                      /* reposition cursor in advance.*/
                    Show_Line(SUB,(CURS_Y-old_maxY));
                 if((i = Get_SLEN(LINE_Y)) < LINE_X ) /* Keep x legal */
                     Show_Col(ABS,i);
                     c_PlaceCURS(LINE_X,old_maxY);
                     CURS_Y=old_maxY;
                  }
                     retract_CW();
                  while(i != 1001)      /* Wait for retract to complete.*/
                     i = checkinput();
                     old_maxY=0;
                }
          i=0;
         }
      }
    while ((i != 1000) && (i != 27));
  finish();                           /* Close and free all. */
 exit(0);                             /* 0.exit success. */
}

void Do_155()      /* 155 = Func/Arrow/Shifted-Tab key. */
{
  long i;
  WORD l;
        i=checkinput();

/**** DEBUG ****
     if(i)
        printf("155, i = %ld\n",i);
*****************/


/* Function key: (compile,compile+opt,compile+opt+assem...etc..etc..) */
/* Shift+Func key: If an error occured during compile you can position*/
/* the cursor to or near the line which caused the error. F1-F5, */
/* Sift+F1 = goto error one, Shift+F2 = error 2, and so on. */
      if(i > 47 && i < 58) {
           l = i;
           i = checkinput();
        if(i != 126) {              /* Shift+Func key. */
           Check_MMARK();           /* Check not in mouse marked state.*/
           checkinput();            /* Swallow ending 126 value.   */
           goto_Eline((int)(i-48)); /* (this func is in hcc main.c)*/
           }
          else {                    /* Norm func key.*/
                Do_FuncKey((WORD)l);
                return;
                }
        i=0;
       }

        Check_MMARK();   /* Check not in mouse marked state.*/

/* If mark mode, cursor movements are restricted to block buf size, */
/* so give a message if user tries to exceed this. */
     if(BLOCK_ON)
       {
        if(LINE_Y < blk_SY && i == 65) {       /* Up. */
           if((blk_SY - LINE_Y) > (B_MAXLINE-4))
             i = -8;
             }
        if(LINE_Y > blk_SY && i == 66) {       /* DOWN.*/
           if((LINE_Y - blk_SY) > (B_MAXLINE-4))
             i = -8;
             }
        if(i == -8) {
           Show_StatV3("Block! buffer is full - (Max %d Lines)", B_MAXLINE-2);
           Delay(MIN_DELAY);
           Show_Status("Marking out - Block...");
           }
        }

/* Unshifted and Shifted Arrow keys, and shifted Tab Key. */
     switch (i) 
      {
             case 32:
                   if(!BLOCK_ON) {
                      i=checkinput();
                   if(i==65)         /* Shift&left. (start of line)*/
                      curs_to_boL();
                   if(i==64)         /* Shift&right.(end of line)  */
                      curs_to_eoL();
                      i=0;
                     }
                     break;
             case 65:             /* 65.UP. */
                  if(!(c_LEGAL_TY()))
                     c_CursOff();
                     Do_UP();
                     break;
             case 66:             /* 66.Down. */
                  if(!(c_LEGAL_BY()))
                     c_CursOff();
                     Do_DOWN();
                     break;
             case 67:             /* 67.Right. */
                     c_CursOn();
                     Do_RIGHT();
                     break;
             case 68:             /* 68.Left. */
                     c_CursOn();
                     Do_LEFT();
                     break;
             case 83:              /* 83.Shift&DOWN. (10 lines Down). */
                   if(BLOCK_ON) {  /* Mark mode?.    */
                     c_CursOff();
                     i = 0;
                     while(LINE_Y < (T_MAXLINE-2) && i++ < 10)
                           Do_DOWN();
                     } else {     /* Not mark mode. */
                             curs_jump_TO(LINE_Y+10);
                             }
                     break;
             case 84:              /* 84.Shift&UP. ( 10 lines Up). */
                   if(BLOCK_ON) {  /* Mark mode?.  */
                     c_CursOff();
                     i = 0;
                     while(LINE_Y && i++ < 10)
                           Do_UP();
                     } else {     /* Not mark mode. */
                             curs_jump_TO(LINE_Y-10);
                             }
                     break;
             case 90: /* Shift & Tab. (move left) */
                 if(P_GadBN[1] > 0) {
                    Show_Col(SUB,P_GadBN[1]);    /* [1]. tab value. */
                    c_PlaceCURS(LINE_X, CURS_Y);
                    }
                    break;
             default:
                    break;
       }
}

/* Do Backspace/Tab/Return/Delete and normal key press. */
void Do_SpecialKey(i)
long i;
{
      if(!BLOCK_ON)  /* Do not allow any key presses etc if marking out!. */
        {
          if (i==8) {                   /* Backspace Key. */
                 Check_MMARK();
                 TXT_CHANGED=TRUE;
                 Do_BACKSPACE();
           }
          if (i==9) {                   /* Tab Key. (move right). */
              if(P_GadBN[1] > 0) {      /* [1]. Tab value. */
                 if(((LINE_X + P_GadBN[1])) <= Get_SLEN(LINE_Y)) {
                     c_MoveCURS(RIGHT,P_GadBN[1]);
                     Show_Col(ADD,P_GadBN[1]);
                     }
              }
           }
          if (i==13) {	                /* Return Key.  */
                 Check_MMARK();
                 TXT_CHANGED=TRUE;
                 c_CursOff();
                 Do_RETURN();
           }
          if (i==127) {                 /* Delete Key. */
                 Check_MMARK();
                 TXT_CHANGED=TRUE;
                 Do_DELETE(); 
                 i=0;
           }
          if ((i>31 && i<128) || (i == 163))  /* Norm Key Press. */
             {                                /* 163, allow pound sign.*/
                   Check_MMARK();
                if(!TXT_CHANGED)
                   TXT_CHANGED=TRUE;
            if((!(c_LEGAL_RX())) && (LINE_Y+1 < (T_MAXLINE-2)))
                  {
                   writechar((long)'\n');
                   Show_Col(ABS,0);
                   Show_Line(ADD,1);
                  if((c_LEGAL_BY()))
                   CURS_Y++;
                   Do_KEYPRESS(i);
                   }
                  else {
                   Do_KEYPRESS(i);
                   }
             }
        }
}

void Do_Ctrl(i)  /* Screen options, line deletion/word deletion etc. */
long i;
{
  char *p,*v;

    switch(i) 
     {
        case 1:           /* Ctrl+A. Assembler options. */
           if(Open_A_Wind())
              Do_GadMsgs();
              i=0;
              break;
        case 3:           /* Ctrl+C. Compiler options. */
           if(Open_C_Wind())
              Do_GadMsgs();
              i=0;
              break;
        case 12:          /* Ctrl+L. Linker options. */
           if(Open_L_Wind())
              Do_GadMsgs();
              i=0;
              break;
        case 15:          /* Ctrl+O. Optimizer options. */
           if(Open_O_Wind())
              Do_GadMsgs();
              i=0;
              break;
        case 4:           /* Ctrl+D. Delete entire line. */
              Check_MMARK();
              TXT_CHANGED=TRUE;
              strcpy(udel.ud_buff,LINE[LINE_Y]);
              udel.ud_line = LINE_Y;
              udel.ud_flag = UD_ALL;
              Show_Col(ABS,0);    /* Show/Set x-counter. */
              LINE[LINE_Y][0] = '\n';
              LINE[LINE_Y][1] = '\0';
              writechar((long)'\r');
           if(LINE_Y <= 0 && LINE[1][0] == '\0')
              c_Command('K');
             else
              Do_DELETE();
              i=0;
              Show_StatV3("Deleted line %ld..",(long)LINE_Y+1);
              break;
        case 5:           /* Ctrl+E. Delete line from curs to eol. */
           if(LINE[LINE_Y][LINE_X] != '\n') {
              Check_MMARK();
              TXT_CHANGED=TRUE;
              strcpy(udel.ud_buff,LINE[LINE_Y]);
              udel.ud_line = LINE_Y;
              udel.ud_flag = UD_PART;
              LINE[LINE_Y][LINE_X] = '\n';
              LINE[LINE_Y][LINE_X+1] = '\0';
              c_Command('K');
              Show_StatV3("Cut line %ld..",(long)LINE_Y+1);
              }
              i=0;
              break;
        case 19:          /* Ctrl+S. Delete spaces between words. */
           if(LINE[LINE_Y][LINE_X] == ' ') {
              Check_MMARK();
              TXT_CHANGED=TRUE;
              strcpy(udel.ud_buff,LINE[LINE_Y]);
              udel.ud_line = LINE_Y;
              udel.ud_flag = UD_PART;
              while(LINE_X && LINE[LINE_Y][LINE_X-1] == ' ') {
                    LINE_X--;
                    }
              while(LINE[LINE_Y][LINE_X] == ' ')
                    rem_CHAR(LINE[LINE_Y], LINE_X);
              c_Command('K');
              Print_LINE(LINE_Y);
              c_PlaceCURS(LINE_X, CURS_Y);
              Show_Col(ABS, LINE_X);
              }
              i=0;
              break;
        case 23:          /* Ctrl+W. Delete a word seperated by ' ' */
              p = LINE[LINE_Y];
              p += LINE_X;
           if((*p != ' ') && (*p != '\n') && (*p != '\0')) {
              Check_MMARK();
              TXT_CHANGED=TRUE;
              strcpy(udel.ud_buff,LINE[LINE_Y]);
              udel.ud_line = LINE_Y;
              udel.ud_flag = UD_PART;
              while(LINE_X && *--p != ' ') { /* Start of word. */
                    LINE_X--;
                    }
              if(*p == ' ') p++;
                 v = p;                       /* End of word. */
              while((*v != ' ') && (*v != '\n') && (*v != '\0'))
                 v++;
              while(*p)   /* Write over word with end part of string*/
                 *p++ = *v++;
              writechar((long)'\r');
              c_Command('K');
              Print_LINE(LINE_Y);
              c_PlaceCURS(LINE_X, CURS_Y);
              Show_Col(ABS, LINE_X);
              }
              i=0;
              break;
        case 21:    /* Ctrl+U. switch char at LINE[][x] to up/low case.*/
              i = LINE[LINE_Y][LINE_X];
           if(i != '\n' && i != '\0') {
             if(isupper(i))
              i = tolower(i);
             else
              i = toupper(i);
              LINE[LINE_Y][LINE_X] = i;
              writechar((long)i);
              Show_Col(ADD,1);
              }
              i=0;
              break;
        case 22:    /* Ctrl+V. Undelete all or part of line. */
              i=0;
           if(udel.ud_flag == UD_NONE)
              break;
           if(udel.ud_flag == UD_ALL)
              {
               Shift_DOWNV2(udel.ud_line, 1);
               strcpy(LINE[udel.ud_line],udel.ud_buff);
               Show_StatV3("UnDeleted line %ld..",(long)udel.ud_line+1);
               }
           if(udel.ud_flag == UD_PART)
              {
               strcpy(LINE[udel.ud_line],udel.ud_buff);
               Show_StatV3("UnCut line %ld..",(long)udel.ud_line+1);
               }
               FixDisplay();
               c_PlaceCURS(0, CURS_Y);
               Show_Col(ABS, 0);
               udel.ud_flag = UD_NONE;
               break;
         default:
               break;
      }
}
