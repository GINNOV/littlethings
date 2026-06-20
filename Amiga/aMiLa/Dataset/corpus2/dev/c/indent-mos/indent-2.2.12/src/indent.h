/** \file
 * Copyright (c) 2015 Tim Hentenaar. All rights reserved.<br>
 * Copyright (c) 2013 Łukasz Stelmach.  All rights reserved.<br>
 * Copyright (c) 1999 Carlo Wood.  All rights reserved.<br>
 * Copyright (c) 1994 Joseph Arceneaux.  All rights reserved.<br>
 * Copyright (c) 1992, 2002, 2008, 2014, 2015 Free Software Foundation, Inc.  All rights reserved.<br>
 *
 * Copyright (c) 1985 Sun Microsystems, Inc. <br>
 * Copyright (c) 1980 The Regents of the University of California. <br>
 * Copyright (c) 1976 Board of Trustees of the University of Illinois. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * - 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * - 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.<br>
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * History:
 * - 2002-11-10 Cristalle Azundris Sabon <cristalle@azundris.com>
 *            Added --preprocessor-indentation (ppi)   if set, will indent nested
 *            preprocessor-statements with n spaces per level.  overrides -lps.
 * -2007-11-11 Jean-Christophe Dubois <jcd@tribudubois.net>
 *            Added --indent-label and --linux-style options.
 * 
 */

#ifndef INDENT_INDENT_H
#define INDENT_INDENT_H

#include "sys.h"
RCSTAG_H (indent, "$Id$");
#include <config.h>

#include <libgettext.h>
#ifdef ENABLE_NLS
#define _(X) gettext(X)
#else
#define _(X) X
#endif

#include "lexi.h"

/** Values that `indent' can return for exit status.
 *
 *  `total_success' means no errors or warnings were found during a successful
 *    invocation of the program.
 *
 *  `invocation_error' is returned if an invocation problem (like an incorrect
 *    option) prevents any formatting to occur.
 *
 *  `indent_error' is returned if errors occur during formatting which
 *    do not prevent completion of the formatting, but which appear to be
 *    manifested by incorrect code (i.e, code which wouldn't compile).
 *
 *  `indent_punt' is returned if formatting of a file is halted because of
 *    an error with the file which prevents completion of formatting.  If more
 *    than one input file was specified, indent continues to the next file.
 *
 *  `indent_fatal' is returned if a serious internal problem occurs and
 *    the entire indent process is terminated, even if all specified files
 *    have not been processed. */

typedef enum exit_values
{
  total_success = 0,
  invocation_error = 1,
  indent_error = 2,
  indent_punt = 3,
  indent_fatal = 4,
  system_error = 5
} exit_values_ty;

typedef unsigned char BOOLEAN;

#define false 0
#define true  1

typedef struct file_buffer
{
  char *name;
  size_t size;
  char *data;
} file_buffer_ty;

typedef enum bb_code
{
  bb_none,
  bb_comma,
  bb_embedded_comment_start,
  bb_embedded_comment_end,
  bb_proc_call,
  bb_dec_ind,
  bb_unary_op,
  bb_binary_op,
  bb_before_boolean_binary_op,
  bb_after_boolean_binary_op,
  bb_after_equal_sign,
  bb_comparisation,
  bb_question,
  bb_colon,
  bb_label,
  bb_semicolon,
  bb_lbrace,
  bb_rbrace,
  bb_overloaded,
  bb_const_qualifier,
  bb_ident,
  bb_attribute,
  bb_struct_delim,
  bb_operator2,                 /* member selection (bb_struct_delim `.' or `->') */
  bb_operator4,                 /* member selection (bb_struct_delim `.*' or `->*') */
  bb_operator5,                 /* multiply, divide or modulo */
  bb_operator6,                 /* add or subtract */
  bb_doublecolon,
  bb_cast
} bb_code_ty;

#define DEFAULT_RIGHT_MARGIN 78

#define DEFAULT_RIGHT_COMMENT_MARGIN 78

#define DEFAULT_LABEL_INDENT -2

/* Name of input file.  */
extern char *in_name;

extern char *in_prog;           /*!< pointer to the null-terminated input
                                   program */

/** Point to the position in the input program which we are currently looking
 *  at.  */

extern char *in_prog_pos;

/** Point to the start of the current line.  */
extern char *cur_line;

/** Size of the input program, not including the NEWLINE EOS we add at the end */
extern unsigned long in_prog_size;

extern char *labbuf;            /*!< buffer for label */
extern char *s_lab;             /*!< start of stored label */
extern char *e_lab;             /*!< end of stored label */
extern char *l_lab;             /*!< limit of label buffer */

extern char *codebuf;           /*!< buffer for code section */
extern char *s_code;            /*!<  start  of stored code */
extern char *s_code_corresponds_to; /*!<  If set, start of corresponding
                                     *  code in token buffer... */
extern char *e_code;            /*!<  end of stored code */
extern char *l_code;            /*!<  limit of code section */

extern char *combuf;            /*!<  buffer for comments */
extern char *s_com;             /*!<  start of stored comments */
extern char *e_com;             /*!<  end of stored comments */
extern char *l_com;             /*!<  limit of comment buffer */

extern char *buf_ptr;           /*!<  ptr to next character to be taken from
                                 * in_buffer */
extern char *buf_end;           /*!<  ptr to first after last char in in_buffer */

/** pointer to the token that lexi() has just found */
extern char *token;

/** points to the first char after the end of token */
extern char *token_end;

extern int squest;
extern file_buffer_ty *current_input;

/** Used to keep track of buffers.  */
typedef struct buf
{
  char *ptr;                    /*!<  points to the start of the buffer */
  char *end;                    /*!<  points to the character beyond the last
                                 *    one (e.g. is equal to ptr if the buffer is
                                 *    (empty).  */
  int size;                     /*!<  how many chars are currently allocated.  */
  int len;                      /*!<  how many chars we're actually using. */
  int start_column;             /*!<  corresponding column of first character
                                 *    in the buffer. */
  int column;                   /*!<  Column we were in when we switched buffers. */
} buf_ty;

/** Buffer in which to save a comment which occurs between an if(), while(),
 * etc., and the statement following it.  Note: the fact that we point into
 * this buffer, and that we might realloc() it (via the need_chars macro) is
 * a bad thing (since when the buffer is realloc'd its address might change,
 * making any pointers into it point to garbage), but since the filling of
 * the buffer (hence the need_chars) and the using of the buffer (where
 * buf_ptr points into it) occur at different times, we can get away with it
 * (it would not be trivial to fix).  */

extern buf_ty save_com;

extern char *bp_save;           /*!<  saved value of buf_ptr when taking input
                                   from save_com */
extern char *be_save;           /*!<  similarly saved value of buf_end */


extern int pointer_as_binop;
extern int n_real_blanklines;
extern int prefix_blankline_requested;
extern codes_ty prefix_blankline_requested_code;      /*!<  The code that caused
                                                           the blank line to be
                                                           requested */
extern int postfix_blankline_requested;
extern codes_ty postfix_blankline_requested_code;     /*!<  The code that caused
                                                         * the blank line to be
                                                         * requested */
extern int break_comma;         /*!<  when true and not in parens, break after a
                                 * comma */

/**
 * This structure stores all the user options that come from (e.g.)
 * command line flags.
 */
typedef struct user_options_st
{
    int verbose;     /*!<  when true, non-essential error messages are printed */
    int use_tabs;    /*!<  does indent convert tabs to spaces or not */
    int tabsize;     /*!<  The number of columns a tab character generates. */
    int use_stdout;  /*!<  Where does output go. */
    int space_sp_semicolon; /*!<  If true, a space is inserted between if, while, or for, and a semicolon
                             * for example while (*p++ == ' ') ; */
    int swallow_optional_blanklines;
    int star_comment_cont;   /*!<  true if comment continuation lines should have stars at the beginning of each line. */
    int struct_brace_indent; /*!<  Indentation level to be used for a '{' directly following a struct, union or enum */
    int space_after_while;   /*!<  Put a space after `while' */
    int space_after_if;      /*!<  Put a space after `if' */
    int space_after_for;     /*!<  Put a space after `for' */
    int procnames_start_line; /*!<  if true, the names of procedures being  defined get placed in column 1 (ie. a
                               * newline is placed between the type of the procedure and its name) */
    int parentheses_space;   /*!<  If true, parentheses will look like: ( foo ) rather than (foo) */
    int preserve_mtime;      /*!<  True when the modification time of the files should  be preserved. */
    int paren_indent;        /*!<  set to the indentation per open parens */
    int proc_calls_space;    /*!<  If true, procedure calls look like: foo (bar) rather than foo(bar) */
    int leave_preproc_space; /*!<  if true, leave the spaces between  '#' and preprocessor commands. */
    int force_preproc_width; /*!<  if this is >0, this becomes the preproc indent-level */
    int lineup_to_parens;    /*!<  if true, continued code within parens will be lined up to the open paren */
    int honour_newlines;     /*!<  True when positions at which we read a newline in the input file, should get
                              * a high priority to break long lines at. */
    int fix_nested_comments; /*!<  If nested comments are to be fixed */
    int format_comments; /*!<  If any comments are to be reformatted */
    int format_col1_comments; /*!<  If comments which start in column 1 are to be magically reformatted */
    int extra_expression_indent;     /*!<  True if continuation lines from the expression part of "if(e)",
                                      * "while(e)", "for(e;e;e)" should be indented an extra tab stop so that
                                      * they don't conflict with the code that follows */
    int ljust_decl;          /*!<  true if declarations should be left justified */
    int cast_space;          /*!<  If true, casts look like: (char *) bar rather than (char *)bar */
    int cuddle_else;         /*!<  true if else should cuddle up to '}' */
    int cuddle_do_while;     /*!<  true if '}' should cuddle up to while in do loop */
    int comment_delimiter_on_blankline;
    int blank_after_sizeof; /*!<  true iff a blank should always be inserted after sizeof */
    int break_function_decl_args;    /*!<  true if declarations should have args on new lines */
    int break_function_decl_args_end; /*!<  true if declarations should have
                                       * ")" after args on new lines */
    int leave_comma;         /*!<  if true, never break declarations after commas */
    int break_before_boolean_operator;       /*!<  True when we prefer to break a long line
                                              * before a '&&' or '||', instead of behind it.
                                              */
    int blanklines_before_blockcomments;
    int blanklines_after_declarations;
    int blanklines_after_procs;
    int blanklines_after_declarations_at_proctop;    /*!<  This is vaguely  similar to blanklines_after_declarations except that
                                                      * it only applies to the first set of declarations in a procedure (just after
                                                      * the first '{') and it causes a blank line to be generated even
                                                      * if there are no declarations
                                                      */
    int blanklines_around_conditional_compilation;
    int comment_max_col;
    int max_col;             /*!<  the maximum allowable line length */
    int label_offset;        /* offset of labels */
    int ind_size;            /* !< The size of one indentation level in spaces.  */
    int indent_parameters;   /*!<  Number of spaces to indent parameters.  */
    int decl_indent;         /*!< column to indent declared identifiers to */
    int unindent_displace;   /*!< comments not to the right of code will be
                              * placed this many indentation levels to the
                              * left of code */
    int else_endif_col; /*!< The column in which comments to the right of # else and # endif should start. */
    int case_indent;         /*!< The distance to indent case labels from the switch statement */
    int continuation_indent; /*!< set to the indentation between the edge of code and continuation lines in spaces */
    int decl_com_ind;        /*!< the column in which comments after declarations should be put */
    int case_brace_indent;   /*!< Indentation level to be used for a '{'
                              * directly following a case label. */
    int c_plus_plus; /*!< True if we're handling C++ code. */
    int com_ind;             /*!< the column in which comments to the right of code should start */
    int braces_on_struct_decl_line; /*!< when true, brace should be on same line as the struct declaration */
    int braces_on_func_def_line; /*!< when true, brace should be on same line as the function definition */
    int btype_2; /* when true, brace should be on same line as if, while, etc */
    int brace_indent; /*!< number of spaces to indent braces from the suround if, while, etc. in -bl
                       * (bype_2 == 0) code */
    int expect_output_file;  /*!< Means "-o" was specified. */
    int pointer_align_right; /*!< true: "char *a", false: "char* a" */
    int gettext_strings;     /*!< true: _("...") is a string, false: it's a function */ 
    int allow_single_line_conditionals; /*!< Don't indent the body of an unbraced if, else, etc. */
    int align_with_spaces; /*!< Align with spaces if indenting with tabs. */
    int spaces_around_initializers; /*!< Place spaces after { and before } in initializers. */
    int dont_tab_align_comments; /*!< Don't align comments to the nearest tabstop. */
} user_options_ty;

extern user_options_ty settings;

/** True if there is an embedded comment on this code line */
extern int embedded_comment_on_line;

extern int di_stack_alloc;
extern int *di_stack;

extern int else_or_endif; /*!< True if a # else or # endif has been encountered.  */

extern int     code_lines;          /*!< count of lines with code */

extern int     out_lines;           /*!< the number of lines written, set by
                                 * dump_line */
extern int     com_lines;           /*!< the number of lines with comments, set by
                                 * dump_line */


extern BOOLEAN had_eof;             /*!< set to true when input is exhausted */
extern int     line_no;             /*!< the current input line number. */

extern int     paren_target;


extern int use_stdinout; /*!< Nonzero if we should use standard input/output when files are not
                          * explicitly specified.  */

/**
 * This structure contains information relating to the state of parsing the
 * code.  The difference is that the state is saved on # if and restored on
 * # else.  */

typedef struct parser_state
{
    struct parser_state * next;
    codes_ty              last_token;

  /** This is the parsers stack, and the current allocated size.  */
    codes_ty            * p_stack;
    int                   p_stack_size;

  /** This stack stores indentation levels 
     * Currently allocated size is stored in p_stack_size.  */

    int                 * il;

  /** If the last token was an ident and is a reserved word,
     * remember the type. */

    rwcodes_ty            last_rw;

  /** also, remember its depth in parentheses */

    int                   last_rw_depth;

  /** Used to store case stmt indentation levels.
   * Currently allocated size is stored in p_stack_size.  */
    int                  *cstk;

  /** Pointer to the top of stack of the p_stack, il and cstk arrays. */
    int                   tos;

    int                   box_com; /*!<  set to true when we are in a
                                    * "boxed" comment. In that case, the
                                    * first non-blank char should be
                                    * lined up with the / in the comment
                                    * closing delimiter */

    int                   cast_mask; /*!<  indicates which close parens close off
                                      * casts */
  /** A bit for each paren level, set if the open paren was in a context which
       indicates that this pair of parentheses is not a cast.  */
    int                   noncast_mask;

    int                   sizeof_mask; /*!<  indicates which close parens close off
                                        * sizeof''s */
    int                   block_init;  /*!<  set to 1 if inside a block initialization
                                        * set to 2 if inside an enum declaration
                                        * and 3 for C99 compound literals. */
    int block_init_level;         /*!<  The level of brace nesting in an
                                   * initialization (0 in an enum decl) */
    int last_nl;                  /*!<  this is true if the last thing scanned was
                                   * a newline */
    int last_saw_nl;              /*!<  this is true if the last non white space
                                   * scanned was a newline */
    int saw_double_colon;         /*!<  set when we see a ::, reset at first semi-
                                   * colon or left brace */
    int is_func_ptr_decl;         /*!<  set when we see a decl, followed by lparen
                                   * and '*'. */
    int broken_at_non_nl;         /*!<  true when a line was broken at a place
                                   * where there was no newline in the input file */
    int in_or_st;                 /*!<  Will be true iff there has been a
                                   * declarator (e.g. int or char) and no left
                                   * paren since the last semicolon. When true,
                                   * a '{' is starting a structure definition
                                   * or an initialization list */
    int col_1;                    /*!<  set to true if the last token started in
                                   * column 1 */
    int com_col;                  /*!<  this is the column in which the current
                                   * coment should start */
    int dec_nest;                 /*!<  current nesting level for structure or
                                   * init */
    int decl_on_line;             /*!<  set to true if this line of code has part
                                   * of a declaration on it */
    int i_l_follow;               /*!<  the level in spaces to which ind_level
                                   * should be set after the current line is
                                   * printed */
    BOOLEAN in_decl;              /*!<  set to true when we are in a declaration
                                   * statement.  The processing of braces is then
                                   * slightly different */
    int in_stmt;                  /*!<  set to 1 while in a stmt */
    int in_parameter_declaration;
    int ind_level;                /*!<  the current indentation level in spaces */
    int ind_stmt;                 /*!<  set to 1 if next line should have an extra
                                   * indentation level because we are in the
                                   * middle of a stmt */
    int last_u_d;                 /*!<  set to true after scanning a token which
                                   * forces a following operator to be unary */
    int p_l_follow;               /*!<  used to remember how to indent following
                                   * statement */
    int paren_level;              /*!<  parenthesization level. used to indent
                                   * within stmts */
    int paren_depth;              /*!<  Depth of paren nesting anywhere. */
    
  /** Column positions of paren at each level.  If positive, it contains just
     * the number of characters of code on the line up to and including the
     * right parenthesis character.  If negative, it contains the opposite of
     * the actual level of indentation in characters (that is, the indentation
     * of the line has been added to the number of characters and the sign has
     * been reversed to indicate that this has been done).  */
    short *paren_indents;         /*!<  column positions of each paren */
    int paren_indents_size;       /*!<  Currently allocated size.  */

    int pcase;                    /*!<  set to 1 if the current line label is a
                                   * case.  It is printed differently from a
                                   * regular label */
    int search_brace;             /*!<  set to true by parse when it is necessary
                                   * to buffer up all info up to the start of a
                                   * stmt after an if, while, etc */
    int use_ff;                   /*!<  set to one if the current line should be
                                   * terminated with a form feed */
    int want_blank;               /*!<  set to true when the following token
                                   * should be prefixed by a blank. (Said
                                   * prefixing is ignored in some cases.) */
    bb_code_ty can_break;         /*!<  set when a break is ok before the following
                                   * token (is automatically implied by
                                   * `want_blank'. */
    int its_a_keyword;
    int sizeof_keyword;
    char *procname;               /*!<  The name of the current procedure */
    char *procname_end;           /*!<  One char past the last one in procname */
    char *classname;              /*!<  The name of the current C++ class */
    char *classname_end;          /*!<  One char past the last one in classname */
    int just_saw_decl;
    int matching_brace_on_same_line;      /*!<  Set to a value >= 0 if the the
                                             current '}' has a matching '{'
                                             on the same input line */
} parser_state_ty;

/** All manipulations of the parser state occur at the top of stack (tos). A
 * stack is kept for conditional compilation (unrelated to the p_stack, il, &
 * cstk stacks)--it is implemented as a linked list via the next field. */

extern parser_state_ty *parser_state_tos;

#endif /* INDENT_INDENT_H */
