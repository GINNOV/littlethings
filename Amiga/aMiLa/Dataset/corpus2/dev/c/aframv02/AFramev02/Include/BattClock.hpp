//////////////////////////////////////////////////////////////////////////////
// BattClock.hpp - AFrame v1.0 © 1996 Synthetic Input
//
//
// Deryk B Robosson
// Jeffry A Worth
// January 24, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __AFBATTCLOCK_HPP__
#define __AFBATTCLOCK_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/AFrame.hpp"
#include "aframe:include/Object.hpp"
#include <exec/types.h>
#include <exec/libraries.h>
#include <proto/battclock.h>
#include <resources/battclock.h>

//////////////////////////////////////////////////////////////////////////////
// AFBattClock Class

class AFBattClock : public AFObject
{
public:

    AFBattClock();
    ~AFBattClock();
    
    virtual char *ObjectType() { return "BattClock"; };

    ULONG m_time;

// Methods

    virtual void OnCreate();
    virtual void DestroyObject();

    virtual void AFResetBattClock(void);
    virtual ULONG AFReadBattClock(void);
    virtual void AFWriteBattClock(ULONG);

};

//////////////////////////////////////////////////////////////////////////////
#endif // __AFBATTCLOCK_HPP__
