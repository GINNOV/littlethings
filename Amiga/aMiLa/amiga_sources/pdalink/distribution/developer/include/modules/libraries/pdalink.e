/*
** PdaLink -- Connect Palm with Amiga
**
** Copyright (C) 1998-2010 Richard "Shred" Körber
**   http://pdalink.shredzone.org
**
** This library is free software: you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License as published by the Free Software Foundation, either
** version 3 of the License, or (at your option) any later version.
**
** This library is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
** Lesser General Public License for more details.
**
** You should have received a copy of the GNU Lesser General Public
** License along with this library.  If not, see <http://www.gnu.org/licenses/>.
**/

OPT MODULE
OPT EXPORT
OPT PREPROCESS

/*--------------------------------------------------------------**
**    Miscellaneous
*/
#define PDALINK_NAME  'pdalink.library'

/*--------------------------------------------------------------**
**    Tags
*/
CONST PLTAG_BASE          = $8FEA0000        /* Base for all TagItems */
CONST PLTAG_ErrorPtr      = PLTAG_BASE + $00 /* Pointer to LONG for error code result */
CONST PLTAG_SerialDevice  = PLTAG_BASE + $01 /* Device name */
CONST PLTAG_SerialUnit    = PLTAG_BASE + $02 /* Device unit nr. */
CONST PLTAG_SerialMaxRate = PLTAG_BASE + $03 /* Maximum baud rate */
CONST PLTAG_SerialTimeout = PLTAG_BASE + $04 /* Timeout = seconds */
CONST PLTAG_AbortMask     = PLTAG_BASE + $05 /* Signal mask for abortion, e.g. CTRL-C */


/*--------------------------------------------------------------**
**    Desktop Link Protocol
*/
/* System Time */
OBJECT dlp_SysTime
    year:INT                            /* Year */
    month:CHAR                          /* Month */
    day:CHAR                            /* Day */
    hour:CHAR                           /* Hour */
    minute:CHAR                         /* Minute */
    second:CHAR                         /* Second */
    pad:CHAR                            /* = always set to 0 */
ENDOBJECT

/* RAM/ROM card info */
OBJECT dlp_StorageInfo
    cardVersion:INT                   /* Version */
    date:dlp_SysTime                  /* Creation date */
    romSize:LONG                      /* Size of ROM */
    ramSize:LONG                      /* Size of RAM */
    ramFree:LONG                      /* Free RAM */
    name[128]:ARRAY OF CHAR           /* Name of the card */
    manuf[128]:ARRAY OF CHAR          /* Manufacturer of the card */
    cardNo:CHAR                       /* Card No. */
    more:CHAR                         /* BOOL: more cards? */
ENDOBJECT

/* System Info */
OBJECT dlp_SysInfo
    romVer:LONG                         /* ROM Version */
    locale:LONG                         /* Localizion code */
    name[128]:ARRAY OF CHAR             /* System name */
ENDOBJECT

/* User Info */
OBJECT dlp_UserInfo
    userID:LONG
    viewerID:LONG
    lastSyncPC:LONG
    successfulSync:dlp_SysTime
    lastSync:dlp_SysTime
    userName[128]:ARRAY OF CHAR
    password[128]:ARRAY OF CHAR
ENDOBJECT

/* Netsync Info */
OBJECT dlp_NetSyncInfo
    lanSync:INT
    hostName[256]:ARRAY OF CHAR
    hostAddress[40]:ARRAY OF CHAR
    hostSubnetMask[40]:ARRAY OF CHAR
ENDOBJECT

/* Database Info */
OBJECT dlp_DBInfo
    more:CHAR                       /* BOOL: more databases? */
    excludes:CHAR                   /* Exclude flags, see below */
    flags:INT                       /* Entry flags, see below */
    type:LONG                       /* Type ID */
    creator:LONG                    /* Creator ID */
    version:INT                     /* Version */
    modnum:LONG                     /* Modification Number */
    createDate:dlp_SysTime          /* Creation date */
    modifyDate:dlp_SysTime          /* Last modification */
    backupDate:dlp_SysTime          /* Last backup */
    index:INT                       /* Index */
    name[34]:ARRAY OF CHAR          /* Entry name */
ENDOBJECT

/* GetDBInfo flags */
CONST DLPGDBF_RAM           = $80    /* List RAM entries only */
CONST DLPGDBF_ROM           = $40    /* List ROM entries only */

/* DBInfo excludes */
CONST DLPDBIE_EXCLUDESYNC   = $80    /* Exclude from Sync */

/* DBInfo flags */
CONST DLPDBIF_RESOURCE      = $0001  /* DB Resource = not a record */
CONST DLPDBIF_READONLY      = $0002  /* Read only */
CONST DLPDBIF_APPINFODIRTY  = $0004  /* AppInfo has been modified */
CONST DLPDBIF_BACKUP        = $0008  /* Generic backup */
CONST DLPDBIF_NEWER         = $0010  /* Newer may replace older in open DB */
CONST DLPDBIF_RESET         = $0020  /* Reset after installation */
CONST DLPDBIF_OPEN          = $8000  /* Currently opened */

/* DB Attribute */
CONST DLPDBAT_DELETED       = $80    /* Deleted */
CONST DLPDBAT_DIRTY         = $40    /* Changed since last sync */
CONST DLPDBAT_BUSY          = $20    /* Currently locked */
CONST DLPDBAT_SECRET        = $10    /* Private entry */
CONST DLPDBAT_ARCHIVE       = $08    /* To be archived on next sync */

/* DB Open flags */
CONST DLPDBOF_READ          = $80    /* Open for reading */
CONST DLPDBOF_WRITE         = $40    /* Open for writing */
CONST DLPDBOF_EXCLUSIVE     = $20    /* Do not share */
CONST DLPDBOF_SECRET        = $10    /* Private entry */
CONST DLPDBOF_READWRITE     = $C0



/*--------------------------------------------------------------**
**    Connection Management Protocol
*/

/* CMP structure */
OBJECT pl_CMP
    type:CHAR                          /* CMP message type */
    flags:CHAR                         /* Some flags */
    version:INT                       /* Version code */
    reserved:INT                      /* 0 for now */
    baudrate:LONG                      /* Wakeup: maximum rate */
                                        /* Init: connection rate */
ENDOBJECT

/* CMP Types */
CONST PLCMP_WAKEUP      = 1           /* Wakeup */
CONST PLCMP_INIT        = 2           /* Init connection */
CONST PLCMP_ABORT       = 3           /* Abort connection */

/* CMP Flags */
CONST PLCMPF_CHANGEBAUD = $80        /* Init: change baud rate */



/*--------------------------------------------------------------**
**    Packet Assembly Disassembly Protocol
*/

/* PADP Header structure */
OBJECT pl_PADP_Header
    type:CHAR                          /* Type of Packet */
    flags:CHAR                         /* Flags */
    size:INT                           /* Size of data */
ENDOBJECT

/* PADP Types */
CONST PLPADP_DATA       = $01        /* Plain Data */
CONST PLPADP_WAKE       = $101       /* Wakeup, used by CMP */
CONST PLPADP_ACK        = $02        /* Acknowledge */
CONST PLPADP_TICKLE     = $04        /* Tickle */
CONST PLPADP_ABORT      = $08        /* Abort = PalmOS 2.0 only */

/* PADP Flags */
CONST PLPADPF_FIRST     = $80        /* First packet */
CONST PLPADPF_LAST      = $40        /* Last packet */
CONST PLPADPF_MEMERROR  = $20        /* Receiver has not enough memory */



/*--------------------------------------------------------------**
**    Serial Link Protocol
*/

/* SLP Header structure */
OBJECT pl_SLP_Header
    signature[3]:ARRAY OF CHAR         /* = will be set by pdalink.library */
    destSocket:CHAR                    /* Destination Socket ID */
    srcSocket:CHAR                     /* Source Socket ID */
    pckType:CHAR                       /* Packet Type */
    dataSize:INT                       /* = will be set by pdalink.library */
    transID:CHAR                       /* Current transaction ID */
    checksum:CHAR                      /* = calculated by pdalink.library */
ENDOBJECT

/* SLP Socket IDs */
CONST PLSLPSOCK_DEBUG = 0             /* Debugger */
CONST PLSLPSOCK_CON   = 1             /* Console */
CONST PLSLPSOCK_RUI   = 2             /* Remote User Interface */
CONST PLSLPSOCK_DLP   = 3             /* Desktop Link Protocol */

/* SLP Packet Types */
CONST PLSLPTYPE_RDCP  = 0             /* Remote Debugger / Console */
CONST PLSLPTYPE_PADP  = 2             /* Packet Assembler Disassembler */
CONST PLSLPTYPE_LOOP  = 3             /* Loopback */



/*--------------------------------------------------------------**
**    Error Codes
*/

/* PdaLink errors */
CONST PLERR_OKAY              = 0     /* No error occured */
CONST PLERR_NOMEM             = -1    /* Not enough memory */
CONST PLERR_NORESOURCE        = -2    /* A resource is allocated */
CONST PLERR_SERIAL            = -3    /* Some serial error */
CONST PLERR_TIMEOUT           = -4    /* Connection timeout */
CONST PLERR_CHECKSUM          = -5    /* Data checksum error */
CONST PLERR_REMOTENOMEM       = -6    /* Remote has not enough memory */
CONST PLERR_BADPACKET         = -7    /* Got an unexpected packet */
CONST PLERR_NOTCOMPATIBLE     = -8    /* Connection not compatible */
CONST PLERR_BADBAUD           = -9    /* No fitting Baud rate found */
                                        /* If you should get this one, try */
                                        /* to lower PLTAG_SerialMaxRate. */
                                        /* 9600 should work in any case, */
                                        /* except you have a very wierd */
                                        /* multi serial board. */
CONST PLERR_DOSERROR          = -10   /* DOS error, see IoErr=  */
CONST PLERR_OS2REQUIRED       = -11   /* PalmOS2.0 or higher is required */
                                        /* to use this function */
CONST PLERR_TOOLARGE          = -12   /* Data buffer is too large = >64KB */
CONST PLERR_ABORTED           = -13   /* Aborted by abortion signal */

/* DLP errors */
CONST PLERR_GENERAL           = 1     /* General system error */
CONST PLERR_ILLEGALFCT        = 2     /* Illegal function */
CONST PLERR_DLPNOMEM          = 3     /* Out of memory */
CONST PLERR_INVPARAM          = 4     /* Invalid parameter */
CONST PLERR_NOTFOUND          = 5     /* Not found */
CONST PLERR_NONEOPEN          = 6     /* None opened */
CONST PLERR_ALREADYOPEN       = 7     /* Already opened */
CONST PLERR_TOOMANYOPEN       = 8     /* Too many are opened */
CONST PLERR_ALREADYEXIST      = 9     /* Already exists */
CONST PLERR_CANTOPEN          = 10    /* Can't open */
CONST PLERR_RECDELETED        = 11    /* Record deleted */
CONST PLERR_RECBUSY           = 12    /* Record busy */
CONST PLERR_UNSUPPORTED       = 13    /* Operation not supported */
CONST PLERR_READONLY          = 15    /* Read only */
CONST PLERR_NOSPACE           = 16    /* Not enough space */
CONST PLERR_EXCEEDED          = 17    /* Limit exceeded */
CONST PLERR_CANCELLED         = 18    /* Sync cancelled */
CONST PLERR_BADARG            = 19    /* Bad argument wrapper */
CONST PLERR_ARGMISSING        = 20    /* Argument is missing */
CONST PLERR_ARGSIZE           = 21    /* Bad argument size */


/****************************************************************/
