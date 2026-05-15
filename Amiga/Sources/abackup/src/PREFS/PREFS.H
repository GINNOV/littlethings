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
#ifndef PREFS_ABACKUP_H
#define PREFS_ABACKUP_H
/*      ___________________

	ABackup Prefs
	prefs.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Aug-93
	Modified: 18-Jan-98
	Tab size: 8
	___________________
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif


/*****************************************************************************/
/* Miscellaneous limits */

#define XPKMETHODLEN    5       	/* see XPLIST <libraries/xpk.h>     */
#define FILTERLEN       256     	/* Length of Filter string          */
#define MAXPEN  	4       	/* Number of screen Pens	    */
#define MAXEXT  	3       	/* Number of External programs      */
#define MAXCOM  	81      	/* Size of Backup Comment           */
#define MAXSTR  	256

/*****************************************************************************/

typedef struct ABackupPrefs
{
    /* General options */
    ULONG ab_Flags;
    UWORD ab_BufferSize;		/* Child task buffer    	    */
    UBYTE ab_TempDir[MAXSTR];   	/* Temporary directory path         */
    UBYTE ab_SelectionPath[MAXSTR];     /* Default selection path           */
    UBYTE ab_External[MAXEXT][MAXSTR];  /* External programs path & name    */

    /* Backup options */
    ULONG ab_BackupFlags;
    UBYTE ab_BackupTo[MAXSTR];  	/* Backup target		    */
    UBYTE ab_LogFile[MAXSTR];   	/* Loag file    		    */
    UBYTE ab_DefaultComment[MAXCOM];    /* Default comment      	    */
    UWORD ab_LabelsLength;      	/* Disk labels lenght (lines)       */

    /* Restore options */
    ULONG ab_RestoreFlags;
    UBYTE ab_RestoreFrom[MAXSTR];       /* Restore source       	    */
    UBYTE ab_RestoreTo[MAXSTR]; 	/* Restore target       	    */

    /* Verify options */
    ULONG ab_VerifyFlags;

    /* Compression options */
    UBYTE ab_XpkMethod[XPKMETHODLEN+1]; /* Xpk Method name      	    */
    UBYTE ab_XpkMode;   		/* Xpk Mode (0..100 scale)          */
    UBYTE ab_Compressor[MAXSTR];	/* External Compressor  	    */
    UBYTE ab_Decompressor[MAXSTR];      /* External Decompressor	    */
    UBYTE ab_Filter[FILTERLEN+1];       /* File Extensions to avoid         */

    /* Tape options */
    ULONG ab_TapeFlags;
    UBYTE ab_DeviceDriver[31];  	/* Device driver name   	    */
    UBYTE ab_SCSIPort;  		/* SCSI port    		    */
    UWORD ab_BlockSize; 		/* Block size   		    */

    /* GUI options */
    ULONG ab_DisplayID;
    UBYTE ab_PubName[MAXPUBSCREENNAME+1];
    UWORD ab_Colors[MAXPEN];
    UBYTE ab_ScreenFontName[MAXFONTNAME];
    UWORD ab_ScreenFontYSize;
    UBYTE ab_TextFontName[MAXFONTNAME];
    UWORD ab_TextFontYSize;
} ABPREFS;

/* flags for ABackupPrefs.ab_Flags */
#define PFL_BEEP	0x0001  	/* Alert: Beep sound    	    */
#define PFL_FLASH       0x0002  	/* Alert: Flash screen  	    */
#define PFL_BYTES       0x0004  	/* Files Size: in Bytes 	    */
#define PFL_KILOBYTES   0x0008  	/* Files Size: in Kilo-Bytes        */
#define PFL_MEGABYTES   0x0010  	/* Files Size: in Mega-Bytes        */
//      not used	0x0020
#define PFL_CUSTOM      0x0040  	/* Use Custom screen    	    */
#define PFL_PUBLIC      0x0080  	/* Use Public screen    	    */
#define PFL_EXTERNAL    0x0100  	/* Use External compressors         */
#define PFL_XPKLIB      0x0200  	/* Use Xpk library      	    */
#define PFL_VISASYNCHRO 0x0400  	/* Run Asynchronously   	    */
#define PFL_VISCONFIRM  0x0800  	/* Confirm Each Visualization       */

/* flags for ABackupPrefs.BackupFlags */
#define BFL_TOFILE      0x00001 	/* Backup to file       	    */
#define BFL_TOTAPE      0x00002 	/* Backup to tape       	    */
#define BFL_REPORT      0x00004 	/* Backup report		    */
#define BFL_REPTOFILE   0x00008 	/* Report to file       	    */
#define BFL_REPSHORT    0x00010 	/* Short report 		    */
#define BFL_VERIFY      0x00020 	/* Verify data  		    */
#define BFL_CHILDTASK   0x00040 	/* Use child task       	    */
#define BFL_LINKS       0x00080 	/* Backup links 		    */
#define BFL_COMPRESS    0x00100 	/* Compress files       	    */
#define BFL_CATCOMP     0x00200 	/* Compress catalog     	    */
#define BFL_ENCRYPT     0x00400 	/* Encrypt data 		    */
#define BFL_SETABIT     0x00800 	/* Set archive bit      	    */
#define BFL_ADDCOMMENT  0x01000 	/* Add comment to archive           */
#define BFL_ADDICON     0x02000 	/* Add icon to archive files        */
#define BFL_DUPCATALOG  0x04000 	/* Duplicate catalog    	    */
#define BFL_PRINTLABELS 0x08000 	/* Print disk labels    	    */
#define BFL_IGNSKIPME   0x10000 	/* Ignore SKIPME		    */

/* flags for ABackupPrefs.RestoreFlags */
#define RFL_FROMFILE    0x0001  	/* Restore from file    	    */
#define RFL_FROMTAPE    0x0002  	/* Restore from tape    	    */
#define RFL_REPORT      0x0004  	/* Restore report       	    */
#define RFL_REPTOFILE   0x0008  	/* Report to file       	    */
#define RFL_REPSHORT    0x0010  	/* Short report 		    */
#define RFL_DIRTREE     0x0020  	/* Restore dir tree     	    */
#define RFL_DATE	0x0040  	/* Restore file date    	    */
#define RFL_LINKS       0x0080  	/* Restore links		    */
#define RFL_EMPTYDIRS   0x0100  	/* Restore empty directories        */
#define RFL_USECATFILE  0x0200  	/* Use catalog file     	    */
#define RFL_REPLACE     0x0400  	/* Existing files: Always           */
#define RFL_ASKREPLACE  0x0800  	/* Existing files: Ask before       */
#define RFL_OLDREPLACE  0x1000  	/* Existing files: Oldest           */
#define RFL_RENAME      0x2000  	/* Existing files: Rename           */
#define RFL_DELBAD      0x4000  	/* Bad files: Always    	    */
#define RFL_ASKDELBAD   0x8000  	/* Bad files: Ask before	    */

/* flags for ABackupPrefs.VerifyFlags */
#define VFL_REPORT      0x0001  	/* Verify report		    */
#define VFL_REPTOFILE   0x0002  	/* Report to file       	    */
#define VFL_REPSHORT    0x0004  	/* Short report 		    */
#define VFL_COMPARE     0x0008  	/* Compare data 		    */
#define VFL_SELECTIVE   0x0010  	/* Selective verify     	    */
#define VFL_IGNOREDATE  0x0020  	/* Ignore files date    	    */

/* flags for ABackupPrefs.TapeFlags */
#define TFL_REWIND      0x0001  	/* Rewind       		    */
#define TFL_EJECT       0x0002  	/* Eject			    */
#define TFL_RETENTION   0x0004  	/* Auto retention       	    */
#define TFL_FASTBUFFER  0x0008  	/* Buffer in FAST memory	    */

/* constants for ABackupPrefs.ab_External */
#define EXT_ASCII       0       	/* ASCII files viewer   	    */
#define EXT_ILBM	1       	/* ILBM  files viewer   	    */
#define EXT_OTHERS      2       	/* Other files viewer   	    */

/*****************************************************************************/

/* chunks IDs */
#define ID_GENE 		MAKE_ID('G','E','N','E')
#define ID_BACK 		MAKE_ID('B','A','C','K')
#define ID_REST 		MAKE_ID('R','E','S','T')
#define ID_VERI 		MAKE_ID('V','E','R','I')
#define ID_COMP 		MAKE_ID('C','O','M','P')
#define ID_TAPE 		MAKE_ID('T','A','P','E')
#define ID_GUIP 		MAKE_ID('G','U','I','P')

/* offset of chunk data */
#define ABPREFS_GENE_START      offsetof(ABPREFS,ab_Flags)
#define ABPREFS_BACK_START      offsetof(ABPREFS,ab_BackupFlags)
#define ABPREFS_REST_START      offsetof(ABPREFS,ab_RestoreFlags)
#define ABPREFS_VERI_START      offsetof(ABPREFS,ab_VerifyFlags)
#define ABPREFS_COMP_START      offsetof(ABPREFS,ab_XpkMethod)
#define ABPREFS_TAPE_START      offsetof(ABPREFS,ab_TapeFlags)
#define ABPREFS_GUIP_START      offsetof(ABPREFS,ab_DisplayID)

/* length of chunk data */
#define ABPREFS_GENE_LENGTH     (ABPREFS_BACK_START - ABPREFS_GENE_START)
#define ABPREFS_BACK_LENGTH     (ABPREFS_REST_START - ABPREFS_BACK_START)
#define ABPREFS_REST_LENGTH     (ABPREFS_VERI_START - ABPREFS_REST_START)
#define ABPREFS_VERI_LENGTH     (ABPREFS_COMP_START - ABPREFS_VERI_START)
#define ABPREFS_COMP_LENGTH     (ABPREFS_TAPE_START - ABPREFS_COMP_START)
#define ABPREFS_TAPE_LENGTH     (ABPREFS_GUIP_START - ABPREFS_TAPE_START)
#define ABPREFS_GUIP_LENGTH     (sizeof(ABPREFS)    - ABPREFS_GUIP_START)

/*****************************************************************************/

/* Default settings */
#define DEF_FLAGS       	PFL_BEEP|PFL_VISCONFIRM
#define DEF_BUFSIZE     	128
#define DEF_TEMPDIR     	"T:"
#define DEF_SELECTPATH  	""

#define DEF_PATH		"SYS:Utilities/"
#define DEF_V36_ASCII   	DEF_PATH"More"
#define DEF_V36_ILBM    	DEF_PATH"Display"
#define DEF_V39_ASCII   	DEF_PATH"MultiView"
#define DEF_V39_ILBM    	DEF_PATH"MultiView"
#define DEF_OTHERS      	DEF_PATH"AZap"

#define DEF_BUPFLAGS    	BFL_VERIFY|BFL_CHILDTASK|BFL_COMPRESS|BFL_CATCOMP|BFL_ADDICON|BFL_ADDCOMMENT
#define DEF_BUPTO       	"DF0:"
#define DEF_LOGFILE     	""
#define DEF_DEFCOMMENT  	""
#define DEF_LABELSLENGTH	5

#define DEF_RESFLAGS    	RFL_DIRTREE|RFL_DATE|RFL_EMPTYDIRS|RFL_ASKREPLACE|RFL_ASKDELBAD
#define DEF_RESFROM     	"DF0:"
#define DEF_RESTO       	""

#define DEF_VERFLAGS    	VFL_COMPARE

#define DEF_TAPFLAGS    	NULL

#define DEF_XPKMETHOD   	"NUKE"
#define DEF_XPKMODE     	50
#define DEF_COMP		""
#define DEF_DECOMP      	""
#define DEF_FILTER      	"arc,arj,dms,gif,jpg,jpeg,lha,lzh,mpg,pp,z,zip,zoo"

#define DEF_DEVICEDRIVER	"scsi.device"
#define DEF_SCSIPORT    	4
#define DEF_BLOCKSIZE   	512

#ifndef ABPREFS_PREFDEF_H
#include "prefdef.h"
#endif

#endif /* PREFS_ABACKUP_H */
