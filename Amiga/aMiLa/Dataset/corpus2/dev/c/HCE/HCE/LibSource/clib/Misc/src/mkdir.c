/*
 *	mkdir(name): make a directory with the given name.
 */

#include <libraries/dosextens.h>   /* Added by J.P. */

typedef struct FileLock LOCK;      /* Was typedef struct Lock LOCK. .J.P. */

extern LOCK *CreateDir();
extern long IoErr();
extern void UnLock();

int mkdir( name )
char *name;
{
	register LOCK *lock;

	if ( *name == '\0' )
		return 0;

	lock = CreateDir( name );
	if ( !lock )
		return (int)IoErr();
	else 
		UnLock( lock );

	return 0;
}
