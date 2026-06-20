
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: intmodp.h,v 1.8 2001/07/09 18:38:07 stes Exp $
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

#ifndef __CAINTEGERMODP_HEADER__
#define __CAINTEGERMODP_HEADER__

#include "cobject.h"

#define USHRT_MAX_PRIME 65521U
typedef unsigned short modp_t;

typedef unsigned short modp_c;
typedef modp_t *modpseq_t;
typedef struct { unsigned short p; } modp_args;

#define modp_isvalue		1
#define modp_pervalue	1

@interface IntegerModp : CAObject
{
    modp_t		value;
    unsigned short	modulus;
}

+ new;
+ modulus:(unsigned short)aPrime;
- _setUpIntValue:(int)intValue modulus:(unsigned short)aPrime;
- int:(int)intValue modulus:(unsigned short)aPrime;
+ int:(int)intValue modulus:(unsigned short)aPrime;
- class_vector;
- class_vardnsrecdegsps_polynomial;
- class_vardnsrecdegdns_polynomial;
- class_vardnsexpdegsps_polynomial;
- setmodp_value:(modp_t)aValue;
- clone;
- (modp_t) modp_value;
- modp_value:(modp_t)aValue;
- (modp_t *) modp_reference;
- modp_reference:(modp_t *)aValue;

- (unsigned) hash;
- (BOOL) isEqual:b;
- (BOOL) notEqual:b;
- (unsigned short) modulus;
- (int) intValue;
- intValue:(int)aValue;

- zero;
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

- one;
- minusOne;
- (BOOL) isOne;
- (BOOL) notOne;
- (BOOL) isMinusOne;
- (BOOL) notMinusOne;
- square;
- multiply:b;
- inverse;
- divide:b;
- _add:(int)v:B multiply:b:(int)w;
- _multiply:a:(int)v add:B:(int)w;
- _multiply:a:(int)v add:B multiply:b:(int)w;

- (int) characteristic;
- frobenius;
- frobeniusInverse;

- (BOOL) printsLeadingSign;
- printOn:(IOD)aFile;

- fileOutOn:aFiler;
- fileInFrom:aFiler;
@end

#endif /* __CAINTEGERMODP_HEADER__ */

