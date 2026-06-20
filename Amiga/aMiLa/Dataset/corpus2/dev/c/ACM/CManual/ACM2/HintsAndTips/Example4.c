/* Example 4                                              */
/* This program tells you if it was run from workbench or */
/* from a CLI window.                                     */

void main();

void main( argc, argv )
int argc;
char *argv[];
{
  int loop;


  if( argc )
    printf( "This program was started from a CLI window!\n" );
  else
    printf( "This program was started from Workbench!\n" );


  /* Wait for a while: */
  for( loop = 0; loop < 500000; loop++ )
    ;
}
