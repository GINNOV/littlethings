
/*
 * Computer Algebra Kit (c) 1993,2000,14 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: polyrseq.h,v 1.8 2014/03/04 14:39:43 stes Exp $
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

#ifndef __CAPOLYNOMIALRECSCALSEQ_HEADER__
#define __CAPOLYNOMIALRECSCALSEQ_HEADER__

#include "cseqc.h"

@interface recpolscalar_sequence : sequencec
{
  id content;
  id eachTerm;
  id eachScalar;
}

- _setUpContent:aPolynomial;
+ content:aPolynomial;
- toFirst;
- toLast;
- (BOOL) isEmpty;
- (unsigned) size;
- toElementAt:(int)i;
- next;
- previous;
@end

#endif /* __CAPOLYNOMIALRECSCALSEQ_HEADER__ */
 
