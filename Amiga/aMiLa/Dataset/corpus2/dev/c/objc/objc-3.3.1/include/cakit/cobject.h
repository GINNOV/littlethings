
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: cobject.h,v 1.7 2000/10/12 14:40:25 stes Exp $
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

#ifndef __CAOBJECT_HEADER__
#define __CAOBJECT_HEADER__

#include "stdio.h"

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include "Object.h"
#endif

@interface CAObject : Object
{
  STR _str;
}

+ (STR) cakitRevision;
+ str:(STR)aString;
+ int:(int)intValue;
- copy;
- deepCopy;

- (BOOL) sameClass:a;
- (BOOL) differentClass:a;
- (BOOL) isKindOfSequence;

- (STR) str;
- str:(STR)aString;
- (int) intValue;
- intValue:(int)i;
- asModp:(unsigned short)p;
- (BOOL) isFloatingPoint;
- asNumerical;
- (float) floatValue;
- floatValue:(float)f;
- asTotalFraction;
- asScalar;
- asSymbol;

- (BOOL) isEqual:a;
- (BOOL) notEqual:a;

- (BOOL) inOrderedSet;
- (int) compare:b;
- (int) sign;
- (BOOL) isLess:a;
- (BOOL) isGreater:a;
- (BOOL) isLessEqual:a;
- (BOOL) isGreaterEqual:a;
- absValue;

- (BOOL) inAdditiveSemiGroup;
- (BOOL) inAdditiveMonoid;
- (BOOL) inAdditiveGroup;
- (BOOL) isZero;
- (BOOL) notZero;
- (BOOL) isOpposite:b;
- (BOOL) notOpposite:b;
- zero;
- negate;
- add:b;
- subtract:b;
- increment;
- decrement;
- multiplyIntValue:(int)b;
- double;
- quadruple;
- divideIntValue:(int)b;
- half;
- quarter;

- (BOOL) commutes;
- (BOOL) commutesWith:b;
- (BOOL) inSemiGroup;
- (BOOL) inMonoid;
- (BOOL) inGroup;
- one;
- minusOne;
- (BOOL) isOne;
- (BOOL) notOne;
- (BOOL) isMinusOne;
- (BOOL) notMinusOne;
- square;
- multiply:b;
- power:(int)n;
- inverse;
- (BOOL) isUnit;
- (BOOL) notUnit;
- divide:b;

- remainder:b quotient:(id *)q;
- remainder:b;
- quotient:b;

- (BOOL) inEuclideanDomain;
- (BOOL) isCoprime:b;
- (BOOL) notCoprime:b;
- (BOOL) isGcd:a:b;
- (BOOL) isLcm:a:b;
- gcd:b;
- bezout:b gcd:(id *)gcd;
- lcm:b;

- modulo:m;
- multiply:b modulo:m;
- squareModulo:m;
- power:(int)n modulo:m;
- genpower:n modulo:m;
- inverseModulo:m;

- random;

- (int) characteristic;
- (BOOL) isCharacteristicZero;
- (BOOL) notCharacteristicZero;
- (BOOL) isCharacteristicTwo;
- (BOOL) notCharacteristicTwo;
- frobenius;
- frobeniusInverse;
- (int) dimensionOverPrimeField;

- (BOOL) inRing;
- (BOOL) inIntegralDomain;
- (BOOL) inField;
- (BOOL) inFieldOfFractions;

- scalarZero;
- scalarContent;
- divideScalarContent;
- multiplyScalar:s;
- divideScalar:s;
- addScalar:s;
- subtractScalar:s;

- (BOOL) printsLeadingSign;
- (BOOL) printsSum;
- (BOOL) printsProduct;
- printOn:(IOD)aFile;
@end

#endif /* __CAOBJECT_HEADER__ */
 
