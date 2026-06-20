
/*
 * Portable Object Compiler (c) 1997,98,99.  All Rights Reserved.
 * $Id: point.h,v 1.1.1.1 2000/06/07 21:09:25 stes Exp $
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

#ifndef __OBJPOINT_H__
#define __OBJPOINT_H__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include <stdio.h>
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

@interface Point : Object
{
  int xLoc;
  int yLoc;
}

+ new;
+ x:(int)x y:(int)y;

- x:(int)x y:(int)y;
- x:(int)x;
- y:(int)y;
- (int) x;
- (int) y;

- (unsigned) hash;
- (BOOL) isEqual:aPoint;
- (BOOL) isBelow:aPoint;
- (BOOL) isAbove:aPoint;
- (BOOL) isLeft:aPoint;
- (BOOL) isRight:aPoint;

- moveBy:aPoint;
- moveBy:(int)x:(int)y;
- moveTo:aPoint;
- plus:aPoint;
- translateBy:aPoint;

- printOn:(IOD)aFile;
#ifdef __PORTABLE_OBJC__
- fileOutOn:aFiler;
- fileInFrom:aFiler;
#endif /* __PORTABLE_OBJC__ */

@end

#endif /* __OBJPOINT_H__ */
 
