/** \file
 * Copyright (c) 1999 Carlo Wood.  All rights reserved.
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

#ifndef INDENT_GLOBS_H
#define INDENT_GLOBS_H

#include "sys.h" /* for RCSTAG_H */
RCSTAG_H (globs, "$Id$");

/* *Warning messages:  indent continues */
#define WARNING(s, a, b) \
    message(_("Warning"), s, (char *)(a), (char *)(b))

/** Error messages: indent stops processing the current file. */
#define ERROR(s, a, b) \
    message(_("Error"), s, (char *)(a), (char *)(b))

extern void *xmalloc(unsigned int size);
extern void *xrealloc(void *ptr, unsigned int size);
extern void xfree(void *ptr);
extern void do_exit(int code);
extern void fatal(const char *string, const char *a0);
extern void message(char *kind, char *string, char *a0, char *a1);

#endif /* INDENT_GLOBS_H */
