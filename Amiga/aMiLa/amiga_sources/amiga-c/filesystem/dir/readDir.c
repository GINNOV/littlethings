/* This program takes a directory/device name as parameter, and    */
/* prints out all the file/directory-names inside it. This example */
/* describes how to use Examine() and ExNext().                    */


#include <libraries/dos.h>
#include <stdio.h>
#include <exec/memory.h>


main( argc, argv )
int argc;
char *argv[];
{
  struct FileLock *lock;
  struct FileInfoBlock *fib_ptr; /* Declare a FileInfoBlock */
                                 /* pointer called fib_ptr. */

 char *path = "PROGDIR:data";


  if( argc < 2 )
  {
    /* No directory/device specified! */
    //printf("Which directory/device do you actually want to examine?\n");
    //exit();
  }



  /* Allocate enough memory for a FileInfoBlock structure: */
  fib_ptr = (struct FileInfoBlock *)
            AllocMem( sizeof( struct FileInfoBlock ),
                      MEMF_PUBLIC | MEMF_CLEAR );

  /* Check if we have allocated the memory successfully: */
  if( fib_ptr == NULL )
  {
    printf("Not enough memory!\n");
    exit();
  };


  
  /* Try to lock the file: */
  lock = (struct FileLock *) Lock( path, SHARED_LOCK );
  
  /* Colud we lock the file? */
  if( lock == NULL )
  {
    printf("Could not lock the file/directory!\n");

    /* Deallocate the memory we have allocated: */
    FreeMem( fib_ptr, sizeof( struct FileInfoBlock ) );
    
    exit();
  }



  /* Try to examine the directory/device/(file): */
  if( Examine( lock, fib_ptr ) )
  {
    /* Check if it is a directory/device: */
    if( fib_ptr->fib_DirEntryType > 0 )
    {
      /* Print out the directory/device name with underlined characters: */
      /* \033[4m : Underline */
      /* \033[0m : Normal    */
      printf("\033[4m%s\033[0m\n", fib_ptr->fib_FileName );



      /* As long as we can examine files/directories we continue: */
      while( ExNext( lock, fib_ptr ) )
      {
        /* If it is a file we print out the name with white characters. */
        /* However, if it is a (sub)directory we use orange:            */
        if( fib_ptr->fib_DirEntryType < 0 )
          printf("%s\n", fib_ptr->fib_FileName ); /* File */
        else
          printf("\033[33m%s\033[31m\n", fib_ptr->fib_FileName ); /* Dir */

        /* \033[33m : Orange (Colour 3) */
        /* \033[31m : White  (Colour 1) */
      }



      /* Check what went wrong. If it was not because there were no more */
      /* files in the directory (ERROR_NO_MORE_ENTRIES), something       */
      /* terrible has happened!                                          */
      if( IoErr() != ERROR_NO_MORE_ENTRIES )
        printf("ERROR WHILE READING!!!\n");
    }
    else
      printf("%s is a file!\n", path );
  }
  else
    printf("Could not examine %s!\n", path );



  /* Unlock the file: */
  UnLock( lock );  



  /* Deallocate the memory we have allocated: */
  FreeMem( fib_ptr, sizeof( struct FileInfoBlock ) );
}