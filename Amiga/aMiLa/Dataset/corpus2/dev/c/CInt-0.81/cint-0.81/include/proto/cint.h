#ifndef PROTO_CINT_H
#define PROTO_CINT_H 1

#ifndef EXEC_TYPES_H
#   include <exec/types.h>
#endif

#ifndef CLIB_CINT_PROTOS_H
#   include <clib/cint_protos.h>
#endif
extern struct CIntBase * CIntBase;

#if defined(AMIGA) && !defined(PRAGMAS_CINT_H)
#   include <pragmas/cint.h>
#endif

#endif
