/* ------------------------------------------------------------------ */
/* $VER: complier.h 39.01 (12.12.1999)                                */
/*                                                                    */
/* compiler spesific tricks for easyaudio.library                     */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#ifndef COMPILER_H
#define COMPILER_H
#endif

 /* -----------------------------------------------------------
    There have been problems how to define the seglist pointer
    under AROS, AmigaOS or elsewhere in a unique (and still
    working!) way. It seems to make sense to use a new, global
    type definition for it. This is done here.
    ---------------------------------------------------------- */

#ifndef _AROS
# ifdef VBCC
#  define SEGLISTPTR APTR
# else /* !VBCC */
#  include <dos/dos.h>
#  define SEGLISTPTR BPTR
# endif /* VBCC */
#else /* !_AROS */
  typedef struct SegList * SEGLISTPTR;
#endif /* _AROS */


/* -----------------------------------------------------------
   Basically, Amiga C compilers must try to reach the goal to
   be as SAS/C compatible as possible. But on the other hand,
   when porting AmigaOS to other platforms, one perhaps
   can't expect GCC becoming fully SAS/C compatible...
   ---------------------------------------------------------- */

/* redefining SAS/C keywords */

#ifdef __GNUC__
#define __d0
#define __d1
#define __d2
#define __d3
#define __d4
#define __d5
#define __d6
#define __d7
#define __a0
#define __a1
#define __a2
#define __a3
#define __a4
#define __a5
#define __a6
#define __a7
#endif

/* defining our own keywords */
/* i dont know about other compilers */

#ifdef __GNUC__
#define REG(r)
#define GNUCREG(r)  __asm( #r )
#define SAVEDS  __saveds
#define ASM
#define REGARGS __regargs
#define STDARGS __stdargs
#define ALIGNED __aligned
#endif /* COMPILER_H */

/* that should be it */
