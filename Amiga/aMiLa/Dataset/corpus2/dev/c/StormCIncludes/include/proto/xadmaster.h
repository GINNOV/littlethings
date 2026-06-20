#ifndef _PROTO_XADMASTER_H
#define _PROTO_XADMASTER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_XADMASTER_PROTOS_H
#include <clib/xadmaster_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct xadMasterBase *xadMasterBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__)
#include <inline/xadmaster.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/xadmaster_lib.h>
#endif
#endif

#endif	/*  _PROTO_XADMASTER_H  */
