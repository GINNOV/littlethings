/* This file is part of GNU cflow
   Copyright (C) 1997-2019 Sergey Poznyakoff
 
   GNU cflow is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
 
   GNU cflow is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>. */

#include <cflow.h>
#include <parser.h>
#include <ctype.h>

typedef struct {
     char *name;
     int type_end;
     int parmcnt;
     int line;
     enum storage storage;
} Ident;

void parse_declaration(Ident*, int);
void parse_variable_declaration(Ident*, int);
void parse_function_declaration(Ident*, int);
void parse_dcl(Ident*, int maybe_knr);
void parse_knr_dcl(Ident*);
void parse_typedef();
void expression();
void initializer_list();
void func_body();
void declare(Ident*, int maybe_knr);
void declare_type(Ident*);
int dcl(Ident*);
int parmdcl(Ident*);
int dirdcl(Ident*);
void skip_struct();
Symbol *get_symbol(char *name);
void maybe_parm_list(int *parm_cnt_return);
    
void call(char*, int);
void reference(char*, int);

int level;                  /* Current nesting level */
Symbol *caller;             /* Current caller */
struct obstack text_stk;    /* Obstack for composing declaration line */

int parm_level;             /* Parameter declaration nesting level */

typedef struct {
     int type;
     char *token;
     int line;
} TOKSTK;

typedef int Stackpos[1];

TOKSTK tok;
TOKSTK *token_stack;
int tos;
int curs;
int token_stack_length = 64;
int token_stack_increase = 32;
static int need_space;

void mark(Stackpos);
void restore(Stackpos);
void tokpush(int,int,char*);
void save_token(TOKSTK *);

static void
print_token(TOKSTK *tokptr)
{
     switch (tokptr->type) {
     case IDENTIFIER:
     case TYPE:
     case WORD:
     case MODIFIER:
     case STRUCT:
     case PARM_WRAPPER:
     case QUALIFIER:
     case OP:
	  fprintf(stderr, "`%s'", tokptr->token);
	  break;
     case LBRACE0:
     case LBRACE:
	  fprintf(stderr, "`{'");
	  break;
     case RBRACE0:
     case RBRACE:
	  fprintf(stderr, "`}'");
	  break;
     case EXTERN:
	  fprintf(stderr, "`extern'");
	  break;
     case STATIC:
	  fprintf(stderr, "`static'");
	  break;
     case TYPEDEF:
	  fprintf(stderr, "`typedef'");
	  break;
     case STRING:
	  fprintf(stderr, "\"%s\"", tokptr->token);
	  break;
     default:
	  fprintf(stderr, "`%c'", tokptr->type);
     }
}

static char *
token_type_str(int t)
{
     static char buf[80];
     switch (t) {
     case 0:
	  return "EOF";
     case WORD:
	  return "WORD";
     case LBRACE0:
	  return "'{'";
     case RBRACE0:
	  return "'}'";
     case IDENTIFIER:
	  return "IDENTIFIER";
     case EXTERN:
	  return "EXTERN";
     case STATIC:
	  return "STATIC";
     case TYPEDEF:
	  return "TYPEDEF";
     case STRUCT:
	  return "STRUCT";
     case MODIFIER:
	  return "MODIFIER";
     case OP:
	  return "OP";
     case UNION:
	  return "UNION";
     case ENUM:
	  return "ENUM";
     case LBRACE:
	  return "' {'";
     case RBRACE:
	  return "' }'";
     case MEMBER_OF:
	  return "MEMBER_OF";
     case TYPE:
	  return "TYPE";
     case STRING:
	  return "STRING";
     case PARM_WRAPPER:
	  return "PARM_WRAPPER";
     case QUALIFIER:
	  return "QUALIFIER";
     }	  
     if (isprint(t))
	  snprintf(buf, sizeof(buf), "'%c'(%d)", t, t);
     else
	  snprintf(buf, sizeof(buf), "%d", t);
     return buf;
}

static void
dbgtok(TOKSTK *t, int delim)
{
     if (delim)
	  fputc(delim, stderr);
     fprintf(stderr, "{ %s ", token_type_str(t->type));
     if (t->type)
	  fprintf(stderr, ", %s, %d ", t->token ? t->token : "NULL", t->line);
     fputc('}', stderr);
}

static void
debugtoken(TOKSTK *t, char *fmt, ...)
{
     if (debug > 1) {
	  va_list ap;
	  int i;
	  
	  if (fmt) {
	       va_start(ap, fmt);
	       vfprintf(stderr, fmt, ap);
	       va_end(ap);
	       fprintf(stderr, ": ");
	  }
	  if (t) {
	       dbgtok(t, 0);
	       fprintf(stderr, "; ");
	  }
	  fprintf(stderr, "%d: {", curs);
	  for (i = curs; i < tos; i++)
	       dbgtok(token_stack + i, i == curs ? 0 : ',');
	  fprintf(stderr, "}\n");
     }
}

static void
file_error(char *msg, TOKSTK *tokptr)
{
    fprintf(stderr, "%s:%d: %s", filename, tok.line, msg);
    if (tokptr) {
	fprintf(stderr, _(" near "));
	print_token(tokptr);
    }
    fprintf(stderr, "\n");
}

void
mark(Stackpos pos)
{
     pos[0] = curs;
     if (debug > 1)
	  fprintf(stderr, "marking stack at %d\n", curs);
}

void
restore(Stackpos pos)
{
     curs = pos[0];
     if (curs) {
	  tok = token_stack[curs-1];
	  debugtoken(&tok, "restored stack");
     }
}

void
tokdel(int beg, int end)
{
     if (end >= beg) {
	  if (end < tos)
	       memmove(token_stack + beg, token_stack + end + 1,
		       (tos - end - 1) * sizeof(token_stack[0]));
	  tos -= (end - beg + 1);
     }
}

void
tokins(int pos, int type, int line, char *token)
{
     if (++tos == token_stack_length) {
	  token_stack_length += token_stack_increase;
	  token_stack = xrealloc(token_stack,
				 token_stack_length*sizeof(*token_stack));
     }
     memmove(token_stack + pos + 1, token_stack + pos,
	     (tos - pos - 1) * sizeof(token_stack[0]));
     token_stack[pos].type = type;
     token_stack[pos].token = token;
     token_stack[pos].line = line;
     debugtoken(&token_stack[pos], "insert at %d", pos);
}

void
tokpush(int type, int line, char *token)
{
     token_stack[tos].type = type;
     token_stack[tos].token = token;
     token_stack[tos].line = line;
     if (++tos == token_stack_length) {
	  token_stack_length += token_stack_increase;
	  token_stack = xrealloc(token_stack,
				 token_stack_length*sizeof(*token_stack));
     }
}

void
cleanup_stack()
{
     int delta = tos - curs;

     if (delta > 0) 
	  memmove(token_stack, token_stack+curs, delta*sizeof(token_stack[0]));
     else if (delta < 0) /* Invalid input */
	  delta = 0;
     tos = delta;
     curs = 0;
}

void
clearstack()
{
     tos = curs = 0;
}

int
nexttoken()
{
     int type;
     
     if (curs == tos) {
	  type = get_token();
	  tokpush(type, line_num, yylval.str);
	  yylval.str = NULL;
     }
     tok = token_stack[curs];
     curs++;
     debugtoken(&tok, "next token");
     return tok.type;
}

int
putback()
{
     if (curs == 0) {
	  error(0, 0, _("INTERNAL ERROR: cannot return token to stream"));
	  abort();
     }
     curs--;
     if (curs > 0) {
	  tok = token_stack[curs-1];
     } else
	  tok.type = 0;
     debugtoken(&tok, "putback");
     return tok.type;
}

void
init_parse()
{
     obstack_init(&text_stk);
     token_stack = xmalloc(token_stack_length*sizeof(*token_stack));
     clearstack();
}

void
save_token(TOKSTK *tokptr)
{
     int len;
    
     switch (tokptr->type) {
     case IDENTIFIER:
     case TYPE:
     case STRUCT:
     case PARM_WRAPPER:
     case WORD:
     case QUALIFIER:
	  if (need_space) 
	       obstack_1grow(&text_stk, ' ');
	  len = strlen(tokptr->token);
	  obstack_grow(&text_stk, tokptr->token, len);
	  need_space = 1;
	  break;
     case MODIFIER:
	  if (need_space) 
	       obstack_1grow(&text_stk, ' ');
	  if (tokptr->token[0] == '*') 
	       need_space = 0;
	  else
	       need_space = 1;
	  len = strlen(tokptr->token);
	  obstack_grow(&text_stk, tokptr->token, len);
	  break;
     case EXTERN: /* storage class specifiers are already taken care of */
     case STATIC:
	  break;
     case ',':
	  obstack_1grow(&text_stk, ',');
	  need_space = 1;
	  break;
     case '(':
	  if (need_space) 
	       obstack_1grow(&text_stk, ' ');
	  obstack_1grow(&text_stk, tokptr->type);
	  need_space = 0;
	  break;
     case ')':
	  obstack_1grow(&text_stk, tokptr->type);
	  need_space = 1;
	  break;
     case '[':
     case ']':
	  obstack_1grow(&text_stk, tokptr->type);
	  need_space = 0;
	  break;
     case LBRACE:
     case LBRACE0:
	  if (need_space) 
	       obstack_1grow(&text_stk, ' ');
	  obstack_1grow(&text_stk, '{');
	  need_space = 1;
	  break;
     case RBRACE:
     case RBRACE0:
	  if (need_space) 
	       obstack_1grow(&text_stk, ' ');
	  obstack_1grow(&text_stk, '}');
	  need_space = 1;
	  break;
     case OP:
	  obstack_1grow(&text_stk, ' ');
	  obstack_grow(&text_stk, tokptr->token, strlen(tokptr->token));
	  need_space = 1;
	  break;
     default:
	  if (verbose)
	       file_error(_("unrecognized definition"), tokptr);
     }
}

static Stackpos start_pos; /* Start position in stack for saving tokens */
static int save_end;       /* Stack position up to which the tokens are saved */

void
save_stack()
{
     mark(start_pos);
     save_end = curs - 1;
}

void
undo_save_stack()
{
     save_end = -1;
}

int
save_stack_is_empty()
{
     return save_end <= 0;
}
	  
char *
finish_save_stack(char *name)
{
     int i;
     int level = 0;
     int found_ident = !omit_symbol_names_option;

     need_space = 0;
     for (i = 0; i < save_end ; i++) {
	  switch (token_stack[i].type) {
	  case '(':
	       if (omit_arguments_option) {
		    if (level == 0) {
			 save_token(token_stack+i);
		    }
		    level++;
	       }
	       break;
	  case ')':
	       if (omit_arguments_option) 
		    level--;
	       break;
	  case IDENTIFIER:
	       if (!found_ident && strcmp (name, token_stack[i].token) == 0) {
		    need_space = 1;
		    found_ident = 1;
		    continue;
	       }
	  }
	  if (level == 0)
	       save_token(token_stack+i);
     }
     obstack_1grow(&text_stk, 0);
     return obstack_finish(&text_stk);
}

void
skip_to(int c)
{
     while (nexttoken()) {
	  if (tok.type == c)
	       break;
     }
}

int
skip_balanced(int open_tok, int close_tok, int level)
{
     if (level == 0) {
	  if (nexttoken() != open_tok) {
	       return 1;
	  }
	  level++;
     }
     while (nexttoken()) {
	  if (tok.type == LBRACE0 && open_tok == '{')
	       tok.type = '{';
	  else if (tok.type == RBRACE0 && close_tok == '}')
	       tok.type = '}';
	  
	  if (tok.type == open_tok) 
	       level++;
	  else if (tok.type == close_tok) {
	       if (--level == 0) {
		    nexttoken();
		    return 0;
	       }
	  } 
     }
     return -1;
}

int
yyparse()
{
     Ident identifier;

     level = 0;
     caller = NULL;
     clearstack();
     while (nexttoken()) {
	  identifier.storage = ExternStorage;
	  switch (tok.type) {
	  case 0:
	       return 0;
	  case QUALIFIER:
	       continue;
	  case TYPEDEF:
	       parse_typedef();
	       break;
	  case EXTERN:
	       identifier.storage = ExplicitExternStorage;
	       parse_declaration(&identifier, 0);
	       break;
	  case STATIC:
	       identifier.storage = StaticStorage;
	       nexttoken();
	       /* FALLTHRU */
	  default:
	       parse_declaration(&identifier, 0);
	       break;
	  }
	  cleanup_stack();
     }
     return 0;
}

static int
is_function()
{
     Stackpos sp;
     int res = 0;

     mark(sp);
     while (1) {
	  switch (tok.type) {
	  case QUALIFIER:
	  case TYPE:
	  case IDENTIFIER:
	  case MODIFIER:
	  case STATIC:
	  case EXTERN:
	  case STRUCT:
	  case UNION:
	  case ENUM:
	       nexttoken();
	       continue;
	  case PARM_WRAPPER:
	       if (skip_balanced('(', ')', 0) == -1)
		    file_error(_("unexpected end of file in declaration"),
			       NULL);
	       continue;
	  case '(':
	       res = nexttoken() != MODIFIER;
	       break;
	  default:
	       break;
	  }
	  break;
     }
     
     restore(sp);
     return res;
}

void
parse_declaration(Ident *ident, int parm)
{
     if (is_function()) 
	  parse_function_declaration(ident, parm);
     else
	  parse_variable_declaration(ident, parm);
     delete_parms(parm_level);
}


void
expression()
{
     char *name;
     int line;
     int parens_lev;

     parens_lev = 0;
     while (1) {
	  switch (tok.type) {
	  case ';':
	       return;
	  case LBRACE:
	  case LBRACE0:
	  case RBRACE:
	  case RBRACE0:
	       putback();
	       return;
	  case ',':
	       if (parens_lev == 0)
		    return;
	       break;
	  case 0:
	       if (verbose)
		    file_error(_("unexpected end of file in expression"),
			       NULL);
	       return;
	    
	  case IDENTIFIER:
	       name = tok.token;
	       line = tok.line;
	       nexttoken();
	       if (tok.type == '(') {
		    call(name, line);
		    parens_lev++;
	       } else {
		    reference(name, line);

		    /* MEMBER_OF can be preceded by a closing paren, as in
		       (*a)->b
		    */
		    while (parens_lev > 0 && tok.type == ')') {
			 parens_lev--;
			 nexttoken();
		    }

		    if (tok.type == MEMBER_OF) {
			 nexttoken();
		    } else {
			 putback();
		    }
	       }
	       break;
	  case '(':
	       /* maybe typecast */
	       if (nexttoken() == TYPE || tok.type == STRUCT)
		    skip_to(')');
	       else {
		    putback();
		    parens_lev++;
	       }
	       break;
	  case ')':
	       parens_lev--;
	       break;
	  case MEMBER_OF:
	       nexttoken();
	       break;
	  }
	  nexttoken();
     }
}

void
parse_function_declaration(Ident *ident, int parm)
{
     int error_recovery = 0;
     ident->type_end = -1;
     parse_knr_dcl(ident);

 restart:
     switch (tok.type) {
     case ')':
	  if (parm)
	       break;
	  /*FALLTHROUGH*/
     default:
	  if (error_recovery) 
	       nexttoken();
	  else {
	       if (verbose) 
		    file_error(_("expected `;'"), &tok);
	       error_recovery = 1;
	  }
	  goto restart;
	  
     case ';':
     case ',':
	  break;
     case LBRACE0:
     case LBRACE:
	  if (ident->name) {
	       caller = lookup(ident->name);
	       if (caller && caller->storage == AutoStorage)
		    caller = NULL;
	       func_body();
	  }
	  break;
     case 0:
	  if (verbose)
	       file_error(_("unexpected end of file in declaration"), NULL);
     }
}

int
fake_struct(Ident *ident)
{
     ident->type_end = -1;
     if (tok.type == STRUCT) {
	  if (nexttoken() == IDENTIFIER) {
	       ident->type_end = curs;
	  }
	  putback();
	  skip_struct();
	  if (tok.type == IDENTIFIER || tok.type == MODIFIER || tok.type == QUALIFIER) {
	       putback();
	  } else if (tok.type == '(')
	       return 0;
	  else if (tok.type != ';')
	       file_error(_("missing `;' after struct declaration"), &tok);
	  return 1;
     }
     return 0;
}

void
parse_variable_declaration(Ident *ident, int parm)
{
     Stackpos sp;
     
     mark(sp);
     ident->type_end = -1;
     if (tok.type == STRUCT || tok.type == UNION) {
	  if (nexttoken() == IDENTIFIER) {
	       ident->type_end = curs;
	  }
	  putback();
	  skip_struct();
	  while (tok.type == MODIFIER || tok.type == QUALIFIER)
	       nexttoken();
	  if (tok.type == IDENTIFIER) {
	       if (ident->type_end == -1) {
		    int pos = curs-1;
		    restore(sp);
		    /* there was no tag. Insert { ... } */
		    tokdel(curs, pos - 1);
		    tokins(curs, IDENTIFIER, tok.line, "{ ... }");
		    debugtoken(&tok, "modified stack");
	       }
	  } else {
	       if (tok.type == ';')
		    return;
	       restore(sp);
	  }
     }
 again:
     parse_dcl(ident, 0);
     
 select:    
     switch (tok.type) {
     case ')':
	  if (parm)
	       break;
	  /*FALLTHROUGH*/
     default:
	  if (verbose) 
	       file_error(_("expected `;'"), &tok);
	  /* FIXME: should putback() here */
	  /* FALLTHRU */
     case ';':
	  break;
     case ',':
	  if (parm)
	       break;
	  tos = ident->type_end;
	  restore(sp);
	  goto again;
     case '=':
	  nexttoken();
	  if (tok.type == LBRACE || tok.type == LBRACE0)
	       initializer_list();
	  else
	       expression();
	  goto select;
     case LBRACE0:
     case LBRACE:
	  func_body();
	  break;
     case 0:
	  if (verbose)
	       file_error(_("unexpected end of file in declaration"), NULL);
     }
}

void
initializer_list()
{
     int lev = 0;
     while (1) {
	  switch (tok.type) {
	  case LBRACE:
	  case LBRACE0:
	       lev++;
	       break;
	  case RBRACE:
	  case RBRACE0:
	       if (--lev <= 0) {
		    nexttoken();
		    return;
	       }
	       break;
	  case 0:
	       file_error(_("unexpected end of file in initializer list"),
			  NULL);
	       return;
	  case ',':
	       break;
	  default:
	       expression();
	       break;
	  }
	  nexttoken();
     }
}

void
parse_knr_dcl(Ident *ident)
{
     ident->type_end = -1;
     parse_dcl(ident, !strict_ansi);     
}

void
skip_struct()
{
     if (nexttoken() == IDENTIFIER) {
	  nexttoken();
     } else if (tok.type == ';')
	  return;
     
     if (tok.type == LBRACE || tok.type == LBRACE0) {
	  if (skip_balanced('{', '}', 1) == -1) {
	       file_error(_("unexpected end of file in struct"), NULL);
	       return;
	  }
     }

     while (tok.type == PARM_WRAPPER) {
	  if (skip_balanced('(', ')', 0) == -1) {
	      file_error(_("unexpected end of file in struct"), NULL);
	      return;
	  }
     }
}

void
parse_typedef()
{
     Ident ident;
     
     ident.name = NULL;
     ident.type_end = -1;
     ident.parmcnt = -1;
     ident.line = -1;
     ident.storage = AnyStorage;
     
     nexttoken();
     if (!fake_struct(&ident))
	  putback();
     
     dcl(&ident);
     if (ident.name) 
	  declare_type(&ident);
}

void
parse_dcl(Ident *ident, int maybe_knr)
{
     ident->parmcnt = -1;
     ident->name = NULL;
     putback();
     dcl(ident);
     save_stack();
     if (ident->name)
	  declare(ident, maybe_knr);
     else 
	  undo_save_stack();
}

int
dcl(Ident *idptr)
{
     while (nexttoken() != 0 && tok.type != '(') {
	  if (tok.type == MODIFIER) {
	       if (idptr && idptr->type_end == -1)
		    idptr->type_end = curs-1;
	  } else if (tok.type == PARM_WRAPPER) {
	       if (skip_balanced('(', ')', 0) == -1) {
		    file_error(_("unexpected end of file in function declaration"),
			       NULL);
		    return 1;
	       }
	  } else if (tok.type == IDENTIFIER) {
	       int type;
	       
	       while (tok.type == IDENTIFIER)
		    nexttoken();
	       type = tok.type;
	       putback();
	       if (!(type == TYPE ||
		     type == MODIFIER || type == QUALIFIER))
		    break;
	  } else if (tok.type == ')' || tok.type == ';') {
	       return 1;
	  }
     }
     if (idptr && idptr->type_end == -1)
	  idptr->type_end = curs-1;
     return dirdcl(idptr);
}

int
dirdcl(Ident *idptr)
{
     int wrapper = 0;
     int *parm_ptr = NULL;
     
     if (tok.type == '(') {
	  dcl(idptr);
	  if (tok.type != ')' && verbose) {
	       file_error(_("expected `)'"), &tok);
	       return 1;
	  }
     } else if (tok.type == IDENTIFIER) {
	  if (idptr) {
	       idptr->name = tok.token;
	       idptr->line = tok.line;
	       parm_ptr = &idptr->parmcnt;
	  }
     }
     
     if (nexttoken() == PARM_WRAPPER) {
	  wrapper = 1;
	  nexttoken(); /* read '(' */
     } else
	  putback();

     while (nexttoken() == '[' || tok.type == '(') {
	  if (tok.type == '[') 
	       skip_to(']');
	  else {
	       maybe_parm_list(parm_ptr);
	       if (tok.type != ')' && verbose) {
		    file_error(_("expected `)'"), &tok);
		    return 1;
	       }
	  }
     }
     if (wrapper)
	  nexttoken(); /* read ')' */

     while (tok.type == PARM_WRAPPER) {
	  if (skip_balanced('(', ')', 0) == -1)
	       file_error(_("unexpected end of file in function declaration"),
			  NULL);
     }
     
     return 0;
}

int
parmdcl(Ident *idptr)
{
     int type;

     while (nexttoken() != 0 && tok.type != '(') {
	  if (tok.type == MODIFIER) {
	       if (idptr && idptr->type_end == -1)
		    idptr->type_end = curs-1;
	  } else if (tok.type == IDENTIFIER) {
	       while (tok.type == IDENTIFIER)
		    nexttoken();
	       type = tok.type;
	       putback();
	       if (type != MODIFIER) 
		    break;
	  } else if (tok.type == ')' || tok.type == ',') 
	       return 0;
     }
     if (idptr && idptr->type_end == -1)
	  idptr->type_end = curs-1;
     return dirdcl(idptr);
}


void
maybe_parm_list(int *parm_cnt_return)
{
     int parmcnt = 0;
     Ident ident;
     int level;

     parm_level++;
     while (nexttoken()) {
	  switch (tok.type) {
	  case ')':
	       if (parm_cnt_return)
		    *parm_cnt_return = parmcnt;
	       parm_level--;
	       return;
	  case ',':
	       break;
	  case QUALIFIER:
	  case IDENTIFIER:
	  case MODIFIER: /* unsigned * */
	  case STRUCT:
	  case UNION:
	  case TYPE:
	       parmcnt++;
	       ident.storage = AutoStorage;
	       parse_declaration(&ident, 1);
	       putback();
	       break;
	  default:
	       if (verbose)
		    file_error(_("unexpected token in parameter list"),
			       &tok);
	       level = 0;
	       do {
		    if (tok.type == '(') 
			 level++;
		    else if (tok.type == ')') {
			 if (level-- == 0)
			      break;
		    }
	       } while (nexttoken());
		    ;
	       putback();
	  }
     }
     if (verbose)
	  file_error(_("unexpected end of file in parameter list"), NULL);
}

void
func_body()
{
     Ident ident;
     
     level++;
     move_parms(level);
     while (level) {
	  cleanup_stack();
	  nexttoken();
	  switch (tok.type) {
	  default:
	       expression();
	       break;
	  case STATIC:
	       ident.storage = StaticStorage;
	       nexttoken();
	       parse_variable_declaration(&ident, 0);
	       break;
	  case TYPE:
	  case STRUCT:
	       ident.storage = AutoStorage;
	       parse_variable_declaration(&ident, 0);
	       break;
	  case EXTERN:
	       ident.storage = ExplicitExternStorage;
	       parse_declaration(&ident, 0);
	       break;
	  case LBRACE0:
	  case '{':
	       level++;
	       break;
	  case RBRACE0:
	       if (use_indentation) {
		    if (verbose && level != 1)
			 file_error(_("forced function body close"), NULL);
		    for ( ; level; level--) {
			 delete_autos(level);
		    }
		    break;
	       }
	       /* else: */
	       /* FALLTHRU */
	  case '}':
	       delete_autos(level);
	       level--;
	       break;
	  case 0:
	       if (verbose)
		    file_error(_("unexpected end of file in function body"),
			       NULL);
	       caller = NULL;
	       return;
	  }
     }
     caller = NULL;
}

int
get_knr_args(Ident *ident)
{
     int parmcnt, stop;
     Stackpos sp, new_sp;
     Ident id;

     switch (tok.type) {
     case IDENTIFIER:
     case TYPE:
     case STRUCT:
	  /* maybe K&R function definition */
	  
	  mark(sp);
	  parmcnt = 0;
	  
	  for (stop = 0; !stop && parmcnt < ident->parmcnt;
	       nexttoken()) {
	       id.type_end = -1;
	       switch (tok.type) {
	       case LBRACE:
	       case LBRACE0:
		    putback();
		    stop = 1;
		    break;
	       case TYPE:
	       case IDENTIFIER:
	       case STRUCT:
		    putback();
		    mark(new_sp);
		    if (dcl(&id) == 0) {
			 parmcnt++;
			 if (tok.type == ',') {
			      do {
				   tos = id.type_end; /* ouch! */
				   restore(new_sp);
				   dcl(&id);
			      } while (tok.type == ',');
			 } else if (tok.type != ';')
			      putback();
			 break;
		    }
		    /* else */
		    /* FALLTHRU */
	       default:
		    restore(sp);
		    return 1;
	       }
	  }
     }
     return 0;
}

void
declare(Ident *ident, int maybe_knr)
{
     Symbol *sp;
     
     if (ident->storage == AutoStorage) {
	  undo_save_stack();
	  sp = install_ident(ident->name, ident->storage);
	  if (parm_level) {
	       sp->level = parm_level;
	       sp->flag = symbol_parm;
	  } else
	       sp->level = level;
	  sp->arity = -1;
	  return;
     } 

     if ((ident->parmcnt >= 0
	  && (!maybe_knr || get_knr_args(ident) == 0)
	  && !(tok.type == LBRACE || tok.type == LBRACE0 || tok.type == TYPE
	       || tok.type == PARM_WRAPPER))
	 || (ident->parmcnt < 0 && ident->storage == ExplicitExternStorage)
	 || save_stack_is_empty()) {
	  undo_save_stack();
	  /* add_external()?? */
	  return;
     }
     
     sp = get_symbol(ident->name);
     if (sp->source) {
	  if (ident->storage == StaticStorage
	      && (sp->storage != StaticStorage || level > 0)) {
	       sp = install_ident(ident->name, ident->storage);
	  } else {
	       if (sp->arity >= 0)
		    error_at_line(0, 0, filename, ident->line, 
				  _("%s/%d redefined"),
				  ident->name, sp->arity);
	       else
		    error_at_line(0, 0, filename, ident->line, 
				  _("%s redefined"),
				  ident->name);
	       error_at_line(0, 0, sp->source, sp->def_line,
			     _("this is the place of previous definition"));
	  }
     }

     sp->type = SymIdentifier;
     sp->arity = ident->parmcnt;
     ident_change_storage(sp, 
			  (ident->storage == ExplicitExternStorage) ?
			  ExternStorage : ident->storage);
     sp->decl = finish_save_stack(ident->name);
     sp->source = filename;
     sp->def_line = ident->line;
     sp->level = level;
     if (debug)
	  fprintf(stderr, _("%s:%d: %s/%d defined to %s\n"),
		 filename,
		 line_num,
		 ident->name, ident->parmcnt,
		 sp->decl);
}

void
declare_type(Ident *ident)
{
     Symbol *sp;
     
     undo_save_stack();
     sp = lookup(ident->name);
     for ( ; sp; sp = sp->next)
	  if (sp->type == SymToken && sp->token_type == TYPE)
	       break;
     if (!sp)
	  sp = install(ident->name, INSTALL_UNIT_LOCAL);
     sp->type = SymToken;
     sp->token_type = TYPE;
     sp->source = filename;
     sp->def_line = ident->line;
     sp->ref_line = NULL;
     if (debug)
	  fprintf(stderr, _("%s:%d: type %s\n"), filename, line_num,
		  ident->name);
}

Symbol *
get_symbol(char *name)
{
     Symbol *sp = lookup(name) ;
     
     if (sp) {
	  for (; sp; sp = sp->next) {
	       if (sp->type == SymIdentifier && strcmp(sp->name, name) == 0)
		    break;
	  }
	  if (sp)
	       return sp;
     }
     return install_ident(name, ExternStorage);
}

Symbol *
add_reference(char *name, int line)
{
     Symbol *sp = get_symbol(name);
     Ref *refptr;

     if (sp->storage == AutoStorage
	 || (sp->storage == StaticStorage && globals_only()))
	  return NULL;
     refptr = xmalloc(sizeof(*refptr));
     refptr->source = filename;
     refptr->line = line;
     if (!sp->ref_line)
	  sp->ref_line = linked_list_create(free);
     linked_list_append(&sp->ref_line, refptr);
     return sp;
}


void
call(char *name, int line)
{
     Symbol *sp;

     sp = add_reference(name, line);
     if (!sp)
	  return;
     if (sp->arity < 0)
	  sp->arity = 0;
     if (caller) {
	  if (!data_in_list(caller, sp->caller))
	       linked_list_append(&sp->caller, caller);
	  if (!data_in_list(sp, caller->callee))
	       linked_list_append(&caller->callee, sp);
     }
}

void
reference(char *name, int line)
{
     Symbol *sp = add_reference(name, line);
     if (!sp)
	  return;
     if (caller) {
	  if (!data_in_list(caller, sp->caller))
	       linked_list_append(&sp->caller, caller);
	  if (!data_in_list(sp, caller->callee))
	       linked_list_append(&caller->callee, sp);
     }
}

