
/*
 * Portable Object Compiler (c) 2003.  All Rights Reserved.
 * $Id: unknownt.h,v 1.2 2009/10/23 19:36:43 stes Exp $
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

#ifndef __UNKNOWNTYPE_H__
#define __UNKNOWNTYPE_H__

#include "Exceptn.h"

@interface UnknownType : Exception
{
  char aChar;
}
- (char) typeDesc;
- typeDesc:(char)c;
@end

#endif /* __UNKNOWNTYPE_H__ */
 
