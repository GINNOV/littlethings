
/*
**  $VER: debug.h 1.00 (24.07.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

/*
** usefull macros for debugging
**
** define NDEBUG for no debugging
** define LDEBUG n (n from 0 to 9) for debugging level
*/

#include <assert.h>

#ifndef CLIB_DEBUG_PROTOS_H
#include <clib/debug_protos.h>
#endif /* CLIB_DEBUG_PROTOS_H */

#undef DEBUG
#undef DPUTS
#undef DPRINT1
#undef DPRINT2
#undef DPRINT3
#undef DPRINT4
#undef DWAIT
#undef DBEEP

#ifdef NDEBUG

#define DEBUG(x)
#define DPUTS(l,v)
#define DPRINT1(l,fs,p1)
#define DPRINT2(l,fs,p1,p2)
#define DPRINT3(l,fs,p1,p2,p3)
#define DPRINT4(l,fs,p1,p2,p3,p4)
#define DWAIT(l)
#define DBEEP(l)

#else /* NDEBUG */

#ifndef LDEBUG
#define LDEBUG 9
#endif

#ifndef LWAIT
#define LWAIT 0
#endif

#define DEBUG(x) x
#define DPUTS(l,v) { if (l <= LDEBUG) kprintf("%s,%ld (%s): %s\n",__FILE__,__LINE__,__FUNC__,v); if (LWAIT) DWAIT(l); }
#define DPRINT1(l,fs,p1) { if (l <= LDEBUG) kprintf("%s,%ld (%s): "fs"\n",__FILE__,__LINE__,__FUNC__,p1); if (LWAIT) DWAIT(l); }
#define DPRINT2(l,fs,p1,p2) { if (l <= LDEBUG) kprintf("%s,%ld (%s): "fs"\n",__FILE__,__LINE__,__FUNC__,p1,p2); if (LWAIT) DWAIT(l); }
#define DPRINT3(l,fs,p1,p2,p3) { if (l <= LDEBUG) kprintf("%s,%ld (%s): "fs"\n",__FILE__,__LINE__,__FUNC__,p1,p2,p3); if (LWAIT) DWAIT(l); }
#define DPRINT4(l,fs,p1,p2,p3,p4) { if (l <= LDEBUG) kprintf("%s,%ld (%s): "fs"\n",__FILE__,__LINE__,__FUNC__,p1,p2,p3,p4); if (LWAIT) DWAIT(l); }

#ifndef CLIB_EXEC_PROTOS_H
#include <clib/exec_protos.h>
#endif
#define DWAIT(l) { if (l <= LDEBUG) { kprintf("%s,%ld (%s): Task is waiting for Ctrl-D.\n",__FILE__,__LINE__,__FUNC__); Wait(8192); } }

#ifndef CLIB_INTUITION_PROTOS_H
#include <clib/intuition_protos.h>
#endif
#define DBEEP(l) { if (l <= LDEBUG) { kprintf("%s,%ld (%s): Beep!\n",__FILE__,__LINE__,__FUNC__); DisplayBeep(NULL); } }

#ifdef ASSERTTYPE
#if ASSERTTYPE==1
#undef assert
#define assert(C)                                                             \
   {                                                                          \
      if (!(C))                                                               \
      {                                                                       \
         kprintf("assertion (%s) in file %s, line %ld\n   function %s.\n",#C, \
         __FILE__,__LINE__,__FUNC__);                                         \
         kprintf("Waiting for Ctrl-D\n");                                     \
         Wait(8192);                                                          \
      }                                                                       \
   }
#elif ASSERTTYPE==2
#undef assert
#ifdef __GNUC__
extern void ___stormbreak(void) __asm__("___stormbreak");
#else
extern "ASM" void ___stormbreak(void);
#endif
#define assert(C)                                                             \
    {                                                                         \
      if (!(C))                                                               \
      {                                                                       \
         kprintf("assertion (%s) in file %s, line %ld\n   function %s.\n",#C, \
         __FILE__,__LINE__,__FUNC__);                                         \
         ___stormbreak();                                                     \
      }                                                                       \
   }
#endif // ASSERTTYPE
#endif // ASSERTTYPE

#endif  /* NDEBUG */
