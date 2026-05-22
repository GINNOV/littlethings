/** \file
 * Copyright (c) 2015 Tim Hentenaar. All rights reserved.<br>
 * Copyright (c) 2013 Łukasz Stelmach.  All rights reserved.<br>
 * Copyright (c) 1999, 2000 Carlo Wood.  All rights reserved.<br>
 * Copyright (c) 1994 Joseph Arceneaux.  All rights reserved.<br>
 * Copyright (c) 1992, 2002, 2008, 2014 Free Software Foundation, Inc. 
 *   All rights reserved.<br>
 *
 * Copyright (c) 1980, 1993
 *       The Regents of the University of California.<br>
 * Copyright (c) 1976 Board of Trustees of the University of Illinois.<br>
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
 * HISTORY
 * - 2002-03-14 DI restructured scan_profile and fixed bug handling comments
 * - 2002-06-13 DI fixed handling of missing int parameter.
 * - 2002-08-05 Matthias <moh@itec.uni-klu.ac.at> and Eric Lloyd <ewlloyd@neta.com>
 *            Added support for -brf to place function opening brace after function
 *            declaration.
 * - 2002-11-10 Cristalle Azundris Sabon <cristalle@azundris.com>
 *            Added --preprocessor-indentation (ppi)   if set, will indent nested
 *            preprocessor-statements with n spaces per level.  overrides -lps.
 * -2007-11-11 Jean-Christophe Dubois <jcd@tribudubois.net>
 *            Added --indent-label and --linux-style options.
 * - 2008-03-08 DI Re-baselined on the more acceptable (license-wise) OpenBSD release 3.4.
 */

/* Argument scanning and profile reading code.  Default parameters are set
 * here as well. */

#ifndef _XOPEN_SOURCE
#define _XOPEN_SOURCE 500    /* strdup(3) */
#endif

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "sys.h"
#include "indent.h"
#include "args.h"
#include "globs.h"
#include "utils.h"

RCSTAG_CC ("$Id$");

#define KR_SETTINGS_STRING \
     "-nbad\0-bap\0-nbc\0-bbo\0-hnl\0-br\0-brs\0-c33\0-cd33\0" \
     "-ncdb\0-ce\0-ci4\0-cli0\0-d0\0-di1\0-nfc1\0-i4\0-ip0\0-l75\0-lp\0" \
     "-npcs\0-nprs\0-npsl\0-sai\0-saf\0-saw\0-cs\0-nsc\0-nsob\0-nfca\0-cp33\0"\
     "-nss\0-par\0-sar\0"

#define GNU_SETTINGS_STRING \
     "-nbad\0-bap\0-bbo\0-hnl\0-nbc\0-bl\0-bls\0-ncdb\0-cs\0-nce\0" \
     "-di2\0-ndj\0-nfc1\0-i2\0-ip5\0-lp\0-pcs\0-nprs\0-psl\0-nsc\0-sai\0-saf\0-saw\0-nsob\0" \
     "-bli2\0-cp1\0-nfca\0"

#define ORIG_SETTINGS_STRING \
     "-nbap\0-nbad\0-bbo\0-hnl\0-bc\0-br\0-brs\0-c33\0-cd33\0-cdb\0" \
     "-ce\0-ci4\0-cli0\0-cp33\0-di16\0-fc1\0-fca\0-i4\0-l75\0-lp\0-npcs\0-nprs\0" \
     "-psl\0-sc\0-sai\0-saf\0-saw\0-nsob\0-nss\0-ts8\0"

#define LINUX_SETTINGS_STRING \
     "-nbad\0-bap\0-nbc\0-bbo\0-hnl\0-br\0-brs\0-c33\0-cd33\0" \
     "-ncdb\0-ce\0-ci4\0-cli0\0-d0\0-di1\0-nfc1\0-i8\0-ip0\0-l80\0-lp\0" \
     "-npcs\0-nprs\0-npsl\0-sai\0-saf\0-saw\0-ncs\0-nsc\0-sob\0-nfca\0-cp33\0-ss\0" \
     "-ts8\0-il1\0-nbs\0"

const char *settings_strings[6] = {
	KR_SETTINGS_STRING,
	GNU_SETTINGS_STRING,
	ORIG_SETTINGS_STRING,
	LINUX_SETTINGS_STRING,
	"-ip0\0",
	VERSION
};

#define KR_SETTINGS_IDX      (void *)0
#define GNU_SETTINGS_IDX     (void *)1
#define ORIG_SETTINGS_IDX    (void *)2
#define LINUX_SETTINGS_IDX   (void *)3
#define NIP_SETTINGS_IDX     (void *)4
#define VERSION_SETTINGS_IDX (void *)5

/**
 * Profile types. These identify what kind of switches and arguments 
 * can be passed to indent, and how to process them.
 */
typedef enum
{
    PRO_BOOL,                     /*!< boolean */
    PRO_INT,                      /*!< integer */
    PRO_IGN,                      /*!< ignore it */
    PRO_KEY,                      /*!< -T switch */
    PRO_SETTINGS,                 /*!< bundled set of settings */
    PRO_PRSTRING                  /*!< Print string and exit */
} profile_ty;

/**
 * profile value settings for booleans 
 */

typedef enum
{
    ONOFF_NA,                     /*!< Means Not Applicable.  Used in table for
                                   *   entries that are not of type PRO_BOOL.  */
    OFF,                          /*!< This option turns on the boolean variable
                                   *   in question.  */
    ON                            /*!< it turns it off */
} on_or_off_ty;

/* Explicit flags for each option.  */
static int exp_T    = 0;
static int exp_bacc = 0;
static int exp_badp = 0;
static int exp_bad  = 0;
static int exp_bap  = 0;
static int exp_bbb  = 0;
static int exp_bbo  = 0;
static int exp_bc   = 0;
static int exp_bl   = 0;
static int exp_blf  = 0;
static int exp_bli  = 0;
static int exp_bls  = 0;
static int exp_bs   = 0;
static int exp_c    = 0; /*!< Starting column for comments trailing statements */
static int exp_cbi  = 0;
static int exp_cdb  = 0;
static int exp_cd   = 0; /*!< Starting column for comments trailing declarations */
static int exp_cdw  = 0;
static int exp_ce   = 0;
static int exp_ci   = 0;
static int exp_cli  = 0;
static int exp_cp   = 0;
static int exp_cpp  = 0;
static int exp_cs   = 0;
static int exp_d    = 0;
static int exp_bfda = 0;
static int exp_bfde = 0;
static int exp_di   = 0;
static int exp_dj   = 0; /*!< Left justify declarations */
static int exp_eei  = 0;
static int exp_fc1  = 0;
static int exp_fca  = 0;
static int exp_fnc  = 0;
static int exp_gnu  = 0;
static int exp_gts  = 0;
static int exp_hnl  = 0;
static int exp_i    = 0;
static int exp_il   = 0;
static int exp_ip   = 0;
static int exp_kr   = 0;
static int exp_l    = 0;
static int exp_lc   = 0;
static int exp_linux = 0;
static int exp_lp   = 0;
static int exp_lps  = 0;
static int exp_nip  = 0; 
static int exp_o    = 0;
static int exp_orig = 0;
static int exp_pcs  = 0;
static int exp_pi   = 0;
#ifdef PRESERVE_MTIME
static int exp_pmt  = 0;
#endif
static int exp_pro  = 0;
static int exp_prs  = 0;
static int exp_psl  = 0;
static int exp_ppi  = 0;  /*!< force preprocessor indent at width... */
static int exp_sai  = 0;
static int exp_saf  = 0;
static int exp_saw  = 0;
static int exp_sbi  = 0;
static int exp_sc   = 0;
static int exp_sob  = 0;
static int exp_ss   = 0;
static int exp_st   = 0;
static int exp_ts   = 0;
static int exp_ut   = 0;
static int exp_v    = 0;
static int exp_version = 0;
static int exp_par  = 0;
static int exp_slc  = 0;
static int exp_as   = 0;
static int exp_sar  = 0;
static int exp_ntac = 0;

/**
 * The following structure is controlled by command line parameters and
 * their meaning is explained in indent.h.  
 */

user_options_ty settings;

/* N.B.: because of the way the table here is scanned, options whose names
 * are substrings of other options must occur later; that is, with -lp vs -l,
 * -lp must be first.  Also, while (most) booleans occur more than once, the
 * last default value is the one actually assigned. */

typedef struct
{
    const char * p_name;        /*!< option name, e.g. "bl", "cli" */
    profile_ty   p_type;        /*!< profile type */
    int          p_default;     /*!< the default value (if PRO_BOOL or PRO_INT) */

    on_or_off_ty p_special;     /*!< If p_type == PRO_BOOL, ON or OFF to tell how
                                 * this switch affects the variable. Not used
                                 * for other p_type's.  */

    void  *p_obj;               /*!< if p_type == PRO_SETTINGS, a (char *) pointing
                                 *    to a list of the switches to set, separated by
                                 *    NULLs, terminated by 2 NULLs.
                                 * if p_type ==PRO_BOOL or PRO_INT, the address of
                                 *     the variable that gets set by the option.
                                 * if p_type == PRO_PRSTRING, an index into the
                                 * settings_strings array.
                                 * if p_type == PRO_FUNCTION, a pointer to a
                                 *     function to be called. */

  int          * p_explicit;    /*!< Points to a nonzero value (allocated statically
                                 * for all options) if the option has been specified
                                 * explicitly.  This is necessary because for
                                 * boolean options, the options to set and reset the
                                 * variable must share the explicit flag.  */
} pro_ty;

/*
 * Usage is defined here because the structure pro refers to it. 
 */

static void usage (void); 

#ifdef BERKELEY_DEFAULTS

/**
 * Settings for original defaults
 */

const pro_ty pro[] =
{
    {"version", PRO_PRSTRING,                           0, ONOFF_NA, VERSION_SETTINGS_IDX,                       &exp_version},
    {"v",       PRO_BOOL,                           false,       ON, &settings.verbose,                          &exp_v},
    {"ut",      PRO_BOOL,                            true,       ON, &settings.use_tabs,                         &exp_ut},
    {"ts",      PRO_INT,                                8, ONOFF_NA, &settings.tabsize,                          &exp_ts},
    {"st",      PRO_BOOL,                           false,       ON, &settings.use_stdout,                       &exp_st},
    {"ss",      PRO_BOOL,                           false,       ON, &settings.space_sp_semicolon,               &exp_ss},
    {"sob",     PRO_BOOL,                           false,       ON, &settings.swallow_optional_blanklines,      &exp_sob},
    {"sc",      PRO_BOOL,                            true,       ON, &settings.star_comment_cont,                &exp_sc},
    {"sbi",     PRO_INT,                                0, ONOFF_NA, &settings.struct_brace_indent,              &exp_sbi},
    {"saw",     PRO_BOOL,                            true,       ON, &settings.space_after_while,                &exp_saw},
    {"sai",     PRO_BOOL,                            true,       ON, &settings.space_after_if,                   &exp_sai},
    {"saf",     PRO_BOOL,                            true,       ON, &settings.space_after_for,                  &exp_saf},
    {"psl",     PRO_BOOL,                            true,       ON, &settings.procnames_start_line,             &exp_psl},
    {"prs",     PRO_BOOL,                           false,       ON, &settings.parentheses_space,                &exp_prs},
#ifdef PRESERVE_MTIME
    {"pmt",     PRO_BOOL,                           false,       ON, &settings.preserve_mtime,                   &exp_pmt},
#endif
    {"pi",      PRO_INT,                               -1, ONOFF_NA, &settings.paren_indent,                     &exp_pi},
    {"pcs",     PRO_BOOL,                           false,       ON, &settings.proc_calls_space,                 &exp_pcs},
    {"o",       PRO_BOOL,                           false,       ON, &settings.expect_output_file,               &exp_o},
    {"nv",      PRO_BOOL,                           false,      OFF, &settings.verbose,                          &exp_v},
    {"nut",     PRO_BOOL,                            true,      OFF, &settings.use_tabs,                         &exp_ut},
    {"nss",     PRO_BOOL,                           false,      OFF, &settings.space_sp_semicolon,               &exp_ss},
    {"nsob",    PRO_BOOL,                           false,      OFF, &settings.swallow_optional_blanklines,      &exp_sob},
    {"nsc",     PRO_BOOL,                            true,      OFF, &settings.star_comment_cont,                &exp_sc},
    {"nsaw",    PRO_BOOL,                            true,      OFF, &settings.space_after_while,                &exp_saw},
    {"nsai",    PRO_BOOL,                            true,      OFF, &settings.space_after_if,                   &exp_sai},
    {"nsaf",    PRO_BOOL,                            true,      OFF, &settings.space_after_for,                  &exp_saf},
    {"npsl",    PRO_BOOL,                            true,      OFF, &settings.procnames_start_line,             &exp_psl},
    {"nprs",    PRO_BOOL,                           false,      OFF, &settings.parentheses_space,                &exp_prs},
    {"npro",    PRO_IGN,                                0, ONOFF_NA, 0,                                          &exp_pro},
#ifdef PRESERVE_MTIME
    {"npmt",    PRO_BOOL,                           false,      OFF, &settings.preserve_mtime,                   &exp_pmt},
#endif
    {"npcs",    PRO_BOOL,                           false,      OFF, &settings.proc_calls_space,                 &exp_pcs},
    {"nlps",    PRO_BOOL,                           false,      OFF, &settings.leave_preproc_space,              &exp_lps},
    {"nlp",     PRO_BOOL,                            true,      OFF, &settings.lineup_to_parens,                 &exp_lp},
    {"nip",     PRO_SETTINGS,                           0, ONOFF_NA, NIP_SETTINGS_IDX,                           &exp_nip},
    {"nhnl",    PRO_BOOL,                            true,      OFF, &settings.honour_newlines,                  &exp_hnl},
    {"ngts",    PRO_BOOL,                           false,      OFF, &settings.gettext_strings,                  &exp_gts},
    {"nfca",    PRO_BOOL,                            true,      OFF, &settings.format_comments,                  &exp_fca},
    {"nfc1",    PRO_BOOL,                            true,      OFF, &settings.format_col1_comments,             &exp_fc1},
    {"neei",    PRO_BOOL,                           false,      OFF, &settings.extra_expression_indent,          &exp_eei},
    {"ndj",     PRO_BOOL,                           false,      OFF, &settings.ljust_decl,                       &exp_dj},
    {"ncs",     PRO_BOOL,                            true,      OFF, &settings.cast_space,                       &exp_cs},
    {"nce",     PRO_BOOL,                            true,      OFF, &settings.cuddle_else,                      &exp_ce},
    {"ncdw",    PRO_BOOL,                           false,      OFF, &settings.cuddle_do_while,                  &exp_cdw},
    {"ncdb",    PRO_BOOL,                            true,      OFF, &settings.comment_delimiter_on_blankline,   &exp_cdb},
    {"nbs",     PRO_BOOL,                           false,      OFF, &settings.blank_after_sizeof,               &exp_bs},
    {"nbfda",   PRO_BOOL,                           false,      OFF, &settings.break_function_decl_args,         &exp_bfda},
    {"nbfde",   PRO_BOOL,                           false,      OFF, &settings.break_function_decl_args_end,     &exp_bfde},
    {"nbc",     PRO_BOOL,                            true,       ON, &settings.leave_comma,                      &exp_bc},
    {"nbbo",    PRO_BOOL,                            true,      OFF, &settings.break_before_boolean_operator,    &exp_bbo},
    {"nbbb",    PRO_BOOL,                           false,      OFF, &settings.blanklines_before_blockcomments,  &exp_bbb},
    {"nbap",    PRO_BOOL,                           false,      OFF, &settings.blanklines_after_procs,           &exp_bap},
    {"nbadp",   PRO_BOOL,                           false,      OFF, &settings.blanklines_after_declarations_at_proctop,  &exp_badp},
    {"nbad",    PRO_BOOL,                           false,      OFF, &settings.blanklines_after_declarations,    &exp_bad},
    {"nbacc",   PRO_BOOL,                           false,      OFF, &settings.blanklines_around_conditional_compilation, &exp_bacc},
    {"linux",   PRO_SETTINGS,                           0, ONOFF_NA, LINUX_SETTINGS_IDX,                         &exp_linux},
    {"lps",     PRO_BOOL,                           false,       ON, &settings.leave_preproc_space,              &exp_lps},
    {"lp",      PRO_BOOL,                            true,       ON, &settings.lineup_to_parens,                 &exp_lp},
    {"lc",      PRO_INT,     DEFAULT_RIGHT_COMMENT_MARGIN, ONOFF_NA, &settings.comment_max_col,                  &exp_lc},
    {"l",       PRO_INT,             DEFAULT_RIGHT_MARGIN, ONOFF_NA, &settings.max_col,                          &exp_l},
    {"kr",      PRO_SETTINGS,                           0, ONOFF_NA, KR_SETTINGS_IDX,                            &exp_kr},
    {"ip",      PRO_INT,                                4, ONOFF_NA, &settings.indent_parameters,                &exp_ip},
    {"i",       PRO_INT,                                4, ONOFF_NA, &settings.ind_size,                         &exp_i},
    {"il",      PRO_INT,             DEFAULT_LABEL_INDENT, ONOFF_NA, &settings.label_offset,                     &exp_il},
    {"hnl",     PRO_BOOL,                            true,       ON, &settings.honour_newlines,                  &exp_hnl},
    {"h",       PRO_BOOL,                               0, ONOFF_NA, NULL,                                       NULL},
    {"gts",     PRO_BOOL,                           false,       ON, &settings.gettext_strings,                  &exp_gts},
    {"gnu",     PRO_SETTINGS,                           0, ONOFF_NA, GNU_SETTINGS_IDX,                           &exp_gnu},
    {"fnc",     PRO_BOOL,                           false,       ON, &settings.fix_nested_comments,              &exp_fnc},
    {"fca",     PRO_BOOL,                            true,       ON, &settings.format_comments,                  &exp_fca},
    {"fc1",     PRO_BOOL,                            true,       ON, &settings.format_col1_comments,             &exp_fc1},
    {"eei",     PRO_BOOL,                           false,       ON, &settings.extra_expression_indent,          &exp_eei},
    {"dj",      PRO_BOOL,                           false,       ON, &settings.ljust_decl,                       &exp_dj},
    {"di",      PRO_INT,                               16, ONOFF_NA, &settings.decl_indent,                      &exp_di},
    {"d",       PRO_INT,                                0, ONOFF_NA, &settings.unindent_displace,                &exp_d},
    {"cs",      PRO_BOOL,                            true,       ON, &settings.cast_space,                       &exp_cs},
    {"cp",      PRO_INT,                               33, ONOFF_NA, &settings.else_endif_col,                   &exp_cp},
    {"cli",     PRO_INT,                                0, ONOFF_NA, &settings.case_indent,                      &exp_cli},
    {"ci",      PRO_INT,                                4, ONOFF_NA, &settings.continuation_indent,              &exp_ci},
    {"ce",      PRO_BOOL,                            true,       ON, &settings.cuddle_else,                      &exp_ce},
    {"cdw",     PRO_BOOL,                           false,       ON, &settings.cuddle_do_while,                  &exp_cdw},
    {"cdb",     PRO_BOOL,                            true,       ON, &settings.comment_delimiter_on_blankline,   &exp_cdb},
    {"cd",      PRO_INT,                               33, ONOFF_NA, &settings.decl_com_ind,                     &exp_cd},
    {"cbi",     PRO_INT,                               -1, ONOFF_NA, &settings.case_brace_indent,                &exp_cbi},
    {"c++",     PRO_BOOL,                           false,       ON, &settings.c_plus_plus,                      &exp_cpp},
    {"c",       PRO_INT,                               33, ONOFF_NA, &settings.com_ind,                          &exp_c},
    {"bs",      PRO_BOOL,                           false,       ON, &settings.blank_after_sizeof,               &exp_bs},
    {"brs",     PRO_BOOL,                            true,       ON, &settings.braces_on_struct_decl_line,       &exp_bls},
    {"brf",     PRO_BOOL,                           false,       ON, &settings.braces_on_func_def_line,          &exp_blf},
    {"br",      PRO_BOOL,                            true,       ON, &settings.btype_2,                          &exp_bl},
    {"bls",     PRO_BOOL,                            true,      OFF, &settings.braces_on_struct_decl_line,       &exp_bls},
    {"blf",     PRO_BOOL,                           false,      OFF, &settings.braces_on_func_def_line,          &exp_blf},
    {"bli",     PRO_INT,                                0, ONOFF_NA, &settings.brace_indent,                     &exp_bli},
    {"bl",      PRO_BOOL,                            true,      OFF, &settings.btype_2,                          &exp_bl},
    {"bfda",    PRO_BOOL,                           false,       ON, &settings.break_function_decl_args,         &exp_bfda},
    {"bfde",    PRO_BOOL,                           false,       ON, &settings.break_function_decl_args_end,     &exp_bfde},
    {"bc",      PRO_BOOL,                            true,      OFF, &settings.leave_comma,                      &exp_bc},
    {"bbo",     PRO_BOOL,                            true,       ON, &settings.break_before_boolean_operator,    &exp_bbo},
    {"bbb",     PRO_BOOL,                           false,       ON, &settings.blanklines_before_blockcomments,  &exp_bbb},
    {"bap",     PRO_BOOL,                           false,       ON, &settings.blanklines_after_procs,           &exp_bap},
    {"badp",    PRO_BOOL,                           false,       ON, &settings.blanklines_after_declarations_at_proctop,  &exp_badp},
    {"bad",     PRO_BOOL,                           false,       ON, &settings.blanklines_after_declarations,    &exp_bad},
    {"bacc",    PRO_BOOL,                           false,       ON, &settings.blanklines_around_conditional_compilation, &exp_bacc},
    {"T",       PRO_KEY,                                0, ONOFF_NA, 0,                                          &exp_T},
    {"ppi",     PRO_INT,                                0, ONOFF_NA, &settings.force_preproc_width,              &exp_ppi},
    {"pal",     PRO_BOOL,                            true,      OFF, &settings.pointer_align_right,              &exp_par},
    {"par",     PRO_BOOL,                            true,       ON, &settings.pointer_align_right,              &exp_par},
    {"slc",     PRO_BOOL,                            false,      ON, &settings.allow_single_line_conditionals,   &exp_slc},
    {"as",      PRO_BOOL,                            false,      ON, &settings.align_with_spaces,                &exp_as},
    {"sar",     PRO_BOOL,                            false,      ON, &settings.spaces_around_initializers,       &exp_sar},
    {"ntac",    PRO_BOOL,                            false,      ON, &settings.dont_tab_align_comments,          &exp_ntac},

    /* Signify end of structure.  */
    {0,         PRO_IGN,                                0, ONOFF_NA, 0,                                          0}
};

#else /* Default to GNU style */

/**
 * Changed to make GNU style the default. 
 */

const pro_ty pro[] =
{
    {"version", PRO_PRSTRING,                           0, ONOFF_NA, VERSION_SETTINGS_IDX,                       &exp_version},
    {"v",       PRO_BOOL,                           false,       ON, &settings.verbose,                          &exp_v},
    {"ut",      PRO_BOOL,                            true,       ON, &settings.use_tabs,                         &exp_ut},
    {"ts",      PRO_INT,                                8, ONOFF_NA, &settings.tabsize,                          &exp_ts},
    {"st",      PRO_BOOL,                           false,       ON, &settings.use_stdout,                       &exp_st},
    {"ss",      PRO_BOOL,                           false,       ON, &settings.space_sp_semicolon,               &exp_ss},
    {"sob",     PRO_BOOL,                           false,       ON, &settings.swallow_optional_blanklines,      &exp_sob},
    {"sc",      PRO_BOOL,                           false,       ON, &settings.star_comment_cont,                &exp_sc},
    {"sbi",     PRO_INT,                                0, ONOFF_NA, &settings.struct_brace_indent,              &exp_sbi},
    {"saw",     PRO_BOOL,                            true,       ON, &settings.space_after_while,                &exp_saw},
    {"sai",     PRO_BOOL,                            true,       ON, &settings.space_after_if,                   &exp_sai},
    {"saf",     PRO_BOOL,                            true,       ON, &settings.space_after_for,                  &exp_saf},
    {"psl",     PRO_BOOL,                            true,       ON, &settings.procnames_start_line,             &exp_psl},
    {"prs",     PRO_BOOL,                           false,       ON, &settings.parentheses_space,                &exp_prs},
#ifdef PRESERVE_MTIME
    {"pmt",     PRO_BOOL,                           false,       ON, &settings.preserve_mtime,                   &exp_pmt},
#endif
    {"pi",      PRO_INT,                               -1, ONOFF_NA, &settings.paren_indent,                     &exp_pi},
    {"pcs",     PRO_BOOL,                            true,       ON, &settings.proc_calls_space,                 &exp_pcs},
    {"orig",    PRO_SETTINGS,                           0, ONOFF_NA, ORIG_SETTINGS_IDX,                          &exp_orig},
    {"o",       PRO_BOOL,                           false,       ON, &settings.expect_output_file,               &exp_o},
    {"nv",      PRO_BOOL,                           false,      OFF, &settings.verbose,                          &exp_v},
    {"nut",     PRO_BOOL,                            true,      OFF, &settings.use_tabs,                         &exp_ut},
    {"nss",     PRO_BOOL,                           false,      OFF, &settings.space_sp_semicolon,               &exp_ss},
    {"nsob",    PRO_BOOL,                           false,      OFF, &settings.swallow_optional_blanklines,      &exp_sob},
    {"nsc",     PRO_BOOL,                           false,      OFF, &settings.star_comment_cont,                &exp_sc},
    {"nsaw",    PRO_BOOL,                            true,      OFF, &settings.space_after_while,                &exp_saw},
    {"nsai",    PRO_BOOL,                            true,      OFF, &settings.space_after_if,                   &exp_sai},
    {"nsaf",    PRO_BOOL,                            true,      OFF, &settings.space_after_for,                  &exp_saf},
    {"npsl",    PRO_BOOL,                            true,      OFF, &settings.procnames_start_line,             &exp_psl},
    {"nprs",    PRO_BOOL,                           false,      OFF, &settings.parentheses_space,                &exp_prs},
    {"npro",    PRO_IGN,                                0, ONOFF_NA, 0,                                          &exp_pro},
#ifdef PRESERVE_MTIME
    {"npmt",    PRO_BOOL,                           false,      OFF, &settings.preserve_mtime,                   &exp_pmt},
#endif
    {"npcs",    PRO_BOOL,                            true,      OFF, &settings.proc_calls_space,                 &exp_pcs},
    {"nlps",    PRO_BOOL,                           false,      OFF, &settings.leave_preproc_space,              &exp_lps},
    {"nlp",     PRO_BOOL,                            true,      OFF, &settings.lineup_to_parens,                 &exp_lp},
    {"nip",     PRO_SETTINGS,                           0, ONOFF_NA, NIP_SETTINGS_IDX,                           &exp_nip},
    {"nhnl",    PRO_BOOL,                            true,      OFF, &settings.honour_newlines,                  &exp_hnl},
    {"ngts",    PRO_BOOL,                           false,      OFF, &settings.gettext_strings,                  &exp_gts},
    {"nfca",    PRO_BOOL,                           false,      OFF, &settings.format_comments,                  &exp_fca},
    {"nfc1",    PRO_BOOL,                           false,      OFF, &settings.format_col1_comments,             &exp_fc1},
    {"neei",    PRO_BOOL,                           false,      OFF, &settings.extra_expression_indent,          &exp_eei},
    {"ndj",     PRO_BOOL,                           false,      OFF, &settings.ljust_decl,                       &exp_dj},
    {"ncs",     PRO_BOOL,                            true,      OFF, &settings.cast_space,                       &exp_cs},
    {"nce",     PRO_BOOL,                           false,      OFF, &settings.cuddle_else,                      &exp_ce},
    {"ncdw",    PRO_BOOL,                           false,      OFF, &settings.cuddle_do_while,                  &exp_cdw},
    {"ncdb",    PRO_BOOL,                           false,      OFF, &settings.comment_delimiter_on_blankline,   &exp_cdb},
    {"nbs",     PRO_BOOL,                           false,      OFF, &settings.blank_after_sizeof,               &exp_bs},
    {"nbfda",   PRO_BOOL,                           false,      OFF, &settings.break_function_decl_args,         &exp_bfda},
    {"nbfde",   PRO_BOOL,                           false,      OFF, &settings.break_function_decl_args_end,     &exp_bfde},
    {"nbc",     PRO_BOOL,                            true,       ON, &settings.leave_comma,                      &exp_bc},
    {"nbbo",    PRO_BOOL,                            true,      OFF, &settings.break_before_boolean_operator,    &exp_bbo},
    {"nbbb",    PRO_BOOL,                           false,      OFF, &settings.blanklines_before_blockcomments,  &exp_bbb},
    {"nbap",    PRO_BOOL,                            true,      OFF, &settings.blanklines_after_procs,           &exp_bap},
    {"nbadp",   PRO_BOOL,                           false,      OFF, &settings.blanklines_after_declarations_at_proctop,  &exp_badp},
    {"nbad",    PRO_BOOL,                           false,      OFF, &settings.blanklines_after_declarations,    &exp_bad},
    {"nbacc",   PRO_BOOL,                           false,      OFF, &settings.blanklines_around_conditional_compilation, &exp_bacc},
    {"linux",   PRO_SETTINGS,                           0, ONOFF_NA, LINUX_SETTINGS_IDX,                         &exp_linux},
    {"lps",     PRO_BOOL,                           false,       ON, &settings.leave_preproc_space,              &exp_lps},
    {"lp",      PRO_BOOL,                            true,       ON, &settings.lineup_to_parens,                 &exp_lp},
    {"lc",      PRO_INT,     DEFAULT_RIGHT_COMMENT_MARGIN, ONOFF_NA, &settings.comment_max_col,                  &exp_lc},
    {"l",       PRO_INT,             DEFAULT_RIGHT_MARGIN, ONOFF_NA, &settings.max_col,                          &exp_l},
    {"kr",      PRO_SETTINGS,                           0, ONOFF_NA, KR_SETTINGS_IDX,                            &exp_kr},
    {"il",      PRO_INT,             DEFAULT_LABEL_INDENT, ONOFF_NA, &settings.label_offset,                     &exp_il},
    {"ip",      PRO_INT,                                5, ONOFF_NA, &settings.indent_parameters,                &exp_ip},
    {"i",       PRO_INT,                                2, ONOFF_NA, &settings.ind_size,                         &exp_i},
    {"hnl",     PRO_BOOL,                            true,       ON, &settings.honour_newlines,                  &exp_hnl},
    {"h",       PRO_BOOL,                               0, ONOFF_NA, NULL,                                       NULL},
    {"gts",     PRO_BOOL,                           false,       ON, &settings.gettext_strings,                  &exp_gts},
    /* This is now the default. */
    {"gnu",     PRO_SETTINGS,                           0, ONOFF_NA, GNU_SETTINGS_IDX,                           &exp_gnu},
    {"fnc",     PRO_BOOL,                           false,       ON, &settings.fix_nested_comments,              &exp_fnc},
    {"fca",     PRO_BOOL,                           false,       ON, &settings.format_comments,                  &exp_fca},
    {"fc1",     PRO_BOOL,                           false,       ON, &settings.format_col1_comments,             &exp_fc1},
    {"eei",     PRO_BOOL,                           false,       ON, &settings.extra_expression_indent,          &exp_eei},
    {"dj",      PRO_BOOL,                           false,       ON, &settings.ljust_decl,                       &exp_dj},
    {"di",      PRO_INT,                                2, ONOFF_NA, &settings.decl_indent,                      &exp_di},
    {"d",       PRO_INT,                                0, ONOFF_NA, &settings.unindent_displace,                &exp_d},
    {"cs",      PRO_BOOL,                            true,       ON, &settings.cast_space,                       &exp_cs},
    {"cp",      PRO_INT,                                1, ONOFF_NA, &settings.else_endif_col,                   &exp_cp},
    {"cli",     PRO_INT,                                0, ONOFF_NA, &settings.case_indent,                      &exp_cli},
    {"ci",      PRO_INT,                                0, ONOFF_NA, &settings.continuation_indent,              &exp_ci},
    {"ce",      PRO_BOOL,                           false,       ON, &settings.cuddle_else,                      &exp_ce},
    {"cdw",     PRO_BOOL,                           false,       ON, &settings.cuddle_do_while,                  &exp_cdw},
    {"cdb",     PRO_BOOL,                           false,       ON, &settings.comment_delimiter_on_blankline,   &exp_cdb},
    {"cd",      PRO_INT,                               33, ONOFF_NA, &settings.decl_com_ind,                     &exp_cd},
    {"cbi",     PRO_INT,                               -1, ONOFF_NA, &settings.case_brace_indent,                &exp_cbi},
    {"c++",     PRO_BOOL,                           false,       ON, &settings.c_plus_plus,                      &exp_cpp},
    {"c",       PRO_INT,                               33, ONOFF_NA, &settings.com_ind,                          &exp_c},
    {"bs",      PRO_BOOL,                           false,       ON, &settings.blank_after_sizeof,               &exp_bs},
    {"brs",     PRO_BOOL,                           false,       ON, &settings.braces_on_struct_decl_line,       &exp_bls},
    {"bls",     PRO_BOOL,                           false,      OFF, &settings.braces_on_struct_decl_line,       &exp_bls},
    {"brf",     PRO_BOOL,                           false,       ON, &settings.braces_on_func_def_line,          &exp_blf},
    {"blf",     PRO_BOOL,                           false,      OFF, &settings.braces_on_func_def_line,          &exp_blf},
    {"bli",     PRO_INT,                                2, ONOFF_NA, &settings.brace_indent,                     &exp_bli},
    {"br",      PRO_BOOL,                           false,       ON, &settings.btype_2,                          &exp_bl},
    {"bl",      PRO_BOOL,                           false,      OFF, &settings.btype_2,                          &exp_bl},
    {"bfda",    PRO_BOOL,                           false,       ON, &settings.break_function_decl_args,         &exp_bfda},
    {"bfde",    PRO_BOOL,                           false,       ON, &settings.break_function_decl_args_end,     &exp_bfde},
    {"bc",      PRO_BOOL,                            true,      OFF, &settings.leave_comma,                      &exp_bc},
    {"bbo",     PRO_BOOL,                            true,       ON, &settings.break_before_boolean_operator,    &exp_bbo},
    {"bbb",     PRO_BOOL,                           false,       ON, &settings.blanklines_before_blockcomments,  &exp_bbb},
    {"bap",     PRO_BOOL,                            true,       ON, &settings.blanklines_after_procs,           &exp_bap},
    {"badp",    PRO_BOOL,                           false,       ON, &settings.blanklines_after_declarations_at_proctop,  &exp_badp},
    {"bad",     PRO_BOOL,                           false,       ON, &settings.blanklines_after_declarations,    &exp_bad},
    {"bacc",    PRO_BOOL,                           false,       ON, &settings.blanklines_around_conditional_compilation, &exp_bacc},
    {"T",       PRO_KEY,                                0, ONOFF_NA, 0,                                          &exp_T},
    {"ppi",     PRO_INT,                                0, ONOFF_NA, &settings.force_preproc_width,              &exp_ppi},
    {"pal",     PRO_BOOL,                            true,      OFF, &settings.pointer_align_right,              &exp_par},
    {"par",     PRO_BOOL,                            true,       ON, &settings.pointer_align_right,              &exp_par},
    {"slc",     PRO_BOOL,                            false,      ON, &settings.allow_single_line_conditionals,   &exp_slc},
    {"as",      PRO_BOOL,                            false,      ON, &settings.align_with_spaces,                &exp_as},
    {"sar",     PRO_BOOL,                            false,      ON, &settings.spaces_around_initializers,       &exp_sar},
    {"ntac",    PRO_BOOL,                            false,      ON, &settings.dont_tab_align_comments,          &exp_ntac},

    /* Signify end of structure.  */
    {0,         PRO_IGN,                                0, ONOFF_NA, 0,                                          0}
};

#endif /* GNU defaults */

typedef struct long_option_conversion
{
    const char *long_name;
    const char *short_name;
} long_option_conversion_ty;

const long_option_conversion_ty option_conversions[] =
{
    {"version",                                     "version"},
    {"verbose",                                     "v"},
    {"usage",                                       "h"},
    {"use-tabs",                                    "ut"},
    {"tab-size",                                    "ts"},
    {"swallow-optional-blank-lines",                "sob"},
    {"struct-brace-indentation",                    "sbi"},
    {"start-left-side-of-comments",                 "sc"},
    {"standard-output",                             "st"},
    {"space-special-semicolon",                     "ss"},
    {"space-after-while",                           "saw"},
    {"space-after-procedure-calls",                 "pcs"},
    {"space-after-parentheses",                     "prs"},
    {"space-after-if",                              "sai"},
    {"space-after-for",                             "saf"},
    {"space-after-cast",                            "cs"},
    {"remove-preprocessor-space",                   "nlps"},
    {"procnames-start-lines",                       "psl"},
#ifdef PRESERVE_MTIME
    {"preserve-mtime",                              "pmt"},
#endif
    {"paren-indentation",                           "pi"},
    {"parameter-indentation",                       "ip"},
    {"output-file",                                 "o"},
    {"output",                                      "o"},
    {"original-style",                              "orig"},
    {"original",                                    "orig"},
    {"no-verbosity",                                "nv"},
    {"no-tabs",                                     "nut"},
    {"no-space-after-while",                        "nsaw"},
    {"no-space-after-parentheses",                  "nprs"},
    {"no-space-after-if",                           "nsai"},
    {"no-space-after-function-call-names",          "npcs"},
    {"no-space-after-for",                          "nsaf"},
    {"no-space-after-cast",                         "ncs"},
    {"no-space-after-casts",                        "ncs"},
    {"no-parameter-indentation",                    "nip"},
    {"no-extra-expression-indentation",             "neei"},
    {"no-gettext-strings",                          "ngts"},
    {"no-comment-delimiters-on-blank-lines",        "ncdb"},
    {"no-blank-lines-before-block-comments",        "nbbb"},
    {"no-blank-lines-after-procedures",             "nbap"},
    {"no-blank-lines-after-procedure-declarations", "nbadp"},
    {"no-blank-lines-after-ifdefs",                 "nbacc"},
    {"no-blank-lines-after-declarations",           "nbad"},
    {"no-blank-lines-after-commas",                 "nbc"},
    {"no-blank-before-sizeof",                      "nbs"},
    {"no-Bill-Shannon",                             "nbs"},
    {"label-offset",                                "il"},
    {"line-length",                                 "l"},
    {"line-comments-indentation",                   "d"},
    {"linux-style",                                 "linux"},
    {"left-justify-declarations",                   "dj"},
    {"leave-preprocessor-space",                    "lps"},
    {"leave-optional-blank-lines",                  "nsob"},
    {"kernighan-and-ritchie-style",                 "kr"},
    {"kernighan-and-ritchie",                       "kr"},
    {"k-and-r-style",                               "kr"},
    {"indent-label",                                "il"},
    {"indentation-level",                           "i"},
    {"indent-level",                                "i"},
    {"ignore-profile",                              "npro"},
    {"ignore-newlines",                             "nhnl"},
    {"honour-newlines",                             "hnl"},
    {"help",                                        "h"},
    {"gettext-strings",                             "gts"},
    {"gnu-style",                                   "gnu"},
    {"fix-nested-comments",                         "fnc"},
    {"format-first-column-comments",                "fc1"},
    {"format-all-comments",                         "fca"},
    {"extra-expression-indentation",                "eei"},
    {"else-endif-column",                           "cp"},
    {"dont-star-comments",                          "nsc"},
    {"dont-space-special-semicolon",                "nss"},
    {"dont-line-up-parentheses",                    "nlp"},
    {"dont-left-justify-declarations",              "ndj"},
    {"dont-indent-parameters",                      "nip"},
    {"dont-format-first-column-comments",           "nfc1"},
    {"dont-format-comments",                        "nfca"},
    {"dont-cuddle-else",                            "nce"},
    {"dont-cuddle-do-while",                        "ncdw"},
    {"dont-break-procedure-type",                   "npsl"},
    {"dont-break-function-decl-args",               "nbfda"},
    {"dont-break-function-decl-args-end",           "nbfde"},
    {"declaration-indentation",                     "di"},
    {"declaration-comment-column",                  "cd"},
    {"cuddle-else",                                 "ce"},
    {"cuddle-do-while",                             "cdw"},
    {"continue-at-parentheses",                     "lp"},
    {"continuation-indentation",                    "ci"},
    {"comment-line-length",                         "lc"},
    {"comment-indentation",                         "c"},
    {"comment-delimiters-on-blank-lines",           "cdb"},
    {"case-indentation",                            "cli"},
    {"case-brace-indentation",                      "cbi"},
    {"c-plus-plus",                                 "c++"},
    {"break-function-decl-args",                    "bfda"},
    {"break-function-decl-args-end",                "bfde"},
    {"break-before-boolean-operator",               "bbo"},
    {"break-after-boolean-operator",                "nbbo"},
    {"braces-on-struct-decl-line",                  "brs"},
    {"braces-on-func-def-line",                     "brf"},
    {"braces-on-if-line",                           "br"},
    {"braces-after-struct-decl-line",               "bls"},
    {"braces-after-func-def-line",                  "blf"},
    {"braces-after-if-line",                        "bl"},
    {"brace-indent",                                "bli"},
    {"blank-lines-before-block-comments",           "bbb"},
    {"blank-lines-after-procedures",                "bap"},
    {"blank-lines-after-procedure-declarations",    "badp"},
    {"blank-lines-after-ifdefs",                    "bacc"},
    {"blank-lines-after-declarations",              "bad"},
    {"blank-lines-after-commas",                    "bc"},
    {"blank-before-sizeof",                         "bs"},
    {"berkeley-style",                              "orig"},
    {"berkeley",                                    "orig"},
    {"Bill-Shannon",                                "bs"},
    {"preprocessor-indentation",                    "ppi"},
    {"pointer-align-right",                         "par"},
    {"pointer-align-left",                          "pal"},
    {"single-line-conditionals",                    "slc"},
    {"align-with-spaces",                           "as"},
    {"spaces-around-initializers",                  "sar"},
    {"dont-tab-align-comments",                     "ntac"},

    /* Signify end of structure.  */
    {0,                                             0},
};

/**
 * Print a brief usage message to stderr and exit.
 */

static void usage (void)
{
   DieError(invocation_error, _("usage: indent file [-o outfile ] [ options ]\n       indent file1 file2 ... fileN [ options ]\n"));
}

/**
 * S1 should be a string.  S2 should be a string, perhaps followed by an
 *  argument.  Compare the two, returning true if they are equal, and if they
 *  are equal set *START_PARAM to point to the argument in S2.  
 */

static BOOLEAN eqin (
    const char   * s1,
    const char   * s2,
    const  char ** start_param)
{
    BOOLEAN ret = true;
    
    while (*s1)
    {
        if (*s1++ != *s2++)
        {
            ret = false;
        }
    }
  
    *start_param = s2;
    return ret;
}

/**
 * Set the defaults. 
 */

void set_defaults(void)
{
    const pro_ty *p;

    for (p = pro; p->p_name; p++)
    {
       if (p->p_obj && (
          ((p->p_type == PRO_BOOL) && (p->p_special == ON)) ||
           (p->p_type == PRO_INT)))
        {
            *(int *)p->p_obj = p->p_default;
        }
    }
}

/**
 * Set the defaults after options set 
 */

void set_defaults_after(void)
{
    if (!exp_lc)                        /* if no -lc option was given */
    {
        settings.comment_max_col = settings.max_col;
    }
}

/**
 *
 */

static void arg_missing(
   const char * option,
   const char * option_source)
{
    DieError(invocation_error, _("%s: missing argument to parameter %s\n"), 
             option_source,
                                                                    option);
}

/*!< Strings which can prefix an option, longest first. */
static const char *option_prefixes[4] = {
    "--",
    "-",
    "+",
    0
};

/**
 * Examine the given argument and return the length of the prefix if the prefix
 * is one of "--", "-", or "+". If no such prefix is present return 0.
 */
static size_t option_prefix(const char *arg)
{
    const char ** prefixes    = option_prefixes;
    const char  * this_prefix = *prefixes;
    const char  * argp        = arg;
    size_t        ret         = 0;

    do
    {
        this_prefix = *prefixes;
        argp = arg;
        
        while (*this_prefix == *argp)
        {
            this_prefix++;
            argp++;
        }
      
        if (*this_prefix == '\0')
        {
            ret = (size_t)(this_prefix - *prefixes);
            break;
        }
    } while (*++prefixes);

    return ret;
}

/**
 * Process an option ARG (e.g. "-l60").  PARAM is a possible value
 * for ARG, if PARAM is non-null.  EXPLICT should be nonzero iff the
 * argument is being explicitly specified (as opposed to being taken from a
 * PRO_SETTINGS group of settings).
 *
 * Returns 1 if the option had a value, returns 0 otherwise.
 *
 * - 2002-06-13 D.Ingamells. Fixed check for int param without an int argument.
 */

extern int set_option(
    const char * option,
    const char * param,
    int          explicit,
    const char * option_source)
{
    const pro_ty * p             = pro;
    const char   * param_start   = NULL;
    size_t         option_length = option_prefix(option);
    int            val           = 0;
    BOOLEAN        found         = false;
    char          *tmp           = NULL;
    const char    *ctmp          = NULL;
    size_t         param_len     = 0;

    if (option_length > 0)
    {
        if ((option_length == 1) && (*option == '-'))
        {
            /* Short option prefix */
            option++;
            
            for (p = pro; p->p_name; p++)
            {
                if ((*p->p_name == *option) &&
                    eqin (p->p_name, option, &param_start))
                {
                    found = true;
                    break;
                }
            }
        }
        else
        {
            /* Long prefix */
            const long_option_conversion_ty *o = option_conversions;

            option += option_length;

            while (o->short_name)
            {
                if (eqin (o->long_name, option, &param_start))
                {
                    break;
                }
                
                o++;
            }

            /* Searching twice means we don't have to keep the two tables in
             * sync. */
            
            if (o->short_name)
            {
                for (p = pro; p->p_name; p++)
                {
                    if (!strcmp (p->p_name, o->short_name))
                    {
                        found = true;
                        break;
                    }
                }
            }
        }
    }

    if (!found)
    {
        DieError(invocation_error, _("%s: unknown option \"%s\"\n"), option_source, option - 1);
    }
    else if (strlen(p->p_name) == 1 && *(p->p_name) == 'h')
    {
        usage();
    }
    else
    {
        /* If the parameter has been explicitly specified, we don't
         * want a group of bundled settings to override the explicit
         * setting.  */
        if (settings.verbose)
        {
            fprintf (stderr, _("option: %s\n"), p->p_name);
        }
        
        if (explicit || !*(p->p_explicit))
        {
            if (explicit)
            {
                *(p->p_explicit) = 1;
            }
            
            switch (p->p_type)
            {
            case PRO_PRSTRING:
                /* This is not really an error, but zero exit values are
                   returned only when code has been successfully formatted. */
                printf(_("GNU indent %s\n"),
                       settings_strings[(size_t)p->p_obj]);
                exit (invocation_error);
                break;
            case PRO_SETTINGS:
                /* current position */
                ctmp = settings_strings[(size_t)p->p_obj];
                do {
                    set_option(ctmp, 0, 0, option_source);
                    /* advance to character following next NUL */
                    while (*ctmp++);
                } while (*ctmp);
                break;
            case PRO_IGN:
                break;
            case PRO_KEY:
                if (*param_start == 0)
                {
                    if (!(param_start = param))
                    {
                       arg_missing(option, option_source);
                    }
                    else
                    {
                        val = 1;
                    }
                }

                param_len = strlen(param_start);
                tmp = xmalloc(param_len + 1);
                memcpy(tmp, param_start, param_len);
                tmp[param_len] = '\0';
                addkey(tmp, rw_decl);
                break;
            case PRO_BOOL:
                if (p->p_special == OFF)
                {
                    *(int *)p->p_obj = false;
                }
                else
                {
                    *(int *)p->p_obj = true;
                }
            
                break;
            case PRO_INT:
                if (*param_start == '\0')
                {
                    param_start = param;
                    
                    if (param_start == NULL)
                    {
                       arg_missing(option, option_source);
                    }
                    else
                    {
                        val = 1;
                    }
                }

                if (isdigit (*param_start) || ((*param_start == '-') && isdigit (*(param_start + 1))))
                {
                    *(int *)p->p_obj = atoi(param_start);
                }
                else
                {
                    DieError(invocation_error,
                             _("%s: option ``%s'' requires a numeric parameter\n"),
                             option_source, option - 1);
                }
                
                break;
            default:
                DieError(invocation_error,
                         _("set_option: internal error: p_type %d\n"),
                         (int) p->p_type);
            }
        }
    }
    
    return val;
}

/**
 * The first 2 characters of a c++ comment have been read skip the remainder of the line
 * and return the first character from the next line.
 */

static int skip_cpp_comment(
    FILE * f)
{

    int i;
    
    do
    {
        i = getc (f);
    } while ((i != EOF) && (i != EOL));

    if (i == EOL)
    {
        i = getc (f);
    }
    
    return i;
}

/**
 * the first 2 characters of a c comment have been read. Read past the
 * remainder of the comment and return the first character after the
 * comment.
 */

static int skip_c_comment(
    FILE * f)
{
    int i = getc (f);
    
    do
    {
        /* skip to the next '*' character */
        
        while ((i != EOF) && (i != '*'))
        {
            i = getc (f);
        }
                        
                        
        if (i == EOF)
        {
            WARNING(_("Profile contains an unterminated comment"), NULL, NULL);
            break;
        }
        /* current char is '*' so skip over it. */
        
        i = getc (f);
        
        /* If the current character is a '/' the comment is over. */
    } while (i != '/');

    if (i != EOF)
    {
        i = getc (f);
    }
    
    return i;
}

/**
 * The starting / of a comment has been read.
 * skip over the rest of the comment and return the
 * first character after the comment.
 */

static int skip_comment(
    FILE * f)
{
    int i = getc (f);
    
    switch (i)
    {
        case '/':
            i = skip_cpp_comment(f);
            break;
        case '*':
            i = skip_c_comment(f);
            break;
        default:
            WARNING (_("Profile contains unpalatable characters"), NULL, NULL);
    }
    
    return i;
}

/**
 * Skip a sequence of space and control characters and return the
 * first character after the sequence.
 */

static int skip_spaces(
    FILE * f,
    int    first)
{
    int    i = first;

    while ((i <= ' ') &&
           (i != EOF))
    {
        i = getc (f);
    }
           
    return i;
}

/**
 * Read a string from the input until the next control character, space or /.
 * Return the first character after the read string.
 */

static int read_string(
    FILE  * f,
    char  * buff,
    int     first)
{
    int i = first;
    char *p = buff;
    
    while ( ( i != EOF) &&
            (i > ' ')   &&
            (i != '/')  &&
            (p < buff + BUFSIZ))
    {
        *(p++) = (char)i;
        i = getc(f);
    }

    *p = EOS;
    return i;
}

/**
 * Scan the options in the file f.
 */
static void scan_profile(
   FILE       * f,
   const char * option_source)
{
    char   b0[BUFSIZ];
    char   b1[BUFSIZ];
    char * current = b0;
    int    i = skip_spaces(f, ' ');

    memset(b0, 0, BUFSIZ);
    memset(b1, 0, BUFSIZ);
    
    while (i != EOF)
    {
        if (i == '/')
        {
            /* The start of a comment. */
            i = skip_comment(f);
        }
        else
        {
            i = read_string(f, current, i);

            /* We've scanned something... */

            if (current == b0)
            {
                /* Second buffer still has to be filled. */
                current = b1;
            }
            else if (set_option(b0, b1, 1, option_source) == 1)
            {
                /* The option had a parameter, thus both values
                 * have been consumed.
                 * Reset the 2 buffers to 'empty'
                 */
                current = b0;
            }
            else
            {
                /* Set option consumed one value. Move the
                 * other value to the first buffer and go get a new
                 * second value.
                 */
                
                strcpy(b0, b1);
                current = b1;
            }
            
        }
        
        i = skip_spaces(f, i);
    }

    if (current != b0)
    {
       set_option (b0, NULL, 1, option_source);
    }
}


/**
 * The name of the profile file if the user doesn't supply an explicit one.
 * NB Some operating systems don't allow more than one dot in a filename. 
 */

#if defined (ONE_DOT_PER_FILENAME)
#define INDENT_PROFILE "indent.pro"
#else
#define INDENT_PROFILE ".indent.pro"
#endif

/**
 * an sprintf format to use to generate the full profile path from a directory and
 * a file name.
 */

#ifndef PROFILE_FORMAT
#define PROFILE_FORMAT "%s/%s"
#endif

/**
 * The name of the environment variable the user can set to supply the name
 * of the profile file.
 */

#define PROFILE_ENV_NAME "INDENT_PROFILE"

/**
 * set_profile looks for the profile file via
 * 1) the profile environment variable
 * 2) looks for ./.indent.pro
 * 3)  $HOME/.indent.pro
 * and reads the options given in that file.  Return the
 * path of the file read.
 *
 * Note that as of version 1.3, indent only reads one file. 
 */

char * set_profile(void)
{
   FILE        * f       = NULL;
   char        * fname   = NULL;
   static char   prof[]  = INDENT_PROFILE;
   char        * homedir = NULL;
   const char  * envname = getenv(PROFILE_ENV_NAME);

   if (envname != NULL)
   {
      f = fopen(envname, "r");

      if (f == NULL)
      {
         fatal(_("File named by environment variable %s does not exist or is not readable"),
               PROFILE_ENV_NAME);
      }
      else
      {
         scan_profile(f, envname);
        
         (void) fclose(f);
        
         fname = strdup(envname);
      }
   }
   else
   {
      f = fopen(INDENT_PROFILE, "r");
        
      if (f != NULL)
      {
         int len = strlen (INDENT_PROFILE) + 3;

         scan_profile (f, INDENT_PROFILE);
         (void) fclose (f);

         fname = xmalloc(len);
         strcpy(fname, "./");
         (void) strcat (fname, INDENT_PROFILE);
      }
      else
      {
         homedir = getenv ("HOME");
    
         if (homedir)
         {
            fname = xmalloc(strlen (homedir) + strlen(PROFILE_FORMAT) + sizeof (prof));
            sprintf (fname, PROFILE_FORMAT, homedir, prof);
                
            if ((f = fopen (fname, "r")) != NULL)
            {
               scan_profile (f, fname);
               (void) fclose (f);
            }
            else
            {
               xfree (fname);
               fname = NULL;
            }
         }
      }
   }
    
   return fname;
}
