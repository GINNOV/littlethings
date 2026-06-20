/* 
** Program: HelloWorld-Tasking
** Version: 1.2
** Description: A multitasking hello-world.
**                  Example of multitasking through AmigaDos CreateNewProc() and
**                  Exec CreateTask().
**
** Author: Jeroen Knoester
** Date: 12 January 2000
** Copyright: (c) 2000, Jeroen Knoester.
*/

/* Note:           This code is meant for your enjoyment.
 * Known Bugs: The program can crash if another program
 *                   writes to the same console while this program
 *                   is still running.
 *
 *                   The program can crash if invalid input is
 *                   given ( no number, or an early pressing of return.. )
 */

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

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

int Hello_Multi(); /* In a real program, this would be in a header file! */

void Hello_Setup ()
{
   char procname[127]; /* This is somewhat overkill.. */

   /* This here function is a placeholder:
    * It's sole duty is to create a new process or fail.
    * We can't run the demonstration from tasks, because
    * a task is forbidden to use AmigaDOS stuff, such as
    * Write(). We are allowed to create new processes from
    * a task, though. And that is exactly what we will do.
    */

   struct Process *process=NULL; /* AmigaDos process stucture */

   /* Okay, this bit below is called a busy waiting loop.
    * You really shouldn't use this. It creates a huge ammount
    * of processor overhead, which can be avoided by waiting
    * in a different way. For instance, we could wait for the process
    * to signal us.
    * By the way, Delay() and such won't work, because they use
    * AmigaDOS, which we can't use here.. We'd need a process for
    * that.. 
    */

   while ( allow_change !=TRUE );

   /* Because we wait for allow_change to become true,
    * we know that our task-id's are properly set.. Read on..
    */

   number++; /* Increase the task_id counter. */

   sprintf ( procname, "PP_HelloProcess %d", number );

   /* Okay, first we disable multitasking and then
    * we set allow_change to be false. This makes sure that
    * the next call to Hello_Setup() will wait until the process
    * in Hello_Multi() is ready setting it's task-id. Usually,
    * you'd be better of using a better mechanism for
    * waiting than the one used in this function, but in this
    * case we can be reasonably certain that the code will
    * reach this point nice and fastish. ( Or chrash :) )
    */

   /* Here we create a new process. This particular call only
    * works on V36+ ( >= KS 2.0 )
    * The NP_Entry tag is to make use of a function, instead
    * of a file. The NP_Name tag is used to tell our process it's
    * name. Hello_Multi is the function-pointer to our entry-function,
    * Hello_Multi().
    */

   Forbid();
      allow_change=FALSE;
      process=CreateNewProcTags(NP_Entry,Hello_Multi,
                                              NP_Name,(STRPTR)procname );
   Permit();
   
   if ( process==NULL )
   {
     Wait (0L); /* Ermm, since we have no (easy) way to actually notify
                    * the user of our little problem, we'll just pretend this
                    * whole thing never happened..
                    */
   }

   Wait (0L); /* Wait for all eternity..!
                  * Which is a really BAD way to exit tasks. 
                  * A better way is needed for the main program
                  * to see a task-exit. By-the-by, this definatly
                  * goes for process-exit's as well...
                  */
}

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
      /* Okay, a word about printf(). This function is totally
       * inadequate for usage in a multi-tasking program such as
       * this one. If you do use printf() from other tasks than the
       * main one, you will get all kinds of weird problems. So don't.
       */

      sprintf ( test,"Hello World is running as task (%d),Loop step no. %d!\n\0",
                   task_id,loopcounter );
      Write ( output_handle, test, strlen(test) );
      Flush ( output_handle );

      loopcounter++;
   }

   DeleteTask (0L); /* When we're done, delete yourself. */
}

int main ()
{
   int dummy;

   struct Task *task=NULL; /* A task structure for task 1 */
   struct Task *task2=NULL; /* A task structure for task 2.. :) */

   /* A word about tasknames: They should be unique! ( If at all
    * possible, unique troughout the whole system.. )*/

   char *taskname = "PP_TaskHelloWorldMulti I"; /* Name of task 1 */
   char *taskname2 = "PP_TaskHelloWorldMulti II"; /* Name of task 2 :) */

   /* Okay, we need our two processes to do I/O on *this* console.
    * Since a task can't write to any console and created processes
    * don't know what output handle we've got, we use a global variable
    * called output_handle to contain the handle which conforms to the
    * console we started from.
    */

   output_handle = Output(); /* Read which handle is stdio.. */

   printf ( "How many times should each task do it's thing? ");
   scanf ( "%d",&times);
   
   printf ( "Hello World, this is the multi-tasking version of hello-world! \n");
   printf ( "We will run hello world %d times, in two processes.\n",times);
   printf ( "Have fun!\n\n");

   /* Set up a task. After this point, execution order of the program
    * is no longer garuanteed. Keep that in mind. Also keep in mind that
    * creating a task just to create a process is plain silly.
    */

   task = CreateTask ( taskname, 0L, Hello_Setup, 4096L );

   /* First parameter: name. 
    * Second: priority. Keep it between -5 and 5 for most things.
    *                        0 is a nice choice :)
    * Third: functionpointer. This is the startingpoint of the new
    *                                 task. It should have a prototype like
    *                                 this:  void name ();.
    * Fourth: Stacksize. For most programs, 4096 is enough,
    *                           however, it could be you need more.
    */

   if ( task == NULL )
   {
      printf ( "Bummer, The first task refused to start..\n");
      exit (20);
   }

   /* ALWAYS check the result of functions. Especially nasty
    * low-level ones.
    */

   task2 = CreateTask ( taskname2, 0L, Hello_Setup, 4096L );

   if ( task2 == NULL )
   {
      printf ( "Bummer, The second task refused to start..\n");
      exit (20);
   }

   /* Okay, now for the worst part of the program:
    * This program needs the users input to know it's
    * finished. Press return too early and weird things can
    * happen. A good program should use a different method
    * of figuring out when to quit, really..
    */

   printf ("Press return after the show!\n");
   scanf("%c",&dummy);

   /* Here we remove the two ( hopefully finished ) tasks
    * from the system. This is nasty code, but at least it
    * is 'atomic'.
    */

   Forbid();
      DeleteTask(task);
      DeleteTask(task2);
   Permit();

   exit (0); /* Always exit with a smile on your face.. */
}
/*** EOF ***/