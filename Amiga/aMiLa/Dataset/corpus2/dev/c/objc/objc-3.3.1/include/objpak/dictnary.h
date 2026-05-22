
/*
 * Portable Object Compiler (c) 1997,98.  All Rights Reserved.
 * $Id: dictnary.h,v 1.4 2009/10/23 19:36:43 stes Exp $
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

#ifndef __OBJDIC_H__
#define __OBJDIC_H__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include <stdio.h>
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

@interface Dictionary : Object
{
  id associations;
}

+ new;
- copy;
- deepCopy;
- emptyYourself;
- freeContents;
- freeAll;
- free;

- (unsigned) size;
- (BOOL) isEmpty;
- (BOOL) includesKey:aKey;

- (unsigned) hash;
- (BOOL) isEqual:aDic;

- atKey:aKey;
- atKey:aKey ifAbsent:exceptionBlock;
- atKeySTR:(STR)strKey;
- atKey:aKey put:anObject;
- atKeySTR:(STR)strKey put:anObject;
- eachKey;
- eachValue;

- removeKey:key;
- removeKey:key ifAbsent:aBlock;

#if OBJC_BLOCKS
- keysDo:aBlock;
#endif /* OBJC_BLOCKS */


- printOn:(IOD)aFile;
@end

#endif /* __OBJDIC_H__ */
 
