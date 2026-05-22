/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_INPUT_H
#define _PPCPRAGMA_INPUT_H
#ifdef __GNUC__
#ifndef _PPCINLINE__INPUT_H
#include <ppcinline/input.h>
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

#ifndef INPUT_BASE_NAME
#define INPUT_BASE_NAME InputBase
#endif /* !INPUT_BASE_NAME */

#define	PeekQualifier()	_PeekQualifier(INPUT_BASE_NAME)

static __inline UWORD
_PeekQualifier(void *InputBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) InputBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_INPUT_H */
