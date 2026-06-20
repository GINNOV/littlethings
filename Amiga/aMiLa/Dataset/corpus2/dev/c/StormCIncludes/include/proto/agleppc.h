#ifndef _PROTO_AGLEPPC_H
#define _PROTO_AGLEPPC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_AGLEPPC_PROTOS_H
#include <clib/agleppc_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *gleppcBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__)
#include <inline/agleppc.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/agleppc_lib.h>
#endif
#endif

#endif	/*  _PROTO_AGLEPPC_H  */
