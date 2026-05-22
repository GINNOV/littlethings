
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: mdrspolc.h,v 1.6 2000/10/12 14:40:26 stes Exp $
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

#ifndef __modp_vardnsrecdegsps_polynomial_header__
#define __modp_vardnsrecdegsps_polynomial_header__

#include "drspolc.h"

typedef struct modp_vardnsrecdegspsterm
  {
    struct modp_vardnsrecdegspsterm *nlink;
    struct modp_vardnsrecdegspsterm *plink;
    /* stes - mar31, 1997 - for DEC alpha alignment, put scalar in front */
    modp_c scal;		/* can't be variable sized */
    unimonom_c data;		/* variable sized */
  }
 *modp_vardnsrecdegspsterm_t;

typedef struct
  {
    modp_args sargs;
    unimonom_args margs;
  }
modp_vardnsrecdegspsterm_args;

typedef struct modp_vardnsrecdegspsterm *modp_vardnsrecdegspspol_t;
typedef struct modp_vardnsrecdegspsterm modp_vardnsrecdegspspol_c;
typedef modp_vardnsrecdegspsterm_args modp_vardnsrecdegspspol_args;

typedef struct modp_vardnsrecdegspspol_ix
  {
    modp_vardnsrecdegspsterm_t ix;
    modp_vardnsrecdegspsterm_t head;
  }
 *modp_vardnsrecdegspspol_ixt;

#define modp_vardnsrecdegspspol_isvalue	0
#define modp_vardnsrecdegspspol_pervalue	0

@interface modp_vardnsrecdegsps_polynomial : vardnsrecdegsps_polynomial
{
  id scalarZero;
  id termZero;
  id monomialZero;
  id symbols;
  modp_vardnsrecdegspspol_c value;
}

- _setUpScalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
+ scalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
- empty;
- (int) numTerms;
- (modp_vardnsrecdegspspol_t)modp_vardnsrecdegspspol_value;
- modp_vardnsrecdegspspol_value:(modp_vardnsrecdegspspol_t)aValue;
- (modp_vardnsrecdegspspol_t)modp_vardnsrecdegspspol_reference;
- modp_vardnsrecdegspspol_reference:(modp_vardnsrecdegspspol_c *)aReference;

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
- elt_modp_vardnsrecdegspspol_ix:(modp_vardnsrecdegspspol_ixt)ix;
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

#endif /* __modp_vardnsrecdegsps_polynomial_header__ */
 
