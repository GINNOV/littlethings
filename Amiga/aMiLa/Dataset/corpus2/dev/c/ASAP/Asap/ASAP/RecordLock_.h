/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ARecordLock wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ARecordLock_H
#define ASAP_ARecordLock_H

extern "C"
{
 #include <Proto/DOS.h>
}

class ARecordLock : public RecordLock
{
 public:
 inline BOOL LockRecords(unsigned long timeout);
 inline BOOL UnLockRecords();
};
//----------------------------------------------------------------------------
BOOL ARecordLock::LockRecords (unsigned long timeout)
{
 return ::LockRecords(this, timeout);
}
//----------------------------------------------------------------------------
BOOL ARecordLock::UnLockRecords ()
{
 return ::UnLockRecords(this);
}

#endif
