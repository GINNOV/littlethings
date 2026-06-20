/*
 * settings.c
 * ==========
 * Functions for loading and saving application settings.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include <exec/memory.h>

#include <clib/alib_stdio_protos.h>
#include <proto/dos.h>
#include <proto/exec.h>

#include "apputil.h"


static STRPTR settingsPath;


static BOOL SaveInEnv(BOOL arc, STRPTR basename, VOID *buf, LONG len) {
  BPTR lock;
  struct FileInfoBlock *fib;
  UBYTE filename[MAXBASENAMELEN + 8];
  BOOL success;

  sprintf(filename, "%s:%s", (arc ? "ENVARC" : "ENV"), basename);
  lock = Lock(filename, ACCESS_WRITE);
  if (lock == NULL) {
    if (IoErr() == ERROR_DIR_NOT_FOUND) {
      lock = CreateDir(filename);
    } else {
      return FALSE;
    }
  } else {
    fib = AllocDosObject(DOS_FIB, NULL);
    if (fib != NULL) {
      if (!Examine(lock, fib) || fib->fib_DirEntryType <= 0) {
	UnLock(lock);
	lock = NULL;
      }
      FreeDosObject(DOS_FIB, fib);
    } else {
      UnLock(lock);
      lock = NULL;
    }
  }

  if (lock != NULL) {
    lock = CurrentDir(lock);
    sprintf(filename, "%s.prefs", basename);
    success = SaveSettingsAs(filename, buf, len);
    UnLock(CurrentDir(lock));

    return success;
  } else {
    return FALSE;
  }
}


BOOL InitSettings(STRPTR path, STRPTR basename, VOID *buf, LONG len) {
  BPTR lock;
  UBYTE filename[2 * MAXBASENAMELEN + 12];
  BOOL success;

  if (strlen(basename) > MAXBASENAMELEN) {
    return FALSE;
  }

  if (path != NULL) {
    settingsPath = AllocVec((strlen(path) + 1L) * sizeof *settingsPath,
			    MEMF_PUBLIC);
    if (settingsPath != NULL) {
      strcpy(settingsPath, path);
    }
    success = LoadSettings(path, buf, len);
  } else {
    settingsPath = NULL;
    success = FALSE;
  }

  if (!success) {
    lock = GetProgramDir();
    if (lock != NULL) {
      lock = CurrentDir(lock);
      sprintf(filename, "%s.prefs", basename);
      success = LoadSettings(filename, buf, len);
      CurrentDir(lock);
    }
  }

  if (!success) {
    sprintf(filename, "ENV:%s/%s.prefs", basename, basename);
    return LoadSettings(filename, buf, len);
  } else {
    return TRUE;
  }
}


VOID DisposeSettings(VOID) {
  FreeVec(settingsPath);
}


BOOL LoadSettings(STRPTR path, VOID *buf, LONG len) {
  BPTR file;
  LONG n;

  file = Open(path, MODE_OLDFILE);
  if (file != NULL) {
    n = Read(file, buf, len);
    Close(file);

    return (BOOL)(n == len);
  } else {
    return FALSE;
  }
}


BOOL SaveSettings(STRPTR basename, VOID *buf, LONG len) {
  BPTR lock;
  UBYTE filename[2 * MAXBASENAMELEN + 12];
  BOOL success;

  if (strlen(basename) > MAXBASENAMELEN) {
    return FALSE;
  }

  if (settingsPath != NULL) {
    success = SaveSettingsAs(settingsPath, buf, len);
  } else {
    success = FALSE;
  }

  if (!success) {
    lock = GetProgramDir();
    if (lock != NULL) {
      lock = CurrentDir(lock);
      sprintf(filename, "%s.prefs", basename);
      success = SaveSettingsAs(filename, buf, len);
      CurrentDir(lock);
    }
  }

  if (!success) {
    SaveInEnv(FALSE, basename, buf, len);
    return SaveInEnv(TRUE, basename, buf, len);
  } else {
    return TRUE;
  }
}


BOOL SaveSettingsAs(STRPTR path, VOID *buf, LONG len) {
  BPTR file;
  LONG n;

  file = Open(path, MODE_NEWFILE);
  if (file != NULL) {
    n = Write(file, buf, len);
    Close(file);
    SetProtection(path, FIBF_EXECUTE);

    return (BOOL)(n == len);
  } else {
    return FALSE;
  }
}
