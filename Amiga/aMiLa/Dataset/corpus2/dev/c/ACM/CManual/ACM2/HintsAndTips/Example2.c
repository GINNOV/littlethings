/* Example 2                                                  */
/* This program will print "Hello!" in the CLI window if      */
/* started from CLI, or the text will be printed in a special */
/* window that is automatically opened if run from workbench. */

void main();

void main()
{
  int loop;  

  printf( "Hello!\n" );

  /* Wait for a while: */
  for( loop = 0; loop < 500000; loop++ )
    ;
}
