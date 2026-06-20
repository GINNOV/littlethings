/* Amiga C++ Lists
**	Copyright (C) 1986, by MTS Associates, Jacksonville FL
**	All rights reserved.  Duplication of this data by other than
**	licensed users is a violation of copyright law.
**
**	Function prototypes for the exec.library of Amiga EXEC
**
**	Updated: 11/17/86, TFH
*/

#ifndef EXEC_LISTS_H
#define EXEC_LISTS_H
#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

struct List;

void AddHead(List* l, Node* n);
void AddTail(List* l, Node* n);
void Enqueue(List* l, Node* n);
void NewList(List* l);

void Insert( List *l,  Node* n1,  Node *n2);
Node * RemHead( List* l);
Node * RemTail( List* l);

struct uMinList {	// uninitialized MinList
    struct MinNode *mlh_Head;
    struct MinNode *mlh_Tail;
    struct MinNode *mlh_TailPred;

	BOOL isempty() { return (mlh_Head->ln_Succ == NULL); }
	void add(Node *n) {AddHead((List *)this,n);}
	void insert(Node *n1, Node *n2) {Insert((List *)this, n1, n2);}
	void append(Node *n) {AddTail((List *)this,n);}
	void remove(Node *n) {Remove(n);}
	MinNode *get() {return (MinNode *)RemHead((List *)this);}
	MinNode *first() { return (MinNode *)mlh_Head; }
	MinNode *remove() {return (MinNode *)RemHead((List *)this);}
};

struct MinList : public uMinList {
    MinList()
    { mlh_Head = (MinNode *) &mlh_Tail;
      mlh_Tail = NULL;
      mlh_TailPred = (MinNode *) &mlh_Head;
    }
};

struct uList : public uMinList {  // uninitialized List
#define lh_Head mlh_Head
#define lh_Tail mlh_Tail
#define lh_TailPred mlh_TailPred

    UBYTE   lh_Type;
    UBYTE   lh_pad;

	BOOL isempty() { return (lh_Head->ln_Succ == NULL); }

	void add(Node *n) {AddHead((List *)this,n);}
	void insert(Node *n1, Node *n2) {Insert((List *)this, n1, n2);}
	void append(Node *n) {AddTail((List *)this,n);}
	Node *get() {return RemHead((List *)this);}

	Node *first() { return (Node *) lh_Head; }
	Node *find(TEXT *n) {return FindName((Node *) this, n);}
};

struct List : public uList {

	List(Node_Type nodetype = NT_UNKNOWN) {	// initializer
		lh_Head = (Node *) &lh_Tail;
		lh_TailPred = (Node *) &lh_Head;
		lh_Tail = NULL;
		lh_Type = nodetype;
		lh_pad = 0;		// be neat!
	}
};
#endif
