#ifndef _PROTO_NEURALNET_H
#define _PROTO_NEURALNET_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_NEURALNET_PROTOS_H) && !defined(__GNUC__)
#include <clib/neuralnet_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *NeuralBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/neuralnet.h>
#else
#include <inline/neuralnet.h>
#endif
#elif defined(__VBCC__)
#include <inline/neuralnet_protos.h>
#else
#include <pragma/neuralnet_lib.h>
#endif

#endif	/*  _PROTO_NEURALNET_H  */
