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
 * Hce_Func.c:
 *             Mixed functions used by Hce_main.c, Hce_MenuCtrl.c, 
 *             Hce_KeyCtrl.c and others.
 */

#include <exec/types.h>
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

void FixDisplay()         /* Reprint all text in console window, */
{                         /* from current line. */
  register int v,i;
  int c;

  c = c_ConRows();        /* Max rows.*/
  v = (LINE_Y - CURS_Y);  /* Get line at top of wind. */
  c_CursOff();
  c_PlaceCURS(0,0);
  c_Command('J');         /* Clear Display. */
  i=0;

   do {
       if(i++ != c) {
             nprint(LINE[v++]);
             }
           else
             Print_LINE(v);    /* Print last line excluding '\n' */
      }
   while((i <= c) && (LINE[v][0] != '\0') && (v <= T_MAXLINE-2));
}

void Print_LINE(ly)  /* Print line 'ly' to Wind at current Y Wind pos. */
int ly;
{
  register char *p,*l;
  p = LINE[ly];
  l = PR_BUF;

  writechar((long)'\r');     /* Curs to start of line.*/

  while((*p != '\n') && *p)  /* Don`t print '\n'. */
         *l++ = *p++;

  *l = '\0';
  nprint(PR_BUF);
}

int Get_SLEN(cy) /* Get string length from 'LINE' at line cy. */
int cy;          /* Does not count '\n' as part of string. */
{
 register char *p;
 register int l=0;

    p = LINE[cy];
 while((*p != '\n') && (*p++ != '\0'))  /* get line len. */
        l++;
 return (l);
}

int GetYN() /* Get simple Yes and No information from user.   */
{
 long i;

YNSTART:
           i = checkinput();
        if(i == 'y' || i == 'Y')
             return(1);
        if(i == 'n' || i == 'N')
             return(0);
 goto YNSTART;
}

void Reset_VARS() /* Reset comman variables ready for a new file etc. */
{
   Show_Line(ABS,0);
   Show_Col(ABS,0);
   CURS_Y = 0;
}

void ClearTextBuf()       /* Empty 'LINE[][]'. */
{
  int i=0;

    while(LINE[i][0] != '\0' && i < (T_MAXLINE-1))
      {
       Clear_Carray(LINE[i++],(T_LINELEN-1));
       }
}

void Clear_Carray(ary,size)  /* Clear any char arrays[] to ZERO */
char *ary;
int size;
{
 register int i=0;
   while(i <= size)
       ary[i++] = '\0';
}

int AC_to_PL(ly)  /* Add all or as much of current line to prev line, */
int ly;           /* return 0 if all was copied, 1 if part copied or, */
{                 /* 2 if nothing was copied. */
  int i,l,c;
  char *p;

  c = c_ConCols();                /* Get max columns. */
  i = Get_SLEN((ly-1));           /* Get prev line len.*/

  if(i >= c)
     return(2);                   /* Prev line full?. */

     p=LINE[ly-1];                /* Point to prev line. */

  if(*p == '\n' || *p == '\0') {  /* Prev line Blank?, copy hole, */
     strcpy(LINE[ly-1],LINE[ly]); /* line to it.  */
     Shift_UPV2(ly,1);            /* Fix buf.     */
     return(0);                   /* All copied!. */
     }

     p=LINE[ly];               /* Point to current line. */
     l=0;

  while((*p != '\n') && (*p != '\0') && (i < c)) /* Try copy ly to ly-1. */
    {
     LINE[ly-1][i++] = *p++;
     l++;
     }
     LINE[ly-1][i++] = '\n';
     LINE[ly-1][i] = '\0';      /* Set end condition. */

 if(*p == '\n' || *p == '\0') {
        Shift_UPV2(ly,1);
        return(0);              /* All copied!. */
     }

  while(l > 0) {                /* No!, then remove copied chars from ly.*/
        i=0;
            do {
                 LINE[ly][i] = LINE[ly][i+1];
                 }
            while(LINE[ly][i++] != '\0');
        l--;
     }
 return(1);              /* Part copied. */
}

void ACX_to_NL(lx,ly)  /* Add rest of current line from lx to next line. */
int lx,ly;
{
  int i,l;
  char *p;

     p=LINE[ly];
     p += lx;
     l=0;

  while((*p != '\n') && (*p != '\0')) /* Copy from [ly][lx] to [ly+1][0]. */
    {
     LINE[ly+1][l++] = *p++;
     }
     LINE[ly+1][l] = '\n';
     LINE[ly+1][l+1] = '\0';    /* Set end condition. */

  while(l > 0) {                /* Remove copied chars from [ly][lx]. */
        i=lx;
            do {
                 LINE[ly][i] = LINE[ly][i+1];
                 }
            while(LINE[ly][i++] != '\0');
        l--;
     }
}

int AN_to_CL(ly)  /* Add all or as much of next line to current line, */
int ly;           /* return 0 if all was copied, 1 if part copied, or */
{                 /* 2 if nothing was copied. */
  int i,l,c;
  char *p;

  if(LINE[ly+1][0] == '\0')       /* Anything to copy?. */
     return(2);

  c = c_ConCols();                /* Get max columns. */
  i = Get_SLEN(ly);

  if(i >= c)
     return(2);                   /* Current line full?. */

     p=LINE[ly];                  /* Point to current line. */

  if(*p == '\n' || *p == '\0') {  /* Current line Blank?, copy hole, */
     strcpy(LINE[ly],LINE[ly+1]); /* of Next line to it. */
     Shift_UPV2(ly+1,1);          /* Fix buf.     */
     return(0);                   /* All copied!. */
     }

     p=LINE[ly+1];                /* Point to Next line. */
     l=0;

  while((*p != '\n') && (*p != '\0') && (i < c)) /* Try copy ly+1 to ly. */
    {
     LINE[ly][i++] = *p++;
     l++;
     }
     LINE[ly][i++] = '\n';
     LINE[ly][i] = '\0';      /* Set end condition. */

     ly++;                    /* !Inc line pos!. */

 if(*p == '\n' || *p == '\0') {
        Shift_UPV2(ly,1);
        return(0);            /* All copied!. */
     }

  while(l > 0) {              /* No!, then remove copied chars from ly+1.*/
        i=0;                  /* Note: ly already inced above. (ly++). */
            do {
                 LINE[ly][i] = LINE[ly][i+1];
                 }
            while(LINE[ly][i++] != '\0');
        l--;
     }

 return(1);                   /* Part copied. */
}

int str_insert(src,pos,ly)   /* Insert 'src' into LINE[ly] from 'pos'.*/
char *src;                   /* Returns 0 if went onto new 'LINE',    */
int pos,ly;                  /* else 1. */
{
 char *dst;
 int i,b_len,s_len;
 int tp = pos;
 int rv = 1;                     /* rv. Return value */
 char *d,*s;

 dst = LINE[ly];
 str_n_cpy(PR_BUF,dst,pos);      /* Save end part of 'dst'. */

 b_len = strlen(PR_BUF)-1;       /* Get end parts length.  */
 s_len = strlen(src);            /* Get 'src' length.      */

 if(src[s_len-1] == '\n')        /* Exclude '\n' */
    s_len--;

  i = 0;
  while(LINE[i][0] != '\0')      /* Get number of lines used. */
  i++;

 if((pos+s_len) > c_ConCols())   /* 'src' won`t fit on line from pos. */
  {
      s = src;
      d = dst;
      d += pos;                  /* start char pos. */
     while(tp++ < c_ConCols())   /* Fit as much of 'src' to 'dst' */
      {                          /* as possible. */
        *d++ = *s++;
       }
      *d++ = '\n';
      *d = '\0';                 /* Set end for current line. */

     if(i >= T_MAXLINE-2)        /* No buffer space left for new line?. */
      return(1);
 
      Shift_DOWNV2((ly+1),1);     /* Insert new line below current. */
      d = LINE[ly+1];             /* Point to next line. */

     while(*s != '\n' && *s != '\0')  /* Put rest of source on next line. */
      {
        *d++ = *s++;
       }
      *d++ = '\n';
      *d = '\0';                            /* Set end for next line. */

      d = LINE[ly+1];                       /* Point to start. */
      str_n_add(d, PR_BUF, (strlen(d)-1));  /* Add end part back on.  */
      rv = 0;
   }
  else 
   {   /* 'src' will fit on current line from pos. */

        str_n_add(dst, src, pos);               /* Add source to dest.    */

    if((pos+s_len+b_len) > c_ConCols())         /* But end part won`t fit,*/
     {
     if(i >= T_MAXLINE-2)          /* No buffer space left for new line?. */
        return(0);
        s = PR_BUF;
        d = LINE[ly];
        d += (pos+s_len);          /* Start char pos. */
        tp = (pos+s_len);
        while(tp++ < c_ConCols())  /* Fit as much of end bit to cur line. */
          {
           *d++ = *s++;
           }
        *d++ = '\n';
        *d = '\0';
        Shift_DOWNV2((ly+1),1);    /* Insert new line.('LINE'). */
        d = LINE[ly+1];
        while(*s != '\n' && *s != '\0')  /* Put rest of end on next line. */
          {
           *d++ = *s++;
           }
        *d++ = '\n';
        *d = '\0';
        rv = 0;
      }
     else    /* If reached here, hole block line fits ok!. */
      {
       str_n_add(dst, PR_BUF, (strlen(dst)-1)); /* Add end part back on.  */
       }
   }
return(rv);
}

str_n_cpy(dst,src,from) /* Copy part of 'src' from 'from' to 'dst' */
char *dst,*src;
int from;
{
  src += from;
  while(*src != '\n' && *src != '\0')
       *dst++ = *src++;
  *dst++ = '\n';
  *dst = '\0';
}

str_n_add(dst,src,from) /* Copy 'src' to 'dst' at 'from'. */
char *dst,*src;
int from;
{
  dst += from;
  while(*src != '\n' && *src != '\0')
       *dst++ = *src++;
  *dst++ = '\n';
  *dst = '\0';
}

str_be_cpy(dst,src,b,e) /* Copy part of 'src' from 'b' to 'e' to 'dst'. */
char *dst,*src;
int b,e;
{
  src += b;
  while(*src != '\n' && *src != '\0' && b++ <= e)
       *dst++ = *src++;
  *dst++ = '\n';
  *dst = '\0';
}


/******** CURSOR CONTROL *********/

void Curs_TEOL(flg)    /* Put curs to end of line. */
int flg;               /* Line depends on flg.     */
{                      /* Shows and sets LINE_X/Y  */
  int c,cl,ly;

     cl = CURS_Y;

     if(flg == 1) {          /* Prev line .*/
          Show_Line(SUB,1);  /* Show set new LINE_Y. */
          cl--;
     }
     if(flg == 2) {          /* Next line. */
          Show_Line(ADD,1);  /* Show set new LINE_Y. */
          cl++;
     }
     ly = LINE_Y;
     if(!(flg)) {            /* Current line.*/
        Show_Line(ABS,ly);
     }
     c = Get_SLEN(ly);       /* Get line len. new LINE_Y.*/
     c_PlaceCURS(c, cl);
     Show_Col(ABS,c);        /* Show set new LINE_X. */
}

void curs_to_boF()       /* Place Curs to beginning of file. */
{
   Reset_VARS();         /* LINE_X/Y/CURS_Y = 0. */
   FixDisplay();         /* Redisp wind lines.   */
   c_PlaceCURS(0, CURS_Y);
}

void curs_to_eoF()      /* Place Curs to end of file. */
{
 int i=0;

   i = Buf_Used();      /* Get lines used. */
      if(!LINE_Y) {
         if(i <= c_ConRows()) {   /* File length <= window height?. */
            CURS_Y = i;
               } else {
                       CURS_Y = c_ConRows();
                       }
         Show_Line(ABS, i);
         Show_Col(ABS,0);
         }
    FixDisplay();         /* Redisp wind lines.   */
 c_PlaceCURS(0, CURS_Y);
}

void Curs_to_BEF() /* Placs Cursor and line position to Beg/End of file. */
{ 
  if(LINE_Y)              /* If not at start, goto start of file. */
      curs_to_boF();
   else                   /* If at start, goto to end of file. */
      curs_to_eoF();
}

void curs_to_boL()        /* Curs to beginning of line. */
{
      Show_Col(ABS,0);    /* LINE_X = 0. */
      writechar((long)'\r');
}

void curs_to_eoL()      /* Curs to end of line. */
{
 int x;
    x = Get_SLEN(LINE_Y);
     if(x) {
       Show_Col(ABS, x);
       c_PlaceCURS(x, CURS_Y);
       }
}

void Curs_to_BEL()     /* Place Cursor position to Beg/End of Line. */
{
  if(LINE_X)           /* If not at start, goto start of line. */
       curs_to_boL();
    else               /* If at start, goto end of line. */
       curs_to_eoL();
}

int curs_jump_TO(ly)   /* Jump to Line 'ly' and fix display. */
int ly;                /* Sets LINE_Y/X and CURS_Y. */
{
 int i;

   if(ly > LINE_Y) {    /* Moveing higher up in buffer. DOWN wind. */
         i = Buf_Used();
      if(LINE_Y == i)   /* Already on last available line? */
         return;
      if(ly > i)        /* Do not go past last line. */
         ly = i;
      if(c_LEGAL_BY()) {
          CURS_Y = (ly-LINE_Y);
          if(CURS_Y > c_ConRows())
             CURS_Y = c_ConRows();
          }
         Show_Line(ABS,ly);      /* Show/Set new line. */
         Show_Col(ABS,0);        /* Show/Set new column. */
         FixDisplay();
         c_PlaceCURS(0,CURS_Y);
      }
   if(LINE_Y && LINE_Y > ly) {   /* Moveing lower. UP wind. */
            if(CURS_Y) {
               CURS_Y -= (LINE_Y-ly);
               if(CURS_Y < 0)
                  CURS_Y=0;
              }
            if(ly < 0)           /* Keep within min line. */
               ly=0;
              Show_Line(ABS,ly);
              Show_Col(ABS,0);
              FixDisplay();
              c_PlaceCURS(0,CURS_Y);
      }
}

/******** OTHER ********/

int Buf_Used()  /* Returns number of lines used in 'LINE[][]' */
{
  int i=0;
   while(LINE[i][0] != '\0' && i < T_MAXLINE-2)
      i++;
   return((i-1));
}

int Buf_Avail()  /* Returns number of lines available in 'LINE[][]'. */
{
 return(((T_MAXLINE-2) - Buf_Used()));
}

/***************** FUNCTIONS FOR SEARCH/REPLACE ********************/

int Search_LINE()  /* Returns TRUE when 'string' is found, */
{                  /* Starts search from Current LINE_X/Y Positions, */
 int sx,sl;        /* returns FALSE when end of buf. */
 char *found;
 int sc,bu;
 int ly = LINE_Y;
 int lx = LINE_X;
 if(lx < c_ConCols())      /* Get past last found. */
    lx++;

  bu = Buf_Used();         /* Lines used. */
  sl = strlen(Search_Name)-1;

 while(ly <= bu && ly < T_MAXLINE-2)   /* Return TRUE if found. */
   {
    sc = Do_Search(Search_Name,LINE[ly],&sx,&lx);

    if(sc)    /* Found it? */
       {
        curs_jump_TO(ly);                 /* Sets LINE_X/Y CURS_Y. */
        High_LIGHT(ly,CURS_Y,sx,(sx+sl)); /* Highlight search string.*/
        c_BPen(penshop[CON_PAPER]);
        c_PlaceCURS(sx, CURS_Y);
        Show_Col(ABS,sx);
        return(TRUE);
        } else
            {          /* Reached here. Not found or end of line */
              lx = 0;  /* Reset x pos.    */
              ly++;    /* Inc buffer pos. */
             }
    }
 return(FALSE);
}

int Replace_JOB()  /* Find then replace 'Search' string with 'Replacement',*/ 
{                  /* string. The strings were obtained by the replace     */
 long i;           /* Gadgets. Global and step through modes supported.    */
 int op=0,rl;
 int count=0;

 if(!Search_LINE())
     return(0);     /* Not Found */
 
   rl = strlen(Replace_Name)-1;
   Show_Status("Found! - G=Global, R=Replce, N=Goto-Next, Q=Quit");
   c_CursOn();

 while(!op) {
   i=checkinput();
    switch(i) {
      case 'g' || 'G':              /* Global. */
                    do {
                        Do_Replacement();
                        Show_Col(ABS,LINE_X+rl); /* Stop loop recursion. */
                        count++;
                        } while(Search_LINE());
                    op++;
                    break;
      case 'r' || 'R':              /* Replace 1, goto next. */
                    Do_Replacement();
                    Show_Col(ABS,LINE_X+rl);
                    count++;
                  if(!Search_LINE())
                    op++;           /* op++. not found. */
                    break;
      case 'n' || 'N':              /* Goto next. */
                  if(!Search_LINE())
                    op++;
                    break;
      case 'q' || 'Q':              /* Quit. */
                    op++;
                    break;
             default:
                    break;
      }
  }
  FixDisplay();
  c_PlaceCURS(LINE_X,CURS_Y);

 if(count) {
    TXT_CHANGED=TRUE;
    sprintf(PR_OTHER,"Done! - Replaced: %d", count);
    }
   else {
    strcpy(PR_OTHER,"None - Replaced...");
    }
    Show_Status(PR_OTHER);  /* Used PR_OTHER as PR_BUF used by Show_Status.*/
return(1);
}

void Do_Replacement() /* Call if a call to Search_LINE() was successful*/
{
 char *dst,*s;
 int sl;
  sl = strlen(Search_Name);

  dst = LINE[LINE_Y];
  s = LINE[LINE_Y];
  str_n_cpy(PR_BUF,dst,(LINE_X+sl));       /* Save end part of 'dst'.    */
  str_n_add(s, PR_BUF, LINE_X);            /* Add end part back on,      */
                                           /* removing search str.       */
  str_insert(Replace_Name,LINE_X,LINE_Y);  /* Insert replace str.        */
}

int Do_Search(srch,ly,sx,x)   /* Search string '*ly' for '*srch' string. */
char *srch,*ly;               /* start search from x. (*sx = start x).   */
int *sx,*x;                   /* 1 = found else 0. */
{
  char *s,*b,*f;
  int slen,cmp;

     slen = strlen(srch);     /* Get search strings length.    */
     s = srch;                /* Point to search string.       */
     b = ly;                  /* Point to Line to be searched. */

     if(*x)
        b += *x;              /* Point to x search position. */

  while(*b) /* Check line from where *b is pointing */
      {
       while(*b && !(cmp = c_comp(*b, *s))) { /* Find first char. */
              ++*x;                           /* Keep line pos.   */
              *b++;
              }
      if(*b)
         {
             f = srch;                 /* Point at first char. */
            while(*b && *f && c_comp(*b, *f)) {    /* Compare. */
             *b++;
             *f++;
             ++*x;                     /* Keep line pos. */
             }
         if(!*f) {   /* Match?. */
             *sx = (*x - slen);        /* Set sx to point at first char */
             return(1);                /* Found. */
            }
          }
      }
 return(0); /* Not found! */
}

int c_comp(c1,c2)  /* Compare two chars, return TRUE if same else FALSE. */
char c1,c2;
{
  if(!(c_sensitive)) {       /* If not case sensitive. */
         c1 = toupper(c1);   /* Sensitivity flag set in 'Hce_GadCtrl.c' */
         c2 = toupper(c2);   /* NOTE: toupper checks if already upper.  */
    }     
  if(c1 == c2)
      return(TRUE);
 return(FALSE);
}
