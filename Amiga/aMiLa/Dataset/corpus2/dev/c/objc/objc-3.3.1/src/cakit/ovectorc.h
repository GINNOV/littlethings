
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: ovectorc.h,v 1.6 2000/10/12 14:40:26 stes Exp $
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

#ifndef __obj_vector_header__
#define __obj_vector_header__

#include "vectorc.h"

typedef struct objvec
  {
    int n;
    int c;
    objseq_t ptr;
  }
 *objvec_t;

typedef struct objvec objvec_c;
typedef struct
  {
    obj_args sargs;
  }
objvec_args;

#define objvec_isvalue	0
#define objvec_pervalue	0

typedef struct objvec_ix
  {
    int i;
    int n;
  }
 *objvec_ixt;

@interface obj_vector : vectorc
{
  id scalarZero;
  struct objvec value;
}

- check;

- _setUpScalarZero:aScalarZero numScalars:(int)numScalars;
+ scalarZero:aScalarZero numScalars:(int)numScalars;
- copy;
- deepCopy;
- release;
- (objvec_t)objvec_value;
- objvec_value:(objvec_t)aValue;
- (objvec_t)objvec_reference;
- objvec_reference:(objvec_c *)aReference;

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
- elt_objvec_ix:(objvec_ixt)ix;

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

#endif /* __obj_vector_header__ */
 
