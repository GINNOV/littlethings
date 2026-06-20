/* 
** Program: HelloWorld-Process
** Version: 1.0
** Description: A multitasking hello-world.
**                  Example of multitasking through AmigaDos CreateNewProc().
**
** Author: Jeroen Knoester
** Date: 13 January 2000
** Copyright: (c) 2000, Jeroen Knoester.
*/

/* Note:           This code is meant for your enjoyment.
 * Known Bugs: The program can crash if invalid input is
 *                   given ( no number, or an early pressing of return.. )
 *
 *                   The program can crash if a different program writes
 *                   to the same console as this one.
 */

#include <stdlib.h>
#include <stdio.h>

#include <dos/dostags.h>
#include <clib/dos_protos.h>

int number=0; /* Global variables are a reasonable way to communicate
                    * status information throughout a multi-tasking ( or 
                    * threading ) program. However, you should make sure that
                    * access on these variables is made atomic. In other words,
                    * no other task should be able to change or read these
                    * communication variables while you change them. If you
                    * want interprocess communication without having to halt
                    * your system for each change, set up a message handler..
                    */
int times=0;

BOOL allow_change=TRUE; /* By the way, Boolean's rule!  ;) */

BPTR output_handle=NULL; /* Oh, we need this so our processes know
                                       * where to Write() to.
                                       */

int Hello_Multi ()
{
   int loopcounter=1;
   int task_id=0;
   char test[127];

   /* This here be 'atomic' code..
    * Code between Forbid() and Permit() is
    * protected against task-changes.
    */ 

   Forbid();
     task_id=number;
     allow_change=TRUE;
   Permit();

   /* Note that reported task id's are our own internal representation
    * of task id's. The 'real' task id is something wildly different. And
    * not really of interest to us.
    */

   while ( loopcounter < times+1 )
   {
      /* Okay, a word about printf(). This function is not adequate
       * for usage in a multitasking environment. It will cause trouble
       * such as double lines, broken lines or missing lines in your
       * output. You're better of not using it.
       */

      sprintf ( test,"Hello World is running as process (%d),Loop step no. %d!\n\0",
                  task_id,loopcounter );
      Write ( output_handle, test, strlen(test) );
      Flush ( output_handle );

      loopcounter++;
   }

   DeleteTask (0L); /* When we're done, delete yourself. 
                            * Note that you can delete processes using
                            * the DeleteTask() function.
                            */
}

int main ()
{
   int dummy;

   struct Process *process=NULL; /* A process structure for process 1 */
   struct Process *process2=NULL; /* A process structure for process 2.. :) */

   char *procname = "PP_HelloProcess I"; /* Name of process 1 */
   char *procname2 = "PP_HelloProcess II"; /* Name of process 2 :) */

   /* In order that our processes know where to send their
    * output, we use a global variable output_handle.
    */

   output_handle = Output(); /* Read which handle is stdio.. */

   printf ( "How many times should each process do it's thing? ");
   scanf ( "%d",&times);
   
   printf ( "Hello World, this is the multi-tasking version of hello-world! \n");
   printf ( "We will run hello world %d times, in two processes.\n",times);
   printf ( "Have fun!\n\n");

   /* Set up a process. After this point, execution order of the program
    * is no longer garuanteed. Keep that in mind. 
    */

   allow_change=FALSE;
   process=CreateNewProcTags(NP_Entry,Hello_Multi,
                                           NP_Name,(STRPTR)procname );

   if ( process == NULL )
   {
      printf ( "Bummer, The first process refused to start..\n");
      exit (20);
   }

   /* ALWAYS check the result of functions. Especially nasty
    * low-level ones.
    */

   while ( allow_change !=TRUE )
   {
      /* This is a form of waiting that gives back processor
       * time as we wait for the process to become created.
       * This is a reasonable way to wait. We could also use
       * messageports or semaphores for this.
       */ 
      Delay(1L);
   }
   number++; /* Raise the task-id counter. */

   process2=CreateNewProcTags(NP_Entry,Hello_Multi,
                                            NP_Name,(STRPTR)procname2 );

   if ( process2 == NULL )
   {
      printf ( "Bummer, The second process refused to start..\n");
      exit (20);
   }

   printf ("Press return after the show!\n");
   scanf("%c",&dummy);

   exit (0); /* Always exit with a smile on your face.. */
}
/*** EOF ***/