
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: odespolc.h,v 1.6 2000/10/12 14:40:26 stes Exp $
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

#ifndef __obj_vardnsexpdegsps_polynomial_header__
#define __obj_vardnsexpdegsps_polynomial_header__

#include "despolc.h"

typedef struct obj_vardnsexpdegspsterm
  {
    struct obj_vardnsexpdegspsterm *nlink;
    struct obj_vardnsexpdegspsterm *plink;
    /* stes - mar31, 1997 - for DEC alpha alignment, put scalar in front */
    obj_c scal;			/* can't be variable sized */
    vardnsmonom_c data;		/* variable sized */
  }
 *obj_vardnsexpdegspsterm_t;

typedef struct
  {
    obj_args sargs;
    vardnsmonom_args margs;
  }
obj_vardnsexpdegspsterm_args;

typedef struct obj_vardnsexpdegspsterm *obj_vardnsexpdegspspol_t;
typedef struct obj_vardnsexpdegspsterm obj_vardnsexpdegspspol_c;
typedef obj_vardnsexpdegspsterm_args obj_vardnsexpdegspspol_args;

typedef struct obj_vardnsexpdegspspol_ix
  {
    obj_vardnsexpdegspsterm_t ix;
    obj_vardnsexpdegspsterm_t head;
  }
 *obj_vardnsexpdegspspol_ixt;

#define obj_vardnsexpdegspspol_isvalue	0
#define obj_vardnsexpdegspspol_pervalue	0

@interface obj_vardnsexpdegsps_polynomial : vardnsexpdegsps_polynomial
{
  id scalarZero;
  id termZero;
  id monomialZero;
  id symbols;
  obj_vardnsexpdegspspol_c value;
}

- (obj_vardnsexpdegspspol_t)obj_vardnsexpdegspspol_value;
- obj_vardnsexpdegspspol_value:(obj_vardnsexpdegspspol_t)aValue;
- (obj_vardnsexpdegspspol_t)obj_vardnsexpdegspspol_reference;
- obj_vardnsexpdegspspol_reference:(obj_vardnsexpdegspspol_c *)aReference;

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
- elt_obj_vardnsexpdegspspol_ix:(obj_vardnsexpdegspspol_ixt)ix;
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

#endif /* __obj_vardnsexpdegsps_polynomial_header__ */
 
