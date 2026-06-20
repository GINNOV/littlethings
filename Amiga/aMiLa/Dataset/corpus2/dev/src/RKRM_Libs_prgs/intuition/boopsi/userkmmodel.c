;/* UseRKMModel.c - Execute me to compile me with Lattice 5.10b
LC -b1 -cfistq -v -y -j73 UseRKMModel.c
Blink FROM LIB:c.o,UseRKMModel.o TO UseRKMModel LIBRARY LIB:LC.lib,LIB:Amiga.lib,RKMModel.o
quit
*/

/*
Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/


#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <intuition/classes.h>
#include <intuition/icclass.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <stdio.h>

#include "RKMModel.h"

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }
#endif

#define PROPID              1L
#define INTEGERID           2L
#define RIGHTID             3L
#define LEFTID              4L
#define PROPWIDTH           80L
#define PROPHEIGHT          10L
#define INTWIDTH            50L
#define INTHEIGHT           14L
#define VISIBLE             10L
#define TOTAL               100L
#define INITIALVAL          25L
#define MINWINDOWWIDTH      80
#define MINWINDOWHEIGHT     (PROPGADGETHEIGHT + 70)
#define MAXCHARS            4L

UBYTE *vers = "\0$VER: UseRKMModel 37.1";

BOOL MakeGadgetsAndRKMModel(void);



struct TagItem go2rkmmodel[] = {
    {PGA_Top, RKMMOD_CurrVal},
    {STRINGA_LongVal, RKMMOD_CurrVal},
    {TAG_END,}
};

struct TagItem right2rkmmodel[] = {
    {GA_ID, RKMMOD_Up},
    {TAG_END,}
};

struct TagItem left2rkmmodel[] = {
    {GA_ID, RKMMOD_Down},
    {TAG_END,}
};

struct TagItem mapcurrval2prop[] = {
    {RKMMOD_CurrVal, PGA_Top},
    {TAG_END,}
};

struct TagItem mapcurrval2int[] = {
    {RKMMOD_CurrVal, STRINGA_LongVal},
    {TAG_END,}
};



struct Library *IntuitionBase, *UtilityBase;
struct Window *w;
struct DrawInfo *mydrawinfo;

Class *rkmmodcl;
Object *rkmmodel, *currval2int, *currval2prop;
struct Gadget *prop, *integer, *leftbut, *rightbut;
struct Image *rightimage, *leftimage;

struct IntuiMessage *msg;

void main(void)
{
    BOOL done = FALSE;
        ULONG qwe;


    if (IntuitionBase = OpenLibrary("intuition.library", 37L))
    {
        if (UtilityBase = OpenLibrary("utility.library", 37L))
        {
            if (w = OpenWindowTags(NULL,
                WA_Flags,       WFLG_DEPTHGADGET | WFLG_DRAGBAR |
                                    WFLG_CLOSEGADGET | WFLG_SIZEGADGET,
                WA_IDCMP,       IDCMP_CLOSEWINDOW,
                TAG_END))
            {
                if (rkmmodcl = initRKMModClass())
                {
                    if (mydrawinfo = GetScreenDrawInfo(w->WScreen))
                    {
                        if (MakeGadgetsAndRKMModel())
                        {
                            DoMethod(rkmmodel, OM_ADDMEMBER, currval2prop);
                            DoMethod(rkmmodel, OM_ADDMEMBER, currval2int);

                            WindowLimits(w,(LONG)(w->BorderLeft + w->BorderRight)
                                    + integer->LeftEdge + integer->Width + 10L,
                                (LONG)(w->BorderTop + w->BorderBottom)
                                    + prop->Height+10L,
                                w->MaxWidth,
                                w->MaxHeight);

                            AddGList(w, prop, -1, -1, NULL);
                            RefreshGadgets(prop, w, NULL);

        GetAttr(RKMMOD_CurrVal, rkmmodel, &qwe);
        printf("RKMMOD_CurrVal = %ld\n", qwe);
        Delay(200);

        if (SetAttrs(rkmmodel, RKMMOD_CurrVal, 10L, TAG_DONE))
        {
                RefreshGadgets(prop, w, NULL);
        }
        GetAttr(RKMMOD_CurrVal, rkmmodel, &qwe);
        printf("RKMMOD_CurrVal = %ld\n", qwe);
        Delay(200);

        if (SetAttrs(rkmmodel, RKMMOD_CurrVal, 30L, TAG_DONE))
        {
                RefreshGadgets(prop, w, NULL);
        }
        GetAttr(RKMMOD_CurrVal, rkmmodel, &qwe);
        printf("RKMMOD_CurrVal = %ld\n", qwe);
        Delay(200);

        if (SetAttrs(rkmmodel, RKMMOD_CurrVal, 50L, TAG_DONE))
        {
                RefreshGadgets(prop, w, NULL);
        }
        GetAttr(RKMMOD_CurrVal, rkmmodel, &qwe);
        printf("RKMMOD_CurrVal = %ld\n", qwe);
        Delay(200);

        if (SetAttrs(rkmmodel, RKMMOD_Up, 1L, TAG_DONE))
        {
                RefreshGadgets(prop, w, NULL);
        }


                            /* Wait for the user to click window close gadget. */
                            while (done == FALSE)
                            {
                                WaitPort((struct MsgPort *)w->UserPort);
                                while (msg = (struct IntuiMessage *)
                                   GetMsg((struct MsgPort *)w->UserPort))
                                {
                                    if (msg->Class == IDCMP_CLOSEWINDOW)
                                    {
                                        done = TRUE;
                                    }
                                    ReplyMsg(msg);
                                }
                            }
                            RemoveGList(w, prop, -1);

                            DisposeObject(rightimage);
                            DisposeObject(leftimage);
                            DisposeObject(rkmmodel);
                            DisposeObject(prop);
                            DisposeObject(integer);
                            DisposeObject(leftbut);
                            DisposeObject(rightbut);
                        }
                        FreeScreenDrawInfo(w->WScreen, mydrawinfo);
                    }
                    freeRKMModClass(rkmmodcl);
                }
                CloseWindow(w);
            }
            CloseLibrary(UtilityBase);
        }
        CloseLibrary(IntuitionBase);
    }
}



BOOL MakeGadgetsAndRKMModel(void)
{
    WORD x = 9;

    if (rightimage = (struct Image *)NewObject(NULL, "sysiclass",
        SYSIA_Which,    RIGHTIMAGE,
        SYSIA_DrawInfo, mydrawinfo,
        TAG_END))
    {
        x--;
        if (leftimage = (struct Image *)NewObject(NULL, "sysiclass",
            SYSIA_Which,    LEFTIMAGE,
            SYSIA_DrawInfo, mydrawinfo,
            TAG_END))
        {
            x--;
            if (rkmmodel = NewObject(rkmmodcl, NULL,
                RKMMOD_CurrVal, INITIALVAL,
                RKMMOD_Limit,   (TOTAL - VISIBLE),
                TAG_END))
            {
                x--;
                if (prop = (struct Gadget *)NewObject(NULL, "propgclass",
                    GA_ID,          PROPID,
                    GA_Top,         (w->BorderTop) + 5L,
                    GA_Left,        (w->BorderLeft) + 5L,
                    GA_Width,       PROPWIDTH,
                    GA_Height,      PROPHEIGHT,
                    ICA_MAP,        go2rkmmodel,
                    ICA_TARGET,     rkmmodel,
                    PGA_Freedom,    FREEHORIZ,
                    PGA_Total,      TOTAL,
                    PGA_Top,        INITIALVAL,
                    PGA_Visible,    VISIBLE,
                    PGA_NewLook,    TRUE,
                    TAG_END))

                {
                    x--;
                    if (integer = (struct Gadget *)NewObject(NULL, "strgclass",
                        GA_ID,              INTEGERID,
                        GA_Top,             (w->BorderTop) + 5L,
                        GA_Left,            prop->LeftEdge + prop->Width + 48L,
                        GA_Width,           INTWIDTH,
                        GA_Height,          INTHEIGHT,
                        ICA_MAP,            go2rkmmodel,
                        ICA_TARGET,         rkmmodel,
                        GA_Previous,        prop,
                        STRINGA_LongVal,    INITIALVAL,
                        STRINGA_MaxChars,   MAXCHARS,
                        TAG_END))
                    {
                        x--;
                        if (leftbut = (struct Gadget *)NewObject(NULL,
                            "buttongclass",
                            GA_ID,              LEFTID,
                            GA_Image,           leftimage,
                            GA_Top,             (w->BorderTop) +  5L,
                            GA_Left,            prop->LeftEdge + prop->Width,
                            ICA_MAP,            left2rkmmodel,
                            ICA_TARGET,         rkmmodel,
                            GA_Previous,        integer,
                            TAG_END))
                        {
                            x--;
                            if (rightbut = (struct Gadget *)NewObject(NULL,
                                "buttongclass",
                                GA_ID,        RIGHTID,
                                GA_Image,    rightimage,
                                GA_Top,      (w->BorderTop) +  5L,
                                GA_Left,     prop->LeftEdge + prop->Width
                                                 + leftbut->Width,
                                ICA_MAP,     right2rkmmodel,
                                ICA_TARGET,  rkmmodel,
                                GA_Previous, leftbut,
                                TAG_END))
                            {
                                x--;
                                if (currval2prop = NewObject(NULL, "icclass",
                                    ICA_MAP,    mapcurrval2prop,
                                    ICA_TARGET, prop,
                                    TAG_END))
                                {
                                    x--;
                                    if (currval2int = NewObject(NULL, "icclass",
                                        ICA_MAP,    mapcurrval2int,
                                        ICA_TARGET, integer,
                                        TAG_END))
                                    {
                                        x--;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    switch (x)
    {
        case 0:
            return((BOOL)TRUE);
        case 1:
            DisposeObject(currval2prop);
        case 2:
            DisposeObject(rightbut);
        case 3:
            DisposeObject(leftbut);
        case 4:
            DisposeObject(integer);
        case 5:
            DisposeObject(prop);
        case 6:
            DisposeObject(rkmmodel);
        case 7:
            DisposeObject(leftimage);
        case 8:
            DisposeObject(rightimage);
    }
    return((BOOL)FALSE);
}
