#include <stdio.h>

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"

#include "globals.h"

static void vmwPrintInstructName(Node instruction) {
   
    switch(instruction->op) {
       case vmwNeg: printf("neg"); break;
       case vmwAdd: printf("add"); break;
       case vmwSub: printf("sub"); break;
       case vmwMul: printf("mul"); break;
       case vmwDiv: printf("div"); break;
       case vmwMod: printf("mod"); break;
       case vmwLshift: printf("lshift"); break;
       case vmwRshift: printf("rshift"); break;
       case vmwAnd: printf("and"); break;
       case vmwOr: printf("or"); break;
       case vmwXor: printf("xor"); break;
       case vmwAdda: printf("adda"); break;
       case vmwLoad: printf("load"); 
                     switch(instruction->target_size) {
		      case 1: printf("_b"); break;
		      case 2: printf("_s"); break;
		      case 4: printf("_w"); break;
		      case 8: printf("_l"); break;
		      default: printf("_%i",instruction->target_size);	
		     }
       
                     break;
       
       case vmwStore: printf("store"); 
                     switch(instruction->target_size) {
		      case 1: printf("_b"); break;
		      case 2: printf("_s"); break;
		      case 4: printf("_w"); break;
		      case 8: printf("_l"); break;
		      default: printf("_%i",instruction->target_size);	
		     }
       break;
       
       
     
     
       case vmwMove: printf("move"); break;
       case vmwParam: printf("param"); break;
         
       case vmwBeq: printf("beq"); break;
       case vmwBneq: printf("bneq"); break;
       case vmwBgt: printf("bgt"); break;
       case vmwBlt: printf("blt"); break;
       case vmwBge: printf("bge"); break;
       case vmwBle: printf("ble"); break;
       
       case vmwBsr: printf("bsr"); break;
       case vmwBr: printf("br"); break;
       case vmwRet: printf("ret"); break;
       case vmwEarlyRet: printf("return"); break;
       
       case vmwRead: printf("read"); break;
       case vmwWrite: printf("write"); break;
       case vmwWrl: printf("wrl"); break;
       case vmwHCF: printf("end"); break;
       case vmwPhi: printf("phi"); break;
       
       case vmwNot: printf("not"); break;
       case vmwBoolnot: printf("bnot"); break;
       
       default: printf("Unknown!"); 
    }
}


void vmwDumpNode(Node const y) {

    printf("\nNode ");
    if (y->name!=NULL) {
       printf("%s",y->name);
    }
   
    printf(":\n");
    printf("\tMode: ");
    switch(y->mode) 
     {
      case CSGVar: printf("Var"); break;
      case CSGConst: printf("Const");break;
      case CSGFld: printf("Fld");break;
      case CSGTyp: printf("Typ");break;
      case CSGProc: printf("Proc");break;
      case CSGSProc: printf("SProc");break;
      case CSGReg: printf("Reg");break;
      case CSGJmp:printf("Jmp");break;
      case CSGInstr: printf("Instruction = "); 
	             vmwPrintInstructName(y);
	             if (y->x!=NULL) printf("\n   x=%s (%p)\n",y->x->name,y->x);
		     if (y->y!=NULL) printf("   y=%s (%p)\n",y->y->name,y->y);
	             if (y->op==vmwPhi) {
			Node bob;

			if (y->x!=NULL) printf("%s=(",y->x->master->name);
			bob=y->y;			
			while(bob!=NULL) {
			     
	                   if (bob->mode==CSGVar) {
			      if (bob->master!=NULL) {
				 printf("%s,",bob->master->name);
			      }
			      
			      else 
				{
				   printf("UNKNOWN!,");
				}
			      
			   }
			   else {
			      printf("Instr,");
			   }
			   
				
			   
			   bob=bob->next;
			}
			printf(")\n");
			
		     }
	
	     
	
	             break;
      default: printf("Unknown");
     }
    printf("\n");
    
    if (y->type!=NULL) {
       printf("\tForm: ");
       switch(y->type->form) {
          case CSGInt: printf("Integer"); break;
          case CSGBoolean: printf("Bool"); break;
          case CSGArray: printf("Array"); break;
          case CSGStruct: printf("Struct"); break;
          default: printf("Unknown");
       }
       printf("\n");
       printf("\tSize: %i\n",y->type->size);
     }
   
    printf("\tLevel: %s\n",y->lev==0?"Global":"Local");
    printf("\tval: %i\n",y->val);
   
}




void vmwAddStupidLineNumbers(void) {
   
    Node temp_node;
    long instruction_num=1;
    Block temp_block,prev_block;
    long block_num=1;

   
    temp_block=root_block;
    prev_block=root_block;
   
    while (temp_block!=NULL) {
       temp_block->num=block_num;
   
       temp_node=temp_block->first;
   
          /* Skip empty blocks */
       if (temp_node==NULL) {
//	  prev_block->link=temp_block->link;
//	  temp_block->link->rdom=temp_block->rdom;	    
//	  temp_block=temp_block->link;
//	  temp_block->num=block_num;

       }
       
	    
       
       
       while(temp_node!=NULL) {
   
          temp_node->line_number=instruction_num;
          temp_node=temp_node->next;
          instruction_num++;
       }    
       
       prev_block=temp_block;
       temp_block=temp_block->link;
       block_num++;
    }
   
}


   

void vmwPrintDominatorTree(FILE *fff,Block root) {
       
    Block temp_block;
   
    temp_block=root->dsc;
   
    while(temp_block!=NULL) {
       fprintf(fff,"%i -> %i;\n",root->num,temp_block->num);
       vmwPrintDominatorTree(fff,temp_block);
       temp_block=temp_block->next;
    }
}


void vmwDumpAll(Node root) {
    
    register Node curr;
   
    curr=root;
   
    printf("----------------------------------------\n");
   
    while(curr!=NULL) {
   
       printf("Node: ");
       if (curr->name!=NULL) {
	  printf("%s",curr->name);
       }
       else printf("Unknown");
       
       printf("\n");
       printf("\tclass: ");
       switch(curr->mode) {

	case CSGVar: printf("Var\n"); break;
	case CSGConst: printf("Const\n");break;
	case CSGFld: printf("Fld\n");break;
	case CSGTyp: printf("Typ\n");break;
	case CSGProc: printf("Proc\n");break;
	case CSGSProc: printf("SProc\n");break;
	case CSGReg: printf("Reg\n");break;
	case CSGJmp: printf("Jmp\n");break;
	case CSGInstr: printf("Instr\n"); break;
	default: printf("Unknown\n");break;
       }
       if (curr->type!=NULL) {
	    
          printf("\t\ttype: ");
          switch(curr->type->form) {
	   case 0: printf("Integer\n"); break;
	   case 1: printf("Boolean\n"); break;
	   case 2: printf("Array\n"); break;
	   case 3: printf("Struct\n"); break;
           default: printf("Unknown\n");
          }
	  printf("\t\tsize: %i\n",curr->type->size);
       }
       
	    
       printf("\tlevel: ");
       if (curr->lev==0) printf("Global 0\n");
       else printf("Local %i\n",curr->lev);

       
       printf("\tval: %i\n",curr->val);
       
       curr=curr->next;
    }
   
    printf("----------------------------------------\n");	
   
}



static int vmwFindFirstValidLine(Block target) {
   
   Block temp_block;
   Node temp_node;
   int result=-1;

   temp_block=target;
   if (target==NULL) return -1;
   
   while(result<0) {

      while (temp_block->first==NULL) {
         temp_block=temp_block->link;
	 if (temp_block==NULL) return -1;
      }
      
      if (temp_block->first!=NULL) {
         temp_node=temp_block->first;
	 while ( temp_node!=NULL) {
	    if (!temp_node->deleted) return temp_node->line_number;
	    temp_node=temp_node->next;
	 }
      }
      temp_block=temp_block->link;
   }
      
   return result;
}



    /* Dump the SSA representation */
void vmwDumpInstructions(FILE *fff) {

    Node temp_node,phi_node;
    Block temp_block,temp_branch;

    int done=0;
     
    temp_block=root_block;
      
    while(temp_block!=NULL) {
       fprintf(fff,"*** block %i",temp_block->num);
       fprintf(fff,"  fail ");
       if (temp_block->fail!=NULL) fprintf(fff,"%i",temp_block->fail->num);
       else fprintf(fff,"-");
      
       fprintf(fff,"  branch ");
       if (temp_block->branch!=NULL) fprintf(fff,"%i",temp_block->branch->num);
       else fprintf(fff,"-");
 
       fprintf(fff,"  rdom ");
       if (temp_block->rdom!=NULL) fprintf(fff,"%i",temp_block->rdom->num);
       else fprintf(fff,"-");
      
       fprintf(fff,"  dsc ");
       if (temp_block->dsc!=NULL) fprintf(fff,"%i",temp_block->dsc->num);
       else fprintf(fff,"-");
      
       fprintf(fff,"  next ");
       if (temp_block->next!=NULL) fprintf(fff,"%i",temp_block->next->num);
       else fprintf(fff,"-");

       fprintf(fff,"  link ");
       if (temp_block->link!=NULL) fprintf(fff,"%i",temp_block->link->num);
       else fprintf(fff,"-");
 
       fprintf(fff,"\n");

       temp_node=temp_block->first;
       done=0;
       while((!done) && (temp_node!=NULL)) {

	  fprintf(fff,"   instr %4i:  ",temp_node->line_number);

	  if (temp_node->deleted) fprintf(fff,"***DELETED*** ");
	  
          switch(temp_node->op) {
           case vmwNeg: fprintf(fff,"neg"); break;
	   case vmwNot: fprintf(fff,"not"); break;
	   case vmwBoolnot: fprintf(fff,"bnot"); break;
           case vmwAdd: fprintf(fff,"add"); break;
           case vmwSub: fprintf(fff,"sub"); break;
           case vmwMul: fprintf(fff,"mul"); break;
           case vmwDiv: fprintf(fff,"div"); break;
           case vmwMod: fprintf(fff,"mod"); break;
	   case vmwLshift: fprintf(fff,"lshift"); break;
	   case vmwRshift: fprintf(fff,"rshift"); break;
	   case vmwAnd: fprintf(fff,"and"); break;
	   case vmwOr: fprintf(fff,"or"); break;
	   case vmwXor: fprintf(fff,"xor"); break;
           case vmwAdda: fprintf(fff,"adda"); break;
           case vmwLoad: fprintf(fff,"load");
	                  switch(temp_node->target_size) {
		           case 1: fprintf(fff,"_b"); break;
		           case 2: fprintf(fff,"_s"); break;
		           case 4: fprintf(fff,"_w"); break;
		           case 8: fprintf(fff,"_l"); break;
		           default: fprintf(fff,"_%i",temp_node->target_size);
		          }
	                  break;
           case vmwStore: fprintf(fff,"store"); 
	     	                  switch(temp_node->target_size) {
		           case 1: fprintf(fff,"_b"); break;
		           case 2: fprintf(fff,"_s"); break;
		           case 4: fprintf(fff,"_w"); break;
		           case 8: fprintf(fff,"_l"); break;
		           default: fprintf(fff,"_%i",temp_node->target_size);
		          }
	                  break;
	     
           case vmwMove: fprintf(fff,"move"); break;
           case vmwParam: fprintf(fff,"param"); break;

	   case vmwBeq: fprintf(fff,"beq"); break;
	   case vmwBneq: fprintf(fff,"bneq"); break;
	   case vmwBgt: fprintf(fff,"bgt"); break;
	   case vmwBlt: fprintf(fff,"blt"); break;
	   case vmwBge: fprintf(fff,"bge"); break;
	   case vmwBle: fprintf(fff,"ble"); break;

           case vmwBsr: fprintf(fff,"bsr"); break;
           case vmwBr: fprintf(fff,"br"); break;
           case vmwRet: fprintf(fff,"ret"); break;
	   case vmwEarlyRet: fprintf(fff,"return"); break;
           case vmwRead: fprintf(fff,"read"); break;
           case vmwWrite: fprintf(fff,"write"); break;
           case vmwWrl: fprintf(fff,"wrl"); break;
           case vmwHCF: fprintf(fff,"end"); break;
	   case vmwPhi: fprintf(fff,"%s^%i = phi (",
			       temp_node->x->master->name,
			       temp_node->x->current->line_number);
	                phi_node=temp_node->y;

	                while(phi_node!=NULL) {
			   if (phi_node->xtype==CSGInstr) {
			      fprintf(fff," (%i) ",phi_node->x->line_number);
			   }
			   else
			   if (phi_node->xtype==CSGConst) {	
			      fprintf(fff," %s ",phi_node->x->master->name);
			   }
			   else
			   if (phi_node->x!=NULL) {
			      fprintf(fff," %s^%i ",phi_node->x->master->name,
				     phi_node->x->current->line_number);
			   }
			   

			   phi_node=phi_node->next;
			}
	                fprintf(fff,")");   
			break;
           default: fprintf(fff,"EIEIO"); break;
	  }

	  
          fprintf(fff,"\t"); fflush(stdout);

          if (temp_node->x!=NULL) {
	     if (temp_node->xtype==CSGConst) {
		fprintf(fff,"%s",temp_node->x->name);
	     }
	     else if (temp_node->xtype==CSGInstr) {
	        fprintf(fff,"(%i)",temp_node->x->line_number);
	     }
	     else if (temp_node->xtype==CSGPtr) {
	        fprintf(fff,"%sbase",temp_node->x->name+1);
	     }
	     else if (temp_node->xtype==CSGVar) {
	        fprintf(fff,"%s^%i",temp_node->x->master->name,temp_node->x->current->line_number);
	     }
	     else if (temp_node->xtype==CSGJmp) {
		temp_branch=temp_node->x->jump_target;
		
		if (temp_branch==NULL) fprintf(fff,"%s",temp_node->x->name);
		else
		
		fprintf(fff,"[%i]",vmwFindFirstValidLine(temp_branch));
		       
	     }
	     else if (temp_node->xtype==CSGPhi) {
	     }
	     
		  
	     else {
	        fprintf(fff,"%s",temp_node->x->name);
	     }
          }
	  
	  fprintf(fff,"\t"); fflush(stdout);
 
          if (temp_node->y!=NULL) {
	     if (temp_node->ytype==CSGConst) {
	        fprintf(fff,"%s",temp_node->y->name);
	     }
	     else if (temp_node->ytype==CSGInstr) {
	        fprintf(fff,"(%i)",temp_node->y->line_number);
	     }
	     else if (temp_node->ytype==CSGFld) {
	        fprintf(fff,"%soffs",temp_node->y->name);
	     }
	     else if (temp_node->ytype==CSGVar) {
	        fprintf(fff,"%s^%i",temp_node->y->master->name,temp_node->y->current->line_number);
	     }
	     else if (temp_node->ytype==CSGPtr) {
		fprintf(fff,"%sbase",temp_node->y->name+1);
	     }
	     else if (temp_node->ytype==CSGJmp) {

		temp_branch=temp_node->y->jump_target;

		fprintf(fff,"[%i]",vmwFindFirstValidLine(temp_branch));

	     }
	     else if (temp_node->ytype==CSGPhi) {

	     }
	     else fprintf(fff,"%s",temp_node->y->name);
          }
	  
	  fprintf(fff,"\t");
	  if (temp_node->jump_target!=NULL) {
	     fprintf(fff,"[%i]",vmwFindFirstValidLine(temp_node->jump_target));
	     fprintf(fff,"\t");
	  }
	  

	  if (temp_node->use!=NULL) {
	     fprintf(fff,"use: %i ",temp_node->use->line_number);
	  }
	  fprintf(fff,"\t");
	  
	  if (temp_node->xLastUse!=NULL) {
	     fprintf(fff,"xlu: %i",temp_node->xLastUse->line_number);
	  }
	  fprintf(fff,"\t");
	  
	  if (temp_node->yLastUse!=NULL) {
	     fprintf(fff,"ylu: %i",temp_node->yLastUse->line_number);
	  }
	  fprintf(fff,"\t");
	  

          fprintf(fff,"\n");

	  if (temp_node==temp_block->last) {
	     done=1;
	  }
	  
	  else {
             temp_node=temp_node->next;
	  }
	  
       } 
      
       temp_block=temp_block->link;
   }
   
}
