#include <libraries/dosextens.h>   /* Was include <libraries/dos.h> . J.P. */
#include <exec/memory.h>
#include <limits.h>

#ifndef NULL
#define NULL 0L
#endif

typedef struct FileInfoBlock	FIB;
typedef struct FileLock		LOCK;   /* Was struct Lock LOCK. J.P. */

extern	char *malloc();
extern	void *AllocMem();
LOCK	*ParentDir(), *Lock();

/*
 *    GetCurrentPath: get full path of the current directory
 */

static void GetCurrentPath( path )
register char *path;
{

	char s1[ PATHSIZE ];
	char *name;
	register LOCK	*locka, *lockb;
        register FIB	*fib;

	fib = (FIB *)AllocMem((long)sizeof(FIB), MEMF_CHIP | MEMF_CLEAR);
	if ( fib == NULL ) {
		*path = '\0';
		return;
	}
	
	locka = Lock("", ACCESS_READ );
	*path = s1[0] = '\0';

	while ( locka != NULL ) {
		Examine( locka, fib );
		name = fib->fib_FileName;
		if ( *name == '\0' )
			strcpy( path, "RAM" ); /* Patch for Ram disk bug */
		else
			strcpy( path, name );
		lockb = ParentDir( locka );
		UnLock( locka );
	    
		if ( lockb == NULL )
			strcat( path, ":");
		else if ( s1[0] != '\0' )
			strcat( path, "/");
		strcat( path, s1 );
		strcpy( s1, path );
		locka = lockb;
	}

	FreeMem( fib, (long)sizeof(FIB) );
}

/*
 *	getcwd: return the path name of the current directory
 */

char *getcwd( path, size )
char *path;
int size;
{
	if ( path == (char *)NULL ) {
		if ( (path = malloc( PATHSIZE ) ) == NULL)
			return NULL;
	}

	GetCurrentPath( path );
	return path;
}

