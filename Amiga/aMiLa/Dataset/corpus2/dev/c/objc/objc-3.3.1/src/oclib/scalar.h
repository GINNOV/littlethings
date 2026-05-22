
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
 * $Id: scalar.h,v 1.2 2000/09/08 15:02:08 stes Exp $
 */

#define ISSCALARZERO(e) (([e isKindOf:(id)[Scalar class]])?[e isZero]:((e)?0:1))

@interface Scalar : Variable
{
   id type;
   union {
     int un_int;
     unsigned un_uns;
     long un_long;
     char un_char;
     float un_float;
     double un_double;
     char *un_str;
     void *un_voidstar;
     FILE *un_fp;
   } u;
}

- type;

- u_int:(int)x;
- u_uns:(unsigned)x;
- u_long:(long)x;
- u_char:(char)x;
- u_float:(float)x;
- u_double:(double)x;
- u_str:(char*)x;
- u_voidstar:(void*)x;
- u_fp:(FILE*)x;

- (int)u_int;
- (long)u_long;
- (unsigned)u_uns;
- (char)u_char;
- (float)u_float;
- (double)u_double;
- (char*)u_str;
- (void*)u_voidstar;
- (FILE*)u_fp;

- (BOOL)isZero;

- decrement;
- increment;

@end
 
