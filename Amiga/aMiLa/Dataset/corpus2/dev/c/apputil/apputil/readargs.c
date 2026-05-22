/*
 * readargs.c
 * ==========
 * Functions for parsing command line arguments and WB ToolTypes.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include <exec/memory.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/icon.h>

#include "apputil.h"


static struct Library *iconBase;

#define IconBase iconBase


static BOOL FullName(struct WBArg *wa, STRPTR buf, LONG len) {
  if (len == 0) {
    return FALSE;
  }

  if (NameFromLock(wa->wa_Lock, buf, len)) {
    if (AddPart(buf, wa->wa_Name, len)) {
      return TRUE;
    } else {
      SetIoErr(ERROR_LINE_TOO_LONG);
    }
  }

  return FALSE;
}


static BOOL AddToolTypes(struct WBArg *wa, STRPTR *buf, LONG *len) {
  BPTR oldLock = -1;
  struct DiskObject *diskObj;
  STRPTR *tt;
  STRPTR str, pos;
  BOOL success = FALSE;

  if (wa->wa_Lock != NULL) {
    oldLock = CurrentDir(wa->wa_Lock);
  }

  iconBase = OpenLibrary("icon.library", 33L);
  if (iconBase != NULL) {
    diskObj = GetDiskObject(wa->wa_Name);
    if (diskObj != NULL) {
      *len = 0;
      for (tt = diskObj->do_ToolTypes; *tt != NULL; tt++) {
	if (**tt != '(') {
	  *len += strlen(*tt) + 1;
	}
      }

      if (*len > 0) {
	*buf = AllocVec((*len + 1) * sizeof **buf, MEMF_PUBLIC);
	if (*buf != NULL) {
	  pos = *buf;
	  for (tt = diskObj->do_ToolTypes; *tt != NULL; tt++) {
	    for (str = *tt; *str != '\0'; str++) {
	      *pos++ = (*str == '|') ? ' ' : *str;
	    }
	    *pos++ = ' ';
	  }
	  *(pos - 1) = '\0';
	  (*len)--;
	  success = TRUE;
	}
      } else {
	success = TRUE;
      }

      FreeDiskObject(diskObj);
    }
    CloseLibrary(iconBase);
  }

  if (oldLock != -1) {
    CurrentDir(oldLock);
  }

  return success;
}


static BOOL AddFiles(struct WBArg *wa, LONG n, STRPTR *buf, LONG *len) {
  STRPTR tmp, pos;
  LONG bufSize, remSize;
  LONG i;

  if (n == 0) {
    return TRUE;
  }

#define BUFBLOCK 256
  bufSize = BUFBLOCK + *len;
  remSize = BUFBLOCK;
#undef BUFBLOCK
  tmp = AllocVec(bufSize * sizeof *tmp, MEMF_PUBLIC);
  if (tmp == NULL) {
    return FALSE;
  }

  if (*buf != NULL) {
    CopyMem(*buf, tmp, *len);
    FreeVec(*buf);
    (*len)++;
    pos = tmp + *len;
    *(pos - 1) = ' ';
    remSize--;
  } else {
    *len = 0;
    pos = tmp;
  }

  *buf = tmp;
  for (i = 0; i < n; i++) {
    while (!FullName(wa + i, pos, remSize - 1)) {
      if (IoErr() == ERROR_LINE_TOO_LONG) {
	remSize += bufSize;
	bufSize *= 2;
	tmp = AllocVec(bufSize * sizeof *tmp, MEMF_PUBLIC);
	if (tmp == NULL) {
	  return FALSE;
	}

	CopyMem(*buf, tmp, *len);
	FreeVec(*buf);
	*buf = tmp;
      } else {
	return FALSE;
      }
    }
    *len += strlen(pos) + 1;
    pos = *buf + *len;
    remSize = bufSize - *len;
    *(pos - 1) = ' ';
  }
  *(pos - 1) = '\0';
  (*len)--;

  return TRUE;
}


struct RDArgs *ReadArgsCLI(STRPTR template, LONG *array) {
  struct RDArgs *rdargs;

  rdargs = AllocDosObject(DOS_RDARGS, NULL);
  if (rdargs != NULL) {
    rdargs->RDA_Source.CS_Buffer = NULL;
    rdargs->RDA_DAList = NULL;
    rdargs->RDA_Buffer = NULL;
    rdargs->RDA_Flags = 0;
    ReadArgs(template, array, rdargs);
  }

  return rdargs;
}


struct RDArgs *ReadArgsWB(STRPTR template, LONG *array,
			  struct WBStartup *sm) {
  STRPTR buf = NULL;
  LONG len = 0;
  struct RDArgs *rdargs = NULL;

  if (AddToolTypes(sm->sm_ArgList, &buf, &len) &&
      AddFiles(sm->sm_ArgList + 1, sm->sm_NumArgs - 1, &buf, &len)) {
    if (buf != NULL) {
      rdargs = AllocDosObject(DOS_RDARGS, NULL);
      if (rdargs != NULL) {
	buf[len] = '\n';
	buf[len + 1] = '\0';
	rdargs->RDA_Source.CS_Buffer = buf;
	rdargs->RDA_Source.CS_Length = len + 1;
	rdargs->RDA_Source.CS_CurChr = 0;
	rdargs->RDA_DAList = NULL;
	rdargs->RDA_Buffer = NULL;
	rdargs->RDA_Flags = RDAF_NOPROMPT;
	ReadArgs(template, array, rdargs);
      }
    }
  }
  FreeVec(buf);

  return rdargs;
}


VOID FreeArgsCLIWB(struct RDArgs *rdargs) {
  if (rdargs != NULL) {
    FreeArgs(rdargs);
    FreeDosObject(DOS_RDARGS, rdargs);
  }
}
