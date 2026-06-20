
/*
 *  ASSERT.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 *
 *  relatively optimized, takes advantage of GNU-cpp __BASE_FILE__ macro
 *  allowing us to store the filename string once in a static decl.
 */

#ifndef ASSERT_H
#define ASSERT_H

static char *__BaseFile = __BASE_FILE__;

extern void __FailedAssert(char *, int);

#ifndef assert
#ifdef NDEBUG
#define assert(ignore)
#else
#define assert(exp)     if (!(exp)) __FailedAssert( __BaseFile, __LINE__);
#endif
#endif

#endif


