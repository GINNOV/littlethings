/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AIFFHandle wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_IFFHandle_H
#define ASAP_IFFHandle_H

#include <New.h>

extern "C"
{
 #include <Proto/IFFParse.h>
}

class AIFFHandle : public IFFHandle
{
 public:
 inline static AIFFHandle * AllocIFF();
 inline void * operator new(size_t);
 inline void CloseIFF();
 inline LONG CollectionChunk(long type, long id);
 inline LONG CollectionChunks(LONG * propArray, long numPairs);
 inline ContextNode * CurrentChunk();
 inline LONG EntryHandler(long type, long id, long position, struct Hook * handler, APTR object);
 inline LONG ExitHandler(long type, long id, long position, struct Hook * handler, APTR object);
 inline CollectionItem * FindCollection(long type, long id);
 inline LocalContextItem * FindLocalItem(long type, long id, long ident);
 inline StoredProperty * FindProp(long type, long id);
 inline ContextNode * FindPropContext();
 inline void FreeIFF();
 inline void operator delete (void *);
 inline void InitIFF(long flags, struct Hook * streamHook);
 inline void InitIFFasClip();
 inline void InitIFFasDOS();
 inline LONG OpenIFF(long rwMode);
 inline LONG ParseIFF(long control);
 inline LONG PopChunk();
 inline LONG PropChunk(long type, long id);
 inline LONG PropChunks(LONG * propArray, long numPairs);
 inline LONG PushChunk(long type, long id, long size);
 inline LONG ReadChunkBytes(APTR buf, long numBytes);
 inline LONG ReadChunkRecords(APTR buf, long bytesPerRecord, long numRecords);
 inline LONG StopChunk(long type, long id);
 inline LONG StopChunks(LONG * propArray, long numPairs);
 inline LONG StopOnExit(long type, long id);
 inline void StoreItemInContext(struct LocalContextItem * localItem, struct ContextNode * contextNode);
 inline LONG StoreLocalItem(struct LocalContextItem * localItem, long position);
 inline LONG WriteChunkBytes(APTR buf, long numBytes);
 inline LONG WriteChunkRecords(APTR buf, long bytesPerRecord, long numRecords);
};
//----------------------------------------------------------------------------
AIFFHandle * AIFFHandle::AllocIFF ()
{
 return (AIFFHandle *) ::AllocIFF();
}
//----------------------------------------------------------------------------
void * AIFFHandle::operator new (size_t)
{
 return AIFFHandle::AllocIFF();
}
//----------------------------------------------------------------------------
void AIFFHandle::CloseIFF ()
{
 ::CloseIFF(this);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::CollectionChunk (long type, long id)
{
 return ::CollectionChunk(this, type, id);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::CollectionChunks (LONG * propArray, long numPairs)
{
 return ::CollectionChunks(this, propArray, numPairs);
}
//----------------------------------------------------------------------------
ContextNode * AIFFHandle::CurrentChunk ()
{
 return ::CurrentChunk(this);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::EntryHandler (long type, long id, long position, struct Hook * handler, APTR object)
{
 return ::EntryHandler(this, type, id, position, handler, object);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::ExitHandler (long type, long id, long position, struct Hook * handler, APTR object)
{
 return ::ExitHandler(this, type, id, position, handler, object);
}
//----------------------------------------------------------------------------
CollectionItem * AIFFHandle::FindCollection (long type, long id)
{
 return ::FindCollection(this, type, id);
}
//----------------------------------------------------------------------------
LocalContextItem * AIFFHandle::FindLocalItem (long type, long id, long ident)
{
 return ::FindLocalItem(this, type, id, ident);
}
//----------------------------------------------------------------------------
StoredProperty * AIFFHandle::FindProp (long type, long id)
{
 return ::FindProp(this, type, id);
}
//----------------------------------------------------------------------------
ContextNode * AIFFHandle::FindPropContext ()
{
 return ::FindPropContext(this);
}
//----------------------------------------------------------------------------
void AIFFHandle::FreeIFF ()
{
 ::FreeIFF(this);
}
//----------------------------------------------------------------------------
void AIFFHandle::operator delete (void *iff)
{
 ((AIFFHandle *) iff)->FreeIFF();
}
//----------------------------------------------------------------------------
void AIFFHandle::InitIFF (long flags, struct Hook * streamHook)
{
 ::InitIFF(this, flags, streamHook);
}
//----------------------------------------------------------------------------
void AIFFHandle::InitIFFasClip ()
{
 ::InitIFFasClip(this);
}
//----------------------------------------------------------------------------
void AIFFHandle::InitIFFasDOS ()
{
 ::InitIFFasDOS(this);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::OpenIFF (long rwMode)
{
 return ::OpenIFF(this, rwMode);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::ParseIFF (long control)
{
 return ::ParseIFF(this, control);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::PopChunk ()
{
 return ::PopChunk(this);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::PropChunk (long type, long id)
{
 return ::PropChunk(this, type, id);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::PropChunks (LONG * propArray, long numPairs)
{
 return ::PropChunks(this, propArray, numPairs);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::PushChunk (long type, long id, long size)
{
 return ::PushChunk(this, type, id, size);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::ReadChunkBytes (APTR buf, long numBytes)
{
 return ::ReadChunkBytes(this, buf, numBytes);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::ReadChunkRecords (APTR buf, long bytesPerRecord, long numRecords)
{
 return ::ReadChunkRecords(this, buf, bytesPerRecord, numRecords);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::StopChunk (long type, long id)
{
 return ::StopChunk(this, type, id);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::StopChunks (LONG * propArray, long numPairs)
{
 return ::StopChunks(this, propArray, numPairs);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::StopOnExit (long type, long id)
{
 return ::StopOnExit(this, type, id);
}
//----------------------------------------------------------------------------
void AIFFHandle::StoreItemInContext (struct LocalContextItem * localItem, struct ContextNode * contextNode)
{
 ::StoreItemInContext(this, localItem, contextNode);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::StoreLocalItem (struct LocalContextItem * localItem, long position)
{
 return ::StoreLocalItem(this, localItem, position);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::WriteChunkBytes (APTR buf, long numBytes)
{
 return ::WriteChunkBytes(this, buf, numBytes);
}
//----------------------------------------------------------------------------
LONG AIFFHandle::WriteChunkRecords (APTR buf, long bytesPerRecord, long numRecords)
{
 return ::WriteChunkRecords(this, buf, bytesPerRecord, numRecords);
}

#endif
