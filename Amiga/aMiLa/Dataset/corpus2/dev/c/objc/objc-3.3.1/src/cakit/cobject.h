
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: cobject.h,v 1.8 2000/10/12 14:40:25 stes Exp $
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

/*
 * stdio.h is necessary for FILE*
 * stuff like string.h and assert.h might give portability problems
 */

#include "config.h"		/* .h file names */
#include "stdlib.h"
#include "string.h"
#include "assert.h"
#include "limits.h"
#include "float.h"

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include "Object.h"
#endif

#define obj_t id

typedef id *objseq_t;
#define obj_c id
typedef struct
  {
    id proto;
  }
obj_args;

#define obj_isvalue	0
#define obj_pervalue	1

@interface CAObject : Object
{
  STR _str;
}

+ (STR) cakitRevision;
- new;
+ str:(STR)aString;
+ int:(int)intValue;
+ stringValue:(const char *)aString;
- set_str:(STR)x;
- clone;
- copy;
- deepCopy;
- check;
- invalidate;
- release;

- set;
- (BOOL) sameClass:a;
- (BOOL) differentClass:a;
- errorSetEqual;
- checkSetEqual:a;
- checkSameClass:a;
- (BOOL) isKindOfSequence;
- class_vector;
- class_varspsrecdegsps_polynomial;
- class_varspsrecdegdns_polynomial;
- class_varspsexpdegsps_polynomial;
- class_varspsexpdegdns_polynomial;
- class_vardnsrecdegsps_polynomial;
- class_vardnsrecdegdns_polynomial;
- class_vardnsexpdegsps_polynomial;
- class_vardnsexpdegdns_polynomial;

- (STR) str;
- (const char *) stringValue;
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
- scalar:aScalar;
- asSymbol;
- symbol:aSymbol;

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
- _negate:(int)v;
- add:b;
- _add:(int)v:b:(int)w;
- subtract:b;
- increment;
- decrement;
- multiplyIntValue:(int)b;
- double;
- _double:(int)v;
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
- _square:(int)w;
- multiply:b;
- _multiply:b:(int)w;
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
- _addSquare:(int)v:b:(int)w;
- _add:(int)v:B multiply:b:(int)w;
- _multiply:a:(int)v add:B:(int)w;
- _multiply:a:(int)v add:B multiply:b:(int)w;
- _multiply:a:(int)v divide:d;
- _multiply:a:(int)v add:B multiply:b:(int)w divide:d;

- scalarZero;
- scalarContent;
- divideScalarContent;
- multiplyScalar:s;
- _multiplyScalar:s:(int)v;
- divideScalar:s;
- addScalar:s;
- subtractScalar:s;
- _add:(int)v:B multiplyScalar:b:(int)w;
- _multiplyScalar:a:(int)v add:B:(int)w;
- _multiplyScalar:a:(int)v add:B multiplyScalar:b:(int)w;
- _multiplyScalar:a:(int)v divideScalar:d;
- _multiplyScalar:a:(int)v add:B multiplyScalar:b:(int)w divideScalar:d;
- subtract:r multiplyScalar:q;
- multiplyScalar:p subtract:r multiplyScalar:q divideScalar:d;
- multiplyScalar:p divideScalar:d;
- multiplyCoefficient:s;
- _multiplyCoefficient:s:(int)v;
- divideCoefficient:s;
- _add:(int)v:B multiplyCoefficient:b:(int)w;
- _multiplyCoefficient:a:(int)v add:B:(int)w;
- _multiplyCoefficient:a:(int)v add:B multiplyCoefficient:b:(int)w;
- _multiplyCoefficient:a:(int)v divideCoefficient:d;
- _multiplyCoefficient:a:(int)v add:B multiplyCoefficient:b:(int)w divideCoefficient:d;
- multiplyTerm:s;
- _multiplyTerm:s:(int)v;
- divideTerm:s;
- _add:(int)v:B multiplyTerm:b:(int)w;
- _multiplyCoefficient:a:(int)v add:B multiplyTerm:b:(int)w;
- add:r multiplyTerm:q;
- subtract:r multiplyTerm:q;
- multiplyCoefficient:p subtract:r multiplyTerm:q;
- multiplyMonomial:s;
- _multiplyMonomial:s:(int)v;
- divideMonomial:s;
- _add:(int)v:B multiplyMonomial:b:(int)w;
- _multiplyScalar:a:(int)v add:B multiplyMonomial:b:(int)w;
- add:r multiplyMonomial:q;
- subtract:r multiplyMonomial:q;
- multiplyScalar:p subtract:r multiplyMonomial:q;

- (BOOL) printsLeadingSign;
- (BOOL) printsSum;
- (BOOL) printsProduct;
- printOn:(IOD)aFile;
@end

#endif /* __CAOBJECT_HEADER__ */
 
