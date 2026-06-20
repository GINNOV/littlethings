
/*
 * Portable Object Compiler (c) 1997.  All Rights Reserved.
 * $Id: assoc.h,v 1.2 2000/11/09 22:55:16 stes Exp $
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

#ifndef __OBJASSOC_H__
#define __OBJASSOC_H__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include <stdio.h>
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

/* the name of this class in older versions of Object Pak */
#define Association Assoc

@interface Assoc : Object
{
  id key;
  id value;
}

- key:aKey value:aValue;
+ key:aKey;
+ key:aKey value:aValue;

- key;
- (STR) str;
- value;
- free;
- freeAll;
- release;

- (unsigned) hash;
- self;
- (BOOL) isEqual:anAssoc;
- (int) compare:anAssoc;

- value:aValue;

- printOn:(IOD)aFile;
@end

#endif /* __OBJASSOC_H__ */
 
