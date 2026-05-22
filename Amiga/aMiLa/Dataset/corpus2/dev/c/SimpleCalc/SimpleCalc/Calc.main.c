/* -----------------------------------------------------------
  $VER: calc.main.c 1.01 (28.01.1999)

  startup and functions for calculator project

  (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
  amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
  ------------------------------------------------------------ */

#include <stdio.h>
#include <string.h>

#include <exec/types.h>
#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <intuition/gadgetclass.h>

#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>

#include "Calc.h"

/* some globals - why, cos its easy */
/* others are extern from here */
int UseTape =1;  /* on */
int mode = 1; /* flt */
/* calc display & memory */
char buffer[100];
char memory1[100];

/* amiga version number */
UBYTE *vers = "$VER: Calc v1.01 - © Matthew J Fletcher 2000";

/* ------------------------------------------------------------- */
/* Please note that, this code has been written under gcc libnix */
/* as such it uses auto-library opening and other nice features  */
/* that some amiga compilers do not support. I have explicitly   */
/* opened libs that are not in 3.x ROM, as thats the minimum     */
/* that any decent compiler should support. DICE / GCC-Libnix /  */
/* StormC and perhaps others (allthough i cant be sure) will be  */
/* just fine. -matt                                              */
/* ------------------------------------------------------------- */

int wbmain(void)
{ /* dummy to call main if run from workbench */
    main();
}

int main (void)
{ /* workbench startup & entry point */
int result;

    /* ------------------------ */
    /* open in nice safe manner */
    /* ------------------------ */

    if (SetupScreen() != 0) /* something broke */
       {
       CloseDownScreen();
       exit(20);
       } /* close anything we might have opened */

    if (OpenCalcWindow() != 0)
       {
       CloseCalcWindow();
       CloseDownScreen();
       exit(20);
       } /* close anything we might have opened */

    /* draw inital values & mode to display */
    clear_buffers();          /* clean internal buffers */
    clear_display();          /* clean calc display */
    draw_display("0.0",mode); /* zero of course & defult mode */

    /* ------------------------ */
    /* watch what the user does */
    /* ------------------------ */

    /* we will quit when we get -1 (they clicked quit gadget) */
    do {
       /* do gui processing */
       result = HandleCalcIDCMP();

       } while (result != -1); /* a break */


   /* a seperate procedure will have to call Shutdown() */
   /* to quit - WE dont handle it here */
   Shutdown();
}

/* ------------------------ */
/* these perform some kind  */
/* of calc function.        */
/* ------------------------ */


int Gadget100Clicked( void )
{ /* routine when gadget "MR" is clicked. */
strcpy(buffer,memory1); /* copy in */
clear_display();
draw_display(buffer,NULL);
}

int Gadget110Clicked( void )
{ /* routine when gadget "Min" is clicked. */
strcpy(memory1,buffer); /* copy out */
clear_display();
draw_display(buffer,NULL);
}

int Gadget120Clicked( void )
{ /* routine when gadget "CA" is clicked. */

/* clear all */
clear_buffers();
clear_display();
draw_display("0.0",NULL);
}

int Gadget130Clicked( void )
{ /* routine when gadget "." is clicked. */
do_math('.'); }

int Gadget140Clicked( void )
{ /* routine when gadget "<" is clicked. */
do_math('<'); }

int Gadget150Clicked( void )
{ /* routine when gadget "*" is clicked. */
do_math('*'); }

int Gadget160Clicked( void )
{ /* routine when gadget "/" is clicked. */
do_math('/'); }

int Gadget170Clicked( void )
{ /* routine when gadget "+" is clicked. */
do_math('+'); }

int Gadget180Clicked( void )
{ /* routine when gadget "-" is clicked. */
do_math('-'); }

int Gadget190Clicked( void )
{ /* routine when gadget "-/+" is clicked. */
}

int Gadget200Clicked( void )
{ /* routine when gadget "=" is clicked. */
do_math('='); }

int Gadget210Clicked( void )
{ /* routine when gadget "(" is clicked. */
do_math('('); }

int Gadget220Clicked( void )
{ /* routine when gadget ")" is clicked. */
do_math(')'); }

int Gadget230Clicked( void )
{ /* routine when gadget cycle is clicked. */
long picked;
/* get cycle mode and pass */
GT_GetGadgetAttrs(CalcGadgets[230], CalcWnd, NULL,
                  GTCY_Active, &picked,
                  TAG_DONE);

printf("mode picked is %ld \n",&picked);
/* re-draw display */
clear_display();
draw_display(buffer,picked);
}


/* ---------------------------- */
/* these are the menu functions */
/* ---------------------------- */


int CalcItem0( void )
{ /* routine when (sub)item "About" is selected. */
int result;

struct EasyStruct buffy = {
sizeof(struct EasyStruct),
NULL,
"About Requestor",
"This simple calculator is rubbish !,
Do not use under any curcumstances!,
or you will live in hell!\n\n
A Simple Calculator\n© Matthew J Fletcher 2000\n
amimjf@connectfree.co.uk",
"Ok Matthew|Show Legal",
};

/* show it */
result = EasyRequestArgs(NULL,&buffy,NULL,NULL);

if (result == 0) /* legal */
{
struct EasyStruct buff = {
sizeof(struct EasyStruct),
NULL,
"Legal Section",
"CONSUMER NOTICE: Because of the uncertainty principle, it is
impossible for the consumer to find out at the same time both
precisely where this product is and how fast it is moving.

THIS IS A 100% MATTER PRODUCT: In the unlikely event that
this merchandise should contact antimatter in any form, a
catastrophic explosion will result.

ATTENTION: Despite any other listing of product contents
found hereon, the consumer is advised that, in actuality,
this product consists of 99.9999999999% empty space.

PLEASE NOTE: Some quantum physics theories suggest that
when the consumer is not directly observing this product,
it may cease to exist or will exist only in a vague and
undetermined state.

IMPORTANT NOTICE TO PURCHASERS: The entire physical universe,
including this product, may one day collapse back into an
infinitesimally small space. Should another universe
subsequently re-emerge, the existence of this product in
that universe cannot be guaranteed.

I cannot be held responsible for this, or the consequences
of my own actions. - Matthew J Fletcher 2000",
"Ok",
};

/* pop requestor */
EasyRequestArgs(NULL, &buff, NULL, NULL);
}/* end if */

} /* end about requestor */


int CalcItem1( void )
{ /* routine when (sub)item "Quit" is selected */
int result;
struct EasyStruct buffy = {
    sizeof (struct EasyStruct),
    0,
    "Quit Confermation",
    "Are you sure you wish to quit the calculator ?",
    "Quit|Cancel",
    };
    /* pop requestor */
    result = EasyRequestArgs(NULL, &buffy, NULL, NULL);

    if (result ==1)
        Shutdown(); /* they want to quit */

    /* otherwise nothing */
}


int CalcItem2( void )
{ /* routine when (sub)item "Cut" is selected. */

/* write string to clipboard */
if (WriteClip(buffer) !=0) /* damn */
    printf("Clipboard broke ! (cut/copy)\n");

/* clear display */
clear_display();
draw_display("0.0",NULL);

} /* end cut */


int CalcItem3( void )
{ /* routine when (sub)item "Copy" is selected. */

/* write string to clipboard */
if (WriteClip(buffer) !=0) /* damn */
    printf("Clipboard broke ! (cut/copy)\n");

} /* end copy */


int CalcItem4( void )
{ /* routine when (sub)item "Paste" is selected. */

/* get string from clipboard */
if (ReadClip(buffer) !=0)
    printf("Clipboard broke ! (paste)\n");

} /* end paste */


int CalcItem5( void )
{ /* routine when (sub)item "Erase" is selected. */

/* clear display */
clear_buffers();
clear_display();
draw_display("0.0",NULL);
}


int CalcItem6( void )
{ /* routine when (sub)item "Show Tape" is selected. */

    /* toggle global printf output */
    if (UseTape == 0)
        UseTape = 1;

    else /* if 1 */
        UseTape = 0;
} /* end show tape */


int CalcItem7( void )
{ /* routine when (sub)item "Show Graphic" is selected. */
int result;
time_t time_now;
char tbuffer[100];

    /* ------------------------ */
    /* open in nice safe manner */
    /* ------------------------ */

    if (OpenGraphWindow() != 0)
       {
       CloseGraphWindow();
       } /* close anything we might have opened */


    /* do our stuff */
    //GraphWnd->RPort;

    do {
    //do_graph(rastport);

    /* fiddle with window title */
    time(&time_now);
    sprintf(tbuffer, "%s", ctime(&time_now));
    SetWindowTitles(GraphWnd,(UBYTE *)tbuffer,-1);

    /* check user */
    result = HandleGraphIDCMP();
    } while (result != -1);

    CloseGraphWindow();
} /* end show graph */

