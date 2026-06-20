#ifndef _ASSERT_H
#define _ASSERT_H

#include <stdlib.h> /* for exit() */
#include <stdio.h>  /* for fprintf() */

#ifndef NDEBUG
#define assert(expression)\
    do\
        if (!(expression))\
            fprintf(stderr, "Assertion failed in file %s, function %s(), line %d\n", __FILE__, __func__, __LINE__),\
            exit(1);\
    while (0)
#else
#define assert(expression) ((void)0)
#endif

#endif
