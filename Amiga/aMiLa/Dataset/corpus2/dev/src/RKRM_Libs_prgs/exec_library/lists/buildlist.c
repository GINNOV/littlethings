;/* buildlist.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 buildlist.c
Blink FROM LIB:c.o,buildlist.o TO buildlist LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

buildlist.c - example which uses an application-specific Exec list


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

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>

#include <string.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)  { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }  /* really */
#endif

/* Our function prototypes */
VOID AddName(struct List *, UBYTE *);
VOID FreeNameNodes(struct List *);
VOID DisplayNameList(struct List *);
VOID DisplayName(struct List *, UBYTE *);

struct NameNode {
    struct Node nn_Node;        /* System Node structure */
    UBYTE  nn_Data[62];         /* Node-specific data */
};

#define NAMENODE_ID   100       /* The type of "NameNode" */

VOID main(VOID)
{
    struct  List    *NameList;    /* Note that a MinList would also work */

    if (!( NameList = AllocMem(sizeof(struct List),MEMF_CLEAR)) )
        printf("Out of memory\n");
    else {
        NewList(NameList);        /* Important: prepare header for use */

        AddName(NameList,"Name7");   AddName(NameList,"Name6");
        AddName(NameList,"Name5");   AddName(NameList,"Name4");
        AddName(NameList,"Name2");   AddName(NameList,"Name0");

        AddName(NameList,"Name7");   AddName(NameList,"Name5");
        AddName(NameList,"Name3");   AddName(NameList,"Name1");

        DisplayName(NameList,"Name5");
        DisplayNameList(NameList);

        FreeNameNodes(NameList);
        FreeMem(NameList,sizeof(struct List));  /* Free list header */
    }
}

/* Allocate a NameNode structure, copy the given name into the structure,
 * then add it the specified list.  This example does not provide an
 * error return for the out of memory condition.
*/
VOID AddName(struct List *list, UBYTE *name)
{
    struct NameNode *namenode;

    if (!( namenode = AllocMem(sizeof(struct NameNode),MEMF_CLEAR) ))
        printf("Out of memory\n");
    else {
        strcpy(namenode->nn_Data,name);
        namenode->nn_Node.ln_Name = namenode->nn_Data;
        namenode->nn_Node.ln_Type = NAMENODE_ID;
        namenode->nn_Node.ln_Pri  = 0;
        AddHead((struct List *)list,(struct Node *)namenode);
    }
}

/*
 * Free the entire list, including the header.  The header is not updated
 * as the list is freed.  This function demonstrates how to avoid
 * referencing freed memory when deallocating nodes.
 */
VOID FreeNameNodes(struct List *list)
{
    struct NameNode *worknode;
    struct NameNode *nextnode;

    worknode = (struct NameNode *)(list->lh_Head); /* First node */
    while (nextnode = (struct NameNode *)(worknode->nn_Node.ln_Succ)) {
        FreeMem(worknode,sizeof(struct NameNode));
        worknode = nextnode;
    }

}

/*
 * Print the names of each node in a list.
 */
VOID DisplayNameList(struct List *list)
{
struct Node *node;

    if (list->lh_TailPred == (struct Node *)list)
        printf("List is empty.\n");
    else {
        for (node = list->lh_Head ; node->ln_Succ ; node = node->ln_Succ)
            printf("%lx -> %s\n",node,node->ln_Name);
    }
}

/*
 * Print the location of all nodes with a specified name.
 */
VOID DisplayName(struct List *list, UBYTE *name)
{
struct Node *node;

    if (node = FindName(list,name)) {
        while (node) {
            printf("Found a %s at location %lx\n",node->ln_Name,node);
            node = FindName((struct List *)node,name);
        }
    } else printf("No node with name %s found.\n",name);
}