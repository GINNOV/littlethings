/* 
** Program: HelloWorld-Standard
** Version: 1.1
** Description: The Original program.
**                  Part of the HelloWorld-Multi destribution. Shows
**                  the difference in complexity between multitasking
**                  and single tasking programs.
**
** Author: Jeroen Knoester
** Date: 13 January 2000
** Copyright: (c) 2000, Jeroen Knoester.
*/

/* Note:           This code is meant for your enjoyment.
 *                   Added waiting for a key, so the average
 *                   Workbench-user still sees what is happening..
 * Known Bugs: Are you kidding? 
 */

#include <stdio.h>

int main ()
{
   int dummy;
   /* As you can see, printing helloworld in a single tasking
    * environment is a lot simpler.
    */
   printf ( "Hello World\n");
   /* We will now wait for a keypress, since usage from workbench
    * would remove the console window all to quickly.
    * Note that there are *much* better ways to make sure that a
    * workbench started program doesn't exit to soon when it's
    * output is to a console window. But that would make this program
    * much larger..
    */
   printf ( "Press return to exit!");
   scanf ( "%c",&dummy);
}
/*** EOF ***/