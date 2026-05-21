/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    avl.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Nov-95
    Modified: 12-Nov-95
    _______________________________________________________________________

    Original code for balance() and avlinsert() is
    Copyright 1988 Zinn Computer Company by Mark E. Mallett
    All rights reserved;

    This software may be used at will, provided that all credits and style
    be left in place, and that its distribution is not restricted. Bug fixes
    and improvements are welcomed, please send these back to me at
    mem@zinn.MV.COM

    This is a general-purpose implementation of AVL trees in C. It is derived
    from the description of AVL (Adelson-Velskii and Landis) trees found in
    Knuth's "The Art of Computer Programming Volume 3: Searching and Sorting"
    (Addison-Wesley, 1973) pgs 451-471.
    _______________________________________________________________________
*/

#include "headers.h"

/*************************************************************************/

typedef struct AVLNode AVLNODE ;
typedef struct AVLTree AVLTREE ;

struct AVLNode
{
  AVLNODE	*n_leftP;		/* Ptr to left subtree */
  AVLNODE	*n_rightP;		/* Ptr to right subtree */
  LONG		 n_balance;		/* Balance count */
  VOID		*n_data;		/* Data for this node */
} ;

struct AVLTree
{
  /* Tree parameters */
  AVLNODE	*t_rootP;		/* Ptr to root node */
  AVLNODE	*t_array;		/* Storage for all the nodes */
  LONG		 t_ncount;		/* Current number of nodes in the tree */
  LONG		 t_nmax;		/* Maximal number of nodes in the tree */

  /* Handler functions for the tree */
  LONG		 (*t_cmprtc)(VOID *,AVLNODE *);                 /* Compare two keys */
  AVLNODE	*(*t_mknode)(AVLTREE *,VOID *,AVLNODE *);       /* Node maker */
} ;

/*************************************************************************/

static LONG balance( AVLNODE **branchPP )

/*
	Local routine to balance a branch

	Accepts :

	branchPP	Addr of the variable pointing to the top n

	Returns :

	<value> 	0 if branch has stayed the same height;
			1 if branch shrunk by one.

	Notes :

	This routine accepts a branch in conditions left by the
	internal routines only.  No other cases are dealt with.
*/

{
	LONG		shrunk; 	/* Whether we shrunk */
	AVLNODE 	*nodeP; 	/* Current top node */
	AVLNODE 	*leftP; 	/* Left child */
	AVLNODE 	*rightP;	/* Right child */
	AVLNODE 	*migP;		/* A ndoe that migrates */

    /* Pick up relevant information */
    nodeP = *branchPP;
    leftP = nodeP->n_leftP;
    rightP = nodeP->n_rightP;
    shrunk = 0; 			/* Assume tree doesn't shrink */

    /* Process according to out-of-balance amount, if any */
    switch( nodeP->n_balance ) {
	case -2:			/* Too heavy on left */
	    if ( leftP->n_balance <= 0 ) {

		/* Single rotation */
		*branchPP = leftP;
		nodeP->n_leftP = leftP->n_rightP;
		leftP->n_rightP = nodeP;
		++leftP->n_balance;
		nodeP->n_balance = -(leftP->n_balance);
		if ( leftP->n_balance == 0 )
		    shrunk = 1;
	    }
	    else {			/* Migration of inner node to top */
		migP = leftP->n_rightP;
		leftP->n_rightP = migP->n_leftP;
		nodeP->n_leftP = migP->n_rightP;
		migP->n_leftP = leftP;
		migP->n_rightP = nodeP;
		*branchPP = migP;
		if ( migP->n_balance < 0 ) {
		    leftP->n_balance = 0;
		    nodeP->n_balance = 1;
		}
		else if ( migP->n_balance > 0 ) {
		    leftP->n_balance = -1;
		    nodeP->n_balance = 0;
		}
		else
		    leftP->n_balance = nodeP->n_balance = 0;
		migP->n_balance = 0;
		shrunk = 1;
	    }
	    break;

	case  2:			/* Too heavy on right */
	    if ( rightP->n_balance >= 0 ) {

		/* Single rotation */
		*branchPP = rightP;
		nodeP->n_rightP = rightP->n_leftP;
		rightP->n_leftP = nodeP;
		--rightP->n_balance;
		nodeP->n_balance = -(rightP->n_balance);
		if ( rightP->n_balance == 0 )
		    shrunk = 1;
	    }
	    else {			/* Migration of inner node */
		migP = rightP->n_leftP;
		rightP->n_leftP = migP->n_rightP;
		nodeP->n_rightP = migP->n_leftP;
		migP->n_leftP = nodeP;
		migP->n_rightP = rightP;
		*branchPP = migP;
		if ( migP->n_balance < 0 ) {
		    nodeP->n_balance = 0;
		    rightP->n_balance = 1;
		}
		else if ( migP->n_balance > 0 ) {
		    nodeP->n_balance = -1;
		    rightP->n_balance = 0;
		}
		else
		    nodeP->n_balance = rightP->n_balance = 0;
		migP->n_balance = 0;
		shrunk = 1;
	    }
    }
    return( shrunk );
}

/*************************************************************************/

BOOL AddAVLNode( AVLTREE *treeP, VOID *keyP )

/* $DOC
 * FUNCTION
 *	Insert a node in an avl tree
 * INPUTS
 *	treeP = The address of the tree header structure.
 *	keyP  = The address of the key for the node.  Interpretation
 *		of the key is by the compare and node-create
 *		routines specified in the avl tree header.
 * OUTPUTS
 *	result = success/failure
 * NOTES
 * The tree header structure specifies a node construction routine
 * that is responsible for allocating a node and putting the new
 * key and data information into it.  It is called as follows:
 *	nodeP = construct( treeP, keyP, enodeP )
 * treeP, keyP, are as passed to this routine.	"enodeP"
 * is NULL if a new node is required; otherwise it is the address
 * of an already existing node that matches the specified key -
 * in this case it is up to the constructor to decide whether to
 * overwrite the existing node or to call it an error.	The routine
 * is expected to return the address of the AVLNODE structure
 * that is allocated (if enode==NULL ) or that exists, or to
 * return NULL if the node is not made (or used).
 * $END
 */

{
	LONG		direction;	/* Direction we took from decision pt */
	AVLNODE 	*nodeP; 	/* Node that we're looking at */
	AVLNODE 	*clearP;	/* For erasing tracks */
	AVLNODE 	**nodePP;	/* Pointer to the next link */
	AVLNODE 	**topPP;	/* Pointer to the top pointer */

    /* Traverse the tree to find an insertion point (or existing key).
       Along the way, we'll adjust the balance counts on the nodes as
       we pass by them.  And as we do this, we'll remember the potential
       tree rotation point (the lowest non-balanced treetop) as well as
       the direction we took from it (in case we have to fix it up when
       we discover a lower balance point). */

    nodePP = topPP = &(treeP->t_rootP); /* Start at top of tree */
    direction = 0;			/* Haven't gone anywhwere yet */
    while( (nodeP = *nodePP) != NULL ) { /* Till we reach the end */

	/* See if we're at a potential balance point */
	if ( nodeP->n_balance != 0 ) {

	    /* New balance point.  Erase any trail we've made to here */
	    if ( direction != 0 )
		for( clearP = *topPP; clearP != nodeP;
				 direction = clearP->n_balance ) {
		    clearP->n_balance -= direction;
		    if ( direction < 0 )
			clearP = clearP->n_leftP;
		    else
			clearP = clearP->n_rightP;
		}
	     direction = 0;		/* So we make new balance point */
	     topPP = nodePP;		/* Remember new top */
	}

	/* Now follow the tree... */
	switch( (*treeP->t_cmprtc)( keyP, nodeP ) ) {
	    case 0:			/* Match */
		/* Here we have a duplicate node.  First erase the
		   trail that we left. */
		if ( direction != 0 )
		    for( clearP = *topPP; clearP != NULL;
			    direction = clearP->n_balance ) {
			clearP->n_balance -= direction;
			if ( direction < 0 )
			    clearP = clearP->n_leftP;
			else
			    clearP = clearP->n_rightP;
		    }

		/* Give the node to the node constructor and
		   see what we get. */
		if ( (*treeP->t_mknode)( treeP, keyP, nodeP ) == NULL )
		    return( FALSE );    /* Duplicate key */
		return( TRUE );         /* Return success */

	    case -1:			/* Go left */
		nodePP = &(nodeP->n_leftP);
		--nodeP->n_balance;
		if ( direction == 0 )   /* Remember balance point branch? */
		    direction = -1;
		break;

	    case 1:			/* Go right */
		nodePP = &(nodeP->n_rightP);
		++nodeP->n_balance;
		if ( direction == 0 )
		    direction = 1;
		break;
	}
    }

    /* Here we've gotten to the bottom, so make a new node */
    nodeP = (*treeP->t_mknode)( treeP, keyP, (AVLNODE *)NULL );
    if ( nodeP != NULL ) {              /* Successful node creation? */
	nodeP->n_balance = 0;		/* Fill in the nitty gritty */
	nodeP->n_leftP = nodeP->n_rightP = NULL;
	*nodePP = nodeP;		/* Link it in */
	balance( topPP );               /* May need reshaping now */
	return( TRUE );                 /* Return success */
    }

    /* Error making node.  Erase our trail */
    if ( direction != 0 )
	for( clearP = *topPP; clearP != NULL;
			direction = clearP->n_balance ) {
	    clearP->n_balance -= direction;
	    if ( direction < 0 )
		clearP = clearP->n_leftP;
	    else
		clearP = clearP->n_rightP;
	}
    return( FALSE );                       /* Return error */
}

/*************************************************************************/

static LONG AVLCompareKeys( VOID *pKey , AVLNODE *pNode )
{
  LONG res ;
  struct Object *pe, *pn ;

  pe = (struct Object *)pNode->n_data ;
  pn = (struct Object *)pKey ;

  if ( ObjIsDir( pe ) )
    res = ObjIsDir( pn ) ? stricmp( pn->obj_Name , pe->obj_Name ) : 1 ;
  else
    res = ObjIsDir( pn ) ? -1 : stricmp( pn->obj_Name , pe->obj_Name ) ;

  if ( res < 0 ) res = -1 ;
  else if ( res > 0 ) res = 1 ;
  return( res ) ;
}

/*************************************************************************/

static AVLNODE *AVLAllocNode( AVLTREE *pTree , VOID *pKey , AVLNODE *pNode )
{
 if ( (! pNode) && (pTree->t_ncount < pTree->t_nmax) )
 {
   pNode = &(pTree->t_array[pTree->t_ncount]) ;
   pNode->n_data = pKey ;
   pTree->t_ncount++ ;
 }
 else pNode = NULL ;

 return( pNode ) ;
}

/*************************************************************************/

VOID *CreateAVLTree( LONG ncount )

/* $DOC
 * FUNCTION
 *	Creates a new AVL tree header
 * INPUTS
 *	ncount = maximal number of nodes
 * OUTPUTS
 *	result = pointer to the new header, or NULL if failed
 * $END
 */

{
  AVLTREE *pTree ;

  if ( pTree = MyAllocMem( sizeof(AVLTREE) , NULL ) )
  {
    if ( pTree->t_array = MyAllocMem( ncount * sizeof(AVLNODE) , NULL ) )
    {
      pTree->t_cmprtc = AVLCompareKeys ;
      pTree->t_mknode = AVLAllocNode ;
      pTree->t_nmax   = ncount ;
    }
    else
    {
      MyFreeMem( pTree ) ;
      pTree = NULL ;
    }
  }

  return( (VOID *)pTree ) ;
}

/*************************************************************************/

static VOID __stackext DoAVLToList( struct Object *pRoot , AVLNODE *pNode )

/* If pRoot is NULL, the tree is deleted */

{
  if ( pNode )
  {
    DoAVLToList( pRoot , pNode->n_leftP ) ;
    if ( pRoot ) AddChild( pRoot , (struct Object *)pNode->n_data ) ;
	    else FreeObject( pNode->n_data ) ;
    DoAVLToList( pRoot , pNode->n_rightP ) ;
  }
}

/*************************************************************************/

VOID AVLToList( AVLTREE *pTree , struct Object *pRoot )

/* $DOC
 * FUNCTION
 *	Converts an AVL tree to a standard Exec list
 * INPUTS
 *	pTree = pointer to the tree header
 *	pRoot = pointer to the directory to add Object to
 * NOTES
 *	The tree is automatically DELETED, so pTree MUST NOT BE USED AFTER
 *	CALLING THIS FUNCTION.
 * $END
 */

{
  NoChildren( pRoot ) ;
  DoAVLToList( pRoot , pTree->t_rootP ) ;
  MyFreeMem( pTree->t_array ) ;
  MyFreeMem( pTree ) ;
}

