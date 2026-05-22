
/*
 * Portable Object Compiler (c) 1997,2000,03,04.  All Rights Reserved.
 * $Id: ascfiler.h,v 1.4 2009/10/23 19:36:43 stes Exp $
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

#ifdef __PORTABLE_OBJC__

#ifndef __ASCIIFILER_H__
#define __ASCIIFILER_H__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include <stdio.h>
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

@interface AsciiFiler : Object
{
  FILE *file;
  BOOL ownFile;
  BOOL inSecondPass;
  id toc;
  void **patchPointers;
  int patchSize;
  int patchCapacity;
}

+ initialize;

+ new;
- free;

- (BOOL) store:anObject on:(STR)aFileName;
- readFrom:(STR)aFileName;

- fileOut:(void *)value type:(char)typeDesc;

- fileIn:(void *)value type:(char)typeDesc;

@end

#endif /* __ASCIIFILER_H */

#endif /* __PORTABLE_OBJC__ */
 
