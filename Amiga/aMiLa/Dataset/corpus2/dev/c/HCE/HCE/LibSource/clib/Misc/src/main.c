/*
 * This startup code is called from both the CLI and from Workbench.  If
 * from WorkBench, argc is 0 and the argv parameter points to
 * a WBStartup type of structure.
 *
 * Modified by Jason Petty ,marked J.P. */

#include <exec/types.h>
#include <exec/alerts.h>
#include <exec/memory.h>
#include <libraries/dosextens.h>
#include <workbench/startup.h>
#include <stdio.h>
#include <fcntl.h>

#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0L
#endif

extern long SysBase;		/* Used by exec functions */
extern long DOSBase;		/* Required by AmigaDos functions. */
extern long AbsExecBase;	/* Address of Exec base. */
extern int errno;
extern int _argc;
extern char **_argv;
long IntuitionBase=0;            /* Need Inutition Lib open. J.P. */


int Enable_Abort;
struct WBStartup *WBenchMsg;
typedef struct _device DEVICE;
DEVICE *_devtab;

void (*_fcloseall)();
void (*_freeall)();
void (*_closeall)();
void (*_MathBaseClose)();
void (*_MathTransClose)();

FILE	_iob[OPEN_MAX];	/* stream buffers */

static FILE	startup[] =	/* standard stream files */
	{
/* stdin */	{0, NULL, NULL, (_IOREAD | _IOFBF), 0, 0, '\0'},
/* stdout */	{0, NULL, NULL, (_IOWRT | _IOFBF), 1, 0, '\0'},
/* stderr */	{0, NULL, NULL, (_IOWRT | _IOFBF), 2, 0, '\0'}
	};

	long
_main(length, ptr)
long length;		/* Length of the command string */
char *ptr;		/* Command line (BCPL format)   */
{
	void exit();
	register FILE *f;
	register int i, rv;
	struct Process *taskPtr;
	struct WBArg *wp;
	extern struct Process *FindTask();
	extern void *OpenLibrary(), *GetMsg(), *AllocMem();
	extern long Input(), Output(), Open();
	extern void CurrentDir(), Alert(), CloseLibrary(), _exit();

	/*
	 * Let Exec and AmigaDos know where to find things.
	 */
	SysBase = AbsExecBase;
	if ( (DOSBase = (long)OpenLibrary( "dos.library", 0L )) == 0 ){
		Alert( AG_OpenLib|AO_DOSLib, 0L );
		_exit( 12L );
		}

    /* Open Intuition Library for the alert functions in math.lib. J.P. */
	if (!(IntuitionBase = (long)OpenLibrary("intuition.library",0)))
                          {
                           Alert( AG_OpenLib|AO_Intuition, 0L );                          
		           CloseLibrary( DOSBase );
                           _exit( 12L );
                           }
	/*
	 * Allocate space for the device table.  (Used for lower level
	 * i/o open(), close(), read(), write() etc. functions.
	 */

	_devtab = (DEVICE *)malloc( (int)(OPEN_MAX*sizeof(struct _device)) );
	if ( _devtab == (DEVICE *)NULL){
		Alert(AG_NoMemory, 0L);
		CloseLibrary( DOSBase );
		_exit(12L);
	}

	_devtab[0].mode = O_RDONLY | O_STDIO;	/* stdin */
	_devtab[1].mode = O_WRONLY | O_STDIO;	/* stdout */
	_devtab[0].fileHandle = Input();
	_devtab[1].fileHandle = Output();

	/*
	 * Parse the command line.  Method depends on whether we are
	 * running under the CLI or under Workbench.
	 */

	taskPtr = FindTask(0L);
	if (taskPtr->pr_CLI != 0) {
		_cli_parse(taskPtr, length, ptr);
		Enable_Abort = 1;
	}
	else {
		WaitPort(&taskPtr->pr_MsgPort);
		WBenchMsg = (struct WBStartup *)GetMsg(&taskPtr->pr_MsgPort);
		if (WBenchMsg->sm_ArgList) {
			wp = WBenchMsg->sm_ArgList;
			CurrentDir(wp->wa_Lock);
		}
		_wb_parse(taskPtr, WBenchMsg);
		_argv = (char **)WBenchMsg;
	}

	if ( _devtab[1].fileHandle ) {
		_devtab[2].fileHandle = Open("*", MODE_OLDFILE);
		_devtab[2].mode |= O_WRONLY;	/* stderr */
	}

	/*
	 * Initialize device streams.
	 */

	memcpy( _iob, startup, sizeof startup );
	for(i = 0, f = _iob; i < 3; ++i, ++f)	/* flag device streams */
		if(isatty(f->_file))
			f->_flag |= _IODEV;

	main(_argc, _argv);			/* if main() returns... */
	exit(EXIT_SUCCESS);			/* ...exit with OK status */
}

/*
 * Cleanup and exit.
 */

void exit(status)
int status;		
{
	int fd;

	if ( _fcloseall)
		(*_fcloseall)();

	if ( _closeall)
		(*_closeall)();

	if ( _freeall)
		(*_freeall)(); /* Free any malloc()ed memory */	

	if ( _MathBaseClose )
		(*_MathBaseClose)();

	if ( _MathTransClose )
		(*_MathTransClose)();
        if ( IntuitionBase )
                CloseLibrary( IntuitionBase );

	if ( DOSBase )
		CloseLibrary( DOSBase );

	if ( WBenchMsg != NULL ) {
		Forbid();
		ReplyMsg(WBenchMsg);
	}

	_exit ((long)status);
}
