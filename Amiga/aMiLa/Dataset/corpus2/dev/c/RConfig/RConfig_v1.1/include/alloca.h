/*
 * RConfig -- Replacement Library Configuration
 *   Copyright 1992 by Anthon Pang, Omni Communications Products
 *
 * Source File: alloca.h
 * Description: alloca()
 * Comments: Unix-like alloca() function, where allocated memory is
 *   automatically free()'d when the procedure exits.
 */

#ifndef __ALLOCA_H
#define __ALLOCA_H

#ifndef __STDIO_H
#include <stdio.h>
#endif  /* __STDIO_H */

#ifndef __ALLOCA_REPLACE
#define __ALLOCA_REPLACE
#endif

#ifdef __SAFE_ALLOCA

    /* prototype for internal use */
    void *_alloca(long *_return_address, size_t _size);

    /* This version requires a little work by the programmer */
#   define alloca(v,s) _alloca( (long*)((((long)(&(v)))&~1L)-4), (s) )

#else

    /* This version makes assumptions about a5 */
    void *alloca(size_t _size);

#   endif  /* SAFE_ALLOCA */

#endif  /* __ALLOCA_H */
