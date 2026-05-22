/* Automatically generated header (sfdc 1.10)! Do not edit! */

#ifndef _INLINE_VAMPIRE_H
#define _INLINE_VAMPIRE_H

#ifndef _SFDC_VARARG_DEFINED
#define _SFDC_VARARG_DEFINED
#ifdef __HAVE_IPTR_ATTR__
typedef APTR _sfdc_vararg __attribute__((iptr));
#else
typedef ULONG _sfdc_vararg;
#endif /* __HAVE_IPTR_ATTR__ */
#endif /* _SFDC_VARARG_DEFINED */

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif /* !__INLINE_MACROS_H */

#ifndef VAMPIRE_BASE_NAME
#define VAMPIRE_BASE_NAME VampireBase
#endif /* !VAMPIRE_BASE_NAME */

#define V_AllocExpansionPort(___unitNum, ___name) \
      LP2(0x6, APTR, V_AllocExpansionPort , ULONG, ___unitNum, d0, UBYTE *, ___name, a1,\
      , VAMPIRE_BASE_NAME)

#define V_FreeExpansionPort(___unitNum) \
      LP1NR(0xc, V_FreeExpansionPort , ULONG, ___unitNum, d0,\
      , VAMPIRE_BASE_NAME)

#define V_EnableAMMX(___version) \
      LP1(0x12, ULONG, V_EnableAMMX , ULONG, ___version, d0,\
      , VAMPIRE_BASE_NAME)

#endif /* !_INLINE_VAMPIRE_H */
