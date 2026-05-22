
/*
 * Copyright (c) 1999 David Stes.
 *
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
 *
 * $Id: stkframe.h,v 1.1.1.1 2000/06/07 21:09:26 stes Exp $
 */

extern id topframe;

@interface Stackframe : Object
{
  id vals;
  id def;
  id compound;
  id previous,next;
  BOOL quitframe;
  BOOL breakframe;
  BOOL contframe;
  id returnval;
}

+ push;
+ pop;

- compound;
- compound:c;
- def:m;

- lookupself;
- lookupval:sym;
- defval:sym as:scalar;

- lookuplocal:sym;

- exitframe;
- (BOOL)quitframe;
- quitframe:(BOOL)x;
- (BOOL)breakframe;
- breakframe:(BOOL)x;
- (BOOL)contframe;
- contframe:(BOOL)x;

- returnval:x;
- returnval;

- enclosing;
- printBtOn:(IOD)d;

@end
 
