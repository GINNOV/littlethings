
void vmwAlphaPrintReg(FILE *fff,Node reg) {
   
    if (reg==NULL) {
       fprintf(fff,"ERROR! Null register!\n");
       return;
    }
   
	
    if (reg->reg<0) {
       if (reg->mode==CSGConst) {
	  fprintf(fff,"%lli",reg->val);
       }
       else if (reg->mode==CSGInstr) {
	  fprintf(fff,"(%lli)",reg->line_number);
       }
       else if (reg->mode==CSGFld) {
	  fprintf(fff,"%soffs",reg->name);
       }
       else if (reg->mode==CSGPtr) {
	  fprintf(fff,"%sbase",reg->name+1);
       }
       else if (reg->mode==CSGVar) {
	  fprintf(fff,"%s^%lli",reg->master->name,reg->current->line_number);
       }
       else if (reg->mode==CSGJmp) {
	  fprintf(fff,"BB%lli",reg->jump_target->num);		       
       }
       else {
	  if (reg->master->mode==CSGVar) {
	     fprintf(fff,"%s^%lli",reg->master->name,reg->current->line_number);
	  }
	  else {
             fprintf(fff,"%s",reg->name);	    
	  }
	  
       }
       
    }
    else {
       fprintf(fff,"$%lli",reg->reg);
    }
   
	
	
   
	
   
}


void vmwAlphaOpType(FILE *fff,Node ra,Node rb,Node rc) {
   

    fprintf(fff,"\t");
    vmwAlphaPrintReg(fff,ra);
    fprintf(fff,",");
    vmwAlphaPrintReg(fff,rb);
    fprintf(fff,",");
    vmwAlphaPrintReg(fff,rc);
}

void vmwAlphaMemType(FILE *fff,Node ra, Node rb, long disp) {
    fprintf(fff,"\t");
    vmwAlphaPrintReg(fff,ra);
    fprintf(fff,",%lli(",disp);
    vmwAlphaPrintReg(fff,rb);
    fprintf(fff,")");
}

   

void vmwAlphaTwoType(FILE *fff,Node ra,Node rb) {
   

    fprintf(fff,"\t");
    vmwAlphaPrintReg(fff,ra);
    fprintf(fff,",");
    vmwAlphaPrintReg(fff,rb);

}

   

void vmwDumpAlpha(FILE *fff) {

   Node temp_node;
   Block temp_block;

   int done=0;
   
  
   temp_block=root_block;

   
   while(temp_block!=NULL) {
       fprintf(fff,"# *** block %lli",temp_block->num);
       fprintf(fff,"  fail ");
       if (temp_block->fail!=NULL) fprintf(fff,"%lli",temp_block->fail->num);
       else fprintf(fff,"-");
      
       fprintf(fff,"  branch ");
       if (temp_block->branch!=NULL) fprintf(fff,"%lli",temp_block->branch->num);
       else fprintf(fff,"-");
 
       fprintf(fff,"  rdom ");
       if (temp_block->rdom!=NULL) fprintf(fff,"%lli",temp_block->rdom->num);
       else fprintf(fff,"-");
      
       fprintf(fff,"  dsc ");
       if (temp_block->dsc!=NULL) fprintf(fff,"%lli",temp_block->dsc->num);
       else fprintf(fff,"-");
      
       fprintf(fff,"  next ");
       if (temp_block->next!=NULL) fprintf(fff,"%lli",temp_block->next->num);
       else fprintf(fff,"-");

       fprintf(fff,"  link ");
       if (temp_block->link!=NULL) fprintf(fff,"%lli",temp_block->link->num);
       else fprintf(fff,"-");

       fprintf(fff,"  Type: ");
       switch(temp_block->kind) {
	case blockDefault: fprintf(fff,"Default!"); break;
	case blockIf: fprintf(fff,"If!");break;
	case blockThen: fprintf(fff,"Then!");break;
	case blockElse: fprintf(fff,"Else!");break;
	case blockIfJoin: fprintf(fff,"If Join!");break;
	case blockWhileHead: fprintf(fff,"WhileHead!");break;
	case blockWhileBody: fprintf(fff,"WhileBody!");break;
	case blockWhileJoin: fprintf(fff,"WhileJoin!");break;
	case blockProc: fprintf(fff,"BlockProc!");break;
	case blockReturnProc: fprintf(fff,"ReturnFromProc!");break;
	default: fprintf(fff,"Unknown!");break;
       }
   
      
       fprintf(fff,"\n");
       fprintf(fff,"BB%lli:\n",temp_block->num);

       temp_node=temp_block->first;
       done=0;
       while((!done) && (temp_node!=NULL)) {

	  if (!temp_node->deleted) {
	       
	     fprintf(fff,"\t");

	     switch(temp_node->op) {
                case vmwNeg: fprintf(fff,"negq"); 
		             vmwAlphaTwoType(fff,temp_node->x,temp_node);
		             break;
                case vmwAdd: fprintf(fff,"addq"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		             break;
                case vmwSub: fprintf(fff,"subq"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		             break;
                case vmwMul: fprintf(fff,"mulq"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		             break;
                case vmwDiv: fprintf(fff,"DIVQ"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		             break;
                case vmwMod: fprintf(fff,"MODQ"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		             break;
	        case vmwLshift: fprintf(fff,"sll"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		             break;
	        case vmwRshift: fprintf(fff,"sra"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		             break;
	        case vmwAnd: fprintf(fff,"and"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		             break;
	        case vmwOr: fprintf(fff,"bis"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		            break;
	        case vmwXor: fprintf(fff,"xor"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		            break;
                case vmwAdda: fprintf(fff,"lda"); 
			     vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		            break;
                case vmwLoad: fprintf(fff,"ldq"); 
			     vmwAlphaMemType(fff,temp_node,temp_node->x,0);		
		            break;
                case vmwStore: fprintf(fff,"stq"); 
			     vmwAlphaMemType(fff,temp_node->x,temp_node->y,0);		
		            break;
                case vmwMove: fprintf(fff,"mov"); 
		              vmwAlphaTwoType(fff,temp_node->x,temp_node->y);
		              break;
                case vmwParam: fprintf(fff,"PARAM\t"); 
		              vmwAlphaPrintReg(fff,temp_node->x);
		              break;
                case vmwCmpeq: fprintf(fff,"cmpeq"); 
			      vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		              break;
                case vmwCmplt: fprintf(fff,"cmplt"); 
			      vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		              break;
                case vmwCmple: fprintf(fff,"cmple"); 
			      vmwAlphaOpType(fff,temp_node->x,temp_node->y,temp_node);
		              break;
                case vmwBlbs: fprintf(fff,"blbs"); 
		              vmwAlphaTwoType(fff,temp_node->x,temp_node->y);
		              break;
                case vmwBlbc: fprintf(fff,"blbc"); 
			      vmwAlphaTwoType(fff,temp_node->x,temp_node->y);
		              break;
                case vmwBsr: fprintf(fff,"bsr\t"); 
		              vmwAlphaPrintReg(fff,temp_node->x);
		             break;
                case vmwBr: fprintf(fff,"br\t");
		            vmwAlphaPrintReg(fff,temp_node->x);
		            break;
                case vmwRet: fprintf(fff,"ret"); break;
                case vmwRead: fprintf(fff,"READ\t"); 
		              vmwAlphaPrintReg(fff,temp_node);
		              break;
                case vmwWrite: fprintf(fff,"WRITE\t"); 
		               vmwAlphaPrintReg(fff,temp_node->x);
		              break;
                case vmwWrl: fprintf(fff,"WRL"); break;
                case vmwHCF: fprintf(fff,"END"); break;   
                default: fprintf(fff,"EIEIO"); break;
	     }
	     
             fprintf(fff,"\n");
	  }
	  

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


   
   
