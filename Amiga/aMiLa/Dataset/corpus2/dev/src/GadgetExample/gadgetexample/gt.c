#include <exec/types.h>
#include <libraries/gadtools.h>
#include <intuition/intuition.h>
#include <exec/execbase.h>
#include <stdlib.h>

#define AUTO            auto    /* automatic variables */
#define AGLOBAL         ;       /* global (project-scope) */
#define MODULE		static	/* external static (file-scope) */
#define PERSIST		static	/* internal static (function-scope) */
typedef signed char	ABOOL;	/* 8-bit signed quantity (replaces BOOL) */
typedef signed char	SBYTE;	/* 8-bit signed quantity (replaces Amiga BYTE) */
typedef signed short	SWORD;	/* 16-bit signed quantity (replaces Amiga WORD) */
typedef signed long	SLONG;	/* 32-bit signed quantity (same as LONG) */
#define elif		else if

MODULE struct Gadget        *gadget[3]     = {NULL, NULL, NULL},
                            *GListPtr      = NULL;
MODULE struct TextFont*      FontPtr       = NULL;
MODULE struct IntuitionBase* IntuitionBase = NULL;
MODULE struct DosBase*       DosBase       = NULL;
MODULE struct GadToolsBase*  GadToolsBase  = NULL;
MODULE struct VisualInfo*    VisualInfoPtr = NULL;
MODULE struct Window*        WindowPtr     = NULL;
MODULE struct Screen*        ScreenPtr     = NULL;

IMPORT struct ExecBase*      SysBase;

MODULE void cleanexit(SBYTE rc);

void main(void)
{   WORD                 xsize, ysize;
    ULONG                class, i;
    UWORD                code;
    ABOOL                done              = FALSE;
    struct Gadget       *addr,
                        *gad               = NULL;
    struct NewGadget     NewGadget;
    struct IntuiMessage* IMsgPtr           = NULL;

    struct TextAttr  Topaz8 =
    {   (STRPTR) "topaz.font", 8, FS_NORMAL, FPF_ROMFONT | FPF_DESIGNED
    }; /* "topaz.font" is case-sensitive */

    if (!(DosBase = OpenLibrary("dos.library", 0)))
    {   cleanexit(EXIT_FAILURE);
    }
    if ((SysBase->LibNode.lib_Version) < 37)
    {   Printf("Need AmigaOS 2.04+!\n");
        cleanexit(EXIT_FAILURE);
    }
    if (!(IntuitionBase = OpenLibrary("intuition.library", 37)))
    {   Printf("Can't open intuition.library!\n");
        cleanexit(EXIT_FAILURE);
    }
    if (!(GadToolsBase = OpenLibrary("gadtools.library", 37)))
    {   Printf("Can't open gadtools.library!\n");
        cleanexit(EXIT_FAILURE);
    }
    if (!(FontPtr = OpenFont(&Topaz8)))
    {   Printf("Can't open topaz.font!\n");
    }

    ScreenPtr = LockPubScreen(NULL);
    VisualInfoPtr = GetVisualInfo(ScreenPtr, NULL);
    xsize = ScreenPtr->Width;
    ysize = ScreenPtr->Height;
    UnlockPubScreen(ScreenPtr);
    ScreenPtr = NULL;
    gad = CreateContext(&GListPtr);

    NewGadget.ng_LeftEdge   = 10;
    NewGadget.ng_TopEdge    = 16;
    NewGadget.ng_Width      = 64;
    NewGadget.ng_Height     = 12;
    NewGadget.ng_GadgetText = "1st";
    NewGadget.ng_TextAttr   = (struct TextAttr *) &Topaz8;
    NewGadget.ng_GadgetID   = 0;
    NewGadget.ng_Flags      = 0;
    NewGadget.ng_VisualInfo = VisualInfoPtr;
    NewGadget.ng_UserData   = NULL;
    gadget[0] = gad = CreateGadget
    (   BUTTON_KIND, gad, &NewGadget,
        TAG_END
    );
    NewGadget.ng_LeftEdge   = 76;
    NewGadget.ng_GadgetText = "2nd";
    gadget[1] = gad = CreateGadget
    (   BUTTON_KIND, gad, &NewGadget,
        TAG_END
    );
    NewGadget.ng_LeftEdge   = 142;
    NewGadget.ng_GadgetText = "3rd";
    gadget[2] = gad = CreateGadget
    (   BUTTON_KIND, gad, &NewGadget,
        TAG_END
    );
    if (!gad)
    {   cleanexit(EXIT_FAILURE);
    }

    ScreenPtr = LockPubScreen(NULL);
    if (!(WindowPtr = (struct Window *) OpenWindowTags
    (   NULL,
        WA_Left,         (xsize / 2) - (216 / 2),
        WA_Top,          (ysize / 2) - ( 34 / 2),
        WA_Width,        216,
        WA_Height,       34,
        WA_IDCMP,        IDCMP_CLOSEWINDOW |
                         IDCMP_REFRESHWINDOW |
                         IDCMP_VANILLAKEY |
                         BUTTONIDCMP,
        WA_Gadgets,      GListPtr,
        WA_PubScreen,    ScreenPtr,
        WA_Activate,     TRUE,
        WA_Title,        "GadTools Demo",
        WA_DragBar,      TRUE,
        WA_DepthGadget,  TRUE,
        WA_CloseGadget,  TRUE,
        WA_SmartRefresh, TRUE,
        TAG_DONE
    )))
    {   Printf("Can't open window!\n");
        cleanexit(EXIT_SUCCESS);
    }
    UnlockPubScreen(ScreenPtr);
    ScreenPtr = NULL;
    SetFont(WindowPtr->RPort, FontPtr);
    GT_RefreshWindow(WindowPtr, NULL);

    while(!done)
    {   Wait(1 << WindowPtr->UserPort->mp_SigBit);
        while (IMsgPtr = (struct IntuiMessage *) GT_GetIMsg(WindowPtr->UserPort))
        {   class = IMsgPtr->Class;
            code  = IMsgPtr->Code;
            addr  = (struct Gadget *) IMsgPtr->IAddress;
            GT_ReplyIMsg(IMsgPtr);
            switch(class)
            {
            case IDCMP_CLOSEWINDOW:
                done = TRUE;
            break;
            case IDCMP_GADGETUP:
                for (i = 0; i <= 2; i++)
                {   if (addr == gadget[i])
                    {   Printf("Button %ld was clicked!\n", i + 1);
                        break; // for speed
                }   }
            break;
            case IDCMP_VANILLAKEY:
                if (code == 27) // escape
                {   done = TRUE;
                }
            break;
            case IDCMP_REFRESHWINDOW:
                GT_BeginRefresh(WindowPtr);
                // custom refreshing here
                GT_EndRefresh(WindowPtr, TRUE);
            break;
            default:
            break;
    }   }   }

    cleanexit(EXIT_SUCCESS);
}

MODULE void cleanexit(SBYTE rc)
{   if (ScreenPtr)
    {   UnlockPubScreen(NULL);
        ScreenPtr = NULL;
    }
    if (WindowPtr)
    {   CloseWindow(WindowPtr);
        WindowPtr = NULL;
    }
    if (GListPtr)
    {   FreeGadgets(GListPtr);
        GListPtr = NULL;
    }
    if (VisualInfoPtr)
    {   FreeVisualInfo(VisualInfoPtr);
        VisualInfoPtr = NULL;
    }
    if (FontPtr)
    {   CloseFont(FontPtr);
        FontPtr = NULL;
    }
    if (GadToolsBase)
    {   CloseLibrary(GadToolsBase);
        GadToolsBase = NULL;
    }
    if (IntuitionBase)
    {   CloseLibrary(IntuitionBase);
        IntuitionBase = NULL;
    }
    if (DosBase)
    {   CloseLibrary(DosBase);
        DosBase = NULL;
    }
    exit(rc);
}

