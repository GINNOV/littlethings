/** \file
 * Copyright (C) 2015 Tim Hentenaar. All rights reserved.
 * Copyright (c) 1993,1994, Joseph Arceneaux.  All rights reserved.
 *
 * Copyright (C) 1986, 1989, 1992 Free Software Foundation, Inc. All rights
 * reserved.
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
 */

#include "sys.h"
#include "indent.h"
#include "globs.h"
#include "parse.h"

#ifdef HAVE_MALLOC_H
#include <malloc.h>
#endif
#include <stdlib.h>
#include <errno.h>

RCSTAG_CC ("$Id$");

/**
 * Like malloc but get error if no storage available.  size really should be
 * size_t, but not all systems have size_t, so I hope "unsigned" will work.
 * It works for GNU style machines, where it is 32 bits, and works on
 * MS-DOS.  */
extern void *xmalloc (unsigned int size)
{
    void *val = calloc(1, size);

    if (!val)
    {
        fprintf(stderr, _("indent: Virtual memory exhausted.\n"));
        do_exit(system_error);
    }

#if defined (DEBUG)
    /* Fill it with garbage to detect code which depends on stuff being
       zero-filled.  */
    memset(val, 'x', size);
#endif

    return val;
}

/**
 * Like realloc but get error if no storage available. 
 */
extern void *xrealloc(void *ptr, unsigned int size)
{
    void *val = realloc(ptr, size);

    if (!val)
    {
        fprintf(stderr, _("indent: Virtual memory exhausted.\n"));
        do_exit(system_error);
    }

    return val;
}

/**
 * Free and nullify a pointer allocated with xmalloc().
 */
extern void xfree(void *ptr)
{
    if (!ptr)
    {
#if defined(DEBUG)
        fprintf(stderr, "indent: Attempting to free a NULL pointer.\n");
#endif
        return;
    }

    free(ptr);
}

/**
 * Write a message to stderr.
 *
 * \param[in] kind   "Warning" or "Error"
 * \param[in] string Format string
 * \param[in] a0     First value to format, or NULL.
 * \param[in] a1     Second value to format, or NULL.
 */
extern void message(char *kind, char *string, char *a0, char *a1)
{
    if (kind)
    {
        fprintf (stderr, _("indent: %s:%d: %s:"), in_name, line_no, kind);
    }

    fprintf (stderr, string, a0, a1);
    fprintf (stderr, "\n");
}

/**
 * Wrapper around exit to ensure things get
 * cleaned up.
 */
extern void do_exit(int code)
{
    uninit_parser();
    cleanup_user_specials();
    exit(code);
}

/**
 * Print a fatal error message and exit, or, if compiled with
 * "DEBUG" defined, abort ().
 */

extern void fatal (
    const char *string,
    const char *a0)
{
    fprintf (stderr, _("indent: Fatal Error: "));
    fprintf (stderr, string, a0);
    fprintf (stderr, "\n");

#ifdef DEBUG
    abort ();
#endif /* DEBUG */

    if (errno)
    {
        fprintf (stderr, _("indent: System Error: "));
        perror (0);
    }

    do_exit (indent_fatal);
}
