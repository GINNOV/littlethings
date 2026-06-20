
/*
 * Portable Object Compiler (c) 1998.  All Rights Reserved.
 * $Id: stack.h,v 1.1.1.1 2000/06/07 21:09:24 stes Exp $
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

#ifndef __OBJSTACK_H__
#define __OBJSTACK_H__

#include "cltn.h"

@interface Stack : Cltn
{
  id contents;
}

+ new;
+ new:(unsigned)n;
- copy;
- deepCopy;
- emptyYourself;
- freeContents;
- free;

- (unsigned) depth;
- (BOOL) isEmpty;
- eachElement;
- topElement;

- push:anObject;
- pop;
- swap;
- at:(unsigned )anOffset;
- removeAt:(unsigned )anOffset;

- printOn:(IOD)aFile;
@end

#endif /* __OBJSTACK_H__ */
 
