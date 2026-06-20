
/*
 * Computer Algebra Kit (c) 1993,99 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: drspolc.h,v 1.6 2000/10/12 14:40:25 stes Exp $
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

#ifndef __vardnsrecdegsps_polynomial_header__
#define __vardnsrecdegsps_polynomial_header__

#include "polc.h"

@interface vardnsrecdegsps_polynomial : polynomialc
{
}

+ scalarZero:aScalar;
+ scalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
- scalarZero:aScalar coefficientZero:aCoef symbols:aCltn;
+ scalarZero:aScalar symbols:aCltn;
- scalarZero;
- symbols;
- (BOOL) sameClass:b;
- emptyScalarZero:aZero;
- emptyVariableDense:aCltn;
- emptyVariableSparse;
- emptyExpanded;
- emptyRecursive;
- emptyDegreeSparse;
- emptyDegreeDense;
@end

#endif /* __vardnsrecdegsps_polynomial_header__ */
 
