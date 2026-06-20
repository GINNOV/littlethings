
/*
 * Computer Algebra Kit (c) 1993,2000,14 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: polynom.h,v 1.12 2014/03/04 14:39:43 stes Exp $
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
- check;

+ new;
- _setUpCarrier:aCarrier;
+ over:aCarrier;
+ scalar:aScalar;
- copy;
- deepCopy;
- invalidate;
- clearpoly;
- clone;
- carrier;
- setcarrier:c;
- over:c;
- empty;
- dodifferentcarrier:c;
- differentCarrier:c;
- emptyScalarZero:aZero;
- emptyVariableDense:symbols;
- emptyVariableSparse;
- emptyExpanded;
- emptyRecursive;
- emptyDegreeSparse;
- emptyDegreeDense;

+ wilkinsonDegree:(int)n;
+ randomDegree:(int)n;
+ bernouilliDegree:(int)n;
+ binomialDegree:(int)n;
+ chebyshevTDegree:(int)n;
+ chebyshevUDegree:(int)n;
+ cyclotomicDegree:(int)n;
+ eulerDegree:(int)n;
+ hermiteDegree:(int)n;
+ laguerreDegree:(int)n;
+ legendreDegree:(int)n;

- scalarZero;
- termZero;
- monomialZero;
+ classTerms;
+ classMonomials;
- (unsigned) hash;
- (BOOL) isEqual:b;
- (BOOL) notEqual:b;
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
- scalar:aScalar;
- asSymbol;
- symbol:aSymbol;
- asTerm;
- asMonomial;
- asMember;
- asCoefficient;
- asNumerical;
- asModp:(unsigned short)p;
- commonDenominator;
- onCommonDenominator;

- (int) compareSymbols:aTerm;
- addSymbolsTo:aCltn;
- symbols;
- variables;

- (int) degree;
- (int) order;

- (int) numTerms;
- (int) numMonomials;
- (unsigned) size;

- removeTerm;
- insertTerm:aTerm;
- removeMonomial;
- insertMonomial:aMonomial;
- removeLast;
- insertMember:aMember;

- eachTerm;
- eachMonomial;
- eachSequence;
- memberZero;
- eachElement;
- eachScalar;
- eachCoefficient;

- changeRepresentationTo:aPrototype;
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
- (BOOL) notZero;
- (BOOL) isOpposite:b;
- (BOOL) notOpposite:b;
- negate;
- _double:(int)v;
- double;
- _add:(int)v:b:(int)w;
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
- power:(int)n;
- multiplyScalar:s;
- divideScalar:s;
- _add:(int)v:B multiplyScalar:b:(int)w;
- _multiplyScalar:a:(int)v add:B:(int)w;
- _multiplyScalar:a:(int)v add:B multiplyScalar:b:(int)w;
- multiplyCoefficient:aCoefficient;
- divideCoefficient:aCoefficient;
- _add:(int)v:B multiplyCoefficient:b:(int)w;
- _multiplyCoefficient:a:(int)v add:B:(int)w;
- _multiplyCoefficient:a:(int)v add:B multiplyCoefficient:b:(int)w;
- multiplyTerm:aTerm;
- divideTerm:aTerm;
- _add:(int)v:B multiplyTerm:b:(int)w;
- _multiplyCoefficient:a:(int)v add:B multiplyTerm:b:(int)w;
- multiplyMonomial:s;
- divideMonomial:s;
- _add:(int)v:B multiplyMonomial:b:(int)w;
- _multiplyScalar:a:(int)v add:B multiplyMonomial:b:(int)w;

- remainder:b quotient:(id *)q;
- divide:b;
- remainderReductum:r term:t quotient:(id *)q;
- remainderReductum:r monicTerm:t quotient:(id *)q;
- remainderReductum:r term:t inverse:s quotient:(id *)q;
- remainderReductum:r term:t coefficient:s quotient:(id *)q;
- remainderReductum:r monomial:t quotient:(id *)q;
- remainderReductum:r monicMonomial:t quotient:(id *)q;
- remainderReductum:r monomial:t inverse:s quotient:(id *)q;
- remainderReductum:r monomial:t scalar:s quotient:(id *)q;

- pseudoRemainder:b quotient:(id *)q;
- pseudoRemainder:b;
- pseudoRemainderReductum:r term:t quotient:(id *)q;
- pseudoRemainderReductum:r term:t coefficient:s quotient:(id *)q sparsityCount:(int *)cref;

- content;
- divideContent;
- coefficientContent;
- divideCoefficientContent;
- termContent;
- monomialContent;

- doImprovedSubresultant:(id *)pref:(id *)qref;
- fieldGcd:b;
- idomGcd:b;
- gcd:b;
- resultant:b;
- resultant:b wrt:(STR)aSymbol;
- discriminant;

- signedPseudoRemainder:B;
- (int) signedPseudoRemainderList:g plus:(int*)plus minus:(int*)minus;
- (int) vRealRoots:g;
- (int) numRealRoots;
- (int) varRealRoots:g;

- factor;
- (BOOL) isSquareFree;
- factorSymbol:aSymbol exponent:(int)anExponent;
- factorSquareFreeDerivative:dself gcd:gcd;
- factorSquareFreeDerivative:dself gcd:gcd characteristic:(unsigned)p;
- factorSquareFree;

- truncateAtDegree:(int)d;

- frobenius;
- frobeniusInverse;

- evaluate:aScalar;
- evaluate:(STR)aSymbol at:aScalar;
- evaluateAll:cltnOfScalars;
- (float) floatEvaluate:(float)floatValue;
- (float) floatEvaluateAll:(float *)floatValues;
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
 
