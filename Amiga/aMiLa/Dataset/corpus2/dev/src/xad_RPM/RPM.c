/* RPM Package Manager (RPM) extractor client for XAD.
 * Copyright (C) 2000 Stuart Caie <kyzer@4u.net>
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

/* RPM is the concatenation of two things - some tag-based headers, and
 * an archive. The headers are stored in central databases on people's
 * machines and places like rpmfind.net. The archive is a gzip compressed
 * cpio archive. All this client does is skip past the headers and then
 * pretend to be just like the gzip slave (as far as possible)
 */

#include <libraries/xadmaster.h>
#include <proto/xadmaster.h>
#include <string.h>

#include "SDI_compiler.h"
#include "ConvertE.c"

#ifndef XADMASTERFILE
#define RPM_Client		FirstClient
#define NEXTCLIENT		0
UBYTE version[] = "$VER: RPM 1.2 (13.09.2000)";
#endif
#define RPM_VERSION     1
#define RPM_REVISION    2

#define XADBASE REG(a6, struct xadMasterBase *xadMasterBase)
#define SKIP(offset) if ((err = xadHookAccess(XADAC_INPUTSEEK, \
  (ULONG)(offset), NULL, ai))) goto exit_handler
#define SEEK(offset) SKIP((offset) - ai->xai_InPos)
#define READ(buffer,length) if ((err = xadHookAccess(XADAC_READ, \
  (ULONG)(length), (APTR)(buffer), ai))) goto exit_handler
#define ALLOC(t,v,l) \
  if (!((v) = (t) xadAllocVec((l),0))) ERROR(NOMEMORY)
#define ALLOCOBJ(t,v,kind,tags) \
  if (!((v) = (t) xadAllocObjectA((kind),(tags)))) ERROR(NOMEMORY)
#define FREE(obj) xadFreeObjectA((obj),NULL)
#define ERROR(error) do { err = XADERR_##error; goto exit_handler; } while (0)


ASM(BOOL) RPM_RecogData(REG(d0, ULONG size), REG(a0, UBYTE *d), XADBASE) {
  return (BOOL) (d[0]==0xED && d[1]==0xAB && d[2]==0xEE && d[3]==0xDB);
}

static const STRPTR RPM_arch[] = {
  ".i386", ".alpha", ".sparc", ".mips", ".ppc", ".m68k",
  ".sgi", ".rs6000", "", ".sparc64", ".mips", ".arm"
};

ASM(LONG) SAVEDS RPM_GetInfo(REG(a0, struct xadArchiveInfo *ai), XADBASE) {
  UBYTE *buffer, *fname;
  struct xadArchiveInfo *ai2 = NULL;
  struct xadFileInfo *fi;
  LONG err = XADERR_OK;
  int version, namelen;

  struct TagItem filetags[]  = {
    { XAD_OBJNAMESIZE, 0 },
    { TAG_DONE, 0 }
  };

  struct TagItem datetags[] = {
    { XAD_DATECURRENTTIME, 1 },
    { XAD_GETDATEXADDATE,  0 },
    { TAG_DONE, 0 }
  };

  struct TagItem tags[] = {
    { XAD_INXADSTREAM, 0 },
    { TAG_DONE, 0 },
    { XAD_ARCHIVEINFO, 0 },
    { TAG_DONE, 0 }
  };

  tags[0].ti_Data = (ULONG) &tags[2];
  tags[2].ti_Data = (ULONG) ai;

  ALLOC(UBYTE *, buffer, 96+80); /* buffer = 96 bytes buffer for reading */
  fname = buffer + 96; /* fname = 80 bytes for final archive filename */

  /* read in the 'lead' of the RPM */
  READ(buffer, 96);

  /* create the archive name */
  strncpy(fname, (buffer[10]) ? buffer+10 : "unknown", 66);

  if (EndGetM16(buffer+6) == 1) strcat(fname, ".src");
  else {
    int arch = EndGetM16(buffer+8);
    if (arch >= 1 && arch <= 12) strcat(fname, RPM_arch[arch-1]);
  }
  strcat(fname, ".cpio");


  /* check file format version */
  version = buffer[4]; /* we support versions 2-4 only */
  if (version < 2 || version > 4) return XADERR_DATAFORMAT;

  /* check 'digital signature' version */
  switch (EndGetM16(buffer+78)) {
  case 0: /* no signature */
    break;

  case 1: /* fixed size signature */
    SKIP(256);
    break;

  case 5: /* another 'header' for the sig */
    READ(buffer, 8);
    if (EndGetM32(buffer) != 0x8EADE801) return XADERR_DATAFORMAT;
    /* read tag count and data area length, skip them and align to 8 bytes */
    READ(buffer, 8);
    SKIP(((16 * EndGetM32(buffer) + EndGetM32(buffer+4)) + 7) & -8);
    break;

  default: /* other versions not supported */
    return XADERR_DATAFORMAT;
  }

  /* normal header */
  if (version != 2) {
    READ(buffer, 8);
    if (EndGetM32(buffer) != 0x8EADE801) return XADERR_DATAFORMAT;
  }
  /* read tag count and data area length, skip them */
  READ(buffer, 8);
  SKIP(16 * EndGetM32(buffer) + EndGetM32(buffer+4));


  /* NOW GENERATE THE FILEINFO */

  filetags[0].ti_Data = namelen = strlen(fname) + 1;
  ALLOCOBJ(struct xadArchiveInfo *, ai2, XADOBJ_ARCHIVEINFO, NULL);
  ALLOCOBJ(struct xadFileInfo *, fi, XADOBJ_FILEINFO, filetags);
  ai->xai_FileInfo = fi;

  fi->xfi_EntryNumber = 1;
  fi->xfi_Size        = fi->xfi_CrunchSize = ai->xai_InSize - ai->xai_InPos;
  fi->xfi_DataPos     = ai->xai_InPos;
  fi->xfi_Flags       = XADFIF_SEEKDATAPOS | XADFIF_NODATE;

  /* copy name */
  xadCopyMem(fname, fi->xfi_FileName, namelen);

  /* fill in today's date */
  datetags[1].ti_Data = (ULONG) &fi->xfi_Date;
  xadConvertDatesA(datetags);
  
  /* call 'get info' on embedded archive for accurate filesizes */
  if (!xadGetInfoA(ai2, tags)) {
    struct xadFileInfo *fi2  = ai2->xai_FileInfo;
    if (fi2 && !fi2->xfi_Next) {
      /* get crunched and uncrunched size */
      fi->xfi_Size = fi2->xfi_Size;
      fi->xfi_CrunchSize = fi2->xfi_CrunchSize;

      /* copy the CRYPTED, NOUNCRUNCHSIZE and PARTIALFILE flags */
      fi->xfi_Flags |= fi2->xfi_Flags &
      (XADFIF_CRYPTED | XADFIF_NOUNCRUNCHSIZE | XADFIF_PARTIALFILE);
    }
    xadFreeInfo(ai2);
  }

exit_handler:
  if (ai2) FREE(ai2);
  if (buffer) FREE(buffer);
  return err;
}

ASM(LONG) RPM_UnArchive(REG(a0, struct xadArchiveInfo *ai), XADBASE) {
  struct xadArchiveInfo *ai2 = NULL;
  struct TagItem tags[5];
  LONG err, recog = 0;

  tags[0].ti_Tag  = XAD_ARCHIVEINFO;
  tags[0].ti_Data = (ULONG) ai;
  tags[2].ti_Tag  = XAD_INXADSTREAM;
  tags[2].ti_Data = (ULONG) tags;
  tags[1].ti_Tag  = tags[3].ti_Tag = TAG_DONE;

  ALLOCOBJ(struct xadArchiveInfo *, ai2, XADOBJ_ARCHIVEINFO, NULL);
  if (!(err = xadGetInfoA(ai2, &tags[2]))) {
    struct xadFileInfo *fi2  = ai2->xai_FileInfo;
    if (fi2 && !fi2->xfi_Next) {
      recog = 1;

      tags[2].ti_Tag  = XAD_OUTXADSTREAM; /* ti_Data is still &arcinfo tag */
      tags[3].ti_Tag  = XAD_ENTRYNUMBER;
      tags[3].ti_Data = ai2->xai_FileInfo->xfi_EntryNumber;
      tags[4].ti_Tag  = TAG_DONE;

      /* extract the first file */
      err = xadFileUnArcA(ai2, &tags[2]);
    }
    else err = XADERR_DATAFORMAT;
  }
  xadFreeInfo(ai2);

  /* if an error occured in 'extracting', try again 'copying' */
  if (err && recog) {
    SEEK(ai->xai_CurFile->xfi_DataPos);
    err = xadHookAccess(XADAC_COPY, ai->xai_CurFile->xfi_CrunchSize, NULL, ai);
  }

exit_handler:
  if (ai2) FREE(ai2);
  return err;
}


const struct xadClient RPM_Client = {
  NEXTCLIENT, XADCLIENT_VERSION, 8, RPM_VERSION, RPM_REVISION,
  4, XADCF_FILEARCHIVER|XADCF_FREEFILEINFO,
  0, "RPM",
  (BOOL (*)()) RPM_RecogData,
  (LONG (*)()) RPM_GetInfo,
  (LONG (*)()) RPM_UnArchive,
  NULL
};
