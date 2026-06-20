/* Example6                                                      */
/* This example demonstrates how to protect and unprotect files. */
/* The file Example 5 created ("Letter.doc") will be protected,  */
/* and we will then try to delete it (unsuccessfully). We will   */
/* then unprotect the file and then try to delete it             */
/* (successfully).                                               */  


/* Declares BOOL: */
#include <exec/types.h>
/* Declares the FileHandle structure: */
#include <libraries/dos.h>


void main();

void main()
{
  BOOL ok;


  /* Protect the file: */
  ok = SetProtection( "RAM:Letter.doc", FIBF_DELETE );

  /* Check if the file was successfully protected: */
  if( !ok )
    printf( "Could not protect the file!\n" );


  /* Try to delete the file: */
  ok = DeleteFile( "RAM:Letter.doc" );

  /* Check if the file was successfully deleteted: */
  if( !ok )
    printf( "Could not delete the file!\n" );
  else
    printf( "File deleted!\n" );



  /* Unprotect the file: */
  ok = SetProtection( "RAM:Letter.doc", NULL );

  /* Check if the file was successfully unprotected: */
  if( !ok )
    printf( "Could not unprotect the file!\n" );


  /* Try to delete the file: */
  ok = DeleteFile( "RAM:Letter.doc" );

  /* Check if the file was successfully deleteted: */
  if( !ok )
    printf( "Could not delete the file!\n" );
  else
    printf( "File deleted!\n" );
}
