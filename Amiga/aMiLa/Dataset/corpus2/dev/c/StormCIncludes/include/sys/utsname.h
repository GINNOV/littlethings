/*
 *  This file is part of ixemul.library for the Amiga.
 *  Copyright (C) 1995 Lars G. Hecking
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the Free
 *  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef _SYS_UTSNAME_H_
#define _SYS_UTSNAME_H_

#ifndef __SYS_NMLN
#define __SYS_NMLN 32
#endif

struct utsname {
	char	sysname[__SYS_NMLN];
	char	nodename[__SYS_NMLN];
	char	release[__SYS_NMLN];
	char	version[__SYS_NMLN];
	char	machine[__SYS_NMLN];
};

#ifdef	_KERNEL
extern struct utsname utsname;
#else
int	uname(struct utsname *name);
#endif

#endif /* _SYS_UTSNAME_H_ */
