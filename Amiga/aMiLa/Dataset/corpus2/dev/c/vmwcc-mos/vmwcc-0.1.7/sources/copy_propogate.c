#include <stdio.h>

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"
#include "globals.h"
   

void vmwCopyPropogate() {
   
   Node temp_node;
   Block temp_block;

   printf("OPTIMIZING: Performing Copy Propogation...\n");
   
   temp_block=root_block;
   while(temp_block!=NULL) {
      
      temp_node=temp_block->first;
      while(temp_node!=NULL) {
      
	 if (temp_node->op==vmwMove) {
	    temp_node->deleted=1; 
	    
	    vmwReplaceNode(temp_node->x,temp_node->y);

	 }
	 
	      
	 temp_node=temp_node->next;
      }
      
      temp_block=temp_block->link;
   }
   
	
   
}
