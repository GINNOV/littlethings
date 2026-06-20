
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
 * $Id: msgwrap.h,v 1.1.1.1 2000/06/07 21:09:26 stes Exp $
 */

#define MSGWRAPNARGS 7

typedef id *idreft;

typedef struct { 
  idreft rtyp;
  idreft atyp[MSGWRAPNARGS];
  id (*efun)(IMP,id,SEL,id);
  IMP trapfun;
} MSGWRAP;

extern MSGWRAP stdmsgwraps[];

@interface Mesgwrap : MesgExpr
{
   id (*efun)(IMP,id,SEL,id); /* entry point */
   IMP trapfun; /* Objective-C runtime trap to get into VICI */
}

+ defmsgwrapsfor:(MSGWRAP*)w;

- (IMP)methodFor:(SEL)s cls:c methdef:m;
- send:(IMP)i sel:(SEL)sel with:kw to:rcvr;

@end
 
