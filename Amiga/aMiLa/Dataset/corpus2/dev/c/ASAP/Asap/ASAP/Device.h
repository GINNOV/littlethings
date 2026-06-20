/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADevice wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_Device_H
#define ASAP_Device_H

extern "C"
{
 #include <EXEC/Devices.h>
 #include <Proto/EXEC.h>
}

class ADevice : public Device
{
 public:
 inline void AddDevice();
 inline void RemDevice();
};
//----------------------------------------------------------------------------
void ADevice::AddDevice ()
{
 ::AddDevice(this);
}
//----------------------------------------------------------------------------
void ADevice::RemDevice ()
{
 ::RemDevice(this);
}

#endif
