#ifndef PROTO_POWERSDL_H
#define PROTO_POWERSDL_H

#ifndef __NOLIBBASE__
extern struct Library *
#ifdef __CONSTLIBBASEDECL__
__CONSTLIBBASEDECL__
#endif /* __CONSTLIBBASEDECL__ */
PowerSDLBase;
#endif /* !__NOLIBBASE__ */

#include <clib/powersdl_protos.h>

#ifdef __GNUC__
#ifdef __PPC__
#ifndef _NO_PPCINLINE
#include <ppcinline/powersdl.h>
#endif /* _NO_PPCINLINE */
#else
#ifndef _NO_INLINE
#include <inline/powersdl.h>
#endif /* _NO_INLINE */
#endif /* __PPC__ */

#elif defined(__VBCC__)
#include <inline/powersdl_protos.h>

#else
#include <pragmas/powersdl_pragmas.h>
#endif /* __GNUC__ */

#endif /* !PROTO_POWERSDL_H */
