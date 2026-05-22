/*
 * Filter - the code to deal with filter expressions. We have one parser,
 * and one executer. The parser is passed a pointer to a bunch of tokens,
 * terminated by a null. We return the pointer to the next token, or NULL
 * to indicate a parse error.
 *
 *	Copyright (C) 1989  Mike Meyer
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 1, or any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <exec/types.h>
#include <libraries/dos.h>	/* To get FileInfoBlock definition */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "errors.h"

/*
 * We turn an expression into a linked list of nodes, which will be executed
 * as a reverse polish expression.
 */
static struct node {
	char		n_type ;		/* What it is */	
	char		n_subtype ;		/* And more of same */
	struct node	*n_next ;		/* Next node to interpret */
	union {
		long			un_int ;
		char			*un_string ;
		long			(*un_func)(struct FileInfoBlock *) ;
		struct node		*un_short ;
		} n_data ;
	} ;
#define n_prec		n_data.un_int	/* For operators... */
#define n_int		n_data.un_int
#define n_string	n_data.un_string
#define n_func		n_data.un_func
#define n_short		n_data.un_short	/* short-circuit pointer */
#define n_date		n_data.un_date

/* Major types */
#define NODE_BOGUS	0	/* Node of unknown type */
#define NODE_DATA	1	/* data of type subtype */
#define NODE_FUNC	2	/* Zeroadic function, returning subtype */
#define NODE_REXX	3	/* Unidentified operand, feed it to Rexx */
#define NODE_SHORTCIRC	4	/* target node for short-circuit ops */
#define NODE_OP		5	/* Operator, precedence in n_prec */
#define NODE_UOP	6	/* Unary op, precedence ditto */

/* Data types subtype */
#define	NODE_INT	1
#define NODE_STRING	2
#define NODE_ANY	3

/* built-in oerators subtypes, unary */
#define NODE_BITNOT	0
#define NODE_NOT	1
#define NODE_LP		2
#define NODE_RP		3

/* And binary */
#define NODE_LT		0
#define NODE_LE		1
#define NODE_GT		2
#define NODE_GE		3
#define NODE_EQ		4
#define	NODE_NE		5
#define NODE_BITAND	6
#define NODE_BITOR	7
#define NODE_BITXOR	8
#define NODE_AND	9
#define NODE_OR		10
#define NODE_UPAT	11
#define NODE_APAT	12
#define NODE_NOTUPAT	13
#define NODE_NOTAPAT	14

/* Functions supplied by main for twiddling FileInfoBlocks */
extern long fibkey(struct FileInfoBlock *) ;
extern long fibdirtype(struct FileInfoBlock *) ;
extern char *fibname(struct FileInfoBlock *) ;
extern long fibprot(struct FileInfoBlock *) ;
extern long fibtype(struct FileInfoBlock *) ;
extern long fibsize(struct FileInfoBlock *) ;
extern long fibblock(struct FileInfoBlock *) ;
extern long fibdate(struct FileInfoBlock *) ;
extern long fibday(struct FileInfoBlock *) ;
extern char *fibcomment(struct FileInfoBlock *) ;
extern long askuser(struct FileInfoBlock *) ;
extern long isdir(struct FileInfoBlock *) ;
extern long isfile(struct FileInfoBlock *) ;
extern char *fullname(struct FileInfoBlock *) ;
extern long dofib(char *, long (*)(struct FileInfoBlock *)) ;
extern long dorexx(char *, struct FileInfoBlock *) ;

/*
 * token arrays hold all the tokens we know about.
 */
struct token {
	char	*o_name ;
	char	o_type ;
	char	o_subtype ;
	long	o_value ;
	} ;

/* ops holds the things that can't be applied to files */
static struct token ops[] = {
	/* Functions first, so we can set them later. Nuts */
	{"user",	NODE_FUNC,	NODE_INT,	/* (long) &askuser */ 0},
	{"dir",		NODE_FUNC,	NODE_INT,	/* (long) &isdir */ 0},
	{"file",	NODE_FUNC,	NODE_INT,	/* (long) &isfile */ 0},
	{"filename",	NODE_FUNC,	NODE_STRING,	/* (long) &fullname */ 0},

	/* a couple of constants */
	{"false",	NODE_DATA,	NODE_INT,	0},
	{"true",	NODE_DATA,	NODE_INT,	1},

	{"!",		NODE_UOP, 	NODE_NOT,	70},
	{"<",		NODE_OP,	NODE_LT,	30},
	{"<=",		NODE_OP,	NODE_LE,	30},
	{">",		NODE_OP,	NODE_GT,	30},
	{">=",		NODE_OP,	NODE_GE,	30},
	{"==",		NODE_OP,	NODE_EQ,	30},
	{"!=",		NODE_OP,	NODE_NE,	30},
	{"=*",		NODE_OP,	NODE_UPAT,	30},
	{"=#",		NODE_OP,	NODE_APAT,	30},
	{"!*",		NODE_OP,	NODE_NOTUPAT,	30},
	{"!#",		NODE_OP,	NODE_NOTAPAT,	30},
	{"&",		NODE_OP,	NODE_BITAND,	60},
	{"|",		NODE_OP,	NODE_BITOR,	40},
	{"^",		NODE_OP,	NODE_BITXOR,	50},
	{"~",		NODE_UOP,	NODE_BITNOT,	70},
	{"&&",		NODE_OP,	NODE_AND,	20},
	{"||",		NODE_OP,	NODE_OR,	10},
	{"(",		NODE_UOP,	NODE_LP,	0},
	{")",		NODE_UOP,	NODE_RP,	0},	/* Prec is ignored */

	{NULL,		0,		0,		0},
	} ;
/* Alias for the precedence of ops in this mess */
#define o_prec	o_value

/* fibfuncs holds the mapping from tokens to operand primitives. */
static struct token fibfuncs[] = {
	/* Fib extraction functions */
	{"diskkey",		NODE_FUNC,	NODE_INT,	/* (long) &fibkey */ 0},
	{"direntrytype",	NODE_FUNC,	NODE_INT,	/* (long) &fibdirtype */ 0},
	{"name",		NODE_FUNC,	NODE_STRING,	/* (long) &fibname */ 0},
	{"protection",		NODE_FUNC,	NODE_INT,	/* (long) &fibprot */ 0},
	{"entrytype",		NODE_FUNC,	NODE_INT,	/* (long) &fibtype */ 0},
	{"size",		NODE_FUNC,	NODE_INT,	/* (long) &fibsize */ 0},
	{"numblock",		NODE_FUNC,	NODE_INT,	/* (long) &fibblock */ 0},
	{"date",		NODE_FUNC,	NODE_INT,	/* (long) &fibdate */ 0},
	{"day",			NODE_FUNC,	NODE_INT,	/* (long) &fibday */ 0},
	{"comment",		NODE_FUNC,	NODE_STRING,	/* (long) &fibcomment */ 0},
	{NULL,			0,		0,		0},
	} ;

/* Nasty bug in Lattice makes this routine necessary. Shitheads. */
static void
unlatticecode(void) {
	fibfuncs[0].o_value = (long) &fibkey ;
	fibfuncs[1].o_value = (long) &fibdirtype ;
	fibfuncs[2].o_value = (long) &fibname ;
	fibfuncs[3].o_value = (long) &fibprot ;
	fibfuncs[4].o_value = (long) &fibtype ;
	fibfuncs[5].o_value = (long) &fibsize ;
	fibfuncs[6].o_value = (long) &fibblock ;
	fibfuncs[7].o_value = (long) &fibdate ;
	fibfuncs[8].o_value = (long) &fibday ;
	fibfuncs[9].o_value = (long) &fibcomment ;
	ops[0].o_value = (long) &askuser ;
	ops[1].o_value = (long) &isdir ;
	ops[2].o_value = (long) &isfile ;
	ops[3].o_value = (long) &fullname ;
	}

/*
 * findop finds an operator/operand and returns the pointer to it, or
 * NULL if it's not recognized.
 */
static struct token *
findop(char *name, struct token *table) {

	while (table->o_name)
		if (!(stricmp(table->o_name, name))) return table ;
		else table += 1 ;
	return NULL ;
	}

/* functions used to deal with "`"'ed strings */
long date(char *) ;
long prot(char *) ;

/*
 * lex gets the next token out of the strings it's given, build a node
 * to put into it's second argument, and returns the new pointer. For
 * various reasons, it expects things to start on a non-blank.
 */
#define EQPRE	"=!<>*#"	/* can be an op if concatenated with '=' */
#define DUPOPS	"&|"		/* Ops if duplicated */
#define OPCHARS	"&|^()<>"	/* Single-character ops */
static char *
lex(char *line, struct node *out) {
	char			save, *end, *fibf, buf[160] ;
	struct token		*top ;

	line = stpblk(line) ;
	if (!*line) return NULL ;	/* No more data! */

	/* Is it a number? */
	if (isdigit(*line)) {
		if (tolower(line[1]) != 'x') save = *line == '0' ? 8 : 10 ;
		else {
			line += 2 ;
			save = 16 ;
			}
		out->n_int = strtol(line, &end, save) ;
		out->n_type = NODE_DATA ;
		out->n_subtype = NODE_INT ;
		return end ;
		}

	/* How about a string? */
	if (*line == '\'' || *line == '"' || *line == '`') {
		save = *line ;
		line += 1 ;
		end = strchr(line, save) ;
		if (end == NULL) {
			fprintf(stderr, "%s: Unterminated string: %s\n", my_name, line) ;
			errorflag = ERROR_HALT ;
			return NULL ;
			}
		*end = '\0' ;
		out->n_type = NODE_DATA ;
		if (save != '`') {
			out->n_subtype = NODE_STRING ;
			strlwr(line) ;
			out->n_string = line ;
			}
		else {
			if ((out->n_int = date(line)) == -1
			&&  (out->n_int = prot(line)) == -1) {
				fprintf(stderr, "%s: Invalid constant %s\n",
					my_name, line) ;
				errorflag = ERROR_HALT ;
				return NULL ;
				}
			out->n_subtype = NODE_INT ;
			}
		return end + 1 ;
		}
				
	/* OK, try builtin operators & operands */
	end = line ;
	if (strchr(EQPRE, *line)) {	/* needs special handling */
		if (*++end == '=') end += 1 ;
		else if (*end == '#') end += 1 ;
		else if (*end == '*') end += 1 ;
		}
	else if (strchr(DUPOPS, *line)) {
		if (*line == *++end) end += 1 ;
		}
	else if (!strchr(OPCHARS, *line))
		end = stptok(line, buf, 160, OPCHARS EQPRE " \t") ;

	save = *end ;
	*end = '\0' ;

	/* See if it's a know operator or operand */
	if (!(top = findop(line, ops)))
		top = findop(line, fibfuncs)  ;

	if (top) {
		out->n_type = top->o_type ;
		out->n_subtype = top->o_subtype ;
		out->n_int = top->o_value ;
		}

	/* Or maybe a fibfunc applied to a named file */
	else {
		if ((fibf = strrchr(line, '.'))
		&& (top = findop(fibf + 1, fibfuncs))) {
			out->n_type = NODE_DATA ;
			out->n_subtype = top->o_subtype ;
			*fibf = '\0' ;
			out->n_int = dofib(line,
				(long (*)(struct FileInfoBlock *)) top->o_value) ;
			*fibf = '.' ;
			}
#ifndef	NO_REXX
		else {	/* Don't know what it is, so make it arexx */
			out->n_type = NODE_REXX ;
			out->n_subtype = NODE_INT ;
			if (!(out->n_string = strdup(line))) {
				errorflag = ERROR_HALT ;
				fprintf(stderr, "%s: out of memory!\n", my_name) ;
				}
			}
#else
		else out->n_type = NODE_BOGUS ;
#endif
		}

	*end = save;
	return end ;
	}

/* push is used during parsing to maintain the operator stack */
static void push(struct node **stack, long value, char type, char subtype) ;

/*
 * parse parses the tokens in argv, and puts the resulting RPN code in code
 */
struct node *
parse(char *line) {
	struct node	*last = NULL, *code = NULL, now, *tmp, *stack = NULL ;
	char		*token ;
	int		operand = 1, shorted = 0 ;

	unlatticecode() ;

	while (!errorflag) {
		token = line ;
		if ((line = lex(line, &now)) == NULL || now.n_type == NODE_BOGUS)
			break ;

		/* Check for operands or left paren */
		else if (operand) {
			if (now.n_type == NODE_OP) {
				now.n_type = NODE_BOGUS ;
				break ;
				}
			else if (now.n_type == NODE_UOP) {
				if (now.n_subtype == NODE_RP) {
					now.n_type = NODE_BOGUS ;
					break ;
					}
				push(&stack, now.n_prec, now.n_type, now.n_subtype) ;
				continue ;
				}
			else if ((tmp = (struct node *) malloc(sizeof(struct node))) == NULL) {
				fprintf(stderr, "%s: out of memory!", my_name) ;
				errorflag = ERROR_HALT ;
				}
			else {
				tmp->n_type = now.n_type ;
				tmp->n_subtype = now.n_subtype ;
				tmp->n_int = now.n_int ;
				if (last != NULL) last->n_next = tmp ;
				else code = tmp ;
				last = tmp ;
				}
			operand = 0 ;
			}

		/* If not an operand, then we want an operator */
		else if (now.n_type == NODE_OP) {
			while (stack && stack->n_prec >= now.n_prec) {
				last->n_next = stack ;
				last = stack ;
				stack = stack->n_next ;
				}
			if (now.n_subtype != NODE_AND && now.n_subtype != NODE_OR)
				push(&stack, now.n_prec, now.n_type, now.n_subtype) ;
			else { /* Short circuit ops are screwy */
				if ((tmp = (struct node *) malloc(sizeof(struct node))) == NULL) {
					fprintf(stderr, "%s: out of memory!", my_name) ;
					errorflag = ERROR_HALT ;
					}
				else {
					push(&stack, now.n_prec, NODE_SHORTCIRC, now.n_subtype) ;
					tmp->n_type = now.n_type ;
					tmp->n_subtype = now.n_subtype ;
					tmp->n_short = stack ;
					last->n_next = tmp ;
					last = tmp ;
					shorted = 1 ;
					}
				}
			operand = 1 ;
			}

		/* But a right paren will do instead */
		else if (now.n_type == NODE_UOP && now.n_subtype == NODE_RP) {
			while (stack && !(stack->n_type == NODE_UOP && stack->n_subtype == NODE_LP)) {
				last->n_next = stack ;
				last = stack ;
				stack = stack->n_next ;
				}
			if (!stack) {
				fprintf(stderr, "%s: To many right parens in filter\n",
					my_name) ;
				errorflag = ERROR_HALT ;
				}
			/* Now, pop the stack sans checking */
			last->n_next = stack ;
			stack = stack->n_next ;
			free(last->n_next) ;
			}

		/* And anything else is an out-of-place token */
		else {
			now.n_type = NODE_BOGUS ;
			break ;
			}
		}

	if (now.n_type == NODE_BOGUS) {
		*line = '\0' ;
		fprintf(stderr, "%s: Looking for %s, found %s\n", my_name,
			operand ? "operand" : "operator", stpblk(token)) ;
		errorflag = ERROR_HALT ;
		return NULL ;
		}

	if (operand) {
		fprintf(stderr, "%s: filter ended unexpectedly\n", my_name) ;
		errorflag = ERROR_HALT ;
		return NULL ;
		}

	/* Move the rest of the stacked ops to code */
	while (stack) {
		if (stack->n_type == NODE_UOP && stack->n_subtype == NODE_LP) {
			fprintf(stderr, "%s: To many left parens in filter\n",
				my_name) ;
			errorflag = ERROR_HALT ;
			return NULL ;
			}
		last->n_next = stack ;
		last = stack ;
		stack = stack->n_next ;
		}

	last->n_next = NULL ;

#ifdef	NO_REXX
	/*
	 * Remove any shorts in the code. This is a marginal win, saving
	 * an execute loop for every && or || node that doesn't short-circuit.
	 * About every fourth or fifth node can be so shorted, so if they
	 * short 1/2 the time, you need to look at about 10 files before this
	 * wins. If you examine and fail to short-circuit at least the number
	 * of nodes, you definitely with. However, if you're using the REXX
	 * interface, then you almost cerainly lose, so we take this out.
	 */
	while (shorted) {
		shorted = 0 ;
		for (last = code; last; last = last->n_next) {
			if (last->n_next && last->n_next->n_type == NODE_SHORTCIRC) {
				last->n_next = last->n_next->n_next ;
				shorted = 1 ;
				}
			/*
			 * It's tempting to remove the n_short short circuit
			 * pointer here. However, they get skipped by the
			 * pc=pc->n_next in the execute loop. Removing them
			 * will break said loop.
			 */
			}
		}
#endif

#ifdef	NOWAY
for(last=code; last; last=last->n_next)
printf("%d %d, ", last->n_type, last->n_subtype) ;
putchar('\n') ;
fflush(stdout) ;
#endif

	return code ;
	}

#ifndef	NO_REXX
/*
 * lex builds a string of nodes to execute; free_code throws that same
 * string away. If you don't have a REXX interface, you only compile one
 * string per execution, so it doesn't matter. With a REXX interface,
 * you can compile an unknown number. Said memory leak can be deadly (how
 * do you think I found it?), so we plug it.
 */
void
free_code(struct node *top) {
	struct node	*tmp ;

	while (top != NULL) {
		tmp = top->n_next ;
		free(top) ;
		top = tmp ;
		}
	}
#endif
 
/*
 * Since we're doing RPN, we need a stack. push & pop maintain that stack.
 */
static void
push(struct node **stack, long value, char type, char subtype) {
	struct node	*tmp ;

	if ((tmp = (struct node *) malloc(sizeof(struct node))) == NULL) {
		errorflag = ERROR_HALT ;
		fprintf(stderr, "%s: out of memory!\n", my_name) ;
		}
	else {
		tmp->n_type = type ;
		tmp->n_subtype = subtype ;
		tmp->n_int = value ;
		tmp->n_next = *stack ;
		*stack = tmp ;
		}
	}

static long
pop(struct node **stack, short subtype) {
	long		out ;
	struct node	*tmp ;

	if (!*stack) {
		errorflag = ERROR_HALT ;
		fprintf(stderr, "%s: expression evaluation error\n", my_name) ;
		return 0 ;
		}
	if ((*stack)->n_type != NODE_DATA || ((*stack)->n_subtype & subtype) == 0) {
		errorflag = ERROR_HALT ;
		fprintf(stderr, "%s: operator applied to wrong type\n", my_name) ;
		return 0 ;
		}
	tmp = *stack ;
	*stack = (*stack)->n_next ;
	out = tmp->n_int ;
	free(tmp) ;
	return out ;
	}
/*
 * patcompare - handles the pattern-matching comparisons (=#, =*, !# & !*).
 */
long
patcompare(struct node **stack, int ados) {
	char	*sp, *pp ;
	long	out ;

	pp = (char *) pop(stack, NODE_STRING) ;
	sp = (char *) pop(stack, NODE_STRING) ;
	if (ados) out = (astcsma(sp, pp) == strlen(sp)) ;
	else  out = (stcsma(sp, pp) == strlen(sp)) ;
	return out ;
	}

/* To make pc visible from inside of cpr (mumble) */
#define	pc	cp

/*
 * execute is the outside entry. It gets top evaluated, and maps the
 * result back to "true" or "false".
 */
long
execute(struct FileInfoBlock *fib, struct node *code) {
	struct node	*pc ;
	long		tmp ;
	struct node	*stack = NULL ;

	if (!code) return 1 ;
	pc = code ;

	for (;pc && errorflag != ERROR_HALT; pc = pc->n_next) {
		switch (pc->n_type) {
		    default:
		    	fprintf(stderr, "%s: Invalid code type %d\n", my_name,
				pc->n_type) ;
			errorflag = ERROR_HALT ;
			return 0 ;

		    case NODE_SHORTCIRC: break ;	/* a nop */

		    case NODE_DATA:
			push(&stack, pc->n_int, NODE_DATA, pc->n_subtype) ;
			break ;

		    case NODE_FUNC:
			push(&stack, (pc->n_func)(fib), NODE_DATA,
						pc->n_subtype) ;
			break ;

#ifndef	NO_REXX
		    case NODE_REXX:
			push(&stack, dorexx(pc->n_string, fib), NODE_DATA,
							pc->n_subtype) ;
			break ;
#endif

		    case NODE_UOP:
			switch (pc->n_subtype) {
			    case NODE_BITNOT:
				push(&stack, ~pop(&stack, NODE_INT),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_NOT:
				push(&stack, (long) !pop(&stack, NODE_INT),
					NODE_DATA, NODE_INT) ;
				break ;
			    default:
				fprintf(stderr, "%s: Invalid unary op %x\n",
					my_name, pc->n_subtype) ;
				errorflag = ERROR_HALT ;
				return 0 ;
			    }
			break ;

		    case NODE_OP:
			switch (pc->n_subtype) {
			    case NODE_LT:
				tmp = pop(&stack, NODE_INT) ;
				push(&stack,
					(long) (pop(&stack, NODE_INT) < tmp),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_LE:
				tmp = pop(&stack, NODE_INT) ;
				push(&stack,
					(long) (pop(&stack, NODE_INT) <= tmp),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_GT:
				tmp = pop(&stack, NODE_INT) ;
				push(&stack,
					(long) (pop(&stack, NODE_INT) > tmp),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_GE:
				tmp = pop(&stack, NODE_INT) ;
				push(&stack,
					(long) (pop(&stack, NODE_INT) >= tmp),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_EQ:
				push(&stack,
					(long) (pop(&stack, NODE_INT) == pop(&stack, NODE_INT)),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_NE:
				push(&stack,
					(long) (pop(&stack, NODE_INT) != pop(&stack, NODE_INT)),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_BITAND:
				push(&stack,
					pop(&stack, NODE_INT) & pop(&stack, NODE_INT),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_BITOR:
				push(&stack,
					pop(&stack, NODE_INT) | pop(&stack, NODE_INT),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_BITXOR:
				push(&stack,
					pop(&stack, NODE_INT) ^ pop(&stack, NODE_INT),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_AND:
				tmp = pop(&stack, NODE_INT) ;
				if (!tmp) {
					push(&stack, tmp, NODE_DATA, NODE_INT) ;
					pc = pc->n_short ;
					}
				break ;
			    case NODE_OR:
				tmp = pop(&stack, NODE_INT) ;
				if (tmp) {
					push(&stack, tmp, NODE_DATA, NODE_INT) ;
					pc = pc->n_short ;
					}
				break ;
			    case NODE_APAT:
				push(&stack, patcompare(&stack, 1),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_UPAT:
				push(&stack, patcompare(&stack, 0),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_NOTAPAT:
				push(&stack, (long) !patcompare(&stack, 1),
					NODE_DATA, NODE_INT) ;
				break ;
			    case NODE_NOTUPAT:
				push(&stack, (long) !patcompare(&stack, 0),
					NODE_DATA, NODE_INT) ;
				break ;
			    default:
				fprintf(stderr, "%s: Invalid op %x\n", my_name,
					pc->n_subtype) ;
				errorflag = ERROR_HALT ;
				return 0 ;
			    }
			break ;
		    }
		}
	if (errorflag != ERROR_HALT) return pop(&stack, NODE_ANY) ;
	else return 0 ;
	}
