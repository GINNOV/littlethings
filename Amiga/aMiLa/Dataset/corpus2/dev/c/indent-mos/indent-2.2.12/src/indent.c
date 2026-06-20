/** \file
 * Copyright (c) 2015 Tim Hentenaar. All rights reserved.<br>
 * Copyright (c) 1999, 2000 Carlo Wood.  All rights reserved. <br>
 * Copyright (c) 1994, 1996, 1997 Joseph Arceneaux.  All rights reserved. <br>
 * Copyright (c) 1992, 2002, 2008, 2014, 2015 Free Software Foundation, Inc.  All rights reserved. <br>
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
 */

#include "sys.h"

#if defined (HAVE_UNISTD_H)
#include <unistd.h>
#endif
#ifdef PRESERVE_MTIME
#include <time.h>
#ifdef HAVE_UTIME_H
#include <utime.h>
#elif defined(HAVE_SYS_UTIME_H)
#include <sys/utime.h>
#endif
#endif
#include <sys/stat.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#ifdef HAVE_LOCALE_H
#include <locale.h>
#endif
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



/* Stuff that needs to be shared with the rest of indent.
 * Documented in indent.h.
 */

char           * labbuf                      = NULL;
char           * s_lab                       = NULL;
char           * e_lab                       = NULL;
char           * l_lab                       = NULL;
char           * codebuf                     = NULL;
char           * s_code                      = NULL;
char           * e_code                      = NULL;
char           * l_code                      = NULL;
char           * combuf                      = NULL;
char           * s_com                       = NULL;
char           * e_com                       = NULL;
char           * l_com                       = NULL;
char           * s_code_corresponds_to       = NULL;
buf_ty           save_com;
char           * bp_save                     = NULL;
char           * be_save                     = NULL;
int              code_lines                  = 0;
int              line_no                     = 0;
int              break_comma                 = 0;
int              n_real_blanklines           = 0;
int              prefix_blankline_requested  = 0;
codes_ty         prefix_blankline_requested_code;
int              postfix_blankline_requested  = 0;
codes_ty         postfix_blankline_requested_code;
char           * in_name                     = 0; /*!< Points to current input file name */
file_buffer_ty * current_input               = 0; /*!< Points to the current input buffer */
int              embedded_comment_on_line    = 0; /*!< True if there is an embedded comment on this code line */
int              else_or_endif               = 0;
int            * di_stack                    = NULL; /*!< structure indentation levels */
int              di_stack_alloc              = 0; /*!< Currently allocated size of di_stack.  */
int              squest                      = 0; /*!< when this is positive, we have seen a ? without
                                                * the matching : in a [c]?[s]:[s] construct */
unsigned long    in_prog_size   = 0U;
char           * in_prog        = NULL;

/** The position that we will line the current line up with when it comes time
 * to print it (if we are lining up to parentheses).  */

int       paren_target   = 0;

#ifdef DEBUG
int            debug = 1;
#endif

/**
 *
 */

static void sw_buffer(void)
{
    parser_state_tos->search_brace = false;
    bp_save = buf_ptr;
    be_save = buf_end;
    buf_ptr = save_com.ptr;
    need_chars (&save_com, 1);
    buf_end = save_com.end;
    save_com.end = save_com.ptr;        /* make save_com empty */
}

/**
 *
 */

static BOOLEAN search_brace(
    codes_ty       * type_code,
    BOOLEAN        * force_nl,
    BOOLEAN        * flushed_nl,
    BOOLEAN        * last_else,
    BOOLEAN        * is_procname_definition,
    BOOLEAN        * pbreak_line)
{
    int cur_token;

    while (parser_state_tos->search_brace)
    {
        /* After scanning an if(), while (), etc., it might be necessary to
         * keep track of the text between the if() and the start of the
         * statement which follows.  Use save_com to do so.
         */

        /* The saved buffer has space at the beginning to hold a brace if
         * needed and otherwise collects comments, separating them with newlines
         * if there are more than one.
         *
         * The process stops if we find a left brace or the beginning of a statement.
         *
         * A left brace is moved before any comments in a -br situation.  Otherwise,
         * it comes after comments.
         *
         * At the moment any form feeds before we get to braces or a statement are just
         * dropped.
         */
        cur_token = *type_code;
        switch (cur_token)
        {
        case newline:
            ++line_no;
            *flushed_nl = true;
            break;
        case form_feed:
            break;              /* form feeds and newlines found here will be
                                 * ignored */
        case lbrace:
            /* Ignore buffering if no comment stored. */

            if (save_com.end == save_com.ptr)
            {
                parser_state_tos->search_brace = false;
                return true;                                                            /* RETURN */
            }

            /* We need to put the '{' back into save_com somewhere.  */

            if (settings.btype_2 && (parser_state_tos->last_token != rbrace))
            {
                /* We are asking the brace to jump ahead of the comment.  In 
                 * the event that it was between two comments, the regression
                 * examples want to insert a newline to put the comments on 
                 * separate lines.  If it is followed by something not a 
                 * comment, we don't want to add a newline.
                 *
                 * To make that work, we'll put the brace up front and let the
                 * process continue to pick up another comment or not.
                 */

                save_com.ptr[0] = '{';
                save_com.len = 1;
                save_com.column = current_column ();
            }
            else
            {
                /* Put the brace at the end of the saved buffer, after
                 * a newline character.  The newline char will cause
                 * a `dump_line' call, thus ensuring that the brace
                 * will go into the right column. */

                *save_com.end++ = EOL;
                *save_com.end++ = '{';
                save_com.len += 2;

                /* Go to common code to get out of this loop.  */

                sw_buffer();
            }
            break;
                    
        case comment:
            /* Save this comment in the `save_com' buffer, for
             * possible re-insertion in the output stream later. */

            if (!*flushed_nl || (save_com.end != save_com.ptr))
            {
                need_chars (&save_com, 10);

                if (save_com.end == save_com.ptr)
                {
                    /* if this is the first comment, we must set
                     * up the buffer */

                    save_com.start_column = current_column ();
                    save_com.ptr[0] = save_com.ptr[1] = ' ';
                    save_com.end = save_com.ptr + 2;
                    save_com.len = 2;
                    save_com.column = current_column ();
                }
                else
                {
                    *save_com.end++ = EOL;      /* add newline between
                                                 * comments */
                    *save_com.end++ = ' ';
                    save_com.len += 2;
                    --line_no;
                }

                *save_com.end++ = '/';  /* copy in start of comment */
                *save_com.end++ = '*';

                for (;;)
                {
                    /* loop until we get to the end of the
                     * comment */

                    /* make sure there is room for this character and
                     * (while we're at it) the '/' we might add at the end
                     * of the loop. */
                        
                    need_chars (&save_com, 2);
                    *save_com.end = *buf_ptr++;
                    save_com.len++;

                    if (buf_ptr >= buf_end)
                    {
                        fill_buffer();

                        if (had_eof)
                        {
                            ERROR(_("EOF encountered in comment"), NULL, NULL);
                            return indent_punt;
                        }
                    }

                    if (*save_com.end++ == '*' && *buf_ptr == '/')
                    {
                        break;  /* we are at end of comment */
                    }
                }

                *save_com.end++ = '/';  /* add ending slash */
                save_com.len++;

                if (++buf_ptr >= buf_end)       /* get past / in buffer */
                {
                    fill_buffer();
                }

                break;
            }

            /* Just some statement */
            /* Falls through */

        default:
            /* Some statement.  Unless it's special, arrange
             * to break the line. */

            if (((*type_code == sp_paren) && (*token == 'i') &&    /* "if" statement */
                 *last_else) ||
                ((*type_code == sp_else)  &&     /* "else" statement */
                 (e_code != s_code) && (e_code[-1] == '}') &&      /* The "else" follows '}' */
                 (save_com.end == save_com.ptr)))                  /* And we haven't found an 
                                                                    * intervening comment. */
            {
                *force_nl = false;
            }
            else if (*flushed_nl)
            {
                *force_nl = true;
            }
            else
            {
              /* what ? */
            }

            if (save_com.end == save_com.ptr)
            {
                /* ignore buffering if comment wasnt saved up */

                parser_state_tos->search_brace = false;
                return true;                                      /* RETURN */
            }

            if (*force_nl)
            {
                *force_nl = false;
                --line_no;      /* this will be re-increased when the nl is read from the buffer */
                need_chars (&save_com, 2);
                *save_com.end++ = EOL;
                save_com.len++;
                if (settings.verbose && !*flushed_nl)
                {
                    WARNING(_("Line broken"), NULL, NULL);
                }

                *flushed_nl = false;
            }

            /* Now copy this token we just found into the saved buffer. */

            *save_com.end++ = ' ';
            save_com.len++;
            buf_ptr = token;

            /* A total nightmare is created by trying to get the
             * next token into this save buffer.  Rather than that,
             * I've just backed up the buffer pointer to point
             * at `token'. --jla 9/95 */

            parser_state_tos->procname      = "\0";
            parser_state_tos->procname_end  = "\0";
            parser_state_tos->classname     = "\0";
            parser_state_tos->classname_end = "\0";

            /* Switch input buffers so that calls to lexi() will
             * read from our save buffer. */

            sw_buffer();
            break;
        }                   /* end of switch */

        if (*type_code != code_eof)
        {
            /* Read the next token */
            *type_code = lexi();

            /* Dump the line, if we just saw a newline, and:
             *
             * 1. The current token is a newline. - AND -
             * 2. The comment buffer is empty. - AND -
             * 3. The next token is a newline or comment. - AND -
             * 4. The previous token was a rbrace.
             *
             * This is needed to avoid indent eating newlines between
             * blocks like so:
             *
             * if (...) {
             *
             * }
             *
             * /comment here/
             * if (...)
             *
             * However, if there's a comment in the comment buffer, and the
             * next token is a newline, we'll just append a newline to the end
             * of the comment in the buffer, so that we don't lose it when
             * the comment is written out.
             */
            if (cur_token == newline &&
                (*type_code == newline || *type_code == comment) &&
                parser_state_tos->last_token == rbrace)
            {
                if (!save_com.len) {
                    dump_line(true, &paren_target, pbreak_line);
                    *flushed_nl = true;
                } else if (*type_code == newline) {
                    *save_com.end++ = EOL;
                    save_com.len++;
                }
           }

            *is_procname_definition = ((parser_state_tos->procname[0] != '\0') &&
                                       parser_state_tos->in_parameter_declaration);
        }

        if ((*type_code == ident) && *flushed_nl &&
            !settings.procnames_start_line &&
            parser_state_tos->in_decl &&
            (parser_state_tos->procname[0] != '\0'))
        {
            *flushed_nl = 0;
        }
    }                       /* end of while (search_brace) */

    *last_else = 0;

    return true;
}

/**
 *
 */

static exit_values_ty indent_main_loop(
    BOOLEAN * pbreak_line)
{
    codes_ty         hd_type         = code_eof;
    char           * t_ptr           = NULL;
    codes_ty         type_code       = start_token;
    exit_values_ty   file_exit_value = total_success;
    int              dec_ind         = 0; /* current indentation for declarations */

    BOOLEAN          scase           = false; /* true when we've just see a "case";
                                               * determines what to do with the
                                               * following colon */
    BOOLEAN          flushed_nl;              /* Used when buffering up comments to remember that
                                               * a newline was passed over */
    BOOLEAN          sp_sw           = false; /* true when in the expression part of if(...),
                                               * while(...), etc. */
    BOOLEAN          force_nl        = false;

    /* last_token_ends_sp: True if we have just encountered the end of an if (...),
     * etc. (i.e. the ')' of the if (...) was the last token).  The variable is
     * set to 2 in the middle of the main token reading loop and is decremented
     * at the beginning of the loop, so it will reach zero when the second token
     * after the ')' is read.
     */

    BOOLEAN          last_token_ends_sp = false;

    BOOLEAN          last_else = false; /* true if last keyword was an else */

    for (;;)
    {
        /* this is the main loop.  it will go until
         * we reach eof */

        BOOLEAN is_procname_definition;
        bb_code_ty can_break = bb_none;

        if (type_code != newline)
        {
            can_break = parser_state_tos->can_break;
        }

        parser_state_tos->last_saw_nl = false;
        parser_state_tos->can_break = bb_none;

        type_code = lexi (); /* lexi reads one token.  "token" points to
                              * the actual characters. lexi returns a code
                              * indicating the type of token */

        /* If the last time around we output an identifier or
         * a paren, then consider breaking the line here if it's
         * too long.
         *
         * A similar check is performed at the end of the loop, after
         * we've put the token on the line. */

        if ((settings.max_col > 0) &&
            (buf_break != NULL) &&
            ( ( (parser_state_tos->last_token == ident) &&
                (type_code != comma) &&
                (type_code != semicolon) &&
                (type_code != newline) &&
                (type_code != form_feed) &&
                (type_code != rparen) &&
                (type_code != struct_delim)) ||
              ( (parser_state_tos->last_token == rparen) &&
                (type_code != comma) &&
                (type_code != rparen) ) ) &&
            (output_line_length () > settings.max_col))
        {
            *pbreak_line = true;
        }

        if (last_token_ends_sp > 0)
        {
            last_token_ends_sp--;
        }

        is_procname_definition =
                (((parser_state_tos->procname[0] != '\0') &&
                  parser_state_tos->in_parameter_declaration) ||
                 (parser_state_tos->classname[0] != '\0'));

        /* The following code moves everything following an if (), while (),
         * else, etc. up to the start of the following stmt to a buffer. This
         * allows proper handling of both kinds of brace placement.
         */

        flushed_nl = false;

        /* Don't force a newline after an unbraced if, else, etc. */
        if (settings.allow_single_line_conditionals &&
            (parser_state_tos->last_token == rparen ||
            parser_state_tos->last_token == sp_else))
            force_nl = false;

        /* Don't force a newline after '}' in a block initializer */
        if (parser_state_tos->block_init           &&
            parser_state_tos->last_token == rbrace &&
            *token == ',')
            force_nl = false;

        if (!search_brace(&type_code, &force_nl, &flushed_nl, &last_else,
                          &is_procname_definition, pbreak_line))
        {
            /* Hit EOF unexpectedly in comment. */
            return indent_punt;
        }
        
        if (type_code == code_eof)
        {
            /* we got eof */
            if (s_lab != e_lab || s_code != e_code || s_com != e_com)   /* must dump end of line */
            {
                dump_line(true, &paren_target, pbreak_line);
            }

            if (parser_state_tos->tos > 1)      /* check for balanced braces */
            {
                ERROR(_("Unexpected end of file"), NULL, NULL);
                file_exit_value = indent_error;
            }

            if (settings.verbose)
            {
                printf (_("There were %d non-blank output lines and %d comments\n"),
                        (int) out_lines, (int) com_lines);
                if (com_lines > 0 && code_lines > 0)
                {
                    printf (_("(Lines with comments)/(Lines with code): %6.3f\n"),
                            (1.0 * com_lines) / code_lines);
                }
            }
            flush_output ();

            return file_exit_value;                                              /* RETURN */
        }

        if ((type_code != comment) &&
            (type_code != cplus_comment) &&
            (type_code != newline) &&
            (type_code != preesc) &&
            (type_code != form_feed))
        {
            if (force_nl &&
                (type_code != semicolon) &&
                ( (type_code != lbrace) ||
                  (!parser_state_tos->in_decl && !settings.btype_2) ||
                  (parser_state_tos->in_decl && !settings.braces_on_struct_decl_line) ||
                  (parser_state_tos->last_token == rbrace)))
            {
                if (settings.verbose && !flushed_nl)
                {
                    WARNING(_("Line broken 2"), NULL, NULL);
                }

                flushed_nl = false;
                dump_line(true, &paren_target, pbreak_line);
                parser_state_tos->want_blank = false;
                force_nl = false;
            }

            parser_state_tos->in_stmt = true;   /* turn on flag which causes
                                                 * an extra level of
                                                 * indentation. this is
                                                 * turned off by a ; or } */
            if (s_com != e_com)
            {
                /* the code has an embedded comment in the
                 * line. Move it from the com buffer to the
                 * code buffer.
                 *
                 * Do not add a space before the comment if it is the first
                 * thing on the line.
                 */

                if (e_code != s_code)
                {
                    set_buf_break (bb_embedded_comment_start, paren_target);
                    *e_code++ = ' ';
                    embedded_comment_on_line = 2;
                }
                else
                {
                    embedded_comment_on_line = 1;
                }

                for (t_ptr = s_com; *t_ptr; ++t_ptr)
                {
                    check_code_size();
                    *e_code++ = *t_ptr;
                }

                set_buf_break (bb_embedded_comment_end, paren_target);
                *e_code++ = ' ';
                *e_code = '\0'; /* null terminate code sect */
                parser_state_tos->want_blank = false;
                e_com = s_com;
            }
        }
        else if ((type_code != comment) &&
                 (type_code != cplus_comment) &&
                 !(settings.break_function_decl_args &&
                   (parser_state_tos->last_token == comma)) &&
                 !( (parser_state_tos->last_token == comma) &&
                    !settings.leave_comma))
        {
            /* preserve force_nl thru a comment but
             * cancel forced newline after newline, form feed, etc.
             * however, don't cancel if last thing seen was comma-newline
             * and -bc flag is on. */

            force_nl = false;
        }
        else
        {
          /* what ? */
        }

        /* Main switch on type of token scanned */

        check_code_size();
        
        /* now, decide what to do with the token */

        handle_the_token(type_code, &scase, &force_nl, &sp_sw, &flushed_nl,
                         &hd_type, &dec_ind, &last_token_ends_sp, &file_exit_value,
                         can_break, &last_else, is_procname_definition,
                         pbreak_line);
        
        *e_code = '\0';         /* make sure code section is null terminated */

        if ((type_code != comment) &&
            (type_code != cplus_comment) &&
            (type_code != newline) &&
            (type_code != preesc) &&
            (type_code != form_feed))
        {
            parser_state_tos->last_token = type_code;
        }

        /* Now that we've put the token on the line (in most cases),
         * consider breaking the line because it's too long.
         *
         * Don't consider the cases of `unary_op', newlines,
         * declaration types (int, etc.), if, while, for,
         * identifiers (handled at the beginning of the loop),
         * periods, or preprocessor commands. */

        if ((settings.max_col > 0) && (buf_break != NULL))
        {
            if ( ( (type_code == binary_op) ||
                   (type_code == postop) ||
                   (type_code == question) ||
                   ((type_code == colon) && (scase || (squest <= 0))) ||
                   (type_code == semicolon) ||
                   (type_code == sp_nparen) ||
                   (type_code == sp_else) ||
                   ((type_code == ident) && (*token == '\"')) ||
                   (type_code == struct_delim) ||
                   (type_code == comma)) &&
                 (output_line_length () > settings.max_col))
            {
                *pbreak_line = true;
            }
        }
    }                           /* end of main infinite loop */
}

/**
 *
 */


static exit_values_ty indent (
    file_buffer_ty * this_file)
{
    BOOLEAN break_line = false;       /* Whether or not we should break the line. */

    in_prog                     = this_file->data;
    in_prog_pos                 = this_file->data;
    in_prog_size                = this_file->size;
    squest                      = false;
    n_real_blanklines           = 0;
    postfix_blankline_requested = 0;

    clear_buf_break_list (&break_line);
    
    if (settings.decl_com_ind <= 0)      /* if not specified by user, set this */
    {
        settings.decl_com_ind = settings.ljust_decl ? (settings.com_ind <= 10 ? 2 :
                                                       settings.com_ind - 8) :
                                                       settings.com_ind;
    }

    if (settings.continuation_indent == 0)
    {
        settings.continuation_indent = settings.ind_size;
    }

    if (settings.paren_indent == -1)
    {
        settings.paren_indent = settings.continuation_indent;
    }

    if (settings.case_brace_indent == -1)
    {
        settings.case_brace_indent = settings.ind_size;   /* This was the previous default */
    }

    fill_buffer();             /* Fill the input buffer */

    return indent_main_loop(&break_line);         /* do the work. */
}

/**
 *
 */


static char * handle_profile (
   int    argc, 
   char * argv[])
{
    int i;
    char *profile_pathname = NULL;

    for (i = 1; i < argc; ++i)
    {
        if ((strcmp (argv[i], "-npro") == 0) ||
            (strcmp (argv[i], "--ignore-profile") == 0) ||
            (strcmp (argv[i], "+ignore-profile") == 0))
        {
            break;
        }
    }

    if (i >= argc)
    {
        profile_pathname = set_profile ();
    }

    return profile_pathname;
}

/**
 *
 */

static char    * out_name        = 0; /* Points to the name of the output file */
static int       input_files     = 0; /* How many input files were specified */
static char **   in_file_names   = NULL; /* Names of all input files */
static int       max_input_files = 128; /* Initial number of input filenames to allocate. */

/**
 *
 */

static exit_values_ty process_args (
    int       argc,
    char    * argv[],
    BOOLEAN * using_stdin)
{
    int i;
    exit_values_ty exit_status = total_success;

    for (i = 1; i < argc; ++i)
    {
        if ((*argv[i] != '-') && (*argv[i] != '+'))       /* Filename */
        {
            if (settings.expect_output_file == true)       /* Last arg was "-o" */
            {
                if (out_name != 0)
                {
                    fprintf (stderr,
                             _("indent: only one output file (2nd was %s)\n"),
                             argv[i]);
                    exit_status = invocation_error;
                    break;
                }

                if (input_files > 1)
                {
                    fprintf (stderr,
                             _("indent: only one input file when output file is specified\n"));
                    exit_status = invocation_error;
                    break;
                }

                out_name = argv[i];
                settings.expect_output_file = false;
                continue;
            }
            else
            {
                if (*using_stdin)
                {
                    fprintf (stderr,
                             _("indent: can't have filenames when specifying standard input\n"));
                    exit_status = invocation_error;
                    break;
                }

                input_files++;

                if (input_files > 1)
                {
                    if (out_name != 0)
                    {
                        fprintf (stderr,
                                 _("indent: only one input file when output file is specified\n"));
                        exit_status = invocation_error;
                        break;
                    }

                    if (settings.use_stdout != 0)
                    {
                        fprintf (stderr,
                                 _("indent: only one input file when stdout is used\n"));
                        exit_status = invocation_error;
                        break;
                    }

                    if (input_files > max_input_files)
                    {
                        max_input_files = 2 * max_input_files;
                        in_file_names = xrealloc(in_file_names,
                                                 (max_input_files *
                                                  sizeof(char *)));
                    }
                }

                in_file_names[input_files - 1] = argv[i];
            }
        }
        else
        {
            /* '-' as filename means stdin. */
            
            if (strcmp (argv[i], "-") == 0)
            {
                if (input_files > 0)
                {
                    fprintf (stderr,
                             _("indent: can't have filenames when specifying standard input\n"));
                    exit_status = invocation_error;
                    break;
                }

                *using_stdin = true;
            }
            else
            {
               i += set_option(argv[i], (i < argc ? argv[i + 1] : 0), 1, _("command line"));
            }
        }
    }

    return exit_status;
}

/**
 *
 */

static exit_values_ty indent_multiple_files(void)
{
    exit_values_ty exit_status = total_success;
    
    int i;
    /* When multiple input files are specified, make a backup copy
     * and then output the indented code into the same filename. */

    for (i = 0; input_files; i++, input_files--)
    {
        exit_values_ty status;
        struct stat file_stats;

        in_name = in_file_names[i];
        out_name = in_file_names[i];
        current_input = read_file(in_file_names[i], &file_stats);

        open_output(out_name, "r+");

        make_backup(current_input, &file_stats); /* Aborts on failure. */

        /* We have safely made a backup so the open file can be truncated. */
          
        reopen_output_trunc(out_name);
          
        reset_parser();
        status = indent (current_input);

        if (status > exit_status)
        {
            exit_status = status;
        }

        if (settings.preserve_mtime)
        {
            close_output(&file_stats, out_name);
        }
        else
        {
            close_output(NULL, out_name);
        }
    }
    
    return exit_status;
}

/**
 *
 */

static exit_values_ty indent_single_file(BOOLEAN using_stdin)
{
    int            is_stdin    = false;
    exit_values_ty exit_status = total_success;
    struct stat    file_stats;

    if ((input_files == 0) || using_stdin)
    {
        input_files = 1;
        in_file_names[0] = "Standard input";
        in_name = in_file_names[0];
        current_input = read_stdin ();
        is_stdin = true;
    }
    else
    {
        /* 1 input file */

        in_name = in_file_names[0];
        current_input = read_file(in_file_names[0], &file_stats);

        if (!out_name && !settings.use_stdout)
        {
            out_name = in_file_names[0];
            make_backup(current_input, &file_stats);
        }
    }

    /* Use stdout if it was specified ("-st"), or neither input
     * nor output file was specified. */

    if (settings.use_stdout || !out_name)
    {
        open_output(NULL, NULL);
    }
    else
    {
        open_output(out_name, "w");
    }

    reset_parser ();

    exit_status = indent (current_input);

    if (input_files > 0 && !using_stdin && settings.preserve_mtime)
    {
        close_output(&file_stats, out_name);
    }
    else
    {
        close_output(NULL, out_name);
    }

    if (current_input) {
        if (!is_stdin && current_input->name)
            xfree(current_input->name);
        xfree(current_input->data);
    }

    return exit_status;
}

/**
 *
 */


static exit_values_ty indent_all(
   BOOLEAN using_stdin)
{
    exit_values_ty exit_status = total_success;

    if (input_files > 1)
    {
        exit_status = indent_multiple_files();
        
    }
    else
    {
        /* One input stream -- specified file, or stdin */
        exit_status = indent_single_file(using_stdin);
        
    }

    return exit_status;
}

/**
 *
 */

int main(
    int     argc,
    char ** argv)
{
    char *tmp;
    char *profile_pathname = 0;
    BOOLEAN using_stdin = false;
    exit_values_ty exit_status;

#if defined (HAVE_SETLOCALE)
    setlocale(LC_ALL, "");
#endif
    bindtextdomain(PACKAGE, LOCALEDIR);
    textdomain(PACKAGE);

#if defined (_WIN32) && !defined (__CYGWIN__)
    /* wildcard expansion of commandline arguments, see wildexp.c */

    extern void wildexp(int *argc, char ***argv);

    wildexp(&argc, &argv);
#endif /* defined (_WIN32) && !defined (__CYGWIN__) */

	/* Initialize settings */
	memset(&settings, 0, sizeof(settings));

#ifdef DEBUG
    if (debug)
    {
        debug_init();
    }
#endif

    /* 'size_t', 'wchar_t' and 'ptrdiff_t' are guarenteed to be
     * available in ANSI C.
     *
     * These pointers will be freed in cleanup_user_specials().
     */
    tmp = xmalloc(7);
    memcpy(tmp, "size_t", 7);
    addkey(tmp, rw_decl);
    tmp = xmalloc(8);
    memcpy(tmp, "wchar_t", 8);
    addkey(tmp, rw_decl);
    tmp = xmalloc(10);
    memcpy(tmp, "ptrdiff_t", 10);
    addkey(tmp, rw_decl);

    init_parser ();
    initialize_backups ();
    exit_status = total_success;

    input_files = 0;
    in_file_names = xmalloc(max_input_files * sizeof(char *));

    set_defaults();

    profile_pathname = handle_profile(argc, argv);

    exit_status = process_args(argc, argv, &using_stdin);

    if (exit_status == total_success)
    {
        if (settings.verbose && profile_pathname)
        {
            fprintf (stderr, _("Read profile %s\n"), profile_pathname);
        }

        set_defaults_after();

        exit_status = indent_all(using_stdin);
    }

    if (profile_pathname)
        xfree(profile_pathname);
    xfree(in_file_names);
    uninit_parser();
    cleanup_user_specials();
    return exit_status;
}
