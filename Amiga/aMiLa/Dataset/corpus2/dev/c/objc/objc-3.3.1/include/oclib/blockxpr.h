
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
 * $Id: blockxpr.h,v 1.1.1.1 2000/06/07 21:09:24 stes Exp $
 */

extern id curcompound;		/* BlockExpr responds to messages of CompoundStmt */

@interface BlockExpr : Expr
{
  id lbrace, rbrace;
  id parms, datadefs, stmts, expr;
  id initializers;
  id parmnames, parmtypes;
  id enclosing;
  id enclosingdef;
  id tmpvars;
  id icaches;
  id locals;
  id localdic;
  id alllocals;
  id heapvars, heapnames, heaptypes;
  id heapparms;
  char *heapvarptrname;
  char *heapvartypename;
  id localexprs;
  int numparms;
  int numheapvarblocks;
  id heapvarblocks;
  int blockcount;
  char *blkconsname;
  char *blkdtorname;
  char *blkfunname;
  char *blkdataname;
  char *blktypename;
  id restype;
  id returnlabel;
  id refvar;
  id increfs, decrefs;
}

- lbrace:lb;
- rbrace:rb;
- (BOOL)isblockexpr;
- parms:aList;
- datadefs:aList;
- stmts:aList;
- expr:e;
- returnlabel;
- nextreturnlabel;

- gen;
- genblockfun;
- lookupparm:sym;

#include "shared.h"

@end
 
