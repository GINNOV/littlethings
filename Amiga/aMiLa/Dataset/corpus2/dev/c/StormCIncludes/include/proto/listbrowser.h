#ifndef _PROTO_LISTBROWSER_H
#define _PROTO_LISTBROWSER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_LISTBROWSER_PROTOS_H
#include <clib/listbrowser_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *ListBrowserBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/listbrowser.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/listbrowser_lib.h>
#endif
#endif

#endif	/*  _PROTO_LISTBROWSER_H  */
