/*
 * windows.c
 * =========
 * Window utility functions.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include <intuition/imageclass.h>

#include <proto/graphics.h>
#include <proto/intuition.h>

#include "apputil.h"


VOID SetupWindowPosition(struct Screen *scr,
			 WORD scrWidth, WORD scrHeight,
			 WORD winWidth, WORD winHeight,
			 WORD *left, WORD *top,
			 WORD *zoomLeft, WORD *zoomTop) {
  ULONG modeID;
  struct Rectangle rect;

  if (*left == -1) {
    *left = 0;
    *top = 0;
    modeID = GetVPModeID(&(scr->ViewPort));
    if (modeID != INVALID_ID && QueryOverscan(modeID, &rect, OSCAN_TEXT)) {
      if (scr->LeftEdge < 0) {
	*left = -scr->LeftEdge;
      }
      if (scr->TopEdge < 0) {
	*top = -scr->TopEdge;
      }
      *left += (rect.MaxX - rect.MinX + 1 - winWidth) / 2;
      *top += (rect.MaxY - rect.MinY + 1 - winHeight) / 2;
    }
    *zoomLeft = *left;
    *zoomTop = *top;
  } else {
    if (scr->Width != scrWidth) {
      *left = (*left * scr->Width) / scrWidth;
      *zoomLeft = (*left * scr->Width) / scrWidth;
    }
    if (scr->Height != scrHeight) {
      *top = (*top * scr->Height) / scrHeight;
      *zoomTop = (*zoomTop * scr->Height) / scrHeight;
    }
  }
}


VOID TitleBarExtent(struct Screen *scr, STRPTR title,
		    WORD *width, WORD *height) {
  if (width != NULL) {
    struct DrawInfo *dri;
    struct Image *img;

    *width = TextLength(&scr->RastPort, title, (ULONG)strlen(title)) +
      2 * INTERWIDTH;
    dri = GetScreenDrawInfo(scr);
    img = (struct Image *)NewObject(NULL, "sysiclass",
				    SYSIA_DrawInfo, dri,
				    SYSIA_Which, CLOSEIMAGE,
				    TAG_DONE);
    if (img != NULL) {
      *width += img->Width;
      DisposeObject(img);
    } else {
      *width += 20;
    }
    img = (struct Image *)NewObject(NULL, "sysiclass",
				    SYSIA_DrawInfo, dri,
				    SYSIA_Which, ZOOMIMAGE,
				    TAG_DONE);
    if (img != NULL) {
      *width += img->Width;
      DisposeObject(img);
    } else {
      *width += 24;
    }
    img = (struct Image *)NewObject(NULL, "sysiclass",
				    SYSIA_DrawInfo, dri,
				    SYSIA_Which, DEPTHIMAGE,
				    TAG_DONE);
    if (img != NULL) {
      *width += img->Width;
      DisposeObject(img);
    } else {
      *width += 24;
    }
  }

  if (height != NULL) {
    *height = scr->WBorTop + scr->Font->ta_YSize + 1;
  }
}
