
/*
 * Computer Algebra Kit (c) 1993,99 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: smonomc.h,v 1.6 2000/10/12 14:40:26 stes Exp $
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

#ifndef __varsps_monomial_header__
#define __varsps_monomial_header__

#include "monomc.h"

@interface varsps_monomial : monomialc
{
  id termOne;
  id terms;
}

- check;
- _setUpScalarOne:aOne;
+ scalarOne:aOne;
- copy;
- deepCopy;
- doclone;
- clone;
- _terms;
- _setterms:cltn;
- _terms:cltn;
- empty;
- (BOOL) isEmpty;
- (BOOL) isOne;
- (int) compare:b;
- (BOOL) isEqual:b;
- (unsigned) hash;
- asSymbol;
- symbol:aSymbol;
- (int) numTerms;
- eachTerm;
- removeTerm;
- insertTerm:aTerm;
@end

#endif /* __varsps_monomial_header__ */
 
