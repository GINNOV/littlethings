/*************************************************************
   Copyright (c) 1993,1994 by Paul Long  All rights reserved.
**************************************************************/

/*************************************************************
   metre.h -   This header file contains #defines,
               typedefs, and externs that are used
               by the rules code to interface with
               the parser.
**************************************************************/


#ifndef _METRE_H_
#define _METRE_H_

#include <stdio.h>


/* Define TRUE and FALSE if environment doesn't. */
#ifndef TRUE
#define TRUE (0==0)
#define FALSE (!TRUE)
#endif
typedef int BOOLEAN;

/*
   Project information.  A project consists of one or more modules
   (source files).
*/
typedef struct {
   BOOLEAN begin;          /* Set to whether beginning of the project. */
   BOOLEAN end;            /* Set to whether end of the project. */
} PRJ;

/*
   Module information.  In Metre, a module is currently the same thing as
   a source file.
*/
typedef struct {
   BOOLEAN begin;          /* Set to whether beginning of a source module
                              has been encountered. */
   BOOLEAN end;            /* Set to whether end of a source module (a file
                              and all of its included files) has been
                              reached. */
   struct {
      unsigned total;      /* Set to the total number of lines in a module. */
      unsigned com;        /* Set to the number of comment lines in a module. */
      unsigned white;      /* Set to the number of whitespace lines in a
                              module. */
      unsigned exec;       /* Set to the number of executable lines in a
                              module. */
   } lines;
   unsigned decisions;     /* Set to the number of binary decision points in a
                              module. */
   unsigned functions;     /* Set to the number of functions defined in a
                              module. */
} MOD;

/* Function information. */
typedef struct {
   BOOLEAN begin;          /* Set to whether beginning of a function has
                              been found. */
   BOOLEAN end;            /* Set to whether end of a function has been
                              found. */
   struct {
      unsigned total;      /* Set to the total number of lines in a function. */

      unsigned com;        /* Set to the number of comment lines in a
                              function. */
      unsigned white;      /* Set to the number of whitespace lines in a
                              function. */
      unsigned exec;       /* Set to the number of executable lines in a
                              function. */
   } lines;
   unsigned high;          /* Set to the number of high-level statements found
                              in the definition of a C function. */
   unsigned low;           /* Set to the number of low-level statements found
                              in the definition of a C function. */
   unsigned decisions;     /* Set to the number of binary decision points in a
                              function. */
} FCN;

/* Statement information. */
typedef struct {
   BOOLEAN end;            /* Set to whether end of a statement has been
                              found. */
   unsigned depth;         /* Set to the logical depth of a statement, i.e.,
                              its nesting level within if-, for-, while-, and
                              do-statements. */
   BOOLEAN is_comp;        /* Set to whether is a compound statement. */
   BOOLEAN is_expr;        /* Set to whether is an expression statement. */
   BOOLEAN is_high;        /* Set to whether is a compound, selection, or
                              iteration statement. */
   BOOLEAN is_iter;        /* Set to whether is an iteration statement. */
   BOOLEAN is_jump;        /* Set to whether is a jump statement. */
   BOOLEAN is_label;       /* Set to whether is a labeled statement. */
   BOOLEAN is_low;         /* Set to whether is an expression or jump
                              statement. */

   BOOLEAN is_select;      /* Set to whether is a selection statement. */
} STM;

/* Line information. */
typedef struct {
   unsigned number;        /* Set to the number of the current line, relative
                              to the start of the current file. */
   BOOLEAN end;            /* Set to whether a newline character has been
                              found. */
   BOOLEAN is_comment;     /* Set to whether line has no C code and either
                              contains a comment or is contained within a
                              comment.  The comment must contain text to qualify
                              as a real comment. */
   BOOLEAN is_white;       /* Set to whether line consists entirely of whitespace
                              tabs & spaces), or is a comment line without any
                              text. */
   BOOLEAN is_exec;        /* Set to whether line contains code that is
                              executable. */
   unsigned statements;    /* Set to the number of statements on the current
                                 line. */
   BOOLEAN is_mixed_indent;   /* Set to whether line is indented with both space
                                 and tab characters. */
} LIN;

/* Lexical information. */
typedef struct {
   int nonstandard;        /* Whenever a character is found that is not in the
                              standard C set, the value of this variable is set
                              to the integer representation of the nonstandard
                              character. */
} LEX;

/*
   Extern declarations for the structs through which the parser provides
   information to the rules.
*/
extern PRJ prj;
extern MOD mod;
extern FCN fcn;
extern STM stm;
extern LIN lin;
extern LEX lex;

/* FILE pointer to where any output should be directed by the rules. */
extern FILE *out_fp;

/* Returns pointer to current function name. */
extern char *fcn_name(void);

/* Returns pointer to current module (file) name. */
extern char *mod_name(void);

/* Returns pointer to current source line. */
extern char *line(void);

/*
   Returns pointer to string that "points" to the parser's current location in
   source.  E.g.,
                                   -
   Useful in error messages.  The parser uses this function for syntax errors,
   but it could also be used by a rule.
*/
extern char *marker(void);

/* Returns pointer to current token (lexeme, actually) in the source. */
extern char *token(void);

/*
   Returns TRUE when the indicated keyword or identifier, e.g., "while"
   or "myBuffer", respectively, is encountered.  Can be used as a
   trigger in a rule.
*/
extern BOOLEAN keyword(char *);
extern BOOLEAN identifier(char *);

/*
   Returns pointer to the part of an option following the "=".  E.g.,
   for -Xabc=def, it would point to the "def" part.
*/
extern char *str_option(char);

/*
   Returns TRUE if the indicated option character was specified on the
   command line.  E.g., for -S, would return TRUE for option('S').
*/
extern int option(char);

/*
   Used by rules to indicate a fatal error or warning.  Expects a
   fatal-error or warning number that the programmer can make up,
   followed by a format string and other arguments, just like printf().  E.g.,
   warn(0, "goto statement used (%u time%s)", fcn_gotos, NUMBER(fcn_gotos));
*/
extern void fatal(int, char *, ...);
extern void warn(int, char *, ...);

#endif
