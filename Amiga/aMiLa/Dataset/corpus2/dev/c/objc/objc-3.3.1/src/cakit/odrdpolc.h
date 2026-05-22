
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: odrdpolc.h,v 1.6 2000/10/12 14:40:26 stes Exp $
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

#ifndef __obj_vardnsrecdegdns_polynomial_header__
#define __obj_vardnsrecdegdns_polynomial_header__

#include "drdpolc.h"

typedef objseq_t obj_vardnsrecdegdnspolseq_t;

typedef struct obj_vardnsrecdegdnspol
  {
    int n;
    int c;
    obj_vardnsrecdegdnspolseq_t ptr;
  }
 *obj_vardnsrecdegdnspol_t;

typedef struct obj_vardnsrecdegdnspol obj_vardnsrecdegdnspol_c;
typedef struct
  {
    obj_args sargs;
  }
obj_vardnsrecdegdnspol_args;

typedef struct obj_vardnsrecdegdnspol_ix
  {
    int i;
    int n;
  }
 *obj_vardnsrecdegdnspol_ixt;

#define obj_vardnsrecdegdnspol_isvalue	0
#define obj_vardnsrecdegdnspol_pervalue	0

@interface obj_vardnsrecdegdns_polynomial : vardnsrecdegdns_polynomial
{
  id scalarZero;
  id termZero;
  id monomialZero;
  id symbols;
  obj_vardnsrecdegdnspol_c value;
}

- _setUpScalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
+ scalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
- empty;
- (int) numTerms;
- (obj_vardnsrecdegdnspol_t)obj_vardnsrecdegdnspol_value;
- obj_vardnsrecdegdnspol_value:(obj_vardnsrecdegdnspol_t)aValue;
- (obj_vardnsrecdegdnspol_t)obj_vardnsrecdegdnspol_reference;
- obj_vardnsrecdegdnspol_reference:(obj_vardnsrecdegdnspol_c *)aReference;

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
- elt_obj_vardnsrecdegdnspol_ix:(obj_vardnsrecdegdnspol_ixt)ix;
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

#endif /* __objscal_vardnsrecdegdns_polynomial_header__ */
 
