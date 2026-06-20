;/* tasklist.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 tasklist.c
Blink FROM LIB:c.o,tasklist.o TO tasklist LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

tasklist.c - Snapshots and prints the ExecBase task list


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
#include <exec/lists.h>
#include <exec/nodes.h>
#include <exec/memory.h>
#include <exec/execbase.h>

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>

#include <stdio.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }   /* disable SAS/C CTRL-C handing */
int chkabort(void) {return(0); }
#endif

static UBYTE *VersTag = "$VER: tasklist 37.2 (31.3.92)";
extern struct ExecBase *SysBase;

/* Use extended structure to hold task information */
struct TaskNode {
    struct Node tn_Node;
    ULONG tn_TaskAddress;
    ULONG tn_SigAlloc;
    ULONG tn_SigWait;
    UBYTE tn_Name[32];
};




void main(int argc, char **argv)
{
    struct List *ourtasklist;
    struct List *exectasklist;
    struct Task *task;
    struct TaskNode *node, *tnode, *rnode = NULL;
    struct Node *execnode;

    /* Allocate memory for our list */
    if (ourtasklist = AllocMem(sizeof(struct List), MEMF_CLEAR)) {
        /* Initialize list structure (ala NewList()) */
        ourtasklist->lh_Head = (struct Node *)&ourtasklist->lh_Tail;
        ourtasklist->lh_Tail = 0;
        ourtasklist->lh_TailPred = (struct Node *)&ourtasklist->lh_Head;

        /* Make sure tasks won't switch lists or go away */
        Disable();

        /* Snapshot task WAIT list */
        exectasklist = &(SysBase->TaskWait);
        for (execnode = exectasklist->lh_Head;
                 execnode->ln_Succ; execnode = execnode->ln_Succ)
        {
            if (tnode = AllocMem(sizeof(struct TaskNode), MEMF_CLEAR))
            {
                /* Save task information we want to print */
                strncpy(tnode->tn_Name, execnode->ln_Name, 32);
                tnode->tn_Node.ln_Pri = execnode->ln_Pri;
                tnode->tn_TaskAddress = (ULONG)execnode;
                tnode->tn_SigAlloc = ((struct Task *)execnode)->tc_SigAlloc;
                tnode->tn_SigWait = ((struct Task*)execnode)->tc_SigWait;
                AddTail(ourtasklist, (struct Node *)tnode);
            }
            else break;
        }

        /* Snapshot task READY list */
        exectasklist = &(SysBase->TaskReady);
        for (execnode = exectasklist->lh_Head;
                 execnode->ln_Succ; execnode = execnode->ln_Succ)
        {
            if (tnode = AllocMem(sizeof(struct TaskNode), MEMF_CLEAR))
            {
                /* Save task information we want to print */
                strncpy(tnode->tn_Name, execnode->ln_Name, 32);
                tnode->tn_Node.ln_Pri = execnode->ln_Pri;
                tnode->tn_TaskAddress = (ULONG)execnode;
                tnode->tn_SigAlloc = ((struct Task *)execnode)->tc_SigAlloc;
                tnode->tn_SigWait = ((struct Task*)execnode)->tc_SigWait;
                AddTail(ourtasklist, (struct Node *)tnode);
                if(!rnode)  rnode = tnode;  /* first READY task */
            }
            else
                break;
        }

        /* Re-enable interrupts and taskswitching */
        Enable();

        /* Print now (printing above would have defeated a Forbid or Disable) */
        printf("Pri Address     SigAlloc    SigWait    Taskname\n");

        node = (struct TaskNode *)(ourtasklist->lh_Head);
        printf("\nWAITING:\n");
        while (tnode = (struct TaskNode *)node->tn_Node.ln_Succ)
        {
            if(tnode == rnode)
                printf("\nREADY:\n");  /* we set rnode above */
            printf("%02d  0x%08lx  0x%08lx  0x%08lx %s\n",
                    node->tn_Node.ln_Pri, node->tn_TaskAddress, node->tn_SigAlloc,
                    node->tn_SigWait, node->tn_Name);

            /* Free the memory, no need to remove the node, referenced once only */
            FreeMem(node,sizeof(struct TaskNode));
            node = tnode;
        }
        FreeMem(ourtasklist, sizeof(struct List));

        /* Say who we are */
        printf("\nTHIS TASK:\n");
        task = FindTask(NULL);
        printf("%02d  0x%08lx  0x%08lx  0x%08lx %s\n",
                task->tc_Node.ln_Pri, task, task->tc_SigAlloc,
                task->tc_SigWait, task->tc_Node.ln_Name);

    }
}