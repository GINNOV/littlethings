#include "diskimage_device.h"
#include "scsicmd.h"

static const uint8 inquiry_data[36] = { 0, 0x80, 0, 0x02, 0x20, 0, 0, 0,
	'A', '5', '0', '0', '.', 'o', 'r', 'g', /* vendor */
	'D', 'i', 's', 'k', 'I', 'm', 'a', 'g', 'e', '.', 'd', 'e', 'v', 'i', 'c', 'e', /* prod */
	'D', 'I', '5', '2' }; /* revision */

int32 scsicmd (struct IOStdReq *io, struct SCSICmd *scsi) {
	uint8 *cmd, *data;
	uint32 cmdlen, len;
	int32 err = OK;
	uint8 sense[8] = { 0x72, SENSEKEY_NoSense, 0, 0, 0, 0, 0, 0 };
	#ifdef DEBUG
	int i;
	#endif

	if (io->io_Length < sizeof(struct SCSICmd)) return IOERR_BADLENGTH;
	io->io_Actual = sizeof(struct SCSICmd);

	#ifdef DEBUG
	dbug(("scsi_Data: 0x%08lx\n", scsi->scsi_Data));
	dbug(("scsi_Length: %ld\n", scsi->scsi_Length));
	dbug(("scsi_Command:"));
	for (i = 0; i < scsi->scsi_CmdLength; i++) {
		dbug((" %02lx", scsi->scsi_Command[i]));
	}
	dbug(("\nscsi_CmdLength: %ld\n", scsi->scsi_CmdLength));
	dbug(("scsi_Flags: 0x%02lx\n", scsi->scsi_Flags));
	dbug(("scsi_Status: 0x%02lx\n", scsi->scsi_Status));
	dbug(("scsi_SenseData: 0x%08lx\n", scsi->scsi_SenseData));
	dbug(("scsi_SenseLength: %ld\n", scsi->scsi_SenseLength));
	#endif
	
	cmd = scsi->scsi_Command;
	cmdlen = scsi->scsi_CmdLength;
	data = (uint8 *)scsi->scsi_Data;
	len = scsi->scsi_Length;

	scsi->scsi_Status = SCSI_Good;
	scsi->scsi_CmdActual = 0;
	scsi->scsi_Actual = 0;
	scsi->scsi_SenseActual = 0;

	switch (cmd[0]) {

		case SCSICMD_TestUnitReady:
			if (cmdlen != 6 || cmd[1] || *(int32 *)&cmd[2]) {
				scsi->scsi_Status = SCSI_CheckCondition;
				sense[1] = SENSEKEY_IllegalRequest;
				sense[2] = 0x24; /* Invalid Field In CDB */
			}
			break;

		case SCSICMD_Inquiry:
			if (cmdlen != 6 || (cmd[1] & 0xfe) || cmd[5]) {
				scsi->scsi_Status = SCSI_CheckCondition;
				sense[1] = SENSEKEY_IllegalRequest;
				sense[2] = 0x24; /* Invalid Field In CDB */
			}
			if (cmd[1] & 1) {
				uint8 buf[4] = {0};
				uint32 len2 = *(uint16 *)&cmd[3];
				buf[1] = cmd[2];
				scsi->scsi_Actual = min(min(len, len2), 4);
				memcpy(data, buf, scsi->scsi_Actual);
			} else {
				uint32 len2 = *(uint16 *)&cmd[3];
				if (cmd[2]) {
					scsi->scsi_Status = SCSI_CheckCondition;
					sense[1] = SENSEKEY_IllegalRequest;
					sense[2] = 0x24; /* Invalid Field In CDB */
					break;
				}
				scsi->scsi_CmdActual = 6;
				scsi->scsi_Actual = min(min(len, len2), 36);
				memcpy(data, inquiry_data, scsi->scsi_Actual);
			}
			break;

		case SCSICMD_ReadCapacity:
			if (cmdlen != 10 || cmd[1] || *(int32 *)&cmd[6]) {
				scsi->scsi_Status = SCSI_CheckCondition;
				sense[1] = SENSEKEY_IllegalRequest;
				sense[2] = 0x24; /* Invalid Field In CDB */
			/* }
			if (cmd[8] & 1) {
				scsi->scsi_Status = SCSI_CheckCondition;
				sense[1] = SENSEKEY_IllegalRequest;
				sense[2] = 0x24; *//* Invalid Field In CDB */
			} else {
				struct DriveGeometry dg;
				uint32 buf[2] = {0};
				if (*(uint32 *)&cmd[2] != 0) {
					scsi->scsi_Status = SCSI_CheckCondition;
					sense[1] = SENSEKEY_IllegalRequest;
					sense[2] = 0x24; /* Invalid Field In CDB */
					break;
				}
				if (!getgeometry((struct DiskImageUnit *)io->io_Unit, &dg)) {
					buf[0] = dg.dg_TotalSectors-1;
					buf[1] = dg.dg_SectorSize;
				}
				scsi->scsi_CmdActual = 10;
				scsi->scsi_Actual = min(len, 8);
				memcpy(data, buf, scsi->scsi_Actual);
			}
			break;
			
		default:
			scsi->scsi_Status = SCSI_CheckCondition;
			sense[1] = SENSEKEY_IllegalRequest;
			sense[2] = 0x20; /* Invalid Command Operation Code */
			break;

	}

	if (scsi->scsi_Flags & SCSIF_AUTOSENSE) {
		scsi->scsi_SenseActual = min(scsi->scsi_SenseLength, 8);
		memcpy(scsi->scsi_SenseData, sense, scsi->scsi_SenseActual);
	}
	if (err == OK && scsi->scsi_Status > SCSI_CheckCondition) {
		err = HFERR_BadStatus;
	}

	return err;
}
