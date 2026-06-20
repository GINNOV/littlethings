/*****************************************************************
* This file contains functions for manipulating the lists:
* 	doors: secret doors and regular key/button doors
* 	objects: decorations, obstacles, monsters, etc.
*****************************************************************/

#include "defines.h"

ListRec *doors;
ListRec *objects;
ListRec *buttons;


/*****************************************************************
* Inserts an allocated ListRec into a list.  List is either doors or objects
*****************************************************************/
ListRec *InsertNode(ListRec *node, ListRec *list)
{
ListRec *tmp=list;

	if (list==0)
	{
		list=node;
		list->next=NULL;
		list->prev=NULL;
		return list;
	}
	if (tmp->next==0)
	{
		tmp->next=node;
		node->next=NULL;
		node->prev=tmp;
		return list;
	}
	while (tmp->next) tmp=tmp->next;
	tmp->next=node;
	node->prev=tmp;
	node->next=0;
	return list;
}

/*****************************************************************
* Deletes a ListRec from a list.  List is either doors or objects
*****************************************************************/
ListRec *DeleteNode(ListRec *node, ListRec *list)
{
	if (list==node)
	{
		if (list->next)
		{
			list=list->next;
			list->prev=NULL;
		} else list=0;
		free(node);
		return list;
	}
	if (node->next==0)
	{
		node->prev->next=NULL;
		free(node);
		return list;
	}
	node->prev->next=node->next;
	node->next->prev=node->prev;
	free(node);
	return list;
}

/*****************************************************************
* Prints a Listrec node
*****************************************************************/
void PrintNode(ListRec *p)
{
	if (!p)
	{
		printf("PrintNode passed empty node (Returning).\n");
		return;
	}
	printf("PrintNode: prev=%d  current=%d  next=%d\n",p->prev,p,p->next);
	printf("General fields:\n");
	printf("	type=%d,  x=%lf,  y=%lf,  z=%lf\n",
		p->type, p->x, p->y, p->z);
	printf("	brushnumber=%d,  active=%d,  direction=%d, state=%d\n",
		p->brushnumber, p->active, p->direction, p->state);
	printf("Door Fields:\n");
	printf("	key=%d,  open=%d,  edge=%d\n",
		p->key, p->open, p->edge);
	printf("=============================================\n");
}

/*****************************************************************
* Prints a List.  (Either doors, or objects)
*****************************************************************/
void PrintList(ListRec *p)
{
ListRec *tmp=p;

	if (!tmp)
	{
		printf("PrintList passed empty node (Returning).\n");
		return;
	}
	for (;tmp;)
	{
		PrintNode(tmp);
        if (tmp->next==0) tmp=0; else tmp=tmp->next;
    }

}

/*****************************************************************
* Inserts a door or secretdoor into doors list.
*****************************************************************/
void InsertDoor(short edge, BYTE type, BYTE key, BYTE dir)
{
ListRec *R= (ListRec *)calloc(1,sizeof(ListRec));

	R->type = type;
	R->key = key;
	R->edge = edge;
	R->direction = dir;
	doors = InsertNode(R,doors);
}
/* num<edge#> t1<pt1> t2<pt2> t3<wall#> t4<doortype> t5<key> t6<dir> */

/*****************************************************************
* Inserts a door or secretdoor into doors list.
*****************************************************************/
void InsertButton(int edge, short dir, short start, short out, short in, short y)
{
ListRec *R= (ListRec *)calloc(1,sizeof(ListRec));

	R->type = BUTTON_BOOL;
	R->edge = edge;
	R->direction = dir;
	R->state = start;
	R->scry = y;
	R->wall1 = out;
	R->wall2 = in;
	buttons = InsertNode(R,buttons);
}
/* <edge#> <dir> <start_state> <press_out_wall#> <press_in_wall#> <y> */

