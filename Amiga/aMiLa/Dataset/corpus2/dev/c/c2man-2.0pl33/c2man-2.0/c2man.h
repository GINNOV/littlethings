/* $Id: c2man.h,v 2.0.1.16 1994/05/12 02:23:21 greyham Exp $
 *
 * Definitions for C language manual page generator
 */
#ifndef _C2MAN_H
#define _C2MAN_H

#include "config.h"
#include "symbol.h"

#ifdef I_SYS_TYPES
#include <sys/types.h>
#endif

#ifdef I_STDLIB
#include <stdlib.h>
#endif

#ifdef I_STRING
#include <string.h>
#else
#include <strings.h>
#endif

#include <stdio.h>

#ifdef I_UNISTD
#include <unistd.h>
#endif

#ifdef I_STDDEF
#include <stddef.h>
#endif

#ifdef I_TIME
#include <time.h>
#endif
#ifdef I_SYS_TIME
#include <sys/time.h>
#endif

#ifdef NeXT
#include <libc.h>
#undef ECHO	/* lex generates ECHO */
#endif

#ifdef DBMALLOC
#include </usr/local/debug_include/malloc.h>
#endif

#include "confmagic.h"

/* number of spaces in a tab */
#define NUM_TAB_SPACES 4

/* maximum include file nesting */
#define MAX_INC_DEPTH 15

/* maximum number of include directories */
#define MAX_INC_DIR 15

/* maximum number of characters in a text buffer */
#define MAX_TEXT_LENGTH	256

/* Boolean type */
typedef int boolean;
#ifndef TRUE
#define FALSE	0
#define TRUE	1
#endif

/* NULL char *, useful for passing NULL to functions wanting a char * */
#define NULLCP	((char *)0)

/* This is a list of function parameters. */
typedef struct _parameter_list {
    struct _parameter	*first;	/* pointer to first parameter in list */
    struct _parameter	*last;  /* pointer to last parameter in list */  
} ParameterList;

/* Declaration specifier flags */
#define DS_NONE 	0	/* default */
#define DS_EXTERN	1	/* contains "extern" specifier */
#define DS_STATIC	2	/* contains "static" specifier */
#define DS_CHAR 	4	/* contains "char" type specifier */
#define DS_SHORT	8	/* contains "short" type specifier */
#define DS_FLOAT	16	/* contains "float" type specifier */
#define DS_JUNK 	32	/* we're not interested in this declaration */
#define DS_INLINE	64	/* makes static look interesting */

/* This structure stores information about a declaration specifier. */
typedef struct _decl_spec {
    unsigned short	flags;	/* flags defined above */
    char		*text;	/* source text */
    struct _enumerator_list *enum_list;	/* associated enum (if any) */
} DeclSpec;

/* Styles of declaration/definition */
typedef enum {
    DECL_SIMPLE,	/* simple declaration */
    DECL_COMPOUND,	/* compound declaration */
    DECL_FUNCTION,	/* function declaration (prototype) */
    DECL_FUNCDEF	/* an actual function definition */
} DeclType;

/* This structure stores information about a declarator. */
typedef struct _declarator {
    char		*name;		/* name of variable or function */
    char		*text;		/* source text */
    DeclType		type;		/* style of function declaration */
    ParameterList	params;		/* function parameters */
    char 		*comment;	/* description of param or variable */
    struct _declarator 	*head;		/* head function declarator */
    struct _declarator 	*func_stack;	/* stack of function declarators */
    struct _declarator	*next;		/* next declarator in list */
} Declarator;

/* This is a list of declarators. */
typedef struct _declarator_list {
    Declarator		*first;	/* pointer to first declarator in list */
    Declarator		*last;  /* pointer to last declarator in list */  
} DeclaratorList;

/* This structure stores information about a declaration. */
typedef struct _declaration {
    DeclSpec		decl_spec;
    DeclaratorList	decl_list;
} Declaration;

/* this structure store information about an enumerator */
typedef struct _enumerator {
    char *name;			/* name of enum entry */
    char *comment;		/* description of entry */
    char *group_comment;	/* general descr. for next few enums in list */
    struct _enumerator *next;	/* next enumerator in list */
} Enumerator;

/* This is a list of enumerators. */
typedef struct _enumerator_list {
    Enumerator		*first;	/* pointer to first enumerator in list */
    Enumerator		*last;  /* pointer to last enumerator in list */
    struct _enumerator_list *next;	/* next list in a list-of-lists */
} EnumeratorList;


/* This structure stores information about a function parameter. */
typedef struct _parameter {
    DeclSpec		decl_spec;
    Declarator		*declarator;
    boolean		suppress;	/* don't print in grouped page */
    boolean		duplicate;	/* mention fn in grouped page */
    struct _parameter	*next;		/* next parameter in list */
} Parameter;

/* this is an identifier, with surrounding comments (if any) */
typedef struct _identifier {
    char *name;
    char *comment_before, *comment_after;
} Identifier;

/* parser stack entry type */
typedef union {
    char		*text;
    DeclSpec		decl_spec;
    Parameter		parameter;
    ParameterList	param_list;
    Declarator		*declarator;
    DeclaratorList	decl_list;
    Declaration		declaration;
    Enumerator		enumerator;
    EnumeratorList	*enum_list;
    Identifier		identifier;
    boolean		boolean;
} yystype;

/* include files specified by user */
typedef struct _includefile
{
    char *name;
    struct _includefile *next;
} IncludeFile;

/* output object types */
enum Output_Object
{
#if 0	/* C++ stuff */
    OBJECT_CLASS,
    OBJECT_STRUCT,
    OBJECT_ENUM,
    OBJECT_TYPEDEF,
#endif
    OBJECT_FUNCTION,
    OBJECT_VARIABLE,
    OBJECT_STATIC_FUNCTION,
    OBJECT_STATIC_VARIABLE,
    _OBJECT_NUM
};

struct Output_Object_Info
{
    char flag;		/* -O flag used to set it */
    char *name;		/* descriptive name for usage() */
    char *extension;	/* file extension */
    char *subdir;	/* subdirectory */
};

/* list of sections to exclude */
typedef struct ExcludeSection
{
  char *name;
  struct ExcludeSection *next;
} ExcludeSection;

#define YYSTYPE yystype

/* Program options */
extern boolean static_out;
extern boolean variables_out;
extern boolean promote_param;
extern const char *decl_spec_prefix, *declarator_prefix, *declarator_suffix;
extern const char *first_param_prefix, *middle_param_prefix, *last_param_suffix;
extern int num_inc_dir;
extern const char *inc_dir[];
extern char *manual_name;
extern const char *progname;
extern char *header_prefix;
extern IncludeFile *first_include;
extern ExcludeSection *first_excluded_section;

extern char *group_terse;
extern boolean group_together;
extern boolean terse_specified;
extern boolean always_document_params;

extern char *output_dir;

/* Global declarations */
extern int line_num;
extern const char *basefile;
extern Time_t basetime;
extern boolean inbasefile;
extern boolean header_file;
extern SymbolTable *typedef_names;
extern void output_error();
extern void parse_file _((const char *start_file));
extern int errors;
extern const char *manual_section;
extern boolean use_input_name;
extern boolean make_embeddable;
extern struct Output_Object_Info output_object[_OBJECT_NUM];



/* Output a string to standard output. */
#define put_string(s)	fputs(s, stdout)

/* a malloc that handles errors, and a free that handles NULL */
#ifndef DBMALLOC
void *safe_malloc _((size_t size));
#else
/* use macro so dbmalloc tells us where safe_malloc is called from */
#define safe_malloc(s)	malloc(s)
#endif
#define safe_free(p)	do { if (p) free(p); } while(0)

void outmem();
void print_includes _((FILE *f));/* write #include lines */

void yyerror _V((const char *fmt, ...));

char *strduplicate _((const char *s));
int strncmpi _((const char *s1, const char *s2, size_t n));
char *strtoupper _((char *s));

void my_perror _((const char *action, const char *filename));

char *alloc_string _((const char *start, const char *end));

#endif
