/*
   defs.h -- various useful macros and definitions
   Copyright 2000, Chris F.A. Johnson

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

*/

#ifndef DEFS_H
#define DEFS_H

#include "string.h"

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifdef max
#undef max
#endif
#define max(x, y) (((x) > (y)) ? (x) : (y))

#ifdef min
#undef min
#endif
#define min(x, y) (((x) > (y)) ? (x) : (y))

#ifdef toupper
#undef toupper
#endif
#define toupper(c)      ( islower(c) ? (c) - 'a' + 'A' : (c) )

#ifdef tolower
#undef tolower
#endif
#define tolower(c)      ( isupper(c) ? (c) - 'A' + 'a' : (c) )

#define longer(a,b)  (( strlen(a) >  strlen(b) ? a : b)
#define shorter(a,b) (( strlen(a) >  strlen(b) ? b : a)

#define greater(a,b) (((b) > (a)) ? (b) : (a))
#define lesser(a,b)  (((a) > (b)) ? (b) : (a))

#ifndef eq_str
#define eq_str(a,b) (!strcmp((a),(b)))
#endif

#ifndef neq_str
#define neq_str(a,b) (strcmp((a),(b)))
#endif

#ifndef eq_nstr
#define eq_nstr(x,y,n) (strncmp((x),(y),(n)) == 0)
#endif

#ifndef eq_nstr
#define eq_nstr(x,y,n) (strncmp((x),(y),(n)) == 0)
#endif

#define isHexString( s ) ( ((s)[0] == '0') && toupper( (s)[1] ) == 'X' )

#define NULLRETURN(n) if ((n) == NULL) return NULL

#define VBIT0		  0x00000100
#define VBIT1		  0x00000200
#define VBIT2		  0x00000400
#define VBIT3		  0x00000800
#define VBIT4		  0x00001000
#define VBIT5		  0x00002000
#define VBIT6		  0x00004000
#define VBIT7		  0x00008000
#define VBIT8		  0x00010000
#define VBIT9		  0x00020000
#define VBIT10		  0x00040000
#define VBIT11		  0x00080000
#define VBIT12		  0x00100000
#define VBIT13		  0x00200000
#define VBIT14		  0x00400000
#define VBIT15		  0x00800000

#define FOPEN		  0x01000000
#define FUNCTION_ENTRY	  0x02000000
#define SHOW_VERBOSE	  0x04000000
#define HELP_LONG	  0x08000000

#define SHOW_VERSION	  0x10000000
#define SHOW_USAGE	  0x20000000
#define SHOW_USAGE_LONG   0x40000000

#define VERBOSE_DEFAULT   1
#define VERBOSE_ALL	  0xFFFFFFFF

#define  r_mode 	  "r"
#define  rplus_mode	  "r+"
#define  w_mode 	  "w"
#define  wplus_mode	  "w+"
#define  a_mode 	  "a"
#define  aplus_mode	  "a+"

#define MAX		  128
#define WORD_MAX	  128
#define DICPATH 	  "/usr/share/dict"

extern unsigned int verbose;
extern char *progname;

#endif
/* DEF_H */
