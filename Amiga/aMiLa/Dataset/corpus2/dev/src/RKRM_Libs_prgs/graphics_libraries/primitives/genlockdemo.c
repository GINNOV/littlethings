;/* genlockdemo.c - Genlock VideoControl example.
LC -b1 -cfist -v -j73 genlockdemo.c
Blink FROM LIB:c.o,genlockdemo.o TO genlockdemo LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit


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
#include <exec/memory.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/displayinfo.h>
#include <graphics/VideoControl.h>
#include <graphics/view.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <libraries/gadtools.h>

#include <clib/alib_stdio_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>

#define INTUITIONNAME "intuition.library" /* intuitionbase.h does not define a library name. */
#define GADTOOLSNAME "gadtools.library" /* gadtools.h does not define a library name. */

/* Some gadget ID's */
#define BORDERBLANK_ID          16
#define BORDERNOTRANS_ID        17
#define BITPLANEKEY_ID          18
#define CHROMAPLANE_ID          19
#define CHROMAKEY_ID            20

/* Some protos */
VOID main(int argc, char **argv);
BOOL CheckPAL(STRPTR);
UWORD strlen(STRPTR);

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *GadToolsBase;


/* Give me 3D look window (I'll use a quiet screen */
static UWORD dri_Pens[] =
{
        0, 1, 1, 2, 1, 3, 1, 0, 3, ~0};

/* Just a demo, set everything to topaz 80. */
static struct TextAttr Topaz80 = {
        "topaz.font", 8, 0, 0,};

/* strings for cycle gadget */
static STRPTR ChPlaneText[] = {
        "Plane 0", "Plane 1", "Plane 2", "Plane 3", NULL};

struct EasyStruct failedES = {
        sizeof(struct EasyStruct), 0, "GenlockDemo", "%s", "Continue",};

VOID main(int argc, char **argv)
{
        struct Screen *genscreen;
        struct Window *controlwindow;
        struct Gadget *glist, *gadget, *hitgadget;
        struct ViewPort *vp;
        struct View *viewlord;
        void *vi;
        struct NewGadget ng;
        struct IntuiMessage *imsg;
        struct TagItem vtags[24];
        ULONG GadgetPtrs[21];
        ULONG iclass, icode;
        STRPTR gtextbuffer, gtextptr;
        UWORD i, j;
        BOOL ABORT = FALSE;
        BOOL IsPAL;

        /* Fails silently if < V37 */
        if (IntuitionBase = OpenLibrary(INTUITIONNAME, 37L)) 
        {
                if (GfxBase = (struct GfxBase *) OpenLibrary(GRAPHICSNAME, 37L)) 
                {
                        if (GadToolsBase = OpenLibrary(GADTOOLSNAME, 37L)) 
                        {
                                if (GfxBase->ChipRevBits0 & GFXF_HR_DENISE) 
                                {
                                        /* Check if the user happens to prefer PAL or if this is a true PAL System. */
                                        IsPAL = CheckPAL("Workbench");
                                        /* buffer for some gadget text */
                                        if (gtextbuffer = AllocMem(256, MEMF_CLEAR)) 
                                        {
                                                gtextptr = gtextbuffer;

                                                /* Open a 'standard' HIRES screen */
                                                if (genscreen = OpenScreenTags(NULL, SA_Pens, (ULONG) dri_Pens,
                                                SA_DisplayID, HIRES_KEY,
                                                SA_Depth, 4,
                                                /* Give me a lot of border */
                                                SA_Width, 640,
                                                SA_Height, (IsPAL) ? 256 : 200,
                                                SA_Overscan, 0,
                                                /* Hold the titlebar, please */
                                                SA_Quiet, TRUE,
                                                /* Give me sysfont 0 as default rastport font. */
                                                SA_SysFont, 1,
                                                TAG_DONE)) 
                                                {

                                                        /* Blast some colorbars in screen's rastport, leave some color 0 gaps */
                                                        for (i = 0, j = 0; i < 16; i++, j += 40) 
                                                        {
                                                                SetAPen(&(genscreen->RastPort), i);
                                                                RectFill(&(genscreen->RastPort), (j + 1), 0, (j + 30), (IsPAL) ? 255 : 199);

                                                        }
                                                        /* A line to show where borders start */
                                                        SetAPen(&(genscreen->RastPort), 5);
                                                        Move(&(genscreen->RastPort),0,0);
                                                        Draw(&(genscreen->RastPort),genscreen->Width-1,0);
                                                        Draw(&(genscreen->RastPort),genscreen->Width-1,genscreen->Height-1);
                                                        Draw(&(genscreen->RastPort),0,genscreen->Height-1);
                                                        Draw(&(genscreen->RastPort),0,0);

                                                        /* Open a restricted window, no draggin, sizing, just closing.
                                                                                                         * (don't want to refresh screen)
                                                                                                         */
                                                        if (controlwindow = OpenWindowTags(NULL, WA_Title, (ULONG) "VideoControl",
                                                        WA_Left, 210,
                                                        WA_Top, 20,
                                                        WA_Width, 220,
                                                        WA_Height, 150,
                                                        WA_CustomScreen, genscreen,
                                                        WA_Flags, WFLG_CLOSEGADGET | WFLG_ACTIVATE | WFLG_NOCAREREFRESH,
                                                        WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_GADGETUP,
                                                        TAG_DONE)) {

                                                                /* Ok, got a window, lets make some gadgets */
                                                                if (vi = GetVisualInfo(genscreen, TAG_END)) 
                                                                {
                                                                        if (gadget = CreateContext(&glist)) 
                                                                        {
                                                                                ng.ng_TextAttr = &Topaz80;
                                                                                ng.ng_VisualInfo = vi;
                                                                                ng.ng_Flags = PLACETEXT_LEFT | NG_HIGHLABEL;

                                                                                ng.ng_LeftEdge = controlwindow->BorderLeft + 120;
                                                                                ng.ng_TopEdge = controlwindow->BorderTop + 2;
                                                                                ng.ng_Width = 12;
                                                                                ng.ng_Height = 12;
                                                                                ng.ng_GadgetText = "BORDERBLANK";
                                                                                ng.ng_GadgetID = BORDERBLANK_ID;
                                                                                gadget = CreateGadget(CHECKBOX_KIND, gadget, &ng, TAG_END);
                                                                                GadgetPtrs[BORDERBLANK_ID] = (ULONG) gadget;

                                                                                ng.ng_TopEdge += gadget->Height + 2;
                                                                                ng.ng_GadgetText = "BORDERNOTRANS";
                                                                                ng.ng_GadgetID = BORDERNOTRANS_ID;
                                                                                gadget = CreateGadget(CHECKBOX_KIND, gadget, &ng, TAG_END);
                                                                                GadgetPtrs[BORDERNOTRANS_ID] = (ULONG) gadget;

                                                                                ng.ng_TopEdge += gadget->Height + 2;
                                                                                ng.ng_GadgetText = "CHROMAKEY";
                                                                                ng.ng_GadgetID = CHROMAKEY_ID;
                                                                                gadget = CreateGadget(CHECKBOX_KIND, gadget, &ng, TAG_END);
                                                                                GadgetPtrs[CHROMAKEY_ID] = (ULONG) gadget;

                                                                                ng.ng_TopEdge += gadget->Height + 2;
                                                                                ng.ng_GadgetText = "BITPLANEKEY";
                                                                                ng.ng_GadgetID = BITPLANEKEY_ID;
                                                                                gadget = CreateGadget(CHECKBOX_KIND, gadget, &ng, TAG_END);
                                                                                GadgetPtrs[BITPLANEKEY_ID] = (ULONG) gadget;

                                                                                ng.ng_TopEdge += gadget->Height + 2;
                                                                                ng.ng_Width = 90;
                                                                                ng.ng_GadgetText = "CHROMAPLANE";
                                                                                ng.ng_GadgetID = CHROMAPLANE_ID;
                                                                                gadget = CreateGadget(CYCLE_KIND, gadget, &ng, GTCY_Labels, (ULONG) ChPlaneText, TAG_END);
                                                                                GadgetPtrs[CHROMAPLANE_ID] = (ULONG) gadget;

                                                                                ng.ng_TopEdge += gadget->Height + 20;
                                                                                ng.ng_Width = 12;
                                                                                ng.ng_Flags = PLACETEXT_ABOVE | NG_HIGHLABEL;
                                                                                for (j = 0; j < 2; j++) 
                                                                                {
                                                                                        for (i = 0; i < 8; i++) 
                                                                                        {
                                                                                                ng.ng_LeftEdge = controlwindow->BorderLeft + 2 + (i * gadget->Width);
                                                                                                sprintf(gtextptr, "%ld", i + (j * 8));
                                                                                                ng.ng_GadgetText = gtextptr;
                                                                                                ng.ng_GadgetID = i + (j * 8);
                                                                                                gadget = CreateGadget(CHECKBOX_KIND, gadget, &ng, TAG_END);
                                                                                                GadgetPtrs[i] = (ULONG) gadget;
                                                                                                gtextptr += strlen(gtextptr) + 1;
                                                                                        }
                                                                                        ng.ng_TopEdge += gadget->Height;
                                                                                        ng.ng_Flags = PLACETEXT_BELOW | NG_HIGHLABEL;
                                                                                }
                                                                                AddGList(controlwindow, glist, -1, -1, NULL);
                                                                                RefreshGList(glist, controlwindow, NULL, -1);
                                                                                GT_RefreshWindow(controlwindow, NULL);

                                                                                /* Finally, a window with some gadgets...
                                                                                 *
                                                                                 * Get the current genlock state.
                                                                                 * Obviously I already know what the settings will be (all off),
                                                                                 * since I opened the screen myself. Do it just to show how to get them.
                                                                                 */

                                                                                vp = &(genscreen->ViewPort);

                                                                                /* Is borderblanking on? */
                                                                                vtags[0].ti_Tag = VTAG_BORDERBLANK_GET;
                                                                                vtags[0].ti_Data = NULL;
                                                                                /* Is bordertransparent set */
                                                                                vtags[1].ti_Tag = VTAG_BORDERNOTRANS_GET;
                                                                                vtags[1].ti_Data = NULL;
                                                                                /* Key on bitplane? */
                                                                                vtags[2].ti_Tag = VTAG_BITPLANEKEY_GET;
                                                                                vtags[2].ti_Tag = NULL;
                                                                                /* Get plane which is used to key on */
                                                                                vtags[3].ti_Tag = VTAG_CHROMA_PLANE_GET;
                                                                                vtags[3].ti_Data = NULL;
                                                                                /* Chromakey overlay on? */
                                                                                vtags[4].ti_Tag = VTAG_CHROMAKEY_GET;
                                                                                vtags[4].ti_Data = NULL;

                                                                                for (i = 0; i < 16; i++) 
                                                                                {
                                                                                        /* Find out which colors overlay */
                                                                                        vtags[i + 5].ti_Tag = VTAG_CHROMA_PEN_GET;
                                                                                        vtags[i + 5].ti_Data = i;
                                                                                }

                                                                                /* Indicate end of tag array */
                                                                                vtags[21].ti_Tag = VTAG_END_CM;
                                                                                vtags[21].ti_Data = NULL;

                                                                                /* And send the commands. On return the Tags themself will
                                                                                                                                                         * indicate the genlock settings for this ViewPort's ColorMap.
                                                                                                                                                         */
                                                                                VideoControl(vp->ColorMap, vtags);

                                                                                /* And initialize gadgets, according to genlock settings */
                                                                                if (vtags[0].ti_Tag == VTAG_BORDERBLANK_SET)
                                                                                        GT_SetGadgetAttrs((struct Gadget *) GadgetPtrs[BORDERBLANK_ID], controlwindow, NULL, GTCB_Checked, TRUE, TAG_DONE);
                                                                                if (vtags[1].ti_Tag == VTAG_BORDERNOTRANS_SET)
                                                                                        GT_SetGadgetAttrs((struct Gadget *) GadgetPtrs[BORDERNOTRANS_ID], controlwindow, NULL, GTCB_Checked, TRUE, TAG_DONE);
                                                                                if (vtags[2].ti_Tag == VTAG_BITPLANEKEY_SET)
                                                                                        GT_SetGadgetAttrs((struct Gadget *) GadgetPtrs[BITPLANEKEY_ID], controlwindow, NULL, GTCB_Checked, TRUE, TAG_DONE);
                                                                                if (vtags[3].ti_Tag == VTAG_CHROMA_PLANE_SET)
                                                                                        GT_SetGadgetAttrs((struct Gadget *) GadgetPtrs[CHROMAPLANE_ID], controlwindow, NULL, GTCY_Active, vtags[3].ti_Data, TAG_DONE);
                                                                                if (vtags[4].ti_Tag == VTAG_CHROMAKEY_SET)
                                                                                        GT_SetGadgetAttrs((struct Gadget *) GadgetPtrs[CHROMAKEY_ID], controlwindow, NULL, GTCB_Checked, TRUE, TAG_DONE);
                                                                                for (i = 0; i < 16; i++) 
                                                                                {
                                                                                        if (vtags[i + 5].ti_Tag == VTAG_CHROMA_PEN_SET)
                                                                                                GT_SetGadgetAttrs((struct Gadget *) GadgetPtrs[i], controlwindow, NULL, GTCB_Checked, TRUE);
                                                                                }

                                                                                /* Will only send single commands from here on. */
                                                                                vtags[1].ti_Tag = VTAG_END_CM;

                                                                                /* Get user input. */
                                                                                do 
                                                                                {
                                                                                        WaitPort(controlwindow->UserPort);
                                                                                        while (imsg = GT_GetIMsg(controlwindow->UserPort)) {
                                                                                                iclass = imsg->Class;
                                                                                                icode = imsg->Code;
                                                                                                hitgadget = (struct Gadget *) imsg->IAddress;
                                                                                                GT_ReplyIMsg(imsg);

                                                                                                switch (iclass) 
                                                                                                {
                                                                                                case GADGETUP:
                                                                                                        if (hitgadget->GadgetID < 16) 
                                                                                                        {
                                                                                                                /* Set colorkey */
                                                                                                                if (hitgadget->Flags & SELECTED)
                                                                                                                        vtags[0].ti_Tag = VTAG_CHROMA_PEN_SET;
                                                                                                                /* Clear colorkey */
                                                                                                                else
                                                                                                                        vtags[0].ti_Tag = VTAG_CHROMA_PEN_CLR;
                                                                                                                vtags[0].ti_Data = hitgadget->GadgetID;
                                                                                                        } 
                                                                                                        else 
                                                                                                        {
                                                                                                                switch (hitgadget->GadgetID) {
                                                                                                                case BORDERBLANK_ID:
                                                                                                                        /* Set borderblanking on */
                                                                                                                        if (hitgadget->Flags & SELECTED)
                                                                                                                                vtags[0].ti_Tag = VTAG_BORDERBLANK_SET;
                                                                                                                        /* Turn borderblanking off */
                                                                                                                        else
                                                                                                                                vtags[0].ti_Tag = VTAG_BORDERBLANK_CLR;
                                                                                                                        break;
                                                                                                                case BORDERNOTRANS_ID:
                                                                                                                        /* Set bordertransparency on */
                                                                                                                        if (hitgadget->Flags & SELECTED)
                                                                                                                                vtags[0].ti_Tag = VTAG_BORDERNOTRANS_SET;
                                                                                                                        /* Turn bordertransparency off */
                                                                                                                        else
                                                                                                                                vtags[0].ti_Tag = VTAG_BORDERNOTRANS_CLR;
                                                                                                                        break;
                                                                                                                case BITPLANEKEY_ID:
                                                                                                                        /* Key on current selected bitplane (chromaplane) */
                                                                                                                        if (hitgadget->Flags & SELECTED)
                                                                                                                                vtags[0].ti_Tag = VTAG_BITPLANEKEY_SET;
                                                                                                                        /* Turn bitplane keying off */
                                                                                                                        else
                                                                                                                                vtags[0].ti_Tag = VTAG_BITPLANEKEY_CLR;
                                                                                                                        break;
                                                                                                                case CHROMAPLANE_ID:
                                                                                                                        /* Set plane to key on */
                                                                                                                        vtags[0].ti_Tag = VTAG_CHROMA_PLANE_SET;
                                                                                                                        vtags[0].ti_Data = icode;
                                                                                                                        break;
                                                                                                                case CHROMAKEY_ID:
                                                                                                                        /* Set chromakey overlay on */
                                                                                                                        if (hitgadget->Flags & SELECTED)
                                                                                                                                vtags[0].ti_Tag = VTAG_CHROMAKEY_SET;
                                                                                                                        /* Turn chromakey overlay off */
                                                                                                                        else
                                                                                                                                vtags[0].ti_Tag = VTAG_CHROMAKEY_CLR;
                                                                                                                        break;
                                                                                                                }
                                                                                                        }

                                                                                                        /* send video command */
                                                                                                        VideoControl(vp->ColorMap, vtags);
                                                                                                        /* Get the View for this genlock screen. */
                                                                                                        viewlord = ViewAddress();
                                                                                                        /* And remake the viewport */
                                                                                                        MakeVPort(viewlord, vp);
                                                                                                        MrgCop(viewlord);
                                                                                                        LoadView(viewlord);
                                                                                                        break;

                                                                                                case CLOSEWINDOW:
                                                                                                        /* Get out of here */
                                                                                                        ABORT = TRUE;
                                                                                                        break;
                                                                                                }
                                                                                        }
                                                                                } 
                                                                                while (ABORT == FALSE);

                                                                                RemoveGList(controlwindow, glist, -1);
                                                                                FreeGadgets(glist);
                                                                        } 
                                                                        else
                                                                                EasyRequest(NULL, &failedES, NULL, "Can't create gadget context");
                                                                        FreeVisualInfo(vi);
                                                                } 
                                                                else
                                                                        EasyRequest(NULL, &failedES, NULL, "Can't get visual info");
                                                                CloseWindow(controlwindow);
                                                        } 
                                                        else
                                                                EasyRequest(NULL, &failedES, NULL, "Can't open window");
                                                        CloseScreen(genscreen);
                                                } 
                                                else
                                                        EasyRequest(NULL, &failedES, NULL, "Can't open screen");
                                                FreeMem(gtextbuffer, 256);
                                        } 
                                        else
                                                EasyRequest(NULL, &failedES, NULL, "Out of memory");
                                } 
                                else
                                        EasyRequest(NULL, &failedES, NULL, "Requires ECS");
								CloseLibrary(GadToolsBase);
                        }
						else
							if (argc)
								printf("%s: Unable to open %s\n", argv[0], GADTOOLSNAME);
						CloseLibrary((struct Library *) GfxBase);
                }
				else
					if (argc)
						printf("%s: Unable to open %s\n", argv[0], GRAPHICSNAME);
				CloseLibrary(IntuitionBase);
        }
		else
			if (argc)
				printf("%s: Unable to open %s\n", argv[0], INTUITIONNAME);
}






/* Generic routine to check for a PAL System.
 * CheckPAL returns TRUE, if the the videomode of the specified public screen (or default videmode)
 * is PAL.
 * If the screenname is NULL, the default public screen will be used.
 */


BOOL CheckPAL(STRPTR screenname)
{
        struct Screen *screen;
        ULONG modeID = LORES_KEY;
        struct DisplayInfo displayinfo;
        BOOL IsPAL;

        if (GfxBase->LibNode.lib_Version >= 36) 
        {
        /*
         * We got V36, so lets use the new calls to find out what
         * kind of videomode the user (hopefully) prefers.
         */
    
            if (screen = LockPubScreen(screenname)) 
            {
                /*
                 * Use graphics.library/GetVPModeID() to get the ModeID of the specified screen.
                 * Will use the default public screen (Workbench most of the time) if NULL It is
                 * _very_ unlikely that this would be invalid, heck it's impossible.
                 */
                if ((modeID = GetVPModeID(&(screen->ViewPort))) != INVALID_ID) 
                {
                    /*
                     * If the screen is in VGA mode, we can't tell whether the system is PAL or NTSC. So
                     * to be fullproof we fall back to the displayinfo of the default.monitor by
                     * inquiring about just the LORES_KEY displaymode if we don't know. The
                     * default.monitor reflects the initial video setup of the system, thus is an alias
                     * for either ntsc.monitor or pal.monitor. We only use the displaymode of the
                     * specified public screen if it's display mode is PAL or NTSC and NOT the default.
                     */

                    if (!((modeID & MONITOR_ID_MASK) == NTSC_MONITOR_ID ||
                          (modeID & MONITOR_ID_MASK) == PAL_MONITOR_ID))
                        modeID = LORES_KEY;
                }
                UnlockPubScreen(NULL, screen);
            } /* if fails modeID = LORES_KEY. Can't lock screen, so fall back on default monitor. */
    
            if (GetDisplayInfoData(NULL, (UBYTE *) & displayinfo,
                sizeof(struct DisplayInfo), DTAG_DISP, modeID)) 
            {
                if (displayinfo.PropertyFlags & DIPF_IS_PAL)
                    IsPAL = TRUE;
                else
                    IsPAL = FALSE;  /* Currently the default monitor is always either
                                     * PAL or NTSC.
                                     */
            }
        } 
        else /* < V36. The enhancements to the videosystem in V36 cannot be better expressed than
                * with the simple way to determine PAL in V34.
                */
            IsPAL= (GfxBase->DisplayFlags & PAL) ? TRUE : FALSE;
    
        return(IsPAL);
}
    





