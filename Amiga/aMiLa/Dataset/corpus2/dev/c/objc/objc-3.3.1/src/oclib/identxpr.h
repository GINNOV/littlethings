
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
 * $Id: identxpr.h,v 1.1.1.1 2000/06/07 21:09:25 stes Exp $
 */

@interface IdentifierExpr : Expr
{
  id identifier;
  BOOL ivar;
  BOOL cvar;
  BOOL isself;
  BOOL lhsself;
  BOOL isclassref;
  BOOL infactory;
  BOOL isglobal;
  BOOL isstkvar;
  id heapvarblock;		/* it's a block variable */
  id maybeheapvarblock;
  id classdef;			/* it's a ivar or cvar */
}

+ str:(STR)s;
+ resolve:sym;
- identifier:aRcvr;
- gen;
- lhsself:(BOOL)flag;

- go;
- assignvar:v;

@end
 
