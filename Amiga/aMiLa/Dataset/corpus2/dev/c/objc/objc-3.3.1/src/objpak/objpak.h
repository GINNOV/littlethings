
/*
 * Portable Object Compiler (c) 1997,98,99,2003.  All Rights Reserved.
 * $Id: objpak.h,v 1.4 2009/10/23 19:36:43 stes Exp $
 */

/*
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
 */

#ifndef __objpak__
#define __objpak__

#define __objpak_revision__ "3.2.1"


#include "stdio.h"		/* FILE for printOn: prototype */

#include "config.h"

#include <assert.h>		/* assert() */
#include <ctype.h>		/* isalpha for -dictCompare: */
#include <stdio.h>
#include <stdlib.h>

#ifndef __OBJECT_INCLUDED__
#define __OBJECT_INCLUDED__
#include "Object.h"		/* Stepstone Object.h assumes #import */
#endif

#if OBJC_BLOCKS
#include "Block.h"
#endif /* don't need this otherwise */

#include "Exceptn.h"

#ifdef __PORTABLE_OBJC__
#include "Message.h"
#endif

#include "ascfiler.h"
#include "cltn.h"
#include "ordcltn.h"
#include "dictnary.h"
#include "rectangl.h"
#include "outofbnd.h"
#include "notfound.h"
#include "badvers.h"
#include "unknownt.h"
#include "typeinc.h"
#include "bag.h"
#include "set.h"
#include "stack.h"
#include "sequence.h"
#include "sortcltn.h"
#include "ocstring.h"		/* avoid confusion with string.h */
#include "point.h"
#include "array.h"
#include "idarray.h"
#include "intarray.h"

#include "cltnseq.h"
#include "assoc.h"
#include "objgraph.h"
#include "keyseq.h"
#include "valueseq.h"
#include "bagseq.h"
#include "setseq.h"
#include "treeseq.h"

#endif /* __objpak__ */
 
