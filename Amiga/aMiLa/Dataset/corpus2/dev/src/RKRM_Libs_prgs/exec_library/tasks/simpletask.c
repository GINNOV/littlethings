;/* simpletask.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 simpletask.c
Blink FROM LIB:c.o,simpletask.o TO simpletask LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

simpletask.c - Uses the amiga.lib function CreateTask() to create a simple
subtask.  See the Includes and Autodocs manual for CreateTask() source code


Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/tasks.h>
#include <libraries/dos.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdlib.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }   /* Disable Lattice CTRL/C handling */
int chkabort(void) {return(0);}
#endif

#define STACK_SIZE 1000L

/* Task name, pointers for allocated task struct and stack */
struct Task *task = NULL;
char *simpletaskname = "SimpleTask";

ULONG sharedvar;

/* our function prototypes */
void simpletask(void);
void cleanexit(UBYTE *,LONG);

void main(int argc,char **argv)
{
    sharedvar = 0L;

    task = CreateTask(simpletaskname,0,simpletask,STACK_SIZE);
    if(!task)  cleanexit("Can't create task",RETURN_FAIL);

    printf("This program initialized a variable to zero, then started a\n");
    printf("separate task which is incrementing that variable right now,\n");
    printf("while this program waits for you to press RETURN.\n");
    printf("Press RETURN now: ");
    getchar();

    printf("The shared variable now equals %ld\n",sharedvar);

    /* We can simply remove the task we added because our simpletask does not make */
    /* any system calls which could cause it to be awakened or signalled later.    */
    Forbid();
    DeleteTask(task);
    Permit();
    cleanexit("",RETURN_OK);
}

void simpletask()
{
    while(sharedvar < 0x8000000) sharedvar++;
    /* Wait forever because main() is going to RemTask() us */
    Wait(0L);
}

void cleanexit(UBYTE *s, LONG e)
{
    if(*s) printf("%s\n",s);
    exit(e);
}