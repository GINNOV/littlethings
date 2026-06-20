/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ACurrentBinding wrapper class                                             *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_CurrentBinding_H
#define ASAP_CurrentBinding_H

extern "C"
{
 #include <Libraries/ConfigVars.h>
 #include <Proto/Expansion.h>
}

class ACurrentBinding : public CurrentBinding
{
 public:
 inline ULONG GetCurrentBinding(unsigned long bindingSize);
 inline void SetCurrentBinding(unsigned long bindingSize);
};
//----------------------------------------------------------------------------
ULONG ACurrentBinding::GetCurrentBinding (unsigned long bindingSize)
{
 return ::GetCurrentBinding(this, bindingSize);
}
//----------------------------------------------------------------------------
void ACurrentBinding::SetCurrentBinding (unsigned long bindingSize)
{
 ::SetCurrentBinding(this, bindingSize);
}

#endif
