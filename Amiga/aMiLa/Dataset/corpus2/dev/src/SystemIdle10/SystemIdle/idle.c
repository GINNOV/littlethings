/*****************************************************************

    SystemIdler V1.0 (Idle counter module for TinyMeter 3.6)  by
    Tinic Urou in 1995, FreeWare, orginal code by Thomas Radtke.
    Use this at your own risk. Please leave me a mail if you are
    using this code in your programs:

        EMail: tinic@tinic.mayn.sub.de

    I modified the code from cpuload2. The routines to count the
    maximum  are  much  more  better I think, since they use the
    exact same  number  of  cycles  as  the  normal  idle  count
    routine.
    On a A4000/030, disabling the startup-sequence, you will now
    get  1%  usage.  With  all my tools I get 9-12% usage. These
    results should be correct.

    Bugs: None known.
    ¯¯¯¯
    Invoking:
    ¯¯¯¯¯¯¯¯
    init_idle(); to setup the idle task
    free_idle(); to remove the idle Task

    unsigned long idle;      is the actual idlecount
    unsigned long maximum;   is the maximum idlecount

    To get f.ex. the percentage of system usage simply use:

    __________________________________________________________

        extern unsigned long maximum,idle;

        showusage()
        {
            int percent,n;

            if(init_idle())
            {
                for(n=0;n<25;n++)
                {
                    percent=(int)((idle*100)/maximum);
                    printf("%d percent free\n",percent);
                    Delay(50L);
                }
                free_idle();
            }
        }

    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Used compiler:  gcc  2.7.0  with  libnix  1.0  Look  at  the
    makefile for the used options.

*******************************************************************/

#include <intuition/IntuitionBase.h>
#include <exec/nodes.h>
#include <exec/tasks.h>
#include <libraries/dos.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <exec/libraries.h>
#include <dos/dos.h>

extern  struct          Task *FindTask(char *);
        struct          Task *task,*task2,*met;

        char            *taskname_1 = "CPU_GET",
                        *taskname_2 = "CPU_SET";

        BOOL            quit_setidle,
                        quit_getidle,
                        start_count=TRUE;

        unsigned long   maximum,
                        cnt,
                        idle;

getidle()
{
    struct          timeval updateval;
    int             n;
    struct MsgPort  *timerport;
    struct          timerequest *tr;
    struct          Task *met2;

    /* use "__geta4 getidle()" for DICE or SAS and remove geta4(); */

    geta4();

    met2=FindTask(NULL);

    if ((timerport=(struct MsgPort *)CreatePort (0,0)))
    {
        if ((tr=(struct timerequest *)CreateExtIO(timerport,sizeof(struct timerequest))))
        {
            if ((OpenDevice (TIMERNAME,UNIT_MICROHZ,(struct IORequest *)tr,0))!=0)
            {
                DeleteExtIO(tr);
                DeletePort(timerport);
                goto error;
            }
        }
        else
        {
            DeletePort(timerport);
            goto error;
        }
    }
    else goto error;

    updateval.tv_secs =1;
    updateval.tv_micro=0;

    while((met2->tc_SigRecvd & SIGBREAKF_CTRL_D)==0)
    {
        /* signal setidle()-task, that we can start counting */

        start_count=FALSE;

        cnt=0;
        tr->tr_node.io_Command=TR_ADDREQUEST;
        tr->tr_time=updateval;
        DoIO((struct IORequest *)tr);
        idle=cnt;

        /* check if we have to setup maximum */
        if(maximum==0)
        {
            maximum=idle;
            Signal(met,SIGBREAKF_CTRL_D);
        }
    }

    CloseDevice(tr);
    DeleteExtIO(tr);
    DeletePort(timerport);

    error:

    quit_getidle=FALSE;
    start_count =FALSE;

    idle   =100000;    /* to avoid divisions by zero from the application */
    maximum=100000;

    /* Do nothing and wait for DeleteTask() */

    Wait(0L);

}

setidle()
{
    /* use "__geta4 setidle()" for DICE or SAS and remove geta4(); */

    geta4();

    if(met=FindTask(NULL))
    if(task=(struct Task *)CreateTask(taskname_1,127,getidle,4096))
    {
        quit_getidle=TRUE;

        /* Wait for beginning. Allocating a timerequest may take a while */

        while (start_count) cnt=0;                                         

        /* maximum counter */
        while ((met->tc_SigRecvd & SIGBREAKF_CTRL_D)==0) cnt++;
        SetSignal(0,SIGBREAKF_CTRL_D);

        met->tc_Node.ln_Pri=-127;

        /* idle counter */
        while ((met->tc_SigRecvd & SIGBREAKF_CTRL_D)==0) cnt++;

        met->tc_Node.ln_Pri=0;

        Signal(task,SIGBREAKF_CTRL_D);
        while(quit_getidle) cnt=0;

        /* remove getidle()-task */

        Forbid();
        DeleteTask(task);
        Permit();
    }

    idle   =100000;    /* to avoid divisions by zero from the       */
    maximum=100000;    /* application, if creation of task failed.  */

    quit_setidle=FALSE;
    Wait(0L);
}

struct Task *init_idle()
{
    if( task2=(struct Task *)CreateTask(taskname_2,126,setidle,4096))
    {
        Delay(50L); /* To avoid the use of idle and maximum before they're initialized */
    }
    return(task2);
}

free_idle()
{
    quit_setidle=TRUE;
    Signal(task2,SIGBREAKF_CTRL_D);
    while(quit_setidle) Delay(10L);

    /* remove setidle()-task */

    Forbid();
    DeleteTask(task2);
    Permit();
}
