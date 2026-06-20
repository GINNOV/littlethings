
/*
 * Portable Object Compiler (c) 1997,98,99,03.  All Rights Reserved.
 * $Id: runarray.h,v 1.3 2009/10/23 19:36:43 stes Exp $
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

#ifndef __RUNARY_H__
#define __RUNARY_H__

#include "cltn.h"

@interface RunArray : Cltn
{
  id runs;
  id values;
  unsigned size;
  int laststart;
  int lastend;
  int lastsegment;
}

+ new;
- free;

- values;
- runs;
- at:(unsigned)i;
- (unsigned) runLengthAt:(unsigned)i;
- (unsigned) size;
- addAttribute:attrib from:(unsigned)p size:(unsigned)s;
- at:(unsigned)anOffset insert:(char*)aString count:(int)n;
- deleteFrom:(unsigned)p to:(unsigned)q;
- concat:b;
- coalesce;

- printOn:(IOD)aFile;
@end

#endif /* __RUNARY_H__ */
 
