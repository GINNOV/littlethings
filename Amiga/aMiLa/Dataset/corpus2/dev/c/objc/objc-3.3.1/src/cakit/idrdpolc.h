
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: idrdpolc.h,v 1.6 2000/10/12 14:40:25 stes Exp $
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

#ifndef __bigintobj_vardnsrecdegdns_polynomial_header__
#define __bigintobj_vardnsrecdegdns_polynomial_header__

#include "drdpolc.h"

typedef bigintobjseq_t bigintobj_vardnsrecdegdnspolseq_t;

typedef struct bigintobj_vardnsrecdegdnspol
  {
    int n;
    int c;
    bigintobj_vardnsrecdegdnspolseq_t ptr;
  }
 *bigintobj_vardnsrecdegdnspol_t;

typedef struct bigintobj_vardnsrecdegdnspol bigintobj_vardnsrecdegdnspol_c;
typedef struct
  {
    bigintobj_args sargs;
  }
bigintobj_vardnsrecdegdnspol_args;

typedef struct bigintobj_vardnsrecdegdnspol_ix
  {
    int i;
    int n;
  }
 *bigintobj_vardnsrecdegdnspol_ixt;

#define bigintobj_vardnsrecdegdnspol_isvalue	0
#define bigintobj_vardnsrecdegdnspol_pervalue	0

@interface bigintobj_vardnsrecdegdns_polynomial : vardnsrecdegdns_polynomial
{
  id scalarZero;
  id termZero;
  id monomialZero;
  id symbols;
  bigintobj_vardnsrecdegdnspol_c value;
}

- _setUpScalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
+ scalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
- empty;
- (int) numTerms;
- (bigintobj_vardnsrecdegdnspol_t)bigintobj_vardnsrecdegdnspol_value;
- bigintobj_vardnsrecdegdnspol_value:(bigintobj_vardnsrecdegdnspol_t)aValue;
- (bigintobj_vardnsrecdegdnspol_t)bigintobj_vardnsrecdegdnspol_reference;
- bigintobj_vardnsrecdegdnspol_reference:(bigintobj_vardnsrecdegdnspol_c *)aReference;

- copy;
- deepCopy;
- (BOOL) isEmpty;
- (BOOL) isOne;
- (BOOL) isMinusOne;
- (unsigned) hash;
- (BOOL) isEqual:b;
- (BOOL) notEqual:b;
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
- (int) leadingDegree;
- (int) lastDegree;
- (int) maxDegree;
- (int) minDegree;
- asScalar;
- asSymbol;
- check;
- release;
- eachTerm;
- elt_bigintobj_vardnsrecdegdnspol_ix:(bigintobj_vardnsrecdegdnspol_ixt)ix;
- removeTerm;
- insertTerm:aTerm;
- multiplyCoefficient:s;
- divideCoefficient:s;
- _add:(int)v:B multiplyCoefficient:b:(int)w;
- _multiplyCoefficient:a:(int)v add:B:(int)w;
- _multiplyCoefficient:a:(int)v add:B multiplyCoefficient:b:(int)w;
- multiplyTerm:aTerm;
- _multiplyTerm:aTerm:(int)v;
- divideTerm:aTerm;
- _add:(int)v:B multiplyTerm:b:(int)w;
- _multiplyCoefficient:a:(int)v add:B multiplyTerm:b:(int)w;

- fileOutOn:aFiler;
- fileInFrom:aFiler;
@end

#endif /* __bigintobjscal_vardnsrecdegdns_polynomial_header__ */
 
