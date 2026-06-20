
/*
 * Portable Object Compiler (c) 1997,98,99.  All Rights Reserved.
 * $Id: rectangl.h,v 1.1.1.1 2000/06/07 21:09:24 stes Exp $
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

#ifndef __OBJRECT_H__
#define __OBJRECT_H__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include <stdio.h>
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

@interface Rectangle : Object
{
  id origin;
  id corner;
}

+ new;
+ origin:p corner:q;
+ origin:p extent:q;
+ origin:(int)x1:(int)y1 corner:(int)x2:(int)y2;
+ origin:(int)x:(int)y extent:(int)w:(int)h;
- free;

- origin:p;
- corner:q;
- origin:p corner:q;
- extent:(int)w:(int)h;
- extent:q;
- origin:(int)x1:(int)y1;
- corner:(int)x1:(int)y1;

- (BOOL) contains:aPoint;
- (unsigned) hash;
- (BOOL) isEqual:aRectangle;

- (int) left;
- (int) right;
- (int) top;
- (int) bottom;
- (int) width;
- (int) height;
- origin;
- topLeft;
- topRight;
- topCenter;
- corner;
- bottomLeft;
- bottomCenter;
- bottomRight;
- center;
- leftCenter;
- rightCenter;
- extent;
- quickMerge:rect;

- moveBy:aPoint;
- translateBy:p;
- align:p1 with:p2;

- printOn:(IOD)aFile;
@end

#endif /* __OBJRECT_H__ */
 
