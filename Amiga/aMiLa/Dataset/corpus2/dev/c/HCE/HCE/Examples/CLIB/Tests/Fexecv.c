/* Test 'fexecv()' by Jason Petty (16/6/94). (See 'LIB.doc' for details)
 * This test calls the 'copy' command (which lives in your 'c:' directory)
 * and shows it's failed return code.
 */

long fexecv(), printf();
void main(), exit();

void main()
{
          /* fexec(char *cmd,char *argv[]); */
          /* The array of arguments are optional and */
          /* are left out here to show the commands */
          /* failed return code. */

  printf("\nReturn code from copy = %ld\n", fexecv("c:copy",0L));
 exit(0);
}

