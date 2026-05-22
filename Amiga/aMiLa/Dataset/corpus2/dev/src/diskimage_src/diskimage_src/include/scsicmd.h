#ifndef SCSICMD_H
#define SCSICMD_H

#ifndef DEVICES_SCSIDISK_H
#include <devices/scsidisk.h>
#endif

/* command codes */
#define SCSICMD_TestUnitReady				0x00
#define SCSICMD_Inquiry						0x12
#define SCSICMD_ReadCapacity				0x25

/* status codes */
#define SCSI_Good							0x00
#define SCSI_CheckCondition					0x02
#define SCSI_ConditionMet					0x04
#define SCSI_Busy							0x08
#define SCSI_Intermediate					0x10
#define SCSI_Intermediate_ConditionMet		0x14
#define SCSI_ReservationConflict			0x18
#define SCSI_CommandTerminated				0x22
#define SCSI_TaskSetFull					0x28
#define SCSI_ACAActive						0x30

/* sense key codes */
#define SENSEKEY_NoSense					0x0
#define SENSEKEY_RecoveredError				0x1
#define SENSEKEY_NotReady					0x2
#define SENSEKEY_MediumError				0x3
#define SENSEKEY_HardwareError				0x4
#define SENSEKEY_IllegalRequest				0x5
#define SENSEKEY_UnitAttention				0x6
#define SENSEKEY_DataProtect				0x7
#define SENSEKEY_BlankCheck					0x8
#define SENSEKEY_VendorSpecific				0x9
#define SENSEKEY_CopyAborted				0xA
#define SENSEKEY_AbortedCommand				0xB
#define SENSEKEY_VolumeOverflow				0xD
#define SENSEKEY_Miscompare					0xE

#endif
