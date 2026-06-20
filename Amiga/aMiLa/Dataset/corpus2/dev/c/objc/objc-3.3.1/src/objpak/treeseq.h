
/*
 * Portable Object Compiler (c) 1997,98.  All Rights Reserved.
 * $Id: treeseq.h,v 1.1.1.1 2000/06/07 21:09:25 stes Exp $
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

#ifndef __OBJSORTSEQ_H__
#define __OBJSORTSEQ_H__

#include "sortcltn.h"

@interface TreeSequence : Object
{
  objbbt_t top;
  objbbt_t next;
  objbbt_t prev;
}
- setUpSort:aSort;
+ over:aSort;
- copy;
- free;
- (unsigned) size;
- next;
- peek;
- previous;
- first;
- last;

@end

#endif /* __OBJSORTSEQ_H__ */
 
