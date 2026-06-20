/*
**  $VER: assert.h 2.00 (24.07.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

/* Allow this file to be included multiple
** times with different settings of NDEBUG. */
#undef assert


#ifdef NDEBUG

#define assert(C)

#else   /* NDEBUG */

#ifdef __cplusplus
extern "C" {
#endif

void __do_assert(char *, char *, char *, unsigned int);

#ifdef __cplusplus
}
#endif

#define assert(C) { if(!(C)) __do_assert(#C, __FILE__, __FUNC__, __LINE__); }

#endif  /* NDEBUG */

