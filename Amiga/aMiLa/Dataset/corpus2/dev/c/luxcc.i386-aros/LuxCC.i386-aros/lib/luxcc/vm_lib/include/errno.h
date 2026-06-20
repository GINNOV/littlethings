#ifndef _ERRNO_H
#define _ERRNO_H

#define EDOM    33
#define EILSEQ  84
#define ERANGE  34

extern int *errno;
#define errno (*errno)

#endif
