/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AMonitorSpec wrapper class                                                *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AMonitorSpec_H
#define ASAP_AMonitorSpec_H

#include <New.h>

extern "C"
{
 #include <Proto/Graphics.h>
}

class AMonitorSpec : public MonitorSpec
{
 public:
 inline BOOL CloseMonitor();
 inline void operator delete(void *);
 inline static AMonitorSpec * OpenMonitor(STRPTR monitorName, unsigned long displayID);
 inline void * operator new(size_t, STRPTR monitorName, unsigned long displayID);
};
//----------------------------------------------------------------------------
BOOL AMonitorSpec::CloseMonitor ()
{
 return ::CloseMonitor(this);
}
//----------------------------------------------------------------------------
void AMonitorSpec::operator delete (void *monitorspec)
{
 ((AMonitorSpec *) monitorspec)->CloseMonitor();
}
//----------------------------------------------------------------------------
AMonitorSpec * AMonitorSpec::OpenMonitor (STRPTR monitorName, unsigned long displayID)
{
 return (AMonitorSpec *) ::OpenMonitor(monitorName, displayID);
}
//----------------------------------------------------------------------------
void * AMonitorSpec::operator new (size_t, STRPTR monitorName, unsigned long displayID)
{
 return AMonitorSpec::OpenMonitor(monitorName, displayID);
}

#endif
