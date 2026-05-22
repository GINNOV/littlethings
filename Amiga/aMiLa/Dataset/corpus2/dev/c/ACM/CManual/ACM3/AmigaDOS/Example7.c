/* Example7                                                          */
/* This program takes a file/directory/device name as parameter, and */
/* prints out some interesting information about it.                 */


#include <libraries/dos.h>
#include <exec/memory.h>


main( argc, argv )
int argc;
char *argv[];
{
  struct FileLock *lock;
  struct FileInfoBlock *fib_ptr; /* Declare a FileInfoBlock */
                                 /* pointer called fib_ptr. */


  if( argc < 2 )
  {
    /* No file/directory specified! */
    printf("What file/directory do you actually want to examine?\n");
    exit();
  }



  /* 1. Allocate enough memory for a FileInfoBlock structure:       */
  /* (Here is some casting again. AllocMem() returns a CPTR memory  */
  /* pointer, while fib_ptr is a pointer to a FileInfoBlock. It is  */
  /* actually the same thing, but to not make the compiler upset we */
  /* tell it that AllocMem() returns a pointer to a FileInfoBlock.) */
  fib_ptr = (struct FileInfoBlock *)
            AllocMem( sizeof( struct FileInfoBlock ),
                      MEMF_PUBLIC | MEMF_CLEAR );

  /* MEMF_PUBLIC: Any type of memory (chip/fast) */
  /* MEMF_CLEAR:  Clear the allocated memory.    */

  /* Check if we have allocated the memory successfully: */
  if( fib_ptr == NULL )
  {
    printf("Not enough memory!\n");
    exit();
  };


  
  /* 2. Try to lock the file: */
  /* (Casting again! We tell the compiler that Lock() returns a pointer */
  /* to a FileLock structure.)                                          */
  lock = (struct FileLock *) Lock( argv[ 1 ], SHARED_LOCK );
  
  /* Colud we lock the file? */
  if( lock == NULL )
  {
    printf("Could not lock the file/directory!\n");

    /* Deallocate the memory we have allocated: */
    FreeMem( fib_ptr, sizeof( struct FileInfoBlock ) );
    
    exit();
  }



  /* 3. Try to get some information about the file: */
  if( Examine( lock, fib_ptr ) == NULL )
  {
    printf("Could not examine the file/directory!\n");

    /* Deallocate the memory we have allocated: */
    FreeMem( fib_ptr, sizeof( struct FileInfoBlock ) );
    
    /* Unlock the file: */
    UnLock( lock );  
    
    exit();
  }



  /* 4. You may now examine the FileInfoBlock structure! */

  if( fib_ptr->fib_DirEntryType < 0 )
    printf("Type:       File\n");
  else
    printf("Type:       Directory\n");

  printf("Name:       %s\n", fib_ptr->fib_FileName );
  printf("Size:       %d\n", fib_ptr->fib_Size );
  printf("Blocks:     %d\n", fib_ptr->fib_NumBlocks );
  printf("Comment:    %s\n",
    fib_ptr->fib_Comment[0] != '\0' ? fib_ptr->fib_Comment : "No comment" );

  printf("Deletable:  %s\n",
    fib_ptr->fib_Protection & FIBF_DELETE ? "On" : "Off" );

  printf("Executable: %s\n",
    fib_ptr->fib_Protection & FIBF_EXECUTE ? "On" : "Off" );

  printf("Writable:   %s\n",
    fib_ptr->fib_Protection & FIBF_WRITE ? "On" : "Off" );

  printf("Readable:   %s\n",
    fib_ptr->fib_Protection & FIBF_READ ? "On" : "Off" );

  printf("Archive:    %s\n",
    fib_ptr->fib_Protection & FIBF_ARCHIVE ? "On" : "Off" );

  printf("Pure:       %s\n",
    fib_ptr->fib_Protection & FIBF_PURE ? "On" : "Off" );

  printf("Script:     %s\n",
    fib_ptr->fib_Protection & FIBF_SCRIPT ? "On" : "Off" );

  printf("Days:       %d\n", fib_ptr->fib_Date.ds_Days );
  printf("Minutes:    %d\n", fib_ptr->fib_Date.ds_Minute );
  printf("Ticks:      %d\n", fib_ptr->fib_Date.ds_Tick );



  /* 5. Unlock the file: */
  UnLock( lock );  



  /* 6. Deallocate the memory we have allocated: */
  FreeMem( fib_ptr, sizeof( struct FileInfoBlock ) );
}
