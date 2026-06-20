#include <stdio.h>

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"

#include "globals.h"


void vmwAlphaPrintReg(FILE *fff,Node reg) {
   
    if (reg==NULL) {
       fprintf(fff,"ERROR! Null register!\n");
       return;
    }
   
	
    if (reg->reg<0) {
       if (reg->mode==CSGConst) {
	  fprintf(fff,"%i",reg->val);
       }
       else if (reg->mode==CSGInstr) {
	  fprintf(fff,"(%i)",reg->line_number);
       }
       else if (reg->mode==CSGFld) {
	  fprintf(fff,"%soffs",reg->name);
       }
       else if (reg->mode==CSGPtr) {
	  fprintf(fff,"%sbase",reg->name+1);
       }
       else if (reg->mode==CSGVar) {
	  fprintf(fff,"%s^%i",reg->master->name,reg->current->line_number);
       }
       else if (reg->mode==CSGJmp) {
	  fprintf(fff,"BB%i",reg->jump_target->num);		       
       }
       else {
	  if (reg->master->mode==CSGVar) {
	     fprintf(fff,"%s^%i",reg->master->name,reg->current->line_number);
	  }
	  else {
             fprintf(fff,"%s",reg->name);	    
	  }
	  
       }
       
    }
    else {
       fprintf(fff,"$%i",reg->reg);
    }
   
	
	
   
	
   
}
