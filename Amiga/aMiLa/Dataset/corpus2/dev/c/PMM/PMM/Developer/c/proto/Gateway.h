#ifndef _PROTO_GATEWAY_H
#define _PROTO_GATEWAY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_GATEWAY_PROTOS_H
#include <clib/Gateway_protos.h>
#endif

#ifdef __GNUC__
#include <inline/Gateway.h>
#else
#include <pragma/Gateway_lib.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *GatewayBase;
#endif

#endif	/*  _PROTO_GATEWAY_H  */
