#ifndef LISTMACROS_H
#define LISTMACROS_H
/*
**	$Id: ListMacros.h,v 1.2 1999/02/07 14:41:02 bernie Exp $
**
**	Copyright (C) 1997 Bernardo Innocenti <bernardo.innocenti@usa.net>
**	All rights reserved.
**
**	Use 4 chars wide TABs to read this source
**
**	Some handy macros for list operations.  Using these macros is faster
**	than calling their exec.library equivalents, but they will eventually
**	make your code a little bigger and are also subject to common macro
**	side effects.
*/


#define NEWLIST(l)	( (l)->lh_TailPred = (struct Node *)(l),			\
					(l)->lh_Tail = 0,									\
					(l)->lh_Head = (struct Node *)(&((l)->lh_Tail)) )

#define ADDHEAD(l,n) ( (n)->ln_Pred = (struct Node *)(l),				\
					(n)->ln_Succ = (l)->lh_Head,						\
					(l)->lh_Head->ln_Pred = (n),						\
					(l)->lh_Head = (n) )

#define ADDTAIL(l,n) ( (n)->ln_Succ = (struct Node *)(&((l)->lh_Tail)),	\
					(n)->ln_Pred = (l)->lh_TailPred,					\
					(l)->lh_TailPred->ln_Succ = (n),					\
					(l)->lh_TailPred = (n) )

#define REMOVE(n)	( (n)->ln_Succ->ln_Pred = (n)->ln_Pred,				\
					(n)->ln_Pred->ln_Succ = (n)->ln_Succ )

#define GETHEAD(l)	( (l)->lh_Head->ln_Succ ? (l)->lh_Head : (struct Node *)NULL )

#define GETTAIL(l)  ( (l)->lh_TailPred->ln_Succ ? (l)->lh_TailPred : (struct Node *)NULL )

#define GETSUCC(n)  ( (n)->ln_Succ->ln_Succ ? (n)->ln_Succ : (struct Node *)NULL )

#define GETPRED(n)  ( (n)->ln_Pred->ln_Pred ? (n)->ln_Pred : (struct Node *)NULL )


#ifdef __GNUC__

#define REMHEAD(l)															\
({																			\
	struct Node *n = (l)->lh_Head;											\
	n->ln_Succ ?															\
		(l)->lh_Head = n->ln_Succ,											\
			(l)->lh_Head->ln_Pred = (struct Node *)(l),						\
			n :																\
		NULL;																\
})

#define REMTAIL(l)															\
({																			\
	struct Node *n = (l)->lh_TailPred;										\
	n->ln_Pred ?															\
		(l)->lh_TailPred = n->ln_Pred,										\
			(l)->lh_TailPred->ln_Succ = (struct Node *)(&((l)->lh_Tail)),	\
			n :																\
		NULL;																\
})


#else

/* These two can't be implemented as macros without the GCC ({...}) language extension */

INLINE struct Node *REMHEAD(struct List *l)
{
	struct Node *n = l->lh_Head;

	if (n->ln_Succ)
	{
		l->lh_Head = n->ln_Succ;
		l->lh_Head->ln_Pred = (struct Node *)l;
		return n;
	}
	return NULL;
}

INLINE struct Node *REMTAIL(struct List *l)
{
	struct Node *n = l->lh_TailPred;

	if (n->ln_Pred)
	{
		l->lh_TailPred = n->ln_Pred;
		l->lh_TailPred->ln_Succ = (struct Node *)(&(l->lh_Tail));
		return n;
	}
	return NULL;
}

#endif

#endif /* !LISTMACROS_H */
