#include "diskimage_device.h"

#include <libraries/iffparse.h>

static inline struct IOExtTD *GetIOMsg (struct ExecIFace *IExec,
	struct DiskImageUnit *unit)
{
	struct IOExtTD *iotd;
	IExec->ObtainSemaphoreShared(unit->diu_SigSem);
	iotd = (struct IOExtTD *)IExec->GetMsg(unit->diu_Port);
	IExec->ReleaseSemaphore(unit->diu_SigSem);
	return iotd;
}

static int32 read (struct DiskImageUnit *unit, struct IOExtTD *iotd);
static int32 write (struct DiskImageUnit *unit, struct IOExtTD *iotd);

void remdisk (struct DiskImageUnit *unit);
void diskchange (struct DiskImageUnit *unit);

int UnitProcEntry (char *argstr, int32 arglen, struct ExecBase *SysBase) {
	struct ExecIFace *IExec = (struct ExecIFace *)SysBase->MainInterface;
	struct DOSIFace *IDOS;
	struct UtilityIFace *IUtility;
	struct Process *proc;
	struct DiskImageUnit *unit;
	struct IOExtTD *iotd;
	struct DiskImageMsg *msg;
	struct TagItem *ti, *tstate;
	int32 err;

	dbug(("UnitProcEntry()\n"));

	proc = (struct Process *)IExec->FindTask(NULL);

	while (!(unit = (struct DiskImageUnit *)IExec->GetMsg(&proc->pr_MsgPort)))
		IExec->WaitPort(&proc->pr_MsgPort);

	unit->diu_Port->mp_SigBit = unit->diu_ChangePort->mp_SigBit =
		IExec->AllocSignal(-1);
	unit->diu_Port->mp_Flags = unit->diu_ChangePort->mp_Flags = PA_SIGNAL;

	unit->diu_Name = NULL;
	unit->diu_File = unit->diu_ChangeCnt = 0;
	unit->diu_WriteProtect = FALSE;

	IDOS = unit->diu_LibBase->dib_IDOS;
	IUtility = unit->diu_LibBase->dib_IUtility;

	dbug(("replying to start msg\n"));
	IExec->ReplyMsg(&unit->diu_Msg);

	dbug(("entering main loop\n"));
	for (;;) {
		while (msg = (struct DiskImageMsg *)IExec->GetMsg(unit->diu_ChangePort)) {
			if (tstate = msg->dim_Tags) {
				uint32 t[2] = {0};
				int32 *error = (int32 *)&t[0];
				BPTR dir = 0;
				while (!(*error) && (ti = IUtility->NextTagItem(&tstate))) {
					switch (ti->ti_Tag) {
						case DITAG_Error:
							error = (int32 *)ti->ti_Data;
							*error = OK;
							break;

						case DITAG_CurrentDir:
							dir = ti->ti_Data;
							break;

						case DITAG_Filename:
							remdisk(unit);
							if ((char *)ti->ti_Data) {
								BPTR old;
								char *name;
								old = IDOS->CurrentDir(dir);

								name = IDOS->FilePart((char *)ti->ti_Data);
								unit->diu_Name = IExec->AllocVec(strlen(name)+1, MEMF_PRIVATE);
								unit->diu_File = IDOS->Open((char *)ti->ti_Data, MODE_OLDFILE);

								if (unit->diu_Name && unit->diu_File) {
									strcpy(unit->diu_Name, name);
									*error = OK;
								} else {
									*error = IDOS->IoErr();
								}
								if (*error) {
									remdisk(unit);
								}

								IDOS->CurrentDir(old);
							}
							diskchange(unit);
							break;

						case DITAG_WriteProtect:
							unit->diu_WriteProtect = ti->ti_Data ? TRUE : FALSE;
							break;

						case DITAG_GetImageName:
							if (!unit->diu_Name) {
								*(char **)ti->ti_Data = NULL;
								break;
							}
							*(char **)ti->ti_Data =
								IExec->AllocVec(strlen(unit->diu_Name)+1, MEMF_SHARED);
							if (*(char **)ti->ti_Data)
								strcpy(*(char **)ti->ti_Data, unit->diu_Name);
							else
								*error = ERROR_NO_FREE_STORE;
							break;

						case DITAG_GetWriteProtect:
							*(BOOL *)ti->ti_Data = unit->diu_WriteProtect;
							break;

						case DITAG_DiskImageType:
							*(uint32 *)ti->ti_Data = unit->diu_File
								? DITYPE_RAW
								: DITYPE_NONE;
							break;
					}
				}
			}
			IExec->ReplyMsg(&msg->dim_Message);
		}

		while (iotd = GetIOMsg(IExec, unit)) {
			if (&iotd->iotd_Req.io_Message == &unit->diu_Msg) {
				remdisk(unit);
				IExec->Forbid();
				IExec->ReplyMsg(&unit->diu_Msg);
				return 0;
			}

			switch (iotd->iotd_Req.io_Command) {
				case ETD_READ:
					if (iotd->iotd_Count < unit->diu_ChangeCnt) {
						err = TDERR_DiskChanged;
						break;
					}
				case CMD_READ:
					iotd->iotd_Req.io_Actual = 0;
					err = read(unit, iotd);
					break;

				case ETD_WRITE:
				case ETD_FORMAT:
					if (iotd->iotd_Count < unit->diu_ChangeCnt) {
						err = TDERR_DiskChanged;
						break;
					}
				case CMD_WRITE:
				case TD_FORMAT:
					iotd->iotd_Req.io_Actual = 0;
					err = write(unit, iotd);
					break;

				case NSCMD_ETD_READ64:
					if (iotd->iotd_Count < unit->diu_ChangeCnt) {
						err = TDERR_DiskChanged;
						break;
					}
				case NSCMD_TD_READ64:
				case TD_READ64:
					err = read(unit, iotd);
					break;

				case NSCMD_ETD_WRITE64:
				case NSCMD_ETD_FORMAT64:
					if (iotd->iotd_Count < unit->diu_ChangeCnt) {
						err = TDERR_DiskChanged;
						break;
					}
				case NSCMD_TD_WRITE64:
				case NSCMD_TD_FORMAT64:
				case TD_WRITE64:
				case TD_FORMAT64:
					err = write(unit, iotd);
					break;

				case TD_CHANGENUM:
					err = 0;
					iotd->iotd_Req.io_Actual = unit->diu_ChangeCnt;
					break;

				case TD_CHANGESTATE:
					err = 0;
					iotd->iotd_Req.io_Actual = unit->diu_File ? 0 : 1;
					break;

				case TD_PROTSTATUS:
					err = 0;
					iotd->iotd_Req.io_Actual = unit->diu_WriteProtect;
					break;

				case TD_GETGEOMETRY:
					if (iotd->iotd_Req.io_Length >= sizeof(struct DriveGeometry)) {
						err = getgeometry(unit, (struct DriveGeometry *)iotd->iotd_Req.io_Data);
						iotd->iotd_Req.io_Actual = sizeof(struct DriveGeometry);
					} else {
						err = IOERR_BADLENGTH;
						iotd->iotd_Req.io_Actual = 0;
					}
					break;

				case TD_EJECT:
					err = 0;
					remdisk(unit);
					diskchange(unit);
					break;

				case TD_ADDCHANGEINT:
					iotd->iotd_Req.io_Error = 0;
					IExec->AddTail(unit->diu_ChangeInts, (struct Node *)iotd->iotd_Req.io_Data);
					iotd = NULL;
					break;

				case TD_REMCHANGEINT:
					err = 0;
					IExec->Remove((struct Node *)iotd->iotd_Req.io_Data);
					break;

				case HD_SCSICMD:
					err = scsicmd(&iotd->iotd_Req, (struct SCSICmd *)iotd->iotd_Req.io_Data);
					break;

				default:
					err = IOERR_NOCMD;
					break;
			}

			if (iotd) {
				iotd->iotd_Req.io_Error = err;
				IExec->ReplyMsg(&iotd->iotd_Req.io_Message);
			}
		}

		IExec->Wait(1 << unit->diu_Port->mp_SigBit);
	}
}

int32 error (int32 error) {
	switch (error) {
		case ERROR_SEEK_ERROR:
			return TDERR_SeekError;

		case ERROR_DISK_WRITE_PROTECTED:
		case ERROR_WRITE_PROTECTED:
			return TDERR_WriteProt;

		case ERROR_NO_DISK:
			return TDERR_DiskChanged;

		default:
			return TDERR_NotSpecified;
	}
}

static int32 read (struct DiskImageUnit *unit, struct IOExtTD *iotd) {
	struct DOSIFace *IDOS = unit->diu_LibBase->dib_IDOS;
	int32 size, readsize;
	uint8 *buf;
	uint64 offset;

	if (!unit->diu_File) {
		iotd->iotd_Req.io_Actual = 0;
		return TDERR_DiskChanged;
	}

	offset = ((uint64)iotd->iotd_Req.io_Offset)|((uint64)iotd->iotd_Req.io_Actual << 32);

	if (!IDOS->ChangeFilePosition(unit->diu_File, offset, OFFSET_BEGINNING))
		return TDERR_SeekError;

	buf = iotd->iotd_Req.io_Data;
	size = iotd->iotd_Req.io_Length;
	iotd->iotd_Req.io_Actual = size;

	while (size) {
		readsize = IDOS->Read(unit->diu_File, buf, size);
		if (!readsize) {
			iotd->iotd_Req.io_Actual -= size;
			return IOERR_BADLENGTH;
		}
		if (readsize == -1) {
			iotd->iotd_Req.io_Actual -= size;
			return error(IDOS->IoErr());
		}
		buf += readsize;
		size -= readsize;
	}

	return OK;
}

static int32 write (struct DiskImageUnit *unit, struct IOExtTD *iotd) {
	struct DOSIFace *IDOS = unit->diu_LibBase->dib_IDOS;
	char *buf;
	int32 size, writesize;
	uint64 offset;
	
	if (!unit->diu_File)
		return TDERR_DiskChanged;

	if (unit->diu_WriteProtect)
		return TDERR_WriteProt;

	offset = ((uint64)iotd->iotd_Req.io_Offset)|((uint64)iotd->iotd_Req.io_Actual << 32);

	if (!IDOS->ChangeFilePosition(unit->diu_File, offset, OFFSET_BEGINNING))
		return TDERR_SeekError;

	buf = iotd->iotd_Req.io_Data;
	size = iotd->iotd_Req.io_Length;
	iotd->iotd_Req.io_Actual = size;

	while (size) {
		writesize = IDOS->Write(unit->diu_File, buf, size);
		if (writesize == -1) {
			iotd->iotd_Req.io_Actual -= size;
			return error(IDOS->IoErr());
		}
		buf += writesize;
		size -= writesize;
	}

	return OK;
}

int32 getgeometry (struct DiskImageUnit *unit, struct DriveGeometry *dg) {
	struct DiskImageBase *libBase = unit->diu_LibBase;
	struct DOSIFace *IDOS = libBase->dib_IDOS;
	int64 fsize;

	dg->dg_SectorSize = 512;
   	dg->dg_BufMemType = MEMF_SHARED;
   	dg->dg_DeviceType = DG_DIRECT_ACCESS;
   	dg->dg_Flags = DGF_REMOVABLE;
	dg->dg_Reserved = 0;

	if (!unit->diu_File)
		return TDERR_DiskChanged;

	fsize = IDOS->GetFileSize(unit->diu_File);
	if (fsize == -1)
		return error(IDOS->IoErr());

	dg->dg_Cylinders =
	dg->dg_TotalSectors = fsize >> 9;
	dg->dg_Heads = 1;
	dg->dg_TrackSectors = 1;
	dg->dg_CylSectors = 1;
	return OK;
}

void remdisk (struct DiskImageUnit *unit) {
	struct DiskImageBase *libBase = unit->diu_LibBase;
	struct ExecIFace *IExec = libBase->dib_IExec;
	struct DOSIFace *IDOS = libBase->dib_IDOS;

	IExec->FreeVec(unit->diu_Name);
	unit->diu_Name = NULL;

	IDOS->Close(unit->diu_File);
	unit->diu_File = 0;
}

void diskchange (struct DiskImageUnit *unit) {
	struct DiskImageBase *libBase = unit->diu_LibBase;
	struct ExecIFace *IExec = libBase->dib_IExec;
	struct Interrupt *handler;

	unit->diu_ChangeCnt++;

	handler = (struct Interrupt *)IExec->GetHead(unit->diu_ChangeInts);
	while (handler) {
		IExec->Cause(handler);
		handler = (struct Interrupt *)IExec->GetSucc(&handler->is_Node);
	}
}
