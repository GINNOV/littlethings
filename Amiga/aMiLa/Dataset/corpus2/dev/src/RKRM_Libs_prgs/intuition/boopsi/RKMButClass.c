;/* RKMButClass.c - Example Boopsi gadget for RKRM:Libraries
; Execute me to compile me with Lattice 5.10b
LC -b1 -d0 -cfistq -v -y -j73 RKMButClass.c
Blink FROM LIB:c.o,RKMButClass.o TO TestBut LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <intuition/cghooks.h>
#include <intuition/icclass.h>
#include <utility/tagitem.h>
#include <utility/hooks.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/alib_protos.h>
#include <clib/alib_stdio_protos.h>

#include <graphics/gfxmacros.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }
#endif

UBYTE *vers = "\0$VER: TestBut 37.1";

/***********************************************************/
/****************      Class specifics      ****************/
/***********************************************************/
#define RKMBUT_Pulse   (TAG_USER + 1)

struct ButINST
{
    LONG midX, midY; /* Coordinates of middle of gadget */
};

/* ButINST has one flag:  */
#define ERASE_ONLY   0x00000001 /* Tells rendering routine to */
                                /* only erase the gadget, not */
                                /* rerender a new one.  This  */
                                /* lets the gadget erase it-  */
                                /* self before it rescales.   */

/* The functions in this module */
Class *initRKMButGadClass(void);
BOOL   freeRKMButGadClass(Class *);
ULONG  dispatchRKMButGad(Class *, Object *, Msg);
void   NotifyPulse(Class *, Object *, ULONG, LONG, struct gpInput *);
ULONG  RenderRKMBut(Class *, struct Gadget *, struct gpRender *);
void   geta4(void);
void   MainLoop(ULONG, ULONG);

/*************************************************************************************************/
/* The main() function connects an RKMButClass object to a Boopsi integer gadget, which displays */
/* the RKMButClass gadget's RKMBUT_Pulse value.  The code scales and move the gadget while it is */
/* in place.                                                                                     */
/*************************************************************************************************/

struct TagItem pulse2int[] =
{
    {RKMBUT_Pulse, STRINGA_LongVal},
    {TAG_END,}
};

#define INTWIDTH  40
#define INTHEIGHT 20

struct Library *IntuitionBase, *UtilityBase, *GfxBase;
struct Window *w;
Class *rkmbutcl;
struct Gadget *integer, *but;
struct IntuiMessage *msg;

void main(void)
{
    if (IntuitionBase = OpenLibrary("intuition.library", 37L))
    {
        if (UtilityBase = OpenLibrary("utility.library", 37L))
        {
            if (GfxBase = OpenLibrary("graphics.library", 37L))
            {
                if (w = OpenWindowTags(NULL,
                    WA_Flags,       WFLG_DEPTHGADGET | WFLG_DRAGBAR |
                                        WFLG_CLOSEGADGET | WFLG_SIZEGADGET,
                    WA_IDCMP,       IDCMP_CLOSEWINDOW,
                    WA_Width,           640,
                    WA_Height,          200,
                    TAG_END))
                {
                    WindowLimits(w, 450, 200, 640, 200);

                    if (rkmbutcl = initRKMButGadClass())
                    {
                        if (integer = (struct Gadget *)NewObject(NULL,
                                       "strgclass",
                                       GA_ID,            1L,
                                       GA_Top,           (w->BorderTop) + 5L,
                                       GA_Left,          (w->BorderLeft) + 5L,
                                       GA_Width,         INTWIDTH,
                                       GA_Height,        INTHEIGHT,
                                       STRINGA_LongVal,  0L,
                                       STRINGA_MaxChars, 5L,
                                       TAG_END))
                        {
                            if (but = (struct Gadget *)NewObject(rkmbutcl,
                                       NULL,
                                       GA_ID,       2L,
                                       GA_Top,      (w->BorderTop) + 5L,
                                       GA_Left,     integer->LeftEdge +
                                                        integer->Width + 5L,
                                       GA_Width,    40L,
                                       GA_Height,   INTHEIGHT,
                                       GA_Previous, integer,
                                       ICA_MAP,     pulse2int,
                                       ICA_TARGET,  integer,
                                       TAG_END))
                            {
                                AddGList(w, integer, -1, -1, NULL);
                                RefreshGList(integer, w, NULL, -1);

                                SetWindowTitles(w,
                                    "<-- Click to resize gadget Height",
                                    NULL);
                                MainLoop(TAG_DONE, 0L);

                                SetWindowTitles(w,
                                    "<-- Click to resize gadget Width",
                                    NULL);
                                MainLoop(GA_Height, 100L);

                                SetWindowTitles(w,
                                    "<-- Click to resize gadget Y position",
                                    NULL);
                                MainLoop(GA_Width, 100L);

                                SetWindowTitles(w,
                                    "<-- Click to resize gadget X position",
                                    NULL);
                                MainLoop(GA_Top, but->TopEdge + 20);

                                SetWindowTitles(w,
                                    "<-- Click to quit", NULL);
                                MainLoop(GA_Left, but->LeftEdge + 20);

                                RemoveGList(w, integer, -1);
                                DisposeObject(but);
                            }
                            DisposeObject(integer);
                        }
                        freeRKMButGadClass(rkmbutcl);
                    }
                    CloseWindow(w);
                }
                CloseLibrary(GfxBase);
            }
            CloseLibrary(UtilityBase);
        }
        CloseLibrary(IntuitionBase);
    }
}

void MainLoop(ULONG attr, ULONG value)
{
    ULONG done = FALSE;

    SetGadgetAttrs(but, w, NULL, attr, value, TAG_DONE);

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
}

/***********************************************************/
/**    Make the class and set up the dispatcher's hook    **/
/***********************************************************/
Class   *initRKMButGadClass(void)
{
    Class *cl = NULL;
    extern ULONG HookEntry();     /* defined in amiga.lib */

    if ( cl =  MakeClass( NULL,
                "gadgetclass", NULL,
                sizeof ( struct ButINST ),
                0 ))
    {
        /* initialize the cl_Dispatcher Hook    */
        cl->cl_Dispatcher.h_Entry = HookEntry;
        cl->cl_Dispatcher.h_SubEntry = dispatchRKMButGad;
    }
    return ( cl );
}

/***********************************************************/
/******************     Free the class      ****************/
/***********************************************************/
BOOL freeRKMButGadClass( Class *cl )
{
    return (FreeClass(cl));
}

/***********************************************************/
/**********       The RKMBut class dispatcher      *********/
/***********************************************************/
ULONG dispatchRKMButGad(Class *cl, Object *o, Msg msg)
{
    struct ButINST *inst;
    ULONG retval = FALSE;
    Object *object;

    /* SAS/C and Manx function to make sure register A4
       contains a pointer to global data */
    geta4();

    switch (msg->MethodID)
    {
        case OM_NEW:       /* First, pass up to superclass */
            if (object = (Object *)DoSuperMethodA(cl, o, msg))
            {
                struct Gadget *g = (struct Gadget *)object;

                            /* Initial local instance data */
                inst = INST_DATA(cl, object);
                inst->midX   = g->LeftEdge + ( (g->Width) / 2);
                inst->midY   = g->TopEdge + ( (g->Height) / 2);

                retval = (ULONG)object;
            }
            break;
        case GM_HITTEST:
                   /* Since this is a rectangular gadget this  */
                   /* method always returns GMR_GADGETHIT.     */
            retval = GMR_GADGETHIT;
            break;
        case GM_GOACTIVE:
            inst = INST_DATA(cl, o);

                    /* Only become active if the GM_GOACTIVE   */
                    /* was triggered by direct user input.     */
            if (((struct gpInput *)msg)->gpi_IEvent)
            {
                       /* This gadget is now active, change    */
                       /* visual state to selected and render. */
                ((struct Gadget *)o)->Flags |= GFLG_SELECTED;
                                RenderRKMBut(cl, (struct Gadget *)o, (struct gpRender *)msg);
                retval = GMR_MEACTIVE;
            }
            else            /* The GM_GOACTIVE was not         */
                            /* triggered by direct user input. */
                retval = GMR_NOREUSE;
            break;
        case GM_RENDER:
            retval = RenderRKMBut(cl, (struct Gadget *)o, (struct gpRender *)msg);
            break;
        case GM_HANDLEINPUT:   /* While it is active, this gadget sends its superclass an        */
                               /* OM_NOTIFY pulse for every IECLASS_TIMER event that goes by     */
                               /* (about one every 10th of a second).  Any object that is        */
                               /* connected to this gadget will get A LOT of OM_UPDATE messages. */
            {
                struct Gadget *g = (struct Gadget *)o;
                struct gpInput *gpi = (struct gpInput *)msg;
                struct InputEvent *ie = gpi->gpi_IEvent;

                inst = INST_DATA(cl, o);

                retval = GMR_MEACTIVE;

                if (ie->ie_Class == IECLASS_RAWMOUSE)
                {
                    switch (ie->ie_Code)
                    {
                        case SELECTUP: /* The user let go of the gadget so return GMR_NOREUSE    */
                                       /* to deactivate and to tell Intuition not to reuse       */
                                       /* this Input Event as we have already processed it.      */

                                       /*If the user let go of the gadget while the mouse was    */
                                       /*over it, mask GMR_VERIFY into the return value so       */
                                       /*Intuition will send a Release Verify (GADGETUP).        */
                            if ( ((gpi->gpi_Mouse).X < g->LeftEdge) ||
                                 ((gpi->gpi_Mouse).X > g->LeftEdge + g->Width) ||
                                 ((gpi->gpi_Mouse).Y < g->TopEdge) ||
                                 ((gpi->gpi_Mouse).Y > g->TopEdge + g->Height) )
                                retval = GMR_NOREUSE | GMR_VERIFY;
                            else
                                retval = GMR_NOREUSE;

                                           /* Since the gadget is going inactive, send a final   */
                                           /* notification to the ICA_TARGET.                    */
                            NotifyPulse(cl , o, 0L, inst->midX, (struct gp_Input *)msg);
                            break;
                        case MENUDOWN: /* The user hit the menu button. Go inactive and let      */
                                       /* Intuition reuse the menu button event so Intuition can */
                                       /* pop up the menu bar.                                   */
                            retval = GMR_REUSE;

                                           /* Since the gadget is going inactive, send a final   */
                                           /* notification to the ICA_TARGET.                    */
                            NotifyPulse(cl , o, 0L, inst->midX, (struct gp_Input *)msg);
                            break;
                        default:
                            retval = GMR_MEACTIVE;
                    }

                }
                else if (ie->ie_Class == IECLASS_TIMER)
                              /* If the gadget gets a timer event, it sends an interim OM_NOTIFY */
                    NotifyPulse(cl, o, OPUF_INTERIM, inst->midX, gpi); /*     to its superclass. */
            }
            break;

        case GM_GOINACTIVE:           /* Intuition said to go inactive.  Clear the GFLG_SELECTED */
                                      /* bit and render using unselected imagery.                */
            ((struct Gadget *)o)->Flags &= ~GFLG_SELECTED;
            RenderRKMBut(cl, (struct Gadget *)o, (struct gpRender *)msg);
            break;
        case OM_SET:/* Although this class doesn't have settable attributes, this gadget class   */
                    /* does have scaleable imagery, so it needs to find out when its size and/or */
                    /* position has changed so it can erase itself, THEN scale, and rerender.    */
            if ( FindTagItem(GA_Width,  ((struct opSet *)msg)->ops_AttrList) ||
                 FindTagItem(GA_Height, ((struct opSet *)msg)->ops_AttrList) ||
                 FindTagItem(GA_Top,    ((struct opSet *)msg)->ops_AttrList) ||
                 FindTagItem(GA_Left,   ((struct opSet *)msg)->ops_AttrList) )
            {
                struct RastPort *rp;
                struct Gadget *g = (struct Gadget *)o;

                WORD x,y,w,h;

                x = g->LeftEdge;
                y = g->TopEdge;
                w = g->Width;
                h = g->Height;

                inst = INST_DATA(cl, o);

                retval = DoSuperMethodA(cl, o, msg);

                                                          /* Get pointer to RastPort for gadget. */
                if (rp = ObtainGIRPort( ((struct opSet *)msg)->ops_GInfo) )
                {
                                    UWORD *pens = ((struct opSet *)msg)->ops_GInfo->gi_DrInfo->dri_Pens;

                    SetAPen(rp, pens[BACKGROUNDPEN]);
                    SetDrMd(rp, JAM1);                            /* Erase the old gadget.       */
                    RectFill(rp, x, y, x+w, y+h);

                    inst->midX = g->LeftEdge + ( (g->Width) / 2); /* Recalculate where the       */
                    inst->midY = g->TopEdge + ( (g->Height) / 2); /* center of the gadget is.    */

                                                                  /* Rerender the gadget.        */
                    DoMethod(o, GM_RENDER, ((struct opSet *)msg)->ops_GInfo, rp, GREDRAW_REDRAW);
                    ReleaseGIRPort(rp);
                }
            }
            else
                retval = DoSuperMethodA(cl, o, msg);
            break;
        default:          /* rkmmodelclass does not recognize the methodID, let the superclass's */
                          /* dispatcher take a look at it.                                       */
            retval = DoSuperMethodA(cl, o, msg);
            break;
    }
    return(retval);
}



/*************************************************************************************************/
/************** Build an OM_NOTIFY message for RKMBUT_Pulse and send it to the superclass. *******/
/*************************************************************************************************/
void NotifyPulse(Class *cl, Object *o, ULONG flags, LONG mid, struct gpInput *gpi)
{
    struct TagItem tt[3];

    tt[0].ti_Tag = RKMBUT_Pulse;
    tt[0].ti_Data = mid - ((gpi->gpi_Mouse).X + ((struct Gadget *)o)->LeftEdge);

    tt[1].ti_Tag = GA_ID;
    tt[1].ti_Data = ((struct Gadget *)o)->GadgetID;

    tt[2].ti_Tag = TAG_DONE;

    DoSuperMethod(cl, o, OM_NOTIFY, tt, gpi->gpi_GInfo, flags);
}



/*************************************************************************************************/
/*******************************   Erase and rerender the gadget.   ******************************/
/*************************************************************************************************/
ULONG RenderRKMBut(Class *cl, struct Gadget *g, struct gpRender *msg)
{
    struct ButINST *inst = INST_DATA(cl, (Object *)g);
    struct RastPort *rp;
    ULONG retval = TRUE;
    UWORD *pens = msg->gpr_GInfo->gi_DrInfo->dri_Pens;

    if (msg->MethodID == GM_RENDER)   /* If msg is truly a GM_RENDER message (not a gpInput that */
                                      /* looks like a gpRender), use the rastport within it...   */
        rp = msg->gpr_RPort;
    else                              /* ...Otherwise, get a rastport using ObtainGIRPort().     */
        rp = ObtainGIRPort(msg->gpr_GInfo);

    if (rp)
    {
        UWORD back, shine, shadow, w, h, x, y;

        if (g->Flags & GFLG_SELECTED) /* If the gadget is selected, reverse the meanings of the  */
        {                             /* pens.                                                   */
            back   = pens[FILLPEN];
            shine  = pens[SHADOWPEN];
            shadow = pens[SHINEPEN];
        }
        else
        {
            back   = pens[BACKGROUNDPEN];
            shine  = pens[SHINEPEN];
            shadow = pens[SHADOWPEN];
        }
        SetDrMd(rp, JAM1);

        SetAPen(rp, back);          /* Erase the old gadget.       */
        RectFill(rp, g->LeftEdge,
                     g->TopEdge,
                     g->LeftEdge + g->Width,
                     g->TopEdge + g->Height);

        SetAPen(rp, shadow);     /* Draw shadow edge.            */
        Move(rp, g->LeftEdge + 1, g->TopEdge + g->Height);
        Draw(rp, g->LeftEdge + g->Width, g->TopEdge + g->Height);
        Draw(rp, g->LeftEdge + g->Width, g->TopEdge + 1);

        w = g->Width / 4;       /* Draw Arrows - Sorry, no frills imagery */
        h = g->Height / 2;
        x = g->LeftEdge + (w/2);
        y = g->TopEdge + (h/2);

        Move(rp, x, inst->midY);
        Draw(rp, x + w, y);
        Draw(rp, x + w, y + (g->Height) - h);
        Draw(rp, x, inst->midY);

        x = g->LeftEdge + (w/2) + g->Width / 2;

        Move(rp, x + w, inst->midY);
        Draw(rp, x, y);
        Draw(rp, x, y  + (g->Height) - h);
        Draw(rp, x + w, inst->midY);

        SetAPen(rp, shine);    /* Draw shine edge.           */
        Move(rp, g->LeftEdge, g->TopEdge + g->Height - 1);
        Draw(rp, g->LeftEdge, g->TopEdge);
        Draw(rp, g->LeftEdge + g->Width - 1, g->TopEdge);

        if (msg->MethodID != GM_RENDER) /* If we allocated a rastport, give it back.             */
            ReleaseGIRPort(rp);
    }
    else retval = FALSE;
    return(retval);
}
