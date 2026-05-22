
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
 * $Id: compstmt.h,v 1.1.1.1 2000/06/07 21:09:24 stes Exp $
 */

extern id curcompound;
extern id curloopcompound;

@interface CompoundStmt : Stmt
{
  id lbrace;
  id datadefs;
  id initializers;
  id stmts;
  id rbrace;
  id enclosing;
  id returnlabel;
  id parmnames;			/* always nil for compstmt */
  id tmpvars;
  id icaches;
  id localdic;
  id locals;
  id alllocals;
  id heapvars, heapnames, heaptypes;
  id heapparms;			/* nil */
  char *heapvarptrname;
  char *heapvartypename;
  id localexprs;
  id heapvarblocks;
  id restype;
  id increfs, decrefs;
  BOOL bracedgroup;
  BOOL needreturnflag;
  BOOL checkreturnflag;
}

- (BOOL)isbracedgroup;
- setbracedgroup:(BOOL)flag;

- setreturnflag;
- usereturnflag;
- datadefs:defs;
- stmts:stmtlist;
- lbrace:lb;
- rbrace:rb;
- gen;
- synth;
- lookupparm:sym;
- returnlabel;
- nextreturnlabel;

#include "shared.h"

@end
 
