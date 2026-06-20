#include <stdio.h>
#include <string.h>

#include "node.h"
#include "type.h"
#include "block.h"

#include "scanner.h"

#include "enums.h"
#include "globals.h"

#define MAX_PARAMS 5

#define DESTINATION 0
#define SOURCE1     1
#define SOURCE2     2

static int reg_table[32],reg_count;
static int stack_local_size;

static void handle_spill_before(FILE *fff,int reg,int location,int spill_offset) {
   if (reg>=reg_count) {
      if (location==SOURCE1) {  
         fprintf(fff,"\tlwz\t9,%i(1)\n",spill_offset+(4*(reg-reg_count)));
      }
      if (location==SOURCE2) {  
         fprintf(fff,"\tlwz\t10,%i(1)\n",spill_offset+(4*(reg-reg_count)));
      }
   }
   

}


static void handle_spill_after(FILE *fff,int reg,int spill_offset) {

   if (reg>=reg_count) {
      fprintf(fff,"\tstw\t8,%i(1)\n",spill_offset+(4*(reg-reg_count)));
   }	
}

   
   

static int which_register(int reg,int location) {

   if (reg<0) {
      return -1;
      printf("Reg %i ",reg);
      vmwError("Out Of Bound!\n");
   }
   
   if (reg>=reg_count) {
      
      if (location==0) return 8;
      if (location==1) return 9;
      if (location==2) return 10;
      vmwError("reg SPILL!\n");
   }
   
   return reg_table[reg];
}


static void vmwPPCPrintReg(FILE *fff,Node reg) {
   
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
       fprintf(fff,"$%i",which_register(reg->reg,DESTINATION));
    }   
}


   

static void vmwPPCLoadConst(int dest_reg,int val,FILE *fff) {

   if ((val<32767) && (val>-32768)) {	
      fprintf(fff,"\tli\t%i,%i\t\t# Move %i into r%i\n",dest_reg,val,val,dest_reg);
   }
   
   else {
      fprintf(fff,"\t# Loading constant %i into r%i\n",val,dest_reg);
      fprintf(fff,"\tlis\t%i,%i\t\t# Load high 16 bits\n",
	      dest_reg,(val>>16)&0xffff);
      fprintf(fff,"\tori\t%i,%i,%i\t\t# Add in low 16 bits\n",
	      dest_reg,dest_reg,val&0xffff);
      
   }
   
	
	
   
}

static void vmwPPCMoveReg(int dest_reg,int src_reg, FILE *fff) {
   
   fprintf(fff,"\tmr\t%i,%i\t\t# Move r%i -> r%i\n",dest_reg,src_reg,src_reg,dest_reg);
}


static void vmwPPCMod(FILE *fff) {
   
    fprintf(fff,"\n\t#===================\n");
    fprintf(fff,"\t# vmw_mod        \n");
    fprintf(fff,"\t#===================\n");
    fprintf(fff,"\t# Writes a linefeed to stdout\n\n");
    fprintf(fff,"__mod:\n");  
   
    fprintf(fff,"\tdivw   13,4,3\n");
    fprintf(fff,"\tmullw  13,3,13\n");
    fprintf(fff,"\tsubf   3,13,4\n");

    fprintf(fff,"\tblr\t\t\t# Return\n\n");
}


static void vmwPPCWriteLine(FILE *fff) {
   
    fprintf(fff,"\n\t#===================\n");
    fprintf(fff,"\t# write_line        \n");
    fprintf(fff,"\t#===================\n");
    fprintf(fff,"\t# Writes a linefeed to stdout\n\n");
    fprintf(fff,"write_line:\n");  
    fprintf(fff,"\taddi\t1,1,-4\t\t# Allocate space on stack\n");
    fprintf(fff,"\tlis\t3,0x0a00\t# Move linefeed into r3\n");
    fprintf(fff,"\tstw\t3,0(1)\t\t# Store linefeed onto stack\n");
    fprintf(fff,"\tmr\t4,1\t\t# Point r4 to linefeed\n");
    fprintf(fff,"\tli\t0,4\t\t# put write syscall(4) into r0\n");
    fprintf(fff,"\tli\t3,1\t\t# put stdout into r3\n");
    fprintf(fff,"\tli\t5,1\t\t# print one character\n");
    fprintf(fff,"\tsc\t\t\t# Do syscall\n");
    fprintf(fff,"\taddi\t1,1,4\t\t# Restore stack\n");
    fprintf(fff,"\tblr\t\t\t# Return\n\n");
}

static void vmwPPCWriteLong(FILE *fff) {
   
    fprintf(fff,"\n\t#===================\n");
    fprintf(fff,"\t# write_long        \n");
    fprintf(fff,"\t#===================\n");
    fprintf(fff,"\t# Writes a signed integer to stdout\n\n");
    fprintf(fff,"write_long:\n");
    fprintf(fff,"\taddi\t1,1,-16\t\t# Allocate space on stack\n");
    fprintf(fff,"\tmr\t4,1\t\t# Copy stack pointer to r4\n");
    fprintf(fff,"\tmr\t8,3\t\t# Copy value we are printing to r8\n");
    fprintf(fff,"\tli\t10,10\t\t# load 10 into r10\n");
    fprintf(fff,"\tli\t5,1\t\t# load the count variable\n");
    fprintf(fff,"\tcmpwi\t3,0\t\t# Is the value we are dividing <0 ?\n");
    fprintf(fff,"\tbge\tdiv_by_10\t# If not skip ahead\n");	
    fprintf(fff,"\tneg\t3,3\t\t# If negative we want to print the 2s complement\n");	
    fprintf(fff,"div_by_10:\n");
    fprintf(fff,"\tdivw\t6,3,10\t\t# divide r3 by 10 and put result into r6\n");	
    fprintf(fff,"\tmullw\t7,6,10\t\t# find remainder.  1st q*dividend\n");
    fprintf(fff,"\tsubf\t7,7,3\t\t# then subtract from original = R\n");
    fprintf(fff,"\taddi\t7,7,0x30\t# convert remainder to ascii\n");	
    fprintf(fff,"\tstbu\t7,-1(4)\t\t# Store to backwards buffer\n");
    fprintf(fff,"\tmr\t3,6\t\t# move Quotient as new dividend\n");
    fprintf(fff,"\taddi\t5,5,1\t\t# Update length info\n");
    fprintf(fff,"\tcmpwi\t6,0\t\t# was quotient zero?\n");
    fprintf(fff,"\tbne\tdiv_by_10\t# if not keep dividing\n");
    fprintf(fff,"\tcmpwi\t8,0\t\t# was the original negative?\n");
    fprintf(fff,"\tbge\twrite_out\t# if not skip ahead\n");	
    fprintf(fff,"\taddi\t5,5,1\t\t# Adding an extra char\n");
    fprintf(fff,"\tli\t7,'-'\t\t# It's a minus sign\n");
    fprintf(fff,"\tstbu\t7,-1(4)\t\t# Store it with the rest\n");
    fprintf(fff,"write_out:\n");   
    fprintf(fff,"\tli\t7,' '\t\t# Load a space into r7\n");
    fprintf(fff,"\tstbu\t7,-1(4)\t\t# Save space to end of our buffer\n");	
    fprintf(fff,"\tli\t0,4\t\t# put write syscall(4) into r0\n");
    fprintf(fff,"\tli\t3,1\t\t# write to stdout(1)\n");
    fprintf(fff,"\tsc\t\t\t# syscall\n");
    fprintf(fff,"\taddi\t1,1,16\t\t# Restore stack\n");	
    fprintf(fff,"\tblr\t\t\t# return from subroutine\n\n");   
}

static void vmwPPCReadLong(FILE *fff) {
    
    fprintf(fff,"\t#===================\n");
    fprintf(fff,"\t# read_long\n");
    fprintf(fff,"\t#===================\n");
    fprintf(fff,"\t# Reads a signed integer\n");
    fprintf(fff,"\t# WARNING!  Does not check for errors\n\n");
    fprintf(fff,"read_long:\n");
    fprintf(fff,"\taddi\t1,1,-16\t\t# Allocate space on stack\n");
    fprintf(fff,"\tmr\t4,1\t\t# move buff pointer to stack\n");
    fprintf(fff,"\tli\t8,0\t\t# clear result\n");
    fprintf(fff,"\tli\t7,0\t\t# clear negative flag\n\n");
    fprintf(fff,"read_loop:\n");	
    fprintf(fff,"\tstw\t4,4(1)\t# reg 4-8 Caller saved?\n");
    fprintf(fff,"\tstw\t8,8(1)\n");
    fprintf(fff,"\tstw\t7,12(1)\n");
    fprintf(fff,"\tli\t3,0\t\t# STDIN = 0\n");
    fprintf(fff,"\tli\t0,3\t\t# read syscall (3)\n");
    fprintf(fff,"\tli\t5,1\t\t# We want 1 char\n"); 
    fprintf(fff,"\tsc\t\t\t# call the syscall\n");
    fprintf(fff,"\tlwz\t7,12(1)\t# Restore syscall trashed regs\n");
    fprintf(fff,"\tlwz\t4,4(1)\n");
    fprintf(fff,"\tlwz\t8,8(1)\n");	 
    fprintf(fff,"\tlbz\t6,0(4)\t\t# load in byte we read\n\n");
    fprintf(fff,"\tcmpwi\t6,'\\n'\t\t# are we a linefeed?\n");
    fprintf(fff,"\tbeq\tread_done\t\t# if so, we are done\n\n");
    fprintf(fff,"check_minus:\n");
    fprintf(fff,"\tcmpwi\t6,'-'\t\t# are we \"minus\"\n");
    fprintf(fff,"\tbne\tnot_minus\t\t# if not we are a number\n");
    fprintf(fff,"\tli\t7,1\t\t# set negative flag\n");
    fprintf(fff,"\tb\tread_loop\n\n");
    fprintf(fff,"not_minus:\n");
    fprintf(fff,"\tsubi\t6,6,0x30\t\t# convert from ASCII\n");
    fprintf(fff,"\tmulli\t8,8,10\t\t# multiply value by 10\n");
    fprintf(fff,"\tadd\t8,8,6\t\t# add in new digit\n");
    fprintf(fff,"\tb	read_loop\n\n");
    fprintf(fff,"read_done:\n");
    fprintf(fff,"\tcmpwi\t7,1\t\t# are we negative\n");
    fprintf(fff,"\tbne\tread_result\t\t# if not move ahead\n");
    fprintf(fff,"\tneg\t8,8\t\t# negate our value\n\n");	
    fprintf(fff,"read_result:\n");
    fprintf(fff,"\tmr\t3,8\t\t# move to return value\n");
    fprintf(fff,"\taddi\t1,1,16\t\t# restore stack\n");
    fprintf(fff,"\tblr\t\t\t# return\n\n");
	
}

   

static void vmwPPCarithmetic(char *regular, char *immediate,Node instr,FILE *fff) {
   
    int result=0; 	
    Node x,y;
   
    x=instr->x; 
    y=instr->y;
   
    if (instr->reg==-1) fprintf(fff,"# ");
   
    if (x->mode==CSGConst) {
          /* Both constants!  Unpossible! */
       if (y->mode==CSGConst) {
          
	  if (instr->op==vmwAdd) result=x->val+y->val;
	  if (instr->op==vmwSub) result=x->val-y->val;
	  if (instr->op==vmwMul) result=x->val*y->val;
	  if (instr->op==vmwRshift) result=x->val>>y->val;
	  if (instr->op==vmwAnd) result=x->val & y->val;
	  if (instr->op==vmwOr) result=x->val | y->val;
	  if (instr->op==vmwXor) result=x->val ^ y->val;
	  vmwPPCLoadConst( which_register(instr->reg,DESTINATION),result,fff);
	  return;
       }
         /* X = constant, y isn't */
       else {
	     /* Communative ops */
	  if ((instr->op==vmwAdd) || 
	      (instr->op==vmwMul) || 
	      (instr->op==vmwAnd)) {
	       
//	     printf("Switching %i\n",x->val);
	     x=instr->y;
	     y=instr->x;
	  }
	  else if (instr->op==vmwSub) {
	     x=instr->y;
	     y=instr->x;
	     y->val=-y->val;
	     instr->x=x;
	     instr->y=y;
	     vmwPPCarithmetic("add","addi",instr,fff);
	     handle_spill_before(fff,instr->reg,SOURCE1,stack_local_size);
	     fprintf(fff,"\tneg\t%i,%i\n",which_register(instr->reg,DESTINATION),
		                      which_register(instr->reg,SOURCE1));
	     handle_spill_after(fff,instr->reg,stack_local_size);
	     /* hack, return value to prev especially if constnat */
	     y=instr->y;
	     x=instr->x;
	     y->val=-y->val;
	     instr->y=x;
	     instr->x=y;
	     return;
	  }
	  
	       
          else vmwError("Cannot have add x=const\n");
       }

    }
   
    if ((y->mode==CSGConst) || (y->mode==CSGFld) ){
       if ((y->val>32767)||(y->val<-32768)) {
	  vmwPPCLoadConst(13,y->val,fff);
	  handle_spill_before(fff,x->reg,SOURCE1,stack_local_size);
	  fprintf(fff,"\t%s\t%i,%i,%i\t\t",regular,
		  which_register(instr->reg,DESTINATION),
		  which_register(x->reg,SOURCE1),13);
	  handle_spill_after(fff,instr->reg,stack_local_size);

       }
       else {
	  handle_spill_before(fff,x->reg,SOURCE1,stack_local_size);
          fprintf(fff,"\t%s\t%i,%i,%i\t\t",immediate,
		  which_register(instr->reg,DESTINATION),
		                 which_register(x->reg,SOURCE1),
				                             y->val);
	  handle_spill_after(fff,instr->reg,stack_local_size);

       }  
       	  if (y->mode==CSGFld) fprintf(fff,"# Field offset");
         fprintf(fff,"\n");
    }
    else {
       if (instr->op!=vmwSub) {
	  handle_spill_before(fff,x->reg,SOURCE1,stack_local_size);
	  handle_spill_before(fff,y->reg,SOURCE2,stack_local_size);
	  fprintf(fff,"\t%s\t%i,%i,%i\t\t",regular,
				      which_register(instr->reg,DESTINATION),
				      which_register(x->reg,SOURCE1),
			              which_register(y->reg,SOURCE2));
	  	         fprintf(fff,"\n");
	  	     handle_spill_after(fff,instr->reg,stack_local_size);
       }
       
       else {
	  handle_spill_before(fff,y->reg,SOURCE1,stack_local_size);
	  handle_spill_before(fff,x->reg,SOURCE2,stack_local_size);
	  fprintf(fff,"\t%s\t%i,%i,%i\t\t",regular,
		    which_register(instr->reg,DESTINATION),
		    which_register(y->reg,SOURCE1),
		    which_register(x->reg,SOURCE2));
	         fprintf(fff,"\n");
	  handle_spill_after(fff,instr->reg,stack_local_size);

       }
       
	 

    }
}

static void vmwPPCbranch(char *opcode, Node instr, FILE *fff) {
   

    if (instr->x->mode==CSGConst) {
       if (instr->y->mode==CSGConst) {
	  
	  if ( ((instr->op==vmwBeq) && (instr->x->val==instr->y->val))  ||
	       ((instr->op==vmwBneq) && (instr->x->val!=instr->y->val)) ||
	       ((instr->op==vmwBgt) && (instr->x->val<instr->y->val))   ||
	       ((instr->op==vmwBlt) && (instr->x->val>instr->y->val))   ||
	       ((instr->op==vmwBge) && (instr->x->val>=instr->y->val))  ||
	       ((instr->op==vmwBle) && (instr->x->val<=instr->y->val))    ) {
	     
	     fprintf(fff,"\tb\tBB%i\t\t# Forcing branch due to %s %i %i\n",
		     instr->jump_target->num,opcode,instr->x->val,instr->y->val);
	       
	    }
	  
	  else 
	    {
	       fprintf(fff,"\t# Uneccesary compare (%s %i %i) deleted!\n",
		       opcode,instr->x->val,instr->y->val);
	    }
	  
	  
	  
	  
       }
       
       else {
          vmwError("Can't compare x=const");
       }
       return;
       
    }
    else

    
    if (instr->y->mode==CSGConst) {
       if (instr->y->val<65536) {
	  handle_spill_before(fff,instr->x->reg,SOURCE1,stack_local_size);
          fprintf(fff,"\tcmpi\t0,%i,%i\t\t",
		  which_register(instr->x->reg,SOURCE1),
		  instr->y->val);
          fprintf(fff,"\n");
       }
       else {
          vmwPPCLoadConst(13,instr->y->val,fff);
	  handle_spill_before(fff,instr->x->reg,SOURCE1,stack_local_size);
          fprintf(fff,"\tcmp\t0,%i,13\t\t",
		  which_register(instr->x->reg,SOURCE1));
          fprintf(fff,"\n");
       }       
    }
    else {
       handle_spill_before(fff,instr->x->reg,SOURCE1,stack_local_size);
       handle_spill_before(fff,instr->y->reg,SOURCE2,stack_local_size);
       fprintf(fff,"\tcmp\t0,%i,%i\t\t",
	       which_register(instr->x->reg,SOURCE1),
	       which_register(instr->y->reg,SOURCE2));
       fprintf(fff,"\n");
    }
   
    if (instr->jump_target==NULL) vmwError("Missing Jump Target!");
    fprintf(fff,"\t%s\tBB%i\n",opcode,instr->jump_target->num);
}



   





void vmwDumpPPC(FILE *fff) {

    Node temp_node;
    Block temp_block;

    int done=0,y_reg,i,j,param_num=0,used_reg_mask=0x7fff0000,mask_count=0;
    int temp_param_reg=0,bss_offset=0;

    int writelong_used=0,readlong_used=0,writeline_used=0,mod_used=0;
  
    int reg_mask,reg_first=0,total_regs=0;
    int spill_regs=0;

    char current_fname[BUFSIZ];
   
    temp_block=root_block;
   
   
    /* REGMASK */
   /*
   Register        Usage                CALLEE SAVE
      r0            prolog/epilog           NO
      r1            stack pointer           YES
      r2            TOC pointer (reserved)  YES
      r3-r4         1/2 para and return     NO
      r5-r10        3-8th para              NO
      r11-r12       Func Linkage reg        NO
      r12           Used by global linkage  NO
      r13           Small data area pointer NO     13=TEMP
      r14-r30       General Int registers   YES    14=BSS 15= 
      r31           Global Environment Ptr  YES
     */
   
    reg_mask=0x7fff0000;

    while( !((1<<reg_first)&reg_mask)) {
       reg_first++;
       if (reg_first> BITNESS) vmwError("Can't find first open reg!\n");
    }   
   
    i=0;
    reg_count=0;
    while ( i<32) {
       if ((1<<i)&reg_mask) {
          reg_table[reg_count]=i;
          reg_count++;
       }
       i++;
    }
   
//    printf("First Register=%i\n",reg_first);
//    printf("Total Registers=%i\n",reg_count);
//    for(i=0;i<reg_count;i++) printf("\t%i=r%i\n",i,reg_table[i]);

   
    /* Calculate BSS offsets */
    temp_node=globscope;
    while(temp_node!=NULL) {
       if ((temp_node->mode==CSGVar) && 
	   (temp_node->lev==0)) {// &&
//	   ((temp_node->type->form==CSGArray) ||
//	    (temp_node->type->form==CSGStruct))) {// && (temp_node->used)) {
	  temp_node->bss_offset=bss_offset;
	  fprintf(fff,"# bss offset of %s is %i\n",temp_node->name,bss_offset); 
          bss_offset+=temp_node->type->size;
       }
       temp_node=temp_node->next;
    }
   
   
   
    while(temp_block!=NULL) {
     
       fprintf(fff,"# *** block %i",temp_block->num);
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
       fprintf(fff,"BB%i:\n",temp_block->num);

       
       /* If procedure, do some stuff */       
       if (temp_block->kind==blockProc) {
	  
	     /* Only a prototype, so external function... */
	  if (temp_block->prototype) {
	     fprintf(fff,".globl %s\n",temp_block->vars->name);
	  }
	  
	  else {
	  fprintf(fff,"\n%s:\n\n",temp_block->vars->name);
	     if(!strncmp(temp_block->vars->name,"main",5))
	       	  fprintf(fff,".globl %s\n",temp_block->vars->name);
	     
             if (!temp_block->entry) {
	  
	  Node blargh;
	  int num_params=0,temp_reg=0;
	  
	  param_num=0;
	  temp_param_reg=0;
	  

	  
	  blargh=temp_block->vars;
	  while(blargh->next!=NULL) {
	     if ((blargh->parameter) && (blargh->block==temp_block)) {
		fprintf(fff,"# Parameter %i = %s\n",num_params,blargh->master->name);
		num_params++;
	     }
	     
	     blargh=blargh->next;
	  }

	  mask_count=0;
	  for(i=0;i<32;i++) {
	     if (used_reg_mask & (1<<i)) mask_count++;
	  }     
	  
	  fprintf(fff,"\taddi\t1,1,-%i\t\t# Allocate space on stack\n",4+(mask_count*4));
	  fprintf(fff,"\tmflr\t13\t\t# Move link register into r13\n");
	  fprintf(fff,"\tstw\t13,0(1)\t\t# Store link register onto stack\n\n");
	  fprintf(fff,"\t# Backup regs we use\n");
	  j=0;
	  for(i=0;i<32;i++) {
	     if (used_reg_mask & (1<<i)) {
		fprintf(fff,"\tstw\t%i,%i(1)\t\t#\n",i,4+(j*4));
		j++;
	     }
	     
	  }
	  

	  
	  total_regs=0;
	  blargh=temp_block->vars;
	  while(blargh->next!=NULL) {
	     if ((blargh->parameter) && (blargh->block==temp_block)) {
		total_regs++;
	     }
	 
	     blargh=blargh->next;
	  }

	       
	  
	  fprintf(fff,"\t\t# Move %i params into proper registers\n",total_regs);

	  temp_reg=0;
	  blargh=temp_block->vars;
	  while(blargh->next!=NULL) {
	     if ((blargh->parameter) && (blargh->block==temp_block)) {
		
		if (temp_reg<MAX_PARAMS) {
		     
	           fprintf(fff,"\tmr\t%i,%i\t# %s\n",
			which_register(blargh->reg,DESTINATION),
			temp_reg+3,blargh->master->name);
		   	handle_spill_after(fff,blargh->reg,stack_local_size);
		}
		
		  /* We are on the stack BACKWARDS */
		  /* FIXME */
		else {
		   fprintf(fff,"\tlwz\t%i,%i(1)\t# %s\n",
			   which_register(blargh->reg,DESTINATION),
			   64+(4* ((total_regs-MAX_PARAMS-1)-
				   (temp_reg-MAX_PARAMS))),
			   blargh->master->name);
		   	  handle_spill_after(fff,blargh->reg,stack_local_size);
		}
		
		temp_reg++;
	     }
	     blargh=blargh->next;
	  }

	  fprintf(fff,"\n");
	     }
       

       
       /* Handle local vars on the stack */


	  sprintf(current_fname,"BB%i",temp_block->num);
	  
	  /* Handle register spill */
	  fprintf(fff,"# Registers used by this proc: %i, Regs available: %i\n",
		  temp_block->regs_used,reg_count);
	  if (temp_block->regs_used>=reg_count) {
	     spill_regs=temp_block->regs_used-reg_count;
	     fprintf(fff,"\taddi\t1,1,-%i\t\t# Allocate room for %i reg spill\n",
		  spill_regs*4,spill_regs);	  
	  }
	  else {
	     spill_regs=0;
	  }

	  
	  fprintf(fff,"# Scanning for vars in level %i\n",temp_block->level);
          temp_node=globscope;
          while(temp_node!=NULL) {

             if ((temp_node->mode==CSGVar) && 
	         (temp_node->lev==temp_block->level) &&
		 ((temp_node->type->form==CSGArray) ||
	          (temp_node->type->form==CSGStruct))) {
		fprintf(fff,"# Found %s Size %i\n",temp_node->name,
			temp_node->type->size);
		temp_node->bss_offset=stack_local_size;
		stack_local_size+=temp_node->type->size;
		

	     }
	     

             temp_node=temp_node->next;
	  }
	  
          if (stack_local_size!=0) {
	     fprintf(fff,"\taddi\t1,1,-%i\t\t# Allocate %i bytes on stack for local vars\n",
		  stack_local_size,stack_local_size);	  
          }	  

	  	  
	       
	       

	  
	  }
	  
          /* If entry point, handle it */
       if (temp_block->entry) {
	  param_num=0;
	  	  fprintf(fff,".align 2\n");
	  fprintf(fff,".globl _start\n");
	  fprintf(fff,"_start:\n\n");

	  fprintf(fff,"\tlis\t14,__bss_begin@ha\t\t# Load BSS into r14\n");
	  fprintf(fff,"\taddi\t14,14,__bss_begin@l\n");
	    
       }
    }
       
       

       
	    
    
      
	   
      
      
       temp_node=temp_block->first;
       done=0;
       while((!done) && (temp_node!=NULL)) {

	  if (!temp_node->deleted) {
	       
	     switch(temp_node->op) {
                case vmwNeg: 
		     handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		     fprintf(fff,"\tneg\t%i,%i\t\t",
			     which_register(temp_node->reg,DESTINATION),
			     which_register(temp_node->x->reg,SOURCE1)); 
		     fprintf(fff,"\n");        
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
		     break;
		
		case vmwNot: 
		     handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		     fprintf(fff,"\tnot\t%i,%i\t\t",
			     which_register(temp_node->reg,DESTINATION),
			     which_register(temp_node->x->reg,SOURCE1)); 
		     fprintf(fff,"\n");        
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
		     break;
		
		case vmwBoolnot: 
		     handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		     fprintf(fff,"\tcmpwi\t7,%i,0\t\t# Check if int is zero\n",
			     	 which_register(temp_node->x->reg,SOURCE1));
		     fprintf(fff,"\tmfcr\t%i\t\t# Copy condition registers\n",
			     which_register(temp_node->reg,DESTINATION));
		     fprintf(fff,"\trlwinm\t%i,%i,31,1\t#Shift and mask to see if result was 0\n",
		     			     which_register(temp_node->reg,DESTINATION),
					     which_register(temp_node->reg,DESTINATION));
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
		     break;
		
	        case vmwAdda:
                case vmwAdd:

		
		        /* If x is a CSGPtr */
		     if (temp_node->x->mode==CSGPtr) {

                           /* Handle things in the data segment */
			if (temp_node->x->current->initial_data) {
				 
			   if (temp_node->y==GP) {
				
			   fprintf(fff,"\tlis\t%i,%s@ha\n",
				      which_register(temp_node->reg,DESTINATION),
				      temp_node->x->current->name);
			   fprintf(fff,"\taddi\t%i,%i,%s@l\n",
				      which_register(temp_node->reg,DESTINATION),
				      which_register(temp_node->reg,DESTINATION), 
				      temp_node->x->current->name);
			   
				 
			   handle_spill_after(fff,temp_node->reg,stack_local_size);
			   }
			   
			   else {
			   fprintf(fff,"\tlis\t%i,_l%i_%s@ha\n",

				      which_register(temp_node->reg,DESTINATION),
				   				      temp_node->x->current->lev,
				      temp_node->x->current->name);
			   fprintf(fff,"\taddi\t%i,%i,_l%i_%s@l\n",

				      which_register(temp_node->reg,DESTINATION),
				      which_register(temp_node->reg,DESTINATION), 
				   				   				      temp_node->x->current->lev,

				      temp_node->x->current->name);
			   
				 
			   handle_spill_after(fff,temp_node->reg,stack_local_size);
			      
			   }
			   
			}
			

			else {
			
			     
			
			   /* If bss_offset is too big for immediate */
			   /* Load into Register 13                  */
			   if (temp_node->x->current->bss_offset>32768) {
	   		      vmwPPCLoadConst(13,
					   temp_node->x->current->bss_offset,
		                           fff);
			      if (temp_node->y==GP) {
				
			  
			         fprintf(fff,"\tadd\t%i,14,13",
				      which_register(temp_node->reg,DESTINATION));
			   
			         fprintf(fff,"\t# (%s - __bss_begin) \n",
				      (temp_node->x->name)+1);
			      	  handle_spill_after(fff,temp_node->reg,stack_local_size);
			      }
			      
			   
			      
			   
			   
			      else {
			         fprintf(fff,"\tadd\t%i,1,13",
				      which_register(temp_node->reg,DESTINATION));
			   
			         fprintf(fff,"\t# (%s on stack) \n",
				      (temp_node->x->name)+1);
			      	  handle_spill_after(fff,temp_node->reg,stack_local_size);
			      }
			   }
			   
			   
			
			
			   else {
			      if (temp_node->y==GP) {
				
			         fprintf(fff,"\taddi\t%i,14,%i"
				    "\t\t# Offset of %s in bss\n",
				    which_register(temp_node->reg,DESTINATION),
				    temp_node->x->current->bss_offset,
				    temp_node->x->name);
			      	  handle_spill_after(fff,temp_node->reg,stack_local_size);
			      }
			      
			      else {
			         fprintf(fff,"\taddi\t%i,1,%i"
				    "\t# Offset of %s\n",
				    which_register(temp_node->reg,DESTINATION),
				    temp_node->x->bss_offset,
				    temp_node->x->name);
				  handle_spill_after(fff,temp_node->reg,stack_local_size);
			      }
			      
			   }
			   
			}
			
		     }
		
			
		
		     else {		  		
		        vmwPPCarithmetic("add","addi",temp_node,fff);
		     }
		
		     break;
		
	        case vmwSub:
		     vmwPPCarithmetic("subf","subi",temp_node,fff);
		     break;

                case vmwMul:
		     vmwPPCarithmetic("mullw","mulli",temp_node,fff);
		     break;
		
                case vmwDiv: 
		     if (temp_node->x->mode==CSGConst) {
			if (temp_node->y->mode==CSGConst) {
	                   vmwPPCLoadConst(which_register(temp_node->reg,DESTINATION),
					   temp_node->x->val/temp_node->y->val,fff);
			   	  handle_spill_after(fff,temp_node->reg,stack_local_size);
			}
			else vmwError("Can't divide const\n");
		     }
		     else
		     if (temp_node->y->mode==CSGConst) {
			vmwPPCLoadConst(13,temp_node->y->val,fff);
			handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
			fprintf(fff,"\tdivw\t%i,%i,%i\t\t",
				which_register(temp_node->reg,DESTINATION),
				which_register(temp_node->x->reg,SOURCE1),
				                            13);
			fprintf(fff,"\n");
				  handle_spill_after(fff,temp_node->reg,stack_local_size);
		     }
		     else {
			handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
			handle_spill_before(fff,temp_node->y->reg,SOURCE2,stack_local_size);
		         fprintf(fff,"\tdivw\t%i,%i,%i\t\t",
				 which_register(temp_node->reg,DESTINATION),
				 which_register(temp_node->x->reg,SOURCE1),
				 which_register(temp_node->y->reg,SOURCE2));
			 fprintf(fff,"\n");
				  handle_spill_after(fff,temp_node->reg,stack_local_size);
		     }
		     break;
		
                case vmwMod:
		     if (temp_node->x->mode==CSGConst) vmwError("Can't mod const\n");
		     if (temp_node->y->mode==CSGConst) {
		        vmwPPCLoadConst(3,temp_node->y->val,fff);
		     }
		     else {
			handle_spill_before(fff,temp_node->y->reg,SOURCE1,stack_local_size);
			vmwPPCMoveReg(3,which_register(temp_node->y->reg,SOURCE1),fff);
		     }
		     handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		     vmwPPCMoveReg(4,which_register(temp_node->x->reg,SOURCE1),fff);
		     fprintf(fff,"\tbl\t__mod\t# calculate mod\n");
		     vmwPPCMoveReg(which_register(temp_node->reg,DESTINATION),3,fff);
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
		     mod_used++;
		     break;
		
		
	        case vmwLshift: 
		     if (temp_node->x->mode==CSGConst) {
			vmwPPCLoadConst(13,temp_node->x->val,fff);
		     handle_spill_before(fff,temp_node->y->reg,SOURCE2,stack_local_size);
		     fprintf(fff,"\tslw\t%i,%i,%i\t\t",
			     which_register(temp_node->reg,DESTINATION),
			     13,
			     which_register(temp_node->y->reg,SOURCE2));

		     fprintf(fff,"\n");
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
			
			
			break;
		     }
		
		     if (temp_node->y->mode==CSGConst) {
			vmwPPCLoadConst(13,temp_node->y->val,fff);
			y_reg=13;
		     }
		     else {
			handle_spill_before(fff,temp_node->y->reg,SOURCE2,stack_local_size);
			y_reg=which_register(temp_node->y->reg,SOURCE2);
		     }
		     handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		     fprintf(fff,"\tslw\t%i,%i,%i\t\t",
			     which_register(temp_node->reg,DESTINATION),
			     which_register(temp_node->x->reg,SOURCE1),
			                                     y_reg);
		     fprintf(fff,"\n");
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
		     break;
		
		
	        case vmwRshift: 
		     if (temp_node->x->mode==CSGConst) {
			vmwPPCLoadConst(13,temp_node->x->val,fff);
		     handle_spill_before(fff,temp_node->y->reg,SOURCE2,stack_local_size);
		     fprintf(fff,"\tsraw\t%i,%i,%i\t\t",
			     which_register(temp_node->reg,DESTINATION),
			     13,
			     which_register(temp_node->y->reg,SOURCE2));

		     fprintf(fff,"\n");
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
			
			
			break;
		     }
		
		     if (temp_node->y->mode==CSGConst) {
			vmwPPCLoadConst(13,temp_node->y->val,fff);
			y_reg=13;
		     }
		     else {
			handle_spill_before(fff,temp_node->y->reg,SOURCE2,stack_local_size);
			y_reg=which_register(temp_node->y->reg,SOURCE2);
		     }
		     handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		     fprintf(fff,"\tsraw\t%i,%i,%i\t\t",
			     which_register(temp_node->reg,DESTINATION),
			     which_register(temp_node->x->reg,SOURCE1),
			                                     y_reg);
		     fprintf(fff,"\n");
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
		
//		     vmwPPCarithmetic("sraw","srawi",temp_node,fff);		
		     break;
		
	        case vmwAnd:
		     vmwPPCarithmetic("and","andi.",temp_node,fff);
		     break;
	        case vmwOr: 
		     vmwPPCarithmetic("or","ori",temp_node,fff);
		     break;
	        case vmwXor: 
		     vmwPPCarithmetic("xor","xori",temp_node,fff);
		     break;
                
                case vmwLoad: 
		     handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		     
		     if (temp_node->target_size==1) fprintf(fff,"\tlbz");
		     else if (temp_node->target_size==2) fprintf(fff,"\tlsz");
		     else fprintf(fff,"\tlwz");
		     fprintf(fff,"\t%i,0(%i)\n",
			     which_register(temp_node->reg,DESTINATION),
			     which_register(temp_node->x->reg,SOURCE1)); 
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
		            break;
		

              case vmwStore: 
		
		     if (temp_node->x->mode==CSGConst) {
			vmwPPCLoadConst(13,temp_node->x->val,fff);
			handle_spill_before(fff,temp_node->y->reg,SOURCE1,stack_local_size);
			if (temp_node->target_size==1) 
			   fprintf(fff,"\tstb");
			else fprintf(fff,"\tstw");
			fprintf(fff,"\t13,0(%i)\n",
				which_register(temp_node->y->reg,SOURCE1)); 
		     }
		     else {
			
			handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
			handle_spill_before(fff,temp_node->y->reg,SOURCE2,stack_local_size);
			if (temp_node->target_size==1) 
			   fprintf(fff,"\tstb");
			else fprintf(fff,"\tstw");
		        fprintf(fff,"\t%i,0(%i)\n",
				which_register(temp_node->x->reg,SOURCE1),
				which_register(temp_node->y->reg,SOURCE2)); 
		     }

		     break;
                case vmwMove: 
		     if (temp_node->x->mode==CSGPtr) {
		        fprintf(fff,"\tlis\t%i,%s@ha\t\t# Load address of %s\n",
				which_register(temp_node->y->reg,DESTINATION),
				temp_node->x->name+1,
				temp_node->x->name+1);
	                fprintf(fff,"\taddi\t%i,%i,%s@l\n",
				which_register(temp_node->y->reg,DESTINATION),
				which_register(temp_node->y->reg,DESTINATION),
				temp_node->x->name+1);
				
			handle_spill_after(fff,temp_node->y->reg,stack_local_size);

		     }
		else {
		
		     if (temp_node->y->mode==CSGConst) vmwError("Can't move into a constant!");
		     if (temp_node->x->mode==CSGConst) {
			vmwPPCLoadConst(which_register(temp_node->y->reg,DESTINATION),
					temp_node->x->val,fff);
			handle_spill_after(fff,temp_node->y->reg,stack_local_size);
		     }
/*		     else if (temp_node->x->mode==CSGProc) {
			fprintf(fff,"\tmr\t%i,3\t\t",
				   which_register(temp_node->y->reg,DESTINATION));
			fprintf(fff,"# Copy in result from function\n");
			handle_spill_after(fff,temp_node->y->reg,stack_local_size);
			   
		     }
*/		
		     
		     else {
			if (temp_node->y->reg!=temp_node->x->reg) { 
			   handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		           fprintf(fff,"\tmr\t%i,%i\t\t",
				   which_register(temp_node->y->reg,DESTINATION),
				   which_register(temp_node->x->reg,SOURCE1));
			   fprintf(fff,"\n");
			   	  handle_spill_after(fff,temp_node->y->reg,stack_local_size);
			}
			
		     }
		}
		     break;
                case vmwParam: 

		     if (param_num>(MAX_PARAMS-1)) {
			temp_param_reg=13;
			fprintf(fff,"\taddi\t1,1,-%i\t\t# Allocate space on stack\n",4);
		     }
		     else {
			temp_param_reg=3+param_num;
		     }
		
		 
		     if (temp_node->x->mode==CSGConst) {
			vmwPPCLoadConst(temp_param_reg,
					temp_node->x->val,fff);
					
			fprintf(fff,"# load %i into parameter %i",
				temp_param_reg,temp_node->x->val);
		     }
		
		     else {
			if ((temp_node->x->type!=NULL) &&
			    (temp_node->x->type->form==CSGArray)) {
			   if (temp_node->x->lev==0) {
			      fprintf(fff,"\tlis\t%i,%s@ha\t\t# Load address of %s\n",
				which_register(temp_node->x->reg,DESTINATION),
				temp_node->x->name,
				temp_node->x->name);
	                fprintf(fff,"\taddi\t%i,%i,%s@l\n",
				which_register(temp_node->x->reg,DESTINATION),
				which_register(temp_node->x->reg,DESTINATION),
				temp_node->x->name);
				
			handle_spill_after(fff,temp_node->x->reg,stack_local_size);

			   }
			   else {
			      	fprintf(fff,"\tlis\t%i,_l%i_%s@ha\t\t# Load address of %s\n",
				which_register(temp_node->x->reg,DESTINATION),
				temp_node->x->lev,
				temp_node->x->name,
				temp_node->x->name);
	                fprintf(fff,"\taddi\t%i,%i,_l%i_%s@l\n",
				which_register(temp_node->x->reg,DESTINATION),
				which_register(temp_node->x->reg,DESTINATION),
				temp_node->x->lev,
				temp_node->x->name);
				
			handle_spill_after(fff,temp_node->x->reg,stack_local_size);
			   }
			   
			}
			
			     
			
		      handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);
		     fprintf(fff,"\tmr\t%i,%i\t# load r%i into parameter %i",
			     temp_param_reg,
			     which_register(temp_node->x->reg,SOURCE1),
			     which_register(temp_node->x->reg,SOURCE1),
			     param_num);
		     }
		
		     fprintf(fff,"\n");
		    
		        /* if too many regs, pass on stack */
		     if (param_num>(MAX_PARAMS-1)) {
			fprintf(fff,"\tstw\t%i,%i(%i)\n",
				13,0,//(param_num-MAX_PARAMS)*4,
				1); 
		     }
		
		     
		
		     param_num++;
		     break;
                case vmwBge:
		     vmwPPCbranch("bge",temp_node,fff);
		     break;
	        case vmwBgt:
		     vmwPPCbranch("bgt",temp_node,fff);
		     break;
	        case vmwBeq:
		     vmwPPCbranch("beq",temp_node,fff);
		     break;
	        case vmwBneq:
		     vmwPPCbranch("bne",temp_node,fff);
		     break;
	        case vmwBlt:
		     vmwPPCbranch("blt",temp_node,fff);
		     break;
	        case vmwBle:
		     vmwPPCbranch("ble",temp_node,fff);
		     break;
	       
                case vmwBsr: 
		     fprintf(fff,"\tbl\t"); 
		     vmwPPCPrintReg(fff,temp_node->x);
		     fprintf(fff,"\n");
		        /* Free any stack used for params */
		     if (param_num>(MAX_PARAMS-1)) {
			fprintf(fff,"\taddi\t1,1,%i\t\t# Free space on stack\n",
				(param_num-MAX_PARAMS)*4);			
		     }
		
		     if (temp_node->reg>=0) {
		     
		        fprintf(fff,"\tmr\t%i,3\t\t",
				   which_register(temp_node->reg,DESTINATION));
		        fprintf(fff,"# Copy in result from function\n");
		        handle_spill_after(fff,temp_node->reg,stack_local_size);		     
		     }
		
		     param_num=0;
		     break;
		
                case vmwBr: 
		     fprintf(fff,"\tb\t");
		     vmwPPCPrintReg(fff,temp_node->x);
		     fprintf(fff,"\n");
		     break;
		
	        case vmwEarlyRet:
		     if (temp_node->x!=NULL) {
			if (temp_node->x->mode==CSGConst) {
		           vmwPPCLoadConst(3,temp_node->x->val,fff);
		        }
		        else {
		           handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);			
			   vmwPPCMoveReg(3,which_register(temp_node->x->reg,SOURCE1),fff);

			}
			
			
		     }
		
		     
		     fprintf(fff,"\tb\t__%s_end\t# Early return\n",
			     current_fname);
		     break;
                case vmwRet:
		     fprintf(fff,"\n");
		     fprintf(fff,"__%s_end:\n",current_fname);
		
		     if (stack_local_size!=0) {
	                  fprintf(fff,"\taddi\t1,1,%i\t\t# Restoring %i bytes used by local vars\n",
		          stack_local_size,stack_local_size);	  
			  stack_local_size=0;
		     }
		
		     if (spill_regs) {
			fprintf(fff,"\taddi\t1,1,%i\t\t# Free %i reg spill\n",
		                spill_regs*4,spill_regs);
		        spill_regs=0;
		     }
		
	             fprintf(fff,"\tlwz\t13,0(1)\t\t# Restore link register from stack\n");	 
	             fprintf(fff,"\tmtlr\t13\t\t# Move r13 into link register\n");
		
		     fprintf(fff,"\t# Restore regs we use\n");
	             j=0;
	             for(i=0;i<32;i++) {
	                if (used_reg_mask & (1<<i)) {
		           fprintf(fff,"\tlwz\t%i,%i(1)\t\t#\n",i,4+(j*4));
		           j++;
			}
	             }
		
                     fprintf(fff,"\taddi\t1,1,%i\t\t# Restore stack\n",4+(mask_count*4));
		     fprintf(fff,"\tblr\n\n"); 
		     break;
		
                case vmwRead: 
		     fprintf(fff,"\tbl\tread_long\t# Read int from stdin\n");
		     vmwPPCMoveReg(which_register(temp_node->reg,DESTINATION),3,fff);
			  handle_spill_after(fff,temp_node->reg,stack_local_size);
		     readlong_used++;     
		     break;
		
                case vmwWrite: 

		     if (temp_node->x->mode==CSGConst) {
		        vmwPPCLoadConst(3,temp_node->x->val,fff);
		     }
		     else {
		      handle_spill_before(fff,temp_node->x->reg,SOURCE1,stack_local_size);			
			vmwPPCMoveReg(3,which_register(temp_node->x->reg,SOURCE1),fff);

		     }
		     fprintf(fff,"\tbl\twrite_long\t# Print to stdout\n");
		     writelong_used++;
		     break;
		
                case vmwWrl:
		     fprintf(fff,"\tbl\twrite_line\t# Write lf to stdout\n");
		     writeline_used++;
		     break;
                case vmwHCF:
		     fprintf(fff,"__%s_end:\n",current_fname);
		     fprintf(fff,"\n\t#================================\n");
		     fprintf(fff,"\t# Exit\n");
		     fprintf(fff,"\t#================================\n\n");
		    // fprintf(fff,"\tli\t3,2\t\t# 2 exit value\n");
		     fprintf(fff,"\tli\t0,1\t\t# put the exit syscall number (1) in reg 0\n");
		     fprintf(fff,"\tsc\t\t\t# and exit\n");
		     break;
		
		
                default: fprintf(fff,"\tEIEIO\n"); break;
	     }
	     
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

    fprintf(fff,"\n\t#===================\n");
    fprintf(fff,"\t# CODE LIBRARY        \n");
    fprintf(fff,"\t#===================\n");
   
    if (writelong_used) {
       vmwPPCWriteLong(fff);
    }
   
    if (readlong_used) {
       vmwPPCReadLong(fff);
    }	
   
    if (writeline_used) {
       vmwPPCWriteLine(fff);
    }
   
    if (mod_used) { 
       vmwPPCMod(fff);
    }
   
    /* FIXME.  Sort to save instructions */
    fprintf(fff,"#.bss\n");
    fprintf(fff,".lcomm __bss_begin,0\n");
    temp_node=globscope;
    while(temp_node!=NULL) {
       if ((temp_node->mode==CSGVar) &&
	   (temp_node->initial_data==NULL) &&
	   (temp_node->lev==0)) { 
          fprintf(fff,".lcomm %s,%i\n",temp_node->name,temp_node->type->size);
       }
       temp_node=temp_node->next;
    }
   

    fprintf(fff,".data\n");

    temp_node=globscope;
    while(temp_node!=NULL) {
       if ((temp_node->mode==CSGVar) &&
	   (temp_node->initial_data!=NULL)) {
	   
	  if (temp_node->lev==0) {
	     if (temp_node->type->form==CSGArray) {
	        fprintf(fff,"%s: .asciz \"%s\"\n",temp_node->name,
      	                (char *)temp_node->initial_data);
	     }
	     else {
	        fprintf(fff,"%s: .int %i\n",temp_node->name,
		            *(int *)temp_node->initial_data);
	     }
		 
	  }
	  if (temp_node->lev!=0) {
	     if (temp_node->type->form==CSGArray) {
	        fprintf(fff,"_l%i_%s: .asciz \"%s\"\n",
			temp_node->lev,
			temp_node->name,
      	                (char *)temp_node->initial_data);
	     }
	  }
	  
	       
	  
	  
       }
       temp_node=temp_node->next;
    }
   
}
