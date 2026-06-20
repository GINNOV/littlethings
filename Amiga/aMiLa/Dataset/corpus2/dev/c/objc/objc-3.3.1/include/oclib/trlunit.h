
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
 * $Id: trlunit.h,v 1.1.1.1 2000/06/07 21:09:24 stes Exp $
 */

extern id trlunit;

@interface TranslationUnit : Node
{
  int msgcount;
  int icachecount;
  int blockcount;
  int heapvarcount;
  int retlabelcount;
  id types, typedic;
  id globals, globaldic;
  id builtinfuns, builtintypes;
  id clsimpl;			/* one per file case */
  id clsimpls;			/* more than one per file */
  id seldic, selcltn;
  id msgdic, fwdcltn;
  char *modname;
  char *modversion;
  char *bindfunname;
  char *moddescname;
  id usesentries;
  id definesentries;
  id methods;
  id classdefs;
  id structdefs;
  id gentypes;
  id enumtors;
  BOOL usingblocks;
  BOOL usingselfassign;
}

- (int)msgcount;
- (int)icachecount;
- (int)blockcount;
- (int)heapvarcount;
- returnlabel;
- gettmpvar;
- (BOOL)usingblocks;
- (BOOL)usingselfassign;
- usingblocks:(BOOL)x;
- usingselfassign:(BOOL)x;

- (char *)moddescname;
- setmodversion:(char *)v;
- setmodname:(char *)filename;

- prologue;
- epilogue;

- allclsimpls;
- addclsimpl:c;
- genglobfuncall;

- usesentry:name;
- definesentry:name;

- (int)seloffset:selector;
- (int)fwdoffset:message;

- (BOOL)istypeword:node;
- (BOOL)isbuiltinfun:node;
- defbuiltinfun:node;
- defbuiltintype:node;
- def:sym astype:aType;
- defdata:node astype:aType;
- def:sym asclass:classdef;
- def:sel asmethod:method;
- defenumtor:e;
- lookupclass:sym;
- lookupglobal:sym;
- lookupmethod:sel;
- lookuptype:sym;
- lookupenumtor:sym;
- lookupstruct:s;
- defstruct:s;

- addgentype:s;
- (BOOL)isgentype:s;

@end
 
