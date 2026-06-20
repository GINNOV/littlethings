/* alloca() */

#ifndef _ALLOCA_H
#define _ALLOCA_H 1

#ifndef __SASC
#error Wrong compiler (SAS/C required)
#endif

#ifndef _PROFILE
#error Code using alloca() must be compiled with the PROFILE option
#endif

#include <stddef.h>

extern void *alloca(size_t size);

#endif /* _ALLOCA_H */

