#include "diskimage_device.h"
#include <stdarg.h>

LONG _manager_Obtain(struct DeviceManagerInterface *Self);
ULONG _manager_Release(struct DeviceManagerInterface *Self);

int32 MountImage (struct DiskImageIFace *Self, uint32 unit_num, char *filename);
int32 Info (struct DiskImageIFace *Self, uint32 unit_num, char **filename, BOOL *writeprotect);
int32 WriteProtect (struct DiskImageIFace *Self, uint32 unit_num, BOOL writeprotect);
int32 UnitControlA (struct DiskImageIFace *Self, uint32 unit_num, struct TagItem *tags);
int32 VARARGS68K UnitControl (struct DiskImageIFace *Self, uint32 unit_num, ...);

CONST APTR lib_main_vectors[] = {
    (APTR)_manager_Obtain,
    (APTR)_manager_Release,
	NULL,
	NULL,
	(APTR)MountImage,
	(APTR)Info,
	(APTR)WriteProtect,
	(APTR)UnitControlA,
	(APTR)UnitControl,
	(APTR)-1
};

static struct MsgPort *GetUnitPort (struct DiskImageBase *libBase, uint32 unit_num) {
	struct ExecIFace *IExec = libBase->dib_IExec;
	struct DiskImageUnit *unit;
	unit = (struct DiskImageUnit *)IExec->GetHead(libBase->dib_Units);
	while (unit) {
		if (unit->diu_UnitNum == unit_num) {
			return unit->diu_ChangePort;
		}
		unit = (struct DiskImageUnit *)IExec->GetSucc(&unit->diu_Msg.mn_Node);
	}
	return NULL;
}

int32 MountImage (struct DiskImageIFace *Self, uint32 unit_num, char *filename) {
	struct DiskImageBase *libBase = (struct DiskImageBase *)Self->Data.LibBase;
	int32 err = OK;
	Self->UnitControl(unit_num,
		DITAG_Error,		&err,
		DITAG_CurrentDir,	libBase->dib_IDOS->GetCurrentDir(),
		DITAG_Filename,		filename,
		TAG_END);
	return err;
}

int32 Info (struct DiskImageIFace *Self, uint32 unit_num, char **filename, BOOL *writeprotect) {
	int32 err = OK, err2;
	err2 = Self->UnitControl(unit_num,
		DITAG_Error,			&err,
		DITAG_GetImageName,		filename,
		DITAG_GetWriteProtect,	writeprotect,
		TAG_END);
	return err ? err : err2;
}

int32 WriteProtect (struct DiskImageIFace *Self, uint32 unit_num, BOOL writeprotect) {
	int32 err = OK, err2;
	err2 = Self->UnitControl(unit_num,
		DITAG_Error,		&err,
		DITAG_WriteProtect,	writeprotect,
		TAG_END);
	return err ? err : err2;
}

int32 UnitControlA (struct DiskImageIFace *Self, uint32 unit_num, struct TagItem *tags) {
	struct DiskImageBase *libBase = (struct DiskImageBase *)Self->Data.LibBase;
	struct ExecIFace *IExec = libBase->dib_IExec;
	struct DiskImageMsg *msg;
	struct MsgPort *replyport, *port;
	int32 err = ERROR_BAD_NUMBER;

	IExec->ObtainSemaphore(libBase->dib_SigSem);

	replyport = libBase->dib_Port;
	replyport->mp_SigTask = IExec->FindTask(NULL);
	replyport->mp_SigBit = SIGB_CHILD;
	replyport->mp_Flags = PA_SIGNAL;

	port = GetUnitPort(libBase, unit_num);
	if (port) {
		msg = IExec->AllocSysObjectTags(ASOT_MESSAGE,
			ASOMSG_Size,		sizeof(struct DiskImageMsg),
			ASOMSG_ReplyPort,	replyport,
			TAG_END);
		if (msg) {
			msg->dim_Tags = tags;
			err = OK;

			IExec->PutMsg(port, &msg->dim_Message);
			IExec->WaitPort(replyport);
			IExec->GetMsg(replyport);
			IExec->SetSignal(0, SIGF_CHILD);

			IExec->FreeSysObject(ASOT_MESSAGE, msg);
		} else
			err = ERROR_NO_FREE_STORE;
	}

	IExec->ReleaseSemaphore(libBase->dib_SigSem);

	return err;
}

int32 VARARGS68K UnitControl (struct DiskImageIFace *Self, uint32 unit_num, ...) {
	int32 res;
	va_list tags;
	va_startlinear(tags, unit_num);
	res = Self->UnitControlA(unit_num, va_getlinearva(tags, struct TagItem *));
	va_end(tags);
	return res;
}
