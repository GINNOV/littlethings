/* Example1                                                   */
/* This example shows how to allocate, and deallocate memory. */


#include <exec/types.h>  /* Declares CPTR. */
#include <exec/memory.h> /* Declares MEMF_CHIP. */


main()
{
  /* Declare a pointer to the memory you are going to allocate: */
  CPTR memory;


  /* Allocate 150 bytes of Chip memory: */
  memory = (CPTR) AllocMem( 150, MEMF_CHIP );


  /* Have we allocated the memory successfully? */
  if( memory == NULL )
  {
    printf("Could not allocate the memory!\n");
    exit();
  }


  /* Do whatever you want to do with the memory! */
  

  /* Free the memory we have previously allocated: */
  FreeMem( memory, 150 );  
}
