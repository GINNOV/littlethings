#ifndef _PROTO_DATEBROWSER_H
#define _PROTO_DATEBROWSER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_DATEBROWSER_PROTOS_H
#include <clib/datebrowser_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *DateBrowserBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/datebrowser.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/datebrowser_lib.h>
#endif
#endif

#endif	/*  _PROTO_DATEBROWSER_H  */
