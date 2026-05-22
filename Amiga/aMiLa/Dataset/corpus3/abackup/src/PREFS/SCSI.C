/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*	___________________

	ABackup Prefs
	scsi.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 06-Jul-94
	Modified: 30-Sep-95
	___________________
*/

#include "headers.h"
#include "scsi.h"

BOOL
SCSIInquiry (STRPTR name,LONG port,BOOL quiet)
{
	struct MsgPort	*mp;
	BOOL	rc = FALSE;

	// open I/O ressources for access:
	if (mp = CreatePort(NULL,0L)) {
		struct IOStdReq *io;

		if (io = CreateStdIO(mp)) {
			if (NOT OpenDevice(name,port,(struct IORequest *)io,0)) {
				struct SCSICmd	scsi;
				LONG	k;
				BYTE	buf[128],cmdbuf[64];

				io->io_Command	= HD_SCSICMD;
				io->io_Length	= sizeof(struct SCSICmd);
				io->io_Data		= (APTR)&scsi;

				scsi.scsi_Data		= (UWORD *)buf;
				scsi.scsi_Length	= INQUIRY_DATA;
				scsi.scsi_Actual	= 0;
				scsi.scsi_Command	= cmdbuf;
				scsi.scsi_CmdLength	= 6;
				scsi.scsi_Flags 	= SCSIF_READ;
				scsi.scsi_Status	= 0;

				memset(cmdbuf,'\0',64);
				cmdbuf[0] = (UBYTE)CMD_INQUIRY;
				cmdbuf[1] = (UBYTE)(((port/10-10*(port/100)) & 7) << 5);
				cmdbuf[4] = INQUIRY_DATA;

				// get device information:
				if (NOT DoIO((struct IORequest *)io))  {
					if (NOT quiet) {
						TEXT	text[512];

							 if (buf[7] & 0x40)     k = 32;
						else if (buf[7] & 0x20) k = 16;
						else					k =  8;

						SPrintf(text,
								"%s: %.8s\n%s: %.16s\n%s: %.4s\n%s: %s\n%s: %s\n%s: %lx\n%s: %lx\n%s: %s\n%s: %ld %s",
								GetStr(MSG_VENDOR_ID),                  &buf[8],
								GetStr(MSG_PRODUCT_ID),                 &buf[16],
								GetStr(MSG_PRODUCT_REVISION),   &buf[32],
								GetStr(MSG_DEVICE_TYPE),                ID2Str(DevType,buf[0] & 0x1F,MAX_DEVTYPE),
								GetStr(MSG_REMOVABLE_MEDIUM),   GetStr(buf[1] & 0x80? MSG_YES: MSG_NO),
								GetStr(MSG_ISO_VERSION),                (buf[2] & 0xC0) >> 6,
								GetStr(MSG_ECMA_VERSION),               (buf[2] & 0x38) >> 3,
								GetStr(MSG_ANSI_VERSION),               ID2Str(ANSIVer,buf[2] & 0x07,MAX_ANSIVER),
								GetStr(MSG_DATA_TRANSFERS),             k,
								GetStr(MSG_BYTES));

						// display device information:
						Notify(MSG_SCSI_INFOS,text,MSG_RESUME,NULL);
					}
					rc = TRUE;
				}
				CloseDevice((struct IORequest *)io);
			}
			DeleteStdIO(io);
		}
		DeletePort(mp);
	}
	return(rc);
}
//______________________________________________________________________________

STATIC STRPTR
ID2Str (WORD *msgIDs,LONG ID,UBYTE maxID)
{
	return(GetStr(ID < maxID? msgIDs[ID]: MSG_UNKNOWN));
}
//______________________________________________________________________________

VOID
CheckDiskDevice (UWORD gadID)
{
	TEXT	name[31];

	GDST_COPY(name);
	strcpy(PRF_DEVICEDRIVER,name);
}
//______________________________________________________________________________

VOID
CheckSCSIInquiry()
{
	BOOL	disable = NOT SCSIInquiry(PRF_DEVICEDRIVER,PRF_SCSIPORT,TRUE);

	SetGad(GD_SCSIInquiry,GA_Disabled,(ULONG)disable);
}

// Tab size: 4
