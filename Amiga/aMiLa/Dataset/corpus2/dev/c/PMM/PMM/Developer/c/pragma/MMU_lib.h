#ifndef _INCLUDE_PRAGMA_MMU_LIB_H
#define _INCLUDE_PRAGMA_MMU_LIB_H

#ifndef CLIB_MMU_PROTOS_H
#include <clib/MMU_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MMUBase,0x01E,AllocAligned(d0,d1,a0))
#pragma amicall(MMUBase,0x024,GetMapping(a0))
#pragma amicall(MMUBase,0x02A,ReleaseMapping(a0,a1))
#pragma amicall(MMUBase,0x030,GetPageSize(a0))
#pragma amicall(MMUBase,0x036,GetMMUType())
#pragma amicall(MMUBase,0x048,LockMMUContext(a0))
#pragma amicall(MMUBase,0x04E,UnlockMMUContext(a0))
#pragma amicall(MMUBase,0x054,SetPropertiesA(a0,d1,d2,a1,d0,a2))
#pragma amicall(MMUBase,0x05A,GetPropertiesA(a0,a1,a2))
#pragma amicall(MMUBase,0x060,RebuildTree(a0))
#pragma amicall(MMUBase,0x066,SetPagePropertiesA(a0,d1,d2,a1,a2))
#pragma amicall(MMUBase,0x06C,GetPagePropertiesA(a0,a1,a2))
#pragma amicall(MMUBase,0x072,CreateMMUContextA(a0))
#pragma amicall(MMUBase,0x078,DeleteMMUContext(a0))
#pragma amicall(MMUBase,0x084,AllocLineVec(d0,d1))
#pragma amicall(MMUBase,0x08A,PhysicalPageLocation(a0,a1))
#pragma amicall(MMUBase,0x090,SuperContext(a0))
#pragma amicall(MMUBase,0x096,DefaultContext())
#pragma amicall(MMUBase,0x09C,EnterMMUContext(a0,a1))
#pragma amicall(MMUBase,0x0A2,LeaveMMUContext(a1))
#pragma amicall(MMUBase,0x0A8,AddContextHookA(a0))
#pragma amicall(MMUBase,0x0AE,RemContextHook(a1))
#pragma amicall(MMUBase,0x0B4,AddMessageHookA(a0))
#pragma amicall(MMUBase,0x0BA,RemMessageHook(a1))
#pragma amicall(MMUBase,0x0C0,ActivateException(a1))
#pragma amicall(MMUBase,0x0C6,DeactivateException(a1))
#pragma amicall(MMUBase,0x0CC,AttemptLockMMUContext(a0))
#pragma amicall(MMUBase,0x0D2,LockContextList())
#pragma amicall(MMUBase,0x0D8,UnlockContextList())
#pragma amicall(MMUBase,0x0DE,AttemptLockContextList())
#pragma amicall(MMUBase,0x0E4,SetPropertyList(a0,a1))
#pragma amicall(MMUBase,0x0EA,TouchPropertyList(a1))
#pragma amicall(MMUBase,0x0F0,CurrentContext(a1))
#pragma amicall(MMUBase,0x0F6,DMAInitiate(d1,a0,a1,d0))
#pragma amicall(MMUBase,0x0FC,DMATerminate(d1))
#pragma amicall(MMUBase,0x102,PhysicalLocation(d1,a0,a1))
#pragma amicall(MMUBase,0x108,RemapSize(a0))
#pragma amicall(MMUBase,0x10E,WithoutMMU(a5))
#pragma amicall(MMUBase,0x114,SetBusError(a0,a1))
#pragma amicall(MMUBase,0x11A,GetMMUContextData(a0,d0))
#pragma amicall(MMUBase,0x120,SetMMUContextDataA(a0,a1))
#pragma amicall(MMUBase,0x126,NewMapping())
#pragma amicall(MMUBase,0x12C,CopyMapping(a0,a1,d0,d1,d2))
#pragma amicall(MMUBase,0x132,DupMapping(a0))
#pragma amicall(MMUBase,0x138,CopyContextRegion(a0,a1,d0,d1,d2))
#pragma amicall(MMUBase,0x13E,SetPropertiesMapping(a0,a1,d0,d1,d2))
#pragma amicall(MMUBase,0x144,SetMappingPropertiesA(a0,d1,d2,a1,d0,a2))
#pragma amicall(MMUBase,0x14A,GetMappingPropertiesA(a0,a1,a2))
#pragma amicall(MMUBase,0x150,BuildIndirect(a0,d0,d1))
#pragma amicall(MMUBase,0x156,SetIndirect(a0,a1,d0))
#pragma amicall(MMUBase,0x15C,GetIndirect(a0,a1,d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MMUBase AllocAligned         01E 81003
#pragma  libcall MMUBase GetMapping           024 801
#pragma  libcall MMUBase ReleaseMapping       02A 9802
#pragma  libcall MMUBase GetPageSize          030 801
#pragma  libcall MMUBase GetMMUType           036 00
#pragma  libcall MMUBase LockMMUContext       048 801
#pragma  libcall MMUBase UnlockMMUContext     04E 801
#pragma  libcall MMUBase SetPropertiesA       054 A0921806
#pragma  libcall MMUBase GetPropertiesA       05A A9803
#pragma  libcall MMUBase RebuildTree          060 801
#pragma  libcall MMUBase SetPagePropertiesA   066 A921805
#pragma  libcall MMUBase GetPagePropertiesA   06C A9803
#pragma  libcall MMUBase CreateMMUContextA    072 801
#pragma  libcall MMUBase DeleteMMUContext     078 801
#pragma  libcall MMUBase AllocLineVec         084 1002
#pragma  libcall MMUBase PhysicalPageLocation 08A 9802
#pragma  libcall MMUBase SuperContext         090 801
#pragma  libcall MMUBase DefaultContext       096 00
#pragma  libcall MMUBase EnterMMUContext      09C 9802
#pragma  libcall MMUBase LeaveMMUContext      0A2 901
#pragma  libcall MMUBase AddContextHookA      0A8 801
#pragma  libcall MMUBase RemContextHook       0AE 901
#pragma  libcall MMUBase AddMessageHookA      0B4 801
#pragma  libcall MMUBase RemMessageHook       0BA 901
#pragma  libcall MMUBase ActivateException    0C0 901
#pragma  libcall MMUBase DeactivateException  0C6 901
#pragma  libcall MMUBase AttemptLockMMUContext 0CC 801
#pragma  libcall MMUBase LockContextList      0D2 00
#pragma  libcall MMUBase UnlockContextList    0D8 00
#pragma  libcall MMUBase AttemptLockContextList 0DE 00
#pragma  libcall MMUBase SetPropertyList      0E4 9802
#pragma  libcall MMUBase TouchPropertyList    0EA 901
#pragma  libcall MMUBase CurrentContext       0F0 901
#pragma  libcall MMUBase DMAInitiate          0F6 098104
#pragma  libcall MMUBase DMATerminate         0FC 101
#pragma  libcall MMUBase PhysicalLocation     102 98103
#pragma  libcall MMUBase RemapSize            108 801
#pragma  libcall MMUBase WithoutMMU           10E D01
#pragma  libcall MMUBase SetBusError          114 9802
#pragma  libcall MMUBase GetMMUContextData    11A 0802
#pragma  libcall MMUBase SetMMUContextDataA   120 9802
#pragma  libcall MMUBase NewMapping           126 00
#pragma  libcall MMUBase CopyMapping          12C 2109805
#pragma  libcall MMUBase DupMapping           132 801
#pragma  libcall MMUBase CopyContextRegion    138 2109805
#pragma  libcall MMUBase SetPropertiesMapping 13E 2109805
#pragma  libcall MMUBase SetMappingPropertiesA 144 A0921806
#pragma  libcall MMUBase GetMappingPropertiesA 14A A9803
#pragma  libcall MMUBase BuildIndirect        150 10803
#pragma  libcall MMUBase SetIndirect          156 09803
#pragma  libcall MMUBase GetIndirect          15C 09803
#endif
#ifdef __STORM__
#pragma tagcall(MMUBase,0x054,SetProperties(a0,d1,d2,a1,d0,a2))
#pragma tagcall(MMUBase,0x05A,GetProperties(a0,a1,a2))
#pragma tagcall(MMUBase,0x066,SetPageProperties(a0,d1,d2,a1,a2))
#pragma tagcall(MMUBase,0x06C,GetPageProperties(a0,a1,a2))
#pragma tagcall(MMUBase,0x072,CreateMMUContext(a0))
#pragma tagcall(MMUBase,0x0A8,AddContextHook(a0))
#pragma tagcall(MMUBase,0x0B4,AddMessageHook(a0))
#pragma tagcall(MMUBase,0x120,SetMMUContextData(a0,a1))
#pragma tagcall(MMUBase,0x144,SetMappingProperties(a0,d1,d2,a1,d0,a2))
#pragma tagcall(MMUBase,0x14A,GetMappingProperties(a0,a1,a2))
#endif
#ifdef __SASC_60
#pragma  tagcall MMUBase SetProperties        054 A0921806
#pragma  tagcall MMUBase GetProperties        05A A9803
#pragma  tagcall MMUBase SetPageProperties    066 A921805
#pragma  tagcall MMUBase GetPageProperties    06C A9803
#pragma  tagcall MMUBase CreateMMUContext     072 801
#pragma  tagcall MMUBase AddContextHook       0A8 801
#pragma  tagcall MMUBase AddMessageHook       0B4 801
#pragma  tagcall MMUBase SetMMUContextData    120 9802
#pragma  tagcall MMUBase SetMappingProperties 144 A0921806
#pragma  tagcall MMUBase GetMappingProperties 14A A9803
#endif

#endif	/*  _INCLUDE_PRAGMA_MMU_LIB_H  */
