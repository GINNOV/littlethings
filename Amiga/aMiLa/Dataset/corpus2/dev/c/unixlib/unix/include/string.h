#ifndef UNIX_STRING_H
#define UNIX_STRING_H 1

#include "include:string.h"

/* Nonstandard routines */
#if !defined(_ANSI_SOURCE) && !defined(_STRICT_ANSI)

#ifdef NO_MACROS
#undef index
#undef rindex
#undef bcopy
#undef bcmp
#undef bzero
extern char *index(const char *, int);
extern char *rindex(const char *, int);
extern void bcopy(const void *, void *, size_t);
extern int bcmp(const void *, const void *, size_t);
extern void bzero(void *, size_t);
#endif

extern int strcasecmp(const char *, const char *);
extern int strncasecmp(const char *, const char *, size_t);

#endif
#endif
