/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ABootNode wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_BootNode_H
#define ASAP_BootNode_H

extern "C"
{
 #include <DOS/FileHandler.h>
 #include <Proto/Expansion.h>
}

class ABootNode : public DeviceNode
{
 public:
 inline BOOL AddBootNode(long bootPri, unsigned long flags, ConfigDev *configDev = 0);
};
//----------------------------------------------------------------------------
BOOL ABootNode::AddBootNode (long bootPri, unsigned long flags, ConfigDev *configDev)
{
 return ::AddBootNode(bootPri, flags, this, configDev);
}

#endif
