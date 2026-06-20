#ifndef ASSERT_H
#define ASSERT_H 1

#ifndef NDEBUG
#ifndef STDIO_H
#include "stdio.h"
#endif
#ifndef STDLIB_H
#include "stdlib.h"
#endif
#define assert(x)\
 if (!(x)) {fprintf(stderr,"Assertion failed: x,\
 file %s, line %d\n",__FILE__,__LINE__); exit(EXIT_FAILURE);}
#else
#define assert(x)
#endif

#endif

