/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_DTCLASS_H
#define _PPCPRAGMA_DTCLASS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__DTCLASS_H
#include <ppcinline/dtclass.h>
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

#ifndef DTCLASS_BASE_NAME
#define DTCLASS_BASE_NAME DTClassBase
#endif /* !DTCLASS_BASE_NAME */

#define	ObtainEngine()	_ObtainEngine(DTCLASS_BASE_NAME)

static __inline Class *
_ObtainEngine(void *DTClassBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) DTClassBase;	
	return((Class *)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_DTCLASS_H */
