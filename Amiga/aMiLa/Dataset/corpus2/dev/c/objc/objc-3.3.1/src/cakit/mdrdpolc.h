
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: mdrdpolc.h,v 1.6 2000/10/12 14:40:26 stes Exp $
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

#ifndef __modp_vardnsrecdegdns_polynomial_header__
#define __modp_vardnsrecdegdns_polynomial_header__

#include "drdpolc.h"

typedef modpseq_t modp_vardnsrecdegdnspolseq_t;

typedef struct modp_vardnsrecdegdnspol
  {
    int n;
    int c;
    modp_vardnsrecdegdnspolseq_t ptr;
  }
 *modp_vardnsrecdegdnspol_t;

typedef struct modp_vardnsrecdegdnspol modp_vardnsrecdegdnspol_c;
typedef struct
  {
    modp_args sargs;
  }
modp_vardnsrecdegdnspol_args;

typedef struct modp_vardnsrecdegdnspol_ix
  {
    int i;
    int n;
  }
 *modp_vardnsrecdegdnspol_ixt;

#define modp_vardnsrecdegdnspol_isvalue	0
#define modp_vardnsrecdegdnspol_pervalue	0

@interface modp_vardnsrecdegdns_polynomial : vardnsrecdegdns_polynomial
{
  id scalarZero;
  id termZero;
  id monomialZero;
  id symbols;
  modp_vardnsrecdegdnspol_c value;
}

- _setUpScalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
+ scalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
- empty;
- (int) numTerms;
- (modp_vardnsrecdegdnspol_t)modp_vardnsrecdegdnspol_value;
- modp_vardnsrecdegdnspol_value:(modp_vardnsrecdegdnspol_t)aValue;
- (modp_vardnsrecdegdnspol_t)modp_vardnsrecdegdnspol_reference;
- modp_vardnsrecdegdnspol_reference:(modp_vardnsrecdegdnspol_c *)aReference;

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
- elt_modp_vardnsrecdegdnspol_ix:(modp_vardnsrecdegdnspol_ixt)ix;
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

#endif /* __modpscal_vardnsrecdegdns_polynomial_header__ */
 
