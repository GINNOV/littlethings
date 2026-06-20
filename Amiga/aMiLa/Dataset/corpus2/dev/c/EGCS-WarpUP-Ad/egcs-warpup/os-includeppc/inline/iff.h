/* Automatically generated header! Do not edit! */

#ifndef _INLINE_IFF_H
#define _INLINE_IFF_H

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif /* !__INLINE_MACROS_H */

#ifndef IFF_BASE_NAME
#define IFF_BASE_NAME IFFBase
#endif /* !IFF_BASE_NAME */

#define IFFL_CloseIFF(ifffile) \
	LP1NR(0x24, IFFL_CloseIFF, IFFL_HANDLE, ifffile, a1, \
	, IFF_BASE_NAME)

#define IFFL_CompressBlock(source, destination, size, mode) \
	LP4(0x90, ULONG, IFFL_CompressBlock, APTR, source, a0, APTR, destination, a1, ULONG, size, d0, ULONG, mode, d1, \
	, IFF_BASE_NAME)

#define IFFL_DecodePic(ifffile, bitmap) \
	LP2(0x3c, BOOL, IFFL_DecodePic, IFFL_HANDLE, ifffile, a1, struct BitMap *, bitmap, a0, \
	, IFF_BASE_NAME)

#define IFFL_DecompressBlock(source, destination, size, mode) \
	LP4(0x96, ULONG, IFFL_DecompressBlock, APTR, source, a0, APTR, destination, a1, ULONG, size, d0, ULONG, mode, d1, \
	, IFF_BASE_NAME)

#define IFFL_FindChunk(ifffile, chunkname) \
	LP2(0x2a, void				*, IFFL_FindChunk, IFFL_HANDLE, ifffile, a1, LONG, chunkname, d0, \
	, IFF_BASE_NAME)

#define IFFL_GetBMHD(ifffile) \
	LP1(0x30, struct IFFL_BMHD	*, IFFL_GetBMHD, IFFL_HANDLE, ifffile, a1, \
	, IFF_BASE_NAME)

#define IFFL_GetColorTab(ifffile, colortable) \
	LP2(0x36, LONG, IFFL_GetColorTab, IFFL_HANDLE, ifffile, a1, WORD *, colortable, a0, \
	, IFF_BASE_NAME)

#define IFFL_GetViewModes(ifffile) \
	LP1(0x54, ULONG, IFFL_GetViewModes, IFFL_HANDLE, ifffile, a1, \
	, IFF_BASE_NAME)

#define IFFL_IFFError() \
	LP0(0x4e, LONG, IFFL_IFFError, \
	, IFF_BASE_NAME)

#define IFFL_ModifyFrame(modifyform, bitmap) \
	LP2(0x60, BOOL, IFFL_ModifyFrame, void *, modifyform, a1, struct BitMap *, bitmap, a0, \
	, IFF_BASE_NAME)

#define IFFL_OpenIFF(filename, mode) \
	LP2(0x78, IFFL_HANDLE, IFFL_OpenIFF, char *, filename, a0, ULONG, mode, d0, \
	, IFF_BASE_NAME)

#define IFFL_PopChunk(iff) \
	LP1(0x84, LONG, IFFL_PopChunk, IFFL_HANDLE, iff, a0, \
	, IFF_BASE_NAME)

#define IFFL_PushChunk(iff, type, id) \
	LP3(0x7e, LONG, IFFL_PushChunk, IFFL_HANDLE, iff, a0, ULONG, type, d0, ULONG, id, d1, \
	, IFF_BASE_NAME)

#define IFFL_SaveBitMap(name, bmap, ctab, crmd) \
	LP4(0x42, BOOL, IFFL_SaveBitMap, char *, name, a0, struct BitMap *, bmap, a1, WORD *, ctab, a2, LONG, crmd, d0, \
	, IFF_BASE_NAME)

#define IFFL_SaveClip(name, bmap, ctab, crmd, x, y, w, h) \
	LP8(0x48, BOOL, IFFL_SaveClip, char *, name, a0, struct BitMap *, bmap, a1, WORD *, ctab, a2, LONG, crmd, d0, LONG, x, d1, LONG, y, d2, LONG, w, d3, LONG, h, d4, \
	, IFF_BASE_NAME)

#define IFFL_WriteChunkBytes(iff, buf, size) \
	LP3(0x8a, LONG, IFFL_WriteChunkBytes, IFFL_HANDLE, iff, a0, void *, buf, a1, LONG, size, d0, \
	, IFF_BASE_NAME)

#endif /* !_INLINE_IFF_H */
