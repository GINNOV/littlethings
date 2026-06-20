/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_CONSOLE_H
#define _PPCPRAGMA_CONSOLE_H
#ifdef __GNUC__
#ifndef _PPCINLINE__CONSOLE_H
#include <ppcinline/console.h>
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

#ifndef CONSOLE_BASE_NAME
#define CONSOLE_BASE_NAME ConsoleDevice
#endif /* !CONSOLE_BASE_NAME */

#define	CDInputHandler(events, consoleDevice)	_CDInputHandler(CONSOLE_BASE_NAME, events, consoleDevice)

static __inline struct InputEvent *
_CDInputHandler(void *ConsoleDevice, struct InputEvent *events, struct Library *consoleDevice)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) events;
	MyCaos.a1		=(ULONG) consoleDevice;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) ConsoleDevice;	
	return((struct InputEvent *)PPCCallOS(&MyCaos));
}

#define	RawKeyConvert(events, buffer, length, keyMap)	_RawKeyConvert(CONSOLE_BASE_NAME, events, buffer, length, keyMap)

static __inline LONG
_RawKeyConvert(void *ConsoleDevice, struct InputEvent *events, STRPTR buffer, long length, struct KeyMap *keyMap)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) events;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d1		=(ULONG) length;
	MyCaos.a2		=(ULONG) keyMap;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) ConsoleDevice;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_CONSOLE_H */
