
/*
 * Portable Object Compiler (c) 1997.  All Rights Reserved.
 * $Id: setseq.h,v 1.1.1.1 2000/06/07 21:09:25 stes Exp $
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

#ifndef __OBJSETSEQ_H__
#define __OBJSETSEQ_H__

#include "set.h"

typedef struct objsetseq
  {
    objset_t set;
    int offset;
  }
 *objsetseq_t;

@interface SetSequence : Object
{
  struct objsetseq value;
}
- (objsetseq_t) objsetseqvalue;
+ over:set;
- copy;
- free;
- (unsigned) size;
- next;
- peek;
- previous;
- first;
- last;

@end

#endif /* __OBJSETSEQ_H__ */
 
