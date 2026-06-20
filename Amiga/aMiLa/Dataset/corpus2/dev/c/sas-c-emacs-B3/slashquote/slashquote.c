/*
 *  FILE
 *	slashquote.c
 *
 *  DESCRIPTION
 *	A one function ARexx function library.
 *
 *  AUTHOR
 *	Anders Lindgren, d91ali@csd.uu.se
 *
 *  STATUS
 *	slashquote is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published 
 *	by the Free Software Foundation; either version 1, or (at your 
 *	option) any later version.
 *
 *	GNU Emacs is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public
 *	License along with GNU Emacs; see the file COPYING.  If not,
 *	write to the Free Software Foundation, 675 Mass Ave, Cambridge,
 *	MA 02139, USA.
 */
 
/* Arguments:
 * Up to 15 arguments may be passed in the rm_Args[] array of the parameter
 * block.  Arguments are ALWAYS passed as argstrings and can generally be
 * treated like string pointers in a 'C' program.  The called function may
 * need to convert the strings to numeric values if arithmetic operations
 * are to be performed.  A NULL value in the argument slot means that the
 * argument was omitted from the function call, as in MyFunc(1,,3).
 *
 * The total number of arguments (including the defaulted ones) is available
 * in the low-order byte of the action code field rm_Action.
 * Note that REXX supports function calls with varying numbers of arguments,
 * and that the called function can always determine how many were actually
 * passed.
 *
 * Error reporting:
 * The function must return an integer error code and a result string if no
 * errors were detected.  Errors are considered to be ARexx internal error
 * codes, so the function should make use of these values as appropriate.
 * A code of 0 is interpreted to mean that everything worked.
 *
 * Result strings:
 * The result string must be returned as an argstring, a pointer to the
 * string buffer of an RexxArg structure.  Argstrings can be created by a
 * call to the ARexx Systems library function CreateArgstring().
 * N.B. Never allocate a result string if the error code is non-zero!
 */

#include <exec/types.h>

#include <exec/memory.h>

#include <rexx/storage.h>
#include <rexx/rxslib.h>
#include <rexx/errors.h>

#include <proto/exec.h>
#include <proto/rexxsyslib.h>

#include <string.h>
#include <dos.h>


/*
 *  Forward references.
 */

extern long slashquote (struct RexxMsg *, UBYTE * *);


/*
 *  Global data.
 */

struct Library * RexxSysBase;


/*
 *  FUNCTION
 *	__UserLibInit
 *
 *  DESCRIPTION
 *	Open the rexx system library.
 */

int __saveds
__UserLibInit(void)
{
    if (RexxSysBase = OpenLibrary("rexxsyslib.library", 0)) {
	return(0);
    }
    return(1);
}


/*
 *  FUNCTION
 *	__UserLibCleanup
 *
 *  DESCRIPTION
 *	Close the Rexx system library
 */

void __saveds
__UserLibCleanup(void)
{
    if (RexxSysBase) {
	CloseLibrary(RexxSysBase);
    }
}


/*
 *  FUNCTION
 *	LIBRexxEntry
 *
 *  DESCRIPTION
 *	The library entry point.
 *	Check if this library contains the desired function, otherwise
 *	return a errorcode 1.
 */

long __asm __saveds
LIBRexxEntry(register __a0 struct RexxMsg * rmptr)
{
    long        retcode = 1L;	/* Fail by default */
    UBYTE *     retval  = NULL;


    if (strcmp("SLASHQUOTE", rmptr->rm_Args[0]) == 0) {
	retcode = slashquote(rmptr, & retval);
    } 
	/* Set the return values */
    __builtin_putreg(REG_A0, (long)retval);	/* Return String	*/
    return(retcode);
}


/*
 *  FUNCTION
 *	slashquote
 *
 *  DESCRIPTION
 *	Manipulates a string in the following way:
 *	  1) Put quotes around it.
 *	  2) Escape all quotes and escapecharacters in the string. The
 *	     escapecharacter is the 2:nd arg, or '\' if none is supplied.
 */

long 
slashquote(struct RexxMsg * rmptr, UBYTE * * retvalp)
{
    register char    ch;
	     char    qch;	/* Character to take care of. */
    register UBYTE * dest;
    register UBYTE * src;
    register long    sindex = 0;
    register long    dindex = 0;
    register int     len;

	/* Check the number of arguments */
    if ( (rmptr->rm_Action & 0xFF) == 1 ) {
	qch = '\\';	/* Default, quote backslash */ 
    }
    else if ( (rmptr->rm_Action & 0xFF) == 2 ) {
	qch = rmptr->rm_Args[2][0];
    }
    else {
	return(ERR10_017);
    }

    len = LengthArgstring(rmptr->rm_Args[1]);

    if (dest = AllocMem((len<<1) + 2, MEMF_CLEAR)) {

	dest[dindex++] = '"';	/* Start quote */

	src = rmptr->rm_Args[1];

	do {
	    ch = src[sindex++];

	    if (ch == '"' || ch == qch ) {
		dest[dindex++] = qch;
	    }
	    dest[dindex++] = ch;
	} while (ch);

	dest[dindex-1] = '"';	/* End quote */

	(* retvalp) = CreateArgstring(dest, dindex);

	FreeMem(dest, (len<<1) + 2);

		/* ERR10_003 "Out of memory" */
	return( (* retvalp) ? 0L : ERR10_003 );
    }
    return(ERR10_003);
}
