
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
 * $Id: loaded.h,v 1.1.1.1 2000/06/07 21:09:26 stes Exp $
 */

extern id loaded;
extern id loadedcltn;

@interface Loaded : Object
{
   id unit;
   id filename;
   time_t savetime;
}

+ make;
+ reset;
+ resolve:sym;
+ resolvestr:(char*)name;

- filename;
- filename:x;
- (time_t)savetime;
- savetime:(time_t)t;

- stdmods;
- load;
- silentload:(BOOL)s;

@end
 
