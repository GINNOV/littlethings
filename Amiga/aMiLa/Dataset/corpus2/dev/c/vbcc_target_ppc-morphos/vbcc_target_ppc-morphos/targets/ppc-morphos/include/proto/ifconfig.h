#ifndef _PROTO_IFCONFIG_H
#define _PROTO_IFCONFIG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_IFCONFIG_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/ifconfig_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *IfConfigBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/ifconfig.h>
#else
#include <inline/ifconfig.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/ifconfig_protos.h>
#endif
#else
#include <pragma/ifconfig_lib.h>
#endif

#endif	/*  _PROTO_IFCONFIG_H  */
