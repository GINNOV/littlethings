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

#ifndef _SYS_FILE_H
#define _SYS_FILE_H

#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/unistd.h>

#ifdef _INTERNAL_FILE
#include <sys/stat.h>
#include <libraries/dosextens.h>

/* this is the incore representation of a DTYPE_MEM file */
struct mem_file {
  int   mf_offset;
  void *mf_buffer;
};

/* this `glue' makes a tty a subtype of a plain file. Ie f->f_fh will work
   for plain files as well as ttys. */
struct tty_glue {
  struct FileHandle *fh;
  unsigned long ttyflags;       /* ixemul mapping of termios flags */
};				/* if we run out of bits, we should */
				/* allocate a tty structure instead */

/* ixemul termios flag mappings: */
#define IXTTY_INLCR		0x00000001
#define IXTTY_ICRNL		0x00000002
#define IXTTY_OPOST		0x00000004
#define IXTTY_ONLCR		0x00000008
#define IXTTY_RAW		0x00000010
#define IXTTY_PKT		0x00000020  /* TIOCPKT replacement */

/* this will hold basic information about a file, but contrairy to
 * Unix, it will also hold its name */

struct file {
  char *f_name;	     /* the name as used with open() */
  int f_stb_dirty,   /* gets == 1, if changes have been made to 'stb' */
      f_type,	     /* can be a file or some amiga..devices */
      f_flags,	     /* see fcntl.h */
      f_count,	     /* open-count, normally 1, higher after dup() */
      (*f_write)(),    /* functions to perform write,read,etc on this fd */
      (*f_read)(),
      (*f_ioctl)(),
      (*f_select)(),
      (*f_close)();
  union {
    struct FileHandle *fh; /* this is a CPTR to the allocated
			    * FileHandle */
    struct mem_file mf;	   /* current data for incore files */
    struct {
  	int so; 	   /* points to socket when DTYPE_SOCKET */
	int domain;
	int type;
	int protocol;
	long id;	   /* used in vfork() to store id of socket to give to child */
    } inetsock;
    struct unix_socket *sock; /* points to AF_UNIX socket - DTYPE_USOCKET */
    struct sock_stream *ss;
    struct tty_glue tg;
  } f__fh;
#define f_fh  f__fh.fh
#define f_mf  f__fh.mf
#define f_so  f__fh.inetsock.so
#define f_socket_domain f__fh.inetsock.domain
#define f_socket_type f__fh.inetsock.type
#define f_socket_protocol f__fh.inetsock.protocol
#define f_socket_id f__fh.inetsock.id
#define f_sock	f__fh.sock
#define f_ss  f__fh.ss
#define f_ttyflags f__fh.tg.ttyflags
  /* WARNING: if you change this struct, take care, that f_sp starts at
   * long (!) alignment in the struct. The file-table will be allocated
   * by AllocMem(), thus by itself it will have DOS-compatible alignment,
   * if you don't follow this, you'll get some nice gurus.. */
#ifdef __pos__
  struct pOS_TimeVal f_tv;
  struct pOS_DosIOReq f_select_sp;
#else
  struct StandardPacket f_sp; /* all IO is done thru the Packet-Interface,
			       * not the higher-level DOS-functions */
  struct StandardPacket f_select_sp; /* for the select() function */
#endif
  struct stat f_stb;    /* file-params at open-time, or after changes to fd */
  int	f_sync_flags;	/* for process synchronization */
};


#define FSFB_LOCKED	(0)
#define FSFF_LOCKED	(1<<0)	/* means the fh is in use */
#define FSFB_WANTLOCK	(1)
#define FSFF_WANTLOCK	(1<<1)	/* means a process is sleeping on fh to get free */

#define FSDB_MODE       (0)
#define FSDF_MODE       (1<<0)  /* means fchmod() was used on the file */
#define FSDB_OWNER      (1)
#define FSDF_OWNER      (1<<1)  /* means fchown() was used on the file */
#define FSDB_UTIME      (2)
#define FSDF_UTIME      (1<<2)  /* means we have to set the file time ourselves */
                                /* this is only needed if we truncate the file
                                   without writing anything to it.
                                   Example: echo -n >foo */

#endif /* _INTERNAL_FILE_H */


#define DTYPE_FILE	1	/* 'file' is really a file */
#define DTYPE_PIPE	2	/* it's an incore pipe */
#define DTYPE_MEM	3	/* a RDONLY file completely buffered in memory */
#define DTYPE_TASK_FILE	4	/* is a 'file', but used by a task, not a process !*/
#define DTYPE_SOCKET	5	/* socket (inet.library interface) */
#define DTYPE_USOCKET	6	/* socket (own socket code) */
#define DTYPE_TTY	7	/* AmigaOS file, with special access functions */
/* more to follow.. */

#endif /* _SYS_FILE_H */
