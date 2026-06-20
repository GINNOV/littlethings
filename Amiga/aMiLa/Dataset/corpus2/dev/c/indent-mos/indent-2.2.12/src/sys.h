/** \file
 * Copyright (c) 1999 Carlo Wood.  All rights reserved.<br>
 * Copyright (c) 1993, 1994 Joseph Arceneaux.  All rights reserved.
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

#ifndef SYS_H
#define SYS_H

#ifdef HAVE_CONFIG_H
   #include "config.h"
#endif

#ifdef STDC_HEADERS
   #include <string.h>
#else
   #ifndef HAVE_STRCHR
      #define strchr index
      #define strrchr rindex
   #endif

   char *strchr (), *strrchr ();

   #ifndef HAVE_MEMCPY
      #include <strings.h>
      #define memcpy(d, s, n) bcopy ((s), (d), (n))
   #endif

   #ifndef HAVE_MEMMOVE
      #include <strings.h>
      #define memmove(d, s, n) bcopy ((s), (d), (n))
   #endif
#endif

#include <stdio.h>

/* Values of special characters. */
#define TAB '\t'
#define EOL '\n'
#define EOS '\0'
#define BACKSLASH '\\'
#define NULL_CHAR '\0'

#ifdef DEBUG
   extern int debug;
#endif

#if 'A' == 0xC1	/* Automatic detection of underlying EBCDIC codeset */
   #define CHARSET_EBCDIC
#endif

#ifdef __MSDOS__
   #define ONE_DOT_PER_FILENAME 1
#endif /* __MSDOS__ */

#if defined(HAVE_UTIME) && (defined(HAVE_UTIME_H) || defined(HAVE_SYS_UTIME_H))
   #define PRESERVE_MTIME 1
#endif

/* Donated by Carlo Wood from `libcw'.  All rights reserved. */
#if !defined(__GNUC__) || (__GNUC__ < 2) || (__GNUC__ == 2 && __GNUC_MINOR__ < 7)
   #define __attribute__(x)
#endif

#define RCSTAG_CC(string) static char rcs_ident[] __attribute__ ((unused)) = string

#ifdef __STDC__
   #define RCSTAG_H(name, string) static const char \
                          rcs_ident_##name##_h[] __attribute__ ((unused)) = string
#else
   #define RCSTAG_H(name, string) /**/
#endif

RCSTAG_H (sys, "$Id$");

#endif
