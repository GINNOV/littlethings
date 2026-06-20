/* Example 2                                                  */
/* This example demonstrates how to create a directory called */
/* "MyDirectory" on the RAM disk.                             */


#include <libraries/dos.h>


void main();

void main()
{
  /* Declare a FileLock structure: */
  struct FileLock *lock;

  /* Create a directory on the RAM disk: (The directory will */
  /* be locked with an exclusive lock, and must therefore be */
  /* unlocked before the program terminates.)                */
  lock = (struct FileLock *) CreateDir( "RAM:MyDirectory" );

  /* If there is no lock, no directory has been created. In  */
  /* that case, inform the user about the problem and leave: */
  if( lock == NULL )
  {
    printf( "ERROR Could NOT create the new directory!\n" );
    exit( 0 );
  }

  /* Unlock the directory: */
  UnLock( lock );
}
