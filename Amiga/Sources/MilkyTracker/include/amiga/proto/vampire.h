/* Automatically generated header (sfdc 1.10)! Do not edit! */

#ifndef PROTO_VAMPIRE_H
#define PROTO_VAMPIRE_H

#include <clib/vampire_protos.h>

#ifndef _NO_INLINE
# if defined(__GNUC__)
#  ifdef __AROS__
#   include <defines/vampire.h>
#  else
#   include <inline/vampire.h>
#  endif
# else
#  include <pragmas/vampire_pragmas.h>
# endif
#endif /* _NO_INLINE */

#ifdef __amigaos4__
# include <interfaces/vampire.h>
# ifndef __NOGLOBALIFACE__
   extern struct VampireIFace *IVampire;
# endif /* __NOGLOBALIFACE__*/
#endif /* !__amigaos4__ */
#ifndef __NOLIBBASE__
  extern struct Library *
# ifdef __CONSTLIBBASEDECL__
   __CONSTLIBBASEDECL__
# endif /* __CONSTLIBBASEDECL__ */
  VampireBase;
#endif /* !__NOLIBBASE__ */

#endif /* !PROTO_VAMPIRE_H */
