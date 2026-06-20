
/*
 * Computer Algebra Kit (c) 1993,2000,14 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: term.h,v 1.10 2014/03/04 09:59:25 stes Exp $
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

#ifndef __CATERM_HEADER__
#define __CATERM_HEADER__

#include "cobject.h"

typedef int unimonom_t;
typedef int unimonom_c;
typedef unsigned unimonom_args;	/* unused */

#define unimonom_isvalue	1
#define unimonom_pervalue	1

@interface Term : CAObject
{
  id scalarZero;
  id coefficient;
  id symbol;
  int exponent;
}
- check;

- _setUpScalarZero:aZero coefficient:aCoefficient symbol:aSymbol exponent:(int)anExponent;
- scalarZero:aScalar coefficient:aCoefficient symbol:aSymbol exponent:(int)anExponent;
+ scalarZero:aZero coefficient:aCoefficient symbol:aSymbol exponent:(int)anExponent;
- scalar:aScalar symbol:aSymbol exponent:(int)anExponent;
+ scalar:aScalar symbol:aSymbol exponent:(int)anExponent;
+ coefficient:aCoefficient symbol:aSymbol exponent:(int)anExponent;
- copy;
- deepCopy;
- clone;
- coefficient:aCoefficient symbol:aSymbol exponent:(int)anExponent;
- coefficient:aCoefficient exponent:(int)anExponent;
- coefficient:aCoefficient;
- symbol:aSymbol exponent:(int)anExponent;

- addSymbolsTo:aCltn;
- scalarZero;
- coefficient;
- (BOOL) isCoefficient;
- symbol;
- (int) exponent;
- (int) degree;
- (unsigned) hash;
- (BOOL) isEqual:b;
- (int) compareSymbols:aTerm;
- (int) compareExponents:b;

- (int) intValue;
- intValue:(int)aValue;
- (float) floatValue;
- floatValue:(float)aValue;
- asScalar;
- scalar:aScalar;
- asSymbol;
- symbol:aSymbol;
- asNumerical;
- asModp:(unsigned short)p;

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
- multiplyScalar:b;
- multiplyCoefficient:b;
- varspsMultiplyCoefficient:b;
- multiply:b;
- divideScalar:b;
- divideCoefficient:b;
- varspsDivideCoefficient:b;
- subtractExponents:b;
- divide:b;

- power:(int)n;
- root:(int)n;
- squareRoot;

- frobenius;
- frobeniusInverse;

- derive;
- integrate;
- substitute:(STR)aSymbol by:aPolynomial;
- makeDegreeDense;
- makeDegreeSparse;
- changeRepresentationTo:aPrototype;
- makeVariableSparse;

- (BOOL) printsLeadingSign;
- (BOOL) printsSum;
- (BOOL) printsProduct;
- printOn:(IOD)aFile;

- fileOutOn:aFiler;
- fileInFrom:aFiler;
@end

#endif /* __CATERM_HEADER__ */
 
