#ifndef _PROTO_68040_H
#define _PROTO_68040_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_68040_PROTOS_H
#include <clib/68040_protos.h>
#endif

#ifdef __GNUC__
#include <inline/68040.h>
#else
#include <pragma/68040_lib.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *MC68040Base;
#endif

#endif	/*  _PROTO_68040_H  */
