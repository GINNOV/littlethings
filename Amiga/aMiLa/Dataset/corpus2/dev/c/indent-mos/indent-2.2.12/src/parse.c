/** \file
 * Copyright (c) 1999, 2000 Carlo Wood.  All rights reserved.<br>
 * Copyright (c) 1994 Joseph Arceneaux.  All rights reserved.<br>
 * Copyright (c) 1985 Sun Microsystems, Inc. <br>
 * Copyright (c) 1980 The Regents of the University of California.<br>
 * Copyright (c) 1976 Board of Trustees of the University of Illinois. All rights reserved.<br>
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
 */

#include "sys.h"
#include "indent.h"
#include "parse.h"
#include "globs.h"

RCSTAG_CC ("$Id$");

parser_state_ty *parser_state_tos = NULL;

#define INITIAL_BUFFER_SIZE 1000
#define INITIAL_STACK_SIZE 2

/**
 *
 */

extern void init_parser(void)
{
    parser_state_tos = xmalloc(sizeof (parser_state_ty));

    /* GDB_HOOK_parser_state_tos */
    parser_state_tos->p_stack_size  = INITIAL_STACK_SIZE;
    parser_state_tos->p_stack       = xmalloc(INITIAL_STACK_SIZE * sizeof (codes_ty));
    parser_state_tos->il            = xmalloc(INITIAL_STACK_SIZE * sizeof (int));
    parser_state_tos->cstk          = xmalloc(INITIAL_STACK_SIZE * sizeof (int));
    parser_state_tos->paren_indents_size = 8;
    parser_state_tos->paren_indents = xmalloc(parser_state_tos->paren_indents_size * sizeof (short));

    /* Although these are supposed to grow if we reach the end,
     * I can find no place in the code which does this. */
    combuf = xmalloc(INITIAL_BUFFER_SIZE);
    labbuf = xmalloc(INITIAL_BUFFER_SIZE);
    codebuf = xmalloc(INITIAL_BUFFER_SIZE);

    save_com.size = INITIAL_BUFFER_SIZE;
    save_com.end = save_com.ptr = xmalloc(save_com.size);
    save_com.len = save_com.column = 0;

    di_stack_alloc = 2;
    di_stack = xmalloc(di_stack_alloc * sizeof (*di_stack));
}

/**
 * Free all memory allocated in init_parser().
 */
extern void uninit_parser(void)
{
    if (!parser_state_tos)
    {
        return;
    }

    xfree(parser_state_tos->p_stack);
    xfree(parser_state_tos->il);
    xfree(parser_state_tos->cstk);
    xfree(parser_state_tos->paren_indents);
    xfree(parser_state_tos);
    xfree(save_com.ptr);
    xfree(combuf);
    xfree(labbuf);
    xfree(codebuf);
    xfree(di_stack);
    parser_state_tos = NULL;
}

/**
 *
 */

extern void reset_parser(void)
{
    parser_state_tos->next             = 0;
    parser_state_tos->tos              = 0;
    parser_state_tos->p_stack[0]       = stmt;    /*!< this is the parser's stack */
    parser_state_tos->last_nl          = true;    /*!< this is true if the last thing
                                                   * scanned was a newline */
    parser_state_tos->last_token       = start_token;
    parser_state_tos->last_saw_nl      = false;
    parser_state_tos->broken_at_non_nl = false;
    parser_state_tos->box_com          = false;
    parser_state_tos->cast_mask        = 0;
    parser_state_tos->noncast_mask     = 0;
    parser_state_tos->sizeof_mask      = 0;
    parser_state_tos->block_init       = 0;
    parser_state_tos->block_init_level = 0;
    parser_state_tos->col_1            = false;
    parser_state_tos->com_col          = 0;
    parser_state_tos->dec_nest         = 0;
    parser_state_tos->i_l_follow       = 0;
    parser_state_tos->ind_level        = 0;
    parser_state_tos->last_u_d         = false;
    parser_state_tos->p_l_follow       = 0;
    parser_state_tos->paren_level      = 0;
    parser_state_tos->paren_depth      = 0;
    parser_state_tos->search_brace     = false;
    parser_state_tos->use_ff           = false;
    parser_state_tos->its_a_keyword    = false;
    parser_state_tos->sizeof_keyword   = false;
    parser_state_tos->in_parameter_declaration = false;
    parser_state_tos->just_saw_decl    = 0;
    parser_state_tos->in_decl          = false;
    parser_state_tos->decl_on_line     = false;
    parser_state_tos->in_or_st         = 0;
    parser_state_tos->want_blank       = false;
    parser_state_tos->in_stmt          = false;
    parser_state_tos->ind_stmt         = false;
    parser_state_tos->procname         = "\0";
    parser_state_tos->procname_end     = "\0";
    parser_state_tos->classname        = "\0";
    parser_state_tos->classname_end    = "\0";
    parser_state_tos->pcase            = false;
    parser_state_tos->dec_nest         = 0;
    parser_state_tos->can_break        = bb_none;
    parser_state_tos->saw_double_colon = false;
    parser_state_tos->is_func_ptr_decl = false;

    parser_state_tos->il[0]            = 0;
    parser_state_tos->cstk[0]          = 0;

    save_com.len = save_com.column = 0;

    di_stack[parser_state_tos->dec_nest] = 0;

    l_com = combuf + INITIAL_BUFFER_SIZE - 5;
    l_lab = labbuf + INITIAL_BUFFER_SIZE - 5;
    l_code = codebuf + INITIAL_BUFFER_SIZE - 5;
    combuf[0] = codebuf[0] = labbuf[0] = ' ';
    combuf[1] = codebuf[1] = labbuf[1] = '\0';

    else_or_endif = false;
    s_lab = e_lab = labbuf + 1;
    s_code = e_code = codebuf + 1;
    s_com = e_com = combuf + 1;

    line_no = 1;
    had_eof = false;
    break_comma = false;
    bp_save = 0;
    be_save = 0;

    if (settings.tabsize <= 0)
    {
        settings.tabsize = 1;
    }

    prefix_blankline_requested = 0;
}

/**
 * like ++parser_state_tos->tos but checks for stack overflow and extends
 * stack if necessary.
  */

extern int inc_pstack(void)
{
    if (++parser_state_tos->tos >= parser_state_tos->p_stack_size)
    {
        parser_state_tos->p_stack_size *= 2;
        parser_state_tos->p_stack =
                xrealloc(parser_state_tos->p_stack,
                         parser_state_tos->p_stack_size * sizeof(codes_ty));
        parser_state_tos->il =
                xrealloc(parser_state_tos->il,
                          parser_state_tos->p_stack_size * sizeof(int));
        parser_state_tos->cstk =
                xrealloc(parser_state_tos->cstk,
                         parser_state_tos->p_stack_size * sizeof(int));
    }

    parser_state_tos->cstk[parser_state_tos->tos] = parser_state_tos->cstk[parser_state_tos->tos - 1];
    return parser_state_tos->tos;
}

#ifdef DEBUG
/**
 *
 */

static char **debug_symbol_strings;

/**
 *
 */

extern void debug_init(void)
{
    int size = ((int) number_of_codes) * sizeof (char *);

    debug_symbol_strings = xmalloc (size);

    debug_symbol_strings[code_eof]      = "code_eof";
    debug_symbol_strings[newline]       = "newline";
    debug_symbol_strings[lparen]        = "lparen";
    debug_symbol_strings[rparen]        = "rparen";
    debug_symbol_strings[start_token]   = "start_token";
    debug_symbol_strings[unary_op]      = "unary_op";
    debug_symbol_strings[binary_op]     = "binary_op";
    debug_symbol_strings[postop]        = "postop";
    debug_symbol_strings[question]      = "question";
    debug_symbol_strings[casestmt]      = "casestmt";
    debug_symbol_strings[colon]         = "colon";
    debug_symbol_strings[doublecolon]   = "doublecolon";
    debug_symbol_strings[semicolon]     = "semicolon";
    debug_symbol_strings[lbrace]        = "lbrace";
    debug_symbol_strings[rbrace]        = "rbrace";
    debug_symbol_strings[ident]         = "ident";
    debug_symbol_strings[overloaded]    = "overloaded";
    debug_symbol_strings[cpp_operator]  = "cpp_operator";
    debug_symbol_strings[comma]         = "comma";
    debug_symbol_strings[comment]       = "comment";
    debug_symbol_strings[cplus_comment] = "cplus_comment";
    debug_symbol_strings[swstmt]        = "swstmt";
    debug_symbol_strings[preesc]        = "preesc";
    debug_symbol_strings[form_feed]     = "form_feed";
    debug_symbol_strings[decl]          = "decl";
    debug_symbol_strings[sp_paren]      = "sp_paren";
    debug_symbol_strings[sp_nparen]     = "sp_nparen";
    debug_symbol_strings[sp_else]       = "sp_else";
    debug_symbol_strings[ifstmt]        = "ifstmt";
    debug_symbol_strings[elseifstmt]    = "elseifstmt";
    debug_symbol_strings[whilestmt]     = "whilestmt";
    debug_symbol_strings[forstmt]       = "forstmt";
    debug_symbol_strings[stmt]          = "stmt";
    debug_symbol_strings[stmtl]         = "stmtl";
    debug_symbol_strings[elselit]       = "elselit";
    debug_symbol_strings[dolit]         = "dolit";
    debug_symbol_strings[dohead]        = "dohead";
    debug_symbol_strings[dostmt]        = "dostmt";
    debug_symbol_strings[ifhead]        = "ifhead";
    debug_symbol_strings[elsehead]      = "elsehead";
    debug_symbol_strings[struct_delim]  = "struct_delim";
    debug_symbol_strings[attribute]     = "attribute";
}

#endif

/**
 *
 */

extern exit_values_ty parse (
   codes_ty tk)               /*!< the code for the construct scanned */
{
    int i;

#ifdef DEBUG
    if (debug)
    {
        if (tk >= code_eof && tk < number_of_codes)
        {
            printf ("Parse: %s\n", debug_symbol_strings[tk]);
        }
        else
        {
            printf ("Parse: Unknown code: %d for %s\n", (int) tk, token ? token : "NULL");
        }
    }
#endif

    while ((parser_state_tos->p_stack[parser_state_tos->tos] == ifhead) &&
           (tk != elselit))
    {
        /* true if we have an if without an else */

        /* apply the if(..) stmt ::= stmt reduction */

        parser_state_tos->p_stack[parser_state_tos->tos] = stmt;
        reduce ();              /* see if this allows any reduction */
    }


    switch (tk)
    {
        /* go on and figure out what to do with the input */

        case decl:
            /* scanned a declaration word */
            parser_state_tos->search_brace = settings.braces_on_struct_decl_line;

            /* indicate that following brace should be on same line */

            if ((parser_state_tos->p_stack[parser_state_tos->tos] != decl) &&
                (parser_state_tos->block_init == 0))
            {
                /* only put one declaration onto stack */

                break_comma = true;     /* while in declaration, newline should be
                                         * forced after comma */
                inc_pstack ();
                parser_state_tos->p_stack[parser_state_tos->tos] = decl;
                parser_state_tos->il[parser_state_tos->tos] = parser_state_tos->i_l_follow;

                if (settings.ljust_decl)
                {                       /* only do if we want left justified
                                         * declarations */
                    parser_state_tos->ind_level = 0;
                    for (i = parser_state_tos->tos - 1; i > 0; --i)
                    {
                        if (parser_state_tos->p_stack[i] == decl)
                        {
                            /* indentation is number of declaration levels deep we are
                             * times spaces per level */
                            parser_state_tos->ind_level += settings.ind_size;
                        }
                    }

                    parser_state_tos->i_l_follow = parser_state_tos->ind_level;
                }
            }
            break;

        case ifstmt:            /* scanned if (...) */
            if (parser_state_tos->p_stack[parser_state_tos->tos] == elsehead)
            {
                parser_state_tos->i_l_follow = parser_state_tos->il[parser_state_tos->tos];
            }
            /* falls through */

        case dolit:             /* 'do' */
        case forstmt:           /* for (...) */
        case casestmt:          /* case n: */
            inc_pstack ();
            parser_state_tos->p_stack[parser_state_tos->tos] = tk;
            parser_state_tos->ind_level                 = parser_state_tos->i_l_follow;
            parser_state_tos->il[parser_state_tos->tos] = parser_state_tos->ind_level;

            if (tk != casestmt)
            {
                parser_state_tos->i_l_follow += settings.ind_size;       /* subsequent statements
                                                                 * should be indented */
            }

            parser_state_tos->search_brace = settings.btype_2;
            break;

        case lbrace:            /* scanned { */
            break_comma = false;        /* don't break comma in an initial list */
            if (parser_state_tos->p_stack[parser_state_tos->tos] == stmt
                || parser_state_tos->p_stack[parser_state_tos->tos] == stmtl)
            {
                /* it is a random, isolated stmt group or a declaration */
                parser_state_tos->i_l_follow += settings.ind_size;
            }
            else if (parser_state_tos->p_stack[parser_state_tos->tos] == decl)
            {
                parser_state_tos->i_l_follow += settings.ind_size;

                if ( ( (parser_state_tos->last_rw == rw_struct_like) ||
                       (parser_state_tos->last_rw == rw_enum)) &&
                     ( (parser_state_tos->block_init != 1) ||
                       (parser_state_tos->block_init_level == 0)) &&
                     (parser_state_tos->last_token != rparen) &&
                     (!settings.braces_on_struct_decl_line))
                {
                    parser_state_tos->ind_level += settings.struct_brace_indent;
                    parser_state_tos->i_l_follow += settings.struct_brace_indent;
                }
            }
            else if (parser_state_tos->p_stack[parser_state_tos->tos] == casestmt)
            {
                parser_state_tos->ind_level += settings.case_brace_indent - settings.ind_size;
                parser_state_tos->i_l_follow += settings.case_brace_indent;
            }
            else
            {
                /* It is a group as part of a while, for, etc. */

                /* Only do this if there is nothing on the line */
                if (s_code == e_code)
                {
                    parser_state_tos->ind_level -= settings.ind_size;
                }

                /* For -bl formatting, indent by settings.brace_indent additional spaces
                 * e.g. if (foo == bar) { <--> settings.brace_indent spaces (in this
                 * example, 4) */

                if (!settings.btype_2)
                {
                    parser_state_tos->ind_level += settings.brace_indent;
                    parser_state_tos->i_l_follow += settings.brace_indent;
                }

                if (parser_state_tos->p_stack[parser_state_tos->tos] == swstmt)
                {
                    parser_state_tos->i_l_follow += settings.case_indent;
                }
            }

            inc_pstack ();
            parser_state_tos->p_stack[parser_state_tos->tos] = lbrace;
            parser_state_tos->il[parser_state_tos->tos] = parser_state_tos->ind_level;

            inc_pstack ();
            parser_state_tos->p_stack[parser_state_tos->tos] = stmt;

            /* allow null stmt between braces */

            parser_state_tos->il[parser_state_tos->tos] = parser_state_tos->i_l_follow;
            break;

        case whilestmt:         /* scanned while (...) */
            if (parser_state_tos->p_stack[parser_state_tos->tos] == dohead)
            {
                /* it is matched with do stmt */
                parser_state_tos->i_l_follow = parser_state_tos->il[parser_state_tos->tos];
                parser_state_tos->ind_level   = parser_state_tos->il[parser_state_tos->tos];
                inc_pstack ();
                parser_state_tos->p_stack[parser_state_tos->tos] = whilestmt;

                parser_state_tos->ind_level                 = parser_state_tos->i_l_follow;
                parser_state_tos->il[parser_state_tos->tos] = parser_state_tos->i_l_follow;
            }
            else
            {                   /* it is a while loop */
                inc_pstack ();
                parser_state_tos->p_stack[parser_state_tos->tos] = whilestmt;
                parser_state_tos->il[parser_state_tos->tos] = parser_state_tos->i_l_follow;
                parser_state_tos->i_l_follow += settings.ind_size;
                parser_state_tos->search_brace = settings.btype_2;
            }

            break;

        case elselit:           /* scanned an else */

            if (parser_state_tos->p_stack[parser_state_tos->tos] != ifhead)
            {
                ERROR(_("Unmatched 'else'"), NULL, NULL);
            }
            else
            {
                /* indentation for else should be same as for if */
                parser_state_tos->ind_level = parser_state_tos->il[parser_state_tos->tos];

                /* everything following should be in 1 level */
                parser_state_tos->i_l_follow = (parser_state_tos->ind_level + settings.ind_size);

                parser_state_tos->p_stack[parser_state_tos->tos] = elsehead;
                /* remember if with else */
                parser_state_tos->search_brace = true;
            }
            break;

        case rbrace:            /* scanned a } */
            /* stack should have <lbrace> <stmt> or <lbrace> <stmtl> */
            if ((parser_state_tos->tos > 0) && (parser_state_tos->p_stack[parser_state_tos->tos - 1] == lbrace))
            {
                parser_state_tos->i_l_follow = parser_state_tos->il[--parser_state_tos->tos];
                parser_state_tos->ind_level  = parser_state_tos->i_l_follow;
                parser_state_tos->p_stack[parser_state_tos->tos] = stmt;
            }
            else
            {
                ERROR(_("Stmt nesting error."), NULL, NULL);
            }
            break;

        case swstmt:            /* had switch (...) */
            inc_pstack ();
            parser_state_tos->p_stack[parser_state_tos->tos] = swstmt;
            parser_state_tos->cstk[parser_state_tos->tos] = settings.case_indent + parser_state_tos->i_l_follow;
            if (!settings.btype_2)
            {
                parser_state_tos->cstk[parser_state_tos->tos] += settings.brace_indent;
            }

            /* save current case indent level */
            parser_state_tos->il[parser_state_tos->tos] = parser_state_tos->i_l_follow;

            /* case labels should be one level down from switch, plus
             * `settings.case_indent' if any.  Then, statements should be the `settings.ind_size'
             * further. */

            parser_state_tos->i_l_follow += settings.ind_size;
            parser_state_tos->search_brace = settings.btype_2;
            break;

        case semicolon:         /* this indicates a simple stmt */
            break_comma = false;        /* turn off flag to break after commas in a
                                         * declaration */

            if (parser_state_tos->p_stack[parser_state_tos->tos] == dostmt)
            {
                parser_state_tos->p_stack[parser_state_tos->tos] = stmt;
            }
            else
            {
                inc_pstack ();
                parser_state_tos->p_stack[parser_state_tos->tos] = stmt;
                parser_state_tos->il[parser_state_tos->tos] = parser_state_tos->ind_level;
            }
            break;

            /* This is a fatal error which cases the program to exit. */
        default:
            fatal (_("Unknown code to parser"), 0);
    }

    reduce ();                  /* see if any reduction can be done */

#ifdef DEBUG
    if (debug)
    {
        printf ("\n");

        printf ("ParseStack [%d]:\n", (int) parser_state_tos->p_stack_size);

        for (i = 1; i <= parser_state_tos->tos; ++i)
        {
            printf ("  stack[%d] =>  stack: %d [%-10s]  ind_level: %d\n",
                    (int)i, (int)parser_state_tos->p_stack[i],
                    debug_symbol_strings[parser_state_tos->p_stack[i]],
                    (int)parser_state_tos->il[i]);
        }

        printf ("\n");
    }
#endif

    return total_success;
}

/**
 * NAME: reduce
 *
 * FUNCTION: Implements the reduce part of the parsing algorithm
 *
 * ALGORITHM: The following reductions are done.  Reductions are repeated until
 *  no more are possible.
 *
 *  Old TOS              New TOS [stmt] [stmt]           [stmtl] [stmtl] [stmt]
 *     [stmtl] do [stmt]                 dohead [dohead] [whilestmt]
 *     [dostmt] if [stmt]                "ifstmt" switch [stmt]          [stmt]
 *     decl [stmt]               [stmt] "ifelse" [stmt]          [stmt] for
 *     [stmt]                    [stmt] while [stmt]                     [stmt]
 *     "dostmt" while            [stmt]
 *
 *  On each reduction, parser_state_tos->i_l_follow (the indentation for the
 *     following line) is set to the indentation level associated with the old
 *     TOS.
 *
 *  PARAMETERS: None
 *
 *  RETURNS: Nothing
 *
 *  GLOBALS: parser_state_tos->cstk parser_state_tos->i_l_follow =
 *     parser_state_tos->il parser_state_tos->p_stack = parser_state_tos->tos =
 *
 *  CALLS: None
 *
 *  CALLED BY: parse
 *
 *  HISTORY: initial coding         November 1976   D A Willcox of CAC
 *
 */

extern void reduce(void)
{
    int i;

    for (;;)
    {
        /* keep looping until there is nothing left to reduce */

        switch (parser_state_tos->p_stack[parser_state_tos->tos])
        {
            case stmt:
                if (parser_state_tos->tos == 0) return;
                switch (parser_state_tos->p_stack[parser_state_tos->tos - 1])
                {
                    case stmt:
                    case stmtl:
                        /* stmtl stmt or stmt stmt */
                        parser_state_tos->p_stack[--parser_state_tos->tos] = stmtl;
                        break;

                    case dolit: /* [do] [stmt] */
                        parser_state_tos->p_stack[--parser_state_tos->tos] = dohead;
                        parser_state_tos->i_l_follow = parser_state_tos->il[parser_state_tos->tos];
                        break;

                    case ifstmt:
                        /* [if] [stmt] */
                        parser_state_tos->p_stack[--parser_state_tos->tos] = ifhead;
                        for (i = parser_state_tos->tos - 1;
                             ( (parser_state_tos->p_stack[i] != stmt) &&
                               (parser_state_tos->p_stack[i] != stmtl) &&
                               (parser_state_tos->p_stack[i] != lbrace));
                             --i)
                        {
                        }

                        parser_state_tos->i_l_follow = parser_state_tos->il[i];

                        /* for the time being, we will assume that there is no else on
                         * this if, and set the indentation level accordingly. If an
                         * else is scanned, it will be fixed up later */

                        break;

                    case swstmt:
                        /* [switch] [stmt] */
                    case decl:          /* finish of a declaration */
                    case elsehead:
                        /* [[if] [stmt] else] [stmt] */
                    case forstmt:
                        /* [for] [stmt] */
                    case casestmt:
                        /* [case n:] [stmt] */
                    case whilestmt:
                        /* [while] [stmt] */
                        parser_state_tos->p_stack[--parser_state_tos->tos] = stmt;
                        parser_state_tos->i_l_follow = parser_state_tos->il[parser_state_tos->tos];
                        break;

                    default:            /* [anything else] [stmt] */
                        return;

                }                       /* end of section for [stmt] on top of stack */
                break;

            case whilestmt:     /* while (...) on top */
                if (parser_state_tos->p_stack[parser_state_tos->tos - 1] == dohead)
                {
                    /* it is termination of a do while */
                    parser_state_tos->p_stack[--parser_state_tos->tos] = dostmt;
                    break;
                }
                else
                    return;

            default:            /* anything else on top */
                return;

        }
    }
}

/**
 * This kludge is called from main.  It is just like parse(semicolon) except
 * that it does not clear break_comma.  Leaving break_comma alone is
 * necessary to make sure that "int foo(), bar()" gets formatted correctly
 * under -bc.  */

extern void parse_lparen_in_decl(void)
{
   inc_pstack ();
   parser_state_tos->p_stack[parser_state_tos->tos] = stmt;
   parser_state_tos->il[parser_state_tos->tos]      = parser_state_tos->ind_level;

   reduce ();
}
