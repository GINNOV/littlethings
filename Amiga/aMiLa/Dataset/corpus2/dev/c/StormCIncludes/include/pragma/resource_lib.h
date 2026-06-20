#ifndef _INCLUDE_PRAGMA_RESOURCE_LIB_H
#define _INCLUDE_PRAGMA_RESOURCE_LIB_H

#ifndef CLIB_RESOURCE_PROTOS_H
#include <clib/resource_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/resource.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ResourceBase,0x01E,RL_OpenResource(a0,a1,a2))
#pragma amicall(ResourceBase,0x024,RL_CloseResource(a0))
#pragma amicall(ResourceBase,0x02A,RL_NewObjectA(a0,d0,a1))
#pragma amicall(ResourceBase,0x030,RL_DisposeObject(a0,a1))
#pragma amicall(ResourceBase,0x036,RL_NewGroupA(a0,d0,a1))
#pragma amicall(ResourceBase,0x03C,RL_DisposeGroup(a0,a1))
#pragma amicall(ResourceBase,0x042,RL_GetObjectArray(a0,a1,d0))
#pragma amicall(ResourceBase,0x048,RL_SetResourceScreen(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ResourceBase RL_OpenResource      01E A9803
#pragma  libcall ResourceBase RL_CloseResource     024 801
#pragma  libcall ResourceBase RL_NewObjectA        02A 90803
#pragma  libcall ResourceBase RL_DisposeObject     030 9802
#pragma  libcall ResourceBase RL_NewGroupA         036 90803
#pragma  libcall ResourceBase RL_DisposeGroup      03C 9802
#pragma  libcall ResourceBase RL_GetObjectArray    042 09803
#pragma  libcall ResourceBase RL_SetResourceScreen 048 9802
#endif
#ifdef __STORM__
#pragma tagcall(ResourceBase,0x02A,RL_NewObject(a0,d0,a1))
#pragma tagcall(ResourceBase,0x036,RL_NewGroup(a0,d0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall ResourceBase RL_NewObject         02A 90803
#pragma  tagcall ResourceBase RL_NewGroup          036 90803
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_RESOURCE_LIB_H  */
