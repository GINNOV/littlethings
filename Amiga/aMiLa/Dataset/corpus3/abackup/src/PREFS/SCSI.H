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
#ifndef ABPREFS_SCSI_H
#define ABPREFS_SCSI_H
/*	___________________

	ABackup Prefs
	scsi.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Jun-94
	Modified: 22-Apr-95
	___________________
*/

STATIC STRPTR	ID2Str	(WORD *,LONG,UBYTE);

STATIC WORD	DevType[] = {	MSG_DIRECT_ACCESS,
							MSG_SEQUENTIAL_ACCESS,
							MSG_PRINTER,
							MSG_PROCESSOR,
							MSG_WORM,
							MSG_CDROM,
							MSG_SCANNER,
							MSG_OPTICAL_DISK,
							MSG_MEDIUM_CHANGER,
							MSG_COMMUNICATION	},
			ANSIVer[] = {	MSG_NOT_ANSI,
							MSG_SCSI1,
							MSG_SCSI2	};

#define MAX_DEVTYPE		10
#define MAX_ANSIVER		3

#define INQUIRY_DATA	36
#define CMD_INQUIRY		0x12

#endif	// ABPREFS_SCSI_H
