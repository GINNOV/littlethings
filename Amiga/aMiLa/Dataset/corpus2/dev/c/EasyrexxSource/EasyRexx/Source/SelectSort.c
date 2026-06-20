/*
 *	File:					SelectSort.h
 *	Description:	
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef	SELECTSORT_H
#define	SELECTSORT_H

/*** INCLUDES ************************************************************************/
#include "System.h"
#include "SelectSort.h"
#include "List.h"

/*** FUNCTIONS ***********************************************************************/
__asm void SwapNodes(	register __a0 struct List *list,
											register __a1 struct Node *node1,
											register __a2 struct Node *node2)
{
	if(node1!=NULL & node2!=NULL)
	{
		register struct Node *tmp=node1->ln_Pred;

		Remove(node1);
		Insert(list, node1, node2);
		Remove(node2);
		Insert(list, node2, tmp);
	}
}

__asm struct Node *FindMinNode(	register __a0 struct List *list,
																register __a1 struct Node *node)
{
	register struct Node *minnode=node;

	while(TRUE)
	{
		if(Stricmp(node->ln_Name, minnode->ln_Name)<0)
			minnode=node;
		if(NULL==(node=GetSucc(list, node)))
			break;
	}
	return minnode;
}

__asm __stackext void SelectSort(register __a0 struct List *list)
{
	if(!IsNil(list))
	{
		register struct Node *node, *minnode;

		for(every_node)
			if(minnode=FindMinNode(list, node))
				if(Stricmp(node->ln_Name, minnode->ln_Name)>0)
				{
					SwapNodes(list, node, minnode);
					node=minnode;
				}
	}
}

#endif
