/* Example 3                                                          */
/* This example demonstrates how to rename files and directories. It  */
/* will rename the file Example 1 created (called "HighScore.dat") to */
/* "Numbers.dat". It will also rename the directory Example 2 created */
/* ("MyDirectory") to "NewDirectory".                                 */ 


/* This file declares the type BOOL: */
#include <exec/types.h>


void main();

void main()
{
  BOOL ok;


  /* Rename the file: */
  ok = Rename( "RAM:HighScore.dat", "RAM:Numbers.dat" );

  /* Check if the file was successfully renamed: */
  if( !ok )
    printf( "The file could not be renamed!\n" );


  /* Rename the directory: */
  ok = Rename( "RAM:MyDirectory", "RAM:NewDirectory" );

  /* Check if the directory was successfully renamed: */
  if( !ok )
    printf( "The directory could not be renamed!\n" );
}
