
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
 * $Id: method.h,v 1.1.1.1 2000/06/07 21:09:25 stes Exp $
 */

@interface Method : Node
{
  int lineno;
  id filename;
  id restype;
  id usel;
  id ksel;
  id selector;
  BOOL varargs;
  BOOL haveneedscast;
  BOOL needscast;
  BOOL havecanforward;
  BOOL canforward;
  BOOL haveisselptr;
  BOOL isselptr;
  BOOL havehash;
  unsigned typehash;
}

- ksel;
- (BOOL)typeEqual:x;
- (unsigned)typehash;

- (BOOL)isselptr;
- (BOOL)needscast;
- (BOOL)canforward;
- canforward:(BOOL)flag;

- synth;
- (int)lineno;
- filename;

- selector;
- restype;
- restype:type;
- unarysel:usel;
- keywsel:aList;
- (BOOL)varargs;
- varargs:(BOOL)flag;

- gen;
- gencast;
- genrestype;
- gendispargs;
- genmsgargs;
- genparmlist;
- warnforwithmethod;
- cvtcommalist;

@end
 
