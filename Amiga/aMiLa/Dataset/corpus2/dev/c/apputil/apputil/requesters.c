/*
 * requesters.c
 * ============
 * Requester utility functions.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include <intuition/intuitionbase.h>

#include <proto/intuition.h>

#include "apputil.h"


static UWORD __chip BUSY_POINTER[] = {
  0x0000, 0x0000,
  0x0400, 0x07C0,
  0x0000, 0x07C0,
  0x0100, 0x0380,
  0x0000, 0x07E0,
  0x07C0, 0x1FF8,
  0x1FF0, 0x3FEC,
  0x3FF8, 0x7FDE,
  0x3FF8, 0x7FBE,
  0x7FFC, 0xFF7F,
  0x7EFC, 0xFFFF,
  0x7FFC, 0xFFFF,
  0x3FF8, 0x7FFE,
  0x3FF8, 0x7FFE,
  0x1FF0, 0x3FFC,
  0x07C0, 0x1FF8,
  0x0000, 0x07E0,
  0x0000, 0x0000,
};


BOOL BlockWindow(struct Window *win, struct Requester *req) {
  if (win != NULL && req != NULL) {
    InitRequester(req);
    if (Request(req, win)) {
      if (IntuitionBase->LibNode.lib_Version >= 39L) {
	SetWindowPointer(win, WA_BusyPointer, TRUE, TAG_DONE);
      } else {
	SetPointer(win, BUSY_POINTER, 16, 16, -6, 0);
      }

      return TRUE;
    }
  }

  return FALSE;
}


VOID UnblockWindow(struct Window *win, struct Requester *req) {
  if (IntuitionBase->LibNode.lib_Version >= 39L) {
    SetWindowPointerA(win, NULL);
  } else {
    ClearPointer(win);
  }
  EndRequest(req, win);
}


LONG MessageRequesterA(struct Window *win, STRPTR title,
		       STRPTR textFmt, STRPTR gadFmt, APTR argList) {
  struct EasyStruct es;
  struct Window *reqWin;
  struct Requester req;
  BOOL blocking;
  LONG retval;

  es.es_StructSize = sizeof es;
  es.es_Flags = 0;
  es.es_Title = title;
  es.es_TextFormat = textFmt;
  es.es_GadgetFormat = gadFmt;

  reqWin = BuildEasyRequestArgs(win, &es, NULL, argList);
  if (win != NULL) {
    blocking = BlockWindow(win, &req);
  } else {
    blocking = FALSE;
  }
  while ((retval = SysReqHandler(reqWin, NULL, TRUE)) == -2) {
  }
  if (blocking) {
    UnblockWindow(win, &req);
  }
  FreeSysRequest(reqWin);

  return retval;
}


LONG MessageRequester(struct Window *win, STRPTR title,
		      STRPTR textFmt, STRPTR gadFmt, APTR arg, ...) {
  return MessageRequesterA(win, title, textFmt, gadFmt, &arg);
}
