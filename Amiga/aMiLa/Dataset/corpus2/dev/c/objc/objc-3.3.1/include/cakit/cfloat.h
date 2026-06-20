
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: cfloat.h,v 1.3 2000/09/09 10:33:52 stes Exp $
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

#ifndef __CAFLOAT_HEADER__
#define __CAFLOAT_HEADER__

#include "cobject.h"

typedef float float_t;

@interface Float : CAObject
{
  float_t value;
}

+ new;
+ floatValue:(float)floatValue;
+ str:(STR)aString;

- (unsigned) hash;
- (BOOL) isEqual:b;
- (float) floatValue;
- floatValue:(float)f;

- (int) sign;
- (int) compare:b;

- zero;
- (BOOL) isZero;
- (BOOL) isOpposite:b;
- negate;
- double;
- add:b;
- subtract:b;

- one;
- minusOne;
- (BOOL) isOne;
- (BOOL) isMinusOne;
- square;
- multiply:b;
- inverse;
- divide:b;

- (BOOL) printsLeadingSign;
- printOn:(IOD)aFile;
@end

#endif /* __CAFLOAT_HEADER__ */
 
