
/*
 * Copyright (c) 1998 David Stes.
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
 * $Id: msgxpr.h,v 1.1.1.1 2000/06/07 21:09:26 stes Exp $
 */

extern id msgwraps; /* VICI */

@interface MesgExpr : Expr
{
  id msg;
  id sel;
  id rcvr;
  BOOL supermsg;
  BOOL infactory;
  BOOL indispatchfun;
  BOOL methodfound;
  id method;
  id classdef;
  id tmpvar;
  id refvar;
  id icache;
  char *fwdname;
  char *dispname;
  char *argstructname;
  id msgwrap; /* VICI */
}

- (unsigned)hash;
- (BOOL)isEqual:x;
- indispatchfun:(BOOL)f;

- receiver:aRcvr;
- msg:method;
- method:method;

- msg;
- tmpvar;
- method;
- selector;

- typesynth;
- gen;
- gendispfun;
- genfwdstub;
- genargstruct;
- gendispargsintostruct;
- (char*)fwdname;
- (char*)dispname;
- (char*)argstructname;

- go;
- send:(IMP)i sel:(SEL)sel with:kw to:rcvr;

@end
 
