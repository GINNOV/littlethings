
/*
 * Portable Object Compiler (c) 2003.  All Rights Reserved.
 * $Id: Exceptn.h,v 1.3 2003/09/30 20:20:27 stes Exp $
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

#ifndef __EXCEPTN_H__
#define __EXCEPTN_H__

#ifdef __PORTABLE_OBJC__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

@interface Exception : Object
{
  id messageText;
  id tag;
  id resumeHandler;
}
:
{
  id handler;			/* for this class of exceptions */
}


+ signal;
+ signal:(STR)message;
- free;

- signal;
- signal:(STR)message;
- messageText;
- (STR) str;
- messageText:message;
- str:(STR)message;

- resignalAs:replacementException;
- resume;
@end

#endif /* __PORTABLE_OBJC__ */

#endif /* __EXCEPTN_H__ */
 
