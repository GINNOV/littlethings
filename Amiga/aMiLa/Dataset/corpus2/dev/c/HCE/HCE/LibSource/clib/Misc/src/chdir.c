#include <libraries/dosextens.h>
#include <exec/memory.h>

                 /* Note - Modified by Jason Petty, Marked J.P. */
#ifndef NULL
#define NULL 0L
#endif

#undef ACCESS_READ
#define ACCESS_READ -2

typedef	struct FileLock LOCK;    /* Was struct Lock LOCK. J.P. */

extern LOCK *Lock();             /* Was LOCK Lock(), J.P. */
extern long IoErr();
extern void UnLock();
extern LOCK *CurrentDir();

/*------------------------------------------------------------------*/
/*	chdir(path): make path the current directory. Return Ok/Not */
/*------------------------------------------------------------------*/

int chdir( path )
char *path;
{
	register LOCK *lock;
	LOCK *oldLock;

	if ( *path == '\0' )
		return 0;

	lock = Lock( path, ACCESS_READ );
	if ( lock == NULL )
		return (int)IoErr();

	oldLock = CurrentDir( lock );
	if ( oldLock )
		UnLock( oldLock );

	return 0;
}
