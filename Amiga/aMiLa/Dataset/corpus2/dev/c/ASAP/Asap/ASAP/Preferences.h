/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * APreferences wrapper class                                                *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_APreferences_H
#define ASAP_APreferences_H

extern "C"
{
 #include <Proto/Intuition.h>
}

class APreferences : public Preferences
{
 public:
 inline APreferences * GetDefPrefs(long size);
 inline APreferences * GetPrefs(long size);
 inline APreferences * SetPrefs(long size, BOOL inform);
};
//----------------------------------------------------------------------------
APreferences * APreferences::GetDefPrefs (long size)
{
 return (APreferences *) ::GetDefPrefs(this, size);
}
//----------------------------------------------------------------------------
APreferences * APreferences::GetPrefs (long size)
{
 return (APreferences *) ::GetPrefs(this, size);
}
//----------------------------------------------------------------------------
APreferences * APreferences::SetPrefs (long size, BOOL inform = 1)
{
 return (APreferences *) ::SetPrefs(this, size, inform);
}

#endif
