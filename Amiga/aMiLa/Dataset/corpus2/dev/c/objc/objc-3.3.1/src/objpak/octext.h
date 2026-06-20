
/*
 * Portable Object Compiler (c) 1997,98,99,2003.  All Rights Reserved.
 * $Id: octext.h,v 1.3 2009/10/23 19:36:44 stes Exp $
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

#ifndef __OBJTXT_H__
#define __OBJTXT_H__

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include <stdio.h>
#include <Object.h>
#endif

@interface Text : Object
{
  id string;
  id runs;
}

- check;
+ new;
+ new:(unsigned)nChars;
+ vsprintf:(STR)format:(OC_VA_LIST*)ap;
+ str:(STR)aString;
+ sprintf:(STR)format,...;
+ fromString:aString;
+ string:aString attribute:attrib;
- string:aString runs:anArray;
- copy;
- free;

- (unsigned) hash;
- (BOOL) isEqual:aStr;

- string;
- runs;
- (STR) str;
- (unsigned) size;
- (char) charAt:(unsigned)anOffset;
- (char) charAt:(unsigned)anOffset put:(char)aChar;
- at:(unsigned)anOffset insert:aString;
- at:(unsigned)anOffset insert:(char*)aString count:(int)size;
- deleteFrom:(unsigned)p to:(unsigned)q;
- concat:b;
- concatSTR:(STR)b;

- allBold;
- makeBoldFrom:(unsigned)p to:(unsigned)q;
- addAttribute:attribute;
- addAttribute:attribute from:(unsigned)p to:(unsigned)q;
- attributesAt:(unsigned)i;
- (unsigned) runLengthFor:(unsigned)i;
- (unsigned) fontNumberAt:(unsigned)i;
- fontAt:(unsigned)i withStyle:textStyle;

- asString;
- asText;
- asParagraph;

- printOn:(IOD)aFile;
@end

#endif /* __OBJTXT_H__ */
 
