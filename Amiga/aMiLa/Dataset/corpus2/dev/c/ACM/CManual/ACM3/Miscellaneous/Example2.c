/* Example2                                                              */
/* This example shows how to allocate and deallocate memory with help of */
/* the functions AllocRemember(), and FreeRemember().                    */


#include <intuition/intuition.h>
#include <exec/memory.h>


struct IntuitionBase *IntuitionBase;


main()
{
  /* Declare and initialize a pointer to the first Remember structure: */
  struct Remember *remember = NULL;
  
  /* Declare three memory pointers: */
  CPTR memory1, memory2, memory3;



  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* Allocate 350 bytes of Chip memory, which is cleared: */
  memory1 = AllocRemember( &remember, 350, MEMF_CHIP|MEMF_CLEAR );

  if( memory1 == NULL )
  {
    CloseLibrary( IntuitionBase );
    exit();
  }


  /* Allocate 900 bytes of memory (any type, Fast if possible): */
  memory2 = AllocRemember( &remember, 900, MEMF_PUBLIC );

  if( memory2 == NULL )
  {
    FreeRemember( &remember, TRUE );
    CloseLibrary( IntuitionBase );
    exit();
  }


  /* Allocate 100 bytes of Chip memory: *
  memory3 = AllocRemember( &remember, 100, MEMF_CHIP );

  if( memory3 == NULL )
  {
    FreeRemember( &remember, TRUE );
    CloseLibrary( IntuitionBase );
    exit();
  }



  /* Do whatever you want to do with the memory. */



  /* Deallocate all memory with one single call: */
  FreeRemember( &remember, TRUE );

  /* Close the Intuition Library: */
  CloseLibrary( IntuitionBase );
}
