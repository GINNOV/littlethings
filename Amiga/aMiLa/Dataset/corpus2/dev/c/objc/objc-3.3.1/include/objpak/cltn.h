
/*
 * Portable Object Compiler (c) 1997,98,2003.  All Rights Reserved.
 * $Id: cltn.h,v 1.3 2009/10/23 19:36:43 stes Exp $
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

#ifndef __CLTN_H__
#define __CLTN_H__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include <stdio.h>		/* FILE */
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

@interface Cltn : Object
{
}
+ with:(int)nArgs,...;
+ with:firstObject with:nextObject;
+ add:firstObject;

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

@end

#endif /* __CLTN_H__ */
 
