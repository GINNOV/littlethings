#define ANSIC 1
#include "iolib.h"
#include "ccfunc.h"
#include <libraries/dosextens.h>
#include <workbench/startup.h>
#include <functions.h>

long _savsp, _stkbase;

extern short _math;	 /* this is in "math.c" */
extern long blocksize;	 /* this is in blocksize.c */

struct WBStartup *WBenchMsg;
void *_oldtrap, **_trapaddr;
void (*exit_fcn)();
void *MathIeeeDoubBasBase, *CCLibBase, *SysBase, *DOSBase, *MathBase;
FILE *stdin, *stdout, *stderr;
long errno;
char *type;

void _main(long alen, char *aptr)
{
register task_UserData *ud;
register struct Process *ThisProcess;
void main(long,char **);

/* This stuff is needed for the Aztec C compiler */
_stkbase = _savsp - *((long *)_savsp+1) + 8;
*(long *)_stkbase = 0x4d414e58L;

ThisProcess = (struct Process *)FindTask(NULL);

/* Get the Workbench Message if this program is being executed
 * from the workbench. */
if( !ThisProcess->pr_CLI )
   {
   WaitPort((struct MsgPort *)&ThisProcess->pr_MsgPort);
   WBenchMsg = (struct WBStartup *)
	       GetMsg((struct MsgPort *)&ThisProcess->pr_MsgPort);
   }

/* Open the C library */
if( !(CCLibBase = OpenLibrary(CCLIBNAME,0L)) )
   goto abort;

if( _math )  /* open up the Ieee math library */
   if( !(MathIeeeDoubBasBase = OpenLibrary("mathieeedoubbas.library",0L)) )
      goto abort;

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
main((long)ud->_argc, ud->_argv);

abort:
_exit(0L);
}


void _exit( long code )
{
long rv = code;
if( exit_fcn )
   (*exit_fcn)();
if( _trapaddr ) /* clean up signal handling */
   *_trapaddr = _oldtrap;

if( MathIeeeDoubBasBase )
   CloseLibrary( MathIeeeDoubBasBase );

if( CCLibBase )
   {
   ClearSTDIO();
   CloseLibrary(CCLibBase);
   }

/* This stuff is needed for the Aztec C compiler */
   {
#asm
   move.l  -4(a5),d0
   move.l  __savsp#,sp
   rts
#endasm
   }
}

void exit( long code )
{
void _exit();
_exit(code);
}






