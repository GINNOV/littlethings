/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_ASYNCIO_H
#define _PPCPRAGMA_ASYNCIO_H
#ifdef __GNUC__
#ifndef _PPCINLINE_ASYNCIO_H
#include <powerup/ppcinline/asyncio.h>
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

#ifndef ASYNCIO_BASE_NAME
#define ASYNCIO_BASE_NAME AsyncIOBase
#endif /* !ASYNCIO_BASE_NAME */

#ifdef ASIO_NOEXTERNALS
#define	OpenAsync(fileName, mode, bufferSize, SysBase, DOSBase)	_OpenAsync(ASYNCIO_BASE_NAME, fileName, mode, bufferSize, SysBase, DOSBase)

static __inline AsyncFile *
_OpenAsync(void *AsyncIOBase, const STRPTR fileName, OpenModes mode, LONG bufferSize, struct ExecBase *SysBase, struct DosLibrary *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) fileName;
	MyCaos.d0		=(ULONG) mode;
	MyCaos.d1		=(ULONG) bufferSize;
	MyCaos.a1		=(ULONG) SysBase;
	MyCaos.a2		=(ULONG) DOSBase;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((AsyncFile *)PPCCallOS(&MyCaos));
}

#define	OpenAsyncFromFH(handle, mode, bufferSize, SysBase, DOSBase)	_OpenAsyncFromFH(ASYNCIO_BASE_NAME, handle, mode, bufferSize, SysBase, DOSBase)

static __inline AsyncFile *
_OpenAsyncFromFH(void *AsyncIOBase, BPTR handle, OpenModes mode, LONG bufferSize, struct ExecBase *SysBase, struct DosLibrary *DOSBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) handle;
	MyCaos.d0		=(ULONG) mode;
	MyCaos.d1		=(ULONG) bufferSize;
	MyCaos.a1		=(ULONG) SysBase;
	MyCaos.a2		=(ULONG) DOSBase;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((AsyncFile *)PPCCallOS(&MyCaos));
}

#else

#define	OpenAsync(fileName, mode, bufferSize)	_OpenAsync(ASYNCIO_BASE_NAME, fileName, mode, bufferSize)

static __inline AsyncFile *
_OpenAsync(void *AsyncIOBase, const STRPTR fileName, OpenModes mode, LONG bufferSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) fileName;
	MyCaos.d0		=(ULONG) mode;
	MyCaos.d1		=(ULONG) bufferSize;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((AsyncFile *)PPCCallOS(&MyCaos));
}

#define	OpenAsyncFromFH(handle, mode, bufferSize)	_OpenAsyncFromFH(ASYNCIO_BASE_NAME, handle, mode, bufferSize)

static __inline AsyncFile *
_OpenAsyncFromFH(void *AsyncIOBase, BPTR handle, OpenModes mode, LONG bufferSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) handle;
	MyCaos.d0		=(ULONG) mode;
	MyCaos.d1		=(ULONG) bufferSize;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((AsyncFile *)PPCCallOS(&MyCaos));
}
#endif /* ASIO_NOEXTERNALS */

#define	CloseAsync(file)	_CloseAsync(ASYNCIO_BASE_NAME, file)

static __inline LONG
_CloseAsync(void *AsyncIOBase, AsyncFile *file)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	PeekAsync(file, buffer, numBytes)	_PeekAsync(ASYNCIO_BASE_NAME, file, buffer, numBytes)

static __inline LONG
_PeekAsync(void *AsyncIOBase, AsyncFile *file, APTR buffer, LONG numBytes)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) numBytes;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReadAsync(file, buffer, numBytes)	_ReadAsync(ASYNCIO_BASE_NAME, file, buffer, numBytes)

static __inline LONG
_ReadAsync(void *AsyncIOBase, AsyncFile *file, APTR buffer, LONG numBytes)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) numBytes;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReadCharAsync(file)	_ReadCharAsync(ASYNCIO_BASE_NAME, file)

static __inline LONG
_ReadCharAsync(void *AsyncIOBase, AsyncFile *file)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReadLineAsync(file, buffer, size)	_ReadLineAsync(ASYNCIO_BASE_NAME, file, buffer, size)

static __inline LONG
_ReadLineAsync(void *AsyncIOBase, AsyncFile *file, APTR buffer, LONG size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	FGetsAsync(file, buffer, size)	_FGetsAsync(ASYNCIO_BASE_NAME, file, buffer, size)

static __inline APTR
_FGetsAsync(void *AsyncIOBase, AsyncFile *file, APTR buffer, LONG size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	FGetsLenAsync(file, buffer, size, length)	_FGetsLenAsync(ASYNCIO_BASE_NAME, file, buffer, size, length)

static __inline APTR
_FGetsLenAsync(void *AsyncIOBase, AsyncFile *file, APTR buffer, LONG size, LONG *length)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) size;
	MyCaos.a2		=(ULONG) length;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	WriteAsync(file, buffer, numBytes)	_WriteAsync(ASYNCIO_BASE_NAME, file, buffer, numBytes)

static __inline LONG
_WriteAsync(void *AsyncIOBase, AsyncFile *file, APTR buffer, LONG numBytes)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) numBytes;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WriteCharAsync(file, ch)	_WriteCharAsync(ASYNCIO_BASE_NAME, file, ch)

static __inline LONG
_WriteCharAsync(void *AsyncIOBase, AsyncFile *file, UBYTE ch)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.d0		=(ULONG) ch;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WriteLineAsync(file, line)	_WriteLineAsync(ASYNCIO_BASE_NAME, file, line)

static __inline LONG
_WriteLineAsync(void *AsyncIOBase, AsyncFile *file, STRPTR line)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.a1		=(ULONG) line;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SeekAsync(file, position, mode)	_SeekAsync(ASYNCIO_BASE_NAME, file, position, mode)

static __inline LONG
_SeekAsync(void *AsyncIOBase, AsyncFile *file, LONG position, SeekModes mode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) file;
	MyCaos.d0		=(ULONG) position;
	MyCaos.d1		=(ULONG) mode;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) AsyncIOBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_ASYNCIO_H */
