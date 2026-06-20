#ifndef _PROTO_TEST_H
#define _PROTO_TEST_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_TEST_PROTOS_H) && !defined(__GNUC__)
#include <clib/test_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *TestBase;
#endif

#ifdef __GNUC__
#include <inline/test.h>
#elif defined(__VBCC__)
#include <inline/test_protos.h>
#else
#include <pragma/test_lib.h>
#endif

#endif	/*  _PROTO_TEST_H  */
