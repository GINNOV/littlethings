/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_TRANSLATOR_H
#define _PPCPRAGMA_TRANSLATOR_H
#ifdef __GNUC__
#ifndef _PPCINLINE__TRANSLATOR_H
#include <ppcinline/translator.h>
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

#ifndef TRANSLATOR_BASE_NAME
#define TRANSLATOR_BASE_NAME TranslatorBase
#endif /* !TRANSLATOR_BASE_NAME */

#define	Translate(inputString, inputLength, outputBuffer, bufferSize)	_Translate(TRANSLATOR_BASE_NAME, inputString, inputLength, outputBuffer, bufferSize)

static __inline LONG
_Translate(void *TranslatorBase, STRPTR inputString, long inputLength, STRPTR outputBuffer, long bufferSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) inputString;
	MyCaos.d0		=(ULONG) inputLength;
	MyCaos.a1		=(ULONG) outputBuffer;
	MyCaos.d1		=(ULONG) bufferSize;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) TranslatorBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_TRANSLATOR_H */
