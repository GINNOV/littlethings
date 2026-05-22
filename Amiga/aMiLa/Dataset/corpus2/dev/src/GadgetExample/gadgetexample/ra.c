#include <exec/types.h>
#include <libraries/gadtools.h>
#include <intuition/intuition.h>
#include <exec/execbase.h>
#include <stdlib.h>

#include <classes/window.h>
#include <pragmas/window_pragmas.h>
#include <gadgets/layout.h>
#include <pragmas/layout_pragmas.h>
#include <gadgets/button.h>

#define AUTO            auto    /* automatic variables */
#define AGLOBAL         ;       /* global (project-scope) */
#define MODULE		static	/* external static (file-scope) */
#define PERSIST		static	/* internal static (function-scope) */
typedef signed char	ABOOL;	/* 8-bit signed quantity (replaces BOOL) */
typedef signed char	SBYTE;	/* 8-bit signed quantity (replaces Amiga BYTE) */
typedef signed short	SWORD;	/* 16-bit signed quantity (replaces Amiga WORD) */
typedef signed long	SLONG;	/* 32-bit signed quantity (same as LONG) */
#define elif		else if

#define ASM             __asm
#define REG(x)          register __ ## x

MODULE struct Gadget*        gadget[4]       = {NULL, NULL, NULL, NULL};
MODULE struct IntuitionBase* IntuitionBase   = NULL;
MODULE struct DosBase*       DosBase         = NULL;
MODULE struct VisualInfo*    VisualInfoPtr   = NULL;
MODULE struct Window*        WindowPtr       = NULL;
MODULE struct Screen*        ScreenPtr       = NULL;
MODULE struct Object*        WindowObjectPtr = NULL;
MODULE struct Library       *ButtonBase      = NULL,
                            *LayoutBase      = NULL,
                            *WindowBase      = NULL;

IMPORT struct ExecBase*      SysBase;

MODULE void cleanexit(SBYTE rc);
MODULE ULONG HookFunc(struct Hook *h, VOID *o, VOID *msg);
MODULE ULONG ASM hookEntry(REG(a0) struct Hook *h, REG(a2) VOID *o, REG(a1) VOID *msg);
MODULE void InitHook(struct Hook* hook, ULONG (*func)(), void* data);

void main(void)
{   WORD        xsize, ysize;
    ULONG       result;
    UWORD       code;
    ABOOL       done = FALSE;
    struct Hook HookStruct;

    if (!(DosBase = OpenLibrary("dos.library", 0)))
    {   cleanexit(EXIT_FAILURE);
    }
    if ((SysBase->LibNode.lib_Version) < 40)
    {   Printf("Need AmigaOS 3.5+!\n");
        cleanexit(EXIT_FAILURE);
    }
    if (!(IntuitionBase = OpenLibrary("intuition.library", 37)))
    {   Printf("Can't open intuition.library!\n");
        cleanexit(EXIT_FAILURE);
    }
    if (!(WindowBase = OpenLibrary("classes/window.class", 44)))
    {   Printf("Can't open window.class!\n");
        cleanexit(EXIT_FAILURE);
    }
    if (!(LayoutBase = OpenLibrary("gadgets/layout.gadget", 44)))
    {   Printf("Can't open layout.gadget!\n");
        cleanexit(EXIT_FAILURE);
    }
    if (!(ButtonBase = OpenLibrary("gadgets/button.gadget", 44)))
    {   Printf("Can't open button.gadget!\n");
        cleanexit(EXIT_FAILURE);
    }

    InitHook(&HookStruct, HookFunc, NULL);

    ScreenPtr = LockPubScreen(NULL);
    VisualInfoPtr = GetVisualInfo(ScreenPtr, NULL);
    xsize = ScreenPtr->Width;
    ysize = ScreenPtr->Height;

    if (!(WindowObjectPtr = NewObject
    (   WINDOW_GetClass(),
        NULL,
        WA_PubScreen,             ScreenPtr,
        WA_ScreenTitle,           "Reaction Demo",
        WA_Title,                 "ReAction Demo",
        WA_Activate,              TRUE,
        WA_DepthGadget,           TRUE,
        WA_DragBar,               TRUE,
        WA_CloseGadget,           TRUE,
        WA_IDCMP,                 IDCMP_RAWKEY,
        WINDOW_IDCMPHook,         &HookStruct,
        WINDOW_IDCMPHookBits,     IDCMP_RAWKEY,
        WINDOW_Position,          WPOS_CENTERSCREEN,
        WINDOW_ParentGroup,       gadget[0] =
        NewObject
        (   LAYOUT_GetClass(),         NULL,
            // root-layout tags
            LAYOUT_Orientation,        LAYOUT_ORIENT_HORIZ,
            LAYOUT_SpaceOuter,         TRUE,
            LAYOUT_DeferLayout,        TRUE,
            LAYOUT_AddChild,           gadget[1] =
            NewObject
            (   NULL,
                "button.gadget",
                GA_ID,                 0,
                GA_RelVerify,          TRUE,
                GA_Text,               "1st",
                TAG_DONE
            ),
            LAYOUT_AddChild,           gadget[2] =
            NewObject
            (   NULL,
                "button.gadget",
                GA_ID,                 1,
                GA_RelVerify,          TRUE,
                GA_Text,               "2nd",
                TAG_DONE
            ),
            LAYOUT_AddChild,           gadget[3] =
            NewObject
            (   NULL,
                "button.gadget",
                GA_ID,                 2,
                GA_RelVerify,          TRUE,
                GA_Text,               "3rd",
                TAG_DONE
            ),
            TAG_DONE
        ),
        TAG_DONE
    )))
    {   Printf("Can't create ReAction object(s)!\n");
        cleanexit(EXIT_FAILURE);
    }
    UnlockPubScreen(ScreenPtr);
    ScreenPtr = NULL;

    if (!(WindowPtr = (struct Window *) DoMethod(WindowObjectPtr, WM_OPEN, NULL)))
    {   Printf("Can't open ReAction window!\n");
        cleanexit(EXIT_SUCCESS);
    }

    while(!done)
    {   Wait(1 << WindowPtr->UserPort->mp_SigBit);

        while ((result = DoMethod(WindowObjectPtr, WM_HANDLEINPUT, &code)) != WMHI_LASTMSG)
        {   switch (result & WMHI_CLASSMASK)
            {
            case WMHI_CLOSEWINDOW:
                done = TRUE;
            break;
            case WMHI_GADGETUP:
                switch(result & WMHI_GADGETMASK)
                {
                case 0:
                    Printf("Button 1 was clicked!\n");
                break;
                case 1:
                    Printf("Button 2 was clicked!\n");
                break;
                case 2:
                    Printf("Button 3 was clicked!\n");
                break;
                default:
                break;
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
    if (WindowObjectPtr)
    {   DisposeObject(WindowObjectPtr);
        WindowObjectPtr = NULL;
    }
    if (ButtonBase)
    {   CloseLibrary(ButtonBase);
        ButtonBase = NULL;
    }
    if (LayoutBase)
    {   CloseLibrary(LayoutBase);
        LayoutBase = NULL;
    }
    if (WindowBase)
    {   CloseLibrary(WindowBase);
        WindowBase = NULL;
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

MODULE ULONG HookFunc(struct Hook *h, VOID *o, VOID *msg)
{   /* "When the hook is called, the data argument points to the 
    window object and message argument to the IntuiMessage."

    These IntuiMessages do not need to be replied to by the appliprog. */

    UWORD code;
    ULONG class;

    geta4(); // wait till here before doing anything

    class  = ((struct IntuiMessage *) msg)->Class;
    code   = ((struct IntuiMessage *) msg)->Code;

    switch(class)
    {
    case IDCMP_RAWKEY:
        switch(code)
        {
        case 0x45: // Escape
            cleanexit(EXIT_FAILURE);
        break;
        default:
        break;
        }
    break;
    default:
    break;
    }

    return(1);
}

/* This function converts register-parameter Hook calling convention into
standard C conventions. It requires a C compiler that supports
registerized parameters, such as SAS/C 5.x or greater. */

MODULE ULONG ASM hookEntry(REG(a0) struct Hook *h, REG(a2) VOID *o, REG(a1) VOID *msg)
{   // This is the stub function that converts the register-parameters
    // to stack parameters.

    return ((*(ULONG (*)(struct Hook *, VOID *, VOID *))(*h->h_SubEntry))(h, o, msg));
}

MODULE void InitHook(struct Hook* hook, ULONG (*func)(), void* data)
{   // Make sure a pointer was passed

    if (hook)
    {   // Fill in the Hook fields
        hook->h_Entry    = (ULONG (*)()) hookEntry;
        hook->h_SubEntry = func;
        hook->h_Data     = data;
    } else
    {   Printf("Can't initialize hook (NULL pointer)!");
        cleanexit(EXIT_FAILURE);
}   }
