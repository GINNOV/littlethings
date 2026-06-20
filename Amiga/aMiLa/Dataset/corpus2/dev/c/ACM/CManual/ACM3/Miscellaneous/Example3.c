/* Example3                                                 */
/* This example shows how to get a copy of the preferences. */


#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



main()
{
  /* Declare a preferences structure: */
  struct Preferences pref;



  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* Try to get a copy of the current preferences (whole): */
  if( GetPrefs( &pref, sizeof(pref) ) == NULL )
  {
    /* Could not get a copy of the preferences! */
    CloseLibrary( IntuitionBase );
    exit();
  }



  /* We have now a copy of the preferences. */
  /* Do what ever you want...               */

  /* Why not print out the workbench clours? */
  printf( "\nWorkbench Screen Colours:\n");
  printf( "             RGB\n" );
  printf( "Colour 0: 0x%04x\n", pref.color0 );
  printf( "Colour 1: 0x%04x\n", pref.color1 );
  printf( "Colour 2: 0x%04x\n", pref.color2 );
  printf( "Colour 3: 0x%04x\n\n", pref.color3 );



  /* Close the Intuition Library: */
  CloseLibrary( IntuitionBase );
}

