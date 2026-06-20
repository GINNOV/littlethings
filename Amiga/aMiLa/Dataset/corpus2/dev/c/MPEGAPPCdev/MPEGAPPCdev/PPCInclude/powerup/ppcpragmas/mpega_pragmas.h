/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_MPEGA_H
#define _PPCPRAGMA_MPEGA_H
#ifdef __GNUC__
#ifndef _PPCINLINE_MPEGA_H
#include <powerup/ppcinline/mpega.h>
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

#ifndef MPEGA_BASE_NAME
#define MPEGA_BASE_NAME MPEGABase
#endif /* !MPEGA_BASE_NAME */

#define	MPEGA_open(stream_name, ctrl)	_MPEGA_open(MPEGA_BASE_NAME, stream_name, ctrl)

static __inline MPEGA_STREAM *
_MPEGA_open(void *MPEGABase, char *stream_name, MPEGA_CTRL *ctrl)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) stream_name;
	MyCaos.a1		=(ULONG) ctrl;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) MPEGABase;	
	return((MPEGA_STREAM *)PPCCallOS(&MyCaos));
}

#define	MPEGA_close(mpds)	_MPEGA_close(MPEGA_BASE_NAME, mpds)

static __inline void
_MPEGA_close(void *MPEGABase, MPEGA_STREAM *mpds)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) mpds;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) MPEGABase;	
	PPCCallOS(&MyCaos);
}

#define	MPEGA_decode_frame(mpds, pcm)	_MPEGA_decode_frame(MPEGA_BASE_NAME, mpds, pcm)

static __inline LONG
_MPEGA_decode_frame(void *MPEGABase, MPEGA_STREAM *mpds, WORD *pcm[MPEGA_MAX_CHANNELS])
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) mpds;
	MyCaos.a1		=(ULONG) pcm;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) MPEGABase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MPEGA_seek(mpds, ms_time_position)	_MPEGA_seek(MPEGA_BASE_NAME, mpds, ms_time_position)

static __inline LONG
_MPEGA_seek(void *MPEGABase, MPEGA_STREAM *mpds, ULONG ms_time_position)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) mpds;
	MyCaos.d0		=(ULONG) ms_time_position;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) MPEGABase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MPEGA_time(mpds, ms_time_position)	_MPEGA_time(MPEGA_BASE_NAME, mpds, ms_time_position)

static __inline LONG
_MPEGA_time(void *MPEGABase, MPEGA_STREAM *mpds, ULONG *ms_time_position)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) mpds;
	MyCaos.a1		=(ULONG) ms_time_position;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) MPEGABase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MPEGA_find_sync(buffer, buffersize)	_MPEGA_find_sync(MPEGA_BASE_NAME, buffer, buffersize)

static __inline LONG
_MPEGA_find_sync(void *MPEGABase, BYTE *buffer, LONG buffersize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) buffersize;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) MPEGABase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MPEGA_scale(mpds, scale_percent)	_MPEGA_scale(MPEGA_BASE_NAME, mpds, scale_percent)

static __inline LONG
_MPEGA_scale(void *MPEGABase, MPEGA_STREAM *mpds, LONG scale_percent)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) mpds;
	MyCaos.d0		=(ULONG) scale_percent;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) MPEGABase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_MPEGA_H */
