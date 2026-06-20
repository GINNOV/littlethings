#ifndef _INCLUDE_STDDEF_H
#define _INCLUDE_STDDEF_H

/*
**  $VER: stddef.h 2.0 (22.08.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**       All Rights Reserved
*/

#ifndef NULL
#define NULL 0
#endif

#define offsetof(s,m) ((unsigned long) &((s *) NULL)->m)

#include <sys/types.h>

typedef int ptrdiff_t;
#if __STORM__ < 39
typedef int wchar_t;
#endif


/* obsolete defs */
#ifdef __STORM__
#ifndef __asm
#define __asm
#endif

#ifndef __stdargs
#define __stdargs
#endif
#endif /* __STORM__ */

#endif	/* _INCLUDE_STDDEF_H */
