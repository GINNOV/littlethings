/*
 *   (C) COPYRIGHT International Business Machines Corp. 1993
 *   All Rights Reserved
 *   Licensed Materials - Property of IBM
 *   US Government Users Restricted Rights - Use, duplication or
 *   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose and without fee is hereby granted, provided
// that the above copyright notice appear in all copies and that both that
// copyright notice and this permission notice appear in supporting
// documentation, and that the name of I.B.M. not be used in advertising
// or publicity pertaining to distribution of the software without specific,
// written prior permission. I.B.M. makes no representations about the
// suitability of this software for any purpose.  It is provided "as is"
// without express or implied warranty.
//
// I.B.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL I.B.M.
// BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Author:  John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/


#ifndef _Global_h
#define _Global_h

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#ifdef WIN32
#include <windows.h>
#undef RGB
#endif


#include <stddef.h>
#define offsetof2(type,field1,field2)\
        ((int)(((char *)(&((((type *)NULL)->filed1)->field2))) -((char *) NULL)))


#define CheckMalloc(ptr) \
        if ((void*)(ptr) == NULL) { \
	    printf("GLperf: malloc failed on line %d in file %s\n", __LINE__, __FILE__); \
	    exit(0); \
	}

#ifndef min
  #define min(x,y) (((x)>(y))?(y):(x))
#endif

#ifndef max
  #define max(a,b) (((a)>(b))?(a):(b))
#endif

#define Int			0
#define Float			1
#define Unsigned		2
#define String			3
#define PrintFString		4

#define InvalidValue		0
#define InvalidProperty		1
#define ApplySuccessful		2
#define PropertyNotSettable	3

#define WildCard		999

#ifdef WIN32
#pragma warning(disable : 4244)     // X86
#pragma warning(disable : 4101)     // X86
#endif

#endif
