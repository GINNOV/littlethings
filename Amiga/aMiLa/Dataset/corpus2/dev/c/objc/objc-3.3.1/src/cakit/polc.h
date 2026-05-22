
/*
 * Computer Algebra Kit (c) 1993,2000,14 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: polc.h,v 1.8 2014/03/04 09:38:34 stes Exp $
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

#ifndef __polynomialc_header__
#define __polynomialc_header__

#include "cobject.h"

@interface polynomialc : CAObject
{
}

- empty;
- (BOOL) isEmpty;
- (int) leadingDegree;
- (int) lastDegree;
- (int) maxDegree;
- (int) minDegree;
- eachElement;
- (unsigned) size;
- insertMember:aMember;
- (BOOL) isOpposite:b;
- negate;
- double;
- add:b;
- subtract:b;
- multiplyScalar:aScalar;
- multiplyCoefficient:aCoefficient;
- multiplyMonomial:aMonomial;
- vardnsMultiplyTerm:aTerm;
- multiplyTerm:aTerm;
- divideScalar:aScalar;
- divideCoefficient:aCoefficient;
- divideMonomial:aMonomial;
- vardnsDivideTerm:aTerm;
- divideTerm:aTerm;
- over:aCarrier;
- liftTerm:aTerm;
- varspsMultiplyTerm:aTerm;
- varspsDivideTerm:aTerm;
@end

#endif /* __polynomialc_header__ */
 
