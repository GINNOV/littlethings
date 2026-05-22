#ifndef _PROTO_680X0_H
#define _PROTO_680X0_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_680X0_PROTOS_H
#include <clib/680x0_protos.h>
#endif

#ifdef __GNUC__
#include <inline/680x0.h>
#else
#include <pragma/680x0_lib.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *MC680x0Base;
#endif

#endif	/*  _PROTO_680X0_H  */
