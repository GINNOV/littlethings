
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: matrix.h,v 1.7 2014/03/04 09:38:34 stes Exp $
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

#ifndef __CAMATRIX_HEADER__
#define __CAMATRIX_HEADER__

#include "cobject.h"

@interface Matrix : CAObject
{
  id rows;
  id scalarZero;
  id emptyVector;
}
- check;

+ diagonal:cltnOfScalars;
+ circulant:cltnOfScalars;
+ companion:cltnOfScalars;
+ hankel:rowScalars:colScalars;
+ toeplitz:rowScalars:colScalars;
+ hilbert:(int)n scalarZero:aZero;
+ hilbert:(int)n;

- _setUpScalarZero:aScalarZero numRows:(int)numRows numColumns:(int)numColumns;
- scalarZero:aScalarZero numRows:(int)numRows numColumns:(int)numColumns;
+ scalarZero:aScalarZero numRows:(int)numRows numColumns:(int)numColumns;
- scalar:aScalar numRows:(int)numRows numColumns:(int)numColumns;
+ scalar:aScalar numRows:(int)numRows numColumns:(int)numColumns;
- setrows:r;
- copy;
- dodeepCopy;
- deepCopy;
- clone;
- rows:c;
- doscalarZero:aZero emptyVector:aVector rows:c;
- scalarZero:aZero emptyVector:aVector rows:c;
- numRows:(int)numRows numColumns:(int)numColumns;
- emptyVector;

- scalarZero;
- rows;
+ classVectors;
- (int) numRows;
- (int) numColumns;
- checkDimensionEqual:b;
- checkSquare;
- (BOOL) isEqual:aMatrix;
- (unsigned) hash;
- (BOOL) isDiagonal;
- (BOOL) isSymmetric;
- (BOOL) isAntiSymmetric;

- insertRow:aVector;
- insertRow:aVector at:(int)i;
- insertColumn:aCollection;
- insertColumn:aCollection at:(int)i;

- removeRow;
- removeRowAt:(int)i;
- removeColumn;
- removeColumnAt:(int)i;

- placeScalar:aScalar at:(int)i:(int)j;
- replaceScalarAt:(int)i:(int)j with:aScalar;

- asNumerical;
- asModp:(unsigned short)p;
- commonDenominator;
- asIntegral;
- asFractional;
- onCommonDenominator:(id *)denominator;

- rowAt:(int)i;
- eachRow;
- eachScalar;
- eachSequence;
- (float) floatValueAt:(int)i:(int)j;

- zero;
- negate;
- double;
- add:b;
- subtract:b;
- addScalar:s;
- subtractScalar:s;

- one;
- square;
- multiply:b;
- multiplyVector:aColumn;

- multiplyScalar:b;
- divideScalar:b;

- transpose;

- determinant;
- determinantGauss;
- determinantBareiss;
- solveVector:y;
- solveGaussDeterminant:(id *)detReference;
- solveBareissDeterminant:(id *)detReference;
- inverse;
- divide:b;
- divideGauss:b;
- (int) rank;
- (int) nullity;
- rowReducedFormRank:(int *)rankReference indexRank:(int**)indexRankReference;
- kernel;
- image;

- trace;
- adjoint;

- printOn:(IOD)aFile;
@end

#endif /* __CAMATRIX_HEADER__ */
 
