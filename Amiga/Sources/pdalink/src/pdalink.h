/*
 * PdaLink -- Connect Palm with Amiga
 *
 * Copyright (C) 1998-2010 Richard "Shred" Körber
 *   http://pdalink.shredzone.org
 *
 * This library is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */
 
/**
 * Main headers for pdalink.library.
 *
 * @author Richard "Shred" Körber
 */

#ifndef LIBRARIES_PDALINK_H
#define LIBRARIES_PDALINK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif


/*--------------------------------------------------------------**
**    Miscellaneous
*/
#define PDALINK_NAME "pdalink.library"



/*--------------------------------------------------------------**
**    Tags
*/
#define PLTAG_BASE          (0x8FEA0000)        /* Base for all TagItems */
#define PLTAG_ErrorPtr      (PLTAG_BASE + 0x00) /* Pointer to LONG for error code result */
#define PLTAG_SerialDevice  (PLTAG_BASE + 0x01) /* Device name */
#define PLTAG_SerialUnit    (PLTAG_BASE + 0x02) /* Device unit nr. */
#define PLTAG_SerialMaxRate (PLTAG_BASE + 0x03) /* Maximum baud rate */
#define PLTAG_SerialTimeout (PLTAG_BASE + 0x04) /* Timeout (seconds) */
#define PLTAG_AbortMask     (PLTAG_BASE + 0x05) /* Signal mask for abortion, e.g. CTRL-C */


/*--------------------------------------------------------------**
**    Desktop Link Protocol
*/
/* System Time */
struct DLP_SysTime
{
  UWORD year;                           /* Year */
  UBYTE month;                          /* Month */
  UBYTE day;                            /* Day */
  UBYTE hour;                           /* Hour */
  UBYTE minute;                         /* Minute */
  UBYTE second;                         /* Second */
  UBYTE pad;                            /* (always set to 0) */
};

/* RAM/ROM card info */
struct DLP_StorageInfo
{
  UWORD  cardVersion;                   /* Version */
  struct DLP_SysTime date;              /* Creation date */
  ULONG  ROMSize;                       /* Size of ROM */
  ULONG  RAMSize;                       /* Size of RAM */
  ULONG  RAMFree;                       /* Free RAM */
  char   name[128];                     /* Name of the card */
  char   manuf[128];                    /* Manufacturer of the card */
  UBYTE  cardNo;                        /* Card No. */
  UBYTE  more;                          /* BOOL: more cards? */
};

/* System Info */
struct DLP_SysInfo
{
  ULONG romVer;                         /* ROM Version */
  ULONG locale;                         /* Localizion code */
  UBYTE name[128];                      /* System name */
};

/* User Info */
struct DLP_UserInfo
{
  ULONG userID;
  ULONG viewerID;
  ULONG lastSyncPC;
  struct DLP_SysTime successfulSync;
  struct DLP_SysTime lastSync;
  char  userName[128];
  char  password[128];
};

/* Netsync Info */
struct DLP_NetSyncInfo
{
  UWORD lanSync;
  char hostName[256];
  char hostAddress[40];
  char hostSubnetMask[40];
};

/* Database Info */
struct DLP_DBInfo
{
  UBYTE more;                           /* BOOL: more databases? */
  UBYTE excludes;                       /* Exclude flags, see below */
  UWORD flags;                          /* Entry flags, see below */
  ULONG type;                           /* Type ID */
  ULONG creator;                        /* Creator ID */
  UWORD version;                        /* Version */
  ULONG modnum;                         /* Modification Number */
  struct DLP_SysTime createDate;        /* Creation date */
  struct DLP_SysTime modifyDate;        /* Last modification */
  struct DLP_SysTime backupDate;        /* Last backup */
  UWORD index;                          /* Index */
  UBYTE name[34];                       /* Entry name */
};

/* GetDBInfo flags */
#define DLPGDBF_RAM           (0x80)    /* List RAM entries only */
#define DLPGDBF_ROM           (0x40)    /* List ROM entries only */

/* DBInfo excludes */
#define DLPDBIE_EXCLUDESYNC   (0x80)    /* Exclude from Sync */

/* DBInfo flags */
#define DLPDBIF_RESOURCE      (0x0001)  /* DB Resource (not a record) */
#define DLPDBIF_READONLY      (0x0002)  /* Read only */
#define DLPDBIF_APPINFODIRTY  (0x0004)  /* AppInfo has been modified */
#define DLPDBIF_BACKUP        (0x0008)  /* Generic backup */
#define DLPDBIF_NEWER         (0x0010)  /* Newer may replace older in open DB */
#define DLPDBIF_RESET         (0x0020)  /* Reset after installation */
#define DLPDBIF_OPEN          (0x8000)  /* Currently opened */

/* DB Attribute */
#define DLPDBAT_DELETED       (0x80)    /* Deleted */
#define DLPDBAT_DIRTY         (0x40)    /* Changed since last sync */
#define DLPDBAT_BUSY          (0x20)    /* Currently locked */
#define DLPDBAT_SECRET        (0x10)    /* Private entry */
#define DLPDBAT_ARCHIVE       (0x08)    /* To be archived on next sync */

/* DB Open flags */
#define DLPDBOF_READ          (0x80)    /* Open for reading */
#define DLPDBOF_WRITE         (0x40)    /* Open for writing */
#define DLPDBOF_EXCLUSIVE     (0x20)    /* Do not share */
#define DLPDBOF_SECRET        (0x10)    /* Private entry */
#define DLPDBOF_READWRITE     (0xC0)


/*--------------------------------------------------------------**
**    Connection Management Protocol
*/

/* CMP structure */
struct PL_CMP
{
  UBYTE  type;                          /* CMP message type */
  UBYTE  flags;                         /* Some flags */
  UWORD  version;                       /* Version code */
  WORD   reserved;                      /* 0 for now */
  ULONG  baudrate;                      /* Wakeup: maximum rate */
                                        /* Init: connection rate */
};

/* CMP Types */
#define PLCMP_WAKEUP      (1)           /* Wakeup */
#define PLCMP_INIT        (2)           /* Init connection */
#define PLCMP_ABORT       (3)           /* Abort connection */

/* CMP Flags */
#define PLCMPF_CHANGEBAUD (0x80)        /* Init: change baud rate */


/*--------------------------------------------------------------**
**    Packet Assembly Disassembly Protocol
*/

/* PADP Header structure */
struct PL_PADP_Header
{
  UBYTE  type;                          /* Type of Packet */
  UBYTE  flags;                         /* Flags */
  UWORD  size;                          /* Size of data */
};                                      /* Data follows here */

/* PADP Types */
#define PLPADP_DATA       (0x01)        /* Plain Data */
#define PLPADP_WAKE       (0x101)       /* Wakeup, used by CMP */
#define PLPADP_ACK        (0x02)        /* Acknowledge */
#define PLPADP_TICKLE     (0x04)        /* Tickle */
#define PLPADP_ABORT      (0x08)        /* Abort (PalmOS 2.0 only) */

/* PADP Flags */
#define PLPADPF_FIRST     (0x80)        /* First packet */
#define PLPADPF_LAST      (0x40)        /* Last packet */
#define PLPADPF_MEMERROR  (0x20)        /* Receiver has not enough memory */


/*--------------------------------------------------------------**
**    NetSync Protocol
*/

/* NetSync Header structure */
struct PL_NetSync_Header
{
  UBYTE  type;                          /* Type of Packet */
  UBYTE  transID;                       /* current transaction ID */
  ULONG  dataSize;                      /* payload */
};                                      /* Data follows here */


/*--------------------------------------------------------------**
**    Serial Link Protocol
*/

/* SLP Header structure */
struct PL_SLP_Header
{
  UBYTE  signature[3];                  /* (will be set by pdalink.library) */
  UBYTE  destSocket;                    /* Destination Socket ID */
  UBYTE  srcSocket;                     /* Source Socket ID */
  UBYTE  pckType;                       /* Packet Type */
  UWORD  dataSize;                      /* (will be set by pdalink.library) */
  UBYTE  transID;                       /* Current transaction ID */
  UBYTE  checksum;                      /* (calculated by pdalink.library) */
};

/* SLP Socket IDs */
#define PLSLPSOCK_DEBUG (0)             /* Debugger */
#define PLSLPSOCK_CON   (1)             /* Console */
#define PLSLPSOCK_RUI   (2)             /* Remote User Interface */
#define PLSLPSOCK_DLP   (3)             /* Desktop Link Protocol */

/* SLP Packet Types */
#define PLSLPTYPE_RDCP  (0)             /* Remote Debugger / Console */
#define PLSLPTYPE_PADP  (2)             /* Packet Assembler Disassembler */
#define PLSLPTYPE_LOOP  (3)             /* Loopback */


/*--------------------------------------------------------------**
**    Category Application Info
*/

/* Category AppInfo structure */
struct PL_CategoryAppInfo
{
  UWORD  renamed;                       /* Bit array: renamed categories */
  UBYTE  name[16][16];                  /* Array of Category names */
  UBYTE  ID[16];                        /* Category IDs */
  UBYTE  lastUniqueID;
  UBYTE  pad[3];                        /* always 0 */
};


/*--------------------------------------------------------------**
**    Error Codes
*/

/* PdaLink errors */
#define PLERR_OKAY              (0)     /* No error occured */
#define PLERR_NOMEM             (-1)    /* Not enough memory */
#define PLERR_NORESOURCE        (-2)    /* A resource is allocated */
#define PLERR_SERIAL            (-3)    /* Some serial error */
#define PLERR_TIMEOUT           (-4)    /* Connection timeout */
#define PLERR_CHECKSUM          (-5)    /* Data checksum error */
#define PLERR_REMOTENOMEM       (-6)    /* Remote has not enough memory */
#define PLERR_BADPACKET         (-7)    /* Got an unexpected packet */
#define PLERR_NOTCOMPATIBLE     (-8)    /* Connection not compatible */
#define PLERR_BADBAUD           (-9)    /* No fitting Baud rate found */
                                        /* If you should get this one, try */
                                        /* to lower PLTAG_SerialMaxRate. */
                                        /* 9600 should work in any case, */
                                        /* except you have a very wierd */
                                        /* multi serial board. */
#define PLERR_DOSERROR          (-10)   /* DOS error, see IoErr() */
#define PLERR_OS2REQUIRED       (-11)   /* PalmOS2.0 or higher is required */
                                        /* to use this function */
#define PLERR_TOOLARGE          (-12)   /* Data buffer is too large (>64KB) */
#define PLERR_ABORTED           (-13)   /* Aborted by abortion signal */

/* DLP errors */
#define PLERR_GENERAL           (1)     /* General system error */
#define PLERR_ILLEGALFCT        (2)     /* Illegal function */
#define PLERR_DLPNOMEM          (3)     /* Out of memory */
#define PLERR_INVPARAM          (4)     /* Invalid parameter */
#define PLERR_NOTFOUND          (5)     /* Not found */
#define PLERR_NONEOPEN          (6)     /* None opened */
#define PLERR_ALREADYOPEN       (7)     /* Already opened */
#define PLERR_TOOMANYOPEN       (8)     /* Too many are opened */
#define PLERR_ALREADYEXIST      (9)     /* Already exists */
#define PLERR_CANTOPEN          (10)    /* Can't open */
#define PLERR_RECDELETED        (11)    /* Record deleted */
#define PLERR_RECBUSY           (12)    /* Record busy */
#define PLERR_UNSUPPORTED       (13)    /* Operation not supported */
#define PLERR_READONLY          (15)    /* Read only */
#define PLERR_NOSPACE           (16)    /* Not enough space */
#define PLERR_EXCEEDED          (17)    /* Limit exceeded */
#define PLERR_CANCELLED         (18)    /* Sync cancelled */
#define PLERR_BADARG            (19)    /* Bad argument wrapper */
#define PLERR_ARGMISSING        (20)    /* Argument is missing */
#define PLERR_ARGSIZE           (21)    /* Bad argument size */


#endif
/****************************************************************/

