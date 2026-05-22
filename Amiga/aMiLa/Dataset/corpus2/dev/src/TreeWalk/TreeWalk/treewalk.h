/*
 * header file for users of the treewalk function.
 *
 *	Copyright (C) 1989  Mike Meyer
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 1, or any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef	EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif

/*
 * A prototype for treewalk.
 */
int treewalk(BPTR, int (*)(BPTR, struct FileInfoBlock *), int) ;

#define TREE_PRE	0x01			/* Visit dirs preorder */
#define TREE_POST	0x02			/* Visit dirs postorder */
#define TREE_BOTH 	(TREE_PRE|TREE_POST)

/*
 * return values for visitfunc. Must return one of these...
 */
#define TREE_STOP	TRUE
#define TREE_CONT	FALSE
