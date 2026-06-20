/* -----------------------------------------------------------
  $VER: calc.math.c 1.01 (28.01.1999)

  maths core for calculator project

  (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
  amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
  ------------------------------------------------------------ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <dos/dos.h>
#include <exec/types.h>
#include <exec/exec.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>

#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>

#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/exec_protos.h>

#include "Calc.h"

#define MAX 255 /* max char precision */

/* buffers for maths core preserved betwen calls */
long double result=0; /* final total */
char number1[MAX];    /* first number */
char op;              /* math op */
char number2[MAX];    /* second number */
int i=0,y=0;
int flag=0,sflag=0;  /* control flags */

/* tape history */
extern int UseTape;
/* maths mode */
extern int mode;
/* whats on screen */
extern char buffer[100];

double do_math(char inchar)
{ /* maths core for calculator */
char *t1,*t2;
static long double realnumber1,realnumber2,realresult;

/* if previous result exists & op is first gad pressed */
if ( ((inchar == '+' ) || (inchar == '-' ) || (inchar == '/' ) ||
     (inchar == '*' )) && (result != 0)
   )
   /* second or more calc */
   {
    op = inchar; /* store */
    // printf("operation (%c)\n",op);
    draw_op(op);
    flag =1;  /* now only fill second number */
    sflag =1; /* calc, uses stored number as number1 */

    /* copy previous result to number1 store */
    realnumber1 = result;
   }

/* if input is number and op is blank store */
if ( ((isdigit(inchar) != 0) || (inchar =='.')) && (flag ==0))
   /* make sure we are first number */
   {
    /* first distroy, old result, cos user did NOT, want */
    /* to perform an operation on it (they started to type */
    /* a new number !!) */
    result=0;

    number1[i] = inchar; /* add next input */
    i++;
    // printf("1stored (%c), number1 (%s)\n",inchar, number1);
    clear_display();
    draw_display(number1,NULL);
   }

/* if input is number and op is NOT blank store */
if (((isdigit(inchar) != 0) || (inchar =='.')) && (flag ==1))
   /* make sure we are second number */
   {
    number2[y] = inchar; /* add next input */
    y++;
    // printf("2stored (%c), number2 (%s)\n",inchar, number2);
    clear_display();
    draw_display(number2,NULL);
   }


/* if we get a operations store */
if ( (inchar == '+' ) || (inchar == '-' ) || (inchar == '/' ) ||
     (inchar == '*' ) || (inchar == '(' ) || (inchar == ')' ) ||
     (inchar == '<' ) && (sflag == 0) /* skip if op allready parsed */
   ) /* its an operation */

   {
    op = inchar; /* store */
    // printf("operation (%c)\n",op);
    clear_display();
    draw_op(op);
    draw_display(NULL,NULL); /* a refresh basicly */
    flag =1; /* now only fill second number */
   }


/* if = pressed */
if (inchar == '=')
    {
    /* we work out result imedieatly */

    /* convert to numbers */
    if (sflag ==0) realnumber1 = strtod(number1, &t1);
    /* or not if one is available */
    if (sflag ==1) realnumber1 = result;

    realnumber2 = strtod(number2, &t2);
    /* second number always input */

    if (UseTape ==1)
        printf("%.25Lg %c %.25Lg\n ",realnumber1,op,realnumber2);

    switch (op)
    {
    case '+':
    realresult = (realnumber1 + realnumber2);
    break;

    case '-':
    realresult = (realnumber1 - realnumber2);
    break;

    case '/':
    realresult = (realnumber1 / realnumber2);
    break;

    case '*':
    realresult = (realnumber1 * realnumber2);
    break;

    default:
    printf("Something broke, couldent get operand ! got (%c)\n",op);
    break;
    };

    /* copy to store */
    result = realresult;

    /* output conversion depends on mode selected */
    /* ALL maths done internally as decimal */

    switch (mode)
    {
    case 0: /* DEC */
    /* copy data for display */
    sprintf(buffer, "%-.25Ld",realresult);
    /* tape display */
    if (UseTape ==1)
        printf("=%s %.25Ld%s\n",BOLD,realresult,NORMAL);
    break;
    case 1: /* FLT */
    sprintf(buffer, "%-.25Lg",realresult);
    if (UseTape ==1)
        printf("=%s %.25Lg%s\n",BOLD,realresult,NORMAL);
    break;
    case 2: /* HEX */
    sprintf(buffer, "%-.25Lx",realresult);
    if (UseTape ==1)
        printf("=%s %.25Lx%s\n",BOLD,realresult,NORMAL);
    break;
    case 3: /* OCT */
    sprintf(buffer, "%-.25Lo",realresult);
    if (UseTape ==1)
        printf("=%s %.25Lo%s\n",BOLD,realresult,NORMAL);
    break;
    case 4: /* BIN */
    sprintf(buffer, "%-.25Ld",realresult);
    /* display return from atob (int) */
    if (UseTape ==1)
        printf("=%s %.25Ld%s\n",BOLD,atob(buffer),NORMAL);
    break;
    case 5: /* EXPO */
    sprintf(buffer, "%-.25Le",realresult);
    if (UseTape ==1)
        printf("=%s %.25Le%s\n",BOLD,realresult,NORMAL);
    break;
    };

    /* check for overload */
    if (stricmp(buffer,"NaN")==0)
        strcpy(buffer,"Overload !!");

    /* clean our mess */
    clear_buffers();
    clear_display();
    draw_display(buffer,NULL);
    /* we are safe to call again now */

    } /* end calculation */


} /* end do_math */


int draw_display(char *inchar, int mode)
{ /* re-draw display */
static int smode =0;

/* poss maths modes */
struct IntuiText dec_mode = {
    1, 0, JAM1, 0, 0, NULL, (UBYTE *)"DEC", NULL, };
struct IntuiText flt_mode = {
    1, 0, JAM1, 0, 0, NULL, (UBYTE *)"FLT", NULL, };
struct IntuiText hex_mode = {
    1, 0, JAM1, 0, 0, NULL, (UBYTE *)"HEX", NULL, };
struct IntuiText oct_mode = {
    1, 0, JAM1, 0, 0, NULL, (UBYTE *)"OCT", NULL, };
struct IntuiText bin_mode = {
    1, 0, JAM1, 0, 0, NULL, (UBYTE *)"BIN", NULL, };
struct IntuiText expo_mode = {
    1, 0, JAM1, 0, 0, NULL, (UBYTE *)"EXPO", NULL, };

/* display structure */
struct IntuiText display = {
    1, 0, JAM1,0, 0, NULL, (UBYTE *)inchar, NULL };

    /* store untill, user changes */
    if (mode != NULL)
    smode = mode;
    /* NULL for no change */

    /* print maths mode */
    switch (smode)
    {
    case 0: /* DEC */
    PrintIText(CalcWnd->RPort,&dec_mode,11,14);
    break;
    case 1: /* FLT */
    PrintIText(CalcWnd->RPort,&flt_mode,11,14);
    break;
    case 2: /* HEX */
    PrintIText(CalcWnd->RPort,&hex_mode,11,14);
    break;
    case 3: /* OCT */
    PrintIText(CalcWnd->RPort,&oct_mode,11,14);
    break;
    case 4: /* BIN */
    PrintIText(CalcWnd->RPort,&bin_mode,11,14);
    break;
    case 5: /* EXPO */
    PrintIText(CalcWnd->RPort,&expo_mode,11,14);
    break;
    };

    /* print display */
    if (inchar != NULL)
    PrintIText(CalcWnd->RPort,&display,11,22);

    /* NULL passed, if no change required */
    /* note we dont buffer the display buffer!! */
    /* so it needs to be re-passed, if you want */
    /* a display and/or an update */

}  /* end draw_display */


void clear_display(void)
{
/* just draw a filed rectangle over display */
/* re-calc each time for font size change */
BYTE BorderLeft = CalcWnd->BorderLeft;
BYTE BorderTop = CalcWnd->BorderTop;
BYTE BorderRight = CalcWnd->BorderRight;
BYTE BorderBottom = CalcWnd->BorderBottom;

    SetAPen(CalcWnd->RPort,4); /* dark grey */
    RectFill(CalcWnd->RPort,11,13,210,27);

    /*
    RectFill(CalcWnd->RPort,((CalcLeft+BorderLeft)+1),
                            ((CalcTop+BorderTop)+1),

                            ((CalcWidth-BorderRight)-1),
                            ((CalcHeight-BorderBottom)-1)
            );
    */

} /* end clear display */


void clear_buffers(void)
{
int x=0;
/* if erase selected or CA, we flush all internal */
/* data stores, so we can start again */

    i=0,y=0;
    flag=0;  /* pointers */
    sflag=0;

    for (x=0; x != MAX; x++) /* stores */
        { number1[x] =0;
          number2[x] =0;
        }
    /* we are safe to call again now */

} /* end clear buffers */


void draw_op(char op)
{ /* place operation on display */
struct IntuiText add = {
1, 0, JAM1,0, 0, NULL, (UBYTE *)"+", NULL };
struct IntuiText sub = {
1, 0, JAM1,0, 0, NULL, (UBYTE *)"-", NULL };
struct IntuiText div = {
1, 0, JAM1,0, 0, NULL, (UBYTE *)"/", NULL };
struct IntuiText mul = {
1, 0, JAM1,0, 0, NULL, (UBYTE *)"*", NULL };

    switch (op)
    { /* print op type */
    case '+':
    PrintIText(CalcWnd->RPort,&add,200,14);
    break;
    case '-':
    PrintIText(CalcWnd->RPort,&sub,200,14);
    break;
    case '/':
    PrintIText(CalcWnd->RPort,&div,200,14);
    break;
    case '*':
    PrintIText(CalcWnd->RPort,&mul,200,14);
    break;
    };

} /* end print op */


int atob(char *str)
/* ASCII-to-binary conversion */
{
int val;

    for (val = 0; *str; str++)
    {
    val *= 2;

    if (*str == '1')
        val++;
        else if (*str != '0')
        return(-1);
    }
    return(val);
}
