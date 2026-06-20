/*
 * gadgets.c
 * =========
 * Gadget utility functions.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include <intuition/gadgetclass.h>

#include <clib/alib_protos.h>
#include <proto/graphics.h>

#include "apputil.h"


static VOID EraseGadget(struct RastPort *rp, struct Gadget *gad) {
  if (gad->Width > 0 && gad->Height > 0) {
    EraseRect(rp, (LONG)gad->LeftEdge, (LONG)gad->TopEdge,
	      (LONG)gad->LeftEdge + gad->Width - 1,
	      (LONG)gad->TopEdge + gad->Height - 1);
  }
}


VOID EraseGadgets(struct Gadget *gads, struct Window *win,
		  struct Requester *req) {
  struct RastPort *rp;
  struct Gadget *gad;

  if (win != NULL) {
    rp = win->RPort;
  } else {
    rp = req->RWindow->RPort;
  }
  for (gad = gads; gad != NULL; gad = gad->NextGadget) {
    EraseGadget(rp, gad);
  }
}


VOID EraseGList(struct Gadget *gads, struct Window *win,
		struct Requester *req, LONG numGads) {
  if (numGads == -1) {
    EraseGadgets(gads, win, req);
  } else {
    struct RastPort *rp;
    struct Gadget *gad;
    LONG i;

    if (win != NULL) {
      rp = win->RPort;
    } else {
      rp = req->RWindow->RPort;
    }
    for (gad = gads, i = 0; gad != NULL && i < numGads;
	 gad = gad->NextGadget, i++) {
      EraseGadget(rp, gad);
    }
  }
}


BOOL PointInGadget(ULONG point, struct Gadget *gad) {
  WORD x = (point >> 16L) - gad->LeftEdge;
  WORD y = (point & 0xFFFF) - gad->TopEdge;

  if (gad->GadgetType & GTYP_CUSTOMGADGET) {
    return (BOOL)(GMR_GADGETHIT ==
		  DoMethod((Object *)gad, GM_HITTEST, NULL, (x << 16L) + y));
  } else {
    return (BOOL)(x >= 0 && y >= 0 && x < gad->Width && y < gad->Height);
  }
}
