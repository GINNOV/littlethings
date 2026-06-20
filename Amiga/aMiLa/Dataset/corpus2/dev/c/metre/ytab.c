/* c:\mks\bin\yacc -d gram.y */
#define TK_IDENTIFIER	257
#define TK_CONSTANT	258
#define TK_STRING_LITERAL	259
#define TK_SIZEOF	260
#define TK_PTR_OP	261
#define TK_INC_OP	262
#define TK_DEC_OP	263
#define TK_LEFT_OP	264
#define TK_RIGHT_OP	265
#define TK_LE_OP	266
#define TK_GE_OP	267
#define TK_EQ_OP	268
#define TK_NE_OP	269
#define TK_AND_OP	270
#define TK_OR_OP	271
#define TK_MUL_ASSIGN	272
#define TK_DIV_ASSIGN	273
#define TK_MOD_ASSIGN	274
#define TK_ADD_ASSIGN	275
#define TK_SUB_ASSIGN	276
#define TK_LEFT_ASSIGN	277
#define TK_RIGHT_ASSIGN	278
#define TK_AND_ASSIGN	279
#define TK_XOR_ASSIGN	280
#define TK_OR_ASSIGN	281
#define TK_TYPE_NAME	282
#define TK_TYPEDEF	283
#define TK_EXTERN	284
#define TK_STATIC	285
#define TK_AUTO	286
#define TK_REGISTER	287
#define TK_CHAR	288
#define TK_SHORT	289
#define TK_INT	290
#define TK_LONG	291
#define TK_SIGNED	292
#define TK_UNSIGNED	293
#define TK_FLOAT	294
#define TK_DOUBLE	295
#define TK_CONST	296
#define TK_VOLATILE	297
#define TK_VOID	298
#define TK_STRUCT	299
#define TK_UNION	300
#define TK_ENUM	301
#define TK_ELIPSIS	302
#define TK_RANGE	303
#define TK_CASE	304
#define TK_DEFAULT	305
#define TK_IF	306
#define TK_ELSE	307
#define TK_SWITCH	308
#define TK_WHILE	309
#define TK_DO	310
#define TK_FOR	311
#define TK_GOTO	312
#define TK_CONTINUE	313
#define TK_BREAK	314
#define TK_RETURN	315
#define THEN	316
extern int yychar, yyerrflag;
#ifndef YYSTYPE
#define YYSTYPE int
#endif
extern YYSTYPE yyval;
extern YYSTYPE yylval;
#line 708 "gram.y"
/*************************************************************
   Copyright (c) 1993,1994 by Paul Long  All rights reserved.
**************************************************************/

#include <stdio.h>
#include <limits.h>
#include <stdarg.h>
#include "metreint.h"

/* External variables. */

/*
   Metre maintains statistics in the int_* structures, e.g., int_prj.  The
   structures with the unadorned names, e.g., prj, are used to communicate with
   the rules.  They are zero-filled except when a trigger is being fired.  At
   that time, the contents of the corresponding int_* structure is copied
   to it, the rules() function is called, and then the structure is zero-filed
   again.
*/
PRJ prj, int_prj;    /* Project. */
MOD mod, int_mod;    /* Module. */
FCN fcn;             /* Function. */
static FCN int_fcn;
STM stm;             /* Statement. */
static STM int_stm;
LIN lin, int_lin;    /* Line. */
LEX lex, int_lex;    /* Lexeme. */

/*
   Which command-line argument (argv) at which to start looking for the next
   file name to process and original file name, respectively.
*/
unsigned next_cmd_line_file;
unsigned next_cmd_line_file_orig_n;

/* Number of decision points and functions in module (file). */
unsigned mod_decisions;
unsigned mod_functions;

/*
   Indicates whether we are looking for a tag.  Parser writes it, lexer reads
   it.  Since tags are in a separate name space from other identifiers, this
   helps the lexer determine whether a lexeme is an identifier or a type name.
*/
BOOLEAN looking_for_tag;

/*
   Indicates whether we are within a function definition.  Used to determine
   whether to use the last identifier as the function name.
*/
BOOLEAN is_within_function;

/*
   Name of current input file and name of original file, if specified on
   command line with the substitute-file-name option.  If substitute not
   provided, input_file_orig_name points to the same name as input_file.
*/
char *input_file;
char *input_file_orig_name;

/* Where all output is written. */
FILE *out_fp;

/* Global versions of main's argc and argv. */
int cmd_line_argc;
char **cmd_line_argv;

/*
   Block within which typedef type names are held in the typedef symbol-table.
*/
typedef struct typedef_sym_blk {
   struct typedef_sym_blk *next;          /* Next block. */
   unsigned total;                        /* Total in this block. */
   char *id[TYPEDEF_SYMBOLS_PER_BLOCK]; /* Array of pointers to type names. */
} TYPEDEF_SYM_BLK;

/*
   Head of the typedef symbol-table.  NOTE: This is the only symbol table in
   Metre, and it is used just to hold typedef type names, not all symbols.
*/
TYPEDEF_SYM_BLK *typedef_sym_tbl_head = NULL;


/* Static variables. */

/* Control depth--current number of nested control structures. */
static unsigned depth;

/* Used to determine how many statements are on a line. */
static unsigned previous_statements_line_number;

/* Number of decision points in function. */
static unsigned fcn_decisions;

/*
   Metre maintains the number of statements appearing on a line.
   The is_if and is_else BOOLEANs are used principally to relax the
   criteria for what constitutes a statement.  For example, "else if,"
   is not considered two statements because this is a common idiom.
*/
static BOOLEAN is_else, is_if;

/*
   is_typedef indicates whether we are parsing a typedef.  Since typedefs
   cannot be nested, it's okay that this is just a BOOLEAN.  This is used to
   find the type name of a typedef so that it can be added to the typedef
   symbol table.  If the type name is subsequently encountered by the lexer,
   the lexer returns a token for a type name rather than for an identifier.
   This is the ugly part of C that cannot practically be expressed by a YACC
   grammar specification.
*/
static BOOLEAN is_typedef;

/*
   nested_decl_specs is used to distinguish the type name of the root-level
   declaration in a typedef from other identifiers in the typedef.
*/
static unsigned nested_decl_specs;

/*
   Whether the last statement was a case label.  Used to consider adjacent
   case labels as one decision point.  The transition from is_case_label==TRUE
   to is_case_label==FALSE is a decision point, instead of each case label
   being a decision point.  Adjacent case labels are considered one decision
   point because this is analogous to an if statement with or logical
   operators, ||.  For example,

      switch (expr) {
      case 5:
      case 10:
         a;
      }

   is, in this regard, analogous to

      if (expr == 5 || expr == 10)
         a;

   I did not want to bias the metric against the switch statement.
*/
static BOOLEAN is_case_label;

static IDENTIFIER function_name;
static IDENTIFIER last_identifier;

/* Static function declarations. */

static void fire_fcn(void);
static void fire_stm(void);
static void print_exception(int, char *, char *, va_list);
static void typedef_symbol_table_add(char *);
static void case_label(void);
static void not_case_label(void);
static void check_starting_options(void);
static void print_banner(void);
static void print_help(void);
static void stat_func_begin(void);
static void stat_func_end(void);
static void check_multiple_statements(void);
static void int_fatal(int, char *, ...);
static void int_warn(int, char *, ...);


/* Functions. */

main(int argc, char *argv[])
{
   print_banner();

   /* Save so that the argument list may be accessed globally. */
   cmd_line_argv = argv;
   cmd_line_argc = argc;

   /* Get command-line options that affect Metre at the start. */
   check_starting_options();

   /* Initialize YACC and Lex. */
   init_yacc();
   init_lex();

   /*
      Look for the first input file and first original name of that input file.
   */
   next_cmd_line_file = 0;
   next_cmd_line_file_orig_n = 0;
   if ((input_file = get_next_input_file(&next_cmd_line_file)) != NULL)
      if ((yyin = fopen(input_file, "r")) != NULL)
      {
         input_file_orig_name =
               get_next_input_file_orig_name(&next_cmd_line_file_orig_n);
         /* If no original name given, use the actual as the original, also. */
         if (input_file_orig_name == NULL)
            input_file_orig_name = input_file;

         /* Fire the beginning-of-project trigger. */
         ZERO(int_prj);
         int_prj.begin = TRUE;
         fire_prj();
         int_prj.begin = FALSE;

         /* Fire the beginning-of-module trigger. */
         ZERO(int_mod);
         int_mod.begin = TRUE;
         fire_mod();
         int_mod.begin = FALSE;

         /*
            Call the YACC-generated parser to wade through the input file(s).
            When all done, close the last input file.  yywrap() could have
            opened any number of subsequent input files.
         */
         yyparse();
         fclose(yyin);
      }
      else
         int_warn(W_CANNOT_OPEN_FILE, input_file);
   else
      /* Since no input file specified on command line, print Metre's help. */
      print_help();

/* VMS has different ideas about what constitutes a successful return value. */
#ifdef VAX
   return 1;
#else
   return 0;
#endif
}

/* Common exception-handling function. */
static void print_exception(int n, char *severity_str, char *format, va_list ap)
{
   fflush(out_fp);

   /*
      Display input line if supposed to, then display line with marker
      character in it if appropriate.
   */
   if (mod_name() != NULL && strlen(mod_name()) > 0)
   {
      if (!int_mod.end && !int_fcn.end)
      {
         if (!display_input && READ_LINE)
            fputs(line(), out_fp);

         if (!int_lin.end && READ_LINE)
            fputs(marker(), out_fp);
      }
   }

   /*
      Display module name and line number if a module name has been established.
      If one hasn't, the error must not relate to a location in the input file.
   */
   if (mod_name() != NULL && strlen(mod_name()) > 0)
      fprintf(out_fp, "%s(%u): ", mod_name(), yylineno);
   fprintf(out_fp, "%s%04u: ", severity_str, n);

   vfprintf(out_fp, format, ap);
   fputc('\n', out_fp);
}

/* Print message for internal fatal error. */
static void int_fatal(int n, char *format, ...)
{
   va_list ap;

   va_start(ap, format);

   print_exception(n, "Fatal Error ME", format, ap);

   exit(1);
}

/* Print message for fatal error that occured in the rules() function. */
void fatal(int n, char *format, ...)
{
   va_list ap;

   va_start(ap, format);

   print_exception(n, "Fatal Error E", format, ap);

   exit(1);
}

/* Print message for internal warning. */
static void int_warn(int n, char *format, ...)
{
   va_list ap;

   va_start(ap, format);

   print_exception(n, "Warning MW", format, ap);
}

/* Print message for warning that occured in the rules() function. */
void warn(int n, char *format, ...)
{
   va_list ap;

   va_start(ap, format);

   print_exception(n, "Warning W", format, ap);
}

/* Function called by YACC when it detects an error. */
void yyerror(char *s)
{
#ifdef DEBUG_TYPEDEF
   /* Used for debugging typedef processing. */
   typedef_symbol_table_dump();
#endif
   int_fatal(0, "%s", s);
}

/* Add type name to the typedef symbol table. */
static void typedef_symbol_table_add(char *p_symbol)
{
   TYPEDEF_SYM_BLK *block;
   char *str_buf = (char *)malloc(strlen(p_symbol) + 1);

   if (str_buf == NULL)
      int_fatal(E_NO_HEAP);

   /* Make copy of argument. */
   strcpy(str_buf, p_symbol);

   /* Is symbol table empty? */
   if (typedef_sym_tbl_head == NULL)
   {
      /* Allocate first block and make the head of the table list. */
      typedef_sym_tbl_head = block = (TYPEDEF_SYM_BLK *)malloc(sizeof *block);
      if (block == NULL)
         int_fatal(E_NO_HEAP);

      block->total = 0;
      block->next = NULL;
   }
   else
   {
      TYPEDEF_SYM_BLK *prev_block;

      /* Find first block in symbol-table list that isn't full. */
      for (prev_block = NULL, block = typedef_sym_tbl_head;
            block != NULL && block->total == DIM_OF(block->id);
            prev_block = block, block = block->next)
         ;

      /* If all blocks are full, allocate a new one and append to list. */
      if (block == NULL)
      {
         block = (TYPEDEF_SYM_BLK *)malloc(sizeof *block);
         if (block == NULL)
            int_fatal(E_NO_HEAP);

         block->total = 0;
         block->next = NULL;
         if (prev_block == NULL)
            typedef_sym_tbl_head = block;
         else
            prev_block->next = block;
      }
   }

   /* Save pointer to the new type name in first empty slot of this block. */
   block->id[block->total++] = str_buf;
}

/* Return TRUE if symbol exists in the typedef symbol table. */
BOOLEAN typedef_symbol_table_find(char *p_symbol)
{
   TYPEDEF_SYM_BLK *block;
   BOOLEAN found = FALSE;

   /* Loop for each block of symbols. */
   for (block = typedef_sym_tbl_head; block != NULL; block = block->next)
   {
      unsigned i;

      /* Loop for each symbol in this block. */
      for (i = 0; i < block->total; ++i)
         if (strcmp(block->id[i], p_symbol) == 0)
            found = TRUE;
   }

   return found;
}

/*
   Remove all symbols (and symbol blocks) from the symbol table--make the
   table empty.
*/
void typedef_symbol_table_flush(void)
{
   TYPEDEF_SYM_BLK *block;

   /* Loop for each block of symbols. */
   for (block = typedef_sym_tbl_head; block != NULL; )
   {
      unsigned i;
      TYPEDEF_SYM_BLK *temp_block;

      /* Loop for each symbol in this block. */
      for (i = 0; i < block->total; ++i)
         free(block->id[i]);              /* Free symbol. */

      temp_block = block->next;
      free(block);                        /* Free block now that it's empty. */
      block = temp_block;
   }

   typedef_sym_tbl_head = NULL;
}

#ifdef DEBUG_TYPEDEF
/*
   Display the contents of the typedef symbol table.  Used for debugging
   typedef processing.
*/
void typedef_symbol_table_dump(void)
{
   TYPEDEF_SYM_BLK *block;

   puts("typedef symbol table dump:");

   /* Loop for each block of symbols. */
   for (block = typedef_sym_tbl_head; block != NULL; block = block->next)
   {
      unsigned i;

      /* Loop for each symbol in this block. */
      for (i = 0; i < block->total; ++i)
         puts(block->id[i]);
   }
}
#endif

/* Record that the last statement was a case label. */
static void case_label(void)
{
   is_case_label = TRUE;
}

/*
   Record that the last statement was not a case label.  If the previous
   statement was a case label, increment the decision-point counter--this ends
   a run of adjacent case labels which count as one decision point.
*/
static void not_case_label(void)
{
   if (is_case_label)
   {
      is_case_label = FALSE;
      ++fcn_decisions;        /* This is a decision point. */
   }
}

/* Initialize parser. */
void init_yacc(void)
{
   /* Make the typedef symbol table empty. */
   typedef_symbol_table_flush();

   /*
      See the definition of each of these variables, above, for more
      information.
   */
   is_typedef = FALSE;
   nested_decl_specs = 0;
   is_case_label = FALSE;

   function_name[0] = '\0';
   last_identifier[0] = '\0';

   mod_decisions = 0;
   mod_functions = 0;
   is_else = is_if = FALSE;
   looking_for_tag = FALSE;

   is_within_function = FALSE;
}

/*
   Returns TRUE if the indicated option character was specified on the
   command line.  E.g., for -S, would return TRUE for option('S').
*/
int option(char opt_char)
{
   char *opt_str = str_option(opt_char);

   return opt_str == NULL ? 0 : strlen(opt_str) == 0 ? 1 : atoi(opt_str);
}

/*
   Returns pointer to the part of an option following the "=".  E.g.,
   for -Xabc=def, it would point to the "def" part.
*/
char *str_option(char opt_char)
{
   unsigned i;

   for (i = 1; i < cmd_line_argc; ++i)
      if (strchr(OPT_INTRO_CHARS, cmd_line_argv[i][0]) != NULL)
         if (toupper(cmd_line_argv[i][1]) == toupper(opt_char))
            break;

   return i < cmd_line_argc ? &cmd_line_argv[i][2] : NULL;
}

/*
   Return pointer to the name of the next input file in the argv array
   starting with the argument that p_i points to.  An input file name is
   distinguished from the command-line options by not starting with one of
   characters in the OPT_INTRO_CHARS string.

   NOTE: argument 0 is the name of the command, not the first argument, per se.
*/
char *get_next_input_file(unsigned *p_i)
{
   for (++*p_i; *p_i < cmd_line_argc &&
         strchr(OPT_INTRO_CHARS, cmd_line_argv[*p_i][0]) != NULL; ++*p_i)
      ;

   return *p_i < cmd_line_argc ? cmd_line_argv[*p_i] : NULL;
}

/*
   Return pointer to the original name of the next input file in the argv
   array starting with the argument that p_i points to.  An original name is
   specified as a command-line option.  That is how an original name is
   distinguished from the name of an actual input file

   NOTE: argument 0 is the name of the command, not the first argument, per se.
*/
char *get_next_input_file_orig_name(unsigned *p_i)
{
   for (++*p_i; *p_i < cmd_line_argc; ++*p_i)
      if (strchr(OPT_INTRO_CHARS, cmd_line_argv[*p_i][0]) != NULL &&
            toupper(cmd_line_argv[*p_i][1]) == SUBST_FILE_OPT_CHAR)
         break;

   return *p_i < cmd_line_argc ? &cmd_line_argv[*p_i][2] : NULL;
}

/* Returns pointer to current module (file) name. */
char *mod_name(void)
{
   return input_file_orig_name;
}

/* Process the command-line options that affect the start of Metre. */
static void check_starting_options(void)
{
   static char *output_file_name;

   /* Interleave the input with the output? */
   display_input = option(COPY_INPUT_OPT_CHAR);

   /*
      Name of listing file to contain output.  This for those OS's that don't
      support command-line redirection, e.g., VMS.
   */
   output_file_name = str_option(LISTING_OPT_CHAR);
   if (output_file_name != NULL && strlen(output_file_name) > 0)
   {
      out_fp = fopen(output_file_name, "w");
      if (out_fp == NULL)
      {
         out_fp = stdout;     /* Restore to previous, good output file. */
         int_fatal(E_CANT_OPEN_LISTING_FILE);   /* Die. */
      }
   }
   else
      out_fp = stdout;
}

/* Print name, version, and copyright notice. */
static void print_banner(void)
{
   printf("METRE Version %s  ", metre_version);
   puts("Copyright (c) 1993,1994 by Paul Long  All rights reserved.");
}

/* Print Metre command-usage information. */
static void print_help(void)
{
   puts("Syntax: METRE [ options ] file[s]   Option character in either case.  / or -");
   puts("-Dxxx=[xxx] Define identifier     -Lxxx  Name of listing file (stdout)");
   puts("-Sxxx       Substitute file name  -C     Copy input to output");
}

/* Called at the beginning of a function definition. */
static void stat_func_begin(void)
{
   /* Fire the beginning-of-function trigger. */
   ZERO(int_fcn);
   int_fcn.begin = TRUE;
   fire_fcn();
   int_fcn.begin = FALSE;

   /* Initialize variables relating to a function. */
   depth = 0;
   is_within_function = TRUE;
   fcn_decisions = 0;
   previous_statements_line_number = 0;

   /* Install starting counts.  Will replace with deltas at end-of-function. */
   int_fcn.lines.white = int_mod.lines.white;
   int_fcn.lines.com = int_mod.lines.com;
   int_fcn.lines.exec = int_mod.lines.exec;
   int_fcn.lines.total = yylineno;
}

/* Called at the end of a function definition. */
static void stat_func_end(void)
{
   /*
      Replace initial counts with their deltas to arrive at totals for
      the function.
   */
   int_fcn.lines.white = int_mod.lines.white - int_fcn.lines.white;
   int_fcn.lines.com = int_mod.lines.com - int_fcn.lines.com;
   int_fcn.lines.exec = int_mod.lines.exec - int_fcn.lines.exec;
   int_fcn.lines.total = yylineno - int_fcn.lines.total;

   ++mod_functions;                 /* Increment function count. */

   /* Accumulate function decision count into module decision count. */
   mod_decisions += fcn_decisions;

   /*
      Install the rest of the function-related information into the function
      structure and fire the end-of-function trigger.
   */
   int_fcn.decisions = fcn_decisions;
   int_fcn.end = TRUE;
   fire_fcn();
   ZERO(int_fcn);

   /*
      Clear variables that would otherwise indicate that we are still
      parsing a function.
   */
   strcpy(function_name, "");
   is_within_function = FALSE;
}

/*
   Returns pointer to current function name, or an empty string if not in a
   function.
*/
char *fcn_name(void)
{
   return function_name;
}

/*
   Increment the number of statements for the current line.  This function is
   called whenever a statement is encountered.  If the current line number is
   the same as when the last statement was encountered and if this is not the
   special situation of "else if," the counter is incremented.
*/
static void check_multiple_statements(void)
{
   if (previous_statements_line_number == yylineno)
      if (is_else && is_if)
         ;        /* do nothing */
      else
         ++int_lin.statements;
   else
      previous_statements_line_number = yylineno;

   is_else = is_if = FALSE;
}


/*
   This is true for all of the fire_*() functions: Copy the internal structure
   to the exported structure, allow the triggers to fire in the rules()
   function, then zero-fill the exported structure so that unrelated rules
   won't execute when other triggers are fired.
*/

void fire_prj(void)
{
   prj = int_prj;
   rules();
   ZERO(prj);
}

void fire_mod(void)
{
   mod = int_mod;
   rules();
   ZERO(mod);
}

static void fire_fcn(void)
{
   fcn = int_fcn;
   rules();
   ZERO(fcn);
}

static void fire_stm(void)
{
   stm = int_stm;
   rules();
   ZERO(stm);
}

void fire_lin(void)
{
   lin = int_lin;
   rules();
   ZERO(lin);
}

void fire_lex(void)
{
   lex = int_lex;
   rules();
   ZERO(lex);
}
static short yydef[] = {
	 203,  205,   -1,  -11,  -21,  202,  204,  -25,  -31,  -35, 
	 -39,  211,  213,  215,  217,  219,  221,  224,  229,  232, 
	 235,  236,  237,  206,  -45,   79,   53,  208,  201,  200, 
	 199,  199,  193,  -49,  197,  198,  212,  214,  216,  218, 
	 220,  222,  223,  225,  226,  227,  228,  230,  231,  233, 
	 234,  198,  207,  196,  -53,  -57,  195
};
static short yyex[] = {
	 257,  209,   40,  209,   42,  209,   59,  209,   -1,    4, 
	 257,  210,   40,  210,   42,  210,   59,  210,   -1,    3, 
	   0,    0,   -1,    1,  257,   11,   41,    9,   -1,   10, 
	 123,    7,   -1,    8,  123,    5,   -1,    6,   44,  208, 
	  59,  208,   -1,   12,   59,  194,   -1,    1,   59,  194, 
	  -1,    1,   41,  194,   -1,    1,   41,  194,   -1,    1
};
static short yyact[] = {
	-195,   -1, -197, -305, -231, -288, -289, -290, -291, -292, 
	-293, -294, -295, -296, -297, -298, -299, -300, -301, -302, 
	-229, -228, -226,  301,  300,  299,  298,  297,  296,  295, 
	 294,  293,  292,  291,  290,  289,  288,  287,  286,  285, 
	 284,  283,  282,  257,   42,   40,   -1, -305, -292, -293, 
	-294, -295, -296, -297, -298, -299, -300, -301, -302, -229, 
	-228, -226,  301,  300,  299,  298,  297,  296,  295,  294, 
	 293,  292,  291,  290,  289,  288,  282,   42, -195,   -1, 
	-197,  257,   42,   40, -195, -197,  257,   40,   -8, -188, 
	  91,   40, -187, -197,  257,  123, -230, -197,  257,  123, 
	-195,   -1, -235, -197,  257,   59,   42,   40, -182, -305, 
	-231, -288, -289, -290, -291, -292, -293, -294, -295, -296, 
	-297, -298, -299, -300, -301, -302, -229, -228, -226,  301, 
	 300,  299,  298,  297,  296,  295,  294,  293,  292,  291, 
	 290,  289,  288,  287,  286,  285,  284,  283,  282,  123, 
	-319,   41, -262, -257, -172, -258, -259, -260, -320, -261, 
	-197, -238, -240, -176, -173, -174,  263,  262,  260,  259, 
	 258,  257,  126,   93,   45,   43,   42,   40,   38,   33, 
	-197,  257, -305, -231, -288, -289, -290, -291, -292, -293, 
	-294, -295, -296, -297, -298, -299, -300, -301, -302, -229, 
	-228, -226,  301,  300,  299,  298,  297,  296,  295,  294, 
	 293,  292,  291,  290,  289,  288,  287,  286,  285,  284, 
	 283,  282, -166,   61, -165, -234,   59,   44, -262, -257, 
	-172, -258, -259, -260, -363, -182, -355, -261, -197, -238, 
	-240, -176, -173, -174, -305, -231, -288, -289, -290, -291, 
	-292, -293, -294, -295, -296, -297, -298, -299, -300, -301, 
	-302, -229, -228, -226, -154, -155, -158, -159, -160, -206, 
	-161, -162, -163, -164,  -25,  315,  314,  313,  312,  311, 
	 310,  309,  308,  306,  305,  304,  301,  300,  299,  298, 
	 297,  296,  295,  294,  293,  292,  291,  290,  289,  288, 
	 287,  286,  285,  284,  283,  282,  263,  262,  260,  259, 
	 258,  257,  126,  125,  123,   59,   45,   43,   42,   40, 
	  38,   33, -305, -292, -293, -294, -295, -296, -297, -298, 
	-299, -300, -301, -302, -229, -228, -226,  301,  300,  299, 
	 298,  297,  296,  295,  294,  293,  292,  291,  290,  289, 
	 288,  282, -322,   41, -321,   93, -152, -151,  271,   63, 
	-150,  270, -149,  124, -148,   94, -147,   38, -145, -146, 
	 269,  268, -141, -142, -143, -144,  267,  266,   62,   60, 
	-139, -140,  265,  264, -137, -138,   45,   43, -136, -134, 
	-135,   47,   42,   37, -262, -257, -133, -258, -259, -260, 
	-261, -197, -238, -240, -176, -173, -174,  263,  262,  260, 
	 259,  258,  257,  126,   45,   43,   42,   40,   38,   33, 
	-262, -257, -172, -258, -259, -260, -261, -197, -238, -240, 
	-176, -173, -174,  263,  262,  260,  259,  258,  257,  126, 
	  45,   43,   42,   40,   38,   33, -262, -257, -132, -258, 
	-259, -260, -261, -197, -238, -240, -176, -173, -174,  263, 
	 262,  260,  259,  258,  257,  126,   45,   43,   42,   40, 
	  38,   33, -129, -130, -128, -131, -248, -249,  263,  262, 
	 261,   91,   46,   40, -262, -257, -172, -258, -259, -260, 
	-261, -197, -238, -240, -176, -173, -174, -305, -292, -293, 
	-294, -295, -296, -297, -298, -299, -300, -301, -302, -229, 
	-228, -226,  301,  300,  299,  298,  297,  296,  295,  294, 
	 293,  292,  291,  290,  289,  288,  282,  263,  262,  260, 
	 259,  258,  257,  126,   45,   43,   42,   40,   38,   33, 
	-241,  259, -125,  123, -124,   61, -123, -227,  125,   44, 
	-120,  123, -262, -257, -172, -258, -259, -260, -119, -261, 
	-197, -238, -240, -176, -173, -174,  263,  262,  260,  259, 
	 258,  257,  126,  123,   45,   43,   42,   40,   38,   33, 
	-368,   59, -367,   59,  -34,   40, -115,   40, -114,   40, 
	-113,   40, -262, -257, -172, -258, -259, -260, -363, -182, 
	-357, -261, -197, -238, -240, -176, -173, -174, -305, -231, 
	-288, -289, -290, -291, -292, -293, -294, -295, -296, -297, 
	-298, -299, -300, -301, -302, -229, -228, -226, -154, -155, 
	-158, -159, -160, -206, -161, -162, -163, -164,  -25,  315, 
	 314,  313,  312,  311,  310,  309,  308,  306,  305,  304, 
	 301,  300,  299,  298,  297,  296,  295,  294,  293,  292, 
	 291,  290,  289,  288,  287,  286,  285,  284,  283,  282, 
	 263,  262,  260,  259,  258,  257,  126,  125,  123,   59, 
	  45,   43,   42,   40,   38,   33, -262, -257, -172, -258, 
	-259, -260, -363, -182, -356, -261, -197, -238, -240, -176, 
	-173, -174, -154, -155, -158, -159, -160, -206, -161, -162, 
	-163, -164,  -25,  315,  314,  313,  312,  311,  310,  309, 
	 308,  306,  305,  304,  263,  262,  260,  259,  258,  257, 
	 126,  125,  123,   59,   45,   43,   42,   40,   38,   33, 
	-215,   58, -110, -364,   59,   44, -271, -272, -273, -274, 
	-275, -276, -277, -278, -279, -280, -281,  281,  280,  279, 
	 278,  277,  276,  275,  274,  273,  272,   61, -108,   58, 
	-107,   44, -105,   44, -103,   -1, -104, -197, -305, -292, 
	-293, -294, -295, -296, -297, -298, -299, -300, -301, -302, 
	-229, -228, -226,  301,  300,  299,  298,  297,  296,  295, 
	 294,  293,  292,  291,  290,  289,  288,  282,  257,   91, 
	  42,   40, -262, -257, -172, -244, -258, -259, -260, -261, 
	-197, -238, -240, -176, -173, -174,  263,  262,  260,  259, 
	 258,  257,  126,   45,   43,   42,   41,   40,   38,   33, 
	 -97,   -1, -104, -305, -292, -293, -294, -295, -296, -297, 
	-298, -299, -300, -301, -302, -229, -228, -226,  301,  300, 
	 299,  298,  297,  296,  295,  294,  293,  292,  291,  290, 
	 289,  288,  282,   91,   42,   40,  -96,   41, -239, -110, 
	  44,   41, -195,   -1,  -94, -197, -305, -292, -293, -294, 
	-295, -296, -297, -298, -299, -300, -301, -302, -229, -228, 
	-226,  301,  300,  299,  298,  297,  296,  295,  294,  293, 
	 292,  291,  290,  289,  288,  282,  257,   58,   42,   40, 
	-307, -305, -292, -293, -294, -295, -296, -297, -298, -299, 
	-300, -301, -302, -229, -228, -226,  301,  300,  299,  298, 
	 297,  296,  295,  294,  293,  292,  291,  290,  289,  288, 
	 282,  125, -369,   59, -110,   44, -366,   59, -262, -257, 
	-172, -258, -259, -260, -363, -182, -261, -197, -238, -240, 
	-176, -173, -174, -154, -155, -158, -159, -160, -206, -161, 
	-162, -163, -164,  -25,  315,  314,  313,  312,  311,  310, 
	 309,  308,  306,  305,  304,  263,  262,  260,  259,  258, 
	 257,  126,  123,   59,   45,   43,   42,   40,   38,   33, 
	-262, -257, -172, -258, -259, -260, -363, -182, -358, -261, 
	-197, -238, -240, -176, -173, -174, -154, -155, -158, -159, 
	-160, -206, -161, -162, -163, -164,  -25,  315,  314,  313, 
	 312,  311,  310,  309,  308,  306,  305,  304,  263,  262, 
	 260,  259,  258,  257,  126,  125,  123,   59,   45,   43, 
	  42,   40,   38,   33, -216,   58, -197, -329,  302,  257, 
	-324,   41, -305, -292, -293, -294, -295, -296, -297, -298, 
	-299, -300, -301, -302, -229, -228, -226, -332,  302,  301, 
	 300,  299,  298,  297,  296,  295,  294,  293,  292,  291, 
	 290,  289,  288,  282, -262, -257, -172, -258, -259, -260, 
	-339, -261, -197, -238, -240, -176, -173, -174,  263,  262, 
	 260,  259,  258,  257,  126,   93,   45,   43,   42,   40, 
	  38,   33,  -84,  -83,   91,   40, -103, -343,   -1, -104, 
	-197, -305, -292, -293, -294, -295, -296, -297, -298, -299, 
	-300, -301, -302, -229, -228, -226,  301,  300,  299,  298, 
	 297,  296,  295,  294,  293,  292,  291,  290,  289,  288, 
	 282,  257,   91,   42,   41,   40, -103, -104, -197,  257, 
	  91,   40, -323,   41, -110,  -80,   58,   44, -256,   41, 
	-245,  -79,   44,   41, -110, -243,   93,   44,  -97, -343, 
	  -1, -104, -305, -292, -293, -294, -295, -296, -297, -298, 
	-299, -300, -301, -302, -229, -228, -226,  301,  300,  299, 
	 298,  297,  296,  295,  294,  293,  292,  291,  290,  289, 
	 288,  282,   91,   42,   41,   40,  -97, -104,   91,   40, 
	-123, -315,  125,   44,  -78,   58,  -77, -310,   59,   44, 
	-306, -305, -292, -293, -294, -295, -296, -297, -298, -299, 
	-300, -301, -302, -229, -228, -226,  301,  300,  299,  298, 
	 297,  296,  295,  294,  293,  292,  291,  290,  289,  288, 
	 282,  125,  -76, -348,  125,   44,  -75,   59, -208, -110, 
	  44,   41, -212, -110,   44,   41, -214, -110,   44,   41, 
	-340,   93, -345, -305, -292, -293, -294, -295, -296, -297, 
	-298, -299, -300, -301, -302, -229, -228, -226,  301,  300, 
	 299,  298,  297,  296,  295,  294,  293,  292,  291,  290, 
	 289,  288,  282,   41, -262, -257, -172, -258, -259, -260, 
	-341, -261, -197, -238, -240, -176, -173, -174,  263,  262, 
	 260,  259,  258,  257,  126,   93,   45,   43,   42,   40, 
	  38,   33, -344,   41, -338,   41, -195,   -1,  -94, -197, 
	 257,   58,   42,   40, -262, -257, -172, -258, -259, -260, 
	-119, -349, -261, -197, -238, -240, -176, -173, -174,  263, 
	 262,  260,  259,  258,  257,  126,  125,  123,   45,   43, 
	  42,   40,   38,   33, -262, -257, -172, -258, -259, -260, 
	 -55, -261, -197, -238, -240, -176, -173, -174,  263,  262, 
	 260,  259,  258,  257,  126,   59,   45,   43,   42,   40, 
	  38,   33,  -69,  309, -346,   41, -342,   93, -110,  -56, 
	  59,   44,  -64,   40, -203,   41, -201,   41,  -60, -110, 
	  44,   41, -210,  307, -204,   59,   -1
};
static short yypact[] = {
	  62,   90,  100,  100,   23,   62,   90,  152,  180,  182, 
	 223,  358,  361,  363,  365,  367,  370,  376,  382,  386, 
	 391,  478,  541,  545,  433,  757,  769,  223,  771,  773, 
	 793,  858,  955,  433, 1134, 1179,  361,  363,  365,  367, 
	 370,  376,  376,  382,  382,  382,  382,  386,  386,  391, 
	 391, 1238, 1245, 1134,  433,  433, 1453,  984,  984, 1455, 
	 984, 1450, 1447,  433, 1445,  984,  984,  984, 1443, 1440, 
	1437, 1435,  984, 1433, 1418, 1389, 1370,  433,  433,  433, 
	1365, 1363, 1348, 1318, 1301,  984, 1298, 1294, 1290, 1287, 
	1284, 1266, 1248,  433, 1242,  433, 1217, 1196, 1192, 1189, 
	1186, 1183, 1156, 1118, 1088, 1071, 1068,  984,  433,  433, 
	1065, 1037,  433,  433,  433,  984,  957,  953,  566,  337, 
	 936,  901,  181,  433,  181,  880,  877,  433,  826,  181, 
	 181,  433,  512,  433,  433,  433,  433,  433,  433,  433, 
	 433,  433,  433,  433,  433,  433,  433,  433,  433,  433, 
	 433,  433,  744,  433,  741,  713,  639,  591,  589,  587, 
	 585,  181,  583,  581,   81,  566,  129,  551,  337,  548, 
	 543,  512,  459,  459,  433,  407,  355,  353,  337,  181, 
	 104,  275,  129,  226,  202,  202,  181,  166,  151,  129, 
	 104,   98,   94,   86,   81,   23
};
static short yygo[] = {
	  -5, -242, -225, -225, -225,  -27,  -27,  -27,  -27,  -27, 
	 -27,  -27, -225,  -27, -225, -331,  -27,  -27,  -27, -225, 
	 -24,  -24, -246, -247,  -27,  -27, -117, -225, -330, -225, 
	 -27,  -24, -225,  -10,   -9, -225, -225, -225, -237,  195, 
	 194,  193,  192,  191,  190,  186,  181,  180,  179,  164, 
	 161,  156,  155,  130,  129,  124,  122,  121,  115,  111, 
	 107,  106,  102,   85,   76,   72,   67,   66,   65,   60, 
	  58,   57,   35,   30,    4,  -23,  -33,  -33,  -33,  -33, 
	 -62,  -70,  -87,  -88,  -89,  -98, -126, -126, -101, -126, 
	-153,  171,  151,  132,  131,  127,  114,  113,  112,   74, 
	  63,   55,   54,   33,   24,  -22,  -99, -347, -251, -270, 
	-283, -347, -250, -347, -282,  165,  128,  118,  109,  108, 
	  78,   75, -263, -263, -263, -263, -263, -263, -263, -263, 
	-263, -263, -263, -263, -263, -263, -263, -263, -263, -263, 
	-263, -263, -263, -263, -263, -263, -263, -263, -252, -253, 
	-263, -255, -263,  -26,  187,  175,  174,  173,  172,  153, 
	 150,  149,  148,  147,  146,  145,  144,  143,  142,  141, 
	 140,  139,  138,  137,  136,  135,  134,  133,  123,  103, 
	  95,   93,   82,   79,   77, -175, -264, -266, -267, -268, 
	-254, -265,  174,  135,  134,  133,   95, -100, -127, -336, 
	 171,  132,  -51,  -50,  -21,  137,  136,  -49,  -48,  -20, 
	 139,  138,  -47,  -46,  -45,  -44,  -19,  143,  142,  141, 
	 140,  -43,  -42,  -18,  145,  144,  -41,  -17,  146,  -40, 
	 -16,  147,  -39,  -15,  148,  -38,  -14,  149,  -37,  -13, 
	 150,  -12, -284, -236, -284, -284, -284, -284, -284, -284, 
	-269,  187,  153,  123,  103,   93,   82,   79,   77, -109, 
	-314,  -71, -313,  -85, -318, -111, -177,  153,  123,  103, 
	  93,   82,   77, -372, -360, -360, -372, -359,  195,  182, 
	 156,    4, -191, -233, -232, -191, -181,  195,  185,  184, 
	   4, -184,   -4, -185,   -3, -328, -328, -328, -328,   -3, 
	  -3,   -3,   -3,   -3,   -3,   -3,   -3, -327,  195,  189, 
	 185,  184,  182,  181,  166,  156,  121,   31,   30,    5, 
	   4, -186, -286, -285,  164, -335,  -53, -189,  -53,  -28, 
	 -28,  -11, -189, -198,  194,  190,  180,  164,  121,  102, 
	  76,   30, -351, -350, -287,  118,   75, -303, -304, -192, 
	-168,  -92, -121,  119, -169, -309, -309, -308,  120,   91, 
	  -6, -122, -122, -122,  -32, -122,  -32,  -31,  171,  168, 
	 132,  120,  119,   91,    0,  -93, -312, -311,   76, -193, 
	 -95, -170,  124, -171, -317, -316,  122,   -7,   -7,   -2, 
	 193,   35, -325, -326,  -36,  -52,  -52,  -36, -194,  102, 
	  96,   31,   30,    5,    0, -178, -179,  -72, -224,  -82, 
	 178,   83, -102, -180, -223, -106,  -29,  -30, -334, -333, 
	 104,  -81,  -81, -337,  102,   96,  -54,  -54,  -35,   51, 
	  35,  -91, -209, -200, -202, -213, -211, -207, -353, -354, 
	-217, -362, -205, -362, -361,  155,  115,  111,  107,   85, 
	  72,   67,   66,   65,   60,   58,   57, -352, -375, -376, 
	-375, -222,  189,  182,  166, -221, -220, -219, -218,  -73, 
	 -86, -112, -156,  156, -157, -183,  181,  -66,  -57, -365, 
	 -67,  -58,  -68, -116,  -74,  -90,  -65,  -63, -118,   55, 
	  54,   33,  -61,  -59, -371, -370,    4, -199, -190, -374, 
	-373,  166, -167,   -1
};
static short yypgo[] = {
	   0,    0,    0,  293,  321,  350,  347,  383,  348,  405, 
	 406,  413,  502,   38,  498,  495,  467,  493,  467,  492, 
	 467,  484,  483,  467,  482,  479,  481,  466,  480,  478, 
	 477,  470,  469,  457,  444,  444,  444,  444,  444,  415, 
	 412,  389,  379,  348,  349,  349,  354,  292,  286,  286, 
	 277,  277,  250,    1,    1,    1,   75,   75,  105,  105, 
	 105,  105,  105,  105,  105,  105,  106,  106,  153,  153, 
	 153,  153,  153,  185,  185,  185,  185,  185,  185,  191, 
	 191,  204,  204,  204,  204,  114,  114,  259,  259,  259, 
	 259,  259,  259,  259,  259,  259,  259,  259,   90,   90, 
	 266,  291,  291,  323,  292,  292,  292,  292,  307,  307, 
	 307,  307,  307,  307,  307,  307,  307,  307,  307,  307, 
	 307,  307,  347,  347,  352,  352,  357,  375,  375,  377, 
	 377,  348,  381,  381,  385,  389,  389,  389,  389,  389, 
	 389,  398,  398,  367,  367,  414,  416,  416,  409,  417, 
	 417,  419,  419,  199,  428,  428,  428,  428,  428,  428, 
	 428,  428,  428,  344,  344,  344,  431,  431,  444,  457, 
	 457,  461,  461,  461,  461,  475,  475,  472,  472,  465, 
	 465,  466,  468,  468,  468,  468,    0,    0,  495,  497, 
	 497,  500,  500,  488,  488,  479,  423,  423,  423,  199, 
	 409,  414,  398,  398,  333,  333,  385,  377,  323,  286, 
	 286,  250,  241,  241,  239,  239,  236,  236,  233,  233, 
	 230,  230,  227,  227,  227,  223,  223,  223,  223,  223, 
	 216,  216,  216,  209,  209,  209,  153,    1,    0
};
static short yyrlen[] = {
	   0,    0,    0,    0,    0,    0,    2,    0,    2,    0, 
	   0,    0,    0,    1,    0,    1,   10,    0,    9,    0, 
	   9,    0,    0,    6,    0,    3,    0,    6,    0,    0, 
	   0,    0,    0,    3,    1,    1,    1,    1,    1,    0, 
	   0,    1,    1,    4,    1,    1,    0,    1,    3,    3, 
	   3,    2,    5,    1,    1,    3,    1,    2,    1,    4, 
	   3,    4,    3,    3,    2,    2,    1,    3,    2,    2, 
	   2,    2,    4,    1,    1,    1,    1,    1,    1,    1, 
	   4,    1,    3,    3,    3,    1,    3,    1,    1,    1, 
	   1,    1,    1,    1,    1,    1,    1,    1,    1,    3, 
	   1,    1,    3,    3,    1,    1,    1,    1,    1,    1, 
	   1,    1,    1,    1,    1,    1,    1,    1,    1,    1, 
	   1,    1,    6,    5,    1,    2,    3,    1,    3,    2, 
	   3,    6,    1,    3,    3,    3,    3,    4,    4,    6, 
	   6,    2,    3,    1,    2,    3,    1,    3,    3,    1, 
	   3,    2,    1,    2,    3,    2,    3,    3,    4,    2, 
	   3,    3,    4,    1,    3,    4,    1,    3,    1,    5, 
	   4,    2,    3,    3,    4,    1,    2,    1,    2,    1, 
	   2,    8,    3,    2,    2,    3,    1,    2,    1,    3, 
	   4,    1,    2,    1,    0,    0,    2,    1,    1,    1, 
	   1,    1,    2,    1,    2,    1,    1,    1,    1,    1, 
	   1,    1,    3,    1,    3,    1,    3,    1,    3,    1, 
	   3,    1,    3,    3,    1,    3,    3,    3,    3,    1, 
	   3,    3,    1,    3,    3,    1,    1,    1,    2
};
#define YYS0	195
#define YYDELTA	183
#define YYNPACT	196
#define YYNDEF	57

#define YYr236	0
#define YYr237	1
#define YYr238	2
#define YYr80	3
#define YYr83	4
#define YYr108	5
#define YYr112	6
#define YYr124	7
#define YYr126	8
#define YYr138	9
#define YYr140	10
#define YYr143	11
#define YYr231	12
#define YYr235	13
#define YYr229	14
#define YYr227	15
#define YYr218	16
#define YYr217	17
#define YYr216	18
#define YYr215	19
#define YYr214	20
#define YYr213	21
#define YYr212	22
#define YYr211	23
#define YYr210	24
#define YYr209	25
#define YYr208	26
#define YYr206	27
#define YYr205	28
#define YYr203	29
#define YYr202	30
#define YYr190	31
#define YYr188	32
#define YYr187	33
#define YYr186	34
#define YYr185	35
#define YYr184	36
#define YYr183	37
#define YYr182	38
#define YYr144	39
#define YYr141	40
#define YYr134	41
#define YYr127	42
#define YYr123	43
#define YYr114	44
#define YYr113	45
#define YYr110	46
#define YYr89	47
#define YYr84	48
#define YYr81	49
#define YYr78	50
#define YYr77	51
#define YYr60	52
#define YYrACCEPT	YYr236
#define YYrERROR	YYr237
#define YYrLR2	YYr238
#line 2 "c:\mks/etc/yyparse.c"

/*
 * Copyright 1985, 1990 by Mortice Kern Systems Inc.  All rights reserved.
 * 
 * Automaton to interpret LALR(1) tables.
 *
 *	Macros:
 *		yyclearin - clear the lookahead token.
 *		yyerrok - forgive a pending error
 *		YYERROR - simulate an error
 *		YYACCEPT - halt and return 0
 *		YYABORT - halt and return 1
 *		YYRETURN(value) - halt and return value.  You should use this
 *			instead of return(value).
 *		YYREAD - ensure yychar contains a lookahead token by reading
 *			one if it does not.  See also YYSYNC.
 *		YYRECOVERING - 1 if syntax error detected and not recovered
 *			yet; otherwise, 0.
 *
 *	Preprocessor flags:
 *		YYDEBUG - includes debug code.  The parser will print
 *			 a travelogue of the parse if this is defined
 *			 and yydebug is non-zero.
 *		YYSSIZE - size of state and value stacks (default 150).
 *		YYSTATIC - By default, the state stack is an automatic array.
 *			If this is defined, the stack will be static.
 *			In either case, the value stack is static.
 *		YYALLOC - Dynamically allocate both the state and value stacks
 *			by calling malloc() and free().
 *		YYLR2 - defined if lookahead is needed to resolve R/R or S/R conflicts
 *		YYSYNC - if defined, yacc guarantees to fetch a lookahead token
 *			before any action, even if it doesnt need it for a decision.
 *			If YYSYNC is defined, YYREAD will never be necessary unless
 *			the user explicitly sets yychar = -1
 *
 *	Copyright (c) 1983, by the University of Waterloo
 */

/* GENTEXT: yyerror */
#ifndef I18N
#define	gettext(x)	x
#endif

#ifndef YYSSIZE
# define YYSSIZE	150
#endif

#define YYERROR		goto yyerrlabel
#define yyerrok		yyerrflag = 0
#define yyclearin	yychar = -1
#define YYACCEPT	YYRETURN(0)
#define YYABORT		YYRETURN(1)
#define YYRECOVERING()	(yyerrflag != 0)
#ifdef YYALLOC
# define YYRETURN(val)	{ retval = (val); goto yyReturn; }
#else
# define YYRETURN(val)	return(val)
#endif
#ifdef YYDEBUG
/* The if..else makes this macro behave exactly like a statement */
# define YYREAD	if (yychar < 0) {					\
			if ((yychar = yylex()) < 0)			\
				yychar = 0;				\
			if (yydebug)					\
				printf(gettext("read %s (%d)\n"), 	\
				yyptok(yychar),				\
				yychar);				\
		} else
#else
# define YYREAD	if (yychar < 0) {					\
			if ((yychar = yylex()) < 0)			\
				yychar = 0;				\
		} else
#endif
#define YYERRCODE	256		/* value of `error' */
#if 0 && defined(__TURBOC__) && __SMALL__
	/* THIS ONLY WORKS ON TURBO C 1.5 !!! */
#define	YYQYYP	*(int *)((int)yyq + ((int)yyq-(int)yyp))
#else
#define	YYQYYP	yyq[yyq-yyp]
#endif

YYSTYPE	yyval;				/* $$ */
YYSTYPE	*yypvt;				/* $n */
YYSTYPE	yylval;				/* yylex() sets this */

int	yychar,				/* current token */
	yyerrflag,			/* error flag */
	yynerrs;			/* error count */

#ifdef YYDEBUG
int yydebug = 0;		/* debug flag & tables */
extern char	*yysvar[], *yystoken[], *yyptok();
extern short	yyrmap[], yysmap[];
extern int	yynstate, yynvar, yyntoken, yynrule;
# define yyassert(condition, msg, arg) \
	if (!(condition)) { printf(gettext("\nyacc bug: ")); printf(msg, arg); YYABORT; }
#else /* !YYDEBUG */
# define yyassert(condition, msg, arg)
#endif

yyparse()
{

	register short		yyi, *yyp;	/* for table lookup */
	register short		*yyps;		/* top of state stack */
	register short		yystate;	/* current state */
	register YYSTYPE	*yypv;		/* top of value stack */
	register short		*yyq;
	register int		yyj;

#ifdef YYSTATIC
	static short	yys[YYSSIZE + 1];
	static YYSTYPE	yyv[YYSSIZE + 1];
#else
#ifdef YYALLOC
	YYSTYPE *yyv;
	short	*yys;
	YYSTYPE save_yylval;
	YYSTYPE save_yyval;
	YYSTYPE *save_yypvt;
	int save_yychar, save_yyerrflag, save_yynerrs;
	int retval;
#if 0	/* defined in <stdlib.h>*/
	extern char	*malloc();
#endif
#else
	short		yys[YYSSIZE + 1];
	static YYSTYPE	yyv[YYSSIZE + 1];	/* historically static */
#endif
#endif

#ifdef YYALLOC
	yys = (short *) malloc((YYSSIZE + 1) * sizeof(short));
	yyv = (YYSTYPE *) malloc((YYSSIZE + 1) * sizeof(YYSTYPE));
	if (yys == (short *)0 || yyv == (YYSTYPE *)0) {
		yyerror("Not enough space for parser stacks");
		return 1;
	}
	save_yylval = yylval;
	save_yyval = yyval;
	save_yypvt = yypvt;
	save_yychar = yychar;
	save_yyerrflag = yyerrflag;
	save_yynerrs = yynerrs;
#endif

	yynerrs = 0;
	yyerrflag = 0;
	yychar = -1;
	yyps = yys;
	yypv = yyv;
	yystate = YYS0;		/* start state */

yyStack:
	yyassert((unsigned)yystate < yynstate, gettext("state %d\n"), yystate);
	if (++yyps > &yys[YYSSIZE]) {
		yyerror("Parser stack overflow");
		YYABORT;
	}
	*yyps = yystate;	/* stack current state */
	*++yypv = yyval;	/* ... and value */

#ifdef YYDEBUG
	if (yydebug)
		printf(gettext("state %d (%d), char %s (%d)\n"),yysmap[yystate],
			yystate, yyptok(yychar), yychar);
#endif

	/*
	 *	Look up next action in action table.
	 */
yyEncore:
#ifdef YYSYNC
	YYREAD;
#endif
	if (yystate >= sizeof yypact/sizeof yypact[0]) 	/* simple state */
		yyi = yystate - YYDELTA;	/* reduce in any case */
	else {
		if(*(yyp = &yyact[yypact[yystate]]) >= 0) {
			/* Look for a shift on yychar */
#ifndef YYSYNC
			YYREAD;
#endif
			yyq = yyp;
			yyi = yychar;
#if 0 && defined(__TURBOC__) && __SMALL__
	/* THIS ONLY WORKS ON TURBO C 1.5 !!! */
			/* yyi is in di, yyp is in si */
		L01:
			asm lodsw	/* ax = *yyp++; */
			asm cmp yyi, ax
			asm jl L01
#else
			while (yyi < *yyp++)
				;
#endif
			if (yyi == yyp[-1]) {
				yystate = ~YYQYYP;
#ifdef YYDEBUG
				if (yydebug)
					printf(gettext("shift %d (%d)\n"),
						yysmap[yystate], yystate);
#endif
				yyval = yylval;		/* stack what yylex() set */
				yychar = -1;		/* clear token */
				if (yyerrflag)
					yyerrflag--;	/* successful shift */
				goto yyStack;
			}
		}

		/*
	 	 *	Fell through - take default action
	 	 */

		if (yystate >= sizeof yydef /sizeof yydef[0])
			goto yyError;
		if ((yyi = yydef[yystate]) < 0)	 { /* default == reduce? */
											/* Search exception table */
			yyassert((unsigned)~yyi < sizeof yyex/sizeof yyex[0],
				gettext("exception %d\n"), yystate);
			yyp = &yyex[~yyi];
#ifndef YYSYNC
			YYREAD;
#endif
			while((yyi = *yyp) >= 0 && yyi != yychar)
				yyp += 2;
			yyi = yyp[1];
			yyassert(yyi >= 0,
				 gettext("Ex table not reduce %d\n"), yyi);
		}
	}

#ifdef YYLR2
yyReduce:	/* reduce yyi */
#endif
	yyassert((unsigned)yyi < yynrule, gettext("reduce %d\n"), yyi);
	yyj = yyrlen[yyi];
#ifdef YYDEBUG
	if (yydebug) printf(gettext("reduce %d (%d), pops %d (%d)\n"), 
		yyrmap[yyi], yyi, yysmap[yyps[-yyj]], yyps[-yyj]);
#endif
	yyps -= yyj;		/* pop stacks */
	yypvt = yypv;		/* save top */
	yypv -= yyj;
	yyval = yypv[1];	/* default action $$ = $1 */
	switch (yyi) {		/* perform semantic action */
		
case YYr60: {	/* conditional_expr :  logical_or_expr '?' expr ':' conditional_expr */
#line 157 "gram.y"
 ++fcn_decisions; 
} break;

case YYr77: {	/* declaration :  declaration_specifiers ';' */
#line 194 "gram.y"
 is_typedef = FALSE; 
} break;

case YYr78: {	/* declaration :  declaration_specifiers init_declarator_list ';' */
#line 196 "gram.y"
 is_typedef = FALSE; 
} break;

case YYr80: {	/* declaration_specifiers :  storage_class_specifier */
#line 207 "gram.y"
 ++nested_decl_specs; 
} break;

case YYr81: {	/* declaration_specifiers :  storage_class_specifier $80 declaration_specifiers */
#line 209 "gram.y"
 --nested_decl_specs; 
} break;

case YYr83: {	/* declaration_specifiers :  type_specifier */
#line 212 "gram.y"
 ++nested_decl_specs; 
} break;

case YYr84: {	/* declaration_specifiers :  type_specifier $83 declaration_specifiers */
#line 214 "gram.y"
 --nested_decl_specs; 
} break;

case YYr89: {	/* storage_class_specifier :  TK_TYPEDEF */
#line 233 "gram.y"
 is_typedef = TRUE; 
} break;

case YYr108: {	/* struct_or_union_specifier :  struct_or_union identifier */
#line 263 "gram.y"
 looking_for_tag = FALSE; 
} break;

case YYr110: {	/* struct_or_union_specifier :  struct_or_union '{' */
#line 266 "gram.y"
 looking_for_tag = FALSE; 
} break;

case YYr112: {	/* struct_or_union_specifier :  struct_or_union identifier */
#line 269 "gram.y"
 looking_for_tag = FALSE; 
} break;

case YYr113: {	/* struct_or_union :  TK_STRUCT */
#line 280 "gram.y"
 looking_for_tag = TRUE; 
} break;

case YYr114: {	/* struct_or_union :  TK_UNION */
#line 282 "gram.y"
 looking_for_tag = TRUE; 
} break;

case YYr123: {	/* enum_specifier :  enum '{' enumerator_list '}' */
#line 311 "gram.y"
 looking_for_tag = FALSE; 
} break;

case YYr124: {	/* enum_specifier :  enum identifier */
#line 313 "gram.y"
 looking_for_tag = FALSE; 
} break;

case YYr126: {	/* enum_specifier :  enum identifier */
#line 316 "gram.y"
 looking_for_tag = FALSE; 
} break;

case YYr127: {	/* enum :  TK_ENUM */
#line 325 "gram.y"
 looking_for_tag = TRUE; 
} break;

case YYr134: {	/* declarator2 :  identifier */
#line 345 "gram.y"

         
         if (is_typedef && nested_decl_specs == 0)
           typedef_symbol_table_add(token());
      
} break;

case YYr138: {	/* declarator2 :  declarator2 '(' */
#line 363 "gram.y"

         if (!is_within_function)
            strcpy(function_name, last_identifier);
      
} break;

case YYr140: {	/* declarator2 :  declarator2 '(' */
#line 374 "gram.y"

         ++nested_decl_specs;
         if (!is_within_function)
            strcpy(function_name, last_identifier);
      
} break;

case YYr141: {	/* declarator2 :  declarator2 '(' $140 parameter_type_list */
#line 380 "gram.y"
 --nested_decl_specs; 
} break;

case YYr143: {	/* declarator2 :  declarator2 '(' */
#line 383 "gram.y"

         ++nested_decl_specs;
         if (!is_within_function)
            strcpy(function_name, last_identifier);
      
} break;

case YYr144: {	/* declarator2 :  declarator2 '(' $143 parameter_identifier_list */
#line 389 "gram.y"
 --nested_decl_specs; 
} break;

case YYr182: {	/* statement :  compound_statement */
#line 467 "gram.y"

         is_else = is_if = FALSE;

         ++int_fcn.high;      

         
         not_case_label();

         
         int_stm.is_comp = int_stm.is_high = int_stm.end = TRUE;
         int_stm.depth = depth;
         fire_stm();
         ZERO(int_stm);
      
} break;

case YYr183: {	/* statement :  expression_statement */
#line 485 "gram.y"

         check_multiple_statements();

         ++int_fcn.low;          

         
         not_case_label();

         
         int_stm.is_expr = int_stm.is_low = int_stm.end = TRUE;
         int_stm.depth = depth;
         fire_stm();
         ZERO(int_stm);
      
} break;

case YYr184: {	/* statement :  selection_statement */
#line 503 "gram.y"

         ++int_fcn.high;      

         
         not_case_label();

         
         int_stm.is_select = int_stm.is_high = int_stm.end = TRUE;
         int_stm.depth = depth;
         fire_stm();
         ZERO(int_stm);
      
} break;

case YYr185: {	/* statement :  iteration_statement */
#line 519 "gram.y"

         ++int_fcn.high;      

         
         not_case_label();

         
         int_stm.is_iter = int_stm.is_high = int_stm.end = TRUE;
         int_stm.depth = depth;
         fire_stm();
         ZERO(int_stm);
      
} break;

case YYr186: {	/* statement :  jump_statement */
#line 535 "gram.y"

         check_multiple_statements();

         ++int_fcn.low;          

         
         not_case_label();

         
         int_stm.is_jump = int_stm.is_low = int_stm.end = TRUE;
         int_stm.depth = depth;
         fire_stm();
         ZERO(int_stm);
      
} break;

case YYr187: {	/* labeled_statement :  identifier ':' statement */
#line 556 "gram.y"
 is_else = is_if = FALSE; 
} break;

case YYr188: {	/* labeled_statement :  TK_CASE constant_expr ':' */
#line 558 "gram.y"

         check_multiple_statements();

         
         case_label();
      
} break;

case YYr190: {	/* labeled_statement :  TK_DEFAULT ':' */
#line 566 "gram.y"
 check_multiple_statements(); 
} break;

case YYr202: {	/* selection_statement :  TK_IF '(' expr ')' */
#line 594 "gram.y"

         is_if = TRUE;
         check_multiple_statements();
         ++depth;                
         ++fcn_decisions;        
      
} break;

case YYr203: {	/* selection_statement :  TK_IF '(' expr ')' $202 statement */
#line 601 "gram.y"
 --depth;                  
} break;

case YYr205: {	/* selection_statement :  TK_SWITCH '(' expr ')' */
#line 604 "gram.y"

         check_multiple_statements();
         ++depth;                
      
} break;

case YYr206: {	/* selection_statement :  TK_SWITCH '(' expr ')' $205 statement */
#line 609 "gram.y"
 --depth;                  
} break;

case YYr208: {	/* opt_else :  TK_ELSE */
#line 615 "gram.y"

         check_multiple_statements();
         is_else = TRUE;         
         ++depth;                
      
} break;

case YYr209: {	/* opt_else :  TK_ELSE $208 statement */
#line 621 "gram.y"
 --depth;                  
} break;

case YYr210: {	/* iteration_statement :  TK_WHILE '(' expr ')' */
#line 626 "gram.y"

         check_multiple_statements();
         ++depth;                
         ++fcn_decisions;        
      
} break;

case YYr211: {	/* iteration_statement :  TK_WHILE '(' expr ')' $210 statement */
#line 632 "gram.y"
 --depth;                  
} break;

case YYr212: {	/* iteration_statement :  TK_DO */
#line 634 "gram.y"

         ++depth;                
         ++fcn_decisions;        
      
} break;

case YYr213: {	/* iteration_statement :  TK_DO $212 statement */
#line 639 "gram.y"
 --depth;                  
} break;

case YYr214: {	/* iteration_statement :  TK_DO $212 statement $213 TK_WHILE '(' expr ')' ';' */
#line 641 "gram.y"
 check_multiple_statements(); 
} break;

case YYr215: {	/* iteration_statement :  TK_FOR '(' opt_expr ';' ';' opt_expr ')' */
#line 643 "gram.y"

         check_multiple_statements();
         ++depth;                
         
      
} break;

case YYr216: {	/* iteration_statement :  TK_FOR '(' opt_expr ';' ';' opt_expr ')' $215 statement */
#line 649 "gram.y"
 --depth;                  
} break;

case YYr217: {	/* iteration_statement :  TK_FOR '(' opt_expr ';' expr ';' opt_expr ')' */
#line 651 "gram.y"

         check_multiple_statements();
         ++depth;                
         ++fcn_decisions;        
      
} break;

case YYr218: {	/* iteration_statement :  TK_FOR '(' opt_expr ';' expr ';' opt_expr ')' $217 statement */
#line 657 "gram.y"
 --depth;                  
} break;

case YYr227: {	/* external_declaration :  function_definition */
#line 679 "gram.y"
 stat_func_end(); 
} break;

case YYr229: {	/* function_definition :  declarator */
#line 685 "gram.y"
 stat_func_begin(); 
} break;

case YYr231: {	/* function_definition :  declaration_specifiers declarator */
#line 688 "gram.y"
 stat_func_begin(); 
} break;

case YYr235: {	/* identifier :  TK_IDENTIFIER */
#line 699 "gram.y"

         
         strcpy(last_identifier, token());
      
} break;
#line 237 "c:\mks/etc/yyparse.c"
	case YYrACCEPT:
		YYACCEPT;
	case YYrERROR:
		goto yyError;
#ifdef YYLR2
	case YYrLR2:
#ifndef YYSYNC
		YYREAD;
#endif
		yyj = 0;
		while(yylr2[yyj] >= 0) {
			if(yylr2[yyj] == yystate && yylr2[yyj+1] == yychar
			&& yylook(yys+1,yyps,yystate,yychar,yy2lex(),yylr2[yyj+2]))
					break;
			yyj += 3;
		}
		if(yylr2[yyj] < 0)
			goto yyError;
		if(yylr2[yyj+2] < 0) {
			yystate = ~ yylr2[yyj+2];
			goto yyStack;
		}
		yyi = yylr2[yyj+2];
		goto yyReduce;
#endif
	}

	/*
	 *	Look up next state in goto table.
	 */

	yyp = &yygo[yypgo[yyi]];
	yyq = yyp++;
	yyi = *yyps;
#if	0 && defined(__TURBOC__) && __SMALL__
	/* THIS ONLY WORKS ON TURBO C 1.5 !!! */
	/* yyi is in di, yyp is in si */
L02:
	asm lodsw		/* ax = *yyp++; */
	asm cmp yyi, ax
	asm jl L02
#else
	while (yyi < *yyp++)
		;
#endif
	yystate = ~(yyi == *--yyp? YYQYYP: *yyq);
	goto yyStack;

yyerrlabel:	;		/* come here from YYERROR	*/
/*
#pragma used yyerrlabel
 */
	yyerrflag = 1;
	if (yyi == YYrERROR)
		yyps--, yypv--;
	
yyError:
	switch (yyerrflag) {

	case 0:		/* new error */
		yynerrs++;
		yyi = yychar;
		yyerror("Syntax error");
		if (yyi != yychar) {
			/* user has changed the current token */
			/* try again */
			yyerrflag++;	/* avoid loops */
			goto yyEncore;
		}

	case 1:		/* partially recovered */
	case 2:
		yyerrflag = 3;	/* need 3 valid shifts to recover */
			
		/*
		 *	Pop states, looking for a
		 *	shift on `error'.
		 */

		for ( ; yyps > yys; yyps--, yypv--) {
			if (*yyps >= sizeof yypact/sizeof yypact[0])
				continue;
			yyp = &yyact[yypact[*yyps]];
			yyq = yyp;
			do
				;
			while (YYERRCODE < *yyp++);
			if (YYERRCODE == yyp[-1]) {
				yystate = ~YYQYYP;
				goto yyStack;
			}
				
			/* no shift in this state */
#ifdef YYDEBUG
			if (yydebug && yyps > yys+1)
				printf(
	gettext("Error recovery pops state %d (%d), uncovers %d (%d)\n"),
					yysmap[yyps[0]], yyps[0],
					yysmap[yyps[-1]], yyps[-1]);
#endif
			/* pop stacks; try again */
		}
		/* no shift on error - abort */
		break;

	case 3:
		/*
		 *	Erroneous token after
		 *	an error - discard it.
		 */

		if (yychar == 0)  /* but not EOF */
			break;
#ifdef YYDEBUG
		if (yydebug)
			printf(gettext("Error recovery discards %s (%d), "),
				yyptok(yychar), yychar);
#endif
		yyclearin;
		goto yyEncore;	/* try again in same state */
	}
	YYABORT;

#ifdef YYALLOC
yyReturn:
	yylval = save_yylval;
	yyval = save_yyval;
	yypvt = save_yypvt;
	yychar = save_yychar;
	yyerrflag = save_yyerrflag;
	yynerrs = save_yynerrs;
	free((char *)yys);
	free((char *)yyv);
	return(retval);
#endif
}

#ifdef YYLR2
yylook(s,rsp,state,c1,c2,i)
short *s;		/* stack		*/
short *rsp;		/* real top of stack	*/
int state;		/* current state	*/
int c1;			/* current char		*/
int c2;			/* next char		*/
int i;			/* action S < 0, R >= 0	*/
{
	int j;
	short *p,*q;
	short *sb,*st;
#ifdef YYDEBUG
	if(yydebug) {
	printf(gettext("LR2 state %d (%d) char %s (%d) lookahead %s (%d)"),
			yysmap[state],state,yyptok(c1),c1,yyptok(c2),c2);
		if(i > 0)
			printf(gettext("reduce %d (%d)\n"), yyrmap[i], i);
		else
			printf(gettext("shift %d (%d)\n"), yysmap[i], i);
	}
#endif
	st = sb = rsp+1;
	if(i >= 0)
		goto reduce;
  shift:
	state = ~i;
	c1 = c2;
	if(c1 < 0)
		return 1;
	c2 = -1;

  stack:
  	if(++st >= &s[YYSSIZE]) {
		yyerror("Parser Stack Overflow");
		return 0;
	}
	*st = state;
	if(state >= sizeof yypact/sizeof yypact[0])
		i = state- YYDELTA;
	else {
		p = &yyact[yypact[state]];
		q = p;
		i = c1;
		while(i < *p++)
			;
		if(i == p[-1]) {
			state = ~q[q-p];
			c1 = c2;
			if(c1 < 0)
				return 1;
			c2 = -1;
			goto stack;
		}
		if(state >= sizeof yydef/sizeof yydef[0])
			return 0;
		if((i = yydef[state]) < 0) {
			p = &yyex[~i];
			while((i = *p) >= 0 && i != c1)
				p += 2;
			i = p[1];
		}
	}
  reduce:
  	j = yyrlen[i];
	if(st-sb >= j)
		st -= j;
	else {
		rsp -= j+st-sb;
		st = sb;
	}
	switch(i) {
	case YYrERROR:
		return 0;
	case YYrACCEPT:
		return 1;
	case YYrLR2:
		j = 0;
		while(yylr2[j] >= 0) {
			if(yylr2[j] == state && yylr2[j+1] == c1)
				if((i = yylr2[j+2]) < 0)
					goto shift;
				else
					goto reduce;
		}
		return 0;
	}
	p = &yygo[yypgo[i]];
	q = p++;
	i = st==sb ? *rsp : *st;
	while(i < *p++);
	state = ~(i == *--p? q[q-p]: *q);
	goto stack;
}
#endif
		
#ifdef YYDEBUG
	
/*
 *	Print a token legibly.
 *	This won't work if you roll your own token numbers,
 *	but I've found it useful.
 */
char *
yyptok(i)
{
	static char	buf[10];

	if (i >= YYERRCODE)
		return yystoken[i-YYERRCODE];
	if (i < 0)
		return "";
	if (i == 0)
		return "$end";
	if (i < ' ')
		sprintf(buf, "'^%c'", i+'@');
	else
		sprintf(buf, "'%c'", i);
	return buf;
}
#endif
#ifdef YYDEBUG
char * yystoken[] = {
	"error",
	"TK_IDENTIFIER",
	"TK_CONSTANT",
	"TK_STRING_LITERAL",
	"TK_SIZEOF",
	"TK_PTR_OP",
	"TK_INC_OP",
	"TK_DEC_OP",
	"TK_LEFT_OP",
	"TK_RIGHT_OP",
	"TK_LE_OP",
	"TK_GE_OP",
	"TK_EQ_OP",
	"TK_NE_OP",
	"TK_AND_OP",
	"TK_OR_OP",
	"TK_MUL_ASSIGN",
	"TK_DIV_ASSIGN",
	"TK_MOD_ASSIGN",
	"TK_ADD_ASSIGN",
	"TK_SUB_ASSIGN",
	"TK_LEFT_ASSIGN",
	"TK_RIGHT_ASSIGN",
	"TK_AND_ASSIGN",
	"TK_XOR_ASSIGN",
	"TK_OR_ASSIGN",
	"TK_TYPE_NAME",
	"TK_TYPEDEF",
	"TK_EXTERN",
	"TK_STATIC",
	"TK_AUTO",
	"TK_REGISTER",
	"TK_CHAR",
	"TK_SHORT",
	"TK_INT",
	"TK_LONG",
	"TK_SIGNED",
	"TK_UNSIGNED",
	"TK_FLOAT",
	"TK_DOUBLE",
	"TK_CONST",
	"TK_VOLATILE",
	"TK_VOID",
	"TK_STRUCT",
	"TK_UNION",
	"TK_ENUM",
	"TK_ELIPSIS",
	"TK_RANGE",
	"TK_CASE",
	"TK_DEFAULT",
	"TK_IF",
	"TK_ELSE",
	"TK_SWITCH",
	"TK_WHILE",
	"TK_DO",
	"TK_FOR",
	"TK_GOTO",
	"TK_CONTINUE",
	"TK_BREAK",
	"TK_RETURN",
	"THEN",
	0
};
char * yysvar[] = {	"$accept",
	"translation_unit",
	"primary_expr",
	"identifier",
	"string_list",
	"expr",
	"postfix_expr",
	"argument_expr_list",
	"assignment_expr",
	"unary_expr",
	"unary_operator",
	"cast_expr",
	"type_name",
	"multiplicative_expr",
	"additive_expr",
	"shift_expr",
	"relational_expr",
	"equality_expr",
	"and_expr",
	"exclusive_or_expr",
	"inclusive_or_expr",
	"logical_and_expr",
	"logical_or_expr",
	"conditional_expr",
	"assignment_operator",
	"constant_expr",
	"declaration",
	"declaration_specifiers",
	"init_declarator_list",
	"storage_class_specifier",
	"$80",
	"type_specifier",
	"$83",
	"init_declarator",
	"declarator",
	"initializer",
	"struct_or_union_specifier",
	"enum_specifier",
	"struct_or_union",
	"$108",
	"struct_declaration_list",
	"$110",
	"struct_declaration",
	"type_specifier_list",
	"struct_declarator_list",
	"struct_declarator",
	"enum",
	"enumerator_list",
	"$124",
	"enumerator",
	"declarator2",
	"pointer",
	"$138",
	"$140",
	"parameter_type_list",
	"$141",
	"$143",
	"parameter_identifier_list",
	"$144",
	"identifier_list",
	"parameter_list",
	"parameter_declaration",
	"abstract_declarator",
	"direct_abstract_declarator",
	"initializer_list",
	"statement",
	"labeled_statement",
	"compound_statement",
	"expression_statement",
	"selection_statement",
	"iteration_statement",
	"jump_statement",
	"$188",
	"$190",
	"statement_list",
	"declaration_list",
	"$202",
	"$203",
	"opt_else",
	"$205",
	"$208",
	"$210",
	"$212",
	"$213",
	"opt_expr",
	"$215",
	"$217",
	"external_declaration",
	"function_definition",
	"$229",
	"function_body",
	"$231",
	0
};
short yyrmap[] = {
	 236,  237,  238,   80,   83,  108,  112,  124,  126,  138, 
	 140,  143,  231,  235,  229,  227,  218,  217,  216,  215, 
	 214,  213,  212,  211,  210,  209,  208,  206,  205,  203, 
	 202,  190,  188,  187,  186,  185,  184,  183,  182,  144, 
	 141,  134,  127,  123,  114,  113,  110,   89,   84,   81, 
	  78,   77,   60,    1,    2,    4,    5,    6,    7,    8, 
	   9,   10,   11,   12,   13,   14,   15,   16,   18,   19, 
	  20,   21,   22,   23,   24,   25,   26,   27,   28,   29, 
	  30,   31,   32,   33,   34,   61,   62,   63,   64,   65, 
	  66,   67,   68,   69,   70,   71,   72,   73,   74,   75, 
	  76,   85,   86,   88,   90,   91,   92,   93,   94,   95, 
	  96,   97,   98,   99,  100,  101,  102,  103,  104,  105, 
	 106,  107,  109,  111,  115,  116,  117,  118,  119,  121, 
	 122,  125,  128,  129,  131,  135,  136,  137,  139,  142, 
	 145,  148,  149,  150,  151,  153,  154,  155,  157,  158, 
	 159,  160,  161,  163,  167,  168,  169,  170,  171,  172, 
	 173,  174,  175,  176,  177,  178,  179,  180,  181,  189, 
	 191,  192,  193,  194,  195,  196,  197,  198,  199,  200, 
	 201,  204,  221,  222,  223,  224,  225,  226,  228,  230, 
	 232,  233,  234,  220,  219,  207,  166,  165,  164,  162, 
	 156,  152,  147,  146,  133,  132,  130,  120,   87,   82, 
	  79,   59,   58,   57,   56,   55,   54,   53,   52,   51, 
	  50,   49,   48,   47,   46,   45,   44,   43,   42,   41, 
	  40,   39,   38,   37,   36,   35,   17,    3,    0
};
short yysmap[] = {
	   6,   10,   35,   36,   38,   42,   44,   45,   47,   50, 
	  53,   73,   74,   75,   76,   77,   78,   79,   80,   81, 
	  82,   95,   99,  103,  116,  141,  142,  143,  145,  149, 
	 150,  185,  203,  207,  237,  241,  244,  245,  246,  247, 
	 248,  249,  250,  251,  252,  253,  254,  255,  256,  257, 
	 258,  270,  277,  310,  346,  356,  364,  373,  371,  367, 
	 365,  363,  362,  357,  355,  351,  350,  349,  348,  347, 
	 336,  334,  332,  327,  326,  324,  321,  320,  314,  312, 
	 309,  307,  306,  305,  303,  293,  291,  290,  289,  287, 
	 284,  282,  279,  276,  273,  271,  269,  268,  266,  262, 
	 243,  242,  240,  236,  235,  234,  233,  232,  231,  219, 
	 217,  212,  211,  210,  209,  208,  206,  202,  198,  196, 
	 195,  193,  191,  190,  189,  187,  186,  184,  183,  182, 
	 181,  177,  174,  172,  171,  170,  169,  168,  167,  166, 
	 165,  164,  163,  162,  161,  160,  159,  158,  157,  156, 
	 155,  154,  138,  131,  130,  128,  127,  124,  123,  122, 
	 120,  119,  118,  117,  112,  111,  110,  107,  106,  105, 
	 102,   98,   94,   93,   92,   91,   70,   69,   68,   67, 
	  63,   62,   60,   55,   52,   51,   48,   46,   43,   39, 
	  37,   15,   12,    9,    7,    0,    1,    2,    4,  374, 
	 366,  370,  361,  372,  288,  121,  358,  328,  375,  368, 
	 359,  329,  360,  330,  216,  294,  297,  132,  133,  134, 
	 135,  136,  146,  151,    8,   11,  192,   13,   14,   49, 
	  34,  108,  109,  113,   56,  340,  101,  100,  272,   97, 
	 188,   96,  316,  267,  315,  264,  263,  180,  179,  265, 
	 341,  178,  176,  175,  173,  313,   90,   89,   88,   87, 
	  86,   85,   84,  317,   83,  261,  260,  259,  140,  296, 
	 230,  229,  228,  227,  226,  225,  224,  223,  222,  221, 
	 220,  139,  295,   72,   54,  201,  200,   33,   32,   31, 
	  30,   29,   28,   27,   26,   25,   24,   23,   22,   21, 
	  20,   19,   18,   17,   16,  323,  281,  194,  280,  322, 
	 278,  343,  319,  342,  318,  104,  275,  274,   66,   71, 
	 153,  152,  311,  300,   41,   65,   40,   64,  299,  144, 
	 298,  302,  148,  301,  239,  147,  238,  339,  304,  333, 
	 337,  354,  308,  338,  335,  353,  199,  325,  345,  283, 
	 344,  137,  352,  331,  129,  215,  213,  292,   61,  115, 
	 126,  214,  125,  218,  369,  286,  205,  204,  285,    5, 
	  57,    3,   59,  197,   58,  114
};
int yyntoken = 86;
int yynvar = 92;
int yynstate = 376;
int yynrule = 239;
#endif
