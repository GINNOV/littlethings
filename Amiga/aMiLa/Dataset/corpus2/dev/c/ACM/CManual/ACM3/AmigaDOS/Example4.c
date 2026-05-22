/* Example 4                                                         */
/* This example demonstrates how to delete files and directories. It */
/* will delete the file Example 1 and directory Example 2 created.   */
/* (The file and directory are supposed to have been renamed by      */
/* Example 3.)                                                       */


/* This file declares the type BOOL: */
#include <exec/types.h>


void main();

void main()
{
  BOOL ok;


  /* Delete the file: */
  ok = DeleteFile( "RAM:Numbers.dat" );

  /* Check if the file was successfully deleted: */
  if( !ok )
    printf( "The file could not be deleted!\n" );


  /* Delete the directory: */
  ok = DeleteFile( "RAM:NewDirectory" );

  /* Check if the directory was successfully deleted: */
  if( !ok )
    printf( "The directory could not be deleted!\n" );
}

