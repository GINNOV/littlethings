/*   P2S (Pointer To Sprite)   AMIGA C MANUAL    Anders Bjerin    */
/*                                                                */
/* This program prints out the Sprite Data of the pointer. It can */
/* also print out the colours, and/or a SimpleSprite structure.   */
/*                                                                */
/* Syntax: P2S [name] [-c] [-s]                                   */
/* name  : name of the sprite. (Default name is "sprite".)        */
/* -c    : print out the colours.                                 */
/* -s    : print out a SimpleSprite structure.                    */


#include <intuition/intuition.h>


struct IntuitionBase *IntuitionBase;


main( argc, argv)
int argc;
char *argv[];
{
  struct Preferences pref;
  int loop;

  char name[] = "sprite";
  BOOL colours = FALSE;
  BOOL structure = FALSE;



  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* Check which arguments have been sent: */ 
  for( loop = 1; loop < argc; loop++ )
  {
    /* Name: */
    if( argv[ loop ][0] != '-' )
      strcpy( name, argv[ loop ] );

    /* Colours: */
    if( argv[ loop ][0] == '-' && argv[ loop ][1] == 'c' )
      colours = TRUE;

    /* Structure: */
    if( argv[ loop ][0] == '-' && argv[ loop ][1] == 's' )
      structure = TRUE;
  }



  /* Get a copy of the Preferences: */
  if( GetPrefs( &pref, sizeof( struct Preferences ) ) == NULL )
  {
    printf( "Could not get a copy of the Preferences!\n" );
    CloseLibrary( IntuitionBase );
    exit();
  }



  /* Print out the colours: */
  if( colours )
    printf( "UWORD %s_colours[3] = { 0x%04x, 0x%04x, 0x%04x };\n\n",
      name, pref.color17, pref.color18, pref.color19 );



  /* Print out the Sprite Data: */
  printf( "UWORD chip %s_data[%d] =\n{\n  0x0000, 0x0000,\n\n",
    name, POINTERSIZE );

  for( loop = 2; loop < POINTERSIZE - 2; loop += 2)
    printf( "  0x%04x, 0x%04x,\n",
      pref.PointerMatrix[ loop ],
      pref.PointerMatrix[ loop+1 ] );

  printf( "\n  0x0000, 0x0000\n};\n" );



  /* Print out the SimpleSprite structure: */
  if( structure )
  {
    printf( "\nstruct SimpleSprite %s =\n{\n", name );
    printf( "  %s_data,\n  %d,\n  0, 0,\n  -1,\n};\n", name, POINTERSIZE );
  }



  /* Close the Intuition Library: */
  CloseLibrary( IntuitionBase );
}
