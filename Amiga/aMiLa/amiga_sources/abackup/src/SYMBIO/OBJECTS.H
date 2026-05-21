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
    objects.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Aug-93
    Modified: 01-Jul-96
    _______________________________________________________________________
*/
#ifndef ABACKUP_OBJECTS_H
#define ABACKUP_OBJECTS_H

#ifndef MAXFONTNAME
#define MAXFONTNAME	128
#endif

//______________________________________________________________________________

/* object types for AllocObject() */

#define ABO_OBJECT	0		// pData = pointer to object name
#define ABO_PREFERENCE	1
#define ABO_DEVICEDEF	2		// pData = pointer to device name
#define ABO_ARCUNIT	3		// pData = pointer to file/unit name
#define ABO_HEADER	4
#define ABO_BADCYLMAP	5
#define ABO_DEVBUFFER	6		// pData = pointer to ArcUnit structure

//______________________________________________________________________________

#define MINSTR		32		// max length for file names
#define MAXNOTE 	80		// max length for file notes
#define BMAPSIZE	414		// size in bytes of bad cylinders bitmap
#define VERSIONOFS	446		// version offset in header *** DO NOT MODIFY ***
#define MAXDATA 	511		// available size in each sector (ALSO IN AsmSupport.a !!)
#define SIZEMASK	0x1ff		// mask to round up to full sector
#define IOBUFSIZE	(22*TD_SECTOR)  // I/O buffer size (when using TD_SECTOR blocks)
#define IOMAXDATA	(22*MAXDATA)    // I/O buffer size (when using MAXDATA blocks)
#define MAXBADCYL	(BMAPSIZE<<3)   // max number of cylinders in bad cylinders bitmap

#define MUFS_ID 	MAKE_ID( 'm' , 'u' , 'F' , 'S' )

#define MINTBUFSIZE	KBYTES( 12 )    // Minimal TrackBuffer = 12 kBytes

//______________________________________________________________________________

/* One directory/file/link/device - used for file selection */

struct Object
{
  struct MinNode obj_Node;		// for linkage
  struct Object *obj_Parent;		// points back to parent dir, NULL if root
  struct MinList obj_Children;		// header of children list (dirs only)
					// or link to device info (devices only)
					// or destination when restoring (links only)
  UWORD 	 obj_Flags;		// see #define below
  UWORD 	 obj_SelChildren;	// number of children selected
  LONG		 obj_Size;		// size for files, number of children for dirs
  LONG		 obj_Date;		// date of last modification
					// (number of seconds since 01-Jan-78 at 00:00:00)
  ULONG 	 obj_Bits;		// protection bits
  WORD		 obj_Disk;		// disk number in archive
  LONG		 obj_Offset;		// offset in archive
  UWORD 	 obj_UserData;		// for selection functions, and to store
					// recursion level when writing catalog
  BYTE		 obj_Name[1];		// object name starting at this location
};

/* values for obj_Flags field */
/* CAUTION ! THESE VALUES MUST BE THE SAME AS IN ABACKUP 4.01 OR LOWER ! DO NOT CHANGE THEM ! */

#define OBJF_DIRECTORY	0x0001		// is a directory
#define OBJF_RESERVED1	0x0002		// was OBJF_SORTED up to v4.09 ** DO NOT USE **
#define OBJF_SELECTED	0x0004		// is selected (files and empty dirs only)
#define OBJF_SAVED	0x0008		// is saved (backup)
#define OBJF_PATHOK	0x0010		// path for this object is created (restore)
#define OBJF_DEVICE	0x0020		// is a non-DOS device
#define OBJF_HLINK	0x0040		// is a hard link
#define OBJF_SLINK	0x0080		// is a soft link
#define OBJF_MULTIVOL	0x0100		// is the root of a multi-vol backup
#define OBJF_CATALOG	0x0200		// is archive catalog
#define OBJF_CLEAN	0x0400		// is clean (see CleanObj() function)
#define OBJF_DESTLINK	0x0800		// stores a link destination
#define OBJF_RESERVED2	0x1000		// was OBJF_HASCOMMENT up to v5.12 ** DO NOT USE **
#define OBJF_MULTIUSER	0x2000		// object on a muFS volume
#define OBJF_SPLITED	0x4000		// big file splited in several pieces
#define OBJF_HASCOMMENT 0x8000		// has a comment (was 0x1000 up to v5.12)

#define OBJF_LINK	(OBJF_HLINK|OBJF_SLINK)
#define OBJF_TYPE	(OBJF_DIRECTORY|OBJF_DEVICE|OBJF_LINK)
#define OBJF_IOMASK	(OBJF_SELECTED|OBJF_SAVED|OBJF_PATHOK|OBJF_CATALOG)

//______________________________________________________________________________

/* Contains all extra information needed to handle "image" backup */

struct DeviceDef
{
  struct Node	  dd_Node;	// for linkage
  struct DosEnvec dd_Env;	// private copy of DosEnvec structure
  LONG		  dd_Unit;	// unit number	    (from FileSysStartupMsg)
  LONG		  dd_Flags;	// for OpenDevice() (from FileSysStartupMsg)
  BYTE		  dd_Name[1];	// device to use    (from FileSysStartupMsg)
};

#define BMT_CHIP	2	// buffer must be in CHIP mem

//______________________________________________________________________________

/* To handle one unit (file/device/floppy...) */

struct ArcUnit
{
  struct Node	au_Node;		// ln_Type = AUT_FILE, AUT_DEVICE, etc...
  UWORD 	au_Flags;		// see #define below
  BYTE		au_Name[MAXSTR+1];
  BPTR		au_FDesc;		// if AUT_FILE, returned by Open()
  BPTR		au_FLock;		// if AUT_FILE, returned by Lock()
  LONG		au_CurPos;		// offset in file or on device

  // the following fields are used only for AUT_TAPE and AUT_DEVICE nodes
  LONG		au_CylSize;		// cylinder size (buffer size for tapes)
  LONG		au_BufSize;		// size of allocated buffer
  BYTE		*au_Buffer;		// data buffer
  BYTE		*au_VBuffer;		// verify buffer (allocated only if verify is on)
  struct List	*au_Parent;		// pointer to units list header
  struct MsgPort *au_MsgPort;
  struct IOExtTD *au_IOReq;
  LONG		au_LastErr;		// last error on this device
  LONG		au_Result;		// copy of io_Actual
  struct DeviceDef *au_DeviceDef;	// pointer to device definition

  // the following fields are used only for AUT_DEVICE nodes
  LONG		au_CurDisk;		// current disk number
  LONG		au_CurCyl;		// number of the cylinder currently in the buffer
  LONG		au_NumCyls;		// number of cylinders on device
  LONG		au_FirstCyl;		// cylinder where to store bad cylinders map
  LONG		au_NumSectors;		// number of sectors per cylinder
  struct BadCylMap *au_BadCyls; 	// header to store bad cylinders map

  // the following fields are used only for AUT_TAPE nodes
  LONG		au_BlockSize ;		// block size in bytes
  struct SCSICmd au_SCSICmd ;		// for SCSI access
  UBYTE 	au_Lun ;		// Logical Unit Number
  BYTE		au_Inquiry[64]; 	// buffer for SENSE/INQUIRY data
};

#define au_Type 	au_Node.ln_Type // dummy field name for easier access

/* Values for au_Type field */

#define AUT_FILE	1		// unit is a file
#define AUT_TAPE	2		// unit is a streamer
#define AUT_DEVICE	3		// unit is a device

/* Values for au_Flags field */

#define AUF_OPENED	0x0001		// OpenDevice() succeed
#define AUF_ACCESS	0x0002		// at least one access
#define AUF_PROTECTED	0x0004		// disk write protected
#define AUF_BUFFLUSH	0x0008		// flush buffer on close
#define AUF_READONLY	0x0010		// opened for read only
#define AUF_INHIBITED	0x0020		// ACTION_INHIBIT done
#define AUF_ASYNC	0x0040		// use child task to write
#define AUF_PENDING	0x0080		// child task is writing
#define AUF_DONTSKIP	0x0100		// do not skip bad cyls
#define AUF_TRACKDISK	0x0200		// device = trackdisk
#define AUF_CURRENT	0x0400		// is the current unit
#define AUF_NOTARCHIVE	0x0800		// is not an archive (for partitions backup/restore)
#define AUF_LOCKED	0x1000		// asynchronous writes locked
#define AUF_LOADBADCYL	0x2000		// must load bad cyls when preparing device
#define AUF_DACTAPE	0x4000		// direct access tape

//______________________________________________________________________________

/* Header of each object in archive */

#define PATHTABLE	64
#define H_PAD3_LEN	9

struct Header
{
  LONG		h_Idnt1;		// value "ABCK"         |
  LONG		h_Type; 		// header type		| THIS PART IS
  LONG		h_Idnt2;		// value "ABCK"         | NEVER CRYPTED
  LONG		h_CryptSum;		// password checksum	|

  LONG		h_BDate;		// backup date/time (= backup set identifier)
  LONG		h_CatalOfs;		// catalog offset
  struct Object h_Obj;			// object description
  BYTE		h_Pad1[MINSTR]; 	// to store object name
  struct DeviceDef h_DeviceDef; 	// device description (HT_NDOS only)
					// if HT_CATAL, overwritten by an ArcInfo structure
  BYTE		h_Pad2[MINSTR]; 	// to store device name
  BYTE		h_Comment[MAXNOTE+1];	// filenote
  BYTE		h_Parent[MINSTR+1];	// name of parent dir
  LONG		h_CType;		// compression type
  LONG		h_CSize;		// object size in archive (after possible compression)
					// if splited, this is the (compressed) block size
  LONG		h_BSize;		// block size (same as obj_Size if not splited)
  UWORD 	h_OwnerUID;		// for muFS support
  UWORD 	h_OwnerGID;		// for muFS support
  BYTE		h_PathTable[PATHTABLE]; // NEW FOR V5.10 : storage for parent tree
					// if HT_CATAL, contains the (partial) root dir
  BYTE		h_Pad3[H_PAD3_LEN];	// for h_Version field to be at offset 446
  LONG		h_Version;		// header version number
  LONG		h_PathLen;		// NEW FOR V5.10 : size used in h_PathTable
};

/* Special header to store bad cylinders map (h_Type is HT_BADCYL) */

struct BadCylMap
{
  LONG		bcm_Idnt1;		//
  LONG		bcm_Type;		//  THESE FIELDS ARE
  LONG		bcm_Idnt2;		//  EXACTLY THE SAME
  LONG		bcm_CryptSum;		//  AS THE FIRST FIELDS
  LONG		bcm_BDate;		//  OF THE HEADER STRUCTURE
  LONG		bcm_CatalOfs;		//

  LONG		bcm_DiskNum;		// disk number in archive
  LONG		bcm_NumBadCyls; 	// number of bad cylinders
  BYTE		bcm_BMap[BMAPSIZE];	// bitmap for bad cylinders
  LONG		bcm_Version;		// header version number
};

/* header mark (h_Idnt fields) */
#define H_IDNT		MAKE_ID( '#','0','0','0' )
#define H_IDNT_MSK	0xFFF0F0F0
#define H_IDNT_FMT	"#%03ld"

/* Header type (h_Type field) */
/* CAUTION ! THESE VALUES MUST BE THE SAME AS IN ABACKUP 4.01 OR LOWER ! DO NOT CHANGE THEM ! */

#define HT_END		0		// end of archive   (OBSOLETE)
#define HT_DIR		1		// directory
#define HT_FILE 	2		// file (beginning)
#define HT_FILEX	3		// file (continued) (OBSOLETE)
#define HT_OBSCATAL	4		// obsolete catalog (NOT SUPPORTED !)
#define HT_NDOS 	5		// non-dos (begin)
#define HT_NDOSX	6		// non-dos (cont.)  (OBSOLETE)
#define HT_HLINK	7		// hard link
#define HT_SLINK	8		// soft link
#define HT_OLDCATAL	9		// old catalog	    (OBSOLETE)
#define HT_BADCYL	10		// bad cylinder map
#define HT_CATAL	11		// new catalog
#define HT_SPLIT	12		// next piece of a splited file

#define HT_MINHT	HT_END		// min. value
#define HT_MAXHT	HT_SPLIT	// max. value
#define HT_CRYPT	0x80000000	// flag set if crypted

/* header/archive version (h_Version field) */

#define HVER_OLD	0		// before v4.00
#define HVER_V400	400		// v4.xx
//			500		// utilisé par les premières bétas v5.xx
#define HVER_V500	501		// v5.0x
#define HVER_V510	510		// v5.1x
#define HVER_CURRENT	HVER_V510	// current version

/* compression type (th_ctype field) */
/* CAUTION ! THESE VALUES MUST BE THE SAME AS IN ABACKUP 4.01 OR LOWER ! DO NOT CHANGE THEM ! */

#define HCT_NONE	0x01		// no compression
#define HCT_INTERNAL	0x02		// UNIX compress
#define HCT_EXTERNAL	0x03		// external prog.
#define HCT_XPKLIB	0x04		// XPK library
#define HCT_MASK	0x0f

//______________________________________________________________________________

/*
 * Informations about the current archive
 * It is stored in the header of the catalog file, overwriting the
 * h_DeviceDef fields
 */

struct ArcInfo
{
  LONG		ai_NumFiles;			// number of files
  LONG		ai_NumBytes;			// number of bytes
  LONG		ai_CType;			// compression type
  BYTE		ai_XpkMethod[XPKMETHODLEN+1];	// XPK method
} ;

#endif	// ABACKUP_OBJECTS_H
