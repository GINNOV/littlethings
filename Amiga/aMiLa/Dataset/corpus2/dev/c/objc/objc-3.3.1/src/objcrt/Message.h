
/*
 * Portable Object Compiler (c) 1998.  All Rights Reserved.
 * $Id: Message.h,v 1.1.1.1 2000/06/07 21:09:25 stes Exp $
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

#ifndef __MESSAG_H__
#define __MESSAG_H__

#ifdef __PORTABLE_OBJC__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

#include "config.h"		/* because Object.h can be from another runtime */
#include "objcrt.h"
#include <stdio.h>		/* because Object.h can be from another runtime */

@interface Message : Object
{
  SEL selector;
  ARGIMP dispatch;
  void *args;
}

- selector:(SEL)s dispatch:(ARGIMP)d args:(void*)a;
+ new;
+ selector:(SEL)s dispatch:(ARGIMP)d args:(void *)a;

- (SEL) selector;
- printOn:(IOD)anIod;

- sentTo:receiver;
@end

#endif /* __PORTABLE_OBJC__ */

#endif /* __MESSAG_H__ */
 
