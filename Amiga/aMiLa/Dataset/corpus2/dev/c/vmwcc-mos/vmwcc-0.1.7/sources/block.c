#include <stdio.h>
#include <stdlib.h> /* calloc() */

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"

#include "globals.h"
#include "ir_generator.h"


Block InsertBlock( Block *root, char kind, int current_level) {
    
    Block temp_block=NULL;
    Block prev_block=NULL,old_next=NULL;

   
    if (*root==NULL) {
       temp_block=calloc(1,sizeof(BlockDesc));
      
       if (temp_block==NULL) {
	  vmwError("Improbably, we are out of memory");
       }
       *root=temp_block;
       root_block=temp_block;
    }
   
    else {
       prev_block=*root;
       old_next=(*root)->link;
       
       temp_block=*root;

       temp_block->link=calloc(1,sizeof(BlockDesc));
       
       if (temp_block->link==NULL) {
	  vmwError("Improbably, we are out of memory");
       }
       temp_block=temp_block->link;
       if (old_next!=NULL) old_next->prev=temp_block;
      
//       printf("Inserting block %lli after %lli\n",block_num,prev_block->num);
    }
    temp_block->prev=prev_block;
    temp_block->kind=kind;
    temp_block->fail=NULL;
    temp_block->branch=NULL;
    temp_block->first=NULL;
    temp_block->last=NULL;
    temp_block->link=old_next;
    temp_block->dsc=NULL;
    temp_block->rdom=NULL;
    temp_block->num=block_num;
    temp_block->next=NULL;
    temp_block->phi_functions=NULL;
    temp_block->entry=0;
    temp_block->offset=0;
    temp_block->prototype=0;
    temp_block->level=current_level;
    block_num++;
      
    return temp_block;
   
}


Block find_last_block( Block first, Block last) {
   
   Block temp_block;
   
//   printf("START\n"); fflush(stdout);
   
//   printf("First: %i Last: %i\n",first->num,last->num);
   temp_block=first;
   while(temp_block->branch!=last) {
      if (temp_block->branch==NULL) {
         temp_block=temp_block->fail;	 
      }
      else {
         temp_block=temp_block->branch;
      }
      
      if ((temp_block->branch==NULL) && (temp_block->fail==NULL)) {
	 vmwError("I give up!\n");
      }
   }
//   printf("END\n"); fflush(stdout);
   
//   printf("First: %i Last: %i NtoL: %i\n",
//	  first->num,last->num,temp_block->num);
   
   return temp_block;
}

void vmwConnectBlocks() {

   Block temp_block;
   
   temp_block=root_block;
   
   while(temp_block!=NULL) {

      if ((temp_block->fail!=NULL) && (temp_block->branch!=NULL)) {
	 /* Hopefully need no action.  Means a blbc or blbs */
         if (temp_block->fail!=temp_block->link) {
	    vmwError("Invalid Block!\n");
	 }    
      }
      else if (temp_block->fail!=NULL) {
	 if (temp_block->fail!=temp_block->link) {     
	    add_instruction(temp_block,End,vmwBr,CSGMakeJumpNode(&globscope, temp_block->fail),NULL,0);      
	 }
	 
      }
      
      else if (temp_block->branch!=NULL) {
         if (temp_block->branch!=temp_block->link) {
	    add_instruction(temp_block,End,vmwBr,CSGMakeJumpNode(&globscope, temp_block->branch),NULL,0);
	 }
      }

      temp_block=temp_block->link;
   }

}

   
