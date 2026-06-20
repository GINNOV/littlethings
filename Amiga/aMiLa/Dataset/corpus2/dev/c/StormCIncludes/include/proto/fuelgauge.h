#ifndef _PROTO_FUELGAUGE_H
#define _PROTO_FUELGAUGE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_FUELGAUGE_PROTOS_H
#include <clib/fuelgauge_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *FuelGaugeBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/fuelgauge.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/fuelgauge_lib.h>
#endif
#endif

#endif	/*  _PROTO_FUELGAUGE_H  */
