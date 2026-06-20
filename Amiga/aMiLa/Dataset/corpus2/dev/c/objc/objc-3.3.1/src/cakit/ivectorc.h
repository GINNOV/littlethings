
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: ivectorc.h,v 1.6 2000/10/12 14:40:26 stes Exp $
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

#ifndef __bigintobj_vector_header__
#define __bigintobj_vector_header__

#include "vectorc.h"

typedef struct bigintobjvec
  {
    int n;
    int c;
    bigintobjseq_t ptr;
  }
 *bigintobjvec_t;

typedef struct bigintobjvec bigintobjvec_c;
typedef struct
  {
    bigintobj_args sargs;
  }
bigintobjvec_args;

#define bigintobjvec_isvalue	0
#define bigintobjvec_pervalue	0

typedef struct bigintobjvec_ix
  {
    int i;
    int n;
  }
 *bigintobjvec_ixt;

@interface bigintobj_vector : vectorc
{
  id scalarZero;
  struct bigintobjvec value;
}

- check;

- _setUpScalarZero:aScalarZero numScalars:(int)numScalars;
+ scalarZero:aScalarZero numScalars:(int)numScalars;
- copy;
- deepCopy;
- release;
- (bigintobjvec_t)bigintobjvec_value;
- bigintobjvec_value:(bigintobjvec_t)aValue;
- (bigintobjvec_t)bigintobjvec_reference;
- bigintobjvec_reference:(bigintobjvec_c *)aReference;

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
- elt_bigintobjvec_ix:(bigintobjvec_ixt)ix;

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

#endif /* __bigintobj_vector_header__ */
 
