/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AFileLock wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_FileLock_H
#define ASAP_FileLock_H

#include <New.h>

extern "C"
{
 #include <Proto/DOS.h> 
}

class AFileHandle;

class AFileLock : FileLock
{
 public:
 inline AFileLock * CurrentDir();
 inline AFileLock * DupLock();
 inline void * operator new (size_t, AFileLock *);
 inline LONG ExAll(ExAllData * buffer, long size, long data, ExAllControl * control);
 inline void ExAllEnd(ExAllData * buffer, long size, long data, ExAllControl * control);
 inline LONG ExNext(FileInfoBlock * fileInfoBlock);
 inline LONG Examine(FileInfoBlock * fileInfoBlock);
 inline LONG Info(InfoData * parameterBlock);
 inline static AFileLock * Lock(STRPTR name, long type);
 inline void * operator new(size_t, STRPTR name, long type);
 inline LONG NameFromLock(STRPTR buffer, long len);
 inline AFileHandle * OpenFromLock();
 inline AFileLock * ParentDir();
 inline BOOL SameDevice(FileLock * lock2);
 inline LONG SameLock(FileLock * lock2);
 inline AFileLock * SetProgramDir();
 inline void UnLock();
 inline void operator delete(void *lock);
};
//----------------------------------------------------------------------------
AFileLock * AFileLock::CurrentDir ()
{
 return (AFileLock *) ::CurrentDir((BPTR) this);
}
//----------------------------------------------------------------------------
AFileLock * AFileLock::DupLock ()
{
 return (AFileLock *) ::DupLock((BPTR) this);
}
//----------------------------------------------------------------------------
void * AFileLock::operator new (size_t, AFileLock *lock)
{
 return ((AFileLock *) lock)->DupLock(); // ::DupLock((BPTR) lock);
}
//----------------------------------------------------------------------------
LONG AFileLock::ExAll (ExAllData * buffer, long size, long data, ExAllControl * control)
{
 return ::ExAll((BPTR) this, buffer, size, data, control);
}
//----------------------------------------------------------------------------
void AFileLock::ExAllEnd (ExAllData * buffer, long size, long data, ExAllControl * control)
{
 ::ExAllEnd((BPTR) this, buffer, size, data, control);
}
//----------------------------------------------------------------------------
LONG AFileLock::ExNext (FileInfoBlock * fileInfoBlock)
{
 return ::ExNext((BPTR) this, fileInfoBlock);
}
//----------------------------------------------------------------------------
LONG AFileLock::Examine (FileInfoBlock * fileInfoBlock)
{
 return ::Examine((BPTR) this, fileInfoBlock);
}
//----------------------------------------------------------------------------
LONG AFileLock::Info (InfoData * parameterBlock)
{
 return ::Info((BPTR) this, parameterBlock);
}
//----------------------------------------------------------------------------
AFileLock * AFileLock::Lock (STRPTR name, long type)
{
 return (AFileLock *) ::Lock(name, type);
}
//----------------------------------------------------------------------------
void * AFileLock::operator new (size_t, STRPTR name, long type)
{
 return AFileLock::Lock(name, type);
}
//----------------------------------------------------------------------------
LONG AFileLock::NameFromLock (STRPTR buffer, long len)
{
 return ::NameFromLock((BPTR) this, buffer, len);
}
//----------------------------------------------------------------------------
AFileHandle * AFileLock::OpenFromLock ()
{
 return (AFileHandle *) ::OpenFromLock((BPTR) this);
}
//----------------------------------------------------------------------------
AFileLock * AFileLock::ParentDir ()
{
 return (AFileLock *) ::ParentDir((BPTR) this);
}
//----------------------------------------------------------------------------
BOOL AFileLock::SameDevice (FileLock * lock2)
{
 return ::SameDevice((BPTR) this, (BPTR) lock2);
}
//----------------------------------------------------------------------------
LONG AFileLock::SameLock (FileLock * lock2)
{
 return ::SameLock((BPTR) this, (BPTR) lock2);
}
//----------------------------------------------------------------------------
AFileLock * AFileLock::SetProgramDir ()
{
 return (AFileLock *) ::SetProgramDir((BPTR) this);
}
//----------------------------------------------------------------------------
void AFileLock::UnLock ()
{
 ::UnLock((BPTR) this);
}
//----------------------------------------------------------------------------
void AFileLock::operator delete (void *lock)
{
 ((AFileLock *) lock)->UnLock();
}

#endif
