/** \file
 * handletoken.c  GNU indent, processing of tokens returned by the parser.
 *
 * Copyright (c) 2015 Tim Hentenaar. All rights reserved.<br>
 * Copyright (c) 2013 Łukasz Stelmach.  All rights reserved.<br>
 * Copyright (c) 1999, 2000 Carlo Wood.  All rights reserved. <br>
 * Copyright (c) 1994, 1996, 1997 Joseph Arceneaux.  All rights reserved. <br>
 * Copyright (c) 1992, 2002, 2008, 2014 Free Software Foundation, Inc.  All rights reserved. <br>
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
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *
 * Updates:
 * - 2002-08-05: Matthias <moh@itec.uni-klu.ac.at> and Eric Lloyd <ewlloyd@neta.com>
 *             Added support for -brf to place function opening brace after function
 *             declaration.
 * - 28 Sep 2003 Erik de Castro Lopo
 *             Fixed Bug#212320: --blank-lines-after-proceduresdoes not work
 * - 28 Sep 2003 Erik de Castro Lopo
 *             Fixed Bug#206785: indent segfaults on the attached file
 * - 28 Sep 2003 Geoffrey Lee <glee@bogus.example.com>
 *             Fixed Bug#205692: indent: [patch] fix garble shown in locale(fwd)
 * - 2008-03-08 DI Re-baselined on the more acceptable (license-wise) OpenBSD release 3.4.
 *              
 */

#include "sys.h"

#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "indent.h"
#include "backup.h"
#include "code_io.h"
#include "globs.h"
#include "parse.h"
#include "comments.h"
#include "args.h"
#include "output.h"
#include "handletoken.h"

RCSTAG_CC ("$GNU$");

/**
 * Expand a buffer to hold more chars, aligned on a
 * 1 KB boundary.
 */
extern void need_chars(buf_ty * bp, size_t needed)
{
    size_t current_size = (size_t)(bp->end - bp->ptr);

    if (current_size + needed >= (size_t)bp->size)
    {
        bp->size = ((current_size + needed) & (size_t)~1023);
        bp->ptr = xrealloc(bp->ptr, bp->size);
        if (bp->ptr == NULL)
        {
            fatal (_("Ran out of memory"), 0);
        }

        bp->end = bp->ptr + current_size;
    }
}

/**
 *
 */
extern void check_code_size(void)
{
    if (e_code >= l_code)                               
    {                                                   
        int nsize = l_code - s_code + 400;               
        codebuf   = xrealloc(codebuf, nsize);  
        e_code    = codebuf + (e_code - s_code) + 1; 
        l_code    = codebuf + nsize - 5; 
        s_code    = codebuf + 1; 
    }
}

/**
 *
 */

static void check_lab_size(void)
{
    if (e_lab >= l_lab)
    {
        int nsize  = l_lab - s_lab + 400;               
        labbuf = xrealloc(labbuf, nsize); 
        e_lab  = labbuf + (e_lab - s_lab) + 1;        
        l_lab  = labbuf + nsize - 5;                
        s_lab  = labbuf + 1;                        
    }
}

/**
 *
 */

static void copy_id(
    const codes_ty   type_code,
    BOOLEAN        * force_nl,
    exit_values_ty * file_exit_value,
    const bb_code_ty can_break)
{
    char           * t_ptr;
    
    if (parser_state_tos->want_blank)
    {
        set_buf_break (bb_ident, paren_target);
        *(e_code++) = ' ';
    }
    else if (can_break)
    {
        set_buf_break (can_break, paren_target);
    }
    else
    {
    }

    if (s_code == e_code)
    {
        s_code_corresponds_to = token;
    }

    for (t_ptr = token; t_ptr < token_end; ++t_ptr)
    {
        check_code_size();
        *(e_code++) = *t_ptr;
    }

    *e_code = '\0'; /* null terminate code sect */

    parser_state_tos->want_blank = true;

    /* Handle the options -nsaf, -nsai and -nsaw */

    if ((type_code == sp_paren) &&
        ((!settings.space_after_if && (*token == 'i')) ||
         (!settings.space_after_for && (*token == 'f')) ||
         (!settings.space_after_while && (*token == 'w'))))
    {
        parser_state_tos->want_blank = false;
    }

    /* If the token is one of the GNU gettext macro's '_' or 'N_'
     * then we don't want a blank */

    if ((((token_end - token) == 1) && (*token == '_')) ||
        (((token_end - token) == 2) && (*token == 'N') &&
         (token[1] == '_')))
    {
        parser_state_tos->want_blank = false;
    }

    /* If the token is va_dcl, it appears without a semicolon, so we
     * need to pretend that one was there.  */

    if (((token_end - token) == 6) && (strncmp (token, "va_dcl", 6) == 0))
    {
        parser_state_tos->in_or_st = 0;
        parser_state_tos->just_saw_decl--;
        parser_state_tos->in_decl = false;

        do
        {
            if (parse (semicolon) != total_success) 
            {
                *file_exit_value = indent_error;
            }
        } while(0);
                
        *force_nl = true;
    }
}

/**
 *
 */

static void handle_token_form_feed(
    BOOLEAN * pbreak_line)
{
    parser_state_tos->use_ff = true;        /* a form feed is treated
                                             * much like a newline */
    dump_line (true, &paren_target, pbreak_line);
    parser_state_tos->want_blank = false;
}

/**
 * 2002-06-13 D.Ingamells Reset force_nl if the line is dumped.
 */

static void handle_token_newline(
    BOOLEAN * force_nl,
    BOOLEAN * pbreak_line)
{
            
    if (s_lab != e_lab && *s_lab == '#')
    {
        dump_line (true, &paren_target, pbreak_line);

        if (s_code == e_code)
        {
            parser_state_tos->want_blank = false;
        }

        *force_nl = false;
    }
    else
    {
        if ( ( (parser_state_tos->last_token != comma) || 
               !settings.leave_comma ||
               !break_comma || 
               (parser_state_tos->p_l_follow > 0) ||
               parser_state_tos->block_init || 
               (s_com != e_com)) &&
             ( ( (parser_state_tos->last_token != rbrace) ||
                 !(settings.braces_on_struct_decl_line && 
                   parser_state_tos->in_decl))))
        {
            /* Attempt to detect the newline before a procedure name,
             * and if e.g., K&R style, leave the procedure on the
             * same line as the type. */

            if (!settings.procnames_start_line && 
                (s_lab == e_lab) &&
                (parser_state_tos->last_token != lparen) &&
                (parser_state_tos->last_token != semicolon) &&
                (parser_state_tos->last_token != comma) &&
                (parser_state_tos->last_rw == rw_decl) &&
                (parser_state_tos->last_rw_depth == 0) &&
                (!parser_state_tos->block_init) &&
                (parser_state_tos->in_decl))
            {
                /* Put a space between the type and the procedure name,
                 * unless it was a pointer type and the user doesn't
                 * want such spaces after '*'. */

                if (!((e_code > s_code) &&
                      (e_code[-1] == '*')))
                {
                    parser_state_tos->want_blank = true;
                }
            }

            if (!parser_state_tos->in_stmt ||
                (s_com != e_com) || 
                embedded_comment_on_line)
            {
                dump_line (true, &paren_target, pbreak_line);

                if (s_code == e_code)
                {
                    parser_state_tos->want_blank = false;
                }

                *force_nl = false;
            }
        }
    }

    /* If we were on the line with a #else or a #endif, we aren't
     * anymore.  */

    else_or_endif = false;
    ++line_no;              /* keep track of input line number */
}

/**
 *
 */

static void handle_token_lparen(
    BOOLEAN       * force_nl,
    BOOLEAN       * sp_sw,
    int           * dec_ind,
    BOOLEAN       * pbreak_line)
{
    /* Braces in initializer lists should be put on new lines. This is
     * necessary so that -gnu does not cause things like char
     * *this_is_a_string_array[] = { "foo", "this_string_does_not_fit",
     * "nor_does_this_rather_long_string" } which is what happens
     * because we are trying to line the strings up with the
     * parentheses, and those that are too long are moved to the right
     * an ugly amount.
     *
     * However, if the current line is empty, the left brace is
     * already on a new line, so don't molest it.
     */

    if ((*token == '{') && ((s_code != e_code) ||
                              (s_com  != e_com)  ||
                              (s_lab  != e_lab)))
    {
        dump_line (true, &paren_target, pbreak_line);

        /* Do not put a space before the '{'.  */

        parser_state_tos->want_blank = false;
    }

    /* Count parens so we know how deep we are.  */
    
    ++parser_state_tos->p_l_follow;
    
    if (parser_state_tos->p_l_follow >= parser_state_tos->paren_indents_size)
    {
        parser_state_tos->paren_indents_size *= 2;
        parser_state_tos->paren_indents =
                xrealloc(parser_state_tos->paren_indents,
                         parser_state_tos->paren_indents_size * sizeof(short));
    }

    parser_state_tos->paren_depth++;

	/* In the case of nested function pointer declarations, let's ensure
	 * we output a ' ' between the decl word and the lparen, but NOT
	 * between the following rparen and lparen.
	 */
    if (parser_state_tos->is_func_ptr_decl && !settings.proc_calls_space)
        parser_state_tos->want_blank = (*(token - 1) != ')' && *(token - 1) != ' ');

    if (parser_state_tos->want_blank &&
        (*token != '[') &&
        ( (parser_state_tos->last_token != ident) ||
          settings.proc_calls_space ||
          (parser_state_tos->its_a_keyword &&
           (!parser_state_tos->sizeof_keyword || settings.blank_after_sizeof))))
    {
        set_buf_break (bb_proc_call, paren_target);
        *(e_code++) = ' ';
        *e_code = '\0';     /* null terminate code sect */
    }
    else
    {
        set_buf_break (bb_proc_call, paren_target);
    }

	/* Remember if this looks like a function pointer decl. */
	if (*(token + 1) == '*' &&
	    parser_state_tos->last_rw == rw_decl &&
	    (parser_state_tos->last_token == decl ||
	     parser_state_tos->last_token == unary_op))
	        parser_state_tos->is_func_ptr_decl = true;

    if (parser_state_tos->in_decl && !parser_state_tos->block_init)
    {
        if ((*token != '[') && !buf_break_used)
        {
            while ((e_code - s_code) < *dec_ind)
            {
                check_code_size();
                set_buf_break (bb_dec_ind, paren_target);
                *(e_code++) = ' ';
            }

            *(e_code++) = token[0];
            parser_state_tos->ind_stmt = false;
        }
        else
        {
            *(e_code++) = token[0];
        }
    }
    else
    {
        *(e_code++) = token[0];
    }

    if (settings.parentheses_space && *token != '[')
    {
        *(e_code++) = ' ';
    }

    parser_state_tos->paren_indents[parser_state_tos->p_l_follow - 1] =
            e_code - s_code;

    if (*sp_sw && (parser_state_tos->p_l_follow == 1) &&
        settings.extra_expression_indent &&
        (parser_state_tos->paren_indents[0] < 2 * settings.ind_size))
    {
        parser_state_tos->paren_indents[0] = 2 * settings.ind_size;
    }

    parser_state_tos->want_blank = false;

    if ((parser_state_tos->in_or_st == 1) && *token == '(')
    {
        /* this is a kludge to make sure that declarations will be
         * correctly aligned if proc decl has an explicit type on it, i.e.
         * "int a(x) {..." */

        parse_lparen_in_decl ();

        /* Turn off flag for structure decl or initialization.  */
        
        parser_state_tos->in_or_st = 0;
    }

    /* For declarations, if user wants all fn decls broken, force that
     * now. 
     */
    
    if ((*token == '(')                   && 
        settings.break_function_decl_args &&
        parser_state_tos->in_stmt         && 
        parser_state_tos->in_decl         &&
        (parser_state_tos->paren_depth == 1))
    {
        dump_line(true, &paren_target, pbreak_line);
        *force_nl = false;
        
        paren_target = parser_state_tos->paren_depth * settings.ind_size + 1;
        parser_state_tos->paren_indents[parser_state_tos->p_l_follow - 1] = -paren_target;
    }

    if (parser_state_tos->sizeof_keyword)
    {
        parser_state_tos->sizeof_mask |= 1 << parser_state_tos->p_l_follow;
    }

    /* The '(' that starts a cast can never be preceded by an
     * indentifier or decl.  There is an exception immediately
     * following a return.  To prevent that influence from going
     * too far, it is reset by a following ident in lexi.c. 
     */

    if ((parser_state_tos->last_token == decl) ||
        ((parser_state_tos->last_token == ident) &&
         (parser_state_tos->last_rw != rw_return)))
    {
        parser_state_tos->noncast_mask |=
                1 << parser_state_tos->p_l_follow;
    }
    else
    {
        parser_state_tos->noncast_mask &=
                ~(1 << parser_state_tos->p_l_follow);
    }
}

/**
 *
 */

static void handle_token_rparen(
   BOOLEAN        * force_nl,
   BOOLEAN        * sp_sw,
   codes_ty       * hd_type,
   BOOLEAN        * last_token_ends_sp,
   exit_values_ty * file_exit_value,
   BOOLEAN        * pbreak_line)
{
    char tmpchar[2], *tmp;

    parser_state_tos->paren_depth--;
    
    /* For declarations, if user wants close of fn decls broken, force that
     * now. 
     */
    if ((*token == ')')                   &&
        settings.break_function_decl_args_end &&
        !parser_state_tos->in_or_st       &&
         parser_state_tos->in_stmt        && 
        parser_state_tos->in_decl         &&
        (parser_state_tos->paren_depth == 0))
    {
        if ((s_code != e_code) || (s_lab != e_lab) || (s_com != e_com))
        {
            dump_line(true, &paren_target, pbreak_line);
        }
        
        paren_target = parser_state_tos->paren_depth * settings.ind_size;
        parser_state_tos->paren_indents[parser_state_tos->p_l_follow - 1] = paren_target;
        parser_state_tos->ind_stmt = 0;
    }

    if (parser_state_tos->
        cast_mask & (1 << parser_state_tos->
                     p_l_follow) & ~parser_state_tos->sizeof_mask)
    {
        parser_state_tos->last_u_d = true;
        parser_state_tos->cast_mask &=
                (1 << parser_state_tos->p_l_follow) - 1;
        if (!parser_state_tos->cast_mask && settings.cast_space)
        {
            parser_state_tos->want_blank = true;
        }
        else
        {
            parser_state_tos->want_blank = false;
            parser_state_tos->can_break = bb_cast;
        }

        /* Check for a C99 compound literal */
        tmp = token + 1;
        while (isspace(*tmp)) tmp++;
        if (*tmp == '{')
            parser_state_tos->block_init = 3;
    }
    else if (parser_state_tos->in_decl &&
             !parser_state_tos->block_init &&
             (parser_state_tos->paren_depth == 0))
    {
        parser_state_tos->want_blank = true;
    }
    else
    {
      /* what ? */
    }

    parser_state_tos->sizeof_mask &=
            (1 << parser_state_tos->p_l_follow) - 1;

    if (--parser_state_tos->p_l_follow < 0)
    {
        parser_state_tos->p_l_follow = 0;
        tmpchar[0] = *token; tmpchar[1] = '\0';
        WARNING(_("Extra %s"), tmpchar, NULL);
    }

    /* if the paren starts the line, then indent it */

    if (e_code == s_code)
    {
        int level = parser_state_tos->p_l_follow;

        parser_state_tos->paren_level = level;
        if (level > 0)
        {
            paren_target = -parser_state_tos->paren_indents[level - 1];
        }
        else
        {
            paren_target = 0;
        }
    }

    if (settings.parentheses_space && *token != ']')
    {
        *(e_code++) = ' ';
    }

    *(e_code++) = token[0];

    /* Something is setting want_blank to false whereas we need to emit
     * a space if we have a single-line conditional, so make sure we
     * indicate that we want a space before the next identifier.
     */
    if (settings.allow_single_line_conditionals && *(token - 1) == ')'
        && *(token + 2) != '{' && !parser_state_tos->paren_depth)
    {
        parser_state_tos->want_blank = true;
    }

    /* check for end of if (...), or some such */

    if (*sp_sw && (parser_state_tos->p_l_follow == 0))
    {
        /* Indicate that we have just left the parenthesized expression
         * of a while, if, or for, unless we are getting out of the
         * parenthesized expression of the while of a do-while loop.
         * (do-while is different because a semicolon immediately
         * following this will not indicate a null loop body).  */

        if (parser_state_tos->p_stack[parser_state_tos->tos] != dohead)
        {
            *last_token_ends_sp = 2;
        }

        *sp_sw = false;
        *force_nl = !settings.allow_single_line_conditionals;
        parser_state_tos->last_u_d = true;  /* inform lexi that a
                                             * following operator is
                                             * unary */
        parser_state_tos->in_stmt = false;  /* dont use stmt
                                             * continuation
                                             * indentation */

        if (parse (*hd_type) != total_success)
        {
            *file_exit_value = indent_error;
        }
    }

    /* this should ensure that constructs such as main(){...} and
     * int[]{...} have their braces put in the right place
     */
    
    parser_state_tos->search_brace = settings.btype_2;
}

/**
 *
 */

static void handle_token_unary_op(
    int            * dec_ind,
    const bb_code_ty can_break)
{
    char           * t_ptr;
    
    if (parser_state_tos->want_blank &&
        !(parser_state_tos->in_decl &&
          !settings.pointer_align_right &&
          *token == '*'))
    {
        set_buf_break (bb_unary_op, paren_target);
        *(e_code++) = ' ';
        *e_code = '\0';     /* null terminate code sect */
        parser_state_tos->want_blank = false;
    }
    else if (can_break)
    {
        set_buf_break (can_break, paren_target);
    }
    else
    {
      /* what ? */
    }

    {
        char *res = token;
        char *res_end = token_end;

        /* if this is a unary op in a declaration, we should
         * indent this token */

        if ((parser_state_tos->paren_depth == 0) &&
            parser_state_tos->in_decl && !buf_break_used &&
            !parser_state_tos->block_init)
        {
            while ((e_code - s_code) < (*dec_ind - (token_end - token)))
            {
                check_code_size();
                set_buf_break (bb_dec_ind, paren_target);
                *(e_code++) = ' ';
            }

            parser_state_tos->ind_stmt = false;
        }
        else
        {
           /* avoid "- --a" becoming "---a" */

            if ((parser_state_tos->last_token == unary_op) &&
                (e_code > s_code) &&
                 *res != '!' &&
                (*(e_code - 1) == *res))
            {
                *(e_code++) = ' ';
            }
        }

        for (t_ptr = res; t_ptr < res_end; ++t_ptr)
        {
            check_code_size();
            *(e_code++) = *t_ptr;
        }

        if (parser_state_tos->want_blank &&
            !(parser_state_tos->in_decl &&
              settings.pointer_align_right &&
              *token == '*'))
        {
            set_buf_break (bb_unary_op, paren_target);
            *(e_code++) = ' ';
        }

        *e_code = '\0';     /* null terminate code sect */
    }

    parser_state_tos->want_blank = false;
}

/**
 *
 */

static void handle_token_binary_op(
    const bb_code_ty can_break)
{
    char           * t_ptr;
            
    if (parser_state_tos->want_blank        || 
        (e_code > s_code && *e_code != ' '))
    {
        set_buf_break (bb_binary_op, paren_target);
        *(e_code++) = ' ';
        *e_code = '\0';     /* null terminate code sect */
    }
    else if (can_break)
    {
        set_buf_break (can_break, paren_target);
    }
    else
    {
      /* what ? */
    }

    {
        char *res = token;
        char *res_end = token_end;

        for (t_ptr = res; t_ptr < res_end; ++t_ptr)
        {
            check_code_size();
            *(e_code++) = *t_ptr;     /* move the operator */
        }
    }

#if 1
    if (*token == '=')
    {
        parser_state_tos->in_decl = false;
        
    }
#endif
    
    parser_state_tos->want_blank = true;
}

/**
 *
 */

static void handle_token_postop(void)
{
    *(e_code++) = token[0];
    *(e_code++) = token[1];
    parser_state_tos->want_blank = true;
}

/**
 *
 */

static void handle_token_question(
   const bb_code_ty can_break)
{
    squest++;               /* this will be used when a later colon
                             * appears so we can distinguish the
                             * <c>?<n>:<n> construct */

    if (parser_state_tos->want_blank)
    {
        set_buf_break (bb_question, paren_target);
        *(e_code++) = ' ';
    }
    else if (can_break)
    {
        set_buf_break (can_break, paren_target);
    }
    else
    {
      /* what ? */
    }

    *(e_code++) = '?';
    parser_state_tos->want_blank = true;
    *e_code = '\0'; /* null terminate code sect */
}

/**
 *
 */

static void handle_token_casestmt(
   BOOLEAN        * scase,
   exit_values_ty * file_exit_value)
{
    *scase = true;           /* so we can process the later colon
                              * properly */
    do
    {
        if (parse (casestmt) != total_success)
        {
            *file_exit_value = indent_error;
        }
    } while(0);       /* Let parser know about it */
            
}

/**
 *
 */

static void handle_token_colon(
   BOOLEAN        * scase,
   BOOLEAN        * force_nl,
   int            * dec_ind,
   const bb_code_ty can_break,
   BOOLEAN        * pbreak_line)
{
    char           * t_ptr;

    if (squest > 0)
    {
        /* it is part of the <c> ? <n> : <n> construct */

        --squest;
        if (parser_state_tos->want_blank)
        {
            set_buf_break (bb_colon, paren_target);
            *(e_code++) = ' ';
        }
        else if (can_break)
        {
            set_buf_break (can_break, paren_target);
        }
        else
        {
          /* what ? */
        }

        *(e_code++) = ':';
        *e_code = '\0';     /* null terminate code sect */
        parser_state_tos->want_blank = true;
    }
    else
    {
        /*            __ e_code
         *           |
         * "  private:\n"                     C++, treat as label.
         *  ^^^        ^
         *  |          |
         *  |          `- buf_ptr (in different buffer though!)
         *  `- s_code
         *
         * or
         *
         * "  unsigned int private:4\n"       C/C++, treat as bits.
         */
                
        if (parser_state_tos->in_decl)
        {
            if (!(((e_code - s_code > 6) &&
                   !strncmp (&buf_ptr[-8], "private:", 8)) &&
                  !isdigit (*buf_ptr)) &&
                !(((e_code - s_code > 8) &&
                   !strncmp (&buf_ptr[-10], "protected:", 10)) &&
                  !isdigit (*buf_ptr)) &&
                !(((e_code - s_code > 5) &&
                   !strncmp (&buf_ptr[-7], "public:", 7)) &&
                  !isdigit (*buf_ptr)))
            {
                *(e_code++) = ':';
                parser_state_tos->want_blank = false;
                return;
            }
            else if (*s_code == ' ')
            {
                /*
                 * It is possible that dec_ind spaces have been inserted before
                 * the `public:' etc. label because indent thinks it's of the
                 * type:
                 */
                /*
                 * Only now we see the '4' isn't there.
                 * Remove those spaces:
                 */
                        
                char *p1 = s_code;
                char *p2 = s_code + *dec_ind;
                        
                while (p2 < e_code)
                {
                    *p1++ = *p2++;
                }
                        
                e_code -= *dec_ind;
                *e_code = '\0';
            }
            else
            {
              /* what ? */
            }
        }
                
        parser_state_tos->in_stmt = false;      /* seeing a label does not
                                                 * imply we are in a stmt */
        for (t_ptr = s_code; *t_ptr; ++t_ptr)
        {
            check_lab_size();
            *e_lab++ = *t_ptr;  /* turn everything so far into a label */
        }
                
        e_code = s_code;
        clear_buf_break_list (pbreak_line); /* This is bullshit for C code, because
                                             * normally a label doesn't have breakpoints
                                             * at all of course.  But in the case of
                                             * wrong code, not clearing the list can make
                                             * indent core dump. */
        *e_lab++ = ':';
        set_buf_break (bb_label, paren_target);
        *e_lab++ = ' ';
        *e_lab = '\0';
                
        /* parser_state_tos->pcas e will be used by dump_line to decide
         * how to indent the label. force_nl will force a case n: to be
         * on a line by itself */
                
        *force_nl = parser_state_tos->pcase = *scase;
        *scase = false;
        parser_state_tos->want_blank = false;
    }
}

/**
 *
 */

static void handle_token_doublecolon(void)
{
    *(e_code++) = ':';
    *(e_code++) = ':';
    parser_state_tos->want_blank = false;
    parser_state_tos->can_break = bb_doublecolon;
    parser_state_tos->last_u_d = true;
    parser_state_tos->saw_double_colon = true;
}

/**
 *
 */

static void handle_token_semicolon(
    BOOLEAN        * scase,
    BOOLEAN        * force_nl,
    BOOLEAN        * sp_sw,
    int            * dec_ind,
    BOOLEAN        * last_token_ends_sp,
    exit_values_ty * file_exit_value)
{
    parser_state_tos->in_or_st = 0;
    parser_state_tos->saw_double_colon = false;
    *scase = false;
    squest = 0;

    /* The following code doesn't seem to do much good. Just because
     * we've found something like extern int foo();    or int (*foo)();
     * doesn't mean we are out of a declaration.  Now if it was serving
     * some purpose we'll have to address that.... if
     * (parser_state_tos->last_token == rparen)
     * parser_state_tos->in_parameter_declaration = 0; */

    parser_state_tos->cast_mask = 0;
    parser_state_tos->sizeof_mask = 0;
    parser_state_tos->block_init = 0;
    parser_state_tos->block_init_level = 0;
    parser_state_tos->just_saw_decl--;
    parser_state_tos->is_func_ptr_decl = false;

    if (parser_state_tos->in_decl &&
        (s_code == e_code) && !buf_break_used &&
        !parser_state_tos->block_init)
    {
        while ((e_code - s_code) < (*dec_ind - 1))
        {
            check_code_size();
            set_buf_break (bb_dec_ind, paren_target);
            *(e_code++) = ' ';
        }

        parser_state_tos->ind_stmt = false;
    }

    *e_code = '\0'; /* null terminate code sect */

    /* if we were in a first level structure declaration,
     * we aren't any more */

    parser_state_tos->in_decl = (parser_state_tos->dec_nest > 0) ? true : false;

    /* If we have a semicolon following an if, while, or for, and the
     * user wants us to, we should insert a space (to show that there
     * is a null statement there).  */

    if (*last_token_ends_sp && settings.space_sp_semicolon)
    {
        *(e_code++) = ' ';
    }

    *(e_code++) = ';';
    *e_code = '\0'; /* null terminate code sect */
    parser_state_tos->want_blank = true;

    /* we are no longer in the middle of a stmt */

    parser_state_tos->in_stmt = (parser_state_tos->p_l_follow > 0);

    if (!*sp_sw)
    {                       /* if not if for (;;) */
        do
        {
            if (parse (semicolon) != total_success)
            {
                *file_exit_value = indent_error;
            }
        } while(0);
                
        *force_nl = true;    /* force newline after a end of stmt */
    }
}

/**
 *
 */

static void handle_token_lbrace(
   BOOLEAN        * force_nl,
   int            * dec_ind,
   exit_values_ty * file_exit_value,
   BOOLEAN        * pbreak_line)
{
    parser_state_tos->saw_double_colon = false;

    /* If the last token was a binary_op (probably =) then we're
     * likely starting an initializer or initializer list.
     */
    if (parser_state_tos->last_token == binary_op)
        parser_state_tos->block_init = 1;

    if (!parser_state_tos->block_init)
    {
        *force_nl = true;    /* force other stuff on same line as '{' onto
                              * new line */
        parser_state_tos->in_stmt = false;  /* dont indent the '{' */
    }
    else
    {
        /* dont indent the '{' unless it is followed by more code. */

        char *p = buf_ptr;

        for (;;)
        {
            p = skip_horiz_space(p);

            if (*p == EOL || (*p == '/' && p[1] == '/'))
            {
                parser_state_tos->in_stmt = false;
                break;
            }
            else if (*p == '/' && p[1] == '*')
            {
                p += 2;
                /* skip over comment */

                while (*p && *p != EOL && (*p != '*' || p[1] != '/'))
                {
                    ++p;
                }

                if (!*p || *p == EOL)
                {
                    parser_state_tos->in_stmt = false;
                    break;
                }
                p += 2;

                if (!*p)
                {
                    break;
                }
            }
            else
            {
                break;
            }

        }

        if (parser_state_tos->block_init_level <= 0)
        {
            parser_state_tos->block_init_level = 1;
        }
        else
        {
            parser_state_tos->block_init_level++;
        }
    }

    if (s_code != e_code && parser_state_tos->block_init != 1)
    {
        if ((!parser_state_tos->in_decl && !settings.btype_2) ||
            (parser_state_tos->in_decl &&
             !settings.braces_on_struct_decl_line &&
             !settings.braces_on_func_def_line))
        {
            dump_line (true, &paren_target, pbreak_line);
            parser_state_tos->want_blank = false;
        }
        else
        {
            if (parser_state_tos->in_parameter_declaration &&
                !parser_state_tos->in_or_st)
            {
                parser_state_tos->i_l_follow = 0;
                
                if (!settings.braces_on_func_def_line)
                {
                    dump_line (true, &paren_target, pbreak_line);
                }
                else
                {
                    *(e_code++) = ' ';
                }
                
                parser_state_tos->want_blank = false;
            }
            else
            {
                parser_state_tos->want_blank = true;
            }
        }
    }

    if (parser_state_tos->in_parameter_declaration)
    {
        prefix_blankline_requested = 0;
    }

    if (s_code == e_code)
    {
        parser_state_tos->ind_stmt = false; /* dont put extra indentation
                                               on line with '{' */
    }

    if (parser_state_tos->in_decl && parser_state_tos->in_or_st)
    {
        /* This is a structure declaration.  */
        if (parser_state_tos->dec_nest >= di_stack_alloc)
        {
            di_stack_alloc *= 2;
            di_stack = xrealloc(di_stack,
                                di_stack_alloc * sizeof(*di_stack));
        }

        di_stack[parser_state_tos->dec_nest++] = *dec_ind;
    }
    else
    {
        parser_state_tos->in_decl = false;
        parser_state_tos->decl_on_line = false;     /* we cant be in the
                                                     * middle of a
                                                     * declaration, so dont
                                                     * do special
                                                     * indentation of
                                                     * comments */

        parser_state_tos->in_parameter_declaration = 0;
    }

    *dec_ind = 0;

    /* We are no longer looking for an initializer or structure. Needed
     * so that the '=' in "enum bar {a = 1" does not get interpreted as
     * the start of an initializer.  */

    parser_state_tos->in_or_st = 0;

    do
    {
        if (parse (lbrace) != total_success)
        {
            *file_exit_value = indent_error;
        }
    } while(0);
            
    set_buf_break (bb_lbrace, paren_target);
    
    if (parser_state_tos->want_blank && s_code != e_code)
    {
        /* put a blank before '{' if '{' is not at start of line */

        *(e_code++) = ' ';
    }

    parser_state_tos->want_blank = false;
    *(e_code++) = '{';
    *e_code = '\0'; /* null terminate code sect */

    parser_state_tos->just_saw_decl = 0;

    if (parser_state_tos->block_init &&
        (parser_state_tos->block_init_level >= 2))
    {
        /* Treat the indentation of the second '{' as a '('
         * in * struct foo { { bar }, ... } */

        if (++parser_state_tos->p_l_follow >=
            parser_state_tos->paren_indents_size)
        {
            parser_state_tos->paren_indents_size *= 2;
            parser_state_tos->paren_indents =
                    xrealloc(parser_state_tos->paren_indents,
                             parser_state_tos->paren_indents_size *
                             sizeof(short));
        }

        ++parser_state_tos->paren_depth;
        parser_state_tos->paren_indents[parser_state_tos->p_l_follow -
                                        1] = e_code - s_code;
        if (settings.spaces_around_initializers)
            parser_state_tos->want_blank = true;
    }
    else if (parser_state_tos->block_init &&
             (parser_state_tos->block_init_level == 1))
    {
        /* Put a blank after the first '{' */

        parser_state_tos->want_blank = true;
    }
    else
    {
      /* what ? */
    }
}

/**
 *
 */

static void handle_token_rbrace(
    BOOLEAN        * force_nl,
    int            * dec_ind,
    exit_values_ty * file_exit_value,
    BOOLEAN        * pbreak_line)
{
    char tmpchar[2];

    /* semicolons can be omitted in declarations */
    if (((parser_state_tos->p_stack[parser_state_tos->tos] == decl) &&
         !parser_state_tos->block_init) ||
        /* ANSI C forbids label at end of compound statement, but we don't I guess :/ */
        (parser_state_tos->p_stack[parser_state_tos->tos] == casestmt))
    {
        if (parse (semicolon) != total_success)
        {
            *file_exit_value = indent_error;
        }
    }

    parser_state_tos->just_saw_decl = 0;
    parser_state_tos->ind_stmt = false;
    parser_state_tos->in_stmt  = false;
    parser_state_tos->block_init_level--;

    if ((parser_state_tos->block_init_level == 0)
        && (s_code != e_code))
    {
        /* Found closing brace of declaration initialisation, with
         * code on the same line before the brace */

        if (parser_state_tos->matching_brace_on_same_line < 0)
        {
            /* The matching '{' is not on the same line:
             * put the '}' on its own line. */

            dump_line (true, &paren_target, pbreak_line);
        }
        else
        {
            /* Put a space before the '}' */
            set_buf_break (bb_rbrace, paren_target);
            *(e_code++) = ' ';
        }
    }
    else if (parser_state_tos->block_init_level == 1
             && settings.spaces_around_initializers)
    {
             /* Put a space before the '}' */
            set_buf_break (bb_rbrace, paren_target);
            *(e_code++) = ' ';
    }

    *(e_code++) = '}';
    parser_state_tos->want_blank = true;

    if (parser_state_tos->block_init &&
        (parser_state_tos->block_init_level > 0))
    {
        /* We were treating this { } as normal ( ) */

        --parser_state_tos->paren_depth;

        if (--parser_state_tos->p_l_follow < 0)
        {
            parser_state_tos->p_l_follow = 0;
            tmpchar[0] = *token;
            tmpchar[1] = '\0';
            WARNING(_("Extra %s"), tmpchar, NULL);
        }
    }
    else if (parser_state_tos->dec_nest > 0)
    {
        /* we are in multi-level structure
         * declaration */

        *dec_ind = di_stack[--parser_state_tos->dec_nest];

        if ((parser_state_tos->dec_nest == 0) &&
            !parser_state_tos->in_parameter_declaration)
        {
            parser_state_tos->just_saw_decl = 2;
        }

        parser_state_tos->in_decl = true;
    }
    else
    {
      /* what ? */
    }

    prefix_blankline_requested = 0;
            
    if (parse (rbrace) != total_success) 
    {
        *file_exit_value = indent_error;
    }
            
    parser_state_tos->search_brace =
            (settings.cuddle_else &&
             (parser_state_tos->p_stack[parser_state_tos->tos] == ifhead)) ||
            (settings.cuddle_do_while &&
             (parser_state_tos->p_stack[parser_state_tos->tos] == dohead));

    if (parser_state_tos->p_stack[parser_state_tos->tos] == stmtl)
    {
        if ( (parser_state_tos->last_rw != rw_struct_like) &&
             (parser_state_tos->last_rw != rw_enum) &&
             (parser_state_tos->last_rw != rw_decl) )
        {
            *force_nl = true;
        }
#if 0
        else if (!settings.braces_on_struct_decl_line &&
                 (parser_state_tos->block_init != 1))
        {
            *force_nl = true;
        }
        else
        {
          /* what ? */
        }
#endif
    }

    if ( (parser_state_tos->p_stack[parser_state_tos->tos] == ifhead) ||
         ( (parser_state_tos->p_stack[parser_state_tos->tos] == dohead) &&
           !settings.cuddle_do_while && !settings.btype_2))
    {
        *force_nl = true;
    }

    if (!parser_state_tos->in_decl && (parser_state_tos->tos <= 0) &&
        settings.blanklines_after_procs && (parser_state_tos->dec_nest <= 0))
    {
        postfix_blankline_requested = 1;
        postfix_blankline_requested_code =
                parser_state_tos->in_decl ? decl : rbrace;
    }
}

/**
 *
 */

static void handle_token_swstmt(
    BOOLEAN        * sp_sw,
    codes_ty       * hd_type)
{
            
    *sp_sw = true;
    *hd_type = swstmt;       /* keep this for when we have seen the
                              * expression */
    parser_state_tos->in_decl = false;
}

/**
 *
 */

static void handle_token_sp_paren(
    BOOLEAN        * sp_sw,
    codes_ty       * hd_type)
{
    /* the interesting stuff is done after the expression is scanned */
    *sp_sw = true;

    /* remember the type of header for later use by parser */
    *hd_type =
            (*token == 'i' ? ifstmt : (*token == 'w' ? whilestmt : forstmt));
}

/**
 *
 */

static void handle_token_nparen(
    BOOLEAN        * force_nl,
    exit_values_ty * file_exit_value,
    BOOLEAN        * last_else,
    BOOLEAN        * pbreak_line)
{
    parser_state_tos->in_stmt = false;
    if (*token == 'e')
    {
        if (e_code != s_code && (!settings.cuddle_else || e_code[-1] != '}'))
        {
            if (settings.verbose)
            {
                WARNING(_("Line broken"), NULL, NULL);
            }
            
            dump_line (true, &paren_target, pbreak_line);       /* make sure this starts a line */
            parser_state_tos->want_blank = false;
        }
        
        /* This will be over ridden when next we read an `if' */
        
        *force_nl = true;    /* also, following stuff must go onto new
                              * line */
        *last_else = 1;

        if (parse (elselit) != total_success) 
        {
            *file_exit_value = indent_error;
        }
    }
    else
    {
        if (e_code != s_code)
        {
            /* make sure this starts a line */
            
            if (settings.verbose)
            {
                WARNING(_("Line broken"), NULL, NULL);
            }
            
            dump_line (true, &paren_target, pbreak_line);
            parser_state_tos->want_blank = false;
        }
        
        *force_nl = true;    /* also, following stuff must go onto new
                              * line */
        *last_else = 0;

        if (parse (dolit) != total_success) 
        {
            *file_exit_value = indent_error;
        }
    }
}

/**
 *
 */

static void handle_token_overloaded(
    const bb_code_ty can_break)
{
    char           * t_ptr;

    if (parser_state_tos->want_blank)
    {
        set_buf_break (bb_overloaded, paren_target);
        *(e_code++) = ' ';
    }
    else if (can_break)
    {
        set_buf_break (can_break, paren_target);
    }
    else
    {
      /* what ? */
    }

    parser_state_tos->want_blank = true;

    for (t_ptr = token; t_ptr < token_end; ++t_ptr)
    {
        check_code_size();
        *(e_code++) = *t_ptr;
    }

    *e_code = '\0'; /* null terminate code sect */
}

/**
 *
 */

static void handle_token_decl(
    int            * dec_ind,
    exit_values_ty * file_exit_value,
    BOOLEAN        * pbreak_line)
{
    /* handle C++ const function declarations like
     * const MediaDomainList PVR::get_itsMediaDomainList() const
     * {
     * return itsMediaDomainList;
     * }
     * by ignoring "const" just after a parameter list */

    if ((parser_state_tos->last_token == rparen) &&
        parser_state_tos->in_parameter_declaration &&
        parser_state_tos->saw_double_colon &&
        !strncmp (token, "const", 5))
    {
        set_buf_break (bb_const_qualifier, paren_target);
    }
    else
    {
        
        if (!parser_state_tos->sizeof_mask)
        {
            if (parse (decl) != total_success)
            {
                *file_exit_value = indent_error;
            }
        }
        
        if ((parser_state_tos->last_token == rparen) &&
            (parser_state_tos->tos <= 1))
        {
            parser_state_tos->in_parameter_declaration = 1;
            
            if (s_code != e_code)
            {
                dump_line (true, &paren_target, pbreak_line);
                parser_state_tos->want_blank = false;
            }
        }

        if (parser_state_tos->in_parameter_declaration &&
            (parser_state_tos->dec_nest == 0) &&
            (parser_state_tos->p_l_follow == 0))
        {
            parser_state_tos->ind_level = parser_state_tos->i_l_follow =
                    settings.indent_parameters;

            parser_state_tos->ind_stmt = false;
        }
        
        /* in_or_st set for struct or initialization decl. Don't set it if
         * we're in ansi prototype */
        
        if (!parser_state_tos->paren_depth)
        {
            parser_state_tos->in_or_st = 1;
        }
        
        if (!parser_state_tos->sizeof_mask)
        {
            parser_state_tos->in_decl      = true;
            parser_state_tos->decl_on_line = true;
            
            if (parser_state_tos->dec_nest <= 0)
            {
                parser_state_tos->just_saw_decl = 2;
            }
        }
        
#if 0
        /* Erik de Castro Lopo Sun, 28 Sep 2003:
         * I don't know what this is supposed to do, but I do know that it 
         * breaks the operation of the blanklines_after_procs setting in 
         * situations like this where a blank line is supposed to be inserted
         * between the two functions:
         *
         *     int func1 (void)
         *     {
         *         return 42 ;
         *     }
         *     static int func2 (void)
         *     {
         *         return 43 ;
         *     }
         *
         * If this code is removed, the regression tests still pass (except
         * for one which needs to be modified because a blank line is 
         * inserted as it should be.
         */

        if (prefix_blankline_requested &&
            ((parser_state_tos->block_init != 0) ||
             (parser_state_tos->block_init_level != -1) ||
             (parser_state_tos->last_token != rbrace) ||
             (e_code != s_code) || 
             (e_lab  != s_lab)  || 
             (e_com  != s_com)))
        {
            prefix_blankline_requested = 0;
        }
#endif 
        *dec_ind = settings.decl_indent > 0 ? settings.decl_indent :
                                              token_end - token + 1; /* get length of token plus 1 */
    }
}

/**
 *
 */

static void handle_token_ident(
    BOOLEAN        * force_nl,
    BOOLEAN        * sp_sw,
    codes_ty       * hd_type,
    int            * dec_ind,
    exit_values_ty * file_exit_value,
    const bb_code_ty can_break,
    BOOLEAN          is_procname_definition,
    BOOLEAN        * pbreak_line)
{
    /* If we are in a declaration, we must indent identifier. But not
     * inside the parentheses of an ANSI function declaration.  */

    if (parser_state_tos->in_decl &&
        (parser_state_tos->p_l_follow == 0) &&
        (parser_state_tos->last_token != rbrace))
    {
        if (parser_state_tos->want_blank)
        {
            set_buf_break (bb_ident, paren_target);
            *(e_code++) = ' ';
            *e_code = '\0'; /* null terminate code sect */
        }
        else if (can_break)
        {
            set_buf_break (can_break, paren_target);
        }
        else
        {
          /* what ? */
        }

        parser_state_tos->want_blank = false;

        if ((is_procname_definition == false) ||
            (!settings.procnames_start_line && (s_code != e_code)))
        {
            if (!parser_state_tos->block_init && !buf_break_used)
            {
                if (is_procname_definition)
                {
                    *dec_ind = 0;
                }

                while ((e_code - s_code) < *dec_ind)
                {
                    check_code_size();
                    set_buf_break (bb_dec_ind, paren_target);
                    *(e_code++) = ' ';
                }

                *e_code = '\0';     /* null terminate code sect */
                parser_state_tos->ind_stmt = false;
            }
        }
        else
        {
            if ((s_code != e_code) &&
                (parser_state_tos->last_token != doublecolon))
            {
                dump_line(true, &paren_target, pbreak_line);
            }

            *dec_ind = 0;
            parser_state_tos->want_blank = false;
        }
    }
    else if (*sp_sw && parser_state_tos->p_l_follow == 0)
    {
        *sp_sw = false;
        *force_nl = true;
        parser_state_tos->last_u_d = true;
        parser_state_tos->in_stmt = false;
                
        if (parse (*hd_type) != total_success) 
        {
            *file_exit_value = indent_error;
        }
    }
    else
    {
      /* what ? */
    }
}

/**
 *
 */

static void handle_token_struct_delim(void)
{
    char           * t_ptr;
    for (t_ptr = token; t_ptr < token_end; ++t_ptr)
    {
        check_code_size();
        *(e_code++) = *t_ptr;
    }

    parser_state_tos->want_blank = false;   /* dont put a blank after a
                                             * period */
    parser_state_tos->can_break = bb_struct_delim;
}

/**
 *
 */

static void handle_token_comma(
    BOOLEAN        * force_nl,
    int            * dec_ind,
    BOOLEAN          is_procname_definition)
{
    parser_state_tos->want_blank = true;

    if ((parser_state_tos->paren_depth == 0) &&
        parser_state_tos->in_decl &&
        !buf_break_used && (is_procname_definition == false) &&
        !parser_state_tos->block_init)
    {
        while ((e_code - s_code) < (*dec_ind - 1))
        {
            check_code_size();
            set_buf_break (bb_dec_ind, paren_target);
            *(e_code++) = ' ';
        }

        parser_state_tos->ind_stmt = false;
    }

    *(e_code++) = ',';

    if (parser_state_tos->p_l_follow == 0)
    {
        if (parser_state_tos->block_init_level <= 0)
        {
            parser_state_tos->block_init = 0;
        }

        /* If we are in a declaration, and either the user wants all
         * comma'd declarations broken, or the line is getting too
         * long, break the line.  */

        if (break_comma && !settings.leave_comma)
        {
            *force_nl = true;
        }
    }

    if (parser_state_tos->block_init)
    {
        parser_state_tos->in_stmt = false;  /* Don't indent after comma */
    }

    /* For declarations, if user wants all fn decls broken, force that
     * now. */

    if (settings.break_function_decl_args &&
        (!parser_state_tos->in_or_st &&
         parser_state_tos->in_stmt && parser_state_tos->in_decl))
    {
        *force_nl = true;
    }

}

/**
 *
 */


static void handle_token_preesc(
    exit_values_ty * file_exit_value,
    BOOLEAN        * pbreak_line)
{
    char * t_ptr;
    char * p;

    if ((s_com != e_com) || (s_lab != e_lab) || (s_code != e_code))
    {
        dump_line(true, &paren_target, pbreak_line);
    }

    {
        int in_comment = 0;
        int in_cplus_comment = 0;
        int com_start = 0;
        char quote = 0;
        int com_end = 0;

        /* ANSI allows spaces between '#' and preprocessor directives.
         * If the user specified "-lps" and there are such spaces,
         * they will be part of `token', otherwise `token' is just
         * '#'. */

        for (t_ptr = token; t_ptr < token_end; ++t_ptr)
        {
            check_lab_size();
            *e_lab++ = *t_ptr;
        }

        while (!had_eof && (*buf_ptr != EOL || in_comment))
        {
            check_lab_size();
            *e_lab = *buf_ptr++;

            if (buf_ptr >= buf_end)
            {
                fill_buffer();
            }

            switch (*e_lab++)
            {
            case BACKSLASH:
                if (!in_comment && !in_cplus_comment)
                {
                    *e_lab++ = *buf_ptr++;
                    if (buf_ptr >= buf_end)
                    {
                        fill_buffer();
                    }
                }
                break;

            case '/':
                if (((*buf_ptr == '*') ||
                     (*buf_ptr == '/')) &&
                    !in_comment && !in_cplus_comment && !quote)
                {
                    save_com.column = current_column () - 1;

                    if (*buf_ptr == '/')
                    {
                        in_cplus_comment = 1;
                    }
                    else
                    {
                        in_comment = 1;
                    }

                    *e_lab++ = *buf_ptr++;
                    com_start = e_lab - s_lab - 2;

                    /* Store the column that corresponds with the start
                     * of the buffer */

                    if (save_com.ptr == save_com.end)
                    {
                        save_com.start_column = current_column () - 2;
                    }
                }
                break;

            case '"':
            case '\'':
                if (!quote)
                {
                    quote = e_lab[-1];
                }
                else if (e_lab[-1] == quote)
                {
                    quote = 0;
                }
                else
                {
                  /* what ? */
                }

                break;

            case '*':
                if (*buf_ptr == '/' && in_comment)
                {
                    in_comment = 0;
                    *e_lab++ = *buf_ptr++;
                    com_end = e_lab - s_lab;
                }
                break;
            }
        }

        while (e_lab > s_lab && (e_lab[-1] == ' ' || e_lab[-1] == TAB))
        {
            e_lab--;
        }


        if (in_cplus_comment)   /* Should we also check in_comment? -jla */
        {
            in_cplus_comment = 0;
            *e_lab++ = *buf_ptr++;
            com_end = e_lab - s_lab;
        }

        if (e_lab - s_lab == com_end && bp_save == 0)
        {
            /* comment on preprocessor line */

            if (save_com.end != save_com.ptr)
            {
                need_chars (&save_com, 2);
                *save_com.end++ = EOL;  /* add newline between
                                         * comments */
                *save_com.end++ = ' ';
                save_com.len += 2;
                --line_no;
            }

            need_chars (&save_com, com_end - com_start + 1);
            strncpy (save_com.end, s_lab + com_start,
                     com_end - com_start);
            save_com.end[com_end - com_start] = '\0';
            save_com.end += com_end - com_start;
            save_com.len += com_end - com_start;

            e_lab = s_lab + com_start;

            while ((e_lab > s_lab) &&
                   ((e_lab[-1] == ' ') || (e_lab[-1] == TAB)))
            {
                e_lab--;
            }


            /* Switch input buffers so that calls to lexi() will
             * read from our save buffer. */

            bp_save = buf_ptr;
            be_save = buf_end;
            buf_ptr = save_com.ptr;
            need_chars (&save_com, 1);
            buf_end = save_com.end;
            save_com.end = save_com.ptr;        /* make save_com empty */
        }

        *e_lab = '\0';  /* null terminate line */
        parser_state_tos->pcase = false;
    }

    p = s_lab + 1;

    p = skip_horiz_space(p);

    if (strncmp (p, "if", 2) == 0)
    {
        if (settings.blanklines_around_conditional_compilation)
        {
            prefix_blankline_requested++;
            prefix_blankline_requested_code = preesc;

            while (*in_prog_pos++ == EOL)
            {
            }

            in_prog_pos--;
        }

        {
            /* Push a copy of the parser_state onto the stack. All
             * manipulations will use the copy at the top of stack, and
             * then we can return to the previous state by popping the
             * stack.  */

            parser_state_ty *new;

            new = xmalloc(sizeof(parser_state_ty));
            memcpy(new, parser_state_tos, sizeof(parser_state_ty));

            /* We need to copy the dynamically allocated arrays in the
             * struct parser_state too.  */

            new->p_stack = xmalloc(parser_state_tos->p_stack_size *
                                   sizeof(codes_ty));
            memcpy(new->p_stack, parser_state_tos->p_stack,
                   (parser_state_tos->p_stack_size * sizeof(codes_ty)));

            new->il = xmalloc(parser_state_tos->p_stack_size *
                              sizeof (int));
            memcpy(new->il, parser_state_tos->il,
                   parser_state_tos->p_stack_size * sizeof(int));

            new->cstk = xmalloc(parser_state_tos->p_stack_size * sizeof(int));
            memcpy(new->cstk, parser_state_tos->cstk,
                   parser_state_tos->p_stack_size * sizeof(int));

            new->paren_indents = xmalloc(parser_state_tos->paren_indents_size *
                                         sizeof (short));
            memcpy(new->paren_indents,parser_state_tos->paren_indents,
                   (parser_state_tos->paren_indents_size * sizeof(short)));

            new->next = parser_state_tos;
            parser_state_tos = new;
            /* GDB_HOOK_parser_state_tos */
        }
    }
    else if ((strncmp (p, "else", 4) == 0) ||
             (strncmp (p, "elif", 4) == 0))
    {
        /* When we get #else, we want to restore the parser state to
         * what it was before the matching #if, so that things get
         * lined up with the code before the #if.  However, we do not
         * want to pop the stack; we just want to copy the second to
         * top elt of the stack because when we encounter the #endif,
         * it will pop the stack.  */

        else_or_endif = (strncmp (p, "else", 4) == 0);
        prefix_blankline_requested = 0;

        if (parser_state_tos->next)
        {
            /* First save the addresses of the arrays for the top of
             * stack.  */

            codes_ty * tos_p_stack       = parser_state_tos->p_stack;
            int      * tos_il            = parser_state_tos->il;
            int      * tos_cstk          = parser_state_tos->cstk;
            short    * tos_paren_indents =
                    parser_state_tos->paren_indents;
            parser_state_ty * second = parser_state_tos->next;

            (void) memcpy (parser_state_tos, second,
                           sizeof (parser_state_ty));
            parser_state_tos->next = second;

            /* Now copy the arrays from the second to top of stack to
             * the top of stack.  */

            /* Since the p_stack, etc. arrays only grow, never shrink,
             * we know that they will be big enough to fit the array
             * from the second to top of stack.  */

            parser_state_tos->p_stack = tos_p_stack;
            (void) memcpy (parser_state_tos->p_stack,
                           parser_state_tos->next->p_stack,
                           parser_state_tos->p_stack_size *
                           sizeof (codes_ty));

            parser_state_tos->il = tos_il;
            (void) memcpy (parser_state_tos->il,
                           parser_state_tos->next->il,
                           (parser_state_tos->p_stack_size *
                            sizeof (int)));

            parser_state_tos->cstk = tos_cstk;
            (void) memcpy (parser_state_tos->cstk,
                           parser_state_tos->next->cstk,
                           (parser_state_tos->p_stack_size *
                            sizeof (int)));

            parser_state_tos->paren_indents = tos_paren_indents;
            (void) memcpy (parser_state_tos->paren_indents,
                           parser_state_tos->next->paren_indents,
                           (parser_state_tos->paren_indents_size *
                            sizeof (short)));
        }
        else
        {
            ERROR (else_or_endif ? _("Unmatched #else") :
                   _("Unmatched #elif"), 0, 0);
            *file_exit_value = indent_error;
        }
    }
    else if (strncmp (p, "endif", 5) == 0)
    {
        else_or_endif = true;
        prefix_blankline_requested = 0;
        /* We want to remove the second to top elt on the stack, which
         * was put there by #if and was used to restore the stack at
         * the #else (if there was one). We want to leave the top of
         * stack unmolested so that the state which we have been using
         * is unchanged.  */

        if (parser_state_tos->next)
        {
            parser_state_ty *second = parser_state_tos->next;

            parser_state_tos->next = second->next;
            xfree(second->p_stack);
            xfree(second->il);
            xfree(second->cstk);
            xfree(second->paren_indents);
            xfree(second);
        }
        else
        {
            ERROR (_("Unmatched #endif"), 0, 0);
            *file_exit_value = indent_error;
        }

        if (settings.blanklines_around_conditional_compilation)
        {
            postfix_blankline_requested++;
            postfix_blankline_requested_code = preesc;
            n_real_blanklines = 0;
        }
    }
    else
    {
      /* what ? */
    }

    /* Don't put a blank line after declarations if they are directly
     * followed by an #else or #endif -Run */

    if (else_or_endif && prefix_blankline_requested_code == decl)
    {
        prefix_blankline_requested = 0;
    }

    /* Normally, subsequent processing of the newline character
     * causes the line to be printed.  The following clause handles
     * a special case (comma-separated declarations separated
     * by the preprocessor lines) where this doesn't happen. */

    if ((parser_state_tos->last_token == comma) &&
        (parser_state_tos->p_l_follow <= 0) &&
        settings.leave_comma &&
        !parser_state_tos->block_init &&
        break_comma && (s_com == e_com))
    {
        dump_line(true, &paren_target, pbreak_line);
        parser_state_tos->want_blank = false;
    }

}

/**
 *
 */


static void handle_token_comment(
    BOOLEAN        * force_nl,
    BOOLEAN        * flushed_nl,
    BOOLEAN        * pbreak_line)
{
            if (parser_state_tos->last_saw_nl && (s_code != e_code))
            {
                *flushed_nl = false;
                dump_line(true, &paren_target, pbreak_line);
                parser_state_tos->want_blank = false;
                *force_nl = false;
            }
            print_comment (&paren_target, pbreak_line);
}

/**
 *
 */


static void handle_token_attribute(void)
{
    char           * t_ptr;
    
    if (s_code != e_code)
    {
        set_buf_break (bb_attribute, paren_target);
        *(e_code++) = ' ';
    }

    for (t_ptr = token; t_ptr < token_end; ++t_ptr)
    {
        check_code_size();
        *(e_code++) = *t_ptr;
    }

    parser_state_tos->in_decl = false;
    parser_state_tos->want_blank = settings.blank_after_sizeof;
}

/**
 *
 */


extern void handle_the_token(
    const codes_ty   type_code,
    BOOLEAN        * scase,
    BOOLEAN        * force_nl,
    BOOLEAN        * sp_sw,
    BOOLEAN        * flushed_nl,
    codes_ty       * hd_type,
    int            * dec_ind,
    BOOLEAN        * last_token_ends_sp,
    exit_values_ty * file_exit_value,
    const bb_code_ty can_break,
    BOOLEAN        * last_else,
    BOOLEAN          is_procname_definition,
    BOOLEAN        * pbreak_line)
{
    switch (type_code)
    {
    case form_feed:     /* found a form feed in line */
       handle_token_form_feed(pbreak_line);
       break;

    case newline:
       handle_token_newline(force_nl, pbreak_line);
       break;

    case lparen:
       handle_token_lparen(force_nl, sp_sw, dec_ind, pbreak_line);
       break;

    case rparen:
       handle_token_rparen(force_nl, sp_sw, hd_type, last_token_ends_sp,
                           file_exit_value, pbreak_line);
       break;

    case unary_op:
      /* this could be any unary operation */
       handle_token_unary_op( dec_ind, can_break);
       break;

    case binary_op:
      /* any binary operation */
       handle_token_binary_op(can_break);
       break;

    case postop:
      /* got a trailing ++ or -- */
       handle_token_postop();
       break;

    case question:
      /* got a ? */
       handle_token_question(can_break);
       break;

    case casestmt:
      /* got word 'case' or 'default' */
       handle_token_casestmt(scase, file_exit_value);
       copy_id(type_code, force_nl, file_exit_value,
               can_break);
       break;
            
    case colon:
      /* got a ':' */
       handle_token_colon(scase, force_nl, dec_ind, can_break,
                          pbreak_line);
       break;

    case doublecolon:
      /* Deal with C++ Class::Method */
       handle_token_doublecolon();
       break;

    case semicolon:
      /* we are not in an initialization or structure declaration */
       handle_token_semicolon(scase, force_nl, sp_sw, dec_ind,
                              last_token_ends_sp, file_exit_value);
       break;

    case lbrace:
      /* got a '{' */
       handle_token_lbrace(force_nl, dec_ind, file_exit_value,
                           pbreak_line);
       break;

    case rbrace:
      /* got a '}' */
       handle_token_rbrace(force_nl, dec_ind, file_exit_value,
                           pbreak_line);
            
       break;

    case swstmt:
      /* got keyword "switch" */
       handle_token_swstmt(sp_sw, hd_type);
       copy_id(type_code, force_nl, file_exit_value, can_break);
       break;
            
    case sp_paren:
      /* token is if, while, for */
       handle_token_sp_paren(sp_sw,  hd_type);
       copy_id(type_code, force_nl, file_exit_value, can_break);
       break;
            
    case sp_else:
      /* got else */
    case sp_nparen:
      /* got do */
       handle_token_nparen(force_nl, file_exit_value, last_else,
                           pbreak_line);
       copy_id(type_code, force_nl, file_exit_value, can_break);
       break;
            
    case overloaded:
      /* Handle C++ operator overloading like:
       *
       * Class foo::operator = ()"
       *
       * This is just like a decl, but we need to remember this
       * token type. */
            
       handle_token_overloaded(can_break);
       break;

    case decl:
      /* we have a declaration type (int, register, etc.) */

       handle_token_decl(dec_ind, file_exit_value,
                         pbreak_line);
            
       copy_id(type_code, force_nl, file_exit_value, can_break);
       break;
            
    case cpp_operator:
      /* Handle C++ operator overloading.  See case overloaded above. */
    case ident:
      /* got an identifier or constant */
       handle_token_ident(force_nl,  sp_sw, hd_type,
                          dec_ind, file_exit_value,
                          can_break, is_procname_definition,
                          pbreak_line);
            
       copy_id(type_code, force_nl, file_exit_value, can_break);
            
       break;

    case struct_delim:
       handle_token_struct_delim();
       break;

    case comma:
       handle_token_comma(force_nl, dec_ind,
                          is_procname_definition);
       break;

    case preesc:
      /* got the character '#' */
       handle_token_preesc(file_exit_value,
                           pbreak_line);
       break;

    case comment:
    case cplus_comment:
      /* A C or C++ comment. */
       handle_token_comment(force_nl, flushed_nl,
                            pbreak_line);
       break;

      /* An __attribute__ qualifier */
    case attribute:
       handle_token_attribute();
       break;

    default:
       abort ();
    }                       /* end of big switch stmt */
}




