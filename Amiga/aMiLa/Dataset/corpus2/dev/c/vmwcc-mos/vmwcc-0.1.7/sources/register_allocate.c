#include <stdio.h>
#include <stdlib.h> /* exit()   */
#include <string.h> /* memcpy() */

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"
#include "globals.h"

#include "backends.h"

//#define DEBUG 1

struct set_type {
   int length32;
   int *set;
};
   
struct liveset_type {
   int length32;
   struct set_type *liveset;
};

   

static int maximum(int max1,int max2) {
   
   if (max1>max2) return max1;
   else return max2;
   
}

static int minimum(int min1,int min2) {
   if (min1<min2) return min1;
   else return min2;
}

   

static int node_in_set(struct set_type *set,int node,int caller) {
   
    int which_int,offset;
   
    which_int=node/BITNESS;
    offset=node%BITNESS;

    if ( (node/BITNESS)+1> set->length32) {
       if (debug_level>=D_WARNINGS) 
	  printf("WARNING:  Set too small %i %i! %i\n",node,set->length32,caller);
       return 0;
    }
      
    return set->set[which_int]&(1L<<offset);
}

//#ifdef DEBUG

    /* > 32 clean I _think_ */
static void dump_liveset(struct liveset_type *liveset, int max) {
   
   int i,j;
   
   
   struct set_type *temp;
   
   for(i=0;i<max;i++) {
      temp=&liveset->liveset[i];
      for(j=0;j<max;j++) {
	 if (node_in_set(temp,j,1)) printf("1");
	 else printf("0");
      }
      printf("\n");
   }
}


   /* > 32 clean */
static void dump_current_set(struct set_type **set,int max) {
   
    int which_int,offset,i;
   
   
    printf("{ ");

    for(i=0;i<max;i++) {
	
       which_int=i/BITNESS;
       offset=i%BITNESS;
      
       if ( (*set)->set[which_int]&(1<<offset)) {  
          printf("%i, ",i);
       }
      
    }
    printf("};\n");
}

//#endif


struct set_type *copy_set(struct set_type *set) {

    int number;
    struct set_type *temp_set;
      
    number=set->length32;
   
    temp_set=calloc(1,sizeof(struct set_type));
    if (temp_set==NULL) {
       vmwError("Calloc1 in copy_set");
    }
   
    temp_set->length32=number;
    temp_set->set=calloc(number,sizeof(int));
   
    if (temp_set->set==NULL) {
       vmwError("Calloc2 in copy_set");
    }
   
    memcpy(temp_set->set,set->set,number*sizeof(int));
       
    return temp_set;
}


    /* Color the registers */
static void vmwColorMeStupid(struct liveset_type **liveset, 
			     int *reg_num, int num_sets) {
   
    int i,j,temp_reg,x,sum;
  
    struct set_type *saved_row;
   
#ifdef DEBUG   
    dump_liveset(liveset,num_sets);
#endif
   

       /***********************/
       /* Skip all empty rows */
       /***********************/
    i=0;
    sum=0;
    //printf("Coloring %i sets!\n",num_sets);
   
    while ( (i<num_sets) && (!sum) ) {
 
       for(j=0;j < (*liveset)->liveset[i].length32;j++) {
	  sum+= (*liveset)->liveset[i].set[j];
       }
       if (!sum) i++;
    }
   
    if (i<num_sets) {

          /* Save the Row */  
       saved_row=copy_set( &((*liveset)->liveset[i]) );
	 
       
          /* Zero out the row */
       x=0;
       while(x< (*liveset)->liveset[i].length32) {
	  (*liveset)->liveset[i].set[x]=0;
	  x++;
       }
       
          /* Zero out the column */
       for(j=0;j<num_sets;j++) {
	  (*liveset)->liveset[j].set[i/BITNESS]&=~(1L<<(i%BITNESS));
//	 *(liveset+(j*set_width)+(i/BITNESS))&=~(1<<i%BITNESS);
       }
       
       
#ifdef DEBUG
       printf("Before\n");
       dump_liveset(*liveset,num_sets);
#endif      
          /* Recurse */
       vmwColorMeStupid(liveset,reg_num,num_sets);

#ifdef DEBUG      
       printf("After\n");
       dump_liveset(*liveset,num_sets); 
#endif      
       
          /* Restore Column */
       for(j=0;j<num_sets;j++) {
	  if (node_in_set( saved_row,j,2)) {
	     //if (saved_row->length32==1) 
//	       printf("YYYD");
	     (*liveset)->liveset[j].set[i/BITNESS]|=(1L<<(i%BITNESS));
//	    *(liveset+(j*set_width)+(i/BITNESS))|=1<<i%BITNESS;
	  }
       }
       
       
          /* Restore Row */
//      (*liveset)->liveset[i].length32=saved_row->length32;
       for(j=0;j<saved_row->length32;j++) {
          (*liveset)->liveset[i].set[j]=saved_row->set[j];	 
       }
       
       free(saved_row->set);
       free(saved_row);
      
       
          /* If register unassigned */
       if (reg_num[i]==-1) {



	     /* If we conflict with a reg, and it is not assigned */
	     /* yet, make it the default low reg  */
	  for(j=0;j<num_sets;j++) {
	     if ((node_in_set(&( (*liveset)->liveset[i]),j,3))  
	         && (reg_num[j]==-1)) {
	        reg_num[j]=0;
	     }
	  }


	     /* Assign ourselves a reg, making sure not to overlap with */
	     /* Any registers we conflict with                          */
	  j=0;
	  temp_reg=0;
	  while(j<num_sets) {
	     if (node_in_set(&( (*liveset)->liveset[i]),j,4)) {
		
		   /* If we conflict, disaster!  Increase temp reg */
		   /* And restart over from beginning              */
	        if (temp_reg==reg_num[j])  {
		   temp_reg++;
		   j=-1;
	        }	       
	     }
	     j++;
	  }
	  reg_num[i]=temp_reg;
       }
    }
    return;
}


    /* Remove a value from a set */
static void remove_from_set(struct set_type **set,int index) {

    int which_int,offset;
   
    which_int=index/BITNESS;
    offset=index%BITNESS;
   
#ifdef DEBUG   
//    printf("Removing %i %x\n",index,~(1<<offset));
#endif   
   
    if (which_int>(*set)->length32) {
//       printf("TTT %i %i\n",which_int,(*set)->length32);
       vmwError("Error rms!");
    }
   
    (*set)->set[which_int]&=(~(1L<<offset));
}



static void expand_sets(struct set_type **set,
		 struct liveset_type **liveset,int new_size)  {

    struct set_type *new_set;
    struct liveset_type *new_liveset;
    int x,y,old_size;
   
//    printf("Creating size: %i\n",new_size); fflush(stdout);
   
#ifdef DEBUG      
    printf("BEFORE EXPANSION!\n");
    dump_liveset(liveset,set_width); 
#endif
   
    old_size=(*set)->length32;
   
    if (old_size<new_size) {
	
          /* Change the size of the current_set */
       new_set=calloc(1,sizeof(struct set_type));
       if (new_set==NULL) {
          vmwError("Error: Out of memory expanding set!");
       }
       new_set->length32=new_size;   
       new_set->set=calloc(new_size,sizeof(int));
       if (new_set->set==NULL) {
          vmwError("Error: Out of memory expanding set!");
       }
       memcpy(new_set->set,(*set)->set,sizeof(int)*old_size);
   
       free( (*set)->set);
       free( *set);
       *set=new_set;
    }
   
   
    old_size= (*liveset)->length32;
    
    if (old_size<new_size) {
	
   
          /* Change the size of the live-set */
       new_liveset=calloc(1,sizeof(struct liveset_type));
       if (new_liveset==NULL) {
          vmwError("Error making huge array!");
       }
       new_liveset->length32=new_size;
       new_liveset->liveset=calloc(new_size*BITNESS,sizeof(struct set_type));
       if (new_liveset->liveset==NULL) {
	  printf("Two %i %i ",old_size,new_size);
          vmwError("Error making huge array!");
       }
    
       for(x=0;x<new_size*BITNESS;x++) {
          new_liveset->liveset[x].length32=new_size;
          new_liveset->liveset[x].set=calloc(new_size,sizeof(int));
          if (new_liveset->liveset[x].set==NULL) {
	     printf("Three %i ",new_size);
             vmwError("Error making huge array!");
          }
       }
	

          /* Copy old data to new array */
       for(y=0;y<old_size*BITNESS;y++) {
          for(x=0;x<old_size;x++) {
	     new_liveset->liveset[y].set[x]=(*liveset)->liveset[y].set[x];

#ifdef DEBUG	    
	    printf("new[%i]=old[%i]=%i=%i==%i (%i,%i)\n",
		   y*set_width+x,y*old_size+x,
		   *(*liveset+((y*old_size)+x)),
		   (*liveset)[y],
		   *(*liveset+y),old_size,x);
#endif	    
	  }
	  
       }
       
   
          /* FIXME */
       free(*liveset);
       *liveset=new_liveset;      	
    }
   
   
	
#ifdef DEBUG      
    printf("AFTER EXPANSION!\n");
    dump_liveset(*liveset,(set_width)*BITNESS); 	   
#endif         
}



  /* We want to set liveset[node][link]=1 and also
   *                liveset[link][node]=1          */
  /* set_width = how many 32 units each is wide */

  /* > 32 clean */
static void add_liveset_link(struct liveset_type **liveset,
			     struct set_type **set, int node,int link) {

    int link_x,link_sub;
    int node_x,node_sub;
   
    link_x=link/BITNESS;
    link_sub=link%BITNESS;
   
    node_x=node/BITNESS;
    node_sub=node%BITNESS;

    if ((link_x> (*set)->length32) || (node_x> (*set)->length32) ||
	(link_x> (*liveset)->length32) || (node_x> (*liveset)->length32)) {
       
       printf("%i %i > \n",link_x,node_x);

       expand_sets(set,liveset,maximum(link_x,node_x));
       printf("%i %i > \n",link_x,node_x);
//       vmwError("22");
 //      goto bob;
    }
   
//    printf("ZZZ: %i %i %i\n",set_width,link_x,link_sub);

   
    (*liveset)->liveset[node].set[link_x]|=(1L<<link_sub);
    (*liveset)->liveset[link].set[node_x]|=(1L<<node_sub);
   
//    *((*liveset)+((set_width*node)+link_x))|=(1<<link_sub);
//    *((*liveset)+((set_width*link)+node_x))|=(1<<node_sub);
   
#ifdef DEBUG   
    printf("Adding %i %i\n",node,link);
//    dump_liveset(*liveset,((*liveset)->length32)*BITNESS);
#endif   
//    liveset[node]|=(1<<link);
//    liveset[link]|=(1<<node);   
//    printf("LIVE[i]=i\n",node,liveset[node]);
}



   



    /* add the value to the current set */
static void add_current_set(struct liveset_type **liveset,
			    struct set_type **set,
			    int value) {
   

       /* If we are too long for our array we have great *PAIN* */
    if ( (value>= ( (*set)->length32*BITNESS) ) ||
         (value>=( (*liveset)->length32*BITNESS))) {
//       printf("%i %i\n",value,BITNESS);
       expand_sets(set,liveset,(value/BITNESS)+1);
    }
 
    (*set)->set[value/BITNESS]|=(1L<<(value%BITNESS));
   
}



    /* add a conflict for every value in set *set to the liveset */ 
static void connect_liveset(struct liveset_type **liveset, 
			    struct set_type **set, int node,int max) {
   
    int i;

    for(i=0;i<max;i++) {
       if (node_in_set(*set,i,5)) {
	  add_liveset_link(liveset,set,node,i);
       }  
    }
}



static int equalize_lengths(struct set_type **set1, 
			    struct set_type **set2) {
   

    int new_max;
    struct set_type *temp_set;
   
    new_max=(*set1)->length32;
   
    if ((*set1)->length32<(*set2)->length32) {
       temp_set=calloc(1 ,sizeof(struct set_type));
       temp_set->length32=(*set2)->length32;
       temp_set->set=calloc((*set2)->length32,sizeof(int));
       memcpy(temp_set->set,(*set1)->set, ((*set1)->length32)*sizeof(int));
       new_max=(*set2)->length32;
       free((*set1)->set);
       free((*set1));
       *set1=temp_set;
   }
   
   if ((*set2)->length32<(*set1)->length32) {
       temp_set=calloc(1 ,sizeof(struct set_type));
       temp_set->length32=(*set1)->length32;
       temp_set->set=calloc((*set1)->length32,sizeof(int));
       memcpy(temp_set->set,(*set2)->set, ((*set2)->length32)*sizeof(int));
       new_max=(*set1)->length32;
       free((*set2)->set);
       free((*set2));
       *set2=temp_set;
      
   }
   
   return new_max;
   
}

   


static struct set_type *union_set(struct set_type **set1,
				  struct set_type **set2,int max) {

   int i,number;
   struct set_type *temp_set;


#ifdef DEBUG
   printf("Set1: %p ",set1);
   dump_current_set(set1,max);
   printf("Set2: %p ",set2);
   dump_current_set(set2,max);
#endif  
   
   if ( (*set1)->length32!=(*set2)->length32) {
      printf("%i %i\n",(*set1)->length32,(*set2)->length32);
      vmwError("UNION PACIFIC!\n");
   }
   
//   number=(max/BITNESS)+1;   
  
   number=(*set1)->length32;
     
     
   temp_set=calloc(1,sizeof(struct set_type));
   if (temp_set==NULL) {
      vmwError("Calloc in union_set");
   }
   temp_set->set=calloc(number,sizeof(int));
   temp_set->length32=number;
   
   for(i=0;i<number;i++) {
      temp_set->set[i]=((*set1)->set[i])|((*set2)->set[i]);
   }
   
   
   
#ifdef DEBUG
   printf("Union: ");
   dump_current_set(temp_int,max);
#endif   
   return temp_set;

}

   
void vmwRegisterAllocate(Block block,
			 struct set_type **current_set,
			 struct liveset_type **liveset,
			 int *max) {

    Node temp_node;
    int unique=0,i,current_reg;


#ifdef DEBUG   
    printf("############################### BLOCK %i\n",block->num);
#endif   
    
    unique=*max;
   
       /* Start with the last instruction */
    temp_node=block->last;

       /* Add instructions to live set */
    while(temp_node!=NULL) {
       if (!temp_node->deleted) {

	  current_reg=-1;
#ifdef DEBUG
	  dump_current_set(*current_set,unique);
#endif
          if (temp_node->ind>=0) {
	     current_reg=temp_node->ind;
//#ifdef DEBUG	     
           //  printf("TTTT Removing %i (line %i) (block %i)\n",temp_node->ind,temp_node->line_number,
	//	    block->num);
//#endif	     
	  //   	printf("TTTT %i{",(*current_set)->length32);
	//	dump_current_set(current_set,unique);
             remove_from_set(current_set,temp_node->ind);
	  //   printf("} TTTT\n");
	  }
	  else {

#ifdef DEBUG	     
	     printf("Line %i unused!\n",temp_node->line_number);
#endif	     
	  }

	  if (temp_node->op==vmwMove) {

	     current_reg=temp_node->y->ind;
	     if (temp_node->y->ind>=0) {
	//	printf("TTT ");
	//	dump_current_set(current_set,unique);
	        remove_from_set(current_set,temp_node->y->ind);	     
	     }
	     else {
//		temp_node->deleted=1;
	        if (debug_level>=D_WARNINGS)
		   printf("WARNING: Line %i unused!\n",temp_node->line_number);
	     }
	     
	 
	     
//	     printf("Move %i -> %i!\n",temp_node->x->ind,temp_node->y->ind);

	  }
	  
//	  printf("HANDLING CONFLICTS!!!!!!!!!!!!!!!!!!!!!!!!!\n");
	  if (current_reg!=-1) {
	       
	     for(i=0;i<unique;i++) {   
	        if ( node_in_set(*current_set,i,6)) {
//		   printf("CONFLICT BETWEEN %i and %i\n",current_reg,i);	           
//		   if ((*current_set)->length32==1) printf("YYY GOOT\n");
		   connect_liveset(liveset,current_set,current_reg,unique);
		}
		
	     }
	     
	  }
//	  printf("!!!!!!!!!!!!!!!!!!!!!!\n");
	  
	  
       }
       
       
    	  
       if (!temp_node->deleted)  {	  
	  
          if (temp_node->mode==CSGInstr) {
	  
             switch(temp_node->op) {
		
	        case vmwPhi: break;
	        case vmwEarlyRet:
	        case vmwNeg:
	        case vmwNot:
	        case vmwBoolnot:
	        case vmwParam: 
	        case vmwWrite: 
	        case vmwLoad:
		
		   if (temp_node->x==NULL) break;
		   if ((temp_node->x->mode==CSGInstr) && (temp_node->x->ind<0)) {
//#ifdef DEBUG		     
//	                   printf("Adding %i = (%i)\n",unique,temp_node->x->line_number);
//#endif			   
			 add_current_set(liveset,current_set,unique);
		         temp_node->x->ind=unique;
		         unique++;
		     }

		     if (temp_node->x->master!=NULL) {
			
		        if ((temp_node->x->master->mode==CSGVar)&&(temp_node->x->ind<0)){
			   	                 //  printf("Adding %i = (%i)\n",unique,temp_node->x->line_number);
			   add_current_set(liveset,current_set,unique);
		           temp_node->x->ind=unique;
		           unique++;
			}
		     }
		     break;
		
	        case vmwBeq: case vmwBneq: case vmwBge: case vmwBle: case vmwBgt: case vmwBlt:
	      case vmwAdd: case vmwStore: 
	      
	        case vmwSub: case vmwMul: case vmwDiv: case vmwMod: case vmwLshift: 
	        case vmwRshift: case vmwAnd: case vmwOr: case vmwXor: case vmwAdda:
	        case vmwMove: 

		   if ((temp_node->x->mode==CSGInstr) && (temp_node->x->ind<0)) {		     
		      	                 //  printf("Adding %i = (%i)\n",unique,temp_node->x->line_number);
		      add_current_set(liveset,current_set,unique);
   		      temp_node->x->ind=unique;
		      unique++;
		   }

		   if (temp_node->x->master!=NULL) {

		      if (temp_node->x->master->mode==CSGVar) {
			 if (temp_node->x->ind<0) {
			    	                 //  printf("Adding %i = (%i)\n",unique,temp_node->x->line_number);
			    add_current_set(liveset,current_set,unique);
		            temp_node->x->ind=unique;
		            unique++;
			 }
			 else {
			    	                  // printf("Adding %i = (%i)\n",unique,temp_node->x->line_number);
			    add_current_set(liveset,current_set,temp_node->x->ind);	   
			 }	      
		      }	   
		   }

		  if (temp_node->y==NULL) {
		     printf("op=%i\n",temp_node->op);
		     vmwError("Null Y!\n");
		  }
		
		     

		  if ((temp_node->y->mode==CSGInstr) && (temp_node->y->ind<0)) {
		     //	                   printf("Adding %i = (%i)\n",unique,temp_node->x->line_number);
		     add_current_set(liveset,current_set,unique);
		     temp_node->y->ind=unique;
		     unique++;
		  }
		
		  if (temp_node->y->master!=NULL) {
		     if ((temp_node->y->master->mode==CSGVar)&&(temp_node->y->ind<0)) {
				           //        printf("Adding %i = (%i)\n",unique,temp_node->x->line_number);
			add_current_set(liveset,current_set,unique);
		        temp_node->y->ind=unique;
		        unique++;
		     }
		  }
		  break;
	     }
	  }
       }
       
       temp_node=temp_node->prev;    
    }
   
#if 0   
       /* Conflict last vars, probably parameters */	
    for(i=0;i<unique;i++) {    
	for(j=0;j<unique;j++) {
	   if (( node_in_set(*current_set,i,7)) && (node_in_set(*current_set,j,8)))  {
	      add_liveset_link(liveset,current_set,i,j);	 
	   }
	}
     }
#endif   
   
   
#ifdef DEBUG
    dump_current_set(*current_set,unique);
#endif
   
    *max=unique;
   
}





   /* > 32 OK */
static void vmwRegisterAllocateBeginEnd(Block start_block, Block end_block,
	                 struct set_type **current_set,
			 struct liveset_type **liveset,int *max) {
   
   
    Block iterate_block,temp_block2,next_to_last;
    struct set_type *else_set,*then_set;
    struct set_type *while_body=NULL,*while_head,*while_join;
    struct set_type *ending_set;
    int done=0,max1,max2;

    static struct set_type *global_join;
    int global_join_size=0;
   
    static int current_depth=0,global_max=0;

    if (current_depth==0) {
       global_join=calloc(1,sizeof(struct set_type));
       global_join->length32=1;
       global_join->set=calloc(1,sizeof(int));
       global_join_size=1;
       if (global_join==NULL) vmwError("calloc regabe");
       global_max=0;
    }
   
    current_depth++;
   
    iterate_block=end_block;
   
    while (!done) {
       
          /* HANDLE IF STATEMENT */
       if (iterate_block->kind==blockIfJoin) {
		
	  vmwRegisterAllocate(iterate_block,current_set,liveset,max);

	     /* Back up register set in join block for later */
	  else_set=copy_set(*current_set);
	  then_set=copy_set(*current_set);
	  ending_set=copy_set(*current_set);
	  max1=*max;
	  max2=*max;
		
	  temp_block2=iterate_block->rdom->dsc;
	  		
	  while(temp_block2!=NULL) {
	     
	        /* Go through the else block */
	     if (temp_block2->kind==blockElse) {
	         
		next_to_last=find_last_block(temp_block2,iterate_block);
		 
		max1=*max;
		  
		vmwRegisterAllocateBeginEnd(temp_block2,next_to_last,
					     &else_set,liveset,&max1);
		*max=max1;  /* Make sure we don't re-use a set */
	     }
	     
	        /* Go through the then block */
	     if (temp_block2->kind==blockThen) {
		 
		next_to_last=find_last_block(temp_block2,iterate_block);
 
		max2=*max;
		vmwRegisterAllocateBeginEnd(temp_block2,next_to_last,
				      &then_set,liveset,&max2);


		*max=max2; /* make sure we don't reuse a set */
	     }
	     temp_block2=temp_block2->next;
	  }
          equalize_lengths(&else_set,&then_set);
	  *max=maximum(max1,max2);
	  
	  *current_set=union_set(&else_set,&then_set,*max);
       }

	     
	     /* HANDLE WHILE STATEMENT */
       else if (iterate_block->kind==blockWhileJoin) {
		
	  while_join=copy_set(*current_set);

	        /* Allocate the Join Block */
	  temp_block2=iterate_block;
	  vmwRegisterAllocate(temp_block2,&while_join,liveset,max);
	     
	        /* Allocate the head block first time */
	  temp_block2=iterate_block->rdom;
	  while_head=copy_set(while_join);
//	  printf("TTT wh_size=%i\n",while_head->length32);
	  vmwRegisterAllocate(temp_block2,&while_head,liveset,max);
	  
	  
	  
	  
	  if (global_join_size<((*max)/BITNESS)+1) {
	     struct set_type *new_gj;
	     int old_size;
	     
	     old_size=global_join_size;
	     
	     global_join_size=((*max)/BITNESS)+1;
	     
	     new_gj=calloc(1,sizeof(struct set_type));
	     new_gj->set=calloc(1,sizeof(int)*global_join_size);
	     if (new_gj==NULL) vmwError("calloc gj!");
	     memcpy(new_gj->set,global_join->set,old_size*sizeof(int));
	     free(global_join->set);
	     free(global_join);
	     global_join=new_gj;
	  }
	  
          global_max=equalize_lengths(&global_join,&while_head);
//	  	  printf("TTT wh_size=%i %i gm=%i\n",global_join->length32,while_head->length32,global_max);
	  global_join=union_set(&global_join,&while_head,
				   (global_max*BITNESS)-1);
	     
//	  	  	  printf("TTTZ wh_size=%i gj=%i\n",while_head->length32,global_join->length32);   
	  while_head=copy_set(global_join); 
//	  	  printf("TTT wh_size=%i\n",while_head->length32);   
	  
	  
	  

	        /* Allocate the body block */
	  temp_block2=iterate_block->rdom->fail;

	  next_to_last=find_last_block(temp_block2
					   ,iterate_block->rdom);

	  while_body=copy_set(while_head);
		  
	  vmwRegisterAllocateBeginEnd(temp_block2,
					   next_to_last,
					   &while_body,liveset,max);
	   
	     
	  while_head=copy_set(while_body);
//	  	  printf("TTT wh_size=%i\n",while_head->length32);   
	        /* Do the head block again */
	  temp_block2=iterate_block->rdom;
	  vmwRegisterAllocate(temp_block2,&while_head,liveset,max);     
//	  printf("TTT wh_size=%i\n",while_head->length32);
	  vmwRegisterAllocateBeginEnd(temp_block2,
					   next_to_last,
					   &while_head,liveset,max);
//	     	  printf("TTT wh_size=%i\n",while_head->length32);
	     
	       
		  
	        /* Propogate while headers */
	  
	  if (global_join_size<((*max)/BITNESS)+1) {
	     struct set_type *new_gj;
	     int old_size;
	     
	     old_size=global_join_size;
	     
	     global_join_size=((*max)/BITNESS)+1;
	     
	     new_gj=calloc(1,sizeof(struct set_type));
	     new_gj->set=calloc(1,sizeof(int)*global_join_size);
	     if (new_gj==NULL) vmwError("calloc gj!");
	     memcpy(new_gj->set,global_join->set,old_size*sizeof(int));
	     free(global_join->set);
	     free(global_join);
	     global_join=new_gj;
	  }
	  
          global_max=equalize_lengths(&global_join,&while_head);
//	  	  printf("TTT wh_size=%i %i gm=%i\n",global_join->length32,while_head->length32,global_max);
	  global_join=union_set(&global_join,&while_head,
				   (global_max*BITNESS)-1);
	     
//	  	  	  printf("TTTZ wh_size=%i gj=%i\n",while_head->length32,global_join->length32);   
	  while_head=copy_set(global_join); 
//	  	  printf("TTT wh_size=%i\n",while_head->length32);   

	  *current_set=copy_set(while_head);
//	  printf("TTT cur_Set=%i\n",(*current_set)->length32);
#ifdef DEBUG
	  dump_current_set(*current_set,*max);
#endif	     
       }
	     
	     
	        /* Handle all other kinds */
       else {
//	     printf("NORMAL BLOCK!!\n");
		
	  vmwRegisterAllocate(iterate_block,current_set,liveset,max);		
	  //   printf("</DONE NORMAL BLOCK>\n"); fflush(stdout);
		
       }
	     
	
       if (iterate_block==start_block) done=1;
       iterate_block=iterate_block->rdom;	
	  
    }
     {
	int i,j;
       /* Conflict last vars, probably parameters */	
    for(i=0;i<*max;i++) {    
	for(j=0;j<*max;j++) {
	   if (( node_in_set(*current_set,i,7)) && (node_in_set(*current_set,j,8)))  {
	      add_liveset_link(liveset,current_set,i,j);	 
	   }
	}
     }   
     }
   

    current_depth--;
}



void vmwRegisterAllocateAll(Block root) {
       
    Block temp_block,allocate_block;
    Block end_block,iterate_block;
    Node temp_node,temp_node2;
   
    int *reg_assign;
    struct set_type *current_set;
    struct liveset_type *liveset;
    int max=0,i,regs_total=0;
   
    temp_block=root;
   
    while (temp_block!=NULL) {
	
          /* Register Allocate on one proc at a time */
       if (temp_block->kind==blockProc) {	  
	  
	  /* Move to the end of the proc */
	  
	  end_block=temp_block;
	  
	  while ( (end_block->link!=NULL) && 
		  (end_block->link->kind!=blockProc)) {
	     end_block=end_block->link;   
	  }
	  

	     /* Initialize current_set */
	  current_set=calloc(1,sizeof(struct set_type));
          current_set->set=calloc(1,sizeof(int));
	  if (current_set->set==NULL) {
	     vmwError("Out of mem!\n");
	  }
	  current_set->length32=1;

	     /* Initialize liveset */
	  liveset=calloc(1,sizeof(struct liveset_type));
	  liveset->length32=1;
          liveset->liveset=calloc(32,sizeof(struct set_type));
          if (liveset->liveset==NULL) {
	     vmwError("Out of mem!\n");
	  }
	  for(i=0;i<liveset->length32*32;i++) {
	     liveset->liveset[i].length32=1;
	     liveset->liveset[i].set=calloc(1,sizeof(int));
	  }
	  
       
	  iterate_block=end_block;
	  max=0;
	  	
	  vmwRegisterAllocateBeginEnd( temp_block,end_block,
	                 &current_set,&liveset,&max);


	  reg_assign=calloc(max,sizeof(int));
	  if (reg_assign==NULL) {
	     vmwError("Big Calloc\n");
	  }
	   
	  for(i=0;i<max;i++) reg_assign[i]=-1;



	     /* Color the registers */
	  printf("COMPILING: Coloring %i registers\n",max);
          vmwColorMeStupid(&liveset,reg_assign,max);

          for(i=0;i<max;i++) {
             if (reg_assign[i]==-1) reg_assign[i]=0;
	  }
	  
//	  dump_liveset(liveset,max);
	  
	     /* Assign the registers to instr results */
#ifdef DEBUG	  
          for(i=0;i<max;i++) printf("%i = %i\n",i,reg_assign[i]);
#endif
	  
	  allocate_block=root_block;
	  while(allocate_block!=NULL) {
	     temp_node=allocate_block->first;
	     while(temp_node!=NULL) {
		if ((temp_node->reg==-1) && (temp_node->ind>=0)) {
		   temp_node->reg=reg_assign[temp_node->ind];
//		   printf("Line %i = reg %i\n",temp_node->line_number,temp_node->reg);
		}
	        temp_node=temp_node->next;
	     }
	     allocate_block=allocate_block->link;
	  }



	     /* Assign registers to variables */
	  temp_node=root->vars;
//	  vmwDumpAll(temp_node);

	  regs_total=0;
	  while(temp_node!=NULL) {
	     if ((temp_node->reg==-1) && (temp_node->ind>=0)) {
		temp_node->reg=reg_assign[temp_node->ind];
//		printf("Var = reg i\n",temp_node->reg);
	     }
	     
//	     if (temp_node->type==CSGVar) {
//		printf("Var %s %p\n",temp_node->name,temp_node);
		
		temp_node2=temp_node->master->var_list;
		while(temp_node2!=NULL) {
              //     printf("Checking: %s^%i\n",
		//	  temp_node2->master->name,
		//	  temp_node2->current->line_number);
	           if ((temp_node2->reg==-1) && (temp_node2->ind>=0)) {
		      //printf("YYY %i\n",temp_node2->ind); fflush(stdout);
		      temp_node2->reg=reg_assign[temp_node2->ind];
		      regs_total++;
		    //  printf("Var %s = reg %i\n",temp_node2->master->name,
		//	     temp_node2->reg);
	           }	   
		   temp_node2=temp_node2->next;
		}
		
		     
		
//	     }
	     	     
	     temp_node=temp_node->next;
	  }
	  
	       
	  
	  
//          printf("Regs used by this proc=%i\n",max);	       
	  temp_block->regs_used=regs_total;
       }
       
       
       temp_block=temp_block->link;    
    }
   

}
