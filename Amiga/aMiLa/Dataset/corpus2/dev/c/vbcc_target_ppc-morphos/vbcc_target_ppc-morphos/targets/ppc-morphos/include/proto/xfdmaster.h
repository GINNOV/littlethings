#ifndef _PROTO_XFDMASTER_H
#define _PROTO_XFDMASTER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_XFDMASTER_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/xfdmaster_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct xfdMasterBase *xfdMasterBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/xfdmaster.h>
#else
#include <inline/xfdmaster.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/xfdmaster_protos.h>
#endif
#else
#include <pragma/xfdmaster_lib.h>
#endif

#endif	/*  _PROTO_XFDMASTER_H  */
