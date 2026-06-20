/*************************************************************
   Copyright (c) 1993,1994 by Paul Long  All rights reserved.
**************************************************************/

/*************************************************************
   metreint.h -   This header file contains #defines,
                  typedefs, and externs that are used
                  exclusively by the parser.  The rules
                  code does not need access to these.
**************************************************************/


#ifndef _METREINT_H_
#define _METREINT_H_

#include <string.h>
#include <stddef.h>
#include "metre.h"

#define metre_version   "1.08"


/* General-purpose macros. */
/*
   Number of dimensions in array.  E.g., the following prints 10:
      int a[10]; printf("%d\n", DIM_OF(a));
*/
#define DIM_OF(x)    (sizeof (x) / sizeof (x[0]))
/* Sets the object, x, to 0. */
#define ZERO(x)      memset((void *)&x, 0, sizeof x)


/*
   This determines whether the input is buffered by reading in a line at a
   time.  Set it to either TRUE or FALSE (1 or 0).  You can either do it here
   or on the compilation command line, e.g., -DREAD_LINE=0.  The command
   line takes precedence over whatever is specified here.

   There are two reasons why you might want to turn off input buffering.
   1. It may not work properly with the version of lex you are using.
   Although I tried to make Metre compatible with flex, I have my
   doubts about it.  2. If input buffering is enabled, Metre will
   display the input line along with many error messages.  If this is a
   preprocessed file, the line may be misleading because it may look
   nothing like the original source line after macro replacement has
   taken place.  It, therefore, may be better to just never display the
   input line.  You decide.
*/
#ifndef READ_LINE
#define READ_LINE TRUE
#endif

/*
   Add defines for new internal error messages here.
   NOTE: 0 is reserved for yyerror() and error messages that YACC generates.
*/
#define E_NO_HEAP          1, "Out of heap space"
#define E_LINE_TYPE        2, "Invalid line type"
#define E_CANT_OPEN_LISTING_FILE 3, "Cannot open listing file"

/* Add defines for new internal warning messages here. */
#define W_CANNOT_OPEN_FILE 0, "Cannot open %s"

/*
   Number of typedef symbols that each typedef-symbol block can hold.  New
   blocks are allocated on an as-needed basis so that the symbol table is not
   a fixed size.
*/
#define TYPEDEF_SYMBOLS_PER_BLOCK      1000


/* Characters used to identify command-line options. */
#define DEFINE_OPT_CHAR       'D'   /* Translate this identifier. */
#define LISTING_OPT_CHAR      'L'   /* Name of listing file to contain output.*/
#define COPY_INPUT_OPT_CHAR   'C'   /* Copy input to standard out. */
#define SUBST_FILE_OPT_CHAR   'S'  /* Substitute file name. */

#define OPT_INTRO_CHARS "/-"  /* Command-line option-introduction characters. */

/* (Lex's maximum lexeme length--YYLMAX.) */
#define MAX_DECLARATOR_NAME_LEN 100

/* typedef for IDENTIFIER array. */
typedef char IDENTIFIER[MAX_DECLARATOR_NAME_LEN];


/*
   NOTE: External names that are intended to only be used within the parser
   are mangled somewhat by prepending "mtr_" to reduce the possibility of
   collision between names in rules code and parser code.  These #defines
   could all be removed if this is not a concern.
*/


#define mod_decisions   mtr_mod_decisions
#define mod_functions   mtr_mod_functions

extern unsigned mod_decisions;
extern unsigned mod_functions;


#define cmd_line_argc                  mtr_cmd_line_argc
#define cmd_line_argv                  mtr_cmd_line_argv
#define input_file                     mtr_input_file
#define input_file_orig_name           mtr_input_file_orig_name
#define next_cmd_line_file             mtr_next_cmd_line_file
#define next_cmd_line_file_orig_n      mtr_next_cmd_line_file_orig_n
#define column                         mtr_column
#define display_input                  mtr_display_input
#define looking_for_tag                mtr_looking_for_tag

extern int cmd_line_argc;
extern char **cmd_line_argv;
extern FILE *yyin;
extern int yylineno;
extern FILE *yyout;
extern char *input_file;
extern char *input_file_orig_name;
extern unsigned next_cmd_line_file;
extern unsigned next_cmd_line_file_orig_n;
extern BOOLEAN display_input;
extern BOOLEAN looking_for_tag;


#define int_prj      mtr_int_prj
#define int_mod      mtr_int_mod
#define int_lin      mtr_int_lin
#define int_lex      mtr_int_lex

extern PRJ int_prj;
extern MOD int_mod;
extern LIN int_lin;
extern LEX int_lex;


#define get_next_input_file            mtr_get_next_input_file
#define get_next_input_file_orig_name  mtr_get_next_input_file_orig_name
#define typedef_symbol_table_find      mtr_typedef_symbol_table_find
#define init_lex                       mtr_init_lex
#define init_yacc                      mtr_init_yacc
#define fire_prj                       mtr_fire_prj
#define fire_mod                       mtr_fire_mod
#define fire_lin                       mtr_fire_lin
#define fire_lex                       mtr_fire_lex

extern char *get_next_input_file(unsigned *p_i);
extern char *get_next_input_file_orig_name(unsigned *p_i);
extern BOOLEAN typedef_symbol_table_find(char *);
extern void init_lex(void);
extern void init_yacc(void);
extern void fire_prj(void);
extern void fire_mod(void);
extern void fire_lin(void);
extern void fire_lex(void);
#ifdef DEBUG_TYPEDEF
extern void typedef_symbol_table_dump(void);
#endif

#endif
