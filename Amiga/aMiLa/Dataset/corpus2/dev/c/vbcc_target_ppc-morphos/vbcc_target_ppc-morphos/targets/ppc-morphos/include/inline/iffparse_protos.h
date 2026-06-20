#ifndef _VBCCINLINE_IFFPARSE_H
#define _VBCCINLINE_IFFPARSE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct IFFHandle * __AllocIFF(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define AllocIFF() __AllocIFF(IFFParseBase)

LONG __OpenIFF(void *, struct IFFHandle * iff, LONG rwMode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define OpenIFF(iff, rwMode) __OpenIFF(IFFParseBase, (iff), (rwMode))

LONG __ParseIFF(void *, struct IFFHandle * iff, LONG control) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define ParseIFF(iff, control) __ParseIFF(IFFParseBase, (iff), (control))

VOID __CloseIFF(void *, struct IFFHandle * iff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define CloseIFF(iff) __CloseIFF(IFFParseBase, (iff))

VOID __FreeIFF(void *, struct IFFHandle * iff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define FreeIFF(iff) __FreeIFF(IFFParseBase, (iff))

LONG __ReadChunkBytes(void *, struct IFFHandle * iff, APTR buf, LONG numBytes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define ReadChunkBytes(iff, buf, numBytes) __ReadChunkBytes(IFFParseBase, (iff), (buf), (numBytes))

LONG __WriteChunkBytes(void *, struct IFFHandle * iff, CONST APTR buf, LONG numBytes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define WriteChunkBytes(iff, buf, numBytes) __WriteChunkBytes(IFFParseBase, (iff), (buf), (numBytes))

LONG __ReadChunkRecords(void *, struct IFFHandle * iff, APTR buf, LONG bytesPerRecord, LONG numRecords) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define ReadChunkRecords(iff, buf, bytesPerRecord, numRecords) __ReadChunkRecords(IFFParseBase, (iff), (buf), (bytesPerRecord), (numRecords))

LONG __WriteChunkRecords(void *, struct IFFHandle * iff, CONST APTR buf, LONG bytesPerRecord, LONG numRecords) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define WriteChunkRecords(iff, buf, bytesPerRecord, numRecords) __WriteChunkRecords(IFFParseBase, (iff), (buf), (bytesPerRecord), (numRecords))

LONG __PushChunk(void *, struct IFFHandle * iff, LONG type, LONG id, LONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define PushChunk(iff, type, id, size) __PushChunk(IFFParseBase, (iff), (type), (id), (size))

LONG __PopChunk(void *, struct IFFHandle * iff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define PopChunk(iff) __PopChunk(IFFParseBase, (iff))

LONG __EntryHandler(void *, struct IFFHandle * iff, LONG type, LONG id, LONG position, struct Hook * handler, APTR object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,40(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define EntryHandler(iff, type, id, position, handler, object) __EntryHandler(IFFParseBase, (iff), (type), (id), (position), (handler), (object))

LONG __ExitHandler(void *, struct IFFHandle * iff, LONG type, LONG id, LONG position, struct Hook * handler, APTR object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,40(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define ExitHandler(iff, type, id, position, handler, object) __ExitHandler(IFFParseBase, (iff), (type), (id), (position), (handler), (object))

LONG __PropChunk(void *, struct IFFHandle * iff, LONG type, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define PropChunk(iff, type, id) __PropChunk(IFFParseBase, (iff), (type), (id))

LONG __PropChunks(void *, struct IFFHandle * iff, CONST LONG * propArray, LONG numPairs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define PropChunks(iff, propArray, numPairs) __PropChunks(IFFParseBase, (iff), (propArray), (numPairs))

LONG __StopChunk(void *, struct IFFHandle * iff, LONG type, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define StopChunk(iff, type, id) __StopChunk(IFFParseBase, (iff), (type), (id))

LONG __StopChunks(void *, struct IFFHandle * iff, CONST LONG * propArray, LONG numPairs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define StopChunks(iff, propArray, numPairs) __StopChunks(IFFParseBase, (iff), (propArray), (numPairs))

LONG __CollectionChunk(void *, struct IFFHandle * iff, LONG type, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define CollectionChunk(iff, type, id) __CollectionChunk(IFFParseBase, (iff), (type), (id))

LONG __CollectionChunks(void *, struct IFFHandle * iff, CONST LONG * propArray, LONG numPairs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define CollectionChunks(iff, propArray, numPairs) __CollectionChunks(IFFParseBase, (iff), (propArray), (numPairs))

LONG __StopOnExit(void *, struct IFFHandle * iff, LONG type, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define StopOnExit(iff, type, id) __StopOnExit(IFFParseBase, (iff), (type), (id))

struct StoredProperty * __FindProp(void *, CONST struct IFFHandle * iff, LONG type, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define FindProp(iff, type, id) __FindProp(IFFParseBase, (iff), (type), (id))

struct CollectionItem * __FindCollection(void *, CONST struct IFFHandle * iff, LONG type, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define FindCollection(iff, type, id) __FindCollection(IFFParseBase, (iff), (type), (id))

struct ContextNode * __FindPropContext(void *, CONST struct IFFHandle * iff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define FindPropContext(iff) __FindPropContext(IFFParseBase, (iff))

struct ContextNode * __CurrentChunk(void *, CONST struct IFFHandle * iff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define CurrentChunk(iff) __CurrentChunk(IFFParseBase, (iff))

struct ContextNode * __ParentChunk(void *, CONST struct ContextNode * contextNode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define ParentChunk(contextNode) __ParentChunk(IFFParseBase, (contextNode))

struct LocalContextItem * __AllocLocalItem(void *, LONG type, LONG id, LONG ident, LONG dataSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define AllocLocalItem(type, id, ident, dataSize) __AllocLocalItem(IFFParseBase, (type), (id), (ident), (dataSize))

APTR __LocalItemData(void *, CONST struct LocalContextItem * localItem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define LocalItemData(localItem) __LocalItemData(IFFParseBase, (localItem))

VOID __SetLocalItemPurge(void *, struct LocalContextItem * localItem, CONST struct Hook * purgeHook) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define SetLocalItemPurge(localItem, purgeHook) __SetLocalItemPurge(IFFParseBase, (localItem), (purgeHook))

VOID __FreeLocalItem(void *, struct LocalContextItem * localItem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define FreeLocalItem(localItem) __FreeLocalItem(IFFParseBase, (localItem))

struct LocalContextItem * __FindLocalItem(void *, CONST struct IFFHandle * iff, LONG type, LONG id, LONG ident) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define FindLocalItem(iff, type, id, ident) __FindLocalItem(IFFParseBase, (iff), (type), (id), (ident))

LONG __StoreLocalItem(void *, struct IFFHandle * iff, struct LocalContextItem * localItem, LONG position) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define StoreLocalItem(iff, localItem, position) __StoreLocalItem(IFFParseBase, (iff), (localItem), (position))

VOID __StoreItemInContext(void *, struct IFFHandle * iff, struct LocalContextItem * localItem, struct ContextNode * contextNode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define StoreItemInContext(iff, localItem, contextNode) __StoreItemInContext(IFFParseBase, (iff), (localItem), (contextNode))

VOID __InitIFF(void *, struct IFFHandle * iff, LONG flags, CONST struct Hook * streamHook) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define InitIFF(iff, flags, streamHook) __InitIFF(IFFParseBase, (iff), (flags), (streamHook))

VOID __InitIFFasDOS(void *, struct IFFHandle * iff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define InitIFFasDOS(iff) __InitIFFasDOS(IFFParseBase, (iff))

VOID __InitIFFasClip(void *, struct IFFHandle * iff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define InitIFFasClip(iff) __InitIFFasClip(IFFParseBase, (iff))

struct ClipboardHandle * __OpenClipboard(void *, LONG unitNumber) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define OpenClipboard(unitNumber) __OpenClipboard(IFFParseBase, (unitNumber))

VOID __CloseClipboard(void *, struct ClipboardHandle * clipHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define CloseClipboard(clipHandle) __CloseClipboard(IFFParseBase, (clipHandle))

LONG __GoodID(void *, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define GoodID(id) __GoodID(IFFParseBase, (id))

LONG __GoodType(void *, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define GoodType(type) __GoodType(IFFParseBase, (type))

STRPTR __IDtoStr(void *, LONG id, STRPTR buf) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define IDtoStr(id, buf) __IDtoStr(IFFParseBase, (id), (buf))

LONG __SeekChunkBytes(void *, struct IFFHandle * iff, LONG numBytes, LONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define SeekChunkBytes(iff, numBytes, mode) __SeekChunkBytes(IFFParseBase, (iff), (numBytes), (mode))

LONG __SeekChunkRecords(void *, struct IFFHandle * iff, LONG bytesPerRecord, LONG numRecords, LONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define SeekChunkRecords(iff, bytesPerRecord, numRecords, mode) __SeekChunkRecords(IFFParseBase, (iff), (bytesPerRecord), (numRecords), (mode))

#endif /*  _VBCCINLINE_IFFPARSE_H  */
