/*
 *	File:					List.h
 *	Description:	A set of functions for manipulating Exec lists.
 *
 *	(C) 1993,1994,1995 Ketil Hunn
 *
 */

#ifndef LIST_C
#define	LIST_C

/*** INCLUDES ************************************************************************/
#include "System.h"
#include "list.h"
//#include <exec/nodes.h>


/*** DEFINES *************************************************************************/
#define	ARGNODE	(NT_USER)
#define	COMNODE	(NT_USER-1)

/*** FUNCTIONS ***********************************************************************/
__asm BYTE IsNil(register __a0 struct List *list)
{
	if(list==NULL)
		return 1;
	return (BYTE)(IsListEmpty(list));
}

__stackext void RemoveNode(struct Node *node)
{
#ifdef MYDEBUG_H
	DebugOut("RemoveNode");
#endif

	if(node)
	{
		if(node->ln_Pred!=NULL & node->ln_Succ!=NULL)
			Remove(node);

		if(node->ln_Name)
			free(node->ln_Name);

		if(node->ln_Type==COMNODE)
			FreeList(((struct CommandNode *)node)->argumentlist);

		FreeVec(node);
	}
}

void ClearList(struct List *list)
{
#ifdef MYDEBUG_H
	DebugOut("ClearList");
#endif

	while(!IsNil(list))
		RemoveNode(list->lh_Head);
}

void FreeList(struct List *list)
{
#ifdef MYDEBUG_H
	DebugOut("FreeList");
#endif

	ClearList(list);
	FreeVec(list);
}

struct List *InitList(void)
{
	struct List *list;

#ifdef MYDEBUG_H
	DebugOut("ListInit");
#endif

	if(list=AllocVec(sizeof(struct List), MEMF_CLEAR|MEMF_PUBLIC))
		NewList(list);

	return list;
}

struct CommandNode *AddCommandNode(struct List *list, struct Node *prevnode, char *name)
{
	struct CommandNode *node;

#ifdef MYDEBUG_H
	DebugOut("AddCommandNode");
#endif

	if(node=AllocVec(sizeof(struct CommandNode), MEMF_CLEAR|MEMF_PUBLIC))
	{
		node->nn_Node.ln_Name=strdup((name ? name:"\0"));
		node->nn_Node.ln_Type=COMNODE;
		if(node->argumentlist=InitList())
		{
			if(prevnode==NULL)
				AddTail(list, node);
			else if(prevnode==list->lh_Head)
				AddHead(list, node);
			else
				Insert(list, node, prevnode->ln_Pred);
		}
		else
		{
			FreeVec(node);
			node=NULL;
		}
	}
	return node;
}

struct Node *AddNode(struct List *list, struct Node *prevnode, char *name)
{
	struct Node *node;

#ifdef MYDEBUG_H
	DebugOut("AddNode");
#endif

	if(node=AllocVec(sizeof(struct Node), MEMF_CLEAR|MEMF_PUBLIC))
	{
		node->ln_Name=strdup((name ? name:"\0"));
		node->ln_Type=ARGNODE;
		if(prevnode==NULL)
			AddTail(list, node);
		else if(prevnode==list->lh_Head)
			AddHead(list, node);
		else
			Insert(list, node, prevnode->ln_Pred);
	}
	return node;
}

void RenameNode(struct Node *node, char *name)
{
#ifdef MYDEBUG_H
	DebugOut("RenameNode");
#endif

	free(node->ln_Name);
	node->ln_Name=strdup(name);
}

void CopyNode(struct List *list, struct Node **buffer, struct Node *node)
{
#ifdef MYDEBUG_H
	DebugOut("CopyEvent");
#endif

	if(*buffer!=NULL)
		RemoveNode(*buffer);

	*buffer=DuplicateNode(node);
	(*buffer)->ln_Pred=NULL;
	(*buffer)->ln_Succ=NULL;

}

struct Node *CutNode(struct List *list, struct Node **buffer, struct Node *node)
{
	struct Node *activatenext=NULL;

#ifdef MYDEBUG_H
	DebugOut("CutEvent");
#endif

	if(*buffer!=NULL)
		RemoveNode(*buffer);

	if(node->ln_Succ!=NULL & node!=list->lh_TailPred)
		activatenext=node->ln_Succ;
	else if(node->ln_Pred!=NULL & node!=list->lh_Head)
		activatenext=node->ln_Pred;

	*buffer=node;
	Remove(node);
	node->ln_Pred=NULL;
	node->ln_Succ=NULL;

	return activatenext;
}

struct Node *PasteNode(struct List *list, struct Node *buffer, struct Node *before)
{
	struct Node *newnode;
#ifdef MYDEBUG_H
	DebugOut("PasteNode");
#endif

	newnode=DuplicateNode(buffer);
	if(before==NULL)
		AddTail(list, newnode);
	else
		Insert(list, newnode, before->ln_Pred);

	return newnode;
}

__stackext struct Node *DuplicateNode(struct Node *node)
{
	struct Node					*newnode;
	struct CommandNode	*commandnode;

#ifdef MYDEBUG_H
	DebugOut("DuplicateNode");
#endif

	switch(node->ln_Type)
	{
		case COMNODE:
			if(commandnode=AllocVec(sizeof(struct CommandNode), MEMF_CLEAR|MEMF_PUBLIC))
			{
				struct CommandNode *enode=(struct CommandNode *)node;

				CopyMem(node, commandnode, sizeof(struct CommandNode));
				commandnode->nn_Node.ln_Name=strdup(node->ln_Name);
				commandnode->argumentlist=DuplicateList(enode->argumentlist);
			}
			newnode=(struct Node *)commandnode;
			break;

		case ARGNODE:
			if(commandnode=AllocVec(sizeof(struct CommandNode), MEMF_CLEAR|MEMF_PUBLIC))
			{
				CopyMem(node, commandnode, sizeof(struct CommandNode));
				commandnode->nn_Node.ln_Name=strdup(node->ln_Name);
			}
			newnode=(struct Node *)commandnode;
			break;
	}
	return newnode;
}

__stackext struct List *DuplicateList(struct List *list)
{
	struct List *newlist;
	register struct Node *node;

#ifdef MYDEBUG_H
	DebugOut("DuplicateList");
#endif

	if(newlist=InitList())
		for(every_node)
			AddTail(newlist, DuplicateNode(node));

	return newlist;
}

ULONG Count(struct List *list)
{
	register struct Node	*node;
	register ULONG				i=0;

#ifdef MYDEBUG_H
	DebugOut("Count");
#endif

	if(!IsNil(list))
		for(every_node)
			++i;
	return i;
}

void Up(struct Window		*window,
				struct egGadget	*gadget,
				struct List			*list,
				struct Node			*node)
{
	struct Node *pred=node->ln_Pred->ln_Pred;

#ifdef MYDEBUG_H
	DebugOut("Up");
#endif

	DetachList(gadget, window);
	Remove(node);
	Insert(list, node, pred);
	AttachList(gadget, window, list);
}

void Down(struct Window		*window,
					struct egGadget *gadget,
					struct List			*list,
					struct Node			*node)
{
	struct Node *succ=node->ln_Succ;

#ifdef MYDEBUG_H
	DebugOut("Down");
#endif

	DetachList(gadget, window);
	Remove(node);
	Insert(list, node, succ);
	AttachList(gadget, window, list);
}
/*
void Top(	struct Window		*window,
					struct egGadget	*gadget,
					struct List			*list,
					struct Node			*node)
{
#ifdef MYDEBUG_H
	DebugOut("Top");
#endif
	DetachList(window, gadget);
	Remove(node);
	AddHead(list, node);
	AttachList(window, gadget,list);
}

void Bottom(struct Window		*window,
						struct egGadget	*gadget,
						struct List			*list,
						struct Node			*node)
{
#ifdef MYDEBUG_H
	DebugOut("Bottom");
#endif
	DetachList(window, gadget);
	Remove(node);
	AddTail(list, node);
	AttachList(window, gadget, list);
}
*/

__asm struct Node *GetHead(register __a0 struct List *list)
{
	return (IsNil(list) ? NULL : list->lh_Head);
}

__asm struct Node *GetTail(register __a0 struct List *list)
{
	return (IsNil(list) ? NULL : list->lh_TailPred);
}

__asm struct Node *GetSucc(	register __a0 struct List *list,
														register __a1 struct Node *node)
{
	return (node==NULL | node==list->lh_TailPred ? NULL : node->ln_Succ);
}

__asm struct Node *GetPred(register __a0 struct Node *node)
{
	return (node==NULL ? NULL:node->ln_Pred);
}

#endif
