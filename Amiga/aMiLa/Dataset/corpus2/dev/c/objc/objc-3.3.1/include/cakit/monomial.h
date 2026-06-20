
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: monomial.h,v 1.5 2014/03/04 09:15:17 stes Exp $
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

#ifndef __CAMONOMIAL_HEADER__
#define __CAMONOMIAL_HEADER__

#include "cobject.h"

@interface Monomial : CAObject
{
  id scalar;
  id termOne;
  id terms;
  id _symbols;
  id _leadingTerm;
}

+ scalar:aScalar;
+ scalar:aScalar symbols:aCltn;
- empty;
- copy;
- deepCopy;

- (int) intValue;
- intValue:(int)aValue;
- (float) floatValue;
- floatValue:(float)aValue;
- asScalar;
- asSymbol;

- scalar;
- termOne;
- (BOOL) isMonic;
- (BOOL) isVariableSparse;
- (BOOL) isVariableDense;
- (int) degree;
- (int) numTerms;
- (BOOL) isTerm;
- (BOOL) isEqual:aMonomial;
- (unsigned) hash;

- symbols;
- (BOOL) isOrderDegreeCompatible;
- (BOOL) isOrderReverseDegreeCompatible;
- (int) compareTerms:aMonomial;

- removeTerm;
- insertTerm:aTerm;

- eachTerm;
- leadingTerm;

- zero;
- (BOOL) isZero;
- negate;
- double;
- add:b;
- subtract:b;

- one;
- (BOOL) isOne;
- (BOOL) isMinusOne;
- square;
- multiply:b;
- multiplyScalar:s;
- divideScalar:s;
- divide:aMonomial;
- divideTerms:aMonomial;

- gcd:aMonomial;
- lcm:aMonomial;

- frobenius;
- frobeniusInverse;

- (BOOL) printsLeadingSign;
- (BOOL) printsSum;
- (BOOL) printsProduct;
- printOn:(IOD)aFile;
@end

#endif /* __CAMONOMIAL_HEADER__ */
 
