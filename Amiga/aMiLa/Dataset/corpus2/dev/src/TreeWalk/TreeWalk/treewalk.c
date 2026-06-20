/*
 * treewalk.c - generic tree walking routine for AmigaDOS trees.
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
#include <libraries/dosextens.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include "treewalk.h"

/*
 * We keep a stack of locks on directories yet to be visited. Stacknode is the
 * used for this, containing nothing but the pointer down the stack, and
 * the current lock.
 */
struct stacknode {
	struct stacknode	*sn_next ;
	BPTR			sn_lock ;
	} *stacktop = NULL ;

/*
 * Stacktop is global so that these two functions can work cleanly (bleah).
 * Push returns the top value on the stack while removing it from the stack.
 * Pop puts a new value on the stack, and returns FALSE if it fails.
 */

static BPTR
pop(void) {
	BPTR out ;
	struct stacknode *old ;

	if (!stacktop) return NULL ;
	old = stacktop ;
	stacktop = old->sn_next ;
	out = old->sn_lock ;
	FreeMem(old, sizeof(struct stacknode)) ;
	return out ;
	}

static int
push(BPTR new) {
	struct stacknode *top ;

	if ((top = (struct stacknode *) AllocMem(sizeof(struct stacknode), 0)) == NULL) {
		UnLock(new) ;	/* As we're about to throw it out... */
		return FALSE ;
		}
	top->sn_lock = new ;
	top->sn_next = stacktop ;
	stacktop = top ;
	return TRUE ;
	}

int
treewalk(BPTR root, int (*userfunc)(BPTR, struct FileInfoBlock *), int flags) {
	register BPTR			mylock, childlock ;
	register struct FileInfoBlock	*fib ;
	register int			stat ;
	int				visit, scan ;

	if ((fib = AllocMem(sizeof(struct FileInfoBlock), 0)) == NULL)
		return FALSE ;

	/*
	 * Set up the lock & stack as apropos for this pass. If we
	 * are doing only a preorder walk, then we always visit & scan
	 * simultaneously, so we just set them and forget it. postorder
	 * walks will reset them as needed.
	 */
	mylock = DupLock(root) ;
	if (!Examine(mylock, fib)		/* Can't examine */
	|| fib->fib_DirEntryType < 0) {	/* Not a directory */
		UnLock(mylock) ;
		FreeMem(fib, sizeof(*fib)) ;
		return FALSE ;
		}
	if (flags & TREE_POST)
		if (push(mylock)) mylock = root  ;
		else {
			UnLock(mylock) ;
			FreeMem(fib, sizeof(*fib)) ;
			return FALSE ;
			}
	visit = scan = flags & TREE_PRE ;

	do {
		/*
		 * We use root as a "mark" that the following node has been
		 * read for directories, but not visited. The mark could be
		 * anything, but we shouldn't ever find the root of the
		 * tree in the tree. Visit & scan are set to mark the next
		 * loop as either a visit, or a scan, or both.
		 */
		if (flags & TREE_POST)
			if (mylock != root) {
				scan = FALSE ;
				visit = TRUE ;
				}
			else {
				scan = TRUE ;
				visit = flags & TREE_PRE ;
				mylock = DupLock(stacktop->sn_lock) ;
				}

		if (!(stat = Examine(mylock, fib))) break ;
		if (visit && (stat = (*userfunc)(mylock, NULL))) break ;
		while (ExNext(mylock, fib)
		|| IoErr() != ERROR_NO_MORE_ENTRIES) {
			if (fib->fib_DirEntryType >= 0 && scan) {
				mylock = CurrentDir(mylock) ;
				stat = (childlock = Lock(fib->fib_FileName, ACCESS_READ))
					&& push(childlock) ;
				mylock = CurrentDir(mylock) ;
				if (flags & TREE_POST)
					stat = stat && push(root) ;
				if (!stat) goto twobreak ;
				}
			if (visit && (stat = (*userfunc)(mylock, fib)))
				goto twobreak ;
			}
		UnLock(mylock) ;
		stat = TRUE ;		/* Make sure it's right for exit */
		} while (mylock = pop()) ;
/*
 * C doesn't have a multi-level break, so we have to have a label for errors
 * in the inner while to come to.
 *
 * Shit.
 */

twobreak:
	/* Free up the locks, the AllocMem'd memory, and then return */
	while (mylock) {
		if (mylock != root) UnLock(mylock) ;
		mylock = pop() ;
		} 

	FreeMem(fib, sizeof(*fib)) ;
	return stat ;
	}

#ifdef	TEST
/*
 * Test code - just print the tree starting at the current dir, or at
 *	the first (only) argument.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <dos.h>

static int	haltflag = FALSE ;

static int
testvisit(BPTR lock, struct FileInfoBlock *fib) {
	static char	pathname[FMSIZE] ;
	char		*term ;

	if (haltflag) return TREE_STOP ;
	if (!fib) {	/* A directory we're about to scan */
		if (getpath(lock, pathname)) return TREE_STOP ;
		term = strchr(pathname, ':') == NULL ? ":" : "/" ;
		strcat(pathname, term) ;
		puts(pathname) ;
		return TREE_CONT ;
		}

	/* A file from the directory we're now scanning */
	if (fib->fib_DirEntryType < 0)
		printf("%s%s\n", pathname, fib->fib_FileName) ;
	return TREE_CONT ;
	}

static int
do_break(int sig) {

	haltflag = TRUE ;
	signal(SIGINT, do_break) ;
	return 0 ;
	}

void
main(int argc, char **argv) {
	BPTR	start ;
	struct Process *proc ;

	switch (argc) {
		case 0: case 1:
			proc = (struct Process *) FindTask(NULL) ;
			start = DupLock(proc->pr_CurrentDir) ;
			break ;
		case 2:
			if ((start = Lock(argv[1], ACCESS_READ)) == NULL) {
				fprintf(stderr, "%s: Can't lock %s\n",
					argv[0], argv[1]) ;
				exit(RETURN_ERROR) ;
				}
			break ;
		default:
			fprintf(stderr, "usage: %s [directory]\n", argv[0]) ;
			exit(RETURN_ERROR) ;
		}

	/* Arrange to catch signals if we're not ignoring them */
	if (signal(SIGINT, do_break) == SIG_IGN)
		signal(SIGINT, SIG_IGN) ;

	if (!treewalk(start, testvisit, TREE_BOTH)) {
		fprintf(stderr, "%s: Something broke...\n", argv[0]) ;
		UnLock(start) ;
		exit(RETURN_WARN) ;
		}
	if (haltflag) printf("*** BREAK\n") ;
	UnLock(start) ;
	exit(RETURN_OK) ;
	}
#endif