/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_RAMDRIVE_H
#define _PPCPRAGMA_RAMDRIVE_H
#ifdef __GNUC__
#ifndef _PPCINLINE__RAMDRIVE_H
#include <ppcinline/ramdrive.h>
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

#ifndef RAMDRIVE_BASE_NAME
#define RAMDRIVE_BASE_NAME RamdriveDevice
#endif /* !RAMDRIVE_BASE_NAME */

#define	KillRAD(unit)	_KillRAD(RAMDRIVE_BASE_NAME, unit)

static __inline STRPTR
_KillRAD(void *RamdriveDevice, unsigned long unit)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) unit;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) RamdriveDevice;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	KillRAD0()	_KillRAD0(RAMDRIVE_BASE_NAME)

static __inline STRPTR
_KillRAD0(void *RamdriveDevice)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) RamdriveDevice;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_RAMDRIVE_H */
