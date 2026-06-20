
/*
 * Computer Algebra Kit (c) 1994,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: ccltn.h,v 1.3 2000/10/12 14:40:25 stes Exp $
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

#ifndef __CACOLLECTION_HEADER__
#define __CACOLLECTION_HEADER__

#include "cobject.h"

typedef id *mmbs_t;

typedef struct cltn
  {
    int count;
    int capacity;
    mmbs_t members;
  }
 *cltn_t;

@interface CACollection : CAObject
{
  struct cltn value;
}

+ new;
+ new:(unsigned)aCapacity;
- empty;
- copy;
- deepCopy;

- (BOOL) isEqual:aCollection;
- (unsigned) hash;
- (BOOL) isEmpty;
- (BOOL) notEmpty;
- (unsigned) size;

- add:anObject;
- addIfAbsent:anObject;
- at:(unsigned)i insert:anObject;

- removeLast;
- removeAt:(unsigned)i;
- remove:anObject;

- at:(unsigned)i put:anObject;
- swapElementsAt:(int)i:(int)j;

- eachElement;
- eachElementReversed;
- at:(unsigned)i;
- (float) floatValueAt:(int)i;
- (int) intValueAt:(int)i;
- lastElement;
- (unsigned) offsetOf:anObject;

- merge:aCltn;
- union:aCltn;

- printOn:(IOD)aFile;
@end

#endif /* __CACOLLECTION_HEADER__ */
 
