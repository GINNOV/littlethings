#ifndef _INLINE_IFFPARSE_H
#define _INLINE_IFFPARSE_H

#ifndef IFFPARSE_BASE_NAME
#define IFFPARSE_BASE_NAME IFFParseBase
#endif

#define AllocIFF() \
	((struct IFFHandle * (*)(struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 30))((struct Library *) IFFPARSE_BASE_NAME)

#define OpenIFF(iff, rwMode) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 36))(iff, rwMode, (struct Library *) IFFPARSE_BASE_NAME)

#define ParseIFF(iff, control) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 42))(iff, control, (struct Library *) IFFPARSE_BASE_NAME)

#define CloseIFF(iff) \
	((VOID (*)(struct IFFHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 48))(iff, (struct Library *) IFFPARSE_BASE_NAME)

#define FreeIFF(iff) \
	((VOID (*)(struct IFFHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 54))(iff, (struct Library *) IFFPARSE_BASE_NAME)

#define ReadChunkBytes(iff, buf, numBytes) \
	((LONG (*)(struct IFFHandle * __asm("a0"), APTR __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 60))(iff, buf, numBytes, (struct Library *) IFFPARSE_BASE_NAME)

#define WriteChunkBytes(iff, buf, numBytes) \
	((LONG (*)(struct IFFHandle * __asm("a0"), CONST APTR __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 66))(iff, buf, numBytes, (struct Library *) IFFPARSE_BASE_NAME)

#define ReadChunkRecords(iff, buf, bytesPerRecord, numRecords) \
	((LONG (*)(struct IFFHandle * __asm("a0"), APTR __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 72))(iff, buf, bytesPerRecord, numRecords, (struct Library *) IFFPARSE_BASE_NAME)

#define WriteChunkRecords(iff, buf, bytesPerRecord, numRecords) \
	((LONG (*)(struct IFFHandle * __asm("a0"), CONST APTR __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 78))(iff, buf, bytesPerRecord, numRecords, (struct Library *) IFFPARSE_BASE_NAME)

#define PushChunk(iff, type, id, size) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 84))(iff, type, id, size, (struct Library *) IFFPARSE_BASE_NAME)

#define PopChunk(iff) \
	((LONG (*)(struct IFFHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 90))(iff, (struct Library *) IFFPARSE_BASE_NAME)

#define EntryHandler(iff, type, id, position, handler, object) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), struct Hook * __asm("a1"), APTR __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 102))(iff, type, id, position, handler, object, (struct Library *) IFFPARSE_BASE_NAME)

#define ExitHandler(iff, type, id, position, handler, object) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), struct Hook * __asm("a1"), APTR __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 108))(iff, type, id, position, handler, object, (struct Library *) IFFPARSE_BASE_NAME)

#define PropChunk(iff, type, id) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 114))(iff, type, id, (struct Library *) IFFPARSE_BASE_NAME)

#define PropChunks(iff, propArray, numPairs) \
	((LONG (*)(struct IFFHandle * __asm("a0"), CONST LONG * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 120))(iff, propArray, numPairs, (struct Library *) IFFPARSE_BASE_NAME)

#define StopChunk(iff, type, id) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 126))(iff, type, id, (struct Library *) IFFPARSE_BASE_NAME)

#define StopChunks(iff, propArray, numPairs) \
	((LONG (*)(struct IFFHandle * __asm("a0"), CONST LONG * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 132))(iff, propArray, numPairs, (struct Library *) IFFPARSE_BASE_NAME)

#define CollectionChunk(iff, type, id) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 138))(iff, type, id, (struct Library *) IFFPARSE_BASE_NAME)

#define CollectionChunks(iff, propArray, numPairs) \
	((LONG (*)(struct IFFHandle * __asm("a0"), CONST LONG * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 144))(iff, propArray, numPairs, (struct Library *) IFFPARSE_BASE_NAME)

#define StopOnExit(iff, type, id) \
	((LONG (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 150))(iff, type, id, (struct Library *) IFFPARSE_BASE_NAME)

#define FindProp(iff, type, id) \
	((struct StoredProperty * (*)(CONST struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 156))(iff, type, id, (struct Library *) IFFPARSE_BASE_NAME)

#define FindCollection(iff, type, id) \
	((struct CollectionItem * (*)(CONST struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 162))(iff, type, id, (struct Library *) IFFPARSE_BASE_NAME)

#define FindPropContext(iff) \
	((struct ContextNode * (*)(CONST struct IFFHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 168))(iff, (struct Library *) IFFPARSE_BASE_NAME)

#define CurrentChunk(iff) \
	((struct ContextNode * (*)(CONST struct IFFHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 174))(iff, (struct Library *) IFFPARSE_BASE_NAME)

#define ParentChunk(contextNode) \
	((struct ContextNode * (*)(CONST struct ContextNode * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 180))(contextNode, (struct Library *) IFFPARSE_BASE_NAME)

#define AllocLocalItem(type, id, ident, dataSize) \
	((struct LocalContextItem * (*)(LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 186))(type, id, ident, dataSize, (struct Library *) IFFPARSE_BASE_NAME)

#define LocalItemData(localItem) \
	((APTR (*)(CONST struct LocalContextItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 192))(localItem, (struct Library *) IFFPARSE_BASE_NAME)

#define SetLocalItemPurge(localItem, purgeHook) \
	((VOID (*)(struct LocalContextItem * __asm("a0"), CONST struct Hook * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 198))(localItem, purgeHook, (struct Library *) IFFPARSE_BASE_NAME)

#define FreeLocalItem(localItem) \
	((VOID (*)(struct LocalContextItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 204))(localItem, (struct Library *) IFFPARSE_BASE_NAME)

#define FindLocalItem(iff, type, id, ident) \
	((struct LocalContextItem * (*)(CONST struct IFFHandle * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 210))(iff, type, id, ident, (struct Library *) IFFPARSE_BASE_NAME)

#define StoreLocalItem(iff, localItem, position) \
	((LONG (*)(struct IFFHandle * __asm("a0"), struct LocalContextItem * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 216))(iff, localItem, position, (struct Library *) IFFPARSE_BASE_NAME)

#define StoreItemInContext(iff, localItem, contextNode) \
	((VOID (*)(struct IFFHandle * __asm("a0"), struct LocalContextItem * __asm("a1"), struct ContextNode * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 222))(iff, localItem, contextNode, (struct Library *) IFFPARSE_BASE_NAME)

#define InitIFF(iff, flags, streamHook) \
	((VOID (*)(struct IFFHandle * __asm("a0"), LONG __asm("d0"), CONST struct Hook * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 228))(iff, flags, streamHook, (struct Library *) IFFPARSE_BASE_NAME)

#define InitIFFasDOS(iff) \
	((VOID (*)(struct IFFHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 234))(iff, (struct Library *) IFFPARSE_BASE_NAME)

#define InitIFFasClip(iff) \
	((VOID (*)(struct IFFHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 240))(iff, (struct Library *) IFFPARSE_BASE_NAME)

#define OpenClipboard(unitNumber) \
	((struct ClipboardHandle * (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 246))(unitNumber, (struct Library *) IFFPARSE_BASE_NAME)

#define CloseClipboard(clipHandle) \
	((VOID (*)(struct ClipboardHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 252))(clipHandle, (struct Library *) IFFPARSE_BASE_NAME)

#define GoodID(id) \
	((LONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 258))(id, (struct Library *) IFFPARSE_BASE_NAME)

#define GoodType(type) \
	((LONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 264))(type, (struct Library *) IFFPARSE_BASE_NAME)

#define IDtoStr(id, buf) \
	((STRPTR (*)(LONG __asm("d0"), STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) IFFPARSE_BASE_NAME) - 270))(id, buf, (struct Library *) IFFPARSE_BASE_NAME)

#endif /*  _INLINE_IFFPARSE_H  */
