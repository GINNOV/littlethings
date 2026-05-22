
/*
 *  ERRNO.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef ERRNO_H
#define ERRNO_H

#ifndef MATH_H
#define EDOM	    1		/*  repeated in errno.h */
#define ERANGE	    2		/*  repeated in errno.h */
#endif

#define EBADF	    3		/*  bad file descriptor */
#define ENOPERM     4		/*  write on ro or read on wo desc */
#define ENOMEM	    5		/*  no memory ???	*/
#define ENOFILE     6		/*  open faileod	*/
#define ENOENT	    6		/*  ... synonym?	*/

#define EACCES	    7		/*  access disallowed	*/
#define EINVAL	    8		/*  invalid flags	*/
#define EMFILE	    9		/*  ran out of FDs	*/
#define EAGAIN	    10
#define EPEER	    11
#define EPIPE	    12
#define ENOTFND     13
#define ESTACK	    14		/*  ran out of stack	*/

#define ENOTTY	    15
#define ENXIO	    16		/*  lattice compat?	*/
#define EEXIST	    17		/*  already exists	*/

#define EWOULDBLOCK 18		/*  call would block	*/
#define EINTR	    19		/*  interrupted call	*/

#define ENOSPC	    20		/*  ?	*/
#define EIO	    21		/*  ?	*/

extern volatile int errno;

#endif

