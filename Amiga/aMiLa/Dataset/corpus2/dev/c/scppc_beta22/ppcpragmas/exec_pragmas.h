/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_EXEC_H
#define _PPCPRAGMA_EXEC_H
#ifdef __GNUC__
#ifndef _PPCINLINE__EXEC_H
#include <ppcinline/exec.h>
#endif
#else

#ifndef POWERUP_PPCLIB_INTERFACE_H
#include <powerup/ppclib/interface.h>
#endif

#ifndef POWERUP_GCCLIB_PROTOS_H
#include <powerup/gcclib/powerup_protos.h>
#endif

#ifndef NO_PPCINLINE_STDARG
#define NO_PPCINLINE_STDARG
#endif/* SAS C PPC inlines */

#ifndef EXEC_BASE_NAME
#define EXEC_BASE_NAME SysBase
#endif /* !EXEC_BASE_NAME */

#define	AbortIO(ioRequest)	_AbortIO(EXEC_BASE_NAME, ioRequest)

static __inline void
_AbortIO(void *SysBase, struct IORequest *ioRequest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) ioRequest;
	MyCaos.caos_Un.Offset	=	(-480);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddDevice(device)	_AddDevice(EXEC_BASE_NAME, device)

static __inline void
_AddDevice(void *SysBase, struct Device *device)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) device;
	MyCaos.caos_Un.Offset	=	(-432);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddHead(list, node)	_AddHead(EXEC_BASE_NAME, list, node)

static __inline void
_AddHead(void *SysBase, struct List *list, struct Node *node)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) list;
	MyCaos.a1		=(ULONG) node;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddIntServer(intNumber, interrupt)	_AddIntServer(EXEC_BASE_NAME, intNumber, interrupt)

static __inline void
_AddIntServer(void *SysBase, long intNumber, struct Interrupt *interrupt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) intNumber;
	MyCaos.a1		=(ULONG) interrupt;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddLibrary(library)	_AddLibrary(EXEC_BASE_NAME, library)

static __inline void
_AddLibrary(void *SysBase, struct Library *library)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) library;
	MyCaos.caos_Un.Offset	=	(-396);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddMemHandler(memhand)	_AddMemHandler(EXEC_BASE_NAME, memhand)

static __inline void
_AddMemHandler(void *SysBase, struct Interrupt *memhand)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) memhand;
	MyCaos.caos_Un.Offset	=	(-774);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddMemList(size, attributes, pri, base, name)	_AddMemList(EXEC_BASE_NAME, size, attributes, pri, base, name)

static __inline void
_AddMemList(void *SysBase, unsigned long size, unsigned long attributes, long pri, APTR base, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) size;
	MyCaos.d1		=(ULONG) attributes;
	MyCaos.d2		=(ULONG) pri;
	MyCaos.a0		=(ULONG) base;
	MyCaos.a1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-618);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddPort(port)	_AddPort(EXEC_BASE_NAME, port)

static __inline void
_AddPort(void *SysBase, struct MsgPort *port)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) port;
	MyCaos.caos_Un.Offset	=	(-354);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddResource(resource)	_AddResource(EXEC_BASE_NAME, resource)

static __inline void
_AddResource(void *SysBase, APTR resource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) resource;
	MyCaos.caos_Un.Offset	=	(-486);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddSemaphore(sigSem)	_AddSemaphore(EXEC_BASE_NAME, sigSem)

static __inline void
_AddSemaphore(void *SysBase, struct SignalSemaphore *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-600);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddTail(list, node)	_AddTail(EXEC_BASE_NAME, list, node)

static __inline void
_AddTail(void *SysBase, struct List *list, struct Node *node)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) list;
	MyCaos.a1		=(ULONG) node;
	MyCaos.caos_Un.Offset	=	(-246);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AddTask(task, initPC, finalPC)	_AddTask(EXEC_BASE_NAME, task, initPC, finalPC)

static __inline APTR
_AddTask(void *SysBase, struct Task *task, APTR initPC, APTR finalPC)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) task;
	MyCaos.a2		=(ULONG) initPC;
	MyCaos.a3		=(ULONG) finalPC;
	MyCaos.caos_Un.Offset	=	(-282);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	Alert(alertNum)	_Alert(EXEC_BASE_NAME, alertNum)

static __inline void
_Alert(void *SysBase, unsigned long alertNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d7		=(ULONG) alertNum;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	AllocAbs(byteSize, location)	_AllocAbs(EXEC_BASE_NAME, byteSize, location)

static __inline APTR
_AllocAbs(void *SysBase, unsigned long byteSize, APTR location)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) byteSize;
	MyCaos.a1		=(ULONG) location;
	MyCaos.caos_Un.Offset	=	(-204);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	AllocEntry(entry)	_AllocEntry(EXEC_BASE_NAME, entry)

static __inline struct MemList *
_AllocEntry(void *SysBase, struct MemList *entry)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) entry;
	MyCaos.caos_Un.Offset	=	(-222);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct MemList *)PPCCallOS(&MyCaos));
}

#define	AllocMem(byteSize, requirements)	_AllocMem(EXEC_BASE_NAME, byteSize, requirements)

static __inline APTR
_AllocMem(void *SysBase, unsigned long byteSize, unsigned long requirements)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) byteSize;
	MyCaos.d1		=(ULONG) requirements;
	MyCaos.caos_Un.Offset	=	(-198);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	AllocPooled(poolHeader, memSize)	_AllocPooled(EXEC_BASE_NAME, poolHeader, memSize)

static __inline APTR
_AllocPooled(void *SysBase, APTR poolHeader, unsigned long memSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) poolHeader;
	MyCaos.d0		=(ULONG) memSize;
	MyCaos.caos_Un.Offset	=	(-708);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	AllocSignal(signalNum)	_AllocSignal(EXEC_BASE_NAME, signalNum)

static __inline BYTE
_AllocSignal(void *SysBase, long signalNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) signalNum;
	MyCaos.caos_Un.Offset	=	(-330);
	MyCaos.a6		=(ULONG) SysBase;	
	return((BYTE)PPCCallOS(&MyCaos));
}

#define	AllocTrap(trapNum)	_AllocTrap(EXEC_BASE_NAME, trapNum)

static __inline LONG
_AllocTrap(void *SysBase, long trapNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) trapNum;
	MyCaos.caos_Un.Offset	=	(-342);
	MyCaos.a6		=(ULONG) SysBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AllocVec(byteSize, requirements)	_AllocVec(EXEC_BASE_NAME, byteSize, requirements)

static __inline APTR
_AllocVec(void *SysBase, unsigned long byteSize, unsigned long requirements)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) byteSize;
	MyCaos.d1		=(ULONG) requirements;
	MyCaos.caos_Un.Offset	=	(-684);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	Allocate(freeList, byteSize)	_Allocate(EXEC_BASE_NAME, freeList, byteSize)

static __inline APTR
_Allocate(void *SysBase, struct MemHeader *freeList, unsigned long byteSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) freeList;
	MyCaos.d0		=(ULONG) byteSize;
	MyCaos.caos_Un.Offset	=	(-186);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	AttemptSemaphore(sigSem)	_AttemptSemaphore(EXEC_BASE_NAME, sigSem)

static __inline ULONG
_AttemptSemaphore(void *SysBase, struct SignalSemaphore *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-576);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	AttemptSemaphoreShared(sigSem)	_AttemptSemaphoreShared(EXEC_BASE_NAME, sigSem)

static __inline ULONG
_AttemptSemaphoreShared(void *SysBase, struct SignalSemaphore *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-720);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	AvailMem(requirements)	_AvailMem(EXEC_BASE_NAME, requirements)

static __inline ULONG
_AvailMem(void *SysBase, unsigned long requirements)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) requirements;
	MyCaos.caos_Un.Offset	=	(-216);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CacheClearE(address, length, caches)	_CacheClearE(EXEC_BASE_NAME, address, length, caches)

static __inline void
_CacheClearE(void *SysBase, APTR address, unsigned long length, unsigned long caches)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) address;
	MyCaos.d0		=(ULONG) length;
	MyCaos.d1		=(ULONG) caches;
	MyCaos.caos_Un.Offset	=	(-642);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CacheClearU()	_CacheClearU(EXEC_BASE_NAME)

static __inline void
_CacheClearU(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-636);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CacheControl(cacheBits, cacheMask)	_CacheControl(EXEC_BASE_NAME, cacheBits, cacheMask)

static __inline ULONG
_CacheControl(void *SysBase, unsigned long cacheBits, unsigned long cacheMask)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) cacheBits;
	MyCaos.d1		=(ULONG) cacheMask;
	MyCaos.caos_Un.Offset	=	(-648);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CachePostDMA(address, length, flags)	_CachePostDMA(EXEC_BASE_NAME, address, length, flags)

static __inline void
_CachePostDMA(void *SysBase, APTR address, ULONG *length, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) address;
	MyCaos.a1		=(ULONG) length;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-768);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CachePreDMA(address, length, flags)	_CachePreDMA(EXEC_BASE_NAME, address, length, flags)

static __inline APTR
_CachePreDMA(void *SysBase, APTR address, ULONG *length, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) address;
	MyCaos.a1		=(ULONG) length;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-762);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	Cause(interrupt)	_Cause(EXEC_BASE_NAME, interrupt)

static __inline void
_Cause(void *SysBase, struct Interrupt *interrupt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) interrupt;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CheckIO(ioRequest)	_CheckIO(EXEC_BASE_NAME, ioRequest)

static __inline struct IORequest *
_CheckIO(void *SysBase, struct IORequest *ioRequest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) ioRequest;
	MyCaos.caos_Un.Offset	=	(-468);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct IORequest *)PPCCallOS(&MyCaos));
}

#define	ChildFree(tid)	_ChildFree(EXEC_BASE_NAME, tid)

static __inline void
_ChildFree(void *SysBase, APTR tid)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) tid;
	MyCaos.caos_Un.Offset	=	(-738);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	ChildOrphan(tid)	_ChildOrphan(EXEC_BASE_NAME, tid)

static __inline void
_ChildOrphan(void *SysBase, APTR tid)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) tid;
	MyCaos.caos_Un.Offset	=	(-744);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	ChildStatus(tid)	_ChildStatus(EXEC_BASE_NAME, tid)

static __inline void
_ChildStatus(void *SysBase, APTR tid)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) tid;
	MyCaos.caos_Un.Offset	=	(-750);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	ChildWait(tid)	_ChildWait(EXEC_BASE_NAME, tid)

static __inline void
_ChildWait(void *SysBase, APTR tid)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) tid;
	MyCaos.caos_Un.Offset	=	(-756);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CloseDevice(ioRequest)	_CloseDevice(EXEC_BASE_NAME, ioRequest)

static __inline void
_CloseDevice(void *SysBase, struct IORequest *ioRequest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) ioRequest;
	MyCaos.caos_Un.Offset	=	(-450);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CloseLibrary(library)	_CloseLibrary(EXEC_BASE_NAME, library)

static __inline void
_CloseLibrary(void *SysBase, struct Library *library)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) library;
	MyCaos.caos_Un.Offset	=	(-414);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	ColdReboot()	_ColdReboot(EXEC_BASE_NAME)

static __inline void
_ColdReboot(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-726);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CopyMem(source, dest, size)	_CopyMem(EXEC_BASE_NAME, source, dest, size)

static __inline void
_CopyMem(void *SysBase, APTR source, APTR dest, unsigned long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) source;
	MyCaos.a1		=(ULONG) dest;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-624);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CopyMemQuick(source, dest, size)	_CopyMemQuick(EXEC_BASE_NAME, source, dest, size)

static __inline void
_CopyMemQuick(void *SysBase, APTR source, APTR dest, unsigned long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) source;
	MyCaos.a1		=(ULONG) dest;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-630);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	CreateIORequest(port, size)	_CreateIORequest(EXEC_BASE_NAME, port, size)

static __inline APTR
_CreateIORequest(void *SysBase, struct MsgPort *port, unsigned long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) port;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-654);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	CreateMsgPort()	_CreateMsgPort(EXEC_BASE_NAME)

static __inline struct MsgPort *
_CreateMsgPort(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-666);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct MsgPort *)PPCCallOS(&MyCaos));
}

#define	CreatePool(requirements, puddleSize, threshSize)	_CreatePool(EXEC_BASE_NAME, requirements, puddleSize, threshSize)

static __inline APTR
_CreatePool(void *SysBase, unsigned long requirements, unsigned long puddleSize, unsigned long threshSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) requirements;
	MyCaos.d1		=(ULONG) puddleSize;
	MyCaos.d2		=(ULONG) threshSize;
	MyCaos.caos_Un.Offset	=	(-696);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	Deallocate(freeList, memoryBlock, byteSize)	_Deallocate(EXEC_BASE_NAME, freeList, memoryBlock, byteSize)

static __inline void
_Deallocate(void *SysBase, struct MemHeader *freeList, APTR memoryBlock, unsigned long byteSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) freeList;
	MyCaos.a1		=(ULONG) memoryBlock;
	MyCaos.d0		=(ULONG) byteSize;
	MyCaos.caos_Un.Offset	=	(-192);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	Debug(flags)	_Debug(EXEC_BASE_NAME, flags)

static __inline void
_Debug(void *SysBase, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	DeleteIORequest(iorequest)	_DeleteIORequest(EXEC_BASE_NAME, iorequest)

static __inline void
_DeleteIORequest(void *SysBase, APTR iorequest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iorequest;
	MyCaos.caos_Un.Offset	=	(-660);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	DeleteMsgPort(port)	_DeleteMsgPort(EXEC_BASE_NAME, port)

static __inline void
_DeleteMsgPort(void *SysBase, struct MsgPort *port)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) port;
	MyCaos.caos_Un.Offset	=	(-672);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	DeletePool(poolHeader)	_DeletePool(EXEC_BASE_NAME, poolHeader)

static __inline void
_DeletePool(void *SysBase, APTR poolHeader)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) poolHeader;
	MyCaos.caos_Un.Offset	=	(-702);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	Disable()	_Disable(EXEC_BASE_NAME)

static __inline void
_Disable(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	DoIO(ioRequest)	_DoIO(EXEC_BASE_NAME, ioRequest)

static __inline BYTE
_DoIO(void *SysBase, struct IORequest *ioRequest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) ioRequest;
	MyCaos.caos_Un.Offset	=	(-456);
	MyCaos.a6		=(ULONG) SysBase;	
	return((BYTE)PPCCallOS(&MyCaos));
}

#define	Enable()	_Enable(EXEC_BASE_NAME)

static __inline void
_Enable(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	Enqueue(list, node)	_Enqueue(EXEC_BASE_NAME, list, node)

static __inline void
_Enqueue(void *SysBase, struct List *list, struct Node *node)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) list;
	MyCaos.a1		=(ULONG) node;
	MyCaos.caos_Un.Offset	=	(-270);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	FindName(list, name)	_FindName(EXEC_BASE_NAME, list, name)

static __inline struct Node *
_FindName(void *SysBase, struct List *list, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) list;
	MyCaos.a1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-276);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Node *)PPCCallOS(&MyCaos));
}

#define	FindPort(name)	_FindPort(EXEC_BASE_NAME, name)

static __inline struct MsgPort *
_FindPort(void *SysBase, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-390);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct MsgPort *)PPCCallOS(&MyCaos));
}

#define	FindResident(name)	_FindResident(EXEC_BASE_NAME, name)

static __inline struct Resident *
_FindResident(void *SysBase, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Resident *)PPCCallOS(&MyCaos));
}

#define	FindSemaphore(sigSem)	_FindSemaphore(EXEC_BASE_NAME, sigSem)

static __inline struct SignalSemaphore *
_FindSemaphore(void *SysBase, UBYTE *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-594);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct SignalSemaphore *)PPCCallOS(&MyCaos));
}

#define	FindTask(name)	_FindTask(EXEC_BASE_NAME, name)

static __inline struct Task *
_FindTask(void *SysBase, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-294);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Task *)PPCCallOS(&MyCaos));
}

#define	Forbid()	_Forbid(EXEC_BASE_NAME)

static __inline void
_Forbid(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeEntry(entry)	_FreeEntry(EXEC_BASE_NAME, entry)

static __inline void
_FreeEntry(void *SysBase, struct MemList *entry)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) entry;
	MyCaos.caos_Un.Offset	=	(-228);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeMem(memoryBlock, byteSize)	_FreeMem(EXEC_BASE_NAME, memoryBlock, byteSize)

static __inline void
_FreeMem(void *SysBase, APTR memoryBlock, unsigned long byteSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) memoryBlock;
	MyCaos.d0		=(ULONG) byteSize;
	MyCaos.caos_Un.Offset	=	(-210);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	FreePooled(poolHeader, memory, memSize)	_FreePooled(EXEC_BASE_NAME, poolHeader, memory, memSize)

static __inline void
_FreePooled(void *SysBase, APTR poolHeader, APTR memory, unsigned long memSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) poolHeader;
	MyCaos.a1		=(ULONG) memory;
	MyCaos.d0		=(ULONG) memSize;
	MyCaos.caos_Un.Offset	=	(-714);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeSignal(signalNum)	_FreeSignal(EXEC_BASE_NAME, signalNum)

static __inline void
_FreeSignal(void *SysBase, long signalNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) signalNum;
	MyCaos.caos_Un.Offset	=	(-336);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeTrap(trapNum)	_FreeTrap(EXEC_BASE_NAME, trapNum)

static __inline void
_FreeTrap(void *SysBase, long trapNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) trapNum;
	MyCaos.caos_Un.Offset	=	(-348);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeVec(memoryBlock)	_FreeVec(EXEC_BASE_NAME, memoryBlock)

static __inline void
_FreeVec(void *SysBase, APTR memoryBlock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) memoryBlock;
	MyCaos.caos_Un.Offset	=	(-690);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	GetCC()	_GetCC(EXEC_BASE_NAME)

static __inline ULONG
_GetCC(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-528);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetMsg(port)	_GetMsg(EXEC_BASE_NAME, port)

static __inline struct Message *
_GetMsg(void *SysBase, struct MsgPort *port)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) port;
	MyCaos.caos_Un.Offset	=	(-372);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Message *)PPCCallOS(&MyCaos));
}

#define	InitCode(startClass, version)	_InitCode(EXEC_BASE_NAME, startClass, version)

static __inline void
_InitCode(void *SysBase, unsigned long startClass, unsigned long version)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) startClass;
	MyCaos.d1		=(ULONG) version;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	InitResident(resident, segList)	_InitResident(EXEC_BASE_NAME, resident, segList)

static __inline APTR
_InitResident(void *SysBase, struct Resident *resident, unsigned long segList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) resident;
	MyCaos.d1		=(ULONG) segList;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	InitSemaphore(sigSem)	_InitSemaphore(EXEC_BASE_NAME, sigSem)

static __inline void
_InitSemaphore(void *SysBase, struct SignalSemaphore *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-558);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	InitStruct(initTable, memory, size)	_InitStruct(EXEC_BASE_NAME, initTable, memory, size)

static __inline void
_InitStruct(void *SysBase, APTR initTable, APTR memory, unsigned long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) initTable;
	MyCaos.a2		=(ULONG) memory;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	Insert(list, node, pred)	_Insert(EXEC_BASE_NAME, list, node, pred)

static __inline void
_Insert(void *SysBase, struct List *list, struct Node *node, struct Node *pred)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) list;
	MyCaos.a1		=(ULONG) node;
	MyCaos.a2		=(ULONG) pred;
	MyCaos.caos_Un.Offset	=	(-234);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	MakeFunctions(target, functionArray, funcDispBase)	_MakeFunctions(EXEC_BASE_NAME, target, functionArray, funcDispBase)

static __inline void
_MakeFunctions(void *SysBase, APTR target, APTR functionArray, unsigned long funcDispBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) target;
	MyCaos.a1		=(ULONG) functionArray;
	MyCaos.a2		=(ULONG) funcDispBase;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	MakeLibrary(funcInit, structInit, libInit, dataSize, segList)	_MakeLibrary(EXEC_BASE_NAME, funcInit, structInit, libInit, dataSize, segList)

static __inline struct Library *
_MakeLibrary(void *SysBase, APTR funcInit, APTR structInit, unsigned long (*libInit)(), unsigned long dataSize, unsigned long segList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) funcInit;
	MyCaos.a1		=(ULONG) structInit;
	MyCaos.a2		=(ULONG) libInit;
	MyCaos.d0		=(ULONG) dataSize;
	MyCaos.d1		=(ULONG) segList;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Library *)PPCCallOS(&MyCaos));
}

#define	ObtainQuickVector(interruptCode)	_ObtainQuickVector(EXEC_BASE_NAME, interruptCode)

static __inline ULONG
_ObtainQuickVector(void *SysBase, APTR interruptCode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) interruptCode;
	MyCaos.caos_Un.Offset	=	(-786);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ObtainSemaphore(sigSem)	_ObtainSemaphore(EXEC_BASE_NAME, sigSem)

static __inline void
_ObtainSemaphore(void *SysBase, struct SignalSemaphore *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-564);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	ObtainSemaphoreList(sigSem)	_ObtainSemaphoreList(EXEC_BASE_NAME, sigSem)

static __inline void
_ObtainSemaphoreList(void *SysBase, struct List *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-582);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	ObtainSemaphoreShared(sigSem)	_ObtainSemaphoreShared(EXEC_BASE_NAME, sigSem)

static __inline void
_ObtainSemaphoreShared(void *SysBase, struct SignalSemaphore *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-678);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	OldOpenLibrary(libName)	_OldOpenLibrary(EXEC_BASE_NAME, libName)

static __inline struct Library *
_OldOpenLibrary(void *SysBase, UBYTE *libName)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) libName;
	MyCaos.caos_Un.Offset	=	(-408);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Library *)PPCCallOS(&MyCaos));
}

#define	OpenDevice(devName, unit, ioRequest, flags)	_OpenDevice(EXEC_BASE_NAME, devName, unit, ioRequest, flags)

static __inline BYTE
_OpenDevice(void *SysBase, UBYTE *devName, unsigned long unit, struct IORequest *ioRequest, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) devName;
	MyCaos.d0		=(ULONG) unit;
	MyCaos.a1		=(ULONG) ioRequest;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-444);
	MyCaos.a6		=(ULONG) SysBase;	
	return((BYTE)PPCCallOS(&MyCaos));
}

#define	OpenLibrary(libName, version)	_OpenLibrary(EXEC_BASE_NAME, libName, version)

static __inline struct Library *
_OpenLibrary(void *SysBase, UBYTE *libName, unsigned long version)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) libName;
	MyCaos.d0		=(ULONG) version;
	MyCaos.caos_Un.Offset	=	(-552);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Library *)PPCCallOS(&MyCaos));
}

#define	OpenResource(resName)	_OpenResource(EXEC_BASE_NAME, resName)

static __inline APTR
_OpenResource(void *SysBase, UBYTE *resName)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) resName;
	MyCaos.caos_Un.Offset	=	(-498);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	Permit()	_Permit(EXEC_BASE_NAME)

static __inline void
_Permit(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	Procure(sigSem, bidMsg)	_Procure(EXEC_BASE_NAME, sigSem, bidMsg)

static __inline ULONG
_Procure(void *SysBase, struct SignalSemaphore *sigSem, struct SemaphoreMessage *bidMsg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.a1		=(ULONG) bidMsg;
	MyCaos.caos_Un.Offset	=	(-540);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	PutMsg(port, message)	_PutMsg(EXEC_BASE_NAME, port, message)

static __inline void
_PutMsg(void *SysBase, struct MsgPort *port, struct Message *message)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) port;
	MyCaos.a1		=(ULONG) message;
	MyCaos.caos_Un.Offset	=	(-366);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RawDoFmt(formatString, dataStream, putChProc, putChData)	_RawDoFmt(EXEC_BASE_NAME, formatString, dataStream, putChProc, putChData)

static __inline APTR
_RawDoFmt(void *SysBase, UBYTE *formatString, APTR dataStream, void (*putChProc)(), APTR putChData)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) formatString;
	MyCaos.a1		=(ULONG) dataStream;
	MyCaos.a2		=(ULONG) putChProc;
	MyCaos.a3		=(ULONG) putChData;
	MyCaos.caos_Un.Offset	=	(-522);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	ReleaseSemaphore(sigSem)	_ReleaseSemaphore(EXEC_BASE_NAME, sigSem)

static __inline void
_ReleaseSemaphore(void *SysBase, struct SignalSemaphore *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-570);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	ReleaseSemaphoreList(sigSem)	_ReleaseSemaphoreList(EXEC_BASE_NAME, sigSem)

static __inline void
_ReleaseSemaphoreList(void *SysBase, struct List *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-588);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RemDevice(device)	_RemDevice(EXEC_BASE_NAME, device)

static __inline void
_RemDevice(void *SysBase, struct Device *device)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) device;
	MyCaos.caos_Un.Offset	=	(-438);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RemHead(list)	_RemHead(EXEC_BASE_NAME, list)

static __inline struct Node *
_RemHead(void *SysBase, struct List *list)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) list;
	MyCaos.caos_Un.Offset	=	(-258);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Node *)PPCCallOS(&MyCaos));
}

#define	RemIntServer(intNumber, interrupt)	_RemIntServer(EXEC_BASE_NAME, intNumber, interrupt)

static __inline void
_RemIntServer(void *SysBase, long intNumber, struct Interrupt *interrupt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) intNumber;
	MyCaos.a1		=(ULONG) interrupt;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RemLibrary(library)	_RemLibrary(EXEC_BASE_NAME, library)

static __inline void
_RemLibrary(void *SysBase, struct Library *library)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) library;
	MyCaos.caos_Un.Offset	=	(-402);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RemMemHandler(memhand)	_RemMemHandler(EXEC_BASE_NAME, memhand)

static __inline void
_RemMemHandler(void *SysBase, struct Interrupt *memhand)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) memhand;
	MyCaos.caos_Un.Offset	=	(-780);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RemPort(port)	_RemPort(EXEC_BASE_NAME, port)

static __inline void
_RemPort(void *SysBase, struct MsgPort *port)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) port;
	MyCaos.caos_Un.Offset	=	(-360);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RemResource(resource)	_RemResource(EXEC_BASE_NAME, resource)

static __inline void
_RemResource(void *SysBase, APTR resource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) resource;
	MyCaos.caos_Un.Offset	=	(-492);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RemSemaphore(sigSem)	_RemSemaphore(EXEC_BASE_NAME, sigSem)

static __inline void
_RemSemaphore(void *SysBase, struct SignalSemaphore *sigSem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) sigSem;
	MyCaos.caos_Un.Offset	=	(-606);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	RemTail(list)	_RemTail(EXEC_BASE_NAME, list)

static __inline struct Node *
_RemTail(void *SysBase, struct List *list)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) list;
	MyCaos.caos_Un.Offset	=	(-264);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Node *)PPCCallOS(&MyCaos));
}

#define	RemTask(task)	_RemTask(EXEC_BASE_NAME, task)

static __inline void
_RemTask(void *SysBase, struct Task *task)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) task;
	MyCaos.caos_Un.Offset	=	(-288);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	Remove(node)	_Remove(EXEC_BASE_NAME, node)

static __inline void
_Remove(void *SysBase, struct Node *node)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) node;
	MyCaos.caos_Un.Offset	=	(-252);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	ReplyMsg(message)	_ReplyMsg(EXEC_BASE_NAME, message)

static __inline void
_ReplyMsg(void *SysBase, struct Message *message)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) message;
	MyCaos.caos_Un.Offset	=	(-378);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	SendIO(ioRequest)	_SendIO(EXEC_BASE_NAME, ioRequest)

static __inline void
_SendIO(void *SysBase, struct IORequest *ioRequest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) ioRequest;
	MyCaos.caos_Un.Offset	=	(-462);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	SetExcept(newSignals, signalSet)	_SetExcept(EXEC_BASE_NAME, newSignals, signalSet)

static __inline ULONG
_SetExcept(void *SysBase, unsigned long newSignals, unsigned long signalSet)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) newSignals;
	MyCaos.d1		=(ULONG) signalSet;
	MyCaos.caos_Un.Offset	=	(-312);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SetFunction(library, funcOffset, newFunction)	_SetFunction(EXEC_BASE_NAME, library, funcOffset, newFunction)

static __inline APTR
_SetFunction(void *SysBase, struct Library *library, long funcOffset, unsigned long (*newFunction)())
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) library;
	MyCaos.a0		=(ULONG) funcOffset;
	MyCaos.d0		=(ULONG) newFunction;
	MyCaos.caos_Un.Offset	=	(-420);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	SetIntVector(intNumber, interrupt)	_SetIntVector(EXEC_BASE_NAME, intNumber, interrupt)

static __inline struct Interrupt *
_SetIntVector(void *SysBase, long intNumber, struct Interrupt *interrupt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) intNumber;
	MyCaos.a1		=(ULONG) interrupt;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Interrupt *)PPCCallOS(&MyCaos));
}

#define	SetSR(newSR, mask)	_SetSR(EXEC_BASE_NAME, newSR, mask)

static __inline ULONG
_SetSR(void *SysBase, unsigned long newSR, unsigned long mask)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) newSR;
	MyCaos.d1		=(ULONG) mask;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SetSignal(newSignals, signalSet)	_SetSignal(EXEC_BASE_NAME, newSignals, signalSet)

static __inline ULONG
_SetSignal(void *SysBase, unsigned long newSignals, unsigned long signalSet)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) newSignals;
	MyCaos.d1		=(ULONG) signalSet;
	MyCaos.caos_Un.Offset	=	(-306);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SetTaskPri(task, priority)	_SetTaskPri(EXEC_BASE_NAME, task, priority)

static __inline BYTE
_SetTaskPri(void *SysBase, struct Task *task, long priority)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) task;
	MyCaos.d0		=(ULONG) priority;
	MyCaos.caos_Un.Offset	=	(-300);
	MyCaos.a6		=(ULONG) SysBase;	
	return((BYTE)PPCCallOS(&MyCaos));
}

#define	Signal(task, signalSet)	_Signal(EXEC_BASE_NAME, task, signalSet)

static __inline void
_Signal(void *SysBase, struct Task *task, unsigned long signalSet)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) task;
	MyCaos.d0		=(ULONG) signalSet;
	MyCaos.caos_Un.Offset	=	(-324);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	StackSwap(newStack)	_StackSwap(EXEC_BASE_NAME, newStack)

static __inline void
_StackSwap(void *SysBase, struct StackSwapStruct *newStack)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) newStack;
	MyCaos.caos_Un.Offset	=	(-732);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	SumKickData()	_SumKickData(EXEC_BASE_NAME)

static __inline ULONG
_SumKickData(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-612);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SumLibrary(library)	_SumLibrary(EXEC_BASE_NAME, library)

static __inline void
_SumLibrary(void *SysBase, struct Library *library)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) library;
	MyCaos.caos_Un.Offset	=	(-426);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	SuperState()	_SuperState(EXEC_BASE_NAME)

static __inline APTR
_SuperState(void *SysBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) SysBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	Supervisor(userFunction)	_Supervisor(EXEC_BASE_NAME, userFunction)

static __inline ULONG
_Supervisor(void *SysBase, unsigned long (*userFunction)())
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a5		=(ULONG) userFunction;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	TypeOfMem(address)	_TypeOfMem(EXEC_BASE_NAME, address)

static __inline ULONG
_TypeOfMem(void *SysBase, APTR address)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) address;
	MyCaos.caos_Un.Offset	=	(-534);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	UserState(sysStack)	_UserState(EXEC_BASE_NAME, sysStack)

static __inline void
_UserState(void *SysBase, APTR sysStack)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) sysStack;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	Vacate(sigSem, bidMsg)	_Vacate(EXEC_BASE_NAME, sigSem, bidMsg)

static __inline void
_Vacate(void *SysBase, struct SignalSemaphore *sigSem, struct SemaphoreMessage *bidMsg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sigSem;
	MyCaos.a1		=(ULONG) bidMsg;
	MyCaos.caos_Un.Offset	=	(-546);
	MyCaos.a6		=(ULONG) SysBase;	
	PPCCallOS(&MyCaos);
}

#define	Wait(signalSet)	_Wait(EXEC_BASE_NAME, signalSet)

static __inline ULONG
_Wait(void *SysBase, unsigned long signalSet)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) signalSet;
	MyCaos.caos_Un.Offset	=	(-318);
	MyCaos.a6		=(ULONG) SysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	WaitIO(ioRequest)	_WaitIO(EXEC_BASE_NAME, ioRequest)

static __inline BYTE
_WaitIO(void *SysBase, struct IORequest *ioRequest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) ioRequest;
	MyCaos.caos_Un.Offset	=	(-474);
	MyCaos.a6		=(ULONG) SysBase;	
	return((BYTE)PPCCallOS(&MyCaos));
}

#define	WaitPort(port)	_WaitPort(EXEC_BASE_NAME, port)

static __inline struct Message *
_WaitPort(void *SysBase, struct MsgPort *port)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) port;
	MyCaos.caos_Un.Offset	=	(-384);
	MyCaos.a6		=(ULONG) SysBase;	
	return((struct Message *)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_EXEC_H */
