/*
 *	File:					List.h
 *	Description:	
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef LIST_H
#define	LIST_H

/*** PRIVATE INCLUDES ****************************************************************/
#include <exec/lists.h>

/*** DEFINES *************************************************************************/
#define every_node	node=list->lh_Head;node->ln_Succ;node=node->ln_Succ

/*** PROTOTYPES **********************************************************************/
__asm BYTE IsNil(register __a0 struct List *list);
__stackext void RemoveNode(struct Node *node);
void ClearList(struct List *list);
void FreeList(struct List *list);
struct List *InitList(void);
struct CommandNode *AddCommandNode(struct List *list, struct Node *prevnode, char *name);
struct Node *AddNode(struct List *list, struct Node *prevnode, char *name);
void RenameNode(struct Node *node, char *name);
void CopyNode(struct List *list, struct Node **buffer, struct Node *node);
struct Node *CutNode(struct List *list, struct Node **buffer, struct Node *node);
struct Node *PasteNode(struct List *list, struct Node *buffer, struct Node *before);
__stackext struct Node *DuplicateNode(struct Node *node);
__stackext struct List *DuplicateList(struct List *list);
ULONG Count(struct List *list);
void Up(struct Window		*window,
				struct egGadget	*gadget,
				struct List			*list,
				struct Node			*node);
void Down(struct Window		*window,
					struct egGadget *gadget,
					struct List			*list,
					struct Node			*node);
void Top(	struct Window		*window,
					struct egGadget	*gadget,
					struct List			*list,
					struct Node			*node);
void Bottom(struct Window		*window,
						struct egGadget	*gadget,
						struct List			*list,
						struct Node			*node);
__asm struct Node *GetHead(register __a0 struct List *list);
__asm struct Node *GetTail(register __a0 struct List *list);
__asm struct Node *GetSucc(	register __a0 struct List *list,
														register __a1 struct Node *node);
__asm struct Node *GetPred(register __a0 struct Node *node);
#endif
