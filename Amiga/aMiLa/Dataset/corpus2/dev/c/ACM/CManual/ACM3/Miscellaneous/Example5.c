/* Example5                                  */
/* This example prints out the current time. */


#include <intuition/intuition.h>


struct IntuitionBase *IntuitionBase;


main()
{
  ULONG seconds, micros;



  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* Get the current time: */
  CurrentTime( &seconds, &micros );

  /* Print out the current time: */
  printf( "Seconds: %d\n", seconds );
  printf( "Micros:  %d\n", micros );



  /* Close the Intuition Library: */
  CloseLibrary( IntuitionBase );
}