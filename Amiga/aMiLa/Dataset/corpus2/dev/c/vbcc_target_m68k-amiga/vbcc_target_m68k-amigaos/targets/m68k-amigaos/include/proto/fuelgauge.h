#ifndef _PROTO_FUELGAUGE_H
#define _PROTO_FUELGAUGE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_FUELGAUGE_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/fuelgauge_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *FuelGaugeBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/fuelgauge.h>
#else
#include <inline/fuelgauge.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/fuelgauge_protos.h>
#endif
#else
#include <pragma/fuelgauge_lib.h>
#endif

#endif	/*  _PROTO_FUELGAUGE_H  */
