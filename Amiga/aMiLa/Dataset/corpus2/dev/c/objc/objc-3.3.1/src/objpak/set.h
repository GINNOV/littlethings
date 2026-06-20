
/*
 * Portable Object Compiler (c) 1997,98,2003.  All Rights Reserved.
 * $Id: set.h,v 1.4 2009/10/23 19:36:44 stes Exp $
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

#ifndef __OBJSET_H__
#define __OBJSET_H__

#include "cltn.h"

typedef struct objset
  {
    int count;
    int capacity;
    id *ptr;
  }
 *objset_t;

@interface Set : Cltn
{
  struct objset value;
}

+ new;
+ new:(unsigned)n;
+ with:(int)nArgs,...;
+ with:firstObject with:nextObject;
+ add:firstObject;
- copy;
- deepCopy;
- emptyYourself;
- addYourself;
- freeContents;
- freeAll;
- free;
- release;

- (objset_t) objsetvalue;
- (unsigned) size;
- (BOOL) isEmpty;
- eachElement;

- (unsigned) hash;
- (BOOL) isEqual:set;

- add:anObject;
- addNTest:anObject;
- filter:anObject;
#if OBJC_BLOCKS
- add:anObject ifDuplicate:aBlock;
#endif /* OBJC_BLOCKS */

- replace:anObject;

- remove:oldObject;
- remove:oldObject ifAbsent:exceptionBlock;

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
#endif /* OBJC_BLOCKS */


- find:anObject;
- (BOOL) contains:anObject;
- (BOOL) includes:anObject;
- (unsigned) occurrencesOf:anObject;

- printOn:(IOD)aFile;

#ifdef __PORTABLE_OBJC__
- fileOutOn:aFiler;
- fileInFrom:aFiler;
- awakeFrom:aFiler;
#endif /* __PORTABLE_OBJC__ */

@end

#endif /* __OBJSET_H__ */
 
