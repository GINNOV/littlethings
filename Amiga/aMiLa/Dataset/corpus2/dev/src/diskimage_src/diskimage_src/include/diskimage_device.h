#ifndef DISKIMAGE_DEVICE_H
#define DISKIMAGE_DEVICE_H

#include <exec/exec.h>
#include <dos/dos.h>
#include <utility/tagitem.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>

#include <devices/trackdisk.h>
#include <devices/newstyle.h>
#include <devices/scsidisk.h>
#include <string.h>

#include "td64.h"

#define OK 0
#define min(a,b) (((a)<(b))?(a):(b))
#define max(a,b) (((a)>(b))?(a):(b))

#ifdef DEBUG
#define dbug(args) ((struct ExecIFace *)(*(struct ExecBase **)4)->MainInterface)->DebugPrintF args
#else
#define dbug(args)
#endif

struct DiskImageBase {
	struct Library dib_LibNode;
	BPTR dib_SegList;
	
	struct SignalSemaphore *dib_SigSem;
	struct MsgPort *dib_Port;
	struct List *dib_Units;

	struct ExecIFace *dib_IExec;
	struct DOSIFace *dib_IDOS;
	struct UtilityIFace *dib_IUtility;
	
	struct Library *dib_DOSBase;
	struct Library *dib_UtilityBase;
};

struct DiskImageUnit {
	struct Message diu_Msg;
	uint32 diu_UnitNum;
	uint32 diu_OpenCnt;

	struct SignalSemaphore *diu_SigSem;
	struct MsgPort *diu_Port;
	struct DiskImageBase *diu_LibBase;

	char *diu_Name;
	BPTR diu_File;

	uint32 diu_ChangeCnt;
	struct List *diu_ChangeInts;
	struct MsgPort *diu_ChangePort;

	BOOL diu_WriteProtect;
};

struct DiskImageMsg {
	struct Message dim_Message;
	struct TagItem *dim_Tags;
};

enum {
	DITAG_DUMMY = TAG_USER,
	DITAG_Error,
	DITAG_ErrorString,
	DITAG_CurrentDir,
	DITAG_Filename,
	DITAG_WriteProtect,
	DITAG_GetImageName,
	DITAG_GetWriteProtect,
	DITAG_DiskImageType,
	DITAG_Screen,
	DITAG_Password
};

enum {
	DITYPE_NONE,
	DITYPE_RAW,
	DITYPE_IPF,
	DITYPE_CPC
};

struct DiskImageIFace {
	struct InterfaceData Data;

	ULONG APICALL (*Obtain)(struct DiskImageIFace *Self);
	ULONG APICALL (*Release)(struct DiskImageIFace *Self);
	void APICALL (*Expunge)(struct DiskImageIFace *Self);
	struct Interface * APICALL (*Clone)(struct DiskImageIFace *Self);
	int32 APICALL (*MountImage)(struct DiskImageIFace *Self, uint32 unit_number, char *filename);
	int32 APICALL (*Info)(struct DiskImageIFace *Self, uint32 unit_number, char **filename,
		BOOL *writeprotect);
	int32 APICALL (*WriteProtect)(struct DiskImageIFace *Self, uint32 unit_number,
		BOOL writeprotect);
	int32 APICALL (*UnitControlA)(struct DiskImageIFace *Self, uint32 unit_num,
		struct TagItem *tags);
	int32 APICALL (*UnitControl)(struct DiskImageIFace *Self, uint32 unit_num, ...);
};

/* io.c */
LONG libAbortIO (struct DeviceManagerInterface *Self, struct IOStdReq *which_io);
void libBeginIO (struct DeviceManagerInterface *Self, struct IOExtTD *iotd);

/* unit.c */
int UnitProcEntry ();
int32 error (int32 error);
int32 getgeometry (struct DiskImageUnit *unit, struct DriveGeometry *dg);

/* scsicmd.c */
int32 scsicmd (struct IOStdReq *io, struct SCSICmd *scsi);

#endif
