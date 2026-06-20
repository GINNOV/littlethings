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

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <errno.h>
#define obstack_chunk_alloc xmalloc
#define obstack_chunk_free free
#include <obstack.h>
#include <error.h>
#include <xalloc.h>
#include <gettext.h>

#define _(c) gettext(c)
#define N_(c) c

#if HAVE_LOCALE_H
# include <locale.h>
#endif
#if !HAVE_SETLOCALE
# define setlocale(category, locale) /* empty */
#endif

/* Exit codes */
#define EX_OK    0  /* Success */
#define EX_FATAL 1  /* Fatal error */
#define EX_SOFT  2  /* Some input files cannot be read or parsed */
#define EX_USAGE 3  /* Command line usage error */

#define NUMITEMS(a) sizeof(a)/sizeof((a)[0])

struct linked_list_entry {
     struct linked_list_entry *next, *prev;
     struct linked_list *list;
     void *data;
};

typedef void (*linked_list_free_data_fp) (void*);

struct linked_list {
     linked_list_free_data_fp free_data;
     struct linked_list_entry *head, *tail;
};

#define linked_list_head(list) ((list) ? (list)->head : NULL)

enum symtype {
     SymUndefined,  /* Undefined or deleted symbol */
     SymToken,      /* A token */
     SymIdentifier  /* Function or variable */
};

enum storage {
     ExternStorage,
     ExplicitExternStorage,
     StaticStorage,
     AutoStorage,
     AnyStorage
};

typedef struct {
     int line;
     char *source;
} Ref;

enum symbol_flag {
     symbol_none,
     symbol_local,                 /* Unit-local symbol. Must be deleted after
				      processing current compilation unit */
     symbol_parm,                  /* Parameter */
     symbol_alias                  /* Alias to another symbol */
};

typedef struct symbol Symbol;

struct symbol {
     struct table_entry *owner;
     Symbol *next;                 /* Next symbol with the same hash */
     struct linked_list_entry *entry;
     
     enum symtype type;            /* Type of the symbol */
     char *name;                   /* Identifier */
     enum symbol_flag flag;        /* Specific flag */
     struct symbol *alias;         /* Points to the aliased symbol if
				      type==SymToken and flag==symbol_alias.
				      In this case, the rest of the structure
				      is ignored */
	
     int active;                   /* Set to 1 when the symbol's subtree is
				      being processed, prevent recursion */
     int expand_line;              /* Output line when this symbol was first
				      expanded */

     int token_type;               /* Type of the token */
     char *source;                 /* Source file */
     int def_line;                 /* Source line */
     struct linked_list *ref_line; /* Referenced in */
     
     int level;                    /* Block nesting level (for local vars),
				      Parameter nesting level (for params) */
     
     char *decl;                   /* Declaration */ 
     enum storage storage;         /* Storage type */
     
     int arity;                    /* Number of parameters or -1 for
				      variables */  
     
     int recursive;                /* Is the function recursive */
     size_t ord;                   /* ordinal number */
     struct linked_list *caller;   /* List of callers */
     struct linked_list *callee;   /* List of callees */
};

/* Output flags */
#define PRINT_XREF 0x01
#define PRINT_TREE 0x02

#ifndef CFLOW_PREPROC
# define CFLOW_PREPROC "/usr/bin/cpp"
#endif

#define MAX_OUTPUT_DRIVERS 8

extern unsigned char *level_mark;
extern FILE *outfile;
extern char *outname;

extern int verbose;
extern int print_option;
extern int use_indentation;
extern int assume_cplusplus;
extern int record_defines;
extern int strict_ansi;
extern char *level_indent[];
extern char *level_end[];
extern char *level_begin;
extern int print_levels;
extern int print_line_numbers;
extern int print_as_tree;
extern int brief_listing;
extern int reverse_tree;
extern int out_line;
extern char *start_name;
extern int all_functions;
extern int max_depth;
extern int emacs_option;
extern int debug;
extern int preprocess_option;
extern int omit_arguments_option;
extern int omit_symbol_names_option;

extern int token_stack_length;
extern int token_stack_increase;

extern int symbol_count;
extern unsigned input_file_count;

#define INSTALL_DEFAULT     0x00
#define INSTALL_OVERWRITE   0x01
#define INSTALL_CHECK_LOCAL 0x02
#define INSTALL_UNIT_LOCAL  0x04

Symbol *lookup(const char*);
Symbol *install(char*, int);
Symbol *install_ident(char *name, enum storage storage);
void ident_change_storage(Symbol *sp, enum storage storage);
void delete_autos(int level);
void delete_statics(void);
void delete_parms(int level);
void move_parms(int level);
size_t collect_symbols(Symbol ***, int (*sel)(), size_t rescnt);
size_t collect_functions(Symbol ***return_sym);
struct linked_list *linked_list_create(linked_list_free_data_fp fun);
void linked_list_destroy(struct linked_list **plist);
void linked_list_append(struct linked_list **plist, void *data);
void linked_list_prepend(struct linked_list **plist, void *data);
void linked_list_iterate(struct linked_list **plist, 
			 int (*itr) (void *, void *), void *data);
void linked_list_unlink(struct linked_list *list,
			struct linked_list_entry *ent);
size_t linked_list_size(struct linked_list *list);

int data_in_list(void *data, struct linked_list *list);

int get_token(void);
int source(char *name);
void init_lex(int debug_level);
void set_preprocessor(const char *arg);
void pp_option(const char *arg); 

void init_parse(void);
int yyparse(void);

void output(void);
void newline(void);
void print_level(int lev, int last);
int globals_only(void);
int include_symbol(Symbol *sym);
int symbol_is_function(Symbol *sym);

void sourcerc(int *, char ***);

typedef enum {
     cflow_output_init,
     cflow_output_begin,
     cflow_output_end,
     cflow_output_newline,
     cflow_output_separator,
     cflow_output_symbol,
     cflow_output_text
} cflow_output_command;

struct output_symbol {
     int direct;
     int level;
     int last;
     Symbol *sym;
};

int register_output(const char *name,
		    int (*handler) (cflow_output_command cmd,
				    FILE *outfile, int line,
				    void *data, void *handler_data),
		    void *handler_data);
int select_output_driver (const char *name);
void output_init(void);

int gnu_output_handler(cflow_output_command cmd,
		       FILE *outfile, int line,
		       void *data, void *handler_data);
int posix_output_handler(cflow_output_command cmd,
			 FILE *outfile, int line,
			 void *data, void *handler_data);


typedef struct cflow_depmap *cflow_depmap_t;
cflow_depmap_t depmap_alloc(size_t count);
void depmap_set(cflow_depmap_t dmap, size_t row, size_t col);
int depmap_isset(cflow_depmap_t dmap, size_t row, size_t col);
void depmap_tc(cflow_depmap_t dmap);
