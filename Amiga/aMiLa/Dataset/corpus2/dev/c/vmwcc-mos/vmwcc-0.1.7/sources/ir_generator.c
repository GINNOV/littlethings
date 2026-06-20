#include <stdio.h>
#include <stdlib.h> /* calloc() */
#include <string.h> /* strdup() */

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"


#include "enums.h"
#include "globals.h"

#include "debug.h"
#include "phi_functions.h"
#include "copy_propogate.h"
#include "cse.h"
#include "register_allocate.h"

#include "backends.h"

#include "debug.h"


Node add_instruction(Block our_block,int location, int instruction, Node x, Node y,int no_extra_work) {
   
    Node temp_node=NULL,prev_node=NULL,old_next=NULL;
    Node root;

    if (our_block==NULL) vmwError("Null Block");

    root=our_block->first;

       /* If block empty, create first instruction */
    if (root==NULL) {
       temp_node=calloc(1,sizeof(NodeDesc));
      
       if (temp_node==NULL) {
	  vmwError("Improbably, we are out of memory");
       }
       root=temp_node;
       our_block->first=temp_node;
    }

    else {
          /* Put instruction before first isntruction */
       if (location==Before) {
	     
	  if ( root->prev==NULL) {
	     root->prev=calloc(1,sizeof(NodeDesc));
	     temp_node=root->prev;
	     old_next=root;
	     our_block->first=temp_node;
	  }	  
	  else {
	     prev_node=root->prev;
	     old_next=root;
	     prev_node->next=calloc(1,sizeof(NodeDesc));
	     temp_node=prev_node->next;
	     root->prev=temp_node;
	  }
	  
	  
       }
          /* put instruction after first instruction */
       if (location==After) {
	  prev_node=root;
          old_next=prev_node->next;

          prev_node->next=calloc(1,sizeof(NodeDesc));
      
          if (prev_node->next==NULL) {
	     vmwError("Improbably, we are out of memory");
          }
          temp_node=prev_node->next;
       }
       
          /* Put instruction at end of block */
       if (location==End) {
          temp_node=root;
	  while(temp_node->next!=NULL) {
	     temp_node=temp_node->next;
	  }
	  
	  temp_node->next=calloc(1,sizeof(NodeDesc));
	  prev_node=temp_node;
	  temp_node=temp_node->next;
       }
          /* Put before last branch */
       if (location==BeforeLastBranch) {
	  temp_node=root;
          while(temp_node->next!=NULL) {
	     temp_node=temp_node->next;
	  }
	  if ((temp_node->op==vmwBr) ||
	      (temp_node->op==vmwBeq) ||
	      	      (temp_node->op==vmwBle) ||
	      	      (temp_node->op==vmwBlt) ||
	      	      (temp_node->op==vmwBge) ||
	      	      (temp_node->op==vmwBgt) ||
	      	      (temp_node->op==vmwBneq) ||
	      	      (temp_node->op==vmwBeq)) {

	     root=temp_node;
	     
	     if ( root->prev==NULL) {
	        root->prev=calloc(1,sizeof(NodeDesc));
	        temp_node=root->prev;
	        old_next=root;
	        our_block->first=temp_node;
	     }	  
	     else {
	        prev_node=root->prev;
	        old_next=root;
	        prev_node->next=calloc(1,sizeof(NodeDesc));
	        temp_node=prev_node->next;
		root->prev=temp_node;
	     }
	  }
	  
	  else {
	     temp_node->next=calloc(1,sizeof(NodeDesc));
	     prev_node=temp_node;
	     temp_node=temp_node->next;
	  }
       }
    }

    temp_node->prev=prev_node;
    temp_node->next=old_next;
    temp_node->mode=CSGInstr;
    temp_node->op=instruction;
    temp_node->target_size=4; /* FIXME */
    temp_node->ind=-1;
    temp_node->reg=-1;

       /* We want to do fancy work */
    if (!no_extra_work) {
	

	  /* If first operand exists, set it up */
       if (x!=NULL) {
	     /* Set up mode */
          temp_node->xtype=x->mode;
	     /* If variable, point to current version */
          if (x->mode==CSGVar) {
             temp_node->x=x->current;
          }
	     /* Otherwise, x=x */
          else temp_node->x=x;
       }

          /* add fake store to phi block          */
          /* This keeps us from CSE'ing too much? */
       if ( (temp_node->op==vmwStore)
	    && (current_depth>0) && (x!=NULL) ) {
          add_instruction(current_phi_block,Before,vmwStore,NULL,y,0);
       }
       
   
   
    
          /* If store or Move it means we have phi stuff to take care of */
       if ((temp_node->op==vmwMove)) {
	  
	     /* If y operand is instruction then.. well actually we can't store to an instr! */
	  if (y->mode!=CSGVar) {
	     vmwError("Error cannot store to instruction!\n");
//	     	  printf("OHNO! Storing to %s\n",y->name);
	     
	  }


	  
	     /* If we are in an if or while construct */
	     /* Prepare the phi infromation           */
	  if (current_depth>0) {
	     /* y = var */
	     /* y->current = current_version of the var */
	     /* current_path = are win in then or else? */
	     MakePhi(&y,&(y->current),&(y->current),current_path);
	  }
	  
	     /* We are storing/moving so update the version info on y */
	  
	     /* Add a new variable to the linked list */
	     /* And make it the current one           */
//	  printf("BFBF\n");
//	  if (y->var_list==NULL) printf("NULLLLLLLLLLLLLLLLLLLLLLLLLLLLLL\n");
//	  printf("AFAF\n");
	  y->current=AddToList(& (y->var_list),NULL);

	  
	  
//	         printf("***********ADDING %s at %p\n",
//			y->name,y->current);
	  	    {
	       Node blug_node;
	       int i=0;
	       blug_node=y->var_list;
	       while (blug_node!=NULL) 
		 {
//		   printf("%s #%i\n",y->master->name,i);
	           blug_node=blug_node->next;	 
		    i++;
	 	 }
	    }
	     /* Make the variable originate with the current instruction */
	  y->current->current=temp_node;
	     /* The parent of the instruction is y */
	  y->current->master=y;
             /* Our new var is also a var */
//          y->current->mode=CSGVar;

	     /* Update phi info for our new var */
	  if (current_depth>0) {
	     MakePhi(&y,&(y->current),&(y->current),current_path);
	  }
       }
       
          /* handle Y variable */
       if (y!=NULL) {
             /* setup the ytype */
	  temp_node->ytype=y->mode;
       
	     /* If variable point to current version of it */
          if (y->mode==CSGVar) {
	     temp_node->y=y->current;
	     temp_node->ytype=CSGVar;
	  }
	  
          else temp_node->y=y;
       }
    }
    else {   
       temp_node->x=x; 
       temp_node->xtype=x->mode;
       temp_node->y=y; 
       temp_node->ytype=y->mode;
    }
   
    temp_node->line_number=0;
    temp_node->type=CSGlongType;
    temp_node->block=our_block;
    temp_node->lev=1;
    temp_node->use=NULL; 
    temp_node->xLastUse=NULL;
    temp_node->yLastUse=NULL;
      
       /* lastuse destroyed by store */
   /* if ( (temp_node->op==vmwStore) || (temp_node->op==vmwMove)) {
       if (y->mode!=CSGInstr) temp_node->y->use=NULL;
    }
*/
    current_instruction=temp_node;

   
   
      /* set block->last */
    our_block->last=our_block->first;
    while(our_block->last->next!=NULL) {
       our_block->last=our_block->last->next;
    }
   
	
   
    return temp_node;
}



static void TestInt(Node x) {
   
//    if ((x->type->form != CSGLong) &&
  //     (x->type->form != CSGInt)) vmwError("type long expected");

}


Node CSGMakeCallNode(Node *x, char *name) {
    Node temp_node=NULL;

    temp_node=FindNode(&globscope,name);
   
     if (temp_node==NULL) {
	temp_node=AddToList(&globscope,name);
	temp_node->mode=CSGJmp;
     }
   
   return temp_node;
}


    /* Make a node holding a jump target */
Node CSGMakeJumpNode(Node *x, Block target) {
   
     Node temp_node=NULL;
     char id[vmwIdlen];
   
       /* Constants are just named with their values */
     snprintf(id,vmwIdlen,"->%i",target->num);
   
       /* See if we have an identical const already */
     temp_node=FindNode(&globscope,id);
   
     if (temp_node==NULL) {
	temp_node=AddToList(&globscope,id);
	temp_node->mode=CSGJmp;
     }
     temp_node->jump_target=target;
   
   return temp_node;
}

//    label=calloc(1,sizeof(NodeDesc));
//    //    label->mode=CSGJmp;
//    //    label->val=instruction_num;
//    
    /* Make a node holding a constant */
Node CSGMakeConstNode(Node *x, const Type typ, const int val) {
   
     Node temp_node=NULL;
     char id[vmwIdlen];
   
   

       /* Constants are just named with their values */
     snprintf(id,vmwIdlen,"%i",val);
   
       /* See if we have an identical const already */
     temp_node=FindNode(&globscope,id);
   
     if (temp_node==NULL) {
	temp_node=AddToList(&globscope,id);
	temp_node->mode=CSGConst;
	temp_node->type=typ;
	temp_node->val=val;
	temp_node->lev=current_level;
     }	

   return temp_node;
}


    /* Make a node holding a pointer         */
    /* used for globals, arrays, and structs */
Node CSGMakePtrNode(Node *x, Node *point_to) {
   
     Node temp_node=NULL;
     char id[vmwIdlen];
      
     snprintf(id,vmwIdlen,"^%s",(*point_to)->name);
   
       /* See if we have an identical const already */
     temp_node=FindNode(&globscope,id);
   
     if (temp_node==NULL) {
	temp_node=AddToList(&globscope,id);
	temp_node->mode=CSGPtr;
        temp_node->lev=(*point_to)->lev;
	temp_node->x=*x;
	temp_node->current=(*point_to);
     }
      
   return temp_node;
}

static void CheckIfPowerOfTwo(int num, int * const shift) {

    *shift = 0;
    if ((num > 1) && ((num & (num-1)) == 0)) {
	
       while ((num & 1) == 0) {
          num >>= 1; (*shift)++;
       }	
    }
   
    if (num != 1) *shift = 0;
}



    /* Initialize the Code Generator */
void IRInit(void) {

       /* clear the entry point */
   entrypc=-1;
   
       /* Initialize out built-in int and Boolean types */
   
   CSGlongType=calloc(1,sizeof(struct TypeDesc));
   CSGlongType->form=CSGLong;
   CSGlongType->size=sizeof(long);
   
   CSGintType=calloc(1,sizeof(struct TypeDesc));
   CSGintType->form=CSGInt;
   CSGintType->size=sizeof(int);
   
   CSGcharType=calloc(1,sizeof(struct TypeDesc));
   CSGcharType->form=CSGChar;
   CSGcharType->size=sizeof(char);
   
   CSGshortType=calloc(1,sizeof(struct TypeDesc));
   CSGshortType->form=CSGShort;
   CSGshortType->size=sizeof(short);
   
   CSGvoidType=calloc(1,sizeof(struct TypeDesc));
   CSGvoidType->form=CSGVoid;
   CSGvoidType->size=sizeof(void);
 
   CSGboolType=calloc(1,sizeof(struct TypeDesc));
   CSGboolType->form=CSGBoolean;
   CSGboolType->size=sizeof(int);
      
}

   /* Initialize some defaults */
void CSGOpen(void) {
       /* In the global scope */
    current_level=0;
     
    first_instruction=calloc(1,sizeof(NodeDesc));
    first_instruction->op=vmwNop;
    first_instruction->line_number=0;
   
   

}


void vmwMakeStupidDominatorTree(Block root) {
   
    Block temp_block;
   
    temp_block=root;
   
    while(temp_block!=NULL) {
       if (temp_block->rdom!=NULL) {
	  temp_block->next=temp_block->rdom->dsc;
	  temp_block->rdom->dsc=temp_block;
       }
       
	    
       temp_block=temp_block->link;
    }
   
   
}



void vmwFindUse(Node source) {
    Node temp_node,phi_node;
    Block temp_block;
   
       /* Loop through all blocks */
    temp_block=root_block;
    while(temp_block!=NULL) {
          /* Loop through all instrs */
       temp_node=temp_block->first;
       while(temp_node!=NULL) {	  
	

	  if (!(temp_node->deleted)) {

	     
	     if (temp_node->op==vmwPhi) {
	     	
		phi_node=temp_node->y;
			
	        while(phi_node!=NULL) {
		   if (phi_node->x==source) {
		      source->use=temp_node;
		   }
		   phi_node=phi_node->next;
		}
	     }
	     else {
	           /* Calculate use */
	        if ( (temp_node->x==source) || (temp_node->y==source) ) {
	           source->use=temp_node;
	        }
	     }
	     
	  
	        /* Calculate xlu */
	     if ( (source->x) && (source->x->mode==CSGInstr)
	      && ((temp_node->x==source->x)||(temp_node->y==source->x))) {
	       source->xLastUse=temp_node;
	     }
	        /* Calculate ylu */
	     if ( (source->y) && (source->y->mode==CSGInstr)
	        && ((temp_node->x==source->y)||(temp_node->y==source->y))) {
	       source->yLastUse=temp_node;
	     }
	     
	  }
	  
	  
	       
       
          temp_node=temp_node->next;
       }
       
   
       temp_block=temp_block->link;
    }

}

   

void vmwRecalculateUse(void) {
   
    Node temp_node;
    Block temp_block;
   
       /* Loop through all blocks */
    temp_block=root_block;
    while(temp_block!=NULL) {
          /* Loop through all instrs */
       temp_node=temp_block->first;
       while(temp_node!=NULL) {	  
	

	  vmwFindUse(temp_node);
       
          temp_node=temp_node->next;
       }
       
       temp_block=temp_block->link;
    }
}




void IRGenerate(Node root,char *name) {
          
    FILE *dom_tree;
    struct anchor_type anchor; 
    char fname[BUFSIZ];
    FILE *assem,*ssa;


    vmwMakeStupidDominatorTree(root_block);

       /* Print out a graphical view of dominator tree */
       /* Readable using the bell labs dot utility     */
    if (output_options & O_DOMTREE) {

       snprintf(fname,BUFSIZ,"%s.dot",name);
       printf("DEBUG: Printing dominator tree to \"%s\"\n",fname);	
       dom_tree=fopen(fname,"w");
       if (dom_tree!=NULL) {
          fprintf(dom_tree,"digraph dom_tree {\n");
          vmwPrintDominatorTree(dom_tree,root_block);
          fprintf(dom_tree,"}\n");
          fclose(dom_tree);
       }
       
    }
   
   

   
    vmwConnectBlocks();

    if (optimize_level==0) {
       printf("OPTIMIZING: Optimizations are disabled.\n");
    }
   
    else {
//       if (optimize_level>=2) vmwCopyPropogate();
       if (optimize_level>=2) vmwEliminateCommonSubexpressions(anchor,root_block);   
    }
       
   
    vmwRemoveFakeStores();
    vmwRecalculateUse();

    vmwAddStupidLineNumbers();     

   
    printf("COMPILING: Initial SSA completed.");
    if (output_options & O_SSAINITIAL) {	
       snprintf(fname,BUFSIZ,"%s.ssa",name);
       ssa=fopen(fname,"w");
       if (ssa!=NULL) {
	  printf("  Wrote to file %s",fname);  
          vmwDumpInstructions(ssa);
	  fclose(ssa);
       }
    }
    printf("\n");

   
    printf("COMPILING: Removing phi functions...\n");
    vmwRemoveFreakingPhiFunctions(root_block);
   
    printf("COMPILING: Final SSA completed.");
    if (output_options & O_SSAFINAL) {	
       snprintf(fname,BUFSIZ,"%s.ssa2",name);
       ssa=fopen(fname,"w");
       if (ssa!=NULL) {
	  printf("  Wrote to file %s",fname);  
          vmwDumpInstructions(ssa);
          fclose(ssa);
       }    
    }
    printf("\n");
    
   
    printf("COMPILING: Allocating Registers...\n");
    vmwRegisterAllocateAll(root_block);
   
    printf("COMPILING: Generating Assembly...\n");
   
//    vmwDumpPPC(stdout);

   
    snprintf(fname,BUFSIZ,"%s.s",name);
    assem=fopen(fname,"w");
    if (assem==NULL) {
       printf("Could not open %s for writing\n",fname);
       exit(1);
    }
   
    vmwDumpPPC(assem);
    fclose(assem);	
   
}


    /* Checking equality here */
Node CSGRelation(const int op, Node *x, Node *y) {
  
    Node temp_x,temp_y;
   
    TestInt(*x);
    TestInt(*y);
   
     
    if ( (*x)->mode == CSGConst) {
       temp_x=CSGMakeConstNode(&temp_x,CSGlongType,(*x)->val);

       if ( (*y)->mode == CSGConst) {
	  /* X and Y are both constant */
          /* This should be folded up somehow, OPTIMIZE */
	  temp_y=CSGMakeConstNode(&temp_y,CSGlongType,(*y)->val);

	  switch (op) {
	       case vmwTeql: 
	            if (temp_x->val==temp_y->val) {
		       *x=add_instruction(current_block,End,vmwBeq,temp_x,temp_y,0); 
		    }
	     
                    break;
               case vmwTneq: 
	            if (temp_x->val!=temp_y->val) {
	               *x=add_instruction(current_block,End,vmwBneq,temp_x,temp_y,0);
		    }
                    break;
               case vmwTlss: 
	            if (temp_x->val<temp_y->val) {
	               *x=add_instruction(current_block,End,vmwBlt,temp_x,temp_y,0);
		    }
                    break;
               case vmwTgtr: 
	            if (temp_x->val>temp_y->val) {
	               *x=add_instruction(current_block,End,vmwBgt,temp_x,temp_y,0);
		    }
                    break;
               case vmwTleq: 
	            if (temp_x->val<=temp_y->val) { 
	               *x=add_instruction(current_block,End,vmwBle,temp_x,temp_y,0);
		    }
                    break;
               case vmwTgeq: 
	            if (temp_x->val>=temp_y->val) {       
	               *x=add_instruction(current_block,End,vmwBge,temp_x,temp_y,0);
		    }
	     
                    break;       
	  }
       }
       
       else {

	   /* x is const, y is not const */
	   switch (op) {
	      case vmwTeql: *x=CSGRelation(vmwTeql, y, x); break;
	      case vmwTneq: *x=CSGRelation(vmwTneq, y, x); break;
	      case vmwTlss: *x=CSGRelation(vmwTgtr, y, x); break;
	      case vmwTgtr: *x=CSGRelation(vmwTlss, y, x); break;
	      case vmwTleq: *x=CSGRelation(vmwTgeq, y, x); break;
	      case vmwTgeq: *x=CSGRelation(vmwTleq, y, x); break;
	   }
	  
       }
       
    } else {  /* x is not const */
              
       if ( (*x)->lev==0) {
	  *x=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,x),GP,0);
	  *x=add_instruction(current_block,End,vmwLoad,*x,NULL,0);
       }
       
       
       if ( (*y)->mode == CSGConst) {
	  temp_y=CSGMakeConstNode(&temp_y,CSGlongType,(*y)->val);  
	  switch (op) {
             case vmwTeql: 
	          *x=add_instruction(current_block,End,vmwBneq,*x,temp_y,0); 
                  //        *x=add_instruction(current_block,End,vmwBlbc,*x,NULL,0);
                          break;
             case vmwTneq: 
	          *x=add_instruction(current_block,End,vmwBeq,*x,temp_y,0);
             //             *x=add_instruction(current_block,End,vmwBlbs,*x,NULL,0);
                          break;
             case vmwTlss: 
	        //  vmwDumpNode(*x);
	          *x=add_instruction(current_block,End,vmwBge,*x,temp_y,0);
                  //        *x=add_instruction(current_block,End,vmwBlbc,*x,NULL,0);
                          break;
             case vmwTgtr: 
	          *x=add_instruction(current_block,End,vmwBle,*x,temp_y,0);
                  //        *x=add_instruction(current_block,End,vmwBlbs,*x,NULL,0);
                          break;
             case vmwTleq: 
	          *x=add_instruction(current_block,End,vmwBgt,*x,temp_y,0);
                  //        *x=add_instruction(current_block,End,vmwBlbc,*x,NULL,0);
                          break;
             case vmwTgeq: 
	          *x=add_instruction(current_block,End,vmwBlt,*x,temp_y,0);
                  //        *x=add_instruction(current_block,End,vmwBlbc,*x,NULL,0);
                          break;       
	     
	  }
	  
       }
       
       else {
	  if ( (*y)->lev==0) {     
	     *y=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,y),GP,0);
	     *y=add_instruction(current_block,End,vmwLoad,*y,NULL,0);
          }
	  
	      /* neither is const, or const out of range */
          switch (op) {
             case vmwTeql: 
	          *x=add_instruction(current_block,End,vmwBneq,*x,*y,0); 
                  //        *x=add_instruction(current_block,End,vmwBlbc,*x,NULL,0);
                          break;
             case vmwTneq: 
	          *x=add_instruction(current_block,End,vmwBeq,*x,*y,0);
                  //        *x=add_instruction(current_block,End,vmwBlbs,*x,NULL,0);
                          break;
             case vmwTlss: 
	          *x=add_instruction(current_block,End,vmwBge,*x,*y,0);
                  //        *x=add_instruction(current_block,End,vmwBlbc,*x,NULL,0);
                          break;
             case vmwTgtr: 
	          *x=add_instruction(current_block,End,vmwBle,*x,*y,0);
                  //        *x=add_instruction(current_block,End,vmwBlbs,*x,NULL,0);
                          break;
             case vmwTleq: 
	          *x=add_instruction(current_block,End,vmwBgt,*x,*y,0);
                   //       *x=add_instruction(current_block,End,vmwBlbc,*x,NULL,0);
                          break;
             case vmwTgeq: 
	          *x=add_instruction(current_block,End,vmwBlt,*x,*y,0);
                  //        *x=add_instruction(current_block,End,vmwBlbc,*x,NULL,0);
                          break;       

       }
	
       }
       
    }
   

    return *x;
}

    /* x = op x */
Node CSGOp1(const int op, Node *x) {

   switch(op) {
    case vmwTplus:  
        /* If unary plus, do nothing */

        TestInt(*x);
        break;
      
    case vmwTminus: 

         TestInt(*x);
       
         switch ( (*x)->mode) {
          case CSGConst: 
	       *x=CSGMakeConstNode(&globscope,CSGlongType,
					     -((*x)->val)); 
	       break;
	  case CSGVar: 
	  case CSGFld: 
	  case CSGReg:
	  case CSGInstr:
	       if ((*x)->lev==0) {
		  *x=add_instruction(current_block,End,vmwAdda,
				     CSGMakePtrNode(&globscope,x),GP,0);
		  *x=add_instruction(current_block,End,vmwLoad,*x,NULL,0);
	       }
	       *x=add_instruction(current_block,End,vmwNeg,*x,NULL,0);	  
	       break;
	 }
         break;
    case vmwTbitnot:

         TestInt(*x);
       
         switch ( (*x)->mode) {
          case CSGConst: 
	       *x=CSGMakeConstNode(&globscope,CSGlongType,
					     ~((*x)->val)); 
	       break;
	  case CSGVar: 
	  case CSGFld: 
	  case CSGReg:
	  case CSGInstr:
	       if ((*x)->lev==0) {
		  *x=add_instruction(current_block,End,vmwAdda,
				     CSGMakePtrNode(&globscope,x),GP,0);
		  *x=add_instruction(current_block,End,vmwLoad,*x,NULL,0);
	       }
	       *x=add_instruction(current_block,End,vmwNot,*x,NULL,0);	  
	       break;
	 }
         break;
      
    case vmwTboolnot:
         TestInt(*x);
       
         switch ( (*x)->mode) {
          case CSGConst: 
	       *x=CSGMakeConstNode(&globscope,CSGlongType,
					     !((*x)->val)); 
	       break;
	  case CSGVar: 
	  case CSGFld: 
	  case CSGReg:
	  case CSGInstr:
	       if ((*x)->lev==0) {
		  *x=add_instruction(current_block,End,vmwAdda,
				     CSGMakePtrNode(&globscope,x),GP,0);
		  *x=add_instruction(current_block,End,vmwLoad,*x,NULL,0);
	       }
	       *x=add_instruction(current_block,End,vmwBoolnot,*x,NULL,0);
	       break;
	 }
         break;
    default: vmwError("Unknown unary operation!");
   }
   
   return *x;
}



    /* x=x op y */
Node CSGOp2(const int op, Node *x, Node *y)  {

    Node temp_node=NULL;
    int shift;
   
    if ( (*x)->type != (*y)->type) printf("WARNING: incompatible types\n");

    if ( (*x)->mode == CSGConst) {
	
          /* If both are constants, we can fold! */
       if ( (*y)->mode == CSGConst) {
	     
	  switch (op) {		  
	     case vmwTplus: *x=CSGMakeConstNode(&temp_node,CSGlongType,(*x)->val + (*y)->val); break;
	     case vmwTminus: *x=CSGMakeConstNode(&temp_node,CSGlongType,(*x)->val -(*y)->val); break;
	     case vmwTtimes: *x=CSGMakeConstNode(&temp_node,CSGlongType,(*x)->val * (*y)->val); break;
	     case vmwTdiv: *x=CSGMakeConstNode(&temp_node,CSGlongType,(*x)->val / (*y)->val); break;
	     case vmwTmod: *x=CSGMakeConstNode(&temp_node,CSGlongType,(*x)->val % (*y)->val); break;
	     case vmwTlshift: *x=CSGMakeConstNode(&temp_node,CSGlongType,(*x)->val << (*y)->val); break;
	     case vmwTrshift: *x=CSGMakeConstNode(&temp_node,CSGlongType,(*x)->val >> (*y)->val); break;
	     default: vmwError("Unknown operation");
	  }
	  
       }
       
          /* X is a constant, but y is not! */
       else {
	  temp_node=CSGMakeConstNode(&temp_node,CSGlongType,(*x)->val);
	  if ((*y)->lev==0) {
             *y=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,y),GP,0);
	     *y=add_instruction(current_block,End,vmwLoad,*y,NULL,0);
          }
	  switch (op) {
	         /* for communative ops, cheat and just switch */
	         /* operands and re-run                        */
	     case vmwTplus: case vmwTtimes: *x=CSGOp2(op, y, x); /**x = *y;*/ break;
	         /* x = const - y */
	     case vmwTminus:        
	             /* 0 - x = -x */
	          if ( (*x)->val == 0) {
		     *x=add_instruction(current_block,End,vmwNeg,*y,NULL,0);
		  }
	          else {
		     *x=add_instruction(current_block,End,vmwSub,temp_node,*y,0);
		  }
	     
	          break;
	         /* x = const / y */
	     case vmwTdiv: 
	          if ( (*x)->val==0) vmwError("Divide by zero!\n");
	          *x=add_instruction(current_block,End,vmwDiv,temp_node,*y,0);
	          break;
	         /* x = const % y */
	    case vmwTmod:
	         if ( (*x)->val == 0) vmwError("Mod by zero!\n");
		 *x=add_instruction(current_block,End,vmwMod,temp_node,*y,0);
	         break;
	      
	         /* x=const << y */
	    case vmwTlshift:
	         *x=add_instruction(current_block,End,vmwLshift,temp_node,*y,0);
	         break;
	  	         /* x=const >> y */
	    case vmwTrshift:
	         *x=add_instruction(current_block,End,vmwRshift,temp_node,*y,0);
	         break;
  	    default: vmwError("Unknown operation!");
	  }
       }
    }
   

       /* x is not constant */
    else {
       if ((*x)->lev==0) {
          *x=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,x),GP,0);
	  *x=add_instruction(current_block,End,vmwLoad,*x,NULL,0);
       }
       
	    
          /* x is not constant, but y is */
       if ( (*y)->mode == CSGConst) {
	  temp_node=CSGMakeConstNode(&temp_node,CSGlongType,(*y)->val);
          switch (op) {
	     case vmwTplus:   
	        *x=add_instruction(current_block,End,vmwAdd,*x,temp_node,0);  
	        break;
	     case vmwTminus:
	        *x=add_instruction(current_block,End,vmwSub,*x,temp_node,0);
	        break;  
	     case vmwTtimes:
	               
	        if ( (*y)->val != 1) {
		  
		      /* Multiply by -1 is same as negate */
		   if ( (*y)->val == -1) {
		      *x=add_instruction(current_block,End,vmwNeg,*x,NULL,0);
		   }
		      /* Multiply by 0 _is_ zero */
		   else if ( (*y)->val == 0) {
		      *x=CSGMakeConstNode(x, CSGlongType, 0);
		   }
		      /* add twice is faster than *2 */
		   else if ( (*y)->val == 2) {
	              *x=add_instruction(current_block,End,vmwAdd,*x,*x,0);
		   }
		   else {
		         /* If power of 2, shift */
		      CheckIfPowerOfTwo( (*y)->val, &shift);
		      if (shift != 0) {
			 temp_node=CSGMakeConstNode(&temp_node,CSGlongType,shift);
			 *x=add_instruction(current_block,End,vmwLshift,*x,temp_node,0);	     
		      }
		      else {
			 *x=add_instruction(current_block,End,vmwMul,*x,temp_node,0);
		      }
		      
		   }
		   
		}
	        break;
	   case vmwTdiv:
	      if ( (*y)->val == 0) vmwError("division by zero");
	               
	      if ( (*y)->val != 1) {
		    /* Divide by -1 same as negating */
		 if ( (*y)->val == -1) {
		    *x=add_instruction(current_block,End,vmwNeg,*x,NULL,0);
		 }
		 else {
		    CheckIfPowerOfTwo( (*y)->val, &shift);
		    
		       /* Optimze powers of 2 to shifts */
		    if (shift != 0) {
		       temp_node=CSGMakeConstNode(&temp_node,CSGlongType,shift);
		       *x=add_instruction(current_block,End,vmwRshift,*x,temp_node,0);
		    }
		    else {
		       *x=add_instruction(current_block,End,vmwDiv,*x,temp_node,0);
		    }
		    
		 }
		 
	      }
	      break;
	        /* Modulus operator */
	   case vmwTmod:
	      if ( (*y)->val == 0) vmwError("division by zero");
	     
	         /* Mod with 1 is 0 */
	      if ( (*y)->val == 1) {
		 *x=CSGMakeConstNode(x, CSGlongType, 0);
	      }
	      else {
	         CheckIfPowerOfTwo( (*y)->val, &shift);
		     /* power of two can be optimized to and */
		  if (shift != 0) {
		     temp_node=CSGMakeConstNode(&temp_node,CSGlongType,temp_node->val-1);
		     *x=add_instruction(current_block,End,vmwAnd,*x,temp_node,0);
//		     printf("Convert to mod %i\n",temp_node->val);
		  }
		  else {
		     *x=add_instruction(current_block,End,vmwMod,*x,temp_node,0);
		  }
	      }
	      break;
	      case vmwTlshift:   
	           *x=add_instruction(current_block,End,vmwLshift,*x,temp_node,0);  
	           break;
	      case vmwTrshift:   
	           *x=add_instruction(current_block,End,vmwRshift,*x,temp_node,0);  
	           break;
	      default: vmwError("Unknown operation");  
	  }
       }
       
   
   
    
       /* neither x nor y are const */
       else {
	  if ((*y)->lev==0) {
             *y=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,y),GP,0);
	     *y=add_instruction(current_block,End,vmwLoad,*y,NULL,0);
          }
          switch (op) {
	     case vmwTplus: *x=add_instruction(current_block,End,vmwAdd,*x,*y,0);
	                   break;
	     case vmwTminus: *x=add_instruction(current_block,End,vmwSub,*x,*y,0);
	                    break;
	     case vmwTtimes: *x=add_instruction(current_block,End,vmwMul,*x,*y,0);
	                    break;
	     case vmwTdiv: *x=add_instruction(current_block,End,vmwDiv,*x,*y,0);
	                    break;
	     case vmwTmod: *x=add_instruction(current_block,End,vmwMod,*x,*y,0);
	                    break;
	     case vmwTlshift: *x=add_instruction(current_block,End,vmwLshift,*x,*y,0);
	                    break;
	     case vmwTrshift: *x=add_instruction(current_block,End,vmwRshift,*x,*y,0);
	                    break;
	     default: vmwError("Unknown operation");
	  }
       }
       
    }
   
   

    return *x;
}






    /* x = x.y */
Node CSGField(Node *x, Node *y, int load, Type *curr_type)  {

    if ( (*x)->mode!=CSGInstr) {
       if ( (*x)->lev==0) {
          *x=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,x),GP,0);
          *x=add_instruction(current_block,End,vmwAdd,*x,*y,0);
       }
       else {
          *x=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,x),FP,0);
          *x=add_instruction(current_block,End,vmwAdd,*x,*y,0);
       }
    }
       /* If instruction, offsetting fron instr not from GP or FP */
    else {
       *x=add_instruction(current_block,End,vmwAdd,*x,*y,0);
    }
   
   
    if (load) *x=add_instruction(current_block,End,vmwLoad,*x,NULL,0);

       /* store type in the instruction       */
       /* because otherwise this info is lost */
    (*curr_type)=(*y)->type;
   (*x)->type=(*y)->type;
   
    return *x;
}



   /* x=x[y] */
Node CSGIndex(Node *x, Node *y, int load) {
      
    Node temp_node;
    int level,size;
   
    level=(*x)->lev;
   
    if ( (*y)->mode == CSGConst) {
       if (( (*y)->val < 0) || ( (*x)->type->len <= (*y)->val)) {
//	  vmwError("index out of bounds");
       }
    }
   
//    zp=CSGMakeConstNode(&zp, CSGlongType, (*x)->type->base->size);
//  CSGOp2(vmwTtimes, y, &zp);
   

    if ( (*x)->mode!=CSGInstr) {
	
          /* If global, against GP */
       if ( level ==0)  {
          temp_node=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,x),GP,0);
       }
       else {
          temp_node=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,x),FP,0);
       }
       *y=add_instruction(current_block,End,vmwAdd,*y,temp_node,0);
    }
   
       /* If we are an instruction FP/GP has already been added in */
    else {
       *y=add_instruction(current_block,End,vmwAdd,*y,*x,0);
    }
   
   
   
   
    if (load) {
       Type blah;
       
       blah=(*x)->type;
       
       while(blah->base!=NULL) blah=blah->base;

       size=blah->size;
       printf("Loading, size %i\n", size);

       *y=add_instruction(current_block,End,vmwLoad,*y,NULL,0);
       (*y)->target_size=size;
       
    }
   
     (*y)->type = (*x)->type->base;
     while ((*y)->type->form==CSGArray) {
	(*y)->type=(*y)->type->base;
     }
     
     return *y;
}

   /* x=x[y] */
Node CSGBracket(Node *x, Node *y, int first, Node *old, Type *curr_type) {
      
    Node temp_node;
    int level;

/*    static Type curr_type;
   
    if (first) {
       curr_type=(*x)->type;
    }
*/      
    level=(*x)->lev;
   
    if ( (*y)->mode == CSGConst) {
       if (( (*y)->val < 0) || ( (*curr_type)->len <= (*y)->val)) {
//	  vmwError("index out of bounds");
       }
    }
   
//    zp=CSGMakeConstNode(&zp, CSGlongType, (*x)->type->base->size);
//  CSGOp2(vmwTtimes, y, &zp);
   
       /* Multiply index by array size */
   // temp_node=*y;

    if ( (*curr_type)->base==NULL) {
       vmwError("Error in bracket!");
   //    if ( debug_level==D_DEBUG) printf("DEBUG: can we do this?!\n");
    }
   
    else 
     {
	
    temp_node=CSGMakeConstNode(&globscope,CSGlongType,(*curr_type)->base->size);  
    *y=CSGOp2(vmwTtimes,y,&temp_node);
     
     }
   
	
//    *y=add_instruction(current_block,End,vmwMul,*y,CSGMakeConstNode(&globscope,CSGlongType,
//								     curr_type->base->size));
 
   

   if (!first) {
      *y=add_instruction(current_block,End,vmwAdd,*old,*y,0);
   }

   
   
	
   

   /*
       if ( (*x)->mode != CSGFld) {   
	  (*x)->mode = CSGFld;
	  (*x)->r = (*y)->r;
	  if ((*x)->lev > 0) {
	     *x=add_instruction(current_block,End,vmwAdda,*x,FP);
	     //PutOpR(addq, x->r, FP, x->r);
	     (*x)->lev = -1;
	  }
	  else if ( (*x)->lev == 0) {
	     *x=add_instruction(current_block,End,vmwAdda,*x,GP);
	     //PutOpR(addq, x->r, GP, x->r);
	     (*x)->lev = -1;
	  }
       }
       else {
//          PutOpR(addq, x->r, y->r, x->r);
	          
       }	
     }
    */
   
       /* recurse down the array */
     (*curr_type) = (*curr_type)->base;
   
     return *x;
}


   

void CSGEntryPoint(void) {
     
    if (entrypc >= 0) vmwError("multiple program entry points");
    entrypc = 1;

  
}


void CSGEnter(Node proc) {
   
    current_block=InsertBlock(&current_block,blockProc,current_level);
    current_block->vars=proc;

   
}


void CSGEndProc(void) {
   add_instruction(current_block,End,vmwRet,NULL,NULL,0);
}


void CSGReturn(Node *x) {
   add_instruction(current_block,End,vmwEarlyRet,*x,NULL,0);
}

   






void CSGClose(void) {
   add_instruction(current_block,End,vmwHCF,NULL,NULL,0);
}


    /* x = y */
void CSGStore(Node *x, Node *y)  {

   int size;
   
       /* Handle what we are assigning */
    switch ( (*y)->mode) {
       
       case CSGConst: 
            break;
       case CSGVar: 
          
            if ( (*y)->lev == 0 ) {     
               if ( (*y)->type->form != CSGArray) {
	          *y=add_instruction(current_block,End,vmwAdda,CSGMakePtrNode(&globscope,y),GP,0);
	       }
	       
       	       *y=add_instruction(current_block,End,vmwLoad,*y,NULL,0);	       
	    }
	    break;
       case CSGReg: 
            break;
       
       case CSGFld: 
            break;
       case CSGInstr:
            break;
    }
   
   
   
       /* If we have a variable, store it */
    if ( (*x)->mode == CSGVar) {

          /* Global */
       if ( (*x)->lev == 0) {
	  *x=add_instruction(current_block,End,vmwAdda,
			     CSGMakePtrNode(&globscope,x),GP,0);
	  

	  size=(*x)->type->size;
	  printf("Storing size %i\n",size);
	  *x=add_instruction(current_block,End,vmwStore,*y,*x,0);
	         (*x)->target_size=size;
       }
              
       
       
          /* Local */
       else {
	  add_instruction(current_block,End,vmwMove,*y,*x,0);
       }
       
     }
   
    else {
	
       	size=(*x)->type->size;
	printf("Storing size %i\n",size);
       *x=add_instruction(current_block,End,vmwStore,*y,*x,0);
       (*x)->target_size=size;
    }
}


   



    /* Handle sprocs */
    /* x=instruction, y=parameter */
void CSGIOCall(Node *x, Node *y) {

    Node temp_node=NULL;
   
       /* x->a = Sproc Number */
    if ( (*x)->val < 3) TestInt(*y);
     
       /* Read */
    if ( (*x)->val == 1) {
         
       *x=add_instruction(current_block,End,vmwRead,NULL,NULL,0);
       
          /* Handle global vars */
       if ((*y)->lev==0) {
	    
	  temp_node=add_instruction(current_block,End,vmwAdda,
			  CSGMakePtrNode(&globscope,y),
			  GP,0);
	  	  temp_node=add_instruction(current_block,End,vmwStore,*x,temp_node,0);
       }
       else 
       if ( (*y)->mode!=CSGVar) {
       
	  temp_node=add_instruction(current_block,End,vmwStore,*x,*y,0);
       }
       else {
	  *x=add_instruction(current_block,End,vmwMove,*x,*y,0);
       }
       
     }
   
       /* Write */
     else if ( (*x)->val == 2) {

	  /* Handle global vars */
       if ( (*y)->lev==0) {
	  temp_node=add_instruction(current_block,End,vmwAdda,
			  CSGMakePtrNode(&globscope,y),
			  GP,0);
	  temp_node=add_instruction(current_block,End,vmwLoad,temp_node,NULL,0);
       }	
       else 
       if ( (*y)->mode==CSGConst) {
          temp_node=CSGMakeConstNode(&globscope,CSGlongType,(*y)->val);
       }
       else {
          temp_node=*y;
       }
           
       add_instruction(current_block,End,vmwWrite,temp_node,NULL,0);
     }
   
       /* wrl */
    else {
       add_instruction(current_block,End,vmwWrl,NULL,NULL,0);
    }
   
}


void CSGParameter(Node *x, const Type ftyp, const int class) {

    Node temp_node;
   
    /* Handle Global vars as parameters */
   
   
   /*
    if ( (*x)->mode==CSGConst) {
       temp_node=add_instruction(current_block,END,vmw,temp_node,NULL,0);
       add_instruction(current_block,End,vmwParam,temp_node,NULL,0);
    }
   
   
    else */
      /* Handle Global vars as parameters */
    if ( (*x)->lev==0) {
       temp_node=add_instruction(current_block,End,vmwAdda,
			  CSGMakePtrNode(&globscope,x),
			  GP,0);
	temp_node=add_instruction(current_block,End,vmwLoad,temp_node,NULL,0);
       add_instruction(current_block,End,vmwParam,temp_node,NULL,0);
    }
    else {   	
       add_instruction(current_block,End,vmwParam,*x,NULL,0);
    }
   
   
}


void CSGCall(Node *x) {
   
   Node temp_node;
   Block temp_block;
   
   /*temp_node=calloc(1,sizeof(NodeDesc));
   temp_node->mode=CSGJmp;
   temp_node->val=(*x)->val;
   */
   
   temp_node=add_instruction(current_block,End,vmwBsr,
			     CSGMakeCallNode(&globscope,(*x)->name),NULL,0);
   temp_node->xtype=CSGJmp;

   *x=temp_node;
   
      /* since we return from abroad, make a new block */
   temp_block=current_block;
   current_block=InsertBlock(&current_block,blockDefault,current_level);
   temp_block->branch=current_block;
   temp_block->fail=current_block;
   current_block->rdom=temp_block;
}



