
/*
 * Computer Algebra Kit (c) 1993,2000,14 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: fraction.h,v 1.9 2014/03/04 09:09:34 stes Exp $
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

#ifndef __CAFRACTION_HEADER__
#define __CAFRACTION_HEADER__

#include "cobject.h"

@interface Fraction : CAObject
{
  id numerator;
  id denominator;
}
- check;

- totalFraction:aNumerator;
+ totalFraction:aNumerator;
- _setUpNumerator:aNumerator denominator:aDenominator;
+ numerator:aNumerator denominator:aDenominator;
- copy;
- setnumerator:n denominator:d;
- deepCopy;
- numerator:n denominator:d;
- numerator:aNumerator;
- denominator:aDenominator;
- denominator:aNumerator numerator:aDenominator;
- numerator:aNumerator numerator:aDenominator;

- numerator;
- denominator;
- (unsigned) hash;
- (BOOL) isEqual:b;
- (int) compare:b;

- asNumerical;
- asModp:(unsigned short)p;
- asIntegral;

- zero;
- (BOOL) isZero;
- (BOOL) isOpposite:b;
- negate;
- double;
- add:b;
- subtract:b;

- one;
- (BOOL) isOne;
- (BOOL) isMinusOne;
- square;
- inverse;
- multiply:b;
- divide:b;
- power:(int)n;

- intValue:(int)intValue;
- (int) intValue;
- multiplyIntValue:(int)intValue;
- divideIntValue:(int)intValue;

- (BOOL) printsLeadingSign;
- (BOOL) printsSum;
- (BOOL) printsProduct;
- printOn:(IOD)aFile;
@end

#endif /* __CAFRACTION_HEADER__ */
 
