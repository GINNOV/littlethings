/*
 *  This file is part of ixemul.library for the Amiga.
 *  Copyright (C) 1991, 1992  Markus M. Wild
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

#ifndef _SYS_SYSCALL_H
#define _SYS_SYSCALL_H

#define SYSTEM_CALL(func, vec) SYS_##func = vec,

enum _syscall_ {
#include <sys/syscall.def>
#undef SYSTEM_CALL
};

#ifndef _KERNEL
extern void *ixemulbase;

#define syscall(vec, args...) \
  ({register int (*_sc)()=(void *)(&((char *)ixemulbase)[-((vec)+4)*6]); _sc(args);})
#endif

#endif /* _SYS_SYSCALL_H */
