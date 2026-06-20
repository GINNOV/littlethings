/* vmwcc Parser by Vince Weaver                 */
/* Based on:                                    */
/*  C Subset Parser  9-17-03  Martin Burtscher  */

#include <stdio.h>
#include <stdlib.h>   /* malloc  */
#include <string.h>   /* strncpy */

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"
#include "globals.h"

#include "ir_generator.h"
#include "phi_functions.h"


    /* The head root pointer */
Node globscope,GP,FP;

    /* The current symbol */
static int sym;

    /* Hack to tell if in a struct */
static int instruct;

    /* Tell what scope we are in */
static int base_level=0;

static int unique_string=0;

unsigned int vmwVal;
char vmwId[vmwIdlen];

Type CSGlongType,CSGintType,CSGcharType,CSGshortType,CSGboolType,CSGvoidType;
Block current_block,current_phi_block,root_block;
int current_path,current_depth,block_num,current_level,entrypc;
Node first_instruction,current_instruction;

static void Expression(Node *x);
static void DesignatorM(Node *x, int load);
static void ProcedureDeclaration(char *name);
static void ProcedureCallM(Node *x);
static void Statement(void);
static void Unary(Node *x);


static void Prefix(Node *x) {
   Node y,z,q;
   int op;
   
   op=sym;
   sym=vmwGetToken();
   
   if (sym!=vmwTident) vmwError("Expected identifier");
   
   q=FindNode(&globscope, vmwId);
   z=FindNode(&globscope, vmwId);
   if (q==NULL) vmwError("Unknown idetifier");
   
   y=CSGMakeConstNode(&globscope, CSGlongType, 1);

      
   if (op==vmwTplusplus)
      *x=CSGOp2(vmwTplus, &q, &y);
   else
      *x=CSGOp2(vmwTminus,&q,&y);
   
   printf("Prefix\n");
   sym=vmwGetToken();

   
   CSGStore(&z, x);
}

static void Postfix(Node *x) {
   Node y,zp;
   
   int op;
   
   op=sym;

   zp=calloc(1,sizeof(NodeDesc));
   memcpy(zp,*x,sizeof(NodeDesc));

   y=CSGMakeConstNode(&globscope, CSGlongType, 1);

      
   if (op==vmwTplusplus) 
      zp=CSGOp2(vmwTplus, &zp, &y);
   else
      zp=CSGOp2(vmwTminus, &zp, &y);
   
   printf("Postfix\n");
   sym=vmwGetToken();

   CSGStore(x,&zp);
   
}
   

/*
 *      'x'
 *  or  ident
 *  or  number
 *  or  ( EXPRESSION )
 */
static void Factor(Node *x) {

   int ch,ch2,have_close_quote=0;
   
    switch (sym) {

       case vmwTsinglequote:
            ch=vmwGetChar();
            
            if (ch=='\\') {
	       ch=vmwGetChar();
	       switch(ch) {
		case 'a': ch='\a'; break;
		case 'b': ch='\b'; break;
		case 'f': ch='\f'; break;
		case 'n': ch='\n'; break;
		case 't': ch='\t'; break;
		case 'r': ch='\r'; break;				  
		case 'v': ch='\v'; break;		
		case '\\': ch='\\'; break;
		case '\'': ch='\''; break;
		case '\"': ch='\"'; break;
		case '0': ch2=ch; ch=0;
		          while( (ch2=vmwGetChar())!='\'') {
			     if ((ch2>='0') && (ch2<='7')) {
				ch=(ch*8)+(ch2-'0');
			     }
			     else {
				vmwError("Invalid octal constant.");
			     }
		          }
		          have_close_quote=1;
		          break;
		default: vmwError("Unknown escape sequence.");
	       }
	       
		    
	    }
       
            if (!have_close_quote) {
	       sym=vmwGetToken();
	    }
       
            if ((sym!=vmwTsinglequote) && (!have_close_quote)) 
	       vmwError("Expected closing single quote.");
            *x=CSGMakeConstNode(x, CSGlongType, ch);
            sym=vmwGetToken();
            break;
       
       case vmwTident:
          *x = FindNode(&globscope, vmwId);
          if (*x == NULL) {
	     /*if (sym==vmwTlparen) {
		ProcedureCallM(x);
	     }*/
	     vmwError("unknown identifier 1");
	  }
          sym = vmwGetToken();
       
          if (sym==vmwTlparen) {
	     ProcedureCallM(x);	     
	  }
          else {
             DesignatorM(x,1);
	  }
       
          break;
       case vmwTnumber:
          *x=CSGMakeConstNode(x, CSGlongType, vmwVal);
          sym = vmwGetToken();
          break;
       case vmwTlparen:
          sym = vmwGetToken();
          Expression(x);
          if (sym != vmwTrparen) vmwError("')' expected");
          sym = vmwGetToken();
          break;
     case vmwTplus:
     case vmwTminus:
     case vmwTbitnot:
     case vmwTboolnot:
     case vmwTsizeof:
       Unary(x);
       break;
     case vmwTplusplus:
     case vmwTminusminus:
       Prefix(x);
       break;
     case vmwTstring:
          {
	    
	     char temp[BUFSIZ];
	     Node obj;
	     Type typ;
	     sprintf(temp,"_l%i_%i",current_level,unique_string);
	     	  
	     typ=calloc(1,sizeof(TypeDesc));
  
             if (typ == NULL) {
                vmwError("Out of Memory");
             }
   
	     typ->size=strlen(vmwString);
             typ->form = CSGArray;
	     typ->base=CSGcharType;
	     
	     obj=AddToList(&globscope, temp);
	     obj->mode=CSGVar;
	     
	             obj->type=typ;
//	             obj->val=val;
	             obj->lev=current_level;
	     
//             InitObj(obj, CSGVar, NULL, NULL, 0);
	     
	     obj->initial_data=strdup(vmwString);
	     *x=obj;
	     
	  }
          sym=vmwGetToken();
          unique_string++;
       break;
     default: vmwError("factor expected"); break;
    }
    if ((sym==vmwTplusplus) || (sym==vmwTminusminus)) {
       Postfix(x);
    }
}









static void Term(Node *x) {
   
    register int op;
    NodeDesc y;
    Node yp=&y;
   
    Factor(x);

    while ((sym == vmwTtimes) || (sym == vmwTdiv) || (sym == vmwTmod)) {
       op = sym; 
       sym = vmwGetToken();
       Factor(&yp);
       CSGOp2(op, x, &yp);
    }
}

   
/*
 *     !
 * or  ~
 * or  ++
 * or  --
 * or  +
 * or  -
 * or  (type)
 * or  sizeof
 * or  *
 * or  &
 */

static void Unary(Node *x) {
   
   int op;
   Node obj;
   
   op=sym;
   sym=vmwGetToken();
   if ((sym==vmwTboolnot) ||
	  (sym==vmwTbitnot) ||
	  (sym==vmwTplus) ||
	  (sym==vmwTminus) ||
	  (sym==vmwTtimes) ||
	  (sym==vmwTbitand)) {
        Unary(x);
   }

   else {

      if (op==vmwTsizeof) {

	 if (sym!=vmwTlparen) {
	    vmwError("'(' expected");
         }
         sym=vmwGetToken();

	 obj=NULL;
	 
	 if (sym==vmwTident) {
	    obj=FindNode(&globscope, vmwId);
	    if (obj==NULL) vmwError("Unknown identifier");
	 }
	 else if (sym==vmwTlong) {
	    obj=FindNode(&globscope, "long");
	 }
	 else if (sym==vmwTint) {
	    obj=FindNode(&globscope, "int");
	 }
	 else if (sym==vmwTchar) {
	    obj=FindNode(&globscope, "char");
	 }
	 else if (sym==vmwTvoid) {
	    obj=FindNode(&globscope, "void");
	 }
      
         if (obj==NULL) vmwError("sizeof an unkown type");
	 
         *x=CSGMakeConstNode(&globscope,CSGlongType,obj->type->size);
   
	 sym=vmwGetToken();
	 if (sym!=vmwTrparen) vmwError("')' expected");
	 sym=vmwGetToken();
	 return;

      }
      
      else {
         Factor(x);
      }

   }

   CSGOp1(op, x);

}


static void AddSubtract(Node *x) {
   
    int op;
    NodeDesc y;
    Node yp=&y;

    Term(x);
  
    while ((sym == vmwTplus) || (sym == vmwTminus)) {
       op = sym; 
       sym = vmwGetToken();
       Term(&yp);
       CSGOp2(op, x, &yp);
    }   
}

static void SimpleExpression(Node *x) {
 
    int op;
    NodeDesc y;
    Node yp=&y;
    
    AddSubtract(x);
   
    while ((sym==vmwTrshift) || (sym==vmwTlshift)) {
       op=sym;
       sym=vmwGetToken();
       AddSubtract(&yp);
       CSGOp2(op,x,&yp);  
    }
}


static void EqualityExpr(Node *x) {
   
  register int op;
  NodeDesc y;
  Node yp=&y;

  SimpleExpression(x);
  if ((sym == vmwTlss) || (sym == vmwTleq) || (sym == vmwTgtr) || (sym == vmwTgeq)) {
    op = sym; 
    sym = vmwGetToken();
    SimpleExpression(&yp);
    CSGRelation(op, x, &yp);
  }
}


    /* Looking for an expression */
static void Expression(Node *x) {
   
    register int op;
    NodeDesc y;
    Node yp=&y;

    EqualityExpr(x);
   
       /* If == or != get other side? */
    if ((sym == vmwTeql) || (sym == vmwTneq)) {
       op = sym; 
       sym = vmwGetToken();
       EqualityExpr(&yp);
       CSGRelation(op, x, &yp);
    }
   
}



    /* Be sure it's a constant expression */
static void ConstExpression(Node *expr) {
  
    Expression(expr);
     
    if ( (*expr)->mode != CSGConst) {
       vmwError("constant expression expected");
    }
}


static void VariableDeclaration(Node * const root);


    /* Get all the fields in a struct */
static void FieldList(const Type type) {
  
    register Node curr;

       /* Get all the variable declarations  */
       /* Link them as a linked list on type->fields*/
    VariableDeclaration(&(type->fields));
  
    while (sym != vmwTrbrace) {
       VariableDeclaration(&(type->fields));
    }
   
    curr=type->fields;
  
    if (curr==NULL) {
       vmwError("Empty structs are not allowed");
    }
   
    while (curr != NULL) {
       curr->mode = CSGFld;
       curr->val = type->size;
       type->size += curr->type->size;
       if (type->size > 0x7fffffff) {
	  vmwError("struct too large");
       }
       curr = curr->next;
    }
   
}



static void StructType(Type * const type) {
   
    register Node obj;
    register long oldinstruct;
    char id[vmwIdlen];

    sym=vmwGetToken();
  
       /* Error if not identifier */
    if (sym != vmwTident) {
       vmwError("Identifier Expected");
    }
   
    strncpy(id, vmwId, vmwIdlen);
    id[vmwIdlen-1]=0;
   
       /* Get next symbol */
    sym=vmwGetToken();
   
    if (sym != vmwTlbrace) {
       
          /* We are declaring with a name.  See if we know it */
       obj=FindNode(&globscope, id);
       if (obj==NULL) {
	  vmwError("unknown struct type");
       }
       
          /* If identifier isn't struct related, cause error */
       if ( (obj->mode != CSGTyp) || (obj->type->form != CSGStruct) ) { 
	  vmwError("struct type expected");
       }
       
       *type = obj->type;
  
    } else {
          /* We are declaring a new type of struct */
       sym = vmwGetToken();
       *type = calloc(1,sizeof(TypeDesc));
    
       if ((*type)==NULL) {
	  vmwError("out of memory");
       }
       (*type)->form = CSGStruct;
       (*type)->fields = NULL;
       (*type)->size = 0;
       oldinstruct = instruct;
       instruct = 1;

          /* Get all the fields */
       FieldList(*type);

       instruct = oldinstruct;

       
          /* Error if no closing brace */
       if (sym != vmwTrbrace) {
	  vmwError("'}' expected");
       }
       
       sym = vmwGetToken();
       obj = AddToList(&globscope, id);
       InitObj(obj, CSGTyp, NULL, *type, (*type)->size);
    }
}



    /* type part of a declaration */
static void TypeDeclaration(Type *type) {
   
    register Node obj;

       /* If a struct, handle it differently */
    if (sym == vmwTstruct) {
       StructType(type);
    } else {
       
       if ( (sym==vmwTfloat) || (sym==vmwTdouble) ) {
	  vmwError("Floating point not supported.\n");
       }
       else if ( (sym!=vmwTvoid) && (sym != vmwTlong) && 
		 (sym!= vmwTint) && (sym!=vmwTchar) ) {
	  vmwError("Type expected");
       }

#ifdef DEBUG
       printf("TypeDeclaration: Looking for node \"%s\"\n",vmwId);
#endif       
       obj=FindNode(&globscope, vmwId);
#ifdef DEBUG       
       printf("Found: %p %p\n",obj,obj->type);
#endif       
          /* Get next symbol */
       sym=vmwGetToken();
    
          /* The type there doesn't exist.  Error! */
       if (obj==NULL) {
	  vmwError("Unknown type!");
       }
       
          /* We found something, but it wasn't a type! */
       if (obj->mode != CSGTyp) {
	  vmwError("type expected");
       }
       
       *type = obj->type;
    }   
}


    /* We have an array, set it up */
static void RecurseArray(Node *x,Type *type) {
 
    register Type typ;
    NodeDesc expr;
    Node exprp=&expr;
    int auto_detect_size=0;
   
   
//    printf("Entering!\n");
   
    sym=vmwGetToken();
   
    if (sym==vmwTrbrak) {
       auto_detect_size=1;

    }
    else {   	
	
   
          /* Get the size */
       ConstExpression(&exprp);
     
       if (exprp->type != CSGlongType) {
          vmwError("constant long expression required");
       }
    }
   
       /* Look for closing bracket */
    if (sym != vmwTrbrak) {
       vmwError("']' expected");
    }
   
       /* See if we have another dimension */
    sym = vmwGetToken();
    if (sym == vmwTlbrak) {
   
       if (auto_detect_size) vmwError("Can only auto-size last dimesion!");
          /* Recursively handle other dimensions */
       RecurseArray(x,type);
    }
   
    typ=calloc(1,sizeof(TypeDesc));
  
    if (typ == NULL) {
       vmwError("Out of Memory");
    }
   
    typ->form = CSGArray;

    if (auto_detect_size) {
       if (sym!=vmwTbecomes) vmwError("Must have = if auto-detect");	
       sym=vmwGetToken();
       if (sym!=vmwTstring) vmwError("Only support auto-detect of strings");
       typ->len=strlen(vmwString);
       sym=vmwGetToken();
       (*x)->initial_data=strdup(vmwString);
       
    }
    else {	
       typ->len = exprp->val;
    }
   
    typ->base = *type;
//    printf("typ len=%i  base-size=%i\n",typ->len,typ->base->len);
   
    if (0x7fffffff / typ->len < typ->base->size) {
       vmwError("Array size too large");
    }

   
    typ->size = typ->len * typ->base->size;
    *type = typ;


   
}


    /* Identify any vars/functions/arrays that may be lurking */
static void IdentArray(Node *root, Type type) {
  
    Node obj;
    char temp_id[BUFSIZ];
   
    if (sym==vmwTtimes) vmwError("Pointer");
   
    if (sym != vmwTident) {
       vmwError("identifier expected 2");
    }
   
    strncpy(temp_id,vmwId,BUFSIZ);
    
    sym = vmwGetToken();

   
   if (sym==vmwTlparen) {
      ProcedureDeclaration(temp_id);
   } else {	
       obj=AddToList(root, temp_id);	   
      
          /* If bracket, we have an array */
       if (sym == vmwTlbrak) {
          RecurseArray(&obj,&type);
       }


          /* Init the object */
       InitObj(obj, CSGVar, NULL, type, 0);

       if ( (obj->type==CSGlongType) ||
	    (obj->type==CSGshortType) ||
	    (obj->type==CSGvoidType) ||
	    (obj->type==CSGcharType) ||
	    (obj->type==CSGintType) ) {
          obj->var_list=AddToList( &(obj->var_list),NULL);
          obj->current=obj->var_list;
          obj->var_list->master=obj;
          obj->var_list->current=first_instruction;
       }
   }
   
}



    /* Handle a list of comma separated var names */
static void IdentList(Node *root, const Type type) {
  
    NodeDesc xv,yv;
    Node x=&xv,y=&yv;
   
       /* Check to see if Array */
    IdentArray(root, type);
  
    while ((sym == vmwTcomma) || (sym==vmwTbecomes)) {
       
       if (sym==vmwTcomma) {
          sym = vmwGetToken();
          IdentArray(root, type);
       }
       else {
	  sym=vmwGetToken();
	  if ((sym!=vmwTnumber) && (sym!=vmwTstring)) vmwError("Expected a constant value");
	  
	  x = FindNode(&globscope, vmwId);
	  
	  if (sym==vmwTnumber) {
	     if (current_level==0) {
		int *bob;
		
		bob=calloc(1,sizeof(int));
		*bob=vmwVal;
		x->initial_data=bob;
	     }
	     
	     else {
		y=CSGMakeConstNode(&x, CSGlongType, vmwVal);
	        CSGStore(&x, &y);
	     }
	     
	  }
	  else {
	     x->initial_data=strdup(vmwString);
//	     y=CSGMakeStringNode(&x, vmwString);  
	  }
          
	  sym=vmwGetToken();
       }
    }
   
}


static void VariableDeclaration(Node *root) {
   
    Type type;

    TypeDeclaration(&type);
   
    IdentList(root, type);
   
    if (sym != vmwTsemicolon) vmwError("';' expected");
   
    sym = vmwGetToken();
   
}


    /* Handle a constant declaration */
static void ConstantDeclaration(Node * const root) {
   
    register Node obj;
    Type type;
    NodeDesc expr;
    Node exprp=&expr;
    char id[vmwIdlen];

       /* Point to next symbol */
    sym=vmwGetToken();
   
       /* Get the type of the constant */
    TypeDeclaration(&type);
   
    if (type != CSGlongType) {
       vmwError("Only const long supported");
    }
   
       /* We should be at an identifier */
    if (sym != vmwTident) {
       vmwError("identifier expected 1");
    }
   
    strncpy(id, vmwId, vmwIdlen);
    id[vmwIdlen-1]=0;
   
    sym = vmwGetToken();
   
       /* If defining a constant we'd better have a equals sign */
    if (sym!=vmwTbecomes) {
       vmwError("'=' expected");
    }
   
    sym = vmwGetToken();
   
       /* Get the value of the constant */
    ConstExpression(&exprp);
  
       /* We only support long */
    if (exprp->type != CSGlongType) {
       vmwError("constant long expression required");
    }
         
    obj = AddToList(root, id);
  
    obj->mode=CSGConst;
    obj->val=exprp->val;
    obj->type=type;
//    InitObj(obj, CSGConst, NULL, type, exprp->val);
   
   
    if (sym != vmwTsemicolon) vmwError("';' expected");
    sym = vmwGetToken();
}


    /* Checks identifier for a "." struct access */
    /* or a [] array access.  Returns after pointing */
    /* to proper offset */

static void DesignatorM(Node *x, int load) {
  
    Node obj;
    NodeDesc y;
    Node yp=&y;
   
    NodeDesc oldy;
    Node oldyp=&oldy;

    Type curr_type;
       
    int first=1,first_array=1;
   
       /* vmwTident already consumed */
    while ((sym == vmwTperiod) || (sym == vmwTlbrak)) {
       
       if (sym == vmwTperiod) {
	  
	  if (first) {
	     curr_type=(*x)->type;
	     first=0;
	  }
	  
          sym = vmwGetToken();
	
          if ( (*x)->type->form != CSGStruct) vmwError("struct type expected");
	  
          if (sym != vmwTident) vmwError("field identifier expected");
          obj = FindNode( &((*x)->type->fields), vmwId);
		  
          sym = vmwGetToken();
          if (obj == NULL) vmwError("unknown identifier 2");
	  if ((sym==vmwTperiod) || (sym==vmwTlbrak)) {  
             *x=CSGField(x, &obj, 0, &curr_type);
	  }
	  else {
	     *x=CSGField(x, &obj,load,&curr_type);
	  }
	  
	  
	  
       } else {
//	  printf("[\n");
          sym = vmwGetToken();

//	  if ( (*x)->name!=NULL) printf("%s\n",(*x)->name);
          if ( (*x)->type->form != CSGArray) vmwError("array type expected");
          
//	  printf("Before expression\n");
          /* get the index expression */
	  Expression(&yp);
//	  printf("After expression\n");	  
          if (first) {
	     curr_type=(*x)->type;
	     first=0;
	  }
	  
	  if (first_array) {
	     oldyp=yp;
	  }
	  
	       
	  
//	  printf("Before Bracket %s\n",(*x)->name);
	  /* send it off to ir generator */
	  *x=CSGBracket(x, &yp, first_array, &oldyp, &curr_type);
//	  zp=CSGBracket(x, &yp, first,&oldyp);
//          printf("After Bracket\n");
	  oldyp=yp;
	     first_array=0;	  
	  
//	  printf("]\n");
	  
	  /* we should have the closing bracket */
          if (sym != vmwTrbrak) vmwError("']' expected");
          
 
	  /* get the next symbol */
	  sym = vmwGetToken();
	  
	  if (sym!=vmwTlbrak) {
	     if (sym==vmwTperiod) {
		/* Don't do load of value */
		/* If we have offsets to add still */
		/* x= address of x[yp] no load */
		*x=CSGIndex(x,&yp,0);
	     }
	     else {
		/* If done with . and [] then actually load the value */
		/* x= value of x[yp] */
	        *x=CSGIndex(x,&yp,load);
	     }
	     
	  } else {

	            /* x[yp] , don't load*/
//	        zp=CSGIndex(x,&yp,0);
	  
	  }
	  
	  
	  
	  
       }
       
    }
   
//    vmwDumpNode(*x);
   
}


   /* Node x is being assigned a value */
static void AssignmentM(Node *x) {
  
    NodeDesc y;
    Node yp=&y;

       /* vmwTident already consumed */
       /* See if we have struct elements to worry about */
    DesignatorM(x,0);
    if (sym != vmwTbecomes) vmwError("'=' expected");
    sym = vmwGetToken();
    Expression(&yp);
       
      /* yp is being stored to x*/
    CSGStore(x, &yp);
    
}


static void ExpList(Node *proc) {
  
    register Node curr;
    NodeDesc x;
    Node xp=&x;
   
    curr = (*proc)->dsc;
    printf("curr=%p\n",curr);
    Expression(&xp);
   
    if ((curr == NULL) || (curr->dsc != *proc)) 
       vmwError("Wrong number of parameters");


   
//    if (xp->type != curr->type) vmwError("incorrect type 1");

    CSGParameter(&xp, curr->type, curr->mode);

    curr = curr->next;

    while (sym == vmwTcomma) {

       sym = vmwGetToken();
       Expression(&xp);
       if ((curr == NULL) || (curr->dsc != *proc)) vmwError("Wrong number of parameters");
       if (xp->type != curr->type) vmwError("incorrect type 2");
       CSGParameter(&xp, curr->type, curr->mode);
       curr = curr->next;
    }
    if ((curr != NULL) && (curr->dsc == *proc)) vmwError("too few parameters");
}


static void ProcedureCallM(Node *x) {
  
    NodeDesc y;
    Node yp=&y;
   
       /* vmwTident already consumed */   
    if (sym != vmwTlparen) vmwError("'(' expected");
    sym = vmwGetToken();
   
    if ( (*x)->mode == CSGSProc) {
          /* Read */
       if ( (*x)->val == 1) {
          if (sym != vmwTident) vmwError("identifier expected 3");
      
	  yp = FindNode(&globscope, vmwId);
	  
          if (yp == NULL) vmwError("unknown identifier 3");

          sym = vmwGetToken();  // consume ident before calling Designator
          DesignatorM(&yp,0);
	  
	  /* Write */
    } else if ( (*x)->val == 2) {
       Expression(&yp);
    }
       
    CSGIOCall(x, &yp);
  } else {
    if (sym != vmwTrparen) {
      ExpList(x);
    } else {
      if (( (*x)->dsc != NULL) && ( (*x)->dsc->dsc == *x)) vmwError("too few parameters");
    }
    CSGCall(x);
  }
  if (sym != vmwTrparen) vmwError("')' expected");
  sym = vmwGetToken();
//  if (sym != vmwTsemicolon) vmwError("';' expected");
//  sym = vmwGetToken();
}


static void StatementSequence(void);



struct saved_vars_type{
   Node master;
   Node current;
};
   
struct saved_vars_master{
    int vars_to_save;
    struct saved_vars_type *var_list;
};

static struct saved_vars_master *save_vars(void) {

    Node var_list;
   
    struct saved_vars_master *saved_vars;
    int vars_to_save;
   
    var_list=globscope;
    vars_to_save=0;
    while(var_list!=NULL) {
       if (var_list->mode==CSGVar) {
	  vars_to_save++;
       }
       var_list=var_list->next;
    }
    saved_vars=calloc(1,sizeof(struct saved_vars_master));
    saved_vars->var_list=calloc(sizeof(struct saved_vars_type),vars_to_save);
    if ((saved_vars==NULL) || (saved_vars->var_list==NULL)) vmwError("malloc");
   
    saved_vars->vars_to_save=vars_to_save;
   
    var_list=globscope;
    vars_to_save=0;
    while(var_list!=NULL) {
       if (var_list->mode==CSGVar) {
	  saved_vars->var_list[vars_to_save].master=var_list->master;
	  saved_vars->var_list[vars_to_save].current=(var_list->current);
	  vars_to_save++;
       }
       var_list=var_list->next;
    }
    return saved_vars;
}

static void restore_vars(struct saved_vars_master *saved_vars) {
   
    int i;
   
    i=0;
    while(i<saved_vars->vars_to_save) {          	  
       (saved_vars->var_list[i].master)->current=saved_vars->var_list[i].current;
       i++;
    }
    free(saved_vars->var_list);
}

static void IfStatement(void) {
   
    NodeDesc x;
    Node xp=&x;


   
    struct saved_vars_master *saved_vars;
      
    Node conditional_branch=NULL,then_block_branch=NULL;
    Block if_b=NULL,then_b=NULL,else_b=NULL,join_b=NULL;
    Block old_phi_value=NULL;
    int old_current_path;
   
   
    old_phi_value=current_phi_block;
    old_current_path=current_path;
   
       /* We are inside an if block */
    current_depth++;
   
    if_b=current_block;
   
    sym = vmwGetToken();

       /* Handle the conditional test */
    if (sym != vmwTlparen) vmwError("'(' expected");
    sym = vmwGetToken();
    Expression(&xp);
    if (sym != vmwTrparen) vmwError("')' expected");
    sym = vmwGetToken();

       /* Store the branch node */
    conditional_branch=xp;
   
      
       /* Create Then Block */
    then_b=InsertBlock(&current_block,blockThen,current_level);
    then_b->rdom=if_b;
    if_b->fail=then_b;
   
       /* Create Join Block */
    join_b=InsertBlock(&then_b,blockIfJoin,current_level);
    join_b->rdom=if_b; 
    if_b->branch=join_b;    
 
       /* Put all phi's in join block */
    current_phi_block=join_b;
       /* We are in then path */
    current_path=0;

    /* SAVE ALL VAR CURRENTS */
   saved_vars=save_vars();
/*        
    var_list=globscope;
    vars_to_save=0;
    while(var_list!=NULL) {
       if (var_list->mode==CSGVar) {
	  vars_to_save++;
       }
       var_list=var_list->next;
    }
   
    saved_vars=calloc(sizeof(struct saved_vars_type),vars_to_save);
   
    var_list=globscope;
    vars_to_save=0;
    while(var_list!=NULL) {
       if (var_list->mode==CSGVar) {
	  saved_vars[vars_to_save].master=var_list->master;
	  saved_vars[vars_to_save].current=(var_list->current);
	  vars_to_save++;
       }
       var_list=var_list->next;
    }
  */ 
   
       /* Enter Then Block */
    current_block=then_b;
   
       /* Handle instructions in then block */
    if (sym != vmwTlbrace) vmwError("'{' expected");
    sym = vmwGetToken();
    StatementSequence();
    if (sym != vmwTrbrace) vmwError("'}' expected");
    sym = vmwGetToken();
   
       /* Finished with then_block, point branch to proper place */
    current_block->branch=join_b;
    current_phi_block=join_b;   
    current_path=old_current_path;
   
       /* Handle Else Block */

    if (sym == vmwTelse) {
       current_path=1;           
       else_b=InsertBlock(&current_block,blockElse,current_level);       
       else_b->rdom=if_b;
          
       if_b->branch=else_b;
       
       then_block_branch=xp;
             
       current_block=else_b;
       
       sym = vmwGetToken();
       if (sym != vmwTlbrace) vmwError("'{' expected");
       sym = vmwGetToken();

       /* RESTORE VAR->CURRENTS TO PREVIOUS VALUES */
       restore_vars(saved_vars);
/*
       i=0;
       while(i<vars_to_save) {          	  
	  (saved_vars[i].master)->current=saved_vars[i].current;
	  i++;
       }
       free(saved_vars);
*/
       
       
       StatementSequence();
       
       
       if (sym != vmwTrbrace) vmwError("'}' expected");
       sym = vmwGetToken();
      
       current_block->branch=join_b;
    }
   
       /* If we had an else, fix up some things */
    if (else_b!=NULL) {
       
  //     if_b->branch=else_b;
  //     if (then_b->branch==NULL) {
  //        then_b->branch=join_b;
  //        then_b->fail=NULL;
  //     }
 
   //    if (else_b->branch==NULL) {
//	  else_b->fail=join_b;
  //        else_b->branch=NULL;
    //   }
  
       conditional_branch->jump_target=if_b->branch;
//       conditional_branch->y=CSGMakeJumpNode(&globscope,if_b->branch);       
       //conditional_branch->ytype=CSGJmp;
      //        if (if_b->branch==NULL) printf("BAIRE\n");
//       then_block_branch->x=CSGMakeJumpNode(&globscope,join_b);
//       then_block_branch->xtype=CSGJmp;
       
    }
    else {
//       if_b->branch=join_b;
//       then_b->fail=join_b;

       conditional_branch->jump_target=join_b;
//       if (join_b==NULL) printf("AIRE\n");
       
//       conditional_branch->y=CSGMakeJumpNode(&globscope,join_b);
       //conditional_branch->ytype=CSGJmp;
    }
      

    current_block=join_b;
    
    CloseOutPhis(current_phi_block,old_phi_value,old_current_path); 

    current_phi_block=old_phi_value;
    current_path=old_current_path;
   
    current_depth--;   
}


static void WhileStatement(void) {
   
    NodeDesc x;
    Node xp=&x;
   
    Block head_block=NULL,body_block=NULL,join_block=NULL;

    Block old_phi_value=NULL;
    int old_current_path;
   
    old_current_path=current_path;
   
    old_phi_value=current_phi_block;

    head_block=InsertBlock(&current_block,blockWhileHead,current_level);
    head_block->rdom=current_block;
    current_block->fail=head_block;
    
    current_block=head_block;
    
       /* setup phis to go here */
    current_phi_block=head_block;

    current_depth++;
    current_path=1;
   
       /* Get the conditional and handle it */
    sym = vmwGetToken();
    if (sym != vmwTlparen) vmwError("'(' expected");
    sym = vmwGetToken();
    Expression(&xp);
    //CSGTestBool(&x);
    if (sym != vmwTrparen) vmwError("')' expected");
    sym = vmwGetToken();
    if (sym != vmwTlbrace) vmwError("'{' expected");
    sym = vmwGetToken();
 
       /* Create Body Block */
    body_block=InsertBlock(&head_block,blockWhileBody,current_level);
    current_block=body_block;
    body_block->rdom=head_block;
     
       /* Run Body Block */
    StatementSequence();
    if (sym != vmwTrbrace) vmwError("'}' expected");
  
    current_block->fail=NULL;
    current_block->branch=head_block;
   
       /* Reset phi block */
    current_phi_block=head_block;
//    add_instruction(current_block,End,vmwBr,CSGMakeJumpNode(&globscope, head_block),NULL,0);

   
       /* Create Join Block */
    join_block=InsertBlock(&current_block,blockWhileJoin,current_level);

    current_block=join_block;
    join_block->rdom=head_block;

    head_block->last->jump_target=join_block;
//    if (join_block==NULL) printf("QUQUQUUQ\n");
   
//    head_block->last->y=CSGMakeJumpNode(&globscope, join_block); 
//    head_block->last->ytype=CSGJmp;	

    head_block->branch=join_block;
    head_block->fail=body_block;
//    body_block->fail=NULL;
//    body_block->branch=head_block;

    sym = vmwGetToken();

    CloseOutPhis(current_phi_block,old_phi_value,old_current_path); 
   
    current_phi_block=old_phi_value;

    current_path=old_current_path;

    current_depth--;
}

   /* Looks for "for" then
    * (
    * STATEMENT
    * ;
    * EXPRESSION
    * ;
    * STATEMENT
    * ) 
    * {
    * STATEMENTLIST
    * }
    */

static void ForStatement(void) {
   
    NodeDesc x;
    Node xp=&x;
    Node temp_node;

    struct saved_vars_master *saved_vars;
   
    Block head_block=NULL,body_block=NULL,join_block=NULL,loser_block=NULL;

    Block old_phi_value=NULL;
    int old_current_path;
   
    old_current_path=current_path;
    old_phi_value=current_phi_block;

       /* Look for opening parenthesis */
    sym = vmwGetToken();
    if (sym != vmwTlparen) vmwError("'(' expected");
   
       /* Look for Initialization */
    sym = vmwGetToken();
    Statement();

       /* Look for semicolon */
    if (sym!=vmwTsemicolon) vmwError("';' expected");
    sym=vmwGetToken();
   
    head_block=InsertBlock(&current_block,blockWhileHead,current_level);
    head_block->rdom=current_block;
    current_block->fail=head_block;
    
    current_block=head_block;
    
       /* setup phis to go here */
    current_phi_block=head_block;

    current_depth++;
    current_path=1;
   

   
       /* Get the conditional and handle it */
    Expression(&xp);
    //CSGTestBool(&x);
    if (sym!=vmwTsemicolon) vmwError("';' expected");

    saved_vars=save_vars();
   
       /* Get the action and handle it */
    loser_block=calloc(1,sizeof(BlockDesc));
    current_block=loser_block;
    sym = vmwGetToken();
    Statement();

    restore_vars(saved_vars);
   
       /* We should be at the end */
    if (sym != vmwTrparen) vmwError("')' expected");
    sym = vmwGetToken();
    if (sym != vmwTlbrace) vmwError("'{' expected");
    sym = vmwGetToken();
 
       /* Create Body Block */
    body_block=InsertBlock(&head_block,blockWhileBody,current_level);
    current_block=body_block;
    body_block->rdom=head_block;
     
       /* Run Body Block */
    StatementSequence();
    if (sym != vmwTrbrace) vmwError("'}' expected");


   
   
       /* Move stuff from "loser block" into the end of this block */
    temp_node=loser_block->first;
    while(temp_node!=NULL) {
       
       if (current_block->last==NULL) {
          current_block->first=temp_node;
	  
       }
       else {
          current_block->last->next=temp_node;
	  temp_node->prev=current_block->last;
       }
       

       current_block->last=temp_node;
       
       
       temp_node=temp_node->next;
    }

   
    current_block->fail=NULL;
    current_block->branch=head_block;
   
       /* Reset phi block */
    current_phi_block=head_block;
   
       /* Create Join Block */
    join_block=InsertBlock(&current_block,blockWhileJoin,current_level);

    current_block=join_block;
    join_block->rdom=head_block;

    head_block->last->jump_target=join_block;

    head_block->branch=join_block;
    head_block->fail=body_block;

    sym = vmwGetToken();

    CloseOutPhis(current_phi_block,old_phi_value,old_current_path); 
   
    current_phi_block=old_phi_value;

    current_path=old_current_path;
   
    if (loser_block!=NULL) free(loser_block);
   
    current_depth--;
}



static void Statement(void) {
  
    Node temp_node;
    NodeDesc y;
    Node yp=&y;
   
    switch (sym) {
       case vmwTif:    IfStatement(); break;
       case vmwTwhile: WhileStatement(); break;
       case vmwTfor:   ForStatement(); break;
       case vmwTident: temp_node=FindNode(&globscope, vmwId);
                       if (temp_node==NULL) vmwError("unknown identifier 4");
                       sym=vmwGetToken();
                       if (sym==vmwTlparen) {
                          ProcedureCallM(&temp_node);
			  if (sym!=vmwTsemicolon) vmwError("Semicolon expected");
	               } else if ((sym==vmwTplusplus)||(sym==vmwTminusminus)) {
			  Postfix(&temp_node);
	               } else {
	                  AssignmentM(&temp_node);
	               }       
                       break;
       case vmwTreturn:
                        sym=vmwGetToken();
                        if (sym==vmwTsemicolon) {
			   yp=NULL;
			   CSGReturn(&yp);
			}
       
			else {
                           Expression(&yp);
                           CSGReturn(&yp);
                           sym=vmwGetToken();
			}
			   
                        break;
               
       case vmwTsemicolon: 
                           sym=vmwGetToken(); 
                           break;  /* empty statement */
       default: vmwError("unknown statement");
    }
   
}





static void StatementSequence(void) {
  
    while (sym != vmwTrbrace) {
       Statement();
    }
   
}



static void FPSection(Node * const root) {
   
    register Node obj;
    Type type;
    int pointer=0;

   
    TypeDeclaration(&type);
  
       /* First we have a type */
//    if (type != CSGlongType) {
//       vmwError("Only basic type formal parameters allowed");
//    }
   
    if (sym==vmwTtimes) {
       
       while(sym==vmwTtimes) {  
          pointer++;
          sym=vmwGetToken();
       }
       
    }
   
   

   
       /* Then an identifier */
    if (sym != vmwTident) {
       vmwError("identifier expected 4");
    }
   
    obj=AddToList(root,vmwId);

    sym = vmwGetToken();
  
    if (sym == vmwTlbrak) {
       vmwError("no array parameters allowed");
    }

    InitObj(obj, CSGVar, *root, type, 0);
    obj->master=obj;
    obj->parameter=1;
    obj->pointer=1;
    obj->block=current_block;

}


   /* Handle procedure parameters */
static void FormalParameters(Node * const root) {
   
    register Node curr;
    int num_regs=0;

    FPSection(root);
   
   
    while (sym == vmwTcomma) {
       sym = vmwGetToken();
       FPSection(root);
       num_regs++;
    }
    curr = (*root)->next;
    while (curr != NULL) {
       curr = curr->next;
    }
   
}

 
    /* Handle the procedure heading */
static int ProcedureHeading(Node *proc,char *name) {

  //  char name[vmwIdlen];

//    if (sym!=vmwTident) {
//       vmwError("function name expected");
//    }

    
   
//    strncpy(name, vmwId,vmwIdlen);
//    name[vmwIdlen-1]=0;
  
   /* HACK!  FIXME properly! */
     {

	int temp_scope;
	temp_scope=current_level;
	current_level=0;
        *proc = AddToList(&globscope, name);
  
	current_level=temp_scope;
     }
   
    InitObj(*proc, CSGProc, NULL, NULL, 0);
    
       /* Adjust scope */
    base_level=base_level+1;
    current_level=base_level;
   
//    sym = vmwGetToken();
  
       /* Look for parameters */
    if (sym != vmwTlparen) {
       vmwError("'(' expected");
    }
   
    CSGEnter(*proc);
   
    sym = vmwGetToken();
   
       /* Get parameters if any */
    if (sym != vmwTrparen) {
       FormalParameters(proc);
    }
  
       /* Look for close paren */
    if (sym != vmwTrparen) {
       vmwError("')' expected");
    }
   
    sym = vmwGetToken();
  
//    current_block->proc=*proc;
   
    if (strncmp(name, "main",vmwIdlen) == 0) {
       CSGEntryPoint();
       return 1;
    }
    return 0;
   
}


static void ProcedureBody(Node * const proc,int entry) {

       (*proc)->dsc = (*proc)->next;
   
       /* Handle declarations */
    while ( (sym == vmwTconst) || 
	    (sym == vmwTstruct) || 
	    (sym == vmwTlong) ||
	    (sym == vmwTint) ||
	    (sym == vmwTchar) ||
	    (sym == vmwTfloat) ||
	    (sym == vmwTdouble)) {
    
       if (sym == vmwTconst) {
          ConstantDeclaration(proc);
       } else {
          VariableDeclaration(proc);
       }
       
    }
   


  
   
       /* Setup procedure entry point */
    if (entry) current_block->entry=1;
   
    (*proc)->block=current_block;
   
    StatementSequence();
  
    if (strncmp((*proc)->name, "main",vmwIdlen) == 0) {
       CSGClose();
    } else {
       CSGEndProc();
    }
      /* Restore scope to global */
    current_level=0;
}


   /* do ProcedureHeading 
    *    {
    *    ProcedureBlock
    *    }
    */
static void ProcedureDeclaration(char *name) {
   
    Node proc;
    int entry;
    

    entry=ProcedureHeading(&proc,name);
  
       /* Look for beginning of block */
    if ((sym != vmwTlbrace) && (sym !=vmwTsemicolon)) {
       vmwError("'{' or ';' expected");
    }
   
    if (sym==vmwTsemicolon) {
       printf("Trying fix\n"); fflush(stdout);
           proc->dsc = proc->next;
           current_block->prototype=1;
//           proc->dsc->next=NULL;
       printf("Trying fix2\n"); fflush(stdout);
       return;
    }
   
    sym = vmwGetToken();
   
   
    ProcedureBody(&proc,entry);
     
       /* Look for closing block */
    if (sym != vmwTrbrace) {
       vmwError("'}' expected");
    }
   
      /* cheat, as this is what is expected on success */
    sym = vmwTsemicolon;
   
}


   /* Initial starting point of parser*/
   /* Looking for:
      const    -> Constant Declaration
      int      \
      long     |--- Variable Declaration
      char     |
      struct   /
      EOF      -> end
    */
static void Program(void) {

    CSGOpen();

    while (sym != vmwTeof) {
       switch (sym) {
	  case vmwTconst: ConstantDeclaration(&globscope); break;
	  case vmwTstruct:
          case vmwTvoid:
	  case vmwTint:
	  case vmwTlong:
	  case vmwTchar:  VariableDeclaration(&globscope); break;
	  default: vmwError("Definition expected"); break;
       }
    }
}



void vmwParse(char *filename) {

       /* Our Global, Root Pointer */
    globscope = NULL;
   
       /* Insert built in types */
    InsertNode(&globscope, CSGTyp, CSGlongType, "long", 4);
    InsertNode(&globscope, CSGTyp, CSGintType,  "int",  4);
    InsertNode(&globscope, CSGTyp, CSGcharType, "char", 1);
    InsertNode(&globscope, CSGTyp, CSGvoidType, "void", 4);
    InsertNode(&globscope, CSGTyp, CSGshortType,"short",2);
   
       /* Insert our FP and GP registers */
    FP=InsertNode(&globscope, CSGReg, NULL, "FP",4);
    GP=InsertNode(&globscope, CSGReg, NULL, "GP",4);
   
       /* Insert our 3 built-in functions */
    InsertNode(&globscope, CSGSProc, NULL, "ReadLong", 1);
    InsertNode(&globscope, CSGSProc, NULL, "WriteLong", 2);
    InsertNode(&globscope, CSGSProc, NULL, "WriteLine", 3);
 
       /* Open source file */
    vmwScannerInit(filename);

       /* Prime the parser */
    sym = vmwGetToken();

       /* Start parsing */
    Program();
}

