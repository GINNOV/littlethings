#ifndef _PROTO_MMU_H
#define _PROTO_MMU_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_MMU_PROTOS_H
#include <clib/MMU_protos.h>
#endif

#ifdef __GNUC__
#include <inline/MMU.h>
#else
#include <pragma/MMU_lib.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *MMUBase;
#endif

#endif	/*  _PROTO_MMU_H  */
