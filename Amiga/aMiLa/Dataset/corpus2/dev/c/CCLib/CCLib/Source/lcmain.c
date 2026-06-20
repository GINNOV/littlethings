/*-------------------------------------------------------------------------+
 |									   |
 | Name:    lcmain.c							   |
 | Purpose: C startup code replacement for Lattice			   |
 |									   |
 | Author:  RWA 				   Date: 9/89		   |
 +-------------------------------------------------------------------------*/

#include "iolib.h"
#include "ccfunc.h"
#include <libraries/dosextens.h>
#include <workbench/startup.h>

extern short _math;	 /* this is in "math.c" */
extern long blocksize;	 /* this is in blocksize.c */

extern struct WBStartup *WBenchMsg;
void (*exit_fcn)();
void *CCLibBase;
/* Resolve this reference from the library. */
extern void *MathIeeeDoubBasBase;
FILE *stdin, *stdout, *stderr;
long errno, argc;
char *type;
static short _mathopen;

void _main(aptr)
char *aptr;  /* A NULL terminated string is passed in Lattice */
{
extern void _exit();
struct Task *FindTask();
struct Library *OpenLibrary();
struct Message *GetMsg();
void WaitPort();
register task_UserData *ud;
register struct Process *ThisProcess;
register long alen;

/*		   WARNING
 * This checks to make sure that the modified version of
 * c.o (cc.o) is being used. This is for Lattice C only
 * because the workbench is handled completly by CClib.library
 * and the workbench handling code in c.o will crash the system
 * if it is used. The problem will only occur if the program is
 * executed from the workbench.
 */
if( WBenchMsg )
   XCEXIT(100L);

/* Get the Workbench Message if this program is being executed
 * from the workbench.
 */
ThisProcess = (struct Process *)FindTask(0L);
if( !ThisProcess->pr_CLI )
  {
  WaitPort(&ThisProcess->pr_MsgPort);
  WBenchMsg = (struct WBStartup *)GetMsg(&ThisProcess->pr_MsgPort);
  }

/* __fpinit sould always be done AFTER the workbench message
 * has been taken from the task's message port.
 */
__fpinit();


/* Open the C library */
if( !(CCLibBase = OpenLibrary(CCLIBNAME,0L)) )
   goto abort;

/* Get the length of the argument string, this must be done after opening
 * CClib.library or else the reference to strlen will be unresolved. */
alen = strlen(aptr);

if( _math )  /* open up the Ieee math library */
   {
   if( !MathIeeeDoubBasBase )
     /* May have been already done by Lattice, and
      * usually is if you are using the supplied startup
      * code.
      */
      {
      if( !(MathIeeeDoubBasBase =
	 OpenLibrary("mathieeedoubbas.library",0L)) )
      goto abort;
      }
   else
      _mathopen = 1; /* Math library was opened by Lattice */
   }


/* Do some further initialization of the task specific structures.
 * This will:
 *
 * 1) Initialize the task_UserData structure.
 * 2) Parse the command line arguments or the Workbench message.
 * 3) Open standard stream IO for the application.
 * 4) Set up pointers to errno, and blocksize.
 * 5) Give the library a pointer to the Ieee math library if opened above.
 * 6) Set the standard abort function.
 */
if( !SetupSTDIO(&stdin,&stdout,&stderr,
    &errno,&blocksize,&type,MathIeeeDoubBasBase,alen,aptr,WBenchMsg,_exit) )
   goto abort;

/* get a pointer to this task's user data structure */
ud = GetSTDIO();

/* application entry point */
main(ud->_argc, ud->_argv);

abort:
_exit(0L);
}

void CloseLibrary();

void _exit(code)
long code;
{
if( exit_fcn )
   (*exit_fcn)();

if( MathIeeeDoubBasBase && (!_mathopen) )
   CloseLibrary( MathIeeeDoubBasBase );

if( CCLibBase )
   {
   ClearSTDIO();
   CloseLibrary(CCLibBase);
   }

/* This jumps into the Lattice startup code. */
XCEXIT(code);
}

void exit(code)
long code;
{
void _exit();
_exit(code);
}






