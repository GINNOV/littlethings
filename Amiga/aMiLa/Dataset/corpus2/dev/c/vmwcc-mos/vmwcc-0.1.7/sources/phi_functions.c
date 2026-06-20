#include <stdio.h>
#include <stdlib.h> /* calloc() */
#include <string.h> /* strncmp() */

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"
#include "globals.h"

#include "ir_generator.h"

#include "debug.h"

Block current_phi_block=NULL;
int current_path=0;


/* PHI FUNCTION
 * 
 *  * ->op is vmwPhi
 *  * ->x points to "original" value
 *  * ->y points to head of linked list of Nodes
 *  *
 *  *
 *  */



    /* Original value is the value of the variable coming into the phi */
    /*          which is used to fill in empty slots (ie if w/o else)  */
Node MakePhi(Node *parent,Node *original_value,Node *new_value,int path) {

   Node temp_node=NULL,phi_pointer=NULL,old_node=NULL;
   int pre_existing=0,i;

   
//   printf("*** Making phi for %s original %s path %i in block %i == %s\n",
//	  (*parent)->name,(*original_value)->master->name,path,current_phi_block->num,
//	  (*new_value)->master->name);

   if ((*original_value)->master==NULL) vmwError("IO\n");
   
       /* Point to the linked list of phi values at head of current phi block */
    temp_node=current_phi_block->phi_functions;

      /* if no block->phi_functions, create it */
   if (temp_node==NULL) {
      current_phi_block->phi_functions=calloc(1,sizeof(NodeDesc));
      temp_node=current_phi_block->phi_functions;
      temp_node->next=NULL;
   }
   else {
      old_node=temp_node;
          /* see if phi function with varname already exists */
      while ((temp_node!=NULL) && (strncmp( (*parent)->name,temp_node->name,vmwIdlen))) {
	 old_node=temp_node;
	 temp_node=temp_node->next;
      }
      
      if (temp_node==NULL) {
	 old_node->next=calloc(1,sizeof(NodeDesc));
	 temp_node=old_node->next;
      } else {
	 pre_existing=1;
      }

   }
   
       /* If it doesn't already exist, initialize it */
    if (!pre_existing) {
      
          /* Copy over the name */
       strncpy(temp_node->name,(*parent)->name,vmwIdlen);
       temp_node->name[vmwIdlen-1]=0;
          /* Make it a phi function */
       temp_node->op=vmwPhi;

       if ((*original_value)->mode==CSGInstr) vmwError("WHAT?\n");
       
          /* Save original value, we may need it later */
       temp_node->x=(*original_value);
            
          /* setup linked list which will be the (X,Y,Z) of a2=phi(X,Y,Z) */
       temp_node->y=calloc(1,sizeof(NodeDesc));
       temp_node->y->next=NULL;
      
          /* Add the original value as one of the phi choices */
       phi_pointer=temp_node->y;
       phi_pointer->x=(*original_value);

	   
          /* Make sure we set the phi to the path we currently are on */
       for(i=0;i<path;i++) {
	  if (phi_pointer->next==NULL) {
	     phi_pointer->next=calloc(1,sizeof(NodeDesc));
	     phi_pointer->next->next=NULL;
             phi_pointer->next->x=temp_node->x;
//	     printf("Phi(%i)=%i\n",i,temp_node->x->current->line_number);
	  }
	  phi_pointer=phi_pointer->next;
       }
      
       phi_pointer->x=(*new_value);

//       printf("Making phi(%i) to %s %p\n",current_path,(*parent)->name,phi_pointer);            
      
      temp_node->next=NULL;

   }
      /* Pre-existing.  Add it */
    else {
       phi_pointer=temp_node->y;
	   
       for(i=0;i<path;i++) {
	  if (phi_pointer->next==NULL) {
	     phi_pointer->next=calloc(1,sizeof(NodeDesc));
	     phi_pointer->next->next=NULL;
	  }
	  phi_pointer=phi_pointer->next;	 
       }
      
       phi_pointer->x=(*new_value);

//       printf("Making phi(%i) to %s %p\n",current_path,(*parent)->name,phi_pointer);            
       
   }

   return temp_node;
   
}


void CloseOutPhis(Block block, Block parent,int parent_path) {
   
    Node temp_phi=NULL,temp_instr,var,yan,yayan;
    Block temp_block=NULL,dominate_block=NULL;
    int i,dominated;

//    printf("BEGIN CLOSE OUT PHIS\n"); fflush(stdout);

       /* Point to the linked list of phi functions */
       /* In our current join block                 */
    temp_phi=block->phi_functions;
       
       /* Cycle through _all_ the phi functions */
    while(temp_phi!=NULL) {
      
          /* Add phi pseudo-instruction */
       temp_phi->y->mode=CSGPhi;
       
//       printf("EEE\n");
      // vmwDumpNode(temp_phi->x);
       
          /* Make sure we have as many phis as we do paths */
       yan=temp_phi->y;
       for(i=0;i<1/*current_path*/;i++) {
	  if (yan->next==NULL) {
	     yan->next=calloc(1,sizeof(NodeDesc));
	     yan->next->next=NULL;
             yan->next->x=temp_phi->x;
	  }
	  yan=yan->next;
       }
       
          /* Add phi function */
       temp_instr=add_instruction(block,Before,vmwPhi,temp_phi->x,temp_phi->y,0);

//       printf("GEEKY\n"); fflush(stdout);
       
          /* Handle if we are phi'ing a phi function! */
       if (temp_instr->x->master==NULL) {
          var=temp_instr->x->x->master;
       }
       
       else {
	    
       
//	  printf("$$$\n"); fflush(stdout);
//          printf("$$ adding phi for %s in block %i\n",
//	      temp_instr->x->master->name,block->num);
//          fflush(stdout);
          var=temp_instr->x->master;
       }
       
       
             /* Point var->current to the phi function */

          var->current=AddToList ( & (var->var_list),NULL);
          var->current->current=temp_instr;

//       printf("ZZZ***********ADDING %s at %p\n",var->name,var->current);
       	    {
	       Node blug_node;
	       int i=0;
	       blug_node=var->var_list;
	       while (blug_node!=NULL) 
		 {
//		   printf("%s #%i\n",var->master->name,i);
	           blug_node=blug_node->next;	 
		    i++;
	 	 }
	    }
       var->current->master=var;
       
       

       
          /* Also make phi->x equal ourselves       */
       temp_instr->x=var->current;

       
       temp_instr->xtype=CSGPhi;
       temp_instr->ytype=CSGPhi;
       temp_instr->x->mode=CSGVar;
       

          /* Propogate to outer phi-block */
       if (current_depth>1) {
	  int blah;
	  
          temp_block=current_phi_block;
          current_phi_block=parent;

//	  printf("Propogating out current=%i parent=%i!\n",current_path,parent_path);
          	       
	  blah=current_path;
	  current_path=parent_path;
//	  printf("Current path now %i\n",current_path);
	  
	  MakePhi(&(temp_instr->x->master),&(temp_phi->x),&(var->current),parent_path);
	  current_path=blah;
	  
          current_phi_block=temp_block;
       }

       
          /* In a while statement, recurse and point all that pointed */
          /* to old value now point to phi function */

       if (block->kind==blockWhileHead) {

	     /* change all rest in head block */

//	  printf("GOOGOO for var %s!!!\n",var->current->master->name);
//	  temp_instr=block->first;
	  while ( (temp_instr!=NULL) /*&& (temp_instr->next!=NULL)*/) {
	     	     
//	     vmwDumpNode(temp_instr->x);
//	     printf("equals %p %p %p?",temp_instr->x,temp_phi->x,temp_phi->y);
//	     vmwDumpNode(temp_phi->x);
	     if ((temp_instr->x!=NULL) && (temp_instr->x==temp_phi->x)) {
		temp_instr->x=var->current;
	     }
	     if ((temp_instr->y!=NULL) && (temp_instr->y==temp_phi->x)) {
		temp_instr->y=var->current;
	     }
		  
	     temp_instr=temp_instr->next;
		  
	  }
	  /* change all in dominated blocks */
	  
          temp_block=root_block;
          while(temp_block->link!=NULL) {

	     dominated=0;
	     dominate_block=temp_block;
	       
	     while(dominate_block->rdom!=NULL) {
		if (dominate_block->rdom==block) {
		   dominated=1;		          
//		   printf("DOMINATED!\n");
		}
		dominate_block=dominate_block->rdom;
	     }
	     
	     
		    
	     if (dominated) {
//	       	printf("CHECKING!\n");
	        temp_instr=temp_block->first;

	        while( (temp_instr!=NULL) ) 
		  {
		     
		   	     
		   if ((temp_instr->op==vmwPhi)) {
		      yayan=temp_instr->y;
		      while(yayan!=NULL) {
		         if (yayan->x==temp_phi->x) {
		            yayan->x=var->current;     
		            
		         }
			 yayan=yayan->next;
		      }
		   }
		   
		   
		   if ((temp_instr->x!=NULL) && (temp_instr->x==temp_phi->x)) {
		      temp_instr->x=var->current;
		   }
		   if ((temp_instr->y!=NULL) && (temp_instr->y==temp_phi->x)) {
		//      printf("ZIG %s\n",var->current->name);
		      temp_instr->y=var->current;
		   }
		  
		   temp_instr=temp_instr->next;
		  
		}
		
	     }
             temp_block=temp_block->link;
	  }
       }
       

       
       
	    
       
       
       temp_phi=temp_phi->next;
   }


}




   
   
   


static void vmwRemovePhisIf(Block joinBlock, Block thenBlock, Block elseBlock) {
   
   

   Node temp_node;
   
   temp_node=joinBlock->first;
   while(temp_node!=NULL) {
      
      if (temp_node->op==vmwPhi) {

//	 printf("NODE NODE\n");
//	 vmwDumpNode(temp_node->y->x);

	 if (thenBlock==NULL) vmwError("THEN block NULL");
	 if (elseBlock==NULL) vmwError("ELSE block NULL");
	 
	 add_instruction(thenBlock,BeforeLastBranch,vmwMove,
			 temp_node->y->next->x,temp_node->x,1);
	 add_instruction(elseBlock,BeforeLastBranch,vmwMove,
			 temp_node->y->x,temp_node->x,1);
//	 printf("MOVE %s^%i\n",temp_node->y->x->master->name,
//		temp_node->y->x->current->line_number);
//		
         
	 temp_node->deleted=1;
	 
      }
      
	  
      
      temp_node=temp_node->next;
   }
   
}



   
void vmwRemoveFreakingPhiFunctions(Block root) {
   

   Block temp_block,iterate_block;
   Node temp_node;
   Block joinBlock=NULL,thenBlock=NULL,elseBlock=NULL;
   Block parentBlock=NULL,headBlock=NULL,bodyBlock=NULL;
   int found;
   
   temp_block=root;
   
   while(temp_block!=NULL) {
      temp_node=temp_block->first;
      found=0;
      while((temp_node!=NULL) && (!found)) {

//	  printf("NF %i %p\n",temp_block->num,temp_node);
	  if (temp_node->op==vmwPhi) {

//	     printf("ARGH %i\n",temp_block->num);
	     if (temp_block->kind==blockIfJoin) {

		joinBlock=temp_block;
		elseBlock=temp_block->rdom;

		   /* Find "else" case */
		iterate_block=temp_block->rdom->fail;
//		printf("Looking for ELSE starting from %i ending at %i\n",
//		       iterate_block->num,temp_block->num);
		if (iterate_block!=temp_block) { 
		   
		   while(iterate_block->branch!=temp_block) {
		      if ((iterate_block->branch==NULL) &&
			 (iterate_block->fail!=NULL))
			 iterate_block=iterate_block->fail;
		      else iterate_block=iterate_block->branch;
		      if (iterate_block==NULL) break;
		   }
		}

	       if (iterate_block==NULL) {
		 elseBlock=temp_block->rdom;
	       } else {
                  elseBlock=iterate_block;
	       }
		   /* Find "then" case */
		iterate_block=temp_block->rdom;
	   //     printf("Looking for THEN starting from %i ending at %i\n",
	//	       iterate_block->num,temp_block->num);
		while(iterate_block->branch!=temp_block) {
		   if ((iterate_block->branch==NULL) &&
			 (iterate_block->fail!=NULL))
			 iterate_block=iterate_block->fail;
		   else iterate_block=iterate_block->branch;
		   if (iterate_block==NULL) break;
		}
		thenBlock=iterate_block;
		
	   //    printf("AIEE6! %p %p %p\n",joinBlock,thenBlock,elseBlock); fflush(stdout);
		vmwRemovePhisIf(joinBlock,thenBlock,elseBlock);
	     //  printf("AIEE7!\n"); fflush(stdout);
		found=1;
	     }
	     
	     	        /* HANDLE WHILE STATEMENT */
	     else if (temp_block->kind==blockWhileHead) {
	     //   printf("ZZTOP\n");

		parentBlock=temp_block->rdom;
		headBlock=temp_block;		
		iterate_block=temp_block->dsc;
		
		while(iterate_block!=NULL) {
		   
	           if (iterate_block->kind==blockWhileBody) {

		      bodyBlock=iterate_block;
		      
//		      printf("Finding %i -> %i\n",
//			      iterate_block->num,headBlock->num);
		      bodyBlock=find_last_block(iterate_block,headBlock);
//		      while(bodyBlock->branch!=headBlock) {
//			 if (bodyBlock->branch==NULL) {
//			   bodyBlock=bodyBlock->fail;
//			 }
//			 else {  
//		            bodyBlock=bodyBlock->branch;	 
//			 }
//			 
//		      }
		      
		      
			   
		      
		   }
					
		   iterate_block=iterate_block->next;

		}
//		printf("GEEK!\n");fflush(stdout);
		
		if ((bodyBlock==NULL) || (headBlock==NULL)) {
		   vmwError("While NULL ERROR!\n");
		}

		
		vmwRemovePhisIf(headBlock,bodyBlock,parentBlock);
//		printf("ZZZZ\n"); fflush(stdout);
		found=1;
	     }
	     

	     
	     
	  }
//	  printf("PPP\n");
	      
	 
	 
          temp_node=temp_node->next;	
	  if (temp_node==NULL) found=1;
      }
  //    printf("TTT\n");
	   
      
      
      temp_block=temp_block->link;
//      printf("OOOO\n"); fflush(stdout);
   }
   
//	printf("BLARGH!\n"); fflush(stdout);
}

   

