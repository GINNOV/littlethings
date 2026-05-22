#ifndef _PROTO_HDW_H
#define _PROTO_HDW_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_HDW_PROTOS_H) && !defined(__GNUC__)
#include <clib/hdw_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *HDWBase;
#endif

#ifdef __GNUC__
#include <inline/hdw.h>
#elif !defined(__VBCC__)
#include <pragma/hdw_lib.h>
#endif

#endif	/*  _PROTO_HDW_H  */
