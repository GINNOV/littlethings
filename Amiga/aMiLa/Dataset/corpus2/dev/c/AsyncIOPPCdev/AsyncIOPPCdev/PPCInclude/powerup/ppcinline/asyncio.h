/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_ASYNCIO_H
#define _PPCINLINE_ASYNCIO_H

#ifndef __PPCINLINE_MACROS_H
#include <powerup/ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef ASYNCIO_BASE_NAME
#define ASYNCIO_BASE_NAME AsyncIOBase
#endif /* !ASYNCIO_BASE_NAME */


#ifdef ASIO_NOEXTERNALS

#define OpenAsync(fileName, mode, bufferSize, SysBase, DOSBase) \
	LP5(0x1e, AsyncFile *, OpenAsync, const STRPTR, fileName, a0, OpenModes, mode, d0, LONG, bufferSize, d1, struct ExecBase *, SysBase, a1, struct DosLibrary *, DOSBase, a2, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define OpenAsyncFromFH(handle, mode, bufferSize, SysBase, DOSBase) \
	LP5(0x24, AsyncFile *, OpenAsyncFromFH, BPTR, handle, a0, OpenModes, mode, d0, LONG, bufferSize, d1, struct ExecBase *, SysBase, a1, struct DosLibrary *, DOSBase, a2, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#else

#define OpenAsync(fileName, mode, bufferSize) \
	LP3(0x1e, AsyncFile *, OpenAsync, const STRPTR, fileName, a0, OpenModes, mode, d0, LONG, bufferSize, d1, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define OpenAsyncFromFH(handle, mode, bufferSize) \
	LP3(0x24, AsyncFile *, OpenAsyncFromFH, BPTR, handle, a0, OpenModes, mode, d0, LONG, bufferSize, d1, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#endif /* ASIO_NOEXTERNALS */


#define CloseAsync(file) \
	LP1(0x2a, LONG, CloseAsync, AsyncFile *, file, a0, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define PeekAsync(file, buffer, numBytes) \
	LP3(0x66, LONG, PeekAsync, AsyncFile *, file, a0, APTR, buffer, a1, LONG, numBytes, d0, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define ReadAsync(file, buffer, numBytes) \
	LP3(0x36, LONG, ReadAsync, AsyncFile *, file, a0, APTR, buffer, a1, LONG, numBytes, d0, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define ReadCharAsync(file) \
	LP1(0x42, LONG, ReadCharAsync, AsyncFile *, file, a0, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define ReadLineAsync(file, buffer, size) \
	LP3(0x4e, LONG, ReadLineAsync, AsyncFile *, file, a0, APTR, buffer, a1, LONG, size, d0, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define FGetsAsync(file, buffer, size) \
	LP3(0x5a, APTR, FGetsAsync, AsyncFile *, file, a0, APTR, buffer, a1, LONG, size, d0, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define FGetsLenAsync(file, buffer, size, length) \
	LP4(0x60, APTR, FGetsLenAsync, AsyncFile *, file, a0, APTR, buffer, a1, LONG, size, d0, LONG *, length, a2, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define WriteAsync(file, buffer, numBytes) \
	LP3(0x3c, LONG, WriteAsync, AsyncFile *, file, a0, APTR, buffer, a1, LONG, numBytes, d0, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define WriteCharAsync(file, ch) \
	LP2(0x48, LONG, WriteCharAsync, AsyncFile *, file, a0, UBYTE, ch, d0, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define WriteLineAsync(file, line) \
	LP2(0x54, LONG, WriteCharAsync, AsyncFile *, file, a0, STRPTR, line, a1, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define SeekAsync(file, position, mode) \
	LP3(0x30, LONG, SeekAsync, AsyncFile *, file, a0, LONG, position, d0, SeekModes, mode, d1, \
	, ASYNCIO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#endif /* !_PPCINLINE_ASYNCIO_H */
