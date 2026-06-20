#ifndef _PROTO_GATEXPR_H
#define _PROTO_GATEXPR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_GATEXPR_PROTOS_H
#include <clib/GateXpr_protos.h>
#endif

#ifdef __GNUC__
#include <inline/GateXpr.h>
#else
#include <pragma/GateXpr_lib.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *GateXprBase;
#endif

#endif	/*  _PROTO_GATEXPR_H  */
