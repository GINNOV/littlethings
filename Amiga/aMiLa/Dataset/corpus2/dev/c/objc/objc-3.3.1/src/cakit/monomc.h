
/*
 * Computer Algebra Kit (c) 1995,98,99,2014 by David Stes.  All Rights Reserved.
 * $Id: monomc.h,v 1.7 2014/03/04 09:09:34 stes Exp $
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

#ifndef __monomialc_header__
#define __monomialc_header__

#include "cobject.h"

@interface monomialc : CAObject
{
}

- square;
- multiply:b;
- divide:b;
@end

#endif /* __monomialc_header__ */
 
