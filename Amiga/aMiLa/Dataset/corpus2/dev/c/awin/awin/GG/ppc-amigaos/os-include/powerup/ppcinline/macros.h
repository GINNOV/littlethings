#ifndef __INLINE_MACROS_H
#define __INLINE_MACROS_H

#include <powerup/gcclib/powerup_protos.h>

/* Use these macros to calculate cache flush start address and cache flush
length. */
#define __CACHE_START(start) ((void *) ((unsigned long int) (start) & ~31))
#define __CACHE_LENGTH(start,length) ((((length) + (unsigned long int) (start) + 31) & ~31) - ((unsigned long int) (start) & ~31))

/*
   General macros for Amiga function calls. Not all the possibilities have
   been created - only the ones which exist in OS 3.1. Third party libraries
   and future versions of AmigaOS will maybe need some new ones...

   LPX - functions that take X arguments.

   Modifiers (variations are possible):
   NR - no return (void),
   A4, A5 - "a4" or "a5" is used as one of the arguments,
   UB - base will be given explicitly by user (see cia.resource).
   FP - one of the parameters has type "pointer to function".

   "bt" arguments are not used - they are provided for backward compatibility
   only.
   Actually..the "bt" parameter is needed because otherwise the macro doesn`t
   work for some reason i don`t know gcc puts an empty argument at the position
   before the argument bn and without the placeholder "bt".
   I think it has something to do with #define *_BASE_NAME

   the (cm1==IF_CACHEFLUSHAREA) conditional is optimized away
*/

#ifndef __INLINE_STUB_H
#include <powerup/ppcinline/stubs.h>
#endif

#ifndef POWERUP_PPCLIB_INTERFACE_H
#include <powerup/ppclib/interface.h>
#endif

#define LP0(offs, rt, name, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP0NR(offs, name, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

#define LP1(offs, rt, name, t1, v1, r1, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP1NR(offs, name, t1, v1, r1, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only graphics.library/AttemptLockLayerRom() */
#define LP1A5(offs, rt, name, t1, v1, r1, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

/* Only graphics.library/LockLayerRom() and graphics.library/UnlockLayerRom() */
#define LP1NRA5(offs, name, t1, v1, r1, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only exec.library/Supervisor() */
#define LP1A5FP(offs, rt, name, t1, v1, r1, bt, bn, fpt, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   typedef fpt;							\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})


#define LP2(offs, rt, name, t1, v1, r1, t2, v2, r2, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);  					\
      _##name##_re;						\
   }								\
})

#define LP2NR(offs, name, t1, v1, r1, t2, v2, r2, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only cia.resource/AbleICR() and cia.resource/SetICR() */
#define LP2UB(offs, rt, name, t1, v1, r1, t2, v2, r2, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

/* Only dos.library/InternalUnLoadSeg() */
#define LP2FP(offs, rt, name, t1, v1, r1, t2, v2, r2, bt, bn, fpt, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   typedef fpt;							\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP3(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP3NR(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only cia.resource/AddICRVector() */
#define LP3UB(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

/* Only cia.resource/RemICRVector() */
#define LP3NRUB(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only exec.library/SetFunction() */
#define LP3FP(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, bt, bn, fpt, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   typedef fpt;							\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

/* Only graphics.library/SetCollision() */
#define LP3NRFP(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, bt, bn, fpt, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   typedef fpt;							\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

#define LP4(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP4NR(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only exec.library/RawDoFmt() */
#define LP4FP(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, bt, bn, fpt, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   typedef fpt;							\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP5(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP5NR(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only exec.library/MakeLibrary() */
#define LP5FP(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, bt, bn, fpt, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   typedef fpt;							\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP6(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP6NR(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

#define LP7(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#define LP7NR(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only workbench.library/AddAppIconA() */
#define LP7A4(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

/* Would you believe that there really are beasts that need more than 7
   arguments? :-) */

/* For example intuition.library/AutoRequest() */
#define LP8(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, t8, v8, r8, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->##r8		= (ULONG) v8;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

/* For example intuition.library/ModifyProp() */
#define LP8NR(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, t8, v8, r8, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->##r8		= (ULONG) v8;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* For example layers.library/CreateUpfrontHookLayer() */
#define LP9(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, t8, v8, r8, t9, v9, r9, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->##r8		= (ULONG) v8;			\
      MyCaos->##r9		= (ULONG) v9;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

/* For example intuition.library/NewModifyProp() */
#define LP9NR(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, t8, v8, r8, t9, v9, r9, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->##r8		= (ULONG) v8;			\
      MyCaos->##r9		= (ULONG) v9;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* -HS- LP10 is needed by:
   cybergraphics.library/ReadPixelArray
   cybergraphics.library/ScalePixelArray
   cybergraphics.library/WritePixelArray
*/
#define LP10(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, t8, v8, r8, t9, v9, r9, t10, v10, r10, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->##r8		= (ULONG) v8;			\
      MyCaos->##r9		= (ULONG) v9;			\
      MyCaos->##r10		= (ULONG) v10;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

/* Only graphics.library/BltMaskBitMapRastPort() */
#define LP10NR(offs, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, t8, v8, r8, t9, v9, r9, t10, v10, r10, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->##r8		= (ULONG) v8;			\
      MyCaos->##r9		= (ULONG) v9;			\
      MyCaos->##r10		= (ULONG) v10;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      PPCCallOS (MyCaos);					\
   }								\
})

/* Only graphics.library/BltBitMap() */
#define LP11(offs, rt, name, t1, v1, r1, t2, v2, r2, t3, v3, r3, t4, v4, r4, t5, v5, r5, t6, v6, r6, t7, v7, r7, t8, v8, r8, t9, v9, r9, t10, v10, r10, t11, v11, r11, bt, bn, cm1, cs1, cl1, cm2, cs2, cl2 )	\
({								\
   struct Caos *MyCaos;						\
   MyCaos = (struct Caos *) ((unsigned long int) ((char *) alloca (sizeof (struct Caos) + 31) + 31) & ~31); \
   {								\
      rt _##name##_re;						\
      MyCaos->##r1		= (ULONG) v1;			\
      MyCaos->##r2		= (ULONG) v2;			\
      MyCaos->##r3		= (ULONG) v3;			\
      MyCaos->##r4		= (ULONG) v4;			\
      MyCaos->##r5		= (ULONG) v5;			\
      MyCaos->##r6		= (ULONG) v6;			\
      MyCaos->##r7		= (ULONG) v7;			\
      MyCaos->##r8		= (ULONG) v8;			\
      MyCaos->##r9		= (ULONG) v9;			\
      MyCaos->##r10		= (ULONG) v10;			\
      MyCaos->##r11		= (ULONG) v11;			\
      MyCaos->a6		= (ULONG) bn;			\
      MyCaos->M68kCacheMode	=	cm1;			\
      if ((cm1==IF_CACHEFLUSHAREA) || (cm1==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->M68kStart	=	cs1;			\
        MyCaos->M68kLength	=	cl1;			\
      }								\
      MyCaos->PPCCacheMode	=	cm2;			\
      if ((cm2==IF_CACHEFLUSHAREA) || (cm2==IF_CACHEINVALIDAREA))	\
      {								\
        MyCaos->PPCStart	=	cs2;			\
        MyCaos->PPCLength	=	cl2;			\
      }								\
      MyCaos->caos_Un.Offset	=	(-offs);		\
      _##name##_re = (rt) PPCCallOS (MyCaos);			\
      _##name##_re;						\
   }								\
})

#endif /* __INLINE_MACROS_H */


