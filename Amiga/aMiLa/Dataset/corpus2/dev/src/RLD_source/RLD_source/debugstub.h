/*
  $Id: debugstub.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $
   
  $Log: debugstub.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 07:59:11  wegge
  Initial revision

  */

#if !defined(DEBUGSTUB_H)
#define DEBUGSTUB_H

void KPrintF(const char *format, ...);

#if defined(DEBUG_VERSION)

#define KPRINTF_HERE	     do { KPrintF ("%s(%s):%ld\n", \
                             __FUNCTION__, __FILE__, __LINE__); } while (0)
#define KPRINTF_WHERE	     do { KPrintF ("%s(%s):%ld:\n    ", \
                             __FUNCTION__, __FILE__, __LINE__); } while (0)
#define KPRINTF_ARGS(a)	     do { KPrintF a; } while (0)
#define KPRINTF(a)	     do { KPRINTF_WHERE; KPRINTF_ARGS(a); } while (0)
#define KPRINTF_DISABLED(a)  do { Disable (); KPRINTF (a); \
                             Enable (); } while (0)

#define KPRINTF_ARGV(name,argv) \
  do { int argi; \
    for (argi = 0; (argv)[argi] != NULL; argi++) \
      KPRINTF (("%s[%ld] = [%s]\n", (name), argi, (argv)[argi])); \
  } while (0)

#else  /* !defined(DEBUG_VERSION) */

#define KPRINTF_HERE			/* Expands to nothing */
#define KPRINTF_WHERE			/* Expands to nothing */
#define KPRINTF_ARGS(a)			/* Expands to nothing */
#define KPRINTF(a)			/* Expands to nothing */
#define KPRINTF_DISABLED(a)		/* Expands to nothing */
#define KPRINTF_ARGV(name,argv)		/* Expands to nothing */

#endif /* DEBUG_VERSION */

#endif /* DEBUGSTUB_H */
