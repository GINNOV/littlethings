
/*
 * Computer Algebra Kit (c) 1993,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: cseq.h,v 1.4 2014/03/04 15:24:41 stes Exp $
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

#ifndef __CASEQUENCE_HEADER__
#define __CASEQUENCE_HEADER__

#include "cobject.h"

@interface CASequence : CAObject
{
  id carrier;
}

- next;
- previous;

- (unsigned) size;
- (BOOL) isEmpty;
- (BOOL) isKindOfSequence;

- toFirst;
- toLast;
- toElementAt:(int)i;

- lastElement;
- firstElement;
- at:(unsigned)i;

- printOn:(IOD)aFile;
@end

#endif /* __CASEQUENCE_HEADER__ */
 
