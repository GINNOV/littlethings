/* AMOS Sample Bank client for XAD.
 * Copyright (C) 2001-2002 Stuart Caie <kyzer@4u.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/* AMOS bank header:
 *   UBYTE header[4];     // "AmBk" 
 *   UWORD bank_number;
 *   UWORD zero;
 *   ULONG bank_length;   // has bit 31 set
 *   UBYTE bank_type[8];  // "Samples "
 *
 * Depending on how it's ripped, the file might start with header,
 * bank_length, or  bank_type. We assume that there's at least a single
 * 2 byte sample, so the minimum size is 30 bytes.
 *
 * sample bank header
 *   UWORD number_of_samples
 *   ULONG  sample_ptrs[]; // relative to start of sample bank header
 *
 * sample itself:
 *   UBYTE name[8];
 *   UWORD frequency;     // in Hz
 *   ULONG length;
 *   BYTE  sample_data[]  // always rounded to a multiple of 2 bytes
 */

#include <libraries/xadmaster.h>
#include <proto/xadmaster.h>
#include <string.h>

#include "SDI_compiler.h"
#include "ConvertE.c"

#ifndef XADMASTERFILE
#define AMOSSB_Client		FirstClient
#define NEXTCLIENT		0
const UBYTE version[] = "$VER: AmosSampBank 1.1 (20.04.2002)";
#endif
#define AMOSSB_VERSION		1
#define AMOSSB_REVISION		1

#define XADBASE  REG(a6, struct xadMasterBase *xadMasterBase)

#define IFF_HEADER_LEN (0x30)

static const UBYTE iff_header[IFF_HEADER_LEN] = {
  'F', 'O', 'R', 'M',    /* 00 FORM                        */
   0,   0,   0,   0,     /* 04   form length               */
  '8', 'S', 'V', 'X',    /* 08   8SVX                      */ 
  'V', 'H', 'D', 'R',    /* 0c   VHDR                      */ 
   0,   0,   0,   20,    /* 10     vhdr chunk length (20)  */ 
   0,   0,   0,   0,     /* 14     one-shot length         */
   0,   0,   0,   0,     /* 18     repeat length (0)       */
   0,   0,   0,   0,     /* 1c     average rate (0)        */
   0,   0,               /* 20     frequency in hz         */
   1,                    /* 22     number of octave (1)    */
   0,                    /* 23     compression mode (0)    */
   0,   1,   0,   0,     /* 24     volume (0x10000)        */
  'B', 'O', 'D', 'Y',    /* 28   BODY                      */
   0,   0,   0,   0      /* 2c     body length             */
};
 
static const UBYTE bank_name[8] = "Samples ";  

ASM(BOOL) AMOSSB_RecogData(REG(d0, ULONG size), REG(a0, STRPTR d), XADBASE) {
  /* skip over any AMOS bank headers */
  if (EndGetM32(&d[0]) == 0x416D426B) { /* AmBk */
    d += 12; /* skip to "Samples " part */
  }
  if (strncmp(&bank_name[0], &d[0], 8) == 0) return (BOOL) 1;
  if (strncmp(&bank_name[0], &d[4], 8) == 0) return (BOOL) 1;
  return (BOOL) 0;
}

ASM(LONG) AMOSSB_GetInfo(REG(a0, struct xadArchiveInfo *ai), XADBASE) {
  ULONG numfiles, offset, filelen;
  struct xadFileInfo *fi;
  LONG err = XADERR_OK;
  UBYTE buffer[22];
  int i;

  struct TagItem filetags[]  = {
    { XAD_OBJNAMESIZE, 14 },
    { TAG_DONE, 0 }
  };

  struct TagItem datetags[] = {
    { XAD_DATECURRENTTIME, 1 },
    { XAD_GETDATEXADDATE,  0 },
    { TAG_DONE, 0 }
  };

  struct TagItem addtags[] = {
    { XAD_SETINPOS, 0 },
    { TAG_DONE, 0 }
  };

  /* read the file header */
  if ((err = xadHookAccess(XADAC_READ, 22, &buffer[0], ai))) return err;

  /* get the magic header to work out where the number of samples will be */
  offset = EndGetM32(&buffer[0]);  
       if (offset == 0x416D426B) offset = 20; /* AmBk */
  else if (offset == 0x53616D70) offset = 8;  /* Samp */
  else                           offset = 12;

  /* get the number of files */
  numfiles = EndGetM16(&buffer[offset]);

  /* skip past the list of sample offsets */
  offset += 2 + numfiles * 4;
  if ((err = xadHookAccess(XADAC_INPUTSEEK, offset-ai->xai_InPos, NULL, ai)))
    return err;

  while (numfiles--) {
    /* read the file header */
    if ((err = xadHookAccess(XADAC_READ, 14, buffer, ai))) break;

    filelen = EndGetM32(&buffer[10]);
    if (filelen & 1) filelen++;
    offset += 14 + filelen;

    fi = (struct xadFileInfo *) xadAllocObjectA(XADOBJ_FILEINFO, filetags);
    if (!fi) { err = XADERR_NOMEMORY; break; }

    fi->xfi_PrivateInfo = (APTR) EndGetM16(&buffer[8]);
    fi->xfi_Size        = filelen + IFF_HEADER_LEN;
    fi->xfi_CrunchSize  = filelen;
    fi->xfi_Flags       = XADFIF_SEEKDATAPOS | XADFIF_EXTRACTONBUILD;
    fi->xfi_DataPos     = ai->xai_InPos;

    /* make filename */
    for (i = 0; i < 8; i++) {
      if ((buffer[i] == '\0') || (buffer[i] == '.')) break;
      fi->xfi_FileName[i] = buffer[i];
    }
    fi->xfi_FileName[i++] = '.';
    fi->xfi_FileName[i++] = '8';
    fi->xfi_FileName[i++] = 's';
    fi->xfi_FileName[i++] = 'v';
    fi->xfi_FileName[i++] = 'x';
    fi->xfi_FileName[i]   = '\0';

    /* fill in today's date */
    datetags[1].ti_Data = (ULONG) &fi->xfi_Date;
    xadConvertDatesA(datetags);

    addtags[0].ti_Data = offset;
    if ((err = xadAddFileEntryA(fi, ai, addtags))) break;
  }

  if (err) {
    if (!ai->xai_FileInfo) return err;
    ai->xai_Flags |= XADAIF_FILECORRUPT;
    ai->xai_LastError = err;
  }
  return XADERR_OK;
}

ASM(LONG) AMOSSB_UnArchive(REG(a0, struct xadArchiveInfo *ai), XADBASE) {
  UBYTE header[IFF_HEADER_LEN];
  ULONG length, freq;

  memcpy(&header[0], &iff_header[0], IFF_HEADER_LEN);

  /* length of entire IFF file, excluding FORM and this length */
  length = ai->xai_CurFile->xfi_Size - 8;
  header[0x04] = (length >> 24) & 0xFF;
  header[0x05] = (length >> 16) & 0xFF;
  header[0x06] = (length >>  8) & 0xFF;
  header[0x07] = (length      ) & 0xFF;

  /* number of one-shot samples (all of them) / body length */
  length = length + 8 - IFF_HEADER_LEN;
  header[0x2c] = header[0x14] = (length >> 24) & 0xFF;
  header[0x2d] = header[0x15] = (length >> 16) & 0xFF;
  header[0x2e] = header[0x16] = (length >>  8) & 0xFF;
  header[0x2f] = header[0x17] = (length      ) & 0xFF;

  /* sample frequency */
  freq = (ULONG) ai->xai_CurFile->xfi_PrivateInfo;
  header[0x20] = (freq >> 8) & 0xFF;
  header[0x21] = (freq     ) & 0xFF;

  return xadHookAccess(XADAC_WRITE, IFF_HEADER_LEN, (APTR) &header[0], ai)
      || xadHookAccess(XADAC_COPY, length, NULL, ai);
}

const struct xadClient AMOSSB_Client = {
  NEXTCLIENT, XADCLIENT_VERSION, 10, AMOSSB_VERSION, AMOSSB_REVISION,
  30, XADCF_FILEARCHIVER | XADCF_FREEFILEINFO,
  0, "AMOS Sample Bank",

  /* client functions */
  (BOOL (*)()) AMOSSB_RecogData,
  (LONG (*)()) AMOSSB_GetInfo,
  (LONG (*)()) AMOSSB_UnArchive,
  NULL
};
