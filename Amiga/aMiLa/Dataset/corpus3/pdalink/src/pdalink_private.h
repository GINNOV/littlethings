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
 * Private structures and functions of pdalink.library.
 *
 * @author Richard "Shred" Körber
 */
 
#ifndef PDALINK_PRIVATE_H
#define PDALINK_PRIVATE_H

#include <exec/io.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <exec/nodes.h>
#include <exec/semaphores.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>


struct RexxHandle
{
  struct Node rh_node;
  APTR rh_handle;
  unsigned char rh_name[0];
};


struct PL_FileHeader
{
  char name[32];
  UWORD flags;
  UWORD version;
  ULONG creationTime;
  ULONG modificationTime;
  ULONG backupTime;
  ULONG modificationNr;
  ULONG appInfoOffset;
  ULONG sortInfoOffset;
  ULONG type;
  ULONG creator;
  ULONG uniqueID;
  ULONG nextRecordListID;
  UWORD numRecords;
};

struct PL_ResEntryHeader
{
  ULONG type;
  UWORD id;
  ULONG offset;
};

struct PL_RecEntryHeader
{
  ULONG offset;
  UBYTE attrs;
  UBYTE uid[3];
};

struct PL_Entry
{
  struct MinNode node;
  APTR  entryData;
  ULONG offset;
  ULONG size;
  ULONG type;
  UWORD id;
  ULONG uid;
  UBYTE attrs;
};

struct PL_File
{
  BPTR fh;                      /* File handle to the Palm file */
  STRPTR filename;              /* Copy of file name */
  BOOL  resourceFlag;
  BOOL  forWriteFlag;
  ULONG size;                   /* Size of file */
  struct DLP_DBInfo dbinfo;     /* Database info */
  ULONG uniqueID;
  ULONG nextRecordListID;
  UWORD numRecords;
  UWORD entHeaderSize;
  struct MinList entries;       /* List of all entries */
  ULONG cntEntries;
  APTR appInfo;
  ULONG appInfoSize;
  APTR sortInfo;
  ULONG sortInfoSize;
};


struct PL_Serial
{
  struct MsgPort *serport;      /* Message port for interface */
  struct IOExtSer *serio;       /* IO structure for interface */
  struct MsgPort *timerport;    /* Message port for timer */
  struct timerequest *timerio;  /* IO structure for timer */
  struct Device *timerbase;     /* Base of timer device */
  ULONG  currBaud;              /* Current baud rate */
  BOOL   isUSB;                 /* uses netsync protocol */
};


#define PLCMPVER_1_0  (0x0100)  /* V1.0 */
#define PLCMPVER_2_0  (0x0101)  /* V2.0 */

struct PL_Socket
{
  LONG   lastError;             /* Last Error Code */
  struct PL_Serial *serial;     /* Serial Connection */
  ULONG  timeout;               /* Timeout (s) */
  ULONG  baudRate;              /* Baud rate between Palm and Amiga */
  ULONG  maxRate;               /* Amiga's maximum baud rate */
  UBYTE *dlpbuffer;             /* Buffer for DLP data */
  LONG   dlpoffset;             /* Data offset/length*/
  LONG   readoffset;            /* read DLP: starting position */
  UBYTE  transactionID;         /* Current Transaction ID */
  BYTE   initiator;             /* TRUE: transaction initiator */
  UWORD  version;               /* Version of Remote */
  UWORD  dlprecord;             /* Current DLP record */
  ULONG  abortmask;             /* Abort Mask, e.g. CTRL-C */
};





#endif

