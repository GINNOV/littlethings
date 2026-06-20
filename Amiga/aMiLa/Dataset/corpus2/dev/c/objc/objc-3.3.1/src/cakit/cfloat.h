
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: cfloat.h,v 1.6 2000/10/12 14:40:25 stes Exp $
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

#ifndef __CAFLOAT_HEADER__
#define __CAFLOAT_HEADER__

#include "cobject.h"

typedef float float_t;

typedef float float_c;
typedef float *floatseq_t;
typedef struct
  {
    unsigned unused;
  }
float_args;

#define float_isvalue	1
#define float_pervalue	1

@interface Float : CAObject
{
  float_t value;
}

+ new;
- _setUpFloatValue:(float)floatValue;
+ floatValue:(float)floatValue;
+ str:(STR)aString;
- empty;
- (float_t) float_value;
- setfloat_value:(float_t)f;
- float_value:(float_t)f;
- (float_t *) float_reference;
- float_reference:(float_t *)f;

- (BOOL) isFloatingPoint;

- (unsigned) hash;
- (BOOL) isEqual:b;
- (BOOL) notEqual:b;
- (float) floatValue;
- floatValue:(float)f;

- (int) sign;
- (int) compare:b;

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
- str:(STR)aString;

- (BOOL) printsLeadingSign;
- printOn:(IOD)aFile;
@end

#endif /* __CAFLOAT_HEADER__ */
 
