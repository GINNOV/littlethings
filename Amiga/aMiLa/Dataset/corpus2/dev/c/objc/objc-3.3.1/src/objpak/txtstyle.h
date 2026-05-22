
/*
 * Portable Object Compiler (c) 1997,98.  All Rights Reserved.
 * $Id: txtstyle.h,v 1.1.1.1 2000/06/07 21:09:25 stes Exp $
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

#ifndef __TEXTSTYLE_H__
#define __TEXTSTYLE_H__

#include "ocstring.h"

@interface TextStyle : String
{
}

+ default;
+ named:(STR)name;

- (STR) name;

- printOn:(IOD)aFile;
@end

#endif /* __TEXTSTYLE_H__ */
 
