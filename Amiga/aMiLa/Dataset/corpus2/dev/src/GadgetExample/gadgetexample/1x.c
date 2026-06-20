#include <exec/types.h>
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

MODULE struct TextFont*      FontPtr       = NULL;
MODULE struct IntuitionBase* IntuitionBase = NULL;
MODULE struct DosBase*       DosBase       = NULL;
MODULE struct Window*        WindowPtr     = NULL;
MODULE struct Screen*        ScreenPtr     = NULL;

IMPORT struct ExecBase*      SysBase;

MODULE WORD BorderData[] =
{   0,   0,
    65,  0,
    65, 13,
    0,  13,
    0,   0
};
MODULE struct Border TheBorder =
{   -1, -1,     // LeftEdge, TopEdge
     1, 0,      // FrontPen, BackPen
    JAM1,       // DrawMode
    5,          // Count (number of coordinate pairs)
    BorderData, // XY
    NULL        // NextBorder
};
MODULE struct TextAttr  Topaz8 =
{   (STRPTR) "topaz.font", 8, FS_NORMAL, FPF_ROMFONT | FPF_DESIGNED
}; /* "topaz.font" is case-sensitive */
MODULE struct IntuiText TheIntuiText[3] =
{   {   1, 0,       // FrontPen, BackPen
        JAM1,       // DrawMode
        20, 2,      // LeftEdge, TopEdge
        &Topaz8,    // ITextFont
        "1st",      // IText
        NULL        // NextText
    },
    {   1, 0,       // FrontPen, BackPen
        JAM1,       // DrawMode
        20, 2,      // LeftEdge, TopEdge
        &Topaz8,    // ITextFont
        "2nd",      // IText
        NULL        // NextText
    },
    {   1, 0,       // FrontPen, BackPen
        JAM1,       // DrawMode
        20, 2,      // LeftEdge, TopEdge
        &Topaz8,    // ITextFont
        "3rd",      // IText
        NULL        // NextText
}   };
MODULE struct Gadget gadget[3] =
{   {   &gadget[1],
        10, 16,
        64, 12,
        GFLG_GADGHCOMP,
        GACT_RELVERIFY,
        GTYP_BOOLGADGET,
        &TheBorder,
        NULL,
        &TheIntuiText[0],
        0, NULL, NULL, NULL
    },
    {   &gadget[2],
        76, 16,
        64, 12,
        GFLG_GADGHCOMP,
        GACT_RELVERIFY,
        GTYP_BOOLGADGET,
        &TheBorder,
        NULL,
        &TheIntuiText[1],
        NULL, NULL, NULL, NULL
    },
    {   NULL,
        142, 16,
        64, 12,
        GFLG_GADGHCOMP,
        GACT_RELVERIFY,
        GTYP_BOOLGADGET,
        &TheBorder,
        NULL,
        &TheIntuiText[2],
        NULL, NULL, NULL, NULL
}   };

MODULE void cleanexit(SBYTE rc);

void main(void)
{   WORD                 xsize, ysize;
    ULONG                class, i;
    UWORD                code;
    ABOOL                done              = FALSE;
    struct Gadget*       addr;
    struct IntuiMessage* IMsgPtr           = NULL;

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
    if (!(FontPtr = OpenFont(&Topaz8)))
    {   Printf("Can't open topaz.font!\n");
    }

    ScreenPtr = LockPubScreen(NULL);
    xsize = ScreenPtr->Width;
    ysize = ScreenPtr->Height;
    UnlockPubScreen(ScreenPtr);
    ScreenPtr = NULL;

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
                         IDCMP_GADGETDOWN |
                         IDCMP_GADGETUP,
        WA_Gadgets,      gadget,
        WA_PubScreen,    ScreenPtr,
        WA_Activate,     TRUE,
        WA_Title,        "1.x Gadgets Demo",
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

    while(!done)
    {   Wait(1 << WindowPtr->UserPort->mp_SigBit);
        while (IMsgPtr = (struct IntuiMessage *) GetMsg(WindowPtr->UserPort))
        {   class = IMsgPtr->Class;
            code  = IMsgPtr->Code;
            addr  = (struct Gadget *) IMsgPtr->IAddress;
            ReplyMsg(IMsgPtr);
            switch(class)
            {
            case IDCMP_CLOSEWINDOW:
                done = TRUE;
            break;
            case IDCMP_GADGETUP:
                for (i = 0; i <= 2; i++)
                {   if (addr == &gadget[i])
                    {   Printf("Button %ld was clicked!\n", i + 1);
                        break; // for speed
                }   }
            break;
            case IDCMP_REFRESHWINDOW:
                BeginRefresh(WindowPtr);
                /* custom rendering here */
                EndRefresh(WindowPtr, TRUE);
            break;
            case IDCMP_VANILLAKEY:
                if (code == 27) // escape
                {   done = TRUE;
                }
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
    if (FontPtr)
    {   CloseFont(FontPtr);
        FontPtr = NULL;
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

