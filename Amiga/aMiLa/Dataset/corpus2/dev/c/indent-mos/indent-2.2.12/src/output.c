/** \file
 * Copyright (c) 2015 Tim Hentenaar. All Rights Reserved.<br>
 * Copyright (c) 2002 D.Ingamells
 * Copyright (c) 1999, 2000 Carlo Wood.  All rights reserved. <br>
 * Copyright (c) 1994, 1996, 1997 Joseph Arceneaux.  All rights reserved. <br>
 * Copyright (c) 1992, 2002, 2008, 2015 Free Software Foundation, Inc.  All rights reserved. <br>
 *
 * Copyright (c) 1980 The Regents of the University of California. <br>
 * Copyright (c) 1976 Board of Trustees of the University of Illinois. All rights reserved.
 * Copyright (c) 1985 Sun Microsystems, Inc.  
 *   All rights reserved.<br>
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
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * File:    output.c
 * Purpose: Interface to the output file for the indent tool.
 *
 * History:
 * - 2002-03-04 D.Ingamells Creation.
 * - 2002-11-10 Cristalle Azundris Sabon <cristalle@azundris.com>
 *            Added --preprocessor-indentation (ppi)   if set, will indent nested
 *            preprocessor-statements with n spaces per level.  overrides -lps.
 * -2007-11-11 Jean-Christophe Dubois <jcd@tribudubois.net>
 *            Added --indent-label and --linux-style options.
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <utime.h>
#include <time.h>
#include <sys/stat.h>

#include "indent.h"
#include "sys.h"
#include "globs.h"
#include "code_io.h"
#include "output.h"

RCSTAG_CC ("$Id$");

static FILE            * output       = NULL;
static BOOLEAN           inhibited    = 0;
static buf_break_st_ty * buf_break_list = NULL;
buf_break_st_ty * buf_break = NULL;

int             out_lines      = 0;     /*!< used in output.c indent.c */
int             com_lines      = 0;     /*!< used in output.c indent.c comments.c */

int           prev_target_col_break = 0;
int           buf_break_used        = 0;
int           preproc_indent        = 0;

/**
 * Returns `true' when `b1' is a better place to break the code than `b2'.
 * `b1' must be newer.
 *
 * When `lineup_to_parens' is true, do not break more then 1 level deeper
 * unless that doesn't cost us "too much" indentation.
 * What is "too much" is determined in a fuzzy way as follows:
 * Consider the example,
 *   while (!(!(!(!(!(!(mask
 *                      || (((a_very_long_expression_that_cant_be_broken
 * here we prefer to break after `mask' instead of after `while'.
 * This is because the `target_col' is pretty close to the break point
 * of the `while': "mask"->target_col - "while"->col == 15 == "mask"->level * 2 + 1.
 */

static BOOLEAN better_break (
    buf_break_st_ty *b1,
    const buf_break_st_ty *b2)
{
    static int first_level;
    BOOLEAN is_better;

    if (!b2)
    {
        first_level = b1->level;
        b1->first_level = first_level;
        is_better = true;
    }
    else
    {
        if (b2->target_col >= b2->col + 1)
        {
            is_better = true;
        }
        else if (settings.honour_newlines && b2->priority_newline)
        {
            is_better = false;
        }
        else if (settings.honour_newlines && b1->priority_newline)
        {
            is_better = true;
        }
        else
        {
            int only_parens_till_b2 = 0;

            is_better = (b1->priority > b2->priority);

            if (is_better)
            {
                char *p;

                for (p = &s_code[b2->offset]; p >= s_code; --p)
                {
                    if (*p == '!')
                    {
                        --p;
                    }

                    if (*p != '(')
                    {
                        break;
                    }
                }

                if (p < s_code)
                {
                    only_parens_till_b2 = 1;
                }
            }

            if (settings.lineup_to_parens && (b1->level > (first_level + 1)) &&
                !(only_parens_till_b2 &&
                  (b1->target_col <= (b2->col + (1 + 2 * b1->level)))) &&
                (b1->level > b2->level))
            {
                is_better = false;
            }
        }

        if (is_better)
        {
            b1->first_level = first_level;
        }
    }

    return is_better;
}

/**
 * Calculate break priority.
 *
 * Example:
 *                              e_code          (`s_code' buffer, at the moment
 *                                               set_buf_break() is called)
 *                              ptr             (`s_code' buffer)
 *                              corresponds_to  (input buffer)
 * Left most column             col+1           (the column (31 here)).
 * |                             |
 * 1234567890123456789012345678901234567890
 *         if (!(mask[0] == '\\0'
 *               |
 *             target_col (assuming `lineup_to_parens' is true in this example)
 *            1 2    3 2         | level == 2
 *         <--------------------->
 *          priority_code_length
 */

static void set_priority (
              buf_break_st_ty *bb)
{
    bb->priority = bb->priority_code_length;

    switch (bb->priority_code)
    {
        case bb_semicolon:
            bb->priority += 6000;
            break;
        case bb_before_boolean_binary_op:
            bb->priority += 5000;
            break;
        case bb_after_boolean_binary_op:
            if (bb->priority_code_length > 2)
            {
                bb->priority += 5000;
            }

            if (settings.break_before_boolean_operator)
            {
                bb->priority -= 3;
            }
            break;
        case bb_after_equal_sign:
            bb->priority += 4000;
            break;
        case bb_attribute:
            bb->priority += 3000;
            break;
        case bb_comma:
            bb->priority += 2000;
            break;
        case bb_comparisation:
            bb->priority += 1000;
            break;
        case bb_proc_call:
            bb->priority -= 1000;
            break;
        case bb_operator6:
            bb->priority += 600;
            break;
        case bb_operator5:
            bb->priority += 500;
            break;
        case bb_operator4:
            bb->priority += 400;
            break;
        case bb_operator2:
            bb->priority += 200;
            break;
        case bb_doublecolon:
            bb->priority += 100;
            break;
        default:
            break;
    }
}

/**
 * This function is called at every position where we possibly want
 * to break a line (if it gets too long).
 */

void set_buf_break (
    bb_code_ty    code,
    int           paren_targ)
{
    int target_col, level;
    int code_target = compute_code_target (paren_targ);
    buf_break_st_ty *bb;

    /* First, calculate the column that code following e_code would be
     * printed in if we'd break the line here.
     * This is done quite simular to compute_code_target(). */

    /* Base indentation level (number of open left-braces) */

    target_col = parser_state_tos->i_l_follow + 1;

    /* Did we just parse a brace that will be put on the next line
     * by this line break? */

    if (*token == '{')
    {
        target_col -= settings.ind_size; /* Use `ind_size' because this only happens
                                          * for the first brace of initializer blocks. */
    }

    /* Number of open brackets */

    level = parser_state_tos->p_l_follow;

    /* Did we just parse a bracket that will be put on the next line
     * by this line break? */

    if ((*token == '(') || (*token == '['))
    {
        --level;                        /* then don't take it into account */
    }

    /* Procedure name of function declaration? */

    if (parser_state_tos->procname[0] &&
        (token == parser_state_tos->procname))
    {
        target_col = 1;
    }
    else if (level == 0)                /* No open brackets? */
    {
        if (parser_state_tos->in_stmt)  /* Breaking a statement? */
        {
            target_col += settings.continuation_indent;
        }
    }
    else if (!settings.lineup_to_parens)
    {
        target_col += settings.continuation_indent +
                      (settings.paren_indent * (level - 1));
    }
    else
    {
        if (parser_state_tos->paren_indents[level - 1] < 0)
        {
            target_col = -parser_state_tos->paren_indents[level - 1];
        }
        else
        {
            target_col = code_target + parser_state_tos->paren_indents[level - 1];
        }
    }

    /* Store the position of `e_code' as the place to break this line. */

    bb = xmalloc(sizeof(buf_break_st_ty));
    bb->offset = e_code - s_code;
    bb->level = level;
    bb->target_col = target_col;
    bb->corresponds_to = token;
    *e_code = 0;
    bb->col = count_columns (code_target, s_code, NULL_CHAR) - 1;

    /* Calculate default priority. */

    bb->priority_code_length = (e_code - s_code);
    bb->priority_newline = (parser_state_tos->last_saw_nl &&
                            !parser_state_tos->broken_at_non_nl);

    if (buf_break)
    {
        bb->first_level = buf_break->first_level;
    }

    switch (parser_state_tos->last_token)
    {
        case binary_op:
            if ( ((e_code - s_code) >= 3) &&
                 (e_code[-3] == ' ') &&
                 (((e_code[-1] == '&') && (e_code[-2] == '&')) ||
                  ((e_code[-1] == '|') && (e_code[-2] == '|'))))
            {
                bb->priority_code = bb_after_boolean_binary_op;
            }
            else if ( (e_code - s_code >= 2) && (e_code[-1] == '=') &&
                      ( (e_code[-2] == ' ') ||
                        ( (e_code - s_code >= 3) &&
                          (e_code[-3] == ' ') &&
                          ( (e_code[-2] == '%') ||
                            (e_code[-2] == '^') ||
                            (e_code[-2] == '&') ||
                            (e_code[-2] == '*') ||
                            (e_code[-2] == '-') ||
                            (e_code[-2] == '+') ||
                            (e_code[-2] == '|')))))
            {
                bb->priority_code = bb_after_equal_sign;
            }
            else if ( ( ( (e_code - s_code) >= 2) &&
                        (e_code[-2] == ' ') &&
                        ( (e_code[-1] == '<') ||
                          (e_code[-1] == '>'))) ||
                      ( ( (e_code - s_code) >= 3) &&
                        (e_code[-3] == ' ') &&
                        (e_code[-1] == '=')  &&
                        ( (e_code[-2] == '=') ||
                          (e_code[-2] == '!') ||
                          (e_code[-2] == '<') ||
                          (e_code[-2] == '>'))))
            {
                bb->priority_code = bb_comparisation;
            }
            else if ( (e_code[-1] == '+') ||
                      (e_code[-1] == '-'))
            {
                bb->priority_code = bb_operator6;
            }
            else if ( (e_code[-1] == '*') || (e_code[-1] == '/') || (e_code[-1] == '%'))
            {
                bb->priority_code = bb_operator5;
            }
            else
            {
                bb->priority_code = bb_binary_op;
            }

            break;
        case comma:
            bb->priority_code = bb_comma;
            break;
        default:
            if ( (code == bb_binary_op) &&
                 ( (*token == '&') ||
                   (*token == '|')) &&
                 (*token == token[1]))
            {
                bb->priority_code = bb_before_boolean_binary_op;
            }
            else if (e_code[-1] == ';')
            {
                bb->priority_code = bb_semicolon;
            }
            else
            {
                bb->priority_code = code;
                if (code == bb_struct_delim)    /* . -> .* or ->* */
                {
                    if (e_code[-1] == '*')
                    {
                        bb->priority_code = bb_operator4;
                    }
                    else
                    {
                        bb->priority_code = bb_operator2;
                    }
                }
            }
    }
    set_priority (bb);

    /* Add buf_break to the list */

    if (buf_break_list)
    {
        buf_break_list->next = bb;
    }

    bb->prev = buf_break_list;
    bb->next = NULL;
    buf_break_list = bb;

    if (!buf_break || (bb->col <= settings.max_col))
    {
        if (better_break (bb, buf_break))
        {
            /* Found better buf_break.  Get rid of all previous possible breaks. */

            buf_break = bb;

            for (bb = bb->prev; bb;)
            {
                buf_break_st_ty *obb = bb;

                bb = bb->prev;
                xfree(obb);
            }

            buf_break->prev = NULL;
        }
    }
}

/**
 *
 */

void clear_buf_break_list (
    BOOLEAN * pbreak_line)
{
    buf_break_st_ty *bb;

    for (bb = buf_break_list; bb;)
    {
        buf_break_st_ty *obb = bb;

        bb = bb->prev;
        xfree(obb);
    }

    buf_break = buf_break_list = NULL;
    *pbreak_line = false;
}

/**
 * @verbatim
 *        prev_code_target
 *        |                prev_code_target + offset
 *        |                |
 * <----->if ((aaa == bbb) && xxx
 *            && xxx
 *            |
 *            new_code_target
 * @endverbatim
 */

static void set_next_buf_break (
    int       prev_code_target,
    int       new_code_target,
    int       offset,
    BOOLEAN * pbreak_line)
{
    buf_break_st_ty *bb;

    better_break (buf_break, NULL);     /* Reset first_level */

    if (buf_break_list == buf_break)
    {
        clear_buf_break_list (pbreak_line);
    }
    else
    {
        /* Correct all elements of the remaining buf breaks: */
        for (bb = buf_break_list; bb; bb = bb->prev)
        {
            if (bb->target_col > buf_break->target_col && settings.lineup_to_parens)
            {
                bb->target_col -= ((prev_code_target + offset) - new_code_target);
            }

            bb->col -= ((prev_code_target + offset) - new_code_target);
            bb->offset -= offset;
            bb->priority_code_length -= offset;
            bb->first_level = buf_break->first_level;

            if (!buf_break->priority_newline)
            {
                bb->priority_newline = false;
            }

            set_priority (bb);

            if (bb->prev == buf_break)
            {
                break;
            }
        }

        xfree(buf_break);
        if (!bb) goto ret;

        /* Set buf_break to first break in the list */
        buf_break = bb;

        /* GDB_HOOK_buf_break */
        buf_break->prev = NULL;

        /* Find a better break of the existing breaks */
        for (bb = buf_break; bb; bb = bb->next)
        {
            if (bb->col > settings.max_col)
            {
                continue;
            }

            if (better_break (bb, buf_break))
            {
                /* Found better buf_break.  Get rid of all previous possible breaks. */
                buf_break = bb;

                for (bb = bb->prev; bb;)
                {
                    buf_break_st_ty *obb = bb;

                    bb = bb->prev;
                    xfree(obb);
                }
                bb = buf_break;
                buf_break->prev = NULL;
            }
        }
    }

ret:
	return;
}

/**
 * Name:         pad_output
 * Description:  Fill the output line with whitespace up to TARGET_COLUMN,
 *               given that the line is currently in column CURRENT_COLUMN.
 *
 * Returns:      the ending column number.
 *
 * History:
 */
static int pad_output(int cur_col, int target_column)
{
    int offset = 0;
    int align_target = target_column;
    int tos = parser_state_tos->tos;

    if (cur_col < target_column)
    {
        if (settings.use_tabs && (settings.tabsize > 1))
        {
            if (settings.align_with_spaces)
            {
                if (align_target >= parser_state_tos->ind_level)
                    align_target = parser_state_tos->ind_level;

                /* If we're within an if/for/while, only use tabs
                 * to indent to the same level as the parent
                 * statement.
                 */
                if (parser_state_tos->last_rw == rw_sp_paren &&
                    parser_state_tos->p_stack[tos] == stmt   &&
                    *s_code && tos > 0)
                {
                    do {
                        if (parser_state_tos->p_stack[tos] == ifstmt ||
                            parser_state_tos->p_stack[tos] == forstmt ||
                            parser_state_tos->p_stack[tos] == whilestmt)
                            break;
                    } while (--tos);
                    if (tos) align_target = parser_state_tos->il[tos];
                } else if (parser_state_tos->p_stack[tos] == ifstmt ||
                           parser_state_tos->p_stack[tos] == forstmt ||
                           parser_state_tos->p_stack[tos] == whilestmt)
                    align_target = parser_state_tos->il[tos];

                offset = (align_target - cur_col + 1) / settings.tabsize;
                align_target = cur_col + (offset * settings.tabsize);
            }

            offset = settings.tabsize - (cur_col - 1) % settings.tabsize;
            while (cur_col + offset <= align_target)
            {
                putc(TAB, output);
                cur_col += offset;
                offset = settings.tabsize;
            }
        }

        while (cur_col < target_column)
        {
            putc(' ', output);
            cur_col++;
        }
    }

    return cur_col;
}

/**
 * output the sequence of characters starting at begin and
 * ending at the character _before_ end (the character at end is not output)
 * to file.
 */

static void output_substring(
    FILE       * file,
    const char * begin,
    const char * end)
{
    const char * p;

    for (p = begin; p < end; p++)
    {
        putc (*p, file);
    }
}

/**
 * Name:         dump_line_label
 * Description:  routine that actually effects the printing of the new source's label section.
 *
 * Returns:      current column number..
 *
 * History:
 */

static int dump_line_label(void)
{
   int cur_col;

  /* print lab, if any */

   while ((e_lab > s_lab) && ((e_lab[-1] == ' ') ||
                              (e_lab[-1] == TAB)))
   {
      e_lab--;
   }

   cur_col = pad_output(1, compute_label_target());

  /* force indentation of preprocessor directives.
   * this happens when force_preproc_width > 0 */

   if ((settings.force_preproc_width > 0) &&
       (s_lab[0] == '#'))
   {
      int preproc_postcrement;
      char *p = &s_lab[1];

      while(*p == ' ')
      {
         p++;
      }

      preproc_postcrement = settings.force_preproc_width;

      if (strncmp(p, "else", 4) == 0)
      {
         preproc_indent-=settings.force_preproc_width;
      }
      else if ((strncmp(p, "if", 2) == 0) ||
               (strncmp(p, "ifdef", 5) == 0))
      {
      }
      else if (strncmp(p, "elif", 4) == 0)
      {
         preproc_indent -= settings.force_preproc_width;
      }
      else if (strncmp(p, "endif", 5) == 0)
      {
         preproc_indent -= settings.force_preproc_width;
         preproc_postcrement = 0;
      }
      else
      {
         preproc_postcrement = 0;
      }

      if (preproc_indent == 0)
      {
         fprintf (output, "#");
      }
      else
      {
         fprintf (output, "#%*s", preproc_indent, " ");
      }

      fprintf (output, "%.*s", (int) (e_lab - p), p);

      cur_col = count_columns (cur_col + preproc_indent + 1, p, NULL_CHAR);
      preproc_indent += preproc_postcrement;
   }
   else if ((s_lab[0] == '#') && ((strncmp (&s_lab[1], "else", 4) == 0) ||
                                  (strncmp (&s_lab[1], "endif", 5) == 0)))
   {
     /* Treat #else and #endif as a special case because any text
      * after #else or #endif should be converted to a comment.  */

      char *s = s_lab;

      if (e_lab[-1] == EOL)   /* Don't include EOL in the comment */
      {
         e_lab--;
      }

      do
      {
         putc (*s++, output);
         ++cur_col;
      } while ((s < e_lab) && ('a' <= *s) && (*s <= 'z'));

      while (((*s == ' ') || (*s == TAB)) && (s < e_lab))
      {
         s++;
      }

      if (s < e_lab)
      {
         if (settings.tabsize > 1)
         {
            cur_col = pad_output (cur_col, cur_col + settings.tabsize -
                                  (cur_col - 1) % settings.tabsize);
         }
         else
         {
            cur_col = pad_output (cur_col, cur_col + 2);
         }

         if (s[0] == '/' && (s[1] == '*' || s[1] == '/'))
         {
            fprintf (output, "%.*s", (int)(e_lab - s), s);
         }
         else
         {
            fprintf (output, "/* %.*s */", (int)(e_lab - s), s);
         }

        /* no need to update cur_col: the very next thing will
           be a new-line (or end of file) */
      }
   }
   else
   {
      fprintf (output, "%.*s", (int) (e_lab - s_lab), s_lab);
      cur_col = count_columns (cur_col, s_lab, NULL_CHAR);
   }

   return cur_col;
}

/**
 *
 */

static int count_parens(
    const char * string)
{
    int paren_level = 0;

    while (*string)
    {
        switch (*string)
        {
        case '(':
        case '[':
            paren_level++;
            break;
        case ')':
        case ']':
            paren_level--;
            break;
        default:
            break;
        }

        string++;
    }

    return paren_level;
}

/**
 *
 */

static void dump_line_code(
    int     * pcur_col,
    int     * pnot_truncated,
    int       paren_targ,
    BOOLEAN * pbreak_line,
    int       target_col_break)
{
   int paren_level   = 0;

   if (s_code != e_code)
   {                       /* print code section, if any */
      int i;
      int target_col = 0;

     /* If a comment begins this line, then indent it to the correct
      * column for comments, otherwise the line starts with code,
      * so indent it for code. */

      if (embedded_comment_on_line == 1)
      {
         target_col = parser_state_tos->com_col;
      }
      else if (target_col_break != -1)
      {
         target_col = target_col_break;
      }
      else
      {
         target_col = compute_code_target (paren_targ);
      }

     /* If a line ends in an lparen character, the following line should
      * not line up with the parenthesis, but should be indented by the
      * usual amount.  */

      if (parser_state_tos->last_token == lparen)
      {
         parser_state_tos->paren_indents[parser_state_tos->p_l_follow - 1] +=
               settings.ind_size - 1;
      }

      *pcur_col = pad_output (*pcur_col, target_col);

      if (*pbreak_line && (s_com == e_com) &&
          (buf_break->target_col <= buf_break->col))
      {
         int  offset;
         int  len;
         char c;
         char *ptr = &s_code[buf_break->offset];

         if (*ptr != ' ')
         {
            --ptr;
         }

        /* Add target_col (and negate) the brackets that are
         * actually printed.  The remaining brackets must
         * be given an offset of . */

         offset = ptr - s_code + 1;

         for (i = 0; i < parser_state_tos->p_l_follow; i++)
         {
            if (parser_state_tos->paren_indents[i] >= 0)
            {
               if (parser_state_tos->paren_indents[i] < ptr - s_code)
               {
                  parser_state_tos->paren_indents[i] =
                        -(parser_state_tos->paren_indents[i] + target_col);
               }
               else
               {
                  parser_state_tos->paren_indents[i] -= offset;
               }
            }
         }

         for (i = parser_state_tos->p_l_follow;
              i < parser_state_tos->paren_indents_size; ++i)
         {
            if (parser_state_tos->paren_indents[i] >= (ptr - s_code))
            {
               parser_state_tos->paren_indents[i] -= offset;
            }
         }

         output_substring(output, s_code, s_code + buf_break->offset);

         c = s_code[buf_break->offset];

         s_code[buf_break->offset] = '\0';

         *pcur_col = count_columns (*pcur_col, s_code, NULL_CHAR);

         paren_level += count_parens(s_code);

         s_code[buf_break->offset] = c;

         *pnot_truncated = 0;

         len = (e_code - ptr - 1);
         memmove (s_code, ptr + 1, len);

         e_code = s_code + len;
#if COLOR_DEBUG
         fputs (" \e[31m", output);

         output_substring(output, s_code, e_code);

         fputs (" \e[0m", output);
#endif
         *e_code = '\0';
         s_code_corresponds_to = buf_break->corresponds_to;
         prev_target_col_break = buf_break->target_col;

         if (!buf_break->priority_newline)
         {
            parser_state_tos->broken_at_non_nl = true;
         }

         set_next_buf_break (target_col, buf_break->target_col,
                             offset, pbreak_line);

         buf_break_used = 1;

         *pbreak_line = (buf_break != NULL) &&
               (output_line_length() > settings.max_col);
      }
      else
      {
         for (i = 0; i < parser_state_tos->p_l_follow; i++)
         {
            if (parser_state_tos->paren_indents[i] >= 0)
            {
               parser_state_tos->paren_indents[i] =
                     -(parser_state_tos->paren_indents[i] +
                       target_col);
            }
         }

         output_substring(output, s_code, e_code);

         *pcur_col = count_columns (*pcur_col, s_code, NULL_CHAR);
         clear_buf_break_list (pbreak_line);
      }
   }
}

/**
 * Name:         dump_line
 * Description:  routine that actually effects the printing of the new source.
 *               It prints the label section, followed by the code section with
 *               the appropriate nesting level, followed by any comments.
 *
 * Returns:      None.
 *
 * History:
 */

extern void dump_line (
    int          force_nl,
    int        * paren_targ,
    BOOLEAN    * pbreak_line)
{
    int cur_col;
    int not_truncated = 1;
    int target_col_break = -1;

    if (buf_break_used)
    {
        buf_break_used = 0;
        target_col_break = prev_target_col_break;
    }
    else if (force_nl)
    {
        parser_state_tos->broken_at_non_nl = false;
    }


    if (parser_state_tos->procname[0] && !parser_state_tos->classname[0] &&
        (s_code_corresponds_to == parser_state_tos->procname))
    {
        parser_state_tos->procname = "\0";
    }
    else if (parser_state_tos->procname[0] && parser_state_tos->classname[0] &&
             (s_code_corresponds_to == parser_state_tos->classname))
    {
        parser_state_tos->procname = "\0";
        parser_state_tos->classname = "\0";
    }

    /* A blank line */

    if ((s_code == e_code) && (s_lab == e_lab) && (s_com == e_com))
    {
        /* If we have a formfeed on a blank line, we should just output it,
         * rather than treat it as a normal blank line.  */

        if (parser_state_tos->use_ff)
        {
            putc ('\014', output);
            parser_state_tos->use_ff = false;
        }
        else
        {
            n_real_blanklines++;
        }
    }
    else
    {
        if (prefix_blankline_requested && (n_real_blanklines == 0))
        {
            if ((prefix_blankline_requested_code != decl) ||
                !parser_state_tos->decl_on_line)
            {
                n_real_blanklines = 1;
            }
        }
        else if (settings.swallow_optional_blanklines && (n_real_blanklines > 1))
        {
            n_real_blanklines = 1;
        }

        while (--n_real_blanklines >= 0)
        {
            putc (EOL, output);
        }

        n_real_blanklines = 0;

        if ((e_lab != s_lab) || (e_code != s_code))
        {
            ++code_lines;               /* keep count of lines with code */
        }

        if (e_lab != s_lab)
        {
            cur_col = dump_line_label();
        }
        else
        {
            cur_col = 1;                /* there is no label section */
        }

        parser_state_tos->pcase = false;

        /* Remove trailing spaces */
        while ((*(e_code - 1) == ' ') && (e_code > s_code))
        {
            *(--e_code) = NULL_CHAR;
        }

        dump_line_code(&cur_col, &not_truncated, *paren_targ, pbreak_line,
                       target_col_break);

        if (s_com != e_com)
        {
            {
                /* Here for comment printing. */
                int target = parser_state_tos->com_col;
                char *com_st = s_com;

                if (cur_col > target)
                {
                    putc (EOL, output);
                    cur_col = 1;
                    ++out_lines;
                }

                cur_col = pad_output (cur_col, target);
                fwrite (com_st, e_com - com_st, 1, output);
                cur_col += e_com - com_st;
                com_lines++;
            }
        }
        else if (embedded_comment_on_line)
        {
            com_lines++;
        }

        embedded_comment_on_line = 0;

        if (parser_state_tos->use_ff)
        {
            putc ('\014', output);
            parser_state_tos->use_ff = false;
        }
        else
        {
            putc (EOL, output);
        }

        ++out_lines;

        if ((parser_state_tos->just_saw_decl == 1) &&
            settings.blanklines_after_declarations)
        {
            prefix_blankline_requested = 1;
            prefix_blankline_requested_code = decl;
            parser_state_tos->just_saw_decl = 0;
        }
        else
        {
            prefix_blankline_requested = postfix_blankline_requested;
            prefix_blankline_requested_code = postfix_blankline_requested_code;
        }
        postfix_blankline_requested = 0;

    }

    /* if we are in the middle of a declaration, remember that fact
     * for proper comment indentation */

    parser_state_tos->decl_on_line = parser_state_tos->in_decl;

    /* next line should be indented if we have not completed this stmt */

    parser_state_tos->ind_stmt = parser_state_tos->in_stmt;

    e_lab = s_lab;
    *s_lab = '\0';    /* reset buffers */

    if (not_truncated)
    {
        e_code = s_code;
        *s_code = '\0';
        s_code_corresponds_to = NULL;
    }

    e_com = s_com;

    *s_com = '\0';

    parser_state_tos->ind_level = parser_state_tos->i_l_follow;
    parser_state_tos->paren_level = parser_state_tos->p_l_follow;

    if (parser_state_tos->paren_level > 0)
    {
        /* If we broke the line and the following line will
         * begin with a rparen, the indentation is set for
         * the column of the rparen *before* the break - reset
         * the column to the position after the break. */

        if (!not_truncated && ((*s_code == '(') || (*s_code == '[')) &&
            (parser_state_tos->paren_level >= 2))
        {
            *paren_targ = -parser_state_tos->paren_indents[parser_state_tos->paren_level - 2];
        }
        else
        {
            *paren_targ = -parser_state_tos->paren_indents[parser_state_tos->paren_level - 1];
        }
    }
    else
    {
        *paren_targ = 0;
    }

    if (inhibited)
    {
        char *p = cur_line;

        while (--n_real_blanklines >= 0)
        {
            putc (EOL, output);
        }

        n_real_blanklines = 0;

        do
        {
            while ((*p != '\0') && (*p != EOL))
            {
                putc (*p++, output);
            }

            if ((*p == '\0') &&
                ((unsigned long) (p - current_input->data) == current_input->size))
            {
                in_prog_pos = p;
                buf_end = p;
                buf_ptr = p;
                had_eof = true;
                return;
            }

            if (*p == EOL)
            {
                cur_line = p + 1;
                line_no++;
            }

            putc (*p++, output);
            while ((*p == ' ') || (*p == TAB))
            {
                putc (*p, output);
                p++;
            }

            if ((*p == '/') && ((*(p + 1) == '*') ||
                                (*(p + 1) == '/')))
            {
                /* We've hit a comment.  See if turns formatting
                   back on. */
                putc (*p++, output);
                putc (*p++, output);

                while ((*p == ' ') || (*p == TAB))
                {
                    putc (*p, output);
                    p++;
                }

                if (!strncmp (p, "*INDENT-ON*", 11))
                {
                    do
                    {
                        while ((*p != '\0') && (*p != EOL))
                        {
                            putc (*p++, output);
                        }

                        if ((*p == '\0') &&
                            (((unsigned long) (p - current_input->data) ==
                              current_input->size)))
                        {
                            in_prog_pos = p;
                            buf_end     = p;
                            buf_ptr     = p;
                            had_eof     = true;
                            return;
                        }
                        else
                        {
                            if (*p == EOL)
                            {
                                inhibited = false;
                                cur_line = p + 1;
                                line_no++;
                            }

                            putc (*p++, output);
                        }
                    } while (inhibited);
                }
            }
        } while (inhibited);

        in_prog_pos = cur_line;
        buf_end     = cur_line;
        buf_ptr     = cur_line;

        fill_buffer ();
    }

    /* Output the rest already if we really wanted a new-line after this code. */
    if (buf_break_used && (s_code != e_code) && force_nl)
    {
        prefix_blankline_requested = 0;
        dump_line (true, paren_targ, pbreak_line);
    }

    return;
}

/**
 * Name:         flush_output
 * Description:  Flushes any buffered output to the output file.
 *
 * Returns:      None
 *
 * History:
 */

extern void flush_output(void)
{
    fflush (output);
}

/**
 * Name:         open_output
 * Description:  Opens the output file in read/write mode.
 *
 * Returns:      None
 *
 * History:
 */

void open_output(
    const char * filename,
    const char * mode)
{
    if (filename == NULL)
    {
        output = stdout;
    }
    else
    {
        output = fopen(filename, mode);  /* open the file for read + write
                                          *  (but see the trunc function) */
        if (output == NULL)
        {
            fatal(_("indent: can't create %s\n"), filename);
        }
    }
}

/**
 * Name:         reopen_output_trunc
 * Description:  Reopens the output file truncated.
 *
 * Returns:      None
 *
 * History:
 */

extern void reopen_output_trunc(
    const char * filename)
{
    output = freopen(filename, "w", output);

}

/**
 * Name:         close_output
 * Description:  Closes the output file.
 *
 * Returns:      None
 *
 * History:
 */

extern void close_output(
     struct stat * file_stats,
     const char  * filename)
{
    if (output != stdout)
    {
        if (fclose(output) != 0)
        {
            fatal(_("Can't close output file %s"), filename);
        }
        else
        {
#ifdef PRESERVE_MTIME
            if (file_stats != NULL && filename)
            {
                struct utimbuf buf;

                buf.actime = time (NULL);
                buf.modtime = file_stats->st_mtime;
                if (utime(filename, &buf) != 0)
                {
                    WARNING(_("Can't preserve modification time on output file %s"),
                            filename, 0);
                }
            }
#endif
        }
    }
}

/**
 *
 */

extern void inhibit_indenting(
    BOOLEAN flag)
{
    inhibited = flag;
}

/**
 * Return the column in which we should place the code in s_code. 
 */

int compute_code_target (
    int paren_targ)
{
    int target_col;

    if (buf_break_used)
    {
        return prev_target_col_break;
    }

    if (parser_state_tos->procname[0] &&
        (s_code_corresponds_to == parser_state_tos->procname))
    {
        target_col = 1;

        if (!parser_state_tos->paren_level)
        {
            return target_col;
        }
    }
    else
    {
        target_col = parser_state_tos->ind_level + 1;
    }

    if (!parser_state_tos->paren_level)
    {
        if (parser_state_tos->ind_stmt)
        {
            target_col += settings.continuation_indent;
        }

        return target_col;
    }

    if (!settings.lineup_to_parens)
    {
        return target_col + settings.continuation_indent +
                (settings.paren_indent * (parser_state_tos->paren_level - 1));
    }

    return paren_targ;
}

/**
*
*/

int count_columns (
    int column,
    char *bp,
    int stop_char)
{
    while (*bp != stop_char && *bp != NULL_CHAR)
    {
        switch (*bp++)
        {
        case EOL:
        case '\f':           /* form feed */
            column = 1;
            break;
        case TAB:
            column += settings.tabsize - (column - 1) % settings.tabsize;
            break;
        case 010:           /* backspace */
            --column;
            break;
#ifdef COLOR_DEBUG
        case '\e':          /* ANSI color */
            while (*bp++ != 'm')
            {
            }

            break;
#endif
        default:
            ++column;
            break;
        }
    }

    return column;
}

/**
 *
 */

int compute_label_target (void)
{
    /* maybe there should be some option to tell indent where to put public:,
     * private: etc. ? */

    if (*s_lab == '#')
    {
        return 1;
    }

    if (parser_state_tos->pcase)
    {
        return parser_state_tos->cstk[parser_state_tos->tos] + 1;
    }

    if (settings.c_plus_plus && parser_state_tos->in_decl)
    {
        /* FIXME: does this belong here at all? */
        return 1;
    }
    else if (settings.label_offset < 0)
    {
       return parser_state_tos->ind_level + settings.label_offset + 1;
    } 
    else
    {
        return settings.label_offset + 1;
    }
}

/**
 * Compute the length of the line we will be outputting. 
 */

int output_line_length (void)
{
    int code_length = 0;
    int com_length = 0;
    int length;

    if (s_lab == e_lab)
    {
        length = 0;
    }
    else
    {
        length = count_columns (compute_label_target (), s_lab, EOL) - 1;
    }

    if (s_code != e_code)
    {
        int code_col = compute_code_target(paren_target);

        code_length = count_columns(code_col, s_code, EOL) - code_col;
    }

    if (s_com != e_com)
    {
        int com_col = parser_state_tos->com_col;

        com_length = count_columns(com_col, s_com, EOL) - com_col;
    }

    if (code_length != 0)
    {
        length += compute_code_target(paren_target) - 1 + code_length;

        if (embedded_comment_on_line)
        {
            length += com_length;
        }
    }

    return length;
}

