#include <stdio.h>
#include <stdlib.h> /* malloc  */
#include <string.h> /* strncpy */

#include "scanner.h"
#include "node.h"
#include "type.h"
#include "block.h"

#include "globals.h"
#include "enums.h"


    /* Add Node to Linked List */
Node AddToList(Node *root, char *id) {
  
    register Node curr;
   
    curr = NULL;

       /* If we are at root, create the root */
    if (*root == NULL) {
       
       curr = calloc(1,sizeof(NodeDesc));
       *root = curr;
    
       if (curr == NULL) {
	  vmwError("Out of memory!");
       }
       curr->next=NULL;

    } else {
       
       curr = *root;
    
          /* Find end of list or else duplicate identifier */
          /* Also only duplicate if in same scope          */
       
       if (id==NULL) {
	  while ((curr->lev!=current_level) && (curr->next!=NULL)) {
	     curr=curr->next;
	  }
	  
       }
       else {
	    
          while ( ((curr->lev != current_level) || 
		((strncmp(curr->name, id, vmwIdlen) != 0))) 
	     && (curr->next != NULL)) {
	  
	  
	     curr = curr->next;
	    
          }
       }
       
       

       
       if (id!=NULL) { 
	    
          if ( (strncmp(curr->name, id, vmwIdlen) == 0) &&
	       (curr->lev == current_level)) {
             vmwError("Duplicate identifier");
          }
       }
       
    
   

	  
       /* We're a proper addition.  Set it up */
    if (curr->next!=NULL) {
//	     printf("NOT EMPTY!\n");
       while(curr->next!=NULL) {
          curr=curr->next;
       }	     
    }
       
    curr->next = calloc(1,sizeof(NodeDesc));
       
 //         printf("Old %p -> New %p\n",curr,curr->next);
          
    curr=curr->next;
    if (curr==NULL) {
       vmwError("Out of memory");
    }
       
    }
   
//    printf("Var : Adding %s parent=%p %i",id,curr,current_level);
//	  if (curr->name!=NULL) printf("%s",curr->name);
//    printf("\n");
   
    
   
    curr->mode = -1;
    curr->lev = current_level;
    curr->next = NULL;
    curr->dsc = NULL;
    curr->master=curr;
    curr->type = NULL;
    if (id!=NULL) {
       strncpy(curr->name, id, vmwIdlen);
       curr->name[vmwIdlen-1]=0;
    }
   
    curr->val = 0;
    curr->op=-1;
    curr->x=NULL;
    curr->y=NULL;
    curr->xtype=CSGVar;
    curr->ytype=CSGVar;
    curr->block=NULL;
    curr->xLastUse=NULL;
    curr->yLastUse=NULL;
    curr->use=NULL;
    curr->current=curr;
    curr->line_number=0;
    curr->var_list=NULL;
    curr->deleted=0;
    curr->op_list=NULL;
    curr->reg=-1;
    curr->ind=-1;
    curr->used=0;
    curr->parameter=0;
    return curr;
}


    /* InsertNode */
    /* Inserts a Node into linked list */

Node InsertNode( Node *root, const int class, const Type type, 
		 char *name, const int val) {
   
   
   
    char temp_name[vmwIdlen];
    Node temp_node;
   
    strncpy(temp_name,name,vmwIdlen);
    temp_name[vmwIdlen-1]=0;
   
    temp_node=AddToList(root,temp_name);
         
       /* Set the values for our new node */
    temp_node->mode = class;
    temp_node->type = type;
    temp_node->val = val;
   
    return temp_node;
}


    /* Try to find an object */
Node FindNode(const Node  *root, char *id) {
  
    int maxlev;
    register Node curr;
    register Node  obj;

    maxlev = -1;
    curr = *root;
    obj = NULL;

//    printf("Trying to find %s Scope %i\n",id,current_level);
   
    while (curr != NULL) {
    
       while (curr != NULL) { 
	  
	     /* Found a match */
          if (!strncmp(curr->name, id, vmwIdlen) ) {
//	     printf("Found at scope %i %s %s ",curr->lev,curr->name,id);
	     
	        /* Only a match if scope is lower than previous */
	     if (curr->lev == current_level) {
		obj=curr;
		maxlev=curr->lev;
	     }
	     else if ((maxlev<=0) && (curr->lev==0)) {
	        obj=curr;
		maxlev=curr->lev;
	     }
//	     printf("but using Scope %i\n",maxlev);
		  
	     
	     
	  }
	  
             /* Move to next node and continue */
	  curr = curr->next;
       }
       
       
    }

   
       /* Look for scoping problems */
    if (obj != NULL) {
    
       if ( ( (obj->mode == CSGVar) || (obj->mode == CSGFld) ) && 
	    ( (obj->lev != 0) && (obj->lev != current_level)) 
	  ) {
          vmwError("object cannot be accessed");
       }    
    }
   
    return obj;
}




    /* How is this easier than setting the fields ourself? */
void InitObj(const Node obj, 
		    const long class, 
		    const Node dsc, 
		    const Type type, 
		    const long val) {
  

    obj->mode = class;
    obj->next = NULL;
    obj->dsc = dsc;
    obj->type = type;
    obj->val = val;

}


void vmwReplaceNode(Node replacement_node, Node deleted_node) {
   
    Node temp_node,phi_node;
    Block temp_block;

   
       /* Loop through all blocks */
    temp_block=root_block;
    while(temp_block!=NULL) {
          /* Loop through all instrs */
       temp_node=temp_block->first;
       while(temp_node!=NULL) {

	  
             /* See if argument matches deleted */
          if ( (!temp_node->deleted) &&
	       (temp_node!=deleted_node) ) {
		    

	     
	         /* Handle PHI functions */
	     if (temp_node->op==vmwPhi) {
		phi_node=temp_node->y;
			
	        while(phi_node!=NULL) {
		   if (phi_node->x==deleted_node) {
		      phi_node->x=replacement_node;
		      phi_node->xtype=replacement_node->mode;
		   }
		   phi_node=phi_node->next;
		}
	     }
	     else {	     

	        if (temp_node->x==deleted_node) {
		   temp_node->x=replacement_node;
		   temp_node->xtype=replacement_node->mode;
	        }
	        if (temp_node->y==deleted_node) {
		   temp_node->y=replacement_node;
		   temp_node->ytype=replacement_node->mode;
		}
		
	       

	     }
	  }
          temp_node=temp_node->next;
       }
       temp_block=temp_block->link;
    }
   
}
