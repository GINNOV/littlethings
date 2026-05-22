
/*
 * Portable Object Compiler (c) 2003.  All Rights Reserved.
 * $Id: badvers.h,v 1.2 2004/07/24 18:50:39 stes Exp $
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

#ifndef __BADVERSION_H__
#define __BADVERSION_H__

#include "Exceptn.h"

@interface BadVersion : Exception
{
  int badVersion;
  int goodVersion;
}
- (int) goodVersion;
- (int) badVersion;
- goodVersion:(int)g badVersion:(int)b;
- signal;
@end

#endif /* __BADVERSION_H__ */
 
