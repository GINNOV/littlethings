#ifndef IOLIB_H
#define IOLIB_H 1

/*-------------------------------------------------------------------------+
 |									   |
 | Name:    iolib.h							   |
 | Purpose: the structure that gets attached to your task's user data      |
 |									   |
 | Author:  RWA 				   Date: 8/89		   |
 +-------------------------------------------------------------------------*/

#ifndef EXEC_MEMORY_H
#include <exec/memory.h>
#endif

#ifndef LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif

#ifndef LIBRARIES_DOSEXTENS_H
#include <libraries/dosextens.h>
#endif

#ifndef EXEC_TASKS_H
#include <exec/tasks.h>
#endif

#ifndef WORKBENCH_STARTUP_H
#include <workbench/startup.h>
#endif

#ifndef STDLIST_H
#include "stdlist.h"
#endif

#ifndef HEAPMEM_H
#include "heapmem.h"
#endif

#ifndef STDIO_H
#include "stdio.h"
#endif

#ifndef TIME_H
#include "time.h"
#endif

typedef void (*ABORT_FUNC)(long);



typedef struct	/* task_UserData */
{
void *old_ud;			 /* points to the old user data */
struct Task *parent;		 /* points to your task */
_list RAM;			 /* list of allocated memory, see MemBlk */
HEADER base, *allocp;		 /* used for heap managment */
long *blocksize;		 /* points to minimum heap block size */
LastFree lastfree;		 /* the last free'd block of heap memory */
_list OpenFiles;		 /* a list of FileDesc, see below */
_list StreamFiles;		 /* a list of FILE, see stdio.h */
FILE **stdout, **stdin, **stderr;/* pointers to standard IO stream files */
void *scnfp;			 /* used internally by fprintf etc. */
long *errno;			 /* pointer to global errno in app. */
ABORT_FUNC abort_func;		 /* abort function for ^C etc. (_exit) */
void *wbmsg;			 /* pointer to workbench startup message */
short _argc, _arg_len;		 /* for CLI arguments */
char **_argv, *_arg_lin;	 /* for CLI arguments */
char *scanpoint;		 /* used internally by strtok */
char *tempname; 		 /* used internally by tmpnam */
short scnlast;			 /* used internally by gchar etc. */
struct tm tm;			 /* used by time routines */
clock_t start;			 /* ticks at program start */
char buffer[80];		 /* buffer for general use */
void *scdir_mem;		 /* memory used by scdir */
void *getenv_mem;		 /* used internally by getenv */
struct MsgPort *exeport;	 /* message port for exe'd processes */
_list Children; 		 /* list of children (struct Child) */
} task_UserData;

/* This is a what a "file handle" points to, I am cheating by
 * putting pointers to this in a long integer.
 */
typedef struct
{
BPTR fh;
short mode;
} FileDesc;

/* This is what the RAM list consists of. It is a linked list of RAM
 * that has been allocated from Amiga EXEC with the AllocMem function.
 * The size field is the size in bytes that was allocated, and is followed
 * by the allocated block.
 */
typedef struct
{
_node n;
long size;
} MemBlk;

/* This is what the Chidren _list consists of. It is a list of the child
 * processes that were spawned asynchronously, and that need to have their
 * code unloaded before the parent can terminate itself.
 */
typedef struct
{
struct WBStartup startup;     /* startup message sent to the child */
struct WBArg arg;	      /* startup message argument */
struct Process *pid;	      /* pointer to the child process */
} Child;

#ifndef REGS
#define REGS register
#endif

#endif


