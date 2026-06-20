/*        window.c
   or, how to open a DOS window in a custom screen
   and do something like format a disk
   (c) 1986 Commodore-Amiga, Inc.
   This file may be used in any manner, as long as this copyright notice
   remains intact.
  		andy finkel
 		Commodore-Amiga
*/
#include "exec/types.h"
#include "exec/libraries.h"
#include "graphics/gfx.h"
#include "intuition/intuition.h"
#include "libraries/dos.h"
#include "libraries/dosextens.h"

#define BLUE 0 
#define WHITE 1 
#define BLACK 2 
#define RED 3 

struct GfxBase *GfxBase; 
LONG *IntuitionBase;
LONG *DosBase;

extern struct Library *OpenLibrary();
extern struct Screen *OpenScreen();
extern struct Window *OpenWindow();

extern struct MsgPort  *NewConsole();

struct Window   *window=NULL;
struct Screen   *screen=NULL;
struct MsgPort  *task=NULL;
struct Process  *process=NULL;

LONG handle=NULL;

struct NewScreen ns = {
        0,0,
        320,200,4, /* & depth */
        BLUE,WHITE,
        NULL,  /* viewmodes */
        CUSTOMSCREEN,
        NULL, /* default font */
        "Window Test Program",
        NULL, /* no user gadgets */
        NULL
};

struct NewWindow nw = {
        0, 12,          /* starting position (left,top) */
        320,186,        /* width, height */
        BLUE,WHITE,    /* detailpen, blockpen */
        NULL,  /* flags for idcmp */
        SMART_REFRESH|WINDOWDEPTH|WINDOWSIZING|WINDOWDRAG|ACTIVATE, /* window gadget flags */
        NULL,           /* pointer to 1st user gadget */
        NULL,           /* pointer to user check */
        NULL,            /* no title */
        NULL,           /* pointer to window screen (add after it is open */
        NULL,           /* pointer to super bitmap */
        50,50,         /* min width, height */
        320,200,        /* max width, height */
        CUSTOMSCREEN};

main()
{
if((IntuitionBase = OpenLibrary("intuition.library",0)) == NULL)cleanup(20);
if((DosBase = OpenLibrary(DOSNAME, 0)) == NULL) cleanup(20);
if((GfxBase = OpenLibrary("graphics.library", 0)) ==NULL) cleanup(20);

if((screen=OpenScreen(&ns)) == NULL)cleanup(20);
nw.Screen=screen;
if((window=OpenWindow(&nw)) == NULL)cleanup(20); 

/* Start up new console handler task; pass it new window */

if(!(task = NewConsole(window)))cleanup(20);

/* Change AmigaDOS consoletask location. All later calls to */
/* Open("*") by this process will refer to the new window */

process = (struct Process *)FindTask(NULL); 
process -> pr_ConsoleTask = task;

process->pr_WindowPtr=window; /*reset error screen so requesters appear here*/

if (!(handle = Open("*", MODE_OLDFILE))) { /* get a handle on the window */
    CloseConsole(task); /* open failed, kill our console task */
    cleanup(20);
   }

    Write(handle,"\033[20hHello world\n",17);

    Write(handle,"I'm about to format drive 1\n",28);
/* SAMPLE COMMAND; THIS IS OPTIONAL, FOR DEMO PURPOSES ONLY) */
	Execute("format <* >* drive df1: name test",0,0);

	cleanup(0);
}


cleanup(code)
{
struct Process *process;

process = (struct Process *)FindTask(NULL); /* reset error window */
process->pr_WindowPtr=NULL;
process -> pr_ConsoleTask = NULL;;

if(handle)Close(handle);
if(screen)CloseScreen(screen);

if(GfxBase)CloseLibrary(GfxBase);
if(DosBase)CloseLibrary(DosBase);

OpenWorkBench(); /* just in case */
if(IntuitionBase)CloseLibrary(IntuitionBase); 

exit(code);

}
/* end of file window.c */
