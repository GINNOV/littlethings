#ifndef ERRNO_H
#define ERRNO_H 1

extern long errno; /* <= contained in _main.c */

/* Open() can't open the file */
#define ENOENT 1
/* invalid file handle passed to close() */
#define EBADF 2
/* not enough memory to allocate another file handle */
#define ENOMEM 3
/* file already exists */
#define EEXIST 4
/* invalid function number */
#define EINVAL 5
/* no file handles left (should never occur) */
#define EMFILE 6
/* not a console device (should never occur) */
#define ENOTTY 7
/* invalid mode used in open() */
#define EACCES 8
/* math errors (not used by library) */
#define ERANGE 9
#define EDOM 10

#endif

