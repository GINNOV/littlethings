
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: ccomplex.h,v 1.7 2001/07/09 19:30:49 stes Exp $
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

#ifndef __CACOMPLEX_HEADER__
#define __CACOMPLEX_HEADER__

#include "cobject.h"

@interface Gaussian : CAObject
{
  id real;
  id imaginary;
}

+ real:aReal;
- _setUpReal:aReal imaginary:anotherReal;
+ real:aReal imaginary:anotherReal;
- copy;
- deepCopy;
- real:aReal imaginary:anotherReal;
- real:aReal;
- imaginary:aReal;
- symbol:aSymbol;

- real;
- imaginary;
- (BOOL) isReal;
- (BOOL) notReal;
- (unsigned) hash;
- (BOOL) isEqual:b;

- conjugate;
- norm;
- asReal;

- zero;
- (BOOL) isZero;
- (BOOL) isOpposite:b;
- negate;
- double;
- add:b;
- subtract:b;

- I;
- one;
- (BOOL) isOne;
- (BOOL) isMinusOne;
- (BOOL) isUnit;
- square;
- multiplyReal:b;
- multiply:b;
- power:(int)n;

- divideReal:b;
- divide:b;
- inverse;
- quotientReal:b;
- quotient:b;
- remainder:b quotient:(id *)q;

- gcd:b;

- printOn:(IOD)aFile;
@end

#endif /* __CACOMPLEX_HEADER__ */
 
