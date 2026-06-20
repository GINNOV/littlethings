
/*
 * Computer Algebra Kit (c) 1995,98,99 by David Stes.  All Rights Reserved.
 * $Id: dmonomc.h,v 1.6 2000/10/12 14:40:25 stes Exp $
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

#ifndef __vardns_monomial_header__
#define __vardns_monomial_header__

#include "monomc.h"

typedef int *vardnsmonom_t;
typedef int vardnsmonom_c;	/* kind of fishy */

typedef struct
  {
    int nvars;
    /* could add 'order' etc in the future */
  }
vardnsmonom_args;

#define vardnsmonom_isvalue	0
#define vardnsmonom_pervalue 0

typedef vardnsmonom_t vardns_t;
typedef vardnsmonom_t vardns_c;
typedef vardnsmonom_args vardns_args;

#define vardns_isvalue	0
#define vardns_pervalue	1

typedef struct vardns_ix
  {
    int i;
    int n;
  }
 *vardns_ixt;

@interface vardns_monomial : monomialc
{
  id termOne;
  id symbols;
  vardns_c value;
}

- check;
- _setUpScalarOne:aOne symbols:aCltn;
+ scalarOne:aOne symbols:aCltn;
- copy;
- deepCopy;
- release;
- empty;
- (vardns_t) vardns_value;
- dovardns_value:(vardns_t)aValue;
- vardns_value:(vardns_t)aValue;
- (vardns_c *) vardns_reference;
- dovardns_reference:(vardns_c *)aReference;
- vardns_reference:(vardns_c *)aReference;
- (vardnsmonom_t) vardnsmonom_value;
- dovardnsmonom_value:(vardnsmonom_t)aValue;
- vardnsmonom_value:(vardnsmonom_t)aValue;
- (vardnsmonom_c *) vardnsmonom_reference;
- vardnsmonom_reference:(vardnsmonom_c *)aReference;
- (BOOL) sameClass:b;
- (int) numTerms;
- (BOOL) isEmpty;
- (BOOL) isOne;
- (int) compare:b;
- (BOOL) isEqual:b;
- (unsigned) hash;
- eachTerm;
- elt_vardns_ix:(vardns_ixt)ix;
- removeTerm;
- insertTerm:aTerm;

- fileOutOn:aFiler;
- fileInFrom:aFiler;
@end

#endif /* __vardns_monomial_header__ */
 
