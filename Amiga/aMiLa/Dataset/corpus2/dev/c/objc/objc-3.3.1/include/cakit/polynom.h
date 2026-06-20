
/*
 * Computer Algebra Kit (c) 1993,2000,14 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: polynom.h,v 1.10 2014/03/04 14:39:43 stes Exp $
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

#ifndef __CAPOLYNOMIAL_HEADER__
#define __CAPOLYNOMIAL_HEADER__

#include "cobject.h"

@interface Polynomial : CAObject
{
  id scalarZero;
  id termZero;
  id monomialZero;
  id carrier;
  id _symbols;
  id _variables;
  id _zero;
  id _one;
  id _leadingTerm;
  id _leadingMonomial;
}

+ scalar:aScalar;
- copy;
- deepCopy;
- empty;

- scalarZero;
- termZero;
- monomialZero;
- (unsigned) hash;
- (BOOL) isEqual:b;
- (BOOL) isRecursive;
- (BOOL) isExpanded;
- (BOOL) isVariableSparse;
- (BOOL) isVariableDense;
- (BOOL) isDegreeDense;
- (BOOL) isDegreeSparse;
- (BOOL) isUnivariate;
- (BOOL) inUnivariateDomain;
- (BOOL) isMultivariate;

- (int) intValue;
- intValue:(int)aValue;
- (float) floatValue;
- floatValue:(float)aValue;
- asScalar;
- asSymbol;
- asTerm;
- asMonomial;
- asCoefficient;
- asNumerical;
- asModp:(unsigned short)p;

- symbols;

- (int) degree;
- (int) order;

- (int) numTerms;
- (int) numMonomials;

- removeTerm;
- insertTerm:aTerm;
- removeMonomial;
- insertMonomial:aMonomial;

- eachTerm;
- eachMonomial;
- eachSequence;
- eachScalar;
- eachCoefficient;

- makeDegreeDense;
- makeDegreeSparse;
- makeRecursive;
- makeExpanded;
- makeVariableSparse;
- makeVariableDense;
- collect:symbols;

- leadingTerm;
- leadingCoefficient;
- (int) leadingSign;
- leadingMonomial;
- leadingScalar;

- (BOOL) isMonic;
- (BOOL) notMonic;
- makeMonic;

- zero;
- (BOOL) isZero;
- (BOOL) isOpposite:b;
- negate;
- double;
- add:b;
- subtract:b;
- addScalar:s;
- subtractScalar:s;

- one;
- (BOOL) isOne;
- (BOOL) isMinusOne;
- multiply:b;
- square;
- inverse;
- multiplyScalar:s;
- divideScalar:s;
- multiplyCoefficient:aCoefficient;
- divideCoefficient:aCoefficient;
- multiplyTerm:aTerm;
- divideTerm:aTerm;
- multiplyMonomial:s;
- divideMonomial:s;

- remainder:b quotient:(id *)q;
- divide:b;

- pseudoRemainder:b quotient:(id *)q;
- pseudoRemainder:b;

- content;
- divideContent;
- coefficientContent;
- divideCoefficientContent;
- termContent;
- monomialContent;

- gcd:b;
- resultant:b;
- resultant:b wrt:(STR)aSymbol;
- discriminant;

- (int) numRealRoots;
- (int) varRealRoots:g;

- (BOOL) isSquareFree;
- factorSquareFree;

- truncateAtDegree:(int)d;

- frobenius;
- frobeniusInverse;

- evaluate:aScalar;
- evaluate:(STR)aSymbol at:aScalar;
- evaluateAll:cltnOfScalars;
- substitute:aPolynomial;
- substitute:(STR)aSymbol by:aPolynomial;
- substituteAll:cltnOfPolynomials;

- derive;
- deriveWrt:(STR)aSymbol;
- integrate;
- integrateWrt:(STR)aSymbol;

- (BOOL) printsLeadingSign;
- (BOOL) printsSum;
- (BOOL) printsProduct;
- printOn:(IOD)aFile;
@end

#endif /* __CAPOLYNOMIAL_HEADER__ */
 
