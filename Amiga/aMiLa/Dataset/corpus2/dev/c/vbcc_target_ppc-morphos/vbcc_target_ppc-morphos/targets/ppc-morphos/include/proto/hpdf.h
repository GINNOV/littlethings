#ifndef _PROTO_HPDF_H
#define _PROTO_HPDF_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_HPDF_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/hpdf_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *HPDFBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/hpdf.h>
#else
#include <inline/hpdf.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/hpdf_protos.h>
#endif
#else
#include <pragma/hpdf_lib.h>
#endif

#endif	/*  _PROTO_HPDF_H  */
