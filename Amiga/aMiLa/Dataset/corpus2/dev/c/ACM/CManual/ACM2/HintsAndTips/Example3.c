/* Example 3 */
/* This program will not open any console window if run from */
/* workbench. The disadvantage is of course that you can not */
/* use any "console functions" such as printf().             */

void _main();

void _main() /* Note the special character in front of main()! */
{
  int loop;

  /* Wait for a while: */
  for( loop = 0; loop < 500000; loop++ )
    ;
}
