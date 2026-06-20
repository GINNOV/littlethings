
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: matsq.h,v 1.7 2014/03/04 09:38:34 stes Exp $
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

#ifndef __CAMATRIXSEQSCAL_HEADER__
#define __CAMATRIXSEQSCAL_HEADER__

#include "cseqc.h"

@interface CAMatrixSequenceScalars : sequencec
{
  id content;
  id eachSequence;
  id currentSequence;
}

- _setUpContent:aMatrix;
+ content:aMatrix;
- toFirst;
- toLast;
- (BOOL) isEmpty;
- (unsigned) size;
- toElementAt:(int)i;
- next;
- previous;
@end

#endif /* __CAMATRIXSEQSCAL_HEADER__ */
 
