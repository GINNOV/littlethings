/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADeviceNode wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_DeviceNode_H
#define ASAP_DeviceNode_H

extern "C"
{
 #include <DOS/FileHandler.h>
 #include <Proto/Expansion.h>
}

class ADeviceNode : public DeviceNode
{
 public:
 inline BOOL AddDosNode(long bootPri, unsigned long flags);
 inline static ADeviceNode * MakeDosNode(APTR parmPacket);
};
//----------------------------------------------------------------------------
BOOL ADeviceNode::AddDosNode (long bootPri, unsigned long flags)
{
 return ::AddDosNode(bootPri, flags, this);
}
//----------------------------------------------------------------------------
ADeviceNode * ADeviceNode::MakeDosNode (APTR parmPacket)
{
 return (ADeviceNode *) ::MakeDosNode(parmPacket);
}

#endif
