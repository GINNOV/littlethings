/*-
 * Copyright (c) 1982, 1986, 1991 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)types.h	7.17 (Berkeley) 5/6/91
 */

#ifndef _TYPES_H_
#define	_TYPES_H_

typedef	unsigned char	u_char;
typedef	unsigned short	u_short;
typedef	unsigned int	u_int;
typedef	unsigned long	u_long;
typedef	unsigned short	ushort;		/* Sys V compatibility */

typedef	char *	caddr_t;		/* core address */
typedef	long	daddr_t;		/* disk address */

#ifndef _DEV_T
#define _DEV_T 1
typedef	long	dev_t;			/* device number */
#endif

#ifndef _INO_T
#define _INO_T 1
typedef	u_long	ino_t;			/* inode number */
#endif

#ifndef _OFF_T
#define _OFF_T 1
typedef	long	off_t;			/* file offset (should be a quad) */
#endif

typedef	u_short	nlink_t;		/* link count */
typedef	long	swblk_t;		/* swap offset */
typedef	long	segsz_t;		/* segment size */
typedef	u_short	uid_t;			/* user id */
typedef	u_short	gid_t;			/* group id */
typedef	int	pid_t;			/* process id */
typedef	int	mode_t;			/* permissions */
typedef u_long	fixpt_t;		/* fixed point number */

#ifndef _POSIX_SOURCE
typedef	struct	_uquad	{ u_long val[2]; } u_quad;
typedef	struct	_quad	{   long val[2]; } quad;
typedef	long *	qaddr_t;	/* should be typedef quad * qaddr_t; */

#define	major(x)	((int)(((u_int)(x) >> 8)&0xff))	/* major number */
#define	minor(x)	((int)((x)&0xff))		/* minor number */
#define	makedev(x,y)	((dev_t)(((x)<<8) | (y)))	/* create dev_t */
#endif

typedef	long clock_t;

#ifndef _TIME_T
#define _TIME_T 1
typedef long time_t;
#endif

#ifndef _SIZE_T
#define _SIZE_T 1
typedef	unsigned int size_t;
#endif

#ifndef _POSIX_SOURCE

#define	NBBY	8			/* number of bits in a byte */

/*
 * Select uses bit masks of file descriptors in longs.  These macros
 * manipulate such bit fields (the filesystem macros use chars).
 * FD_SETSIZE may be defined by the user, but the default here should
 * be enough for most uses.
 *
 * Note: you must #define FD_SETSIZE before including this file and,
 * if you use the sockets code, also set the external variable _fd_setsize
 * to the same value, e.g.:
 *
 * #define FD_SETSIZE 128
 * #include <sys/types.h>
 * long _fd_setsize = FD_SETSIZE;
 */
#ifndef FD_SETSIZE
#define FD_SETSIZE	64
#endif

typedef long	fd_mask;
#define NFDBITS	(sizeof(fd_mask) * NBBY) /* bits per mask */

#ifndef howmany
#define	howmany(x, y)	(((x)+((y)-1))/(y))
#endif

typedef	struct fd_set {
	fd_mask	fds_bits[howmany(FD_SETSIZE, NFDBITS)];
} fd_set;

#define	FD_SET(n, p)	((p)->fds_bits[(n)/NFDBITS] |= (1 << ((n) % NFDBITS)))
#define	FD_CLR(n, p)	((p)->fds_bits[(n)/NFDBITS] &= ~(1 << ((n) % NFDBITS)))
#define	FD_ISSET(n, p)	((p)->fds_bits[(n)/NFDBITS] & (1 << ((n) % NFDBITS)))
#define FD_COPY(f, t)	memmove(t, f, sizeof(*(f)))
#define	FD_ZERO(p)	memset((char *)(p), 0, sizeof(*(p)))

#endif /* !_POSIX_SOURCE */
#endif /* !_TYPES_H_ */
