/* 
** Program: Multi_Printf()
** Version: 1.3
** Description: A better way to print to Stdio for multitasking
**                  programs.
**
** Author: Jeroen Knoester
** Date: 13 January 2000
** Copyright: (c) 2000, Jeroen Knoester.
*/

/* Note:           This code is meant for your enjoyment.
 *                   Added a small extra to main: A scanf(), so
 *                   that someone starting the executable from
 *                   workbench would still get to actually see the
 *                   output..
 * Known Bugs: The entire output_handle is flushed every
 *                   time the routine Multi_Print() is called. This
 *                   can be something that you don't want. If so,
 *                   you should remove the call to Flush().
 */

#include <stdlib.h>

#include <dos/dostags.h>
#include <clib/dos_protos.h>

BPTR output_handle=NULL; /* This global variable should contain the
                                       * handle to stdio.
                                       */

void Multi_Print ( char *text )
{
   /* This function does not do any formatting of your text, nor does it
    * check if the Output handle is correct. You will have to take care of
    * both. See the example main() for more info.
    */

   Forbid();
      /* We will write to the specified output_handle here.
       */
      Write ( output_handle, text, strlen(text) );
      Flush ( output_handle );
   Permit();
}

int main ()
{
   char test[255];
   int dummy;

   output_handle = Output(); /* Read which handle is stdio.. */

   /* We will now print a line of text: */

   sprintf ( test, "Hello, world.\n"); /* We use sprintf() to format our text.
                                                 * Although that is not nessecary for this
                                                 * example, it is the best way to create
                                                 * formatted strings.
                                                 */
   Multi_Print ( test );

   printf ("Press return to exit");
   scanf("%c",&dummy);

   return 0; /* All went well.. */
}
/*** EOF ***/