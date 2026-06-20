
/*
 * Portable Object Compiler (c) 1997,98,99,2003.  All Rights Reserved.
 * $Id: ordcltn.h,v 1.6 2004/10/23 15:53:40 stes Exp $
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

#ifndef __OBJCLTN_H__
#define __OBJCLTN_H__

#include "cltn.h"

/* full name */
#define OrderedCollection OrdCltn

typedef struct objcol
  {
    int count;
    int capacity;
    id *ptr;
  }
 *objcol_t;

@interface OrdCltn : Cltn
{
  struct objcol value;
}

+ new;
+ new:(unsigned)n;
+ with:(int)nArgs,...;
+ with:firstObject with:nextObject;
+ add:firstObject;
- copy;
- deepCopy;
- emptyYourself;
- freeContents;
- free;

- (unsigned) size;
- (BOOL) isEmpty;
- (unsigned) lastOffset;
- eachElement;
- firstElement;
- lastElement;

- (BOOL) isEqual:aCltn;

- add:anObject;
- addFirst:newObject;
- addLast:newObject;
- addIfAbsent:anObject;
- addIfAbsentMatching:anObject;

- at:(unsigned )anOffset insert:anObject;
- insert:newObject after:oldObject;
- insert:newObject before:oldObject;

- after:anObject;
- before:anObject;
- at:(unsigned )anOffset;
- at:(unsigned )anOffset put:anObject;

- removeFirst;
- removeLast;
- removeAt:(unsigned )anOffset;
- removeAtIndex:(unsigned )anOffset;
- remove:oldObject;
#if OBJC_BLOCKS
- remove:oldObject ifAbsent:exceptionBlock;
#endif /* OBJC_BLOCKS */


- (BOOL) includesAllOf:aCltn;
- (BOOL) includesAnyOf:aCltn;

- addAll:aCltn;
- addContentsOf:aCltn;
- addContentsTo:aCltn;
- removeAll:aCltn;
- removeContentsFrom:aCltn;
- removeContentsOf:aCltn;

- intersection:bag;
- union:bag;
- difference:bag;

- asSet;
- asOrdCltn;

#if OBJC_BLOCKS
- detect:aBlock;
- detect:aBlock ifNone:noneBlock;
- select:testBlock;
- reject:testBlock;
- collect:transformBlock;
- (unsigned) count:aBlock;
#endif /* OBJC_BLOCKS */


- elementsPerform:(SEL)aSelector;
- elementsPerform:(SEL)aSelector with:anObject;
- elementsPerform:(SEL)aSelector with:anObject with:otherObject;
- elementsPerform:(SEL)aSelector with:anObject with:otherObject with:thirdObj;

#if OBJC_BLOCKS
- do:aBlock;
- do:aBlock until:(BOOL*)flag;
- reverseDo:aBlock;
#endif /* OBJC_BLOCKS */


- find:anObject;
- findMatching:anObject;
- (BOOL) includes:anObject;
- findSTR:(STR )aString;
- (BOOL) contains:anObject;
- (unsigned) offsetOf:anObject;

- printOn:(IOD)aFile;

#ifdef __PORTABLE_OBJC__
- fileOutOn:aFiler;
- fileInFrom:aFiler;
#endif /* __PORTABLE_OBJC__ */

@end

#endif /* __OBJCLTN_H__ */
 
