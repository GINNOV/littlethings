/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_COLORWHEEL_H
#define _PPCPRAGMA_COLORWHEEL_H
#ifdef __GNUC__
#ifndef _PPCINLINE__COLORWHEEL_H
#include <ppcinline/colorwheel.h>
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

#ifndef COLORWHEEL_BASE_NAME
#define COLORWHEEL_BASE_NAME ColorWheelBase
#endif /* !COLORWHEEL_BASE_NAME */

#define	ConvertHSBToRGB(hsb, rgb)	_ConvertHSBToRGB(COLORWHEEL_BASE_NAME, hsb, rgb)

static __inline void
_ConvertHSBToRGB(void *ColorWheelBase, struct ColorWheelHSB *hsb, struct ColorWheelRGB *rgb)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) hsb;
	MyCaos.a1		=(ULONG) rgb;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) ColorWheelBase;	
	PPCCallOS(&MyCaos);
}

#define	ConvertRGBToHSB(rgb, hsb)	_ConvertRGBToHSB(COLORWHEEL_BASE_NAME, rgb, hsb)

static __inline void
_ConvertRGBToHSB(void *ColorWheelBase, struct ColorWheelRGB *rgb, struct ColorWheelHSB *hsb)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rgb;
	MyCaos.a1		=(ULONG) hsb;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) ColorWheelBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_COLORWHEEL_H */
