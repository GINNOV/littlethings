
/*
 * Portable Object Compiler (c) 1997,98,99,2003,09,14.  All Rights Reserved.
 * $Id: ocstring.h,v 1.5 2014/03/04 09:02:28 stes Exp $
 */

/*
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Library General Public License as published 
 * by the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef __OBJSTR_H__
#define __OBJSTR_H__

#include "array.h"

#ifdef _XtIntrinsic_h
#define String OCString		/* remap String class - cant use Xt String */
#endif

typedef struct objstr
  {
    int count;
    int capacity;
    char *ptr;
  }
 *objstr_t;

@interface String : Array
{
  struct objstr value;
}

+ new;
+ new:(unsigned)nChars;
+ str:(STR)aString;
+ chars:(STR)aString count:(int)n;
+ vsprintf:(STR)format:(OC_VA_LIST*)ap;
+ sprintf:(STR)format,...;
- copy;
- deepCopy;
- free;
- release;

- (int) compare:aStr;
- (int) compareSTR:(STR)aString;
- (unsigned) hash;
- (int) dictCompare:aStr;
- (BOOL) isEqual:aStr;
- (BOOL) isEqualSTR:(STR)aString;

- (objstr_t) objstrvalue;
- (unsigned) size;
- (char) charAt:(unsigned)anOffset;
- (char) charAt:(unsigned)anOffset put:(char)aChar;

- (STR) strcat:(STR)aBuffer;
- concat:aString;
- concatSTR:(STR)aString;
- concatenateSTR:(STR)aString;
- at:(unsigned)anOffset insert:(char*)aString count:(int)n;
- at:(unsigned)anOffset insert:aString;
- deleteFrom:(unsigned)p to:(unsigned)q;
- assignSTR:(STR)aString;
- assignSTR:(STR)aString length:(unsigned)nChars;

- (double) asDouble;
- (int) asInt;
- (long) asLong;
- asSTR:(STR)aBuffer maxSize:(int)aSize;
- (STR) str;
- (STR) strCopy;

- toLower;
- toUpper;

- printOn:(IOD)aFile;

#ifdef __PORTABLE_OBJC__
- fileOutOn:aFiler;
- fileInFrom:aFiler;
#endif /* __PORTABLE_OBJC__ */

@end

/* some defs needed when cross-compiling with a DIFFERENT compiler */
/* placed this here 'cause we will have a different objcrt.h and Object.h */

#if !defined(__PORTABLE_OBJC__)
#if !defined(OCLONGLONG)

void *OC_Malloc (size_t);	/* allocate memory from the system */
void *OC_Realloc (void *, size_t);	/* reallocate memory from the system */

#endif /* OCLONGLONG */

void *OC_Calloc (size_t);	/* clear memory */
void *OC_MallocAtomic (size_t);	/* allocate memory from the system */
void *OC_Free (void *data);	/* deallocate OC_Malloc'ed memory and return NULL */

#endif /* __PORTABLE_OBJC__ */

#endif /* __OBJSTR_H__ */
 
