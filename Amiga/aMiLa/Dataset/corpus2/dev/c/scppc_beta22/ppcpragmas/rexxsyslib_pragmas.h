/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_REXXSYSLIB_H
#define _PPCPRAGMA_REXXSYSLIB_H
#ifdef __GNUC__
#ifndef _PPCINLINE__REXXSYSLIB_H
#include <ppcinline/rexxsyslib.h>
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

#ifndef REXXSYSLIB_BASE_NAME
#define REXXSYSLIB_BASE_NAME RexxSysBase
#endif /* !REXXSYSLIB_BASE_NAME */

#define	ClearRexxMsg(msgptr, count)	_ClearRexxMsg(REXXSYSLIB_BASE_NAME, msgptr, count)

static __inline void
_ClearRexxMsg(void *RexxSysBase, struct RexxMsg *msgptr, unsigned long count)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) msgptr;
	MyCaos.d0		=(ULONG) count;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	PPCCallOS(&MyCaos);
}

#define	CreateArgstring(string, length)	_CreateArgstring(REXXSYSLIB_BASE_NAME, string, length)

static __inline UBYTE *
_CreateArgstring(void *RexxSysBase, UBYTE *string, unsigned long length)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) string;
	MyCaos.d0		=(ULONG) length;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	return((UBYTE *)PPCCallOS(&MyCaos));
}

#define	CreateRexxMsg(port, extension, host)	_CreateRexxMsg(REXXSYSLIB_BASE_NAME, port, extension, host)

static __inline struct RexxMsg *
_CreateRexxMsg(void *RexxSysBase, struct MsgPort *port, UBYTE *extension, UBYTE *host)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) port;
	MyCaos.a1		=(ULONG) extension;
	MyCaos.d0		=(ULONG) host;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	return((struct RexxMsg *)PPCCallOS(&MyCaos));
}

#define	DeleteArgstring(argstring)	_DeleteArgstring(REXXSYSLIB_BASE_NAME, argstring)

static __inline void
_DeleteArgstring(void *RexxSysBase, UBYTE *argstring)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) argstring;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	PPCCallOS(&MyCaos);
}

#define	DeleteRexxMsg(packet)	_DeleteRexxMsg(REXXSYSLIB_BASE_NAME, packet)

static __inline void
_DeleteRexxMsg(void *RexxSysBase, struct RexxMsg *packet)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) packet;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	PPCCallOS(&MyCaos);
}

#define	FillRexxMsg(msgptr, count, mask)	_FillRexxMsg(REXXSYSLIB_BASE_NAME, msgptr, count, mask)

static __inline BOOL
_FillRexxMsg(void *RexxSysBase, struct RexxMsg *msgptr, unsigned long count, unsigned long mask)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) msgptr;
	MyCaos.d0		=(ULONG) count;
	MyCaos.d1		=(ULONG) mask;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsRexxMsg(msgptr)	_IsRexxMsg(REXXSYSLIB_BASE_NAME, msgptr)

static __inline BOOL
_IsRexxMsg(void *RexxSysBase, struct RexxMsg *msgptr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) msgptr;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	LengthArgstring(argstring)	_LengthArgstring(REXXSYSLIB_BASE_NAME, argstring)

static __inline ULONG
_LengthArgstring(void *RexxSysBase, UBYTE *argstring)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) argstring;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	LockRexxBase(resource)	_LockRexxBase(REXXSYSLIB_BASE_NAME, resource)

static __inline void
_LockRexxBase(void *RexxSysBase, unsigned long resource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) resource;
	MyCaos.caos_Un.Offset	=	(-450);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	PPCCallOS(&MyCaos);
}

#define	UnlockRexxBase(resource)	_UnlockRexxBase(REXXSYSLIB_BASE_NAME, resource)

static __inline void
_UnlockRexxBase(void *RexxSysBase, unsigned long resource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) resource;
	MyCaos.caos_Un.Offset	=	(-456);
	MyCaos.a6		=(ULONG) RexxSysBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_REXXSYSLIB_H */
