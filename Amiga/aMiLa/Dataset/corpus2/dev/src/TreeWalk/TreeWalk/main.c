/*
 * treewalk - a command to get the power of treewalk out to the CLI.
 *
 *	Copyright (C) 1989  Mike Meyer
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 1, or any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <exec/types.h>
#include <libraries/dos.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "treewalk.h"
#include "errors.h"

/*
 * Filter parsing functions, prototypes thereof. The "void *"'s are a lie,
 * but they serve their purpose.
 */
void *parse(char *) ;
long execute(struct FileInfoBlock *, void *) ;

/* Flags needed by the visit function, to help it decide what to do */
static int	singlearg = FALSE, verbose = FALSE, ignore = FALSE ;
static void	*code = NULL ;

/* Things visible to other files */
char	*my_name ;
int	errorflag = ERROR_NONE ;

/*
 * And the functions I need from below.
 */
static int	dofiles(long, struct FileInfoBlock *) ;

/*
 * We need storage for the duration of a filter execution. We use
 * the RememberKey and free it after the execution.
 */
static struct Remember *filterstrings = NULL ;

/*
 * Things for dealing with a issuance of commands
 */
#define COMMAX	240	/* WShell is 240, stock would be 256 */
static char	command[COMMAX] = "", *commnext = command, *commend ;

static void
growcommand(char *stuff, int pad) {

	strcpy(commnext, stuff) ;
	commnext += strlen(stuff) ;
	if (!pad) return ;
	*commnext++ = ' ' ;
	*commnext = '\0' ;
	}

static void
endcommand(void) {

	commend = commnext ;
	}

static void
docommand(void) {

	if (verbose) fprintf(stderr, "Executing: %s\n", command) ;
	Execute(command, NULL, Output()) ;
	if (!ignore && IoErr()) {
		errorflag = ERROR_WARN ;
		if (verbose) fprintf(stderr, "Error from command\n") ;
		else fprintf(stderr, "Error from command '%s'\n", command) ;
		}
	*commend = '\0' ;
	commnext = commend ;
	}

void
main(int argc, char **argv) {
	int	treeflags = TREE_PRE, stat ;
	char	*rootdir = "", *filter = NULL ;
	BPTR	root ;

	/* Just so we can use the Rememberkey stuff... */
	if ((IntuitionBase = (struct IntuitionBase *)
		OpenLibrary("intuition.library", 0L)) == NULL) {
			fprintf(stderr, "%s: No intuition library!", my_name) ;
			exit(RETURN_FAIL) ;
			}
	
	my_name = argv[0] ;

	/* Argument parsing time again... */
	while (*++argv)
		if (!strcmp(*argv, "?")) {
			fprintf(stderr, "usage: %s [options] [command]\n", my_name) ;
			fprintf(stderr, "options: [post|both] [single] [verbose] [ignore] [dir <dir>] [filter <filter>] [command]\n") ;
			CloseLibrary((struct Library *) IntuitionBase) ;
			exit(RETURN_OK) ;
			}
		else if (!strnicmp(*argv, "single", 3)) singlearg = TRUE ;
		else if (!strnicmp(*argv, "verbose", 3)) verbose = TRUE ;
		else if (!strnicmp(*argv, "ignore", 3)) ignore = TRUE ;
		else if (!strnicmp(*argv, "post", 3)) treeflags = TREE_POST ;
		else if (!strnicmp(*argv, "both", 3)) treeflags = TREE_BOTH ;
		else if (!strnicmp(*argv, "dir", 3)) rootdir = *++argv ;
		else if (!strnicmp(*argv, "filter", 3)) filter = *++argv ;
		else if (!strnicmp(*argv, "command", 3)) {
			argv += 1 ;
			break ;
			}
		else break ;	/* Start of command */

	/* Check for filter */
	if (filter) {
		if ((code = parse(filter)) == NULL) {
			fprintf(stderr, "%s: exiting\n", my_name) ;
			CloseLibrary((struct Library *) IntuitionBase) ;
			exit(RETURN_ERROR) ;
			}
		if (filterstrings) {
			FreeRemember(&filterstrings, FALSE) ;
			filterstrings = NULL ;
			}
		}

	/*
	 * Now, stack up commands. Command is large enough to hold any valid
	 * command, so it must be large enough to hold the tail of this one.
	 */
	while (*argv)
		growcommand(*argv++, TRUE) ;
	endcommand() ;

	if ((root = Lock(rootdir, ACCESS_READ)) == NULL) {
		fprintf(stderr, "%s: Can't lock %s\n", my_name, rootdir) ;
		CloseLibrary((struct Library *) IntuitionBase) ;
		exit(RETURN_ERROR) ;
		}

	treewalk(root, dofiles, treeflags) ;
	UnLock(root) ;

	/* Clean up any leftover commands */
	if (*commend) docommand() ;

	/* Tell the user how we exited, if need be */
	switch (errorflag) {
	    case ERROR_BREAK: printf("*** Break: %s\n", my_name) ;
		/* Fall through to next case */

	    case ERROR_NONE: stat = 0;
		break ;

	    case ERROR_WARN: stat = RETURN_WARN ;
		break ;

	    case ERROR_HALT: stat = RETURN_ERROR ;
		fprintf(stderr, "%s: Execution halting\n", my_name) ;
		break ;
	    }
	CloseLibrary((struct Library *) IntuitionBase) ;
	exit(stat) ;
	}

/*
 * And now, where all the work is really done. Various things for dealing
 * filtering out files, getting their true name, and building & executing
 * commands.
 */

/*
 * pathname code: is either a valid pathname, or a "". Getpathname makes it
 * hold the right thing, or return TRUE ;
 */
static char	pathname[FMSIZE] = "" ;

static int
getpathname(BPTR lock) {

	if (getpath(lock, pathname)) {
		fprintf(stderr, "%s: Failure in getting full path name!\n",
			my_name) ;
		*pathname = '\0' ;
		errorflag = ERROR_HALT ;
		return TRUE ;
		}
	strcat(pathname, strchr(pathname, ':') == NULL ? ":" : "/") ;
	return FALSE ;
	}

/*
 * Some globals for use by the primitives below. The values don't change
 * during one filter execution, so it don't matter much.
 */
static BPTR			lock_global ;

/*
 * The visit function - where all the work is actually done...
 */
static int
dofiles(BPTR lock, struct FileInfoBlock *fib) {
	int	status ;

	/* First, check to see if we need to stop */
	if (errorflag == ERROR_HALT) return TREE_STOP ;

	if (SetSignal(0, 0) & SIGBREAKF_CTRL_C) {
		errorflag = ERROR_BREAK ;
		return TREE_STOP ;
		}

	/* Start a new directory */
	if (fib == NULL) {
		/* flush path */
		pathname[0] = '\0' ;
		return TREE_CONT ;
		}

	/* See if we want to deal with this file */
	if (code) {
		lock_global = lock ;
		status = !execute(fib, code) ;
		if (filterstrings) {
			FreeRemember(&filterstrings, TRUE) ;
			filterstrings = NULL ;
			}
		if (status) return TREE_CONT ;
		}

	/* We do, so if we don't have it yet, get it's full name */
	if (!*pathname && getpathname(lock)) return TREE_STOP ;

	/* print it if nothing better to do */
	if (!*command) {
		printf("%s%s\n", pathname, fib->fib_FileName) ;
		return TREE_CONT ;
		}

	/* Deal with easy commands - just one argument! */
	if (singlearg) {
		growcommand("\"", FALSE) ;
		growcommand(pathname, FALSE) ;
		growcommand(fib->fib_FileName, FALSE) ;
		growcommand("\"", FALSE) ;
		docommand() ;
		return TREE_CONT ;
		}

	/* Otherwise, build up the command if we need to */
	if (commnext - command + strlen(pathname) + strlen(fib->fib_FileName) + 3 > COMMAX)
		docommand() ;
	growcommand("\"", FALSE) ;
	growcommand(pathname, FALSE) ;
	growcommand(fib->fib_FileName, FALSE) ;
	growcommand("\"", TRUE) ;
	return TREE_CONT ;
	}

/*
 * And here we have things that check the global FIB, and extract values
 * from it.
 */
long
fibkey(struct FileInfoBlock *fib) {
	return fib->fib_DiskKey ;
	}

long
fibdirtype(struct FileInfoBlock *fib) {
	return fib->fib_DirEntryType ;
	}

char *
fibname(struct FileInfoBlock *fib) {
	char *tmpname ;

	if ((tmpname = AllocRemember(&filterstrings, 100, 0L)) == NULL) {
		fprintf(stderr, "%s: Out of memory\n", my_name) ;
		errorflag = ERROR_HALT ;
		return NULL ;
		}
	strcpy(tmpname, fib->fib_FileName) ;
	strlwr(tmpname) ;
	return tmpname ;
	}

long
fibprot(struct FileInfoBlock *fib) {
	return fib->fib_Protection ^ 017 ;
	}

long
fibtype(struct FileInfoBlock *fib) {
	return fib->fib_EntryType ;
	}

long
fibsize(struct FileInfoBlock *fib) {
	return fib->fib_Size ;
	}

long
fibblock(struct FileInfoBlock *fib) {
	return fib->fib_NumBlocks ;
	}

long
fibdate(struct FileInfoBlock *fib) {
	return fib->fib_Date.ds_Days * 24 * 60 + fib->fib_Date.ds_Minute ;
	}

long
fibday(struct FileInfoBlock *fib) {
	return fib->fib_Date.ds_Days * 24 * 60 ;
	}

char *
fibcomment(struct FileInfoBlock *fib) {
	char *tmpname ;

	if ((tmpname = AllocRemember(&filterstrings, 80, 0L)) == NULL) {
		fprintf(stderr, "%s: Out of memory\n", my_name) ;
		errorflag = ERROR_HALT ;
		return NULL ;
		}
	strcpy(tmpname, fib->fib_Comment) ;
	strlwr(tmpname) ;
	return tmpname ;
	}

long
askuser(struct FileInfoBlock *fib) {
	char c ;

	if (!*pathname && getpathname(lock_global)) return 1 ;
	fprintf(stderr, "%s%s? ", pathname, fib->fib_FileName) ;
	fflush(stderr) ;
	while ((c = getchar()) == ' ' || c == '\t')
		;
	while (getchar() != '\n')
		;
	return (long) (toupper(c) == 'Y') ;
	}

char *
fullname(struct FileInfoBlock *fib) {
	char *tmpname ;

	if ((tmpname = AllocRemember(&filterstrings, FMSIZE, 0L)) == NULL) {
		fprintf(stderr, "%s: Out of memory\n", my_name) ;
		errorflag = ERROR_HALT ;
		return NULL ;
		}
	if (!*pathname) getpathname(lock_global) ;
	strcpy(tmpname, pathname) ;
	strcat(tmpname, fib->fib_FileName) ;
	strlwr(tmpname) ;
	return tmpname ;
	}

long
isfile(struct FileInfoBlock *fib) {
	return (long) (fib->fib_DirEntryType < 0) ;
	}

long
isdir(struct FileInfoBlock *fib) {
	return (long) (fib->fib_DirEntryType >= 0) ;
	}

/*
 * dofib - apply one of the fibfuncs to a named file.
 */
long
dofib(char *file, long (*func)(struct FileInfoBlock *)) {
	BPTR			lock, out ;
	struct FileInfoBlock	*fib ;

	if ((fib = AllocMem(sizeof(struct FileInfoBlock), 0)) == NULL) {
		fprintf(stderr, "%s: Out of memory\n", my_name) ;
		errorflag = ERROR_HALT ;
		return 0 ;
		}

	if (!(lock = Lock(file, ACCESS_READ))) {
		fprintf(stderr, "%s: Can't lock %s\n", my_name, file) ;
		errorflag = ERROR_HALT ;
		FreeMem(fib, sizeof(*fib)) ;
		return 0 ;
		}

	lock_global = lock ;
	*pathname = '\0' ;
	if (!Examine(lock, fib)) {
		fprintf(stderr, "%s: Can't examine %s\n", my_name, file) ;
		errorflag = ERROR_HALT ;
		UnLock(lock) ;
		FreeMem(fib, sizeof(*fib)) ;
		return 0 ;
		}

	out = func(fib) ;
	UnLock(lock) ;
	FreeMem(fib, sizeof(*fib)) ;
	return out ;
	}

#ifndef	NO_REXX
/*
 * Rexx interface - for now, just feed the routine to Rexx, and return
 * whatever integer it gives us back.
 */
#include <rexx/rxslib.h>
#include <rexx/storage.h>
#include <exec/ports.h>

struct Library		*RexxSysBase = NULL ;
#define	REXXNAME	"ftw"
void			free_code(void *) ;

long
dorexx(char *macro, struct FileInfoBlock *fib) {
	struct RexxMsg	*msg ;
	struct MsgPort	*rexxport, *port ;
	long		out ;
	void		*code ;
	char		result[12] ;

	/* Get the library if we need it */
	if ((RexxSysBase = OpenLibrary("rexxsyslib.library", 0)) == NULL) {
		fprintf(stderr, "%s: Can't open rexx library\n", my_name) ;
		errorflag = ERROR_HALT ;
		return 0 ;
		}

	/* Create the port I use to talk to Rexx */
	Forbid() ;
	if (FindPort(REXXNAME) == NULL)
		port = CreatePort(REXXNAME, 0) ;
	Permit() ;
	if (port == NULL) {
		fprintf(stderr, "%s: Can't create port for rexx\n", my_name) ;
		goto badnews ;
		}

	/* Build the message to send */
	if ((msg = CreateRexxMsg(port, REXXNAME, port->mp_Node.ln_Name)) == NULL) {
		fprintf(stderr, "%s: Can't create rexx msg\n", my_name) ;
		goto badnews ;
		}
	msg->rm_Action = RXFUNC | RXFF_RESULT | 2 ;

	/* The command & two arguments */
	if (!*pathname) getpathname(lock_global) ;
	msg->rm_Args[0] = macro ;
	msg->rm_Args[1] = pathname ;
	msg->rm_Args[2] = fib->fib_FileName ;
	if (!FillRexxMsg(msg, 3, 0)) {
		fprintf(stderr, "%s: Can't create rexx arguments\n", my_name) ;
		DeleteRexxMsg(msg) ;
		goto badnews ;
		}

	/* send the message */
	Forbid() ;
	if (rexxport = FindPort(RXSDIR))
		PutMsg(rexxport, (struct Message *) msg) ;
	Permit() ;
	if (!rexxport) {
		fprintf(stderr, "%s: Can't find rexx port\n", my_name) ;
		goto badnews ;
		}

	/* Now, wait for it to come back to me */
	for (;;) {
		/* Get a message, and break if it's what I want */
		WaitPort(port) ;
		msg = (struct RexxMsg *) GetMsg(port) ;
		if (msg->rm_Node.mn_Node.ln_Type == NT_REPLYMSG) break ;

		/*
		 * Got a command - so we interpret the "command" as a filter,
		 * and run it over the current fib.
		 */
		if ((code = parse(msg->rm_Args[0])) == NULL) {
			/* Didn't parse - so return "broken command string" */
			msg->rm_Result1 = 10 ;
			msg->rm_Result2 = 11 ;
			}
		else {
			out = execute(fib, code) ;
			free_code(code) ;
			if (!(msg->rm_Action & RXFF_RESULT)) {
				/* Don't want results, so return TRUE/FALSE */
				msg->rm_Result1 = (out ? 0 : 1) ;
				msg->rm_Result2 = 0 ;
				}
			else {	/* Want a result, so try and give it to them */
				sprintf(result, "%08lx", out) ;
				if ((msg->rm_Result2 =
					(LONG) CreateArgstring(result, (long) strlen(result)))
				    != NULL)
					/* All ok, set result so */
					msg->rm_Result1 = 0 ;
				else {
					/* No memory, say so */
					msg->rm_Result1 = 20 ;
					msg->rm_Result2 = 3 ;
					}
				}
			}
		ReplyMsg((struct Message *) msg) ;
		}
		
	/* Check the result and do what must be done */
	if (msg->rm_Result1 == 0) {
		out = atoi((char *) msg->rm_Result2) ;
		DeleteArgstring((struct RexxArg *) msg->rm_Result2) ;
		}
	else {
		fprintf(stderr, "%s: Rexx error: %s\n", my_name,
			ErrorMsg(msg->rm_Result2)->ns_Buff) ;
		goto badnews ;
		}

	if (0) {	/* Make sure we execute this iff we had a problem */
badnews:
		errorflag = ERROR_HALT ;
		out = 0 ;
		}

	/* Clean up the port */
	if (port != NULL) {
		FreeSignal((long) (port->mp_SigBit)) ;
		RemPort(port) ;
		DeletePort(port) ;
		}

	/* Clean up the rexx msg */
	if (msg != NULL) {
		ClearRexxMsg(msg, 3) ;
		DeleteRexxMsg(msg) ;
		}

	/* Close the library, and return */
	if (RexxSysBase != NULL) CloseLibrary(RexxSysBase) ;
	return out ;
	}
#endif
