/* ------------------------------------------------------------------
 $VER: calc.supp.c 1.01 (28.01.1999)

 support program functions

 (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
 amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------------ */

#include <dos/dos.h>
#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include "Calc.h"

void Shutdown(void)
{ /* program shutdown and garbage collector */

    CloseGraphWindow(); /* it might be left open */
    CloseCalcWindow();  /* is safe cos, they only close whats open */
    CloseDownScreen();
    exit(0);
}

/* --------------------- */
/* these just return the */
/* number pressed (wow)  */
/* --------------------- */

int Gadget00Clicked( void )
{ /* routine when gadget "1" is clicked. */
do_math('1'); }

int Gadget10Clicked( void )
{ /* routine when gadget "2" is clicked. */
do_math('2'); }

int Gadget20Clicked( void )
{ /* routine when gadget "3" is clicked. */
do_math('3'); }

int Gadget30Clicked( void )
{ /* routine when gadget "4" is clicked. */
do_math('4'); }

int Gadget40Clicked( void )
{ /* routine when gadget "5" is clicked. */
do_math('5'); }

int Gadget50Clicked( void )
{ /* routine when gadget "6" is clicked. */
do_math('6'); }

int Gadget60Clicked( void )
{ /* routine when gadget "7" is clicked. */
do_math('7'); }

int Gadget70Clicked( void )
{ /* routine when gadget "8" is clicked. */
do_math('8'); }

int Gadget80Clicked( void )
{ /* routine when gadget "9" is clicked. */
do_math('9'); }

int Gadget90Clicked( void )
{ /* routine when gadget "0" is clicked. */
do_math('0'); }


/* --------------------------- */
/* here we have IDCMP handlers */
/* --------------------------- */

int CalcCloseWindow( void )
{ /* routine for "IDCMP_CLOSEWINDOW" */
return(-1); /* i want to go */
}

int GraphCloseWindow( void )
{ /* routine for "IDCMP_CLOSEWINDOW" */
return(-1); /* close me ! */
}


int CalcRawKey( void )
{ /* routine for "IDCMP_RAWKEY" */
UWORD code = CalcMsg.Code;
UWORD qual = CalcMsg.Qualifier; /* from raw key */

/* ------------------------------ */
/* handling for special values    */
/* checks for R/L Amiga key press */
/* ------------------------------ */

// printf("qual (%d)\n",qual);

if( (qual &= IEQUALIFIER_LCOMMAND) ||
    (qual &= IEQUALIFIER_RCOMMAND)
  )

  { /* user pressed alt, so if we */
    /* have a key we can pull menu item */

    switch (code)
    {
    case '?': /* about */
    CalcItem0();
    break;

    case 'q': /* quit */
    CalcItem1();
    break;

    case 'x': /* cut */
    CalcItem2();
    break;

    case 'c': /* copy */
    CalcItem3();
    break;

    case 'v': /* paste */
    CalcItem4();
    break;

    case 'd': /* erase */
    CalcItem5(); 
    break;

    case 't': /* show tape */
    CalcItem6();
    break;

    case 'g': /* show graph */
    CalcItem7();
    break;
    }; /* end switch */

  } /* end amiga key press */

} /* end IDCMP_RAWKEY control */


int CalcVanillaKey( void )
{ /* routine for "IDCMP_VANILLAKEY" */
UWORD code = CalcMsg.Code;

/* key pressed (after keymap filter) */
// printf("char %c\n",CalcMsg.Code);

/* ------------------------ */
/* now we check for numbers */
/* ------------------------ */

    switch (code)
    {
    case '0':
    do_math('0');
    break;
    case '1':
    do_math('1');
    break;
    case '2':
    do_math('2');
    break;
    case '3':
    do_math('3');
    break;
    case '4':
    do_math('4');
    break;
    case '5':
    do_math('5');
    break;
    case '6':
    do_math('6');
    break;
    case '7':
    do_math('7');
    break;
    case '8':
    do_math('8');
    break;
    case '9':
    do_math('9');
    break;

/* ---------------------------- */
/* then we check for operations */
/* ---------------------------- */

    case '-':
    do_math('-');
    break;
    case '+':
    do_math('+');
    break;
    case '/':
    do_math('/');
    break;
    case '*':
    do_math('*');
    break;
    case '(':
    do_math('(');
    break;
    case ')':
    do_math(')');
    break;
    case '.':
    do_math('.');
    break;
    case '<':
    do_math('<');
    break;
    case '=':
    do_math('=');
    break;
    case 13: /* carrage return ascii */
    do_math('=');
    };

/* end key checks */
}
