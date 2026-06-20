/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AFileHandle wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_FileHandle_H
#define ASAP_FileHandle_H

#include <New.h>

extern "C"
{
 #include <Proto/DOS.h>
}

class AFileLock;

class AFileHandle : FileHandle
{
 public:
 inline LONG Close();
 inline void operator delete (void *);
 inline AFileLock * DupLockFromFH();
 inline BOOL ExamineFH(FileInfoBlock * fib);
 inline LONG FGetC();
 inline STRPTR FGets(STRPTR buf, unsigned long buflen);
 inline LONG FPrintf(STRPTR format, LONG arg1 = 0, ...);
 inline LONG FPutC(long ch);
 inline LONG FPuts(STRPTR str);
 inline LONG FRead(APTR block, unsigned long blocklen, unsigned long number);
 inline LONG FWrite(APTR block, unsigned long blocklen, unsigned long number);
 inline void FWritef(STRPTR format, LONG = 0, ...);
 inline LONG Flush();
 inline BPTR InternalLoadSeg(BPTR table, LONG * funcarray, LONG * stack);
 inline LONG IsInteractive();
 inline BOOL LockRecord(unsigned long offset, unsigned long length, unsigned long mode, unsigned long timeout);
 inline LONG NameFromFH(STRPTR buffer, long len);
 inline static AFileHandle * Open(STRPTR name, long accessMode);
 inline void * operator new(size_t, STRPTR name, long accessMode);
 inline AFileLock * ParentOfFH();
 inline LONG Read(APTR buffer, long length);
 inline LONG Seek(long position, long offset);
 inline AFileHandle * SelectInput();
 inline AFileHandle * SelectOutput();
 inline LONG SetFileSize(long pos, long mode);
 inline LONG SetMode(long mode);
 inline LONG SetVBuf(STRPTR buff, long type, long size);
 inline LONG UnGetC(long character);
 inline BOOL UnLockRecord(unsigned long offset, unsigned long length);
 inline LONG VFPrintf(STRPTR format, APTR argarray);
 inline void VFWritef(STRPTR format, LONG * argarray);
 inline LONG WaitForChar(long timeout);
 inline LONG Write(APTR buffer, long length);
};
//----------------------------------------------------------------------------
LONG AFileHandle::Close ()
{
 return ::Close((BPTR) this);
}
//----------------------------------------------------------------------------
void AFileHandle::operator delete (void *file)
{
 ((AFileHandle *) file)->Close();
}
//----------------------------------------------------------------------------
AFileLock * AFileHandle::DupLockFromFH ()
{
 return (AFileLock *) ::DupLockFromFH((BPTR) this);
}
//----------------------------------------------------------------------------
BOOL AFileHandle::ExamineFH (FileInfoBlock * fib)
{
 return ::ExamineFH((BPTR) this, fib);
}
//----------------------------------------------------------------------------
LONG AFileHandle::FGetC ()
{
 return ::FGetC((BPTR) this);
}
//----------------------------------------------------------------------------
STRPTR AFileHandle::FGets (STRPTR buf, unsigned long buflen)
{
 return ::FGets((BPTR) this, buf, buflen);
}
//----------------------------------------------------------------------------
LONG AFileHandle::FPrintf (STRPTR format, LONG arg1, ...)
{
 return AFileHandle::VFPrintf(format, &arg1);
}
//----------------------------------------------------------------------------
LONG AFileHandle::FPutC (long ch)
{
 return ::FPutC((BPTR) this, ch);
}
//----------------------------------------------------------------------------
LONG AFileHandle::FPuts (STRPTR str)
{
 return ::FPuts((BPTR) this, str);
}
//----------------------------------------------------------------------------
LONG AFileHandle::FRead (APTR block, unsigned long blocklen, unsigned long number)
{
 return ::FRead((BPTR) this, block, blocklen, number);
}
//----------------------------------------------------------------------------
LONG AFileHandle::FWrite (APTR block, unsigned long blocklen, unsigned long number)
{
 return ::FWrite((BPTR) this, block, blocklen, number);
}
//----------------------------------------------------------------------------
void AFileHandle::FWritef (STRPTR format, LONG arg1, ...)
{
 AFileHandle::VFWritef(format, &arg1);
}
//----------------------------------------------------------------------------
LONG AFileHandle::Flush ()
{
 return ::Flush((BPTR) this);
}
//----------------------------------------------------------------------------
BPTR AFileHandle::InternalLoadSeg (BPTR table, LONG * funcarray, LONG * stack)
{
 return ::InternalLoadSeg((BPTR) this, table, funcarray, stack);
}
//----------------------------------------------------------------------------
LONG AFileHandle::IsInteractive ()
{
 return ::IsInteractive((BPTR) this);
}
//----------------------------------------------------------------------------
BOOL AFileHandle::LockRecord (unsigned long offset, unsigned long length, unsigned long mode, unsigned long timeout)
{
 return ::LockRecord((BPTR) this, offset, length, mode, timeout);
}
//----------------------------------------------------------------------------
LONG AFileHandle::NameFromFH (STRPTR buffer, long len)
{
 return ::NameFromFH((BPTR) this, buffer, len);
}
//----------------------------------------------------------------------------
AFileHandle * AFileHandle::Open (STRPTR name, long accessMode)
{
 return (AFileHandle *) ::Open(name, accessMode);
}
//----------------------------------------------------------------------------
void * AFileHandle::operator new (size_t, STRPTR name, long accessMode)
{
 return AFileHandle::Open(name, accessMode);
}
//----------------------------------------------------------------------------
AFileLock * AFileHandle::ParentOfFH ()
{
 return (AFileLock *) ::ParentOfFH((BPTR) this);
}
//----------------------------------------------------------------------------
LONG AFileHandle::Read (APTR buffer, long length)
{
 return ::Read((BPTR) this, buffer, length);
}
//----------------------------------------------------------------------------
LONG AFileHandle::Seek (long position, long offset)
{
 return ::Seek((BPTR) this, position, offset);
}
//----------------------------------------------------------------------------
AFileHandle * AFileHandle::SelectInput ()
{
 return (AFileHandle *) ::SelectInput((BPTR) this);
}
//----------------------------------------------------------------------------
AFileHandle * AFileHandle::SelectOutput ()
{
 return (AFileHandle *) ::SelectOutput((BPTR) this);
}
//----------------------------------------------------------------------------
LONG AFileHandle::SetFileSize (long pos, long mode)
{
 return ::SetFileSize((BPTR) this, pos, mode);
}
//----------------------------------------------------------------------------
LONG AFileHandle::SetMode (long mode)
{
 return ::SetMode((BPTR) this, mode);
}
//----------------------------------------------------------------------------
LONG AFileHandle::SetVBuf (STRPTR buff, long type, long size)
{
 return ::SetVBuf((BPTR) this, buff, type, size);
}
//----------------------------------------------------------------------------
LONG AFileHandle::UnGetC (long character)
{
 return ::UnGetC((BPTR) this, character);
}
//----------------------------------------------------------------------------
BOOL AFileHandle::UnLockRecord (unsigned long offset, unsigned long length)
{
 return ::UnLockRecord((BPTR) this, offset, length);
}
//----------------------------------------------------------------------------
LONG AFileHandle::VFPrintf (STRPTR format, APTR argarray)
{
 return ::VFPrintf((BPTR) this, format, argarray);
}
//----------------------------------------------------------------------------
void AFileHandle::VFWritef (STRPTR format, LONG * argarray)
{
 ::VFWritef((BPTR) this, format, argarray);
}
//----------------------------------------------------------------------------
LONG AFileHandle::WaitForChar (long timeout)
{
 return ::WaitForChar((BPTR) this, timeout);
}
//----------------------------------------------------------------------------
LONG AFileHandle::Write (APTR buffer, long length)
{
 return ::Write((BPTR) this, buffer, length);
}

#endif
