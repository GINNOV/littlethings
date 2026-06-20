
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: vector.h,v 1.6 2014/03/04 09:38:34 stes Exp $
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

#ifndef __CAVECTOR_HEADER__
#define __CAVECTOR_HEADER__

#include "cobject.h"

@interface Vector : CAObject
{
  id carrier;
  id scalarZero;
}

+ collection:aCltn;
+ scalarZero:aScalarZero numScalars:(int)numScalars;
- copy;
- deepCopy;

- scalarZero;
- (int) numScalars;
- (unsigned) hash;
- (BOOL) isEqual:b;

- insertScalar:aScalar;
- insertScalar:aScalar at:(int)i;

- removeScalar;
- removeScalarAt:(int)i;

- placeScalar:aScalar at:(int)i;
- replaceScalarAt:(int)i with:aScalar;
- asCollection;
- asNumerical;
- asModp:(unsigned short)p;
- onCommonDenominator:(id *)denominator;

- eachScalar;
- (float) floatValueAt:(int)i;
- (int) intValueAt:(int)i;

- zero;
- (BOOL) isZero;
- (BOOL) isOpposite:b;
- negate;
- double;
- add:b;
- subtract:b;
- addScalar:s at:(int)i;
- subtractScalar:s at:(int)i;

- multiplyScalar:s;
- divideScalar:s;

- dotSquare;
- dotMultiply:aVector;
- multiplyLeftMatrix:aMatrix;

- printOn:(IOD)aFile;
@end

#endif /* __CAVECTOR_HEADER__ */
 
