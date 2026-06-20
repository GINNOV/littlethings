
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: idespolc.h,v 1.6 2000/10/12 14:40:25 stes Exp $
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

#ifndef __bigintobj_vardnsexpdegsps_polynomial_header__
#define __bigintobj_vardnsexpdegsps_polynomial_header__

#include "despolc.h"

typedef struct bigintobj_vardnsexpdegspsterm
  {
    struct bigintobj_vardnsexpdegspsterm *nlink;
    struct bigintobj_vardnsexpdegspsterm *plink;
    /* stes - mar31, 1997 - for DEC alpha alignment, put scalar in front */
    bigintobj_c scal;		/* can't be variable sized */
    vardnsmonom_c data;		/* variable sized */
  }
 *bigintobj_vardnsexpdegspsterm_t;

typedef struct
  {
    bigintobj_args sargs;
    vardnsmonom_args margs;
  }
bigintobj_vardnsexpdegspsterm_args;

typedef struct bigintobj_vardnsexpdegspsterm *bigintobj_vardnsexpdegspspol_t;
typedef struct bigintobj_vardnsexpdegspsterm bigintobj_vardnsexpdegspspol_c;
typedef bigintobj_vardnsexpdegspsterm_args bigintobj_vardnsexpdegspspol_args;

typedef struct bigintobj_vardnsexpdegspspol_ix
  {
    bigintobj_vardnsexpdegspsterm_t ix;
    bigintobj_vardnsexpdegspsterm_t head;
  }
 *bigintobj_vardnsexpdegspspol_ixt;

#define bigintobj_vardnsexpdegspspol_isvalue	0
#define bigintobj_vardnsexpdegspspol_pervalue	0

@interface bigintobj_vardnsexpdegsps_polynomial : vardnsexpdegsps_polynomial
{
  id scalarZero;
  id termZero;
  id monomialZero;
  id symbols;
  bigintobj_vardnsexpdegspspol_c value;
}

- (bigintobj_vardnsexpdegspspol_t)bigintobj_vardnsexpdegspspol_value;
- bigintobj_vardnsexpdegspspol_value:(bigintobj_vardnsexpdegspspol_t)aValue;
- (bigintobj_vardnsexpdegspspol_t)bigintobj_vardnsexpdegspspol_reference;
- bigintobj_vardnsexpdegspspol_reference:(bigintobj_vardnsexpdegspspol_c *)aReference;

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
- _setUpScalarZero:aScalar symbols:aCltn;
+ scalarZero:aScalar symbols:aCltn;
- release;
- empty;
- (int) numMonomials;
- eachMonomial;
- elt_bigintobj_vardnsexpdegspspol_ix:(bigintobj_vardnsexpdegspspol_ixt)ix;
- removeMonomial;
- insertMonomial:aMonomial;
- multiplyScalar:s;
- divideScalar:s;
- _add:(int)v:B multiplyScalar:b:(int)w;
- _multiplyScalar:a:(int)v add:B:(int)w;
- _multiplyScalar:a:(int)v add:B multiplyScalar:b:(int)w;
- multiplyMonomial:aMonomial;
- _multiplyMonomial:aMonomial:(int)v;
- divideMonomial:aMonomial;
- _add:(int)v:B multiplyMonomial:b:(int)w;
- _multiplyScalar:a:(int)v add:B multiplyMonomial:b:(int)w;

- fileOutOn:aFiler;
- fileInFrom:aFiler;
@end

#endif /* __bigintobj_vardnsexpdegsps_polynomial_header__ */
 
