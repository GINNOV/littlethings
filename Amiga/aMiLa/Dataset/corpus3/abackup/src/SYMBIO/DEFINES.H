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
/*  _______________________________________________________________________

    ABackup 5.0
    defines.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 20-Nov-93
    Modified: 14-Jan-98
    _______________________________________________________________________
*/

#ifndef ABACKUP_DEFINES_H
#define ABACKUP_DEFINES_H

#define DEFPREFSNAME	"SYS:Prefs/"
#define DEFHELPNAME	"HELP:%s/"

#define ONEBYTE 	1L
#define ONEKILOBYTE	1024L
#define ONEMEGABYTE	1048576L

#define KBYTES(x)       (x * ONEKILOBYTE)

#ifndef MAXFONTNAME
#define MAXFONTNAME	128
#endif

#define FLT_BYNAME	0
#define FLT_BYDATE	1
#define FLT_BYBITS	2

// screen types saved in Scr->UserData:
#define ABMAINSCREEN	(UBYTE *)0x01
#define ABHOSTSCREEN	(UBYTE *)0x02

#define FILTER_INCLUDE	0
#define FILTER_EXCLUDE	1

//______________________________________________________________________________

#define SECS_PER_MIN	60
#define SECS_PER_HOUR	3600
#define SECS_PER_DAY	86400

#define RAW_HELP	0x5f
#define RAW_SHIFTED	(IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT)

//______________________________________________________________________________

#define KEEP_WINDOW	0
#define CHANGE_WINDOW	1
#define QUIT		2

// what we are doing:
#define PA_BACKUP	1	// backup of files/dirs/partitions
#define PA_RESTORE	2	// restore of files/dirs/partitions
#define PA_REBUILD	3	// rebuilding archive catalog
#define PA_VERIFY	4	// verifying archive

// values for ProgramFlags:
#define PF_BREAKED	0x0001	// asked to abort
#define PF_PAUSED	0x0002	// paused
#define PF_QUIT 	0x0004	// asked to quit
#define PF_UNCRYPT	0x0008	// reading encrypted archive
#define PF_CATALISTREE	0x0010	// use FreeDirTree() to free catalog
#define PF_AUDIO	0x0020	// audio.device ready
#define PF_WBSTART	0x0040	// fast start, from WB
#define PF_CATALFOUND	0x0080	// archive catalog found
#define PF_CHILDTASK	0x0100	// child task is running
#define PF_BATCH	0x0200	// CLI "batch" mode
#define PF_BADCYL	0x0400	// at least one bad cylinder during the backup

// flags for WalkDirTree():
#define WDTF_RECURSIVE	0x0001	// walk down in sub dirs
#define WDTF_DIRAFTER	0x0002	// process dirs after walking down
#define WDTF_DIRBEFORE	0x0004	// process dirs before walking down
#define WDTF_SELECTED	0x0008	// selected objects only
#define WDTF_EMPTYDIRS	0x0010	// process empty dirs only

// flags for SetCurUnit():
#define SCU_FIRST		1		// select first unit
#define SCU_NEXT		2		// select next unit

// flags for OpenArc() and OpenDev():
#define OAF_READ		0		// open for reading
#define OAF_WRITE		1		// open for writing
#define OAF_DUMMY		2		// open a dummy unit (no I/O will be done)
#define OAF_USECHILDTASK	0x0001		// use child task if OAF_WRITE

// flags for WriteCatalog():
#define WCF_TOFILE		0x01		// write catalog to a file
#define WCF_TOARC		0x02		// write catalog to archive

// flags for ReadCylDev():
#define RCDF_PUTCYLSIZE 	0x01		// put cylinder size at the beginning of the buffer
#define RCDF_QUIET		0x02		// silently fails (no error messages)
#define RCDF_REALCYL		0x04		// don't add LowCyl to the given cylinder number

// flags for PrepareDev():
#define PDF_DONTINHIBIT 	0x0001		// do not inhibit device

// defines for MonitorPrint():
#define MP_POS1 		0		// print on the left
#define MP_POS2 		1		// print on the right
#define MPF_LINEFEED		0x01		// goto next line after displaying text

// flags for FileRequest():
#define FRF_DIRSONLY		0x01		// select a directory, not a file

// flags for FlushArc():
#define FAF_DEVONLY		0x01		// flush AUT_DEVICE only

// flags for DiskRequest():
#define DR_LASTDISK		-1		// asks for the last disk
#define DR_NEXTDISK		-2		// asks for the next disk
#define DR_NEWDISK		-3		// asks for a new disk (for catalog)

// modes for RestoreDev():
#define RDM_RESTORE		1		// true restoration
#define RDM_VERIFY		2		// dummy restoration, for verifying

// flags for CopyFile():
#define CFF_ADDHEADER		0x01		// write pGHdr at the beginning of dest file

// return value of DecompressFile():
#define DFR_OK			0		// success
#define DFR_READERR		1		// read error
#define DFR_CMPERR		2		// comparison error

// defines for HandleError():
#define HERR_IOERR		-1		// use IoErr()
#define HERR_XPKERR		-2		// base for XPK error codes

#define ABERR_CANNOT_OPEN	500	// cannot open something
#define ABERR_DECOMP_ERROR	501	// error when trying to decompress a file
#define ABERR_READ_ERROR	502	// error when trying to read a file
#define ABERR_WRONG_PASSWORD	503	// wrong password for data uncryption
#define ABERR_VERIFY_ERROR	504	// error when comparing data
#define ABERR_BAD_PATTERN	505	// bad pattern for selection
#define ABERR_BAD_DATE		506	// bad date for selection
#define ABERR_BAD_BITS		507	// bad bits for selection
#define ABERR_SYNTAX_ERROR	508	// syntax error in selection file
#define ABERR_BACKUP_TO_ITSELF	509	// trying to backup device to itself
#define ABERR_NOT_A_TAPE	510	// unit is not a tape
#define ABERR_COPYCAT_FAILED	511	// couldn't duplicate catalog
#define ABERR_NOT_AN_ARCHIVE	512	// unit is not an ABackup archive
#define ABERR_BAD_FORMAT	513	// bad data format

// result of GetFileType()
// values lower than FTYPE_EMPTY correspond to crunched files

#define FTYPE_ERROR	-1
#define FTYPE_LHARCARC	 0
#define FTYPE_ZOOARC	 1
#define FTYPE_PPCRUNCH	 2
#define FTYPE_PPCRYPT	 3
#define FTYPE_ABACKUP	 4
#define FTYPE_XPKFILE	 5
#define FTYPE_EMPTY	 6
#define FTYPE_OBJAZTEC	 7
#define FTYPE_LIBAZTEC	 8
#define FTYPE_FONTHEAD	 9
#define FTYPE_WBICON	10
#define FTYPE_EXECPRG	11
#define FTYPE_OBJSASC	12
#define FTYPE_LIBSASC	13
#define FTYPE_IFFILBM	14
#define FTYPE_IFFTEXT	15
#define FTYPE_IFF8SVX	16
#define FTYPE_IFFANIM	17
#define FTYPE_IFFOTHER	18
#define FTYPE_BINARY	19
#define FTYPE_ASCII	20

// defines for pooled allocation:
#define POOL_MEMFLAGS	(MEMF_CLEAR|MEMF_PUBLIC)
#define POOL_PUDDLESIZE KBYTES(8)
#define POOL_TRESHSIZE	KBYTES(8)

#endif	// ABACKUP_DEFINES_H
