
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
 * $Id: symbol.h,v 1.2 2001/01/25 19:54:41 stes Exp $
 */

extern id s_void;
extern id s_char;
extern id s_bool;
extern id s_int;
extern id s_uns;
extern id s_long;
extern id s_double;
extern id s_str;
extern id s_sel;
extern id s_newblock;
extern id s_main;
extern id s_objcmain;
extern id s_id;
extern id s_nil;
extern id s_self;
extern id s_cmd;
extern id s_super;
extern id s_type;
extern id s_aFiler;
extern id s_fileIn;
extern id s_fileOut;
extern id s_fileInIdsFrom;
extern id s_fileOutIdsFor;
extern id s_returnval;
extern id s_returnflag;
extern id s_increfs;
extern id s_decrefs;
extern id s_idincref;
extern id s_iddecref;

BOOL istypeword(id sym);
BOOL isbuiltinfun(id sym);
int  pragmatoggle(char *s);
void definebuiltintype(char *s);
void definebuiltinfun(char *s);
void definebuiltinvar(char *s);

@interface Symbol : String
{
  int lineno;
  id filename;
  id type;
}

+ commonsymbols;
+ str:(char*)s lineno:(int)no filename:fn;
- type;
- filename;
- (int)lineno;
- type:fn;
- filename:fn;
- lineno:(int)no;
- lineno:(int)no filename:fn;

- synth;
- gen;

- (int)bytesize;

- (BOOL)isid;
- (BOOL)isvoid;
- (BOOL)canforward;
- (BOOL)isselptr;
- (BOOL)isenumtor;

- (BOOL)istypedef;
- (BOOL)isstatic;
- (BOOL)isextern;
- (BOOL)isinline;
- (BOOL)isstorageclass;
- (BOOL)isvolatile;
- (BOOL)isrefcounted;

- toscores;
- unescape;
- unescapeChar;

- peekAt:(char*)ptr;
- poke:v at:(char*)ptr;

@end
 
