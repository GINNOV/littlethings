
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: intmodp.h,v 1.5 2001/07/09 18:38:07 stes Exp $
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

@interface IntegerModp : CAObject
{
  modp_t value;
  unsigned short modulus;
}

+ modulus:(unsigned short)aPrime;
+ int:(int)intValue modulus:(unsigned short)aPrime;

- (unsigned) hash;
- (BOOL) isEqual:b;
- (unsigned short) modulus;
- (int) intValue;
- intValue:(int)aValue;

- zero;
- (BOOL) isZero;
- (BOOL) isOpposite:b;
- negate;
- double;
- add:b;
- subtract:b;

- one;
- minusOne;
- (BOOL) isOne;
- (BOOL) isMinusOne;
- square;
- multiply:b;
- inverse;
- divide:b;

- (int) characteristic;
- frobenius;
- frobeniusInverse;

- (BOOL) printsLeadingSign;
- printOn:(IOD)aFile;
@end

#endif /* __CAINTEGERMODP_HEADER__ */
 
