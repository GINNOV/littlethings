#include <stdio.h>

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"
#include "globals.h"

#include "cse.h"



int vmwInstructionsAreEqual(Node x, Node y) 
{
   
   
   
      if ( (x->op==y->op) &&
	           ( ( (x->x==y->x) && (x->y==y->y) ) ||
		               ( (x->x==y->y) && (x->y==y->x) ) ) ) return 1;
      else return 0;
   
}



Node vmwWhatAreWeLoading(Node x) {
   
    Node temp_node,temp_node2;
   	     
    if (x==NULL) return NULL;
   
    if (x->mode==CSGInstr) {
       if ( (x->op==vmwAdd) || (x->op==vmwAdda) ) {

	  
	  
	  temp_node=x->x;
	  temp_node2=x->y;
	  
	  if (temp_node!=NULL) {
	     if (temp_node->mode==CSGPtr) return temp_node;
	     
	     if (temp_node->x==NULL) return NULL;
	     else if (temp_node->x->mode==CSGPtr) return temp_node->x;
	     
	     if (temp_node->y==NULL) return NULL;
	     else if (temp_node->y->mode==CSGPtr) return temp_node->y;
	  }
	  
	  if (temp_node2!=NULL) {
	     if (temp_node2->mode==CSGPtr) return temp_node2;
	     
	     if (temp_node2->x==NULL) return NULL;
	     else if (temp_node2->x->mode==CSGPtr) return temp_node2->x;
	     
	     if (temp_node2->y==NULL) return NULL;
	     else if (temp_node2->y->mode==CSGPtr) return temp_node2->y;
	  }
       }
    }
    return NULL;
}




     /* anchor has a linked list of all instructions of same type in a function */
     /* We start at top and add to anchor if common expression not found        */
     /* If found we replace ourselves with the old value                        */
static void vmwActuallyEliminateCSE(struct anchor_type anchor, Block root) {
   
    Node temp_node,old_op,check_op;
    Block temp_block;
   
    int cse,temp_op,stop_looking;
   
    temp_block=root;
	 
    temp_node=temp_block->first;
   
       /* Search for CSE's in current block */
    while(temp_node!=NULL) {
	
       cse=0;
	    
       temp_op=temp_node->op;
       
          /* See if this instr is a CSE */
       if ( (temp_node->op==vmwNeg) ||
            (temp_node->op==vmwAdd) ||
            (temp_node->op==vmwSub) ||
            (temp_node->op==vmwMul) ||
            (temp_node->op==vmwDiv) ||
            (temp_node->op==vmwMod) ||
	    (temp_node->op==vmwLshift) ||
	    (temp_node->op==vmwRshift) ||
	    (temp_node->op==vmwAnd) ||
	    (temp_node->op==vmwOr) ||
	    (temp_node->op==vmwXor) ||
            (temp_node->op==vmwAdda) ) {

	  

          check_op=anchor.anchor[temp_node->op];
	    
          while(check_op!=NULL) {
	    
             if (temp_node->op!=vmwPhi) {

		 
	           /* It is!  Handle it */
	        if (vmwInstructionsAreEqual(temp_node,check_op)) {
	           cse=1;
	           temp_node->deleted=1;
		   			     
		   vmwReplaceNode(check_op,temp_node);    
		}
		
	     }
	     
	     check_op=check_op->op_list;
          }
       }
       /* Handle load/store/bsr case */
       else if ( (temp_node->op==vmwLoad) ||
                 (temp_node->op==vmwStore) ||
		 (temp_node->op==vmwBsr)) {	 
	  

	  temp_op=vmwLoad;
	  
	  check_op=anchor.anchor[vmwLoad];

	  stop_looking=0;
	  
	  while ((check_op!=NULL) && (!stop_looking)) {
	    

	      if ( check_op->op==vmwBsr) stop_looking=1;
	     
	      if ( (check_op->op==vmwStore) && (temp_node->op==vmwLoad) ) {
	
		 if ( (vmwWhatAreWeLoading(check_op->y))==
		      (vmwWhatAreWeLoading(temp_node->x)) ) {
		      //printf("COLLISION\n");
		      stop_looking=1;
		 }
		 
	      }
		  
		
	        /* It is!  Handle it */
	     if ( (!stop_looking) && (vmwInstructionsAreEqual(temp_node,check_op))) {
	        cse=1;
	        temp_node->deleted=1;
		  		  
		vmwReplaceNode(check_op,temp_node);    
	     }
	     
	     check_op=check_op->op_list;
	  }
/*	  
	  if (temp_node->op==vmwLoad) {  
             foolish_node=vmwWhatAreWeLoading(temp_node->x);
	     if (foolish_node!=NULL) printf("Loading %s\n",foolish_node->name);
	  }
	  if (temp_node->op==vmwStore) {  
             foolish_node=vmwWhatAreWeLoading(temp_node->y);
	     if (foolish_node!=NULL) printf("Saving %s\n",foolish_node->name);
	  }
*/	  
	  
       }
       
	  /* If it wasn't a CSE, add to the list */
       if (!cse) {
	  old_op=anchor.anchor[temp_op];
	  anchor.anchor[temp_op]=temp_node;
	  temp_node->op_list=old_op;
       }
	      	 
       temp_node=temp_node->next;
    }
   
    temp_block=temp_block->dsc;
   
       /* Recurse down the dominator tree */
    while(temp_block!=NULL) {
       vmwActuallyEliminateCSE(anchor,temp_block);
       temp_block=temp_block->next;
    }
   
   
}

void vmwEliminateCommonSubexpressions(struct anchor_type anchor,Block root) {
       
    Block temp_block;

    int i;

    printf("OPTIMIZING: Removing Common Subexpressions...\n");
   
   
    temp_block=root;
   
    while (temp_block!=NULL) {

       	   
          /* Run CSE on one proc at a time */
       if (temp_block->kind==blockProc) {	    
	  
	     /* Clear out the anchor tree */
	  for(i=0;i<vmwHCF;i++) {
             anchor.anchor[i]=NULL;
          }
       }
       	 
       vmwActuallyEliminateCSE(anchor, temp_block);
       
       temp_block=temp_block->link;    
    }
}




void vmwRemoveFakeStores() {

   Block temp_block;
   Node temp_node;
   
   temp_block=root_block;
   while(temp_block!=NULL) {
      temp_node=temp_block->first;
      while(temp_node!=NULL) {
	 
	 if ((temp_node->op==vmwStore) && (temp_node->x==NULL)) {

	       /* Delete the instruction */
	    if ((temp_node->prev==NULL) && (temp_node->next==NULL)) {
//	       vmwDumpNode(temp_node);
	       temp_block->first=NULL;
	       temp_block->last=NULL;
	    }
	    else
	    

	    if (temp_node->prev==NULL) {
//	       vmwDumpNode(temp_node);
	       temp_block->first=temp_node->next;
	       temp_node->next->prev=NULL;
	       
	    }
	    else 
	    if (temp_node->next==NULL) {
//	       vmwDumpNode(temp_node);
	       temp_node->prev->next=NULL;
	       temp_block->last=temp_node->prev;
	    }
	    	 
	    else {
//	       vmwDumpNode(temp_node);
	       temp_node->prev->next=temp_node->next;   
	       temp_node->next->prev=temp_node->prev;
	    }
	    
	    
	 }
	 
	      
	 
         temp_node=temp_node->next;
      }
      	   
      temp_block=temp_block->link;
   }
   
	
   
}


