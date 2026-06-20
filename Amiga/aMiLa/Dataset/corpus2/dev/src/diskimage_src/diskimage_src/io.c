#include "diskimage_device.h"

static const uint16 cmd_list[] = {
	NSCMD_DEVICEQUERY,
	CMD_UPDATE,
	CMD_CLEAR,
	TD_MOTOR,
	CMD_READ,
	CMD_WRITE,
	TD_FORMAT,
	ETD_READ,
	ETD_WRITE,
	ETD_FORMAT,
	TD_CHANGENUM,
	TD_CHANGESTATE,
	TD_PROTSTATUS,
	TD_GETGEOMETRY,
	TD_EJECT,
	TD_ADDCHANGEINT,
	TD_REMCHANGEINT,
	TD_READ64,
	TD_WRITE64,
	TD_FORMAT64,
	NSCMD_TD_READ64,
	NSCMD_TD_WRITE64,
	NSCMD_TD_FORMAT64,
	NSCMD_ETD_READ64,
	NSCMD_ETD_WRITE64,
	NSCMD_ETD_FORMAT64,
	HD_SCSICMD,
	0
};

LONG libAbortIO (struct DeviceManagerInterface *Self, struct IOStdReq *which_io) {
	struct DiskImageBase *libBase = (struct DiskImageBase *)Self->Data.LibBase;
	struct ExecIFace *IExec = libBase->dib_IExec;
	struct DiskImageUnit *unit;
	struct IOStdReq *io;
	LONG error = OK;

	unit = (struct DiskImageUnit *)which_io->io_Unit;
	IExec->ObtainSemaphore(unit->diu_SigSem);

	/* Check if the request is still in the queue, waiting to be
	   processed */

	io = (struct IOStdReq *)IExec->GetHead(&unit->diu_Port->mp_MsgList);
	while (io) {
		if (io == which_io) {
			/* remove it from the queue and tag it as aborted */
			IExec->Remove(&io->io_Message.mn_Node);

			io->io_Actual = 0;
			error = io->io_Error = IOERR_ABORTED;

			/* reply the message, as usual */
			IExec->ReplyMsg(&io->io_Message);
			break;
		}
		io = (struct IOStdReq *)IExec->GetSucc(&io->io_Message.mn_Node);
	}

	IExec->ReleaseSemaphore(unit->diu_SigSem);

	return error;
}

void libBeginIO (struct DeviceManagerInterface *Self, struct IOExtTD *iotd) {
	struct DiskImageBase *libBase = (struct DiskImageBase *)Self->Data.LibBase;
	struct ExecIFace *IExec = libBase->dib_IExec;
	struct DiskImageUnit *unit;

	unit = (struct DiskImageUnit *)iotd->iotd_Req.io_Unit;

	dbug(("BeginIO()\n"));
	dbug(("unit: %ld, command: %ld\n",
		unit->diu_UnitNum,
		iotd->iotd_Req.io_Command));

	switch (iotd->iotd_Req.io_Command) {
		case CMD_READ:
		case CMD_WRITE:
		case TD_FORMAT:
		case ETD_READ:
		case ETD_WRITE:
		case ETD_FORMAT:
		case TD_CHANGENUM:
		case TD_CHANGESTATE:
		case TD_PROTSTATUS:
		case TD_GETGEOMETRY:
		case TD_EJECT:
		case TD_ADDCHANGEINT:
		case TD_REMCHANGEINT:
		case TD_READ64:
		case TD_WRITE64:
		case TD_FORMAT64:
		case NSCMD_TD_READ64:
		case NSCMD_TD_WRITE64:
		case NSCMD_TD_FORMAT64:
		case NSCMD_ETD_READ64:
		case NSCMD_ETD_WRITE64:
		case NSCMD_ETD_FORMAT64:
		case HD_SCSICMD:
			/* forward to unit process */
			iotd->iotd_Req.io_Flags &= ~IOF_QUICK;
			IExec->ObtainSemaphoreShared(unit->diu_SigSem);
			IExec->PutMsg(unit->diu_Port, &iotd->iotd_Req.io_Message);
			IExec->ReleaseSemaphore(unit->diu_SigSem);
			return;

		case CMD_UPDATE:
		case CMD_CLEAR:
		case TD_MOTOR:
			/* handle as no-ops */
			iotd->iotd_Req.io_Error = OK;
			break;

		case NSCMD_DEVICEQUERY:
			if (iotd->iotd_Req.io_Length < sizeof(struct NSDeviceQueryResult)) {
				iotd->iotd_Req.io_Error = IOERR_BADLENGTH;
			} else {
				struct NSDeviceQueryResult *dq;
				dq = (struct NSDeviceQueryResult *)iotd->iotd_Req.io_Data;
				dq->DevQueryFormat = 0;
				iotd->iotd_Req.io_Actual = dq->SizeAvailable =
					sizeof(struct NSDeviceQueryResult);
				dq->DeviceType = NSDEVTYPE_TRACKDISK;
				dq->DeviceSubType = 0;
				dq->SupportedCommands = (uint16 *)cmd_list;
				iotd->iotd_Req.io_Error = OK;
			}
			break;

		default:
			/* not supported */
			iotd->iotd_Req.io_Error = IOERR_NOCMD;
			break;
	}

	iotd->iotd_Req.io_Message.mn_Node.ln_Type = NT_MESSAGE;

	if (!(iotd->iotd_Req.io_Flags & IOF_QUICK))
		IExec->ReplyMsg(&iotd->iotd_Req.io_Message);
}
