
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
 * $Id: node.h,v 1.1.1.1 2000/06/07 21:09:24 stes Exp $
 */

extern FILE *gfile;
extern int inlineno;
extern id infilename;
extern int outlineno;
extern char *outfilename;
extern int exitstatus;

void gc(char c);
void gextc(void);
void gcom(char *cm);
void gvarlist(id c, char *sp, char *iz);
void gcommalist(id c);
void gs(char *str);
void gf(char *fmt,...);
void gl(int no, char *fn);
void g_otbvars(void);
void gstderr(void);
void gnormal(void);

void warn(char *fmt,...);
void warnat(id sym, char *fmt,...);
void fatal(char *fmt,...);
void fatalat(id sym, char *fmt,...);

@interface Node : Object
{
}

- synth;
- gen;
- sgen;
- st80;

- (BOOL)isstorageclass;

@end
 
