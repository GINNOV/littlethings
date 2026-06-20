
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: mvectorc.h,v 1.6 2000/10/12 14:40:26 stes Exp $
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

#ifndef __modp_vector_header__
#define __modp_vector_header__

#include "vectorc.h"

typedef struct modpvec
  {
    int n;
    int c;
    modpseq_t ptr;
  }
 *modpvec_t;

typedef struct modpvec modpvec_c;
typedef struct
  {
    modp_args sargs;
  }
modpvec_args;

#define modpvec_isvalue	0
#define modpvec_pervalue	0

typedef struct modpvec_ix
  {
    int i;
    int n;
  }
 *modpvec_ixt;

@interface modp_vector : vectorc
{
  id scalarZero;
  struct modpvec value;
}

- check;

- _setUpScalarZero:aScalarZero numScalars:(int)numScalars;
+ scalarZero:aScalarZero numScalars:(int)numScalars;
- copy;
- deepCopy;
- release;
- (modpvec_t)modpvec_value;
- modpvec_value:(modpvec_t)aValue;
- (modpvec_t)modpvec_reference;
- modpvec_reference:(modpvec_c *)aReference;

- capacity:(int)aCapacity;
- numScalars:(int)numScalars;

- scalarZero;
- (int) numScalars;

- insertScalar:aScalar;
- insertScalar:aScalar at:(int)i;

- removeScalar;
- removeScalarAt:(int)i;

- placeScalar:aScalar at:(int)i;
- replaceScalarAt:(int)i with:aScalar;

- eachScalar;
- elt_modpvec_ix:(modpvec_ixt)ix;

- dotMultiply:b;
- dotSquare;

- fileOutOn:aFiler;
- fileInFrom:aFiler;
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
- multiplyScalar:s;
- divideScalar:s;
- _add:(int)v:B multiplyScalar:b:(int)w;
- _multiplyScalar:a:(int)v add:B:(int)w;
- _multiplyScalar:a:(int)v add:B multiplyScalar:b:(int)w;
@end

#endif /* __modp_vector_header__ */
 
