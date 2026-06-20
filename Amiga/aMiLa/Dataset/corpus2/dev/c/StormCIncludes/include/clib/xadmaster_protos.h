#ifndef  CLIB_XADMASTER_PROTOS_H
#define  CLIB_XADMASTER_PROTOS_H

/*
**	$VER: clib/xadmaster_protos.h 8.0 (20.08.2000)
**	xadmaster.library function prototypes
**
**	Copyright © 1998-2000 by Dirk Stöcker
**	All Rights Reserved.
*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef LIBRARIES_XADMASTER_H
#include <libraries/xadmaster.h>
#endif

APTR xadAllocObjectA(LONG type, struct TagItem *tags);
APTR xadAllocObject(LONG type, Tag tag1, ...);

void xadFreeObjectA(APTR object, struct TagItem *tags);
void xadFreeObject(APTR object, Tag tag1, ...);

struct xadClient *xadRecogFileA(ULONG size, APTR memory, struct TagItem *tags);
struct xadClient *xadRecogFile(ULONG size, APTR memory, Tag tag1, ...);

LONG xadGetInfoA(struct xadArchiveInfo *ai, struct TagItem *tags);
LONG xadGetInfo(struct xadArchiveInfo *ai, Tag tag1, ...);

void xadFreeInfo(struct xadArchiveInfo *ai);

LONG xadFileUnArcA(struct xadArchiveInfo *ai, struct TagItem *tags);
LONG xadFileUnArc(struct xadArchiveInfo *ai, Tag tag1, ...);

LONG xadDiskUnArcA(struct xadArchiveInfo *ai, struct TagItem *tags);
LONG xadDiskUnArc(struct xadArchiveInfo *ai, Tag tag1, ...);

STRPTR xadGetErrorText(ULONG errnum);

struct xadClient *xadGetClientInfo(void);

/* these functions can be called from client functions only! */
LONG xadHookAccess(ULONG command, LONG data, APTR buffer, struct xadArchiveInfo *ai);
LONG xadHookTagAccessA(ULONG command, LONG data, APTR buffer, struct xadArchiveInfo *ai, struct TagItem *tags);
LONG xadHookTagAccess(ULONG command, LONG data, APTR buffer, struct xadArchiveInfo *ai, Tag tag1, ...);

LONG xadConvertDatesA(struct TagItem *tags);
LONG xadConvertDates(Tag tag1, ...);

UWORD xadCalcCRC16(UWORD id, UWORD init, ULONG size, STRPTR buffer);
ULONG xadCalcCRC32(ULONG id, ULONG init, ULONG size, STRPTR buffer);

APTR xadAllocVec(ULONG size, ULONG flags);
void xadCopyMem(APTR src, APTR dest, ULONG size);

LONG xadConvertProtectionA(struct TagItem *tags);
LONG xadConvertProtection(Tag tag1, ...);

LONG xadGetDiskInfoA(struct xadArchiveInfo *ai, struct TagItem *tags);
LONG xadGetDiskInfo(struct xadArchiveInfo *ai, Tag tag1, ...);

LONG xadDiskFileUnArcA(struct xadArchiveInfo *ai, struct TagItem *tags);
LONG xadDiskFileUnArc(struct xadArchiveInfo *ai, Tag tag1, ...);

LONG xadGetHookAccessA(struct xadArchiveInfo *ai, struct TagItem *tags);
LONG xadGetHookAccess(struct xadArchiveInfo *ai, Tag tag1, ...);

LONG xadFreeHookAccessA(struct xadArchiveInfo *ai, struct TagItem *tags);
LONG xadFreeHookAccess(struct xadArchiveInfo *ai, Tag tag1, ...);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif	/* CLIB_XADMASTER_PROTOS_H */
