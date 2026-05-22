/* TextEditorExample.c -- TextEditor class Example.
 * Adapted from CheckBoxExample.c and Integer.c.
 *
 * Version 1.0a
 * By James Jacobs of Amigan Software. Freely distributable.
 *
 * This is a simple example testing some of the capabilities of the
 * TextEditor gadget class.
 *
 * This code opens a window and then creates 2 TextEditor gadgets which
 * are subsequently attached to the window's gadget list.
 */

// system includes
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <graphics/gfxbase.h>
#include <graphics/text.h>
#include <graphics/gfxmacros.h>
#include <utility/tagitem.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>
#include <proto/wb.h>
#include <proto/icon.h>

#include <clib/alib_protos.h>
#include <clib/texteditor_protos.h>

// ReAction includes
#define ALL_REACTION_CLASSES
#define ALL_REACTION_MACROS
#include <reaction/reaction.h>

#include <gadgets/texteditor.h>
#include <pragmas/texteditor_pragmas.h>

enum
{   GID_MAIN         = 0,
    GID_TEXTEDITOR1,
    GID_TEXTEDITOR2,
    GID_DOWN,
    GID_UP,
    GID_QUIT,
    GID_LAST
};

enum
{   OID_MAIN = 0,
    OID_LAST
};

struct Library *WindowBase,
               *LayoutBase,
               *ButtonBase,
               *TextEditorBase,
               *LabelBase;

void openlibs(void)
{   /* Open the classes - typically not required to be done manually.
     * SAS/C or DICE AutoInit can do this for you if linked with the
     * supplied reaction.lib */

    if (!(WindowBase = OpenLibrary("window.class", 44)))
        Printf("OpenLibrary(\"window.class\") failed!\n");
    if (!(LayoutBase = OpenLibrary("gadgets/layout.gadget", 44)))
        Printf("OpenLibrary(\"gadgets/layout.gadget\") failed!\n");
    if (!(ButtonBase = OpenLibrary("gadgets/button.gadget", 44)))
        Printf("OpenLibrary(\"gadgets/button.gadget\") failed!\n");
    if (!(TextEditorBase = OpenLibrary("gadgets/texteditor.gadget", 0)))
        Printf("OpenLibrary(\"gadgets/texteditor.gadget\") failed!\n");
    if (!(LabelBase = OpenLibrary("images/label.image", 44)))
        Printf("OpenLibrary(\"images/label.image\") failed!\n");
}

void closelibs(void) 
{   // Close the classes.
    CloseLibrary(LabelBase);
    CloseLibrary(TextEditorBase);
    CloseLibrary(ButtonBase);
    CloseLibrary(LayoutBase);
    CloseLibrary(WindowBase);
}

void main(void)
{   struct MsgPort* AppPort;
    struct Window*  window;
    struct Gadget*  gadgets[GID_LAST];
           Object*  objects[OID_LAST];

    APTR Buffer1, Buffer2;

    if (0) // that is, never
        Printf("$VER: TextEditorExample 1.0a (2.3.2001)");

    /* make sure our classes opened... */
    openlibs();

    if (AppPort = CreateMsgPort())
    {   /* Create the window object. */
        objects[OID_MAIN] = NewObject
        (   WINDOW_GetClass(),               NULL,
            WA_ScreenTitle,                  "ReAction",
            WA_Title,                        "ReAction TextEditor Example",
            WA_Activate,                     TRUE,
            WA_DepthGadget,                  TRUE,
            WA_DragBar,                      TRUE,
            WA_CloseGadget,                  TRUE,
            WA_SizeGadget,                   TRUE,
            WINDOW_IconifyGadget,            TRUE,
            WINDOW_IconTitle,                "TextEditor",
            WINDOW_AppPort,                  AppPort,
            WINDOW_Position,                 WPOS_CENTERSCREEN,
            WINDOW_ParentGroup,              gadgets[GID_MAIN] = NewObject
            (   LAYOUT_GetClass(),           NULL,
                LAYOUT_Orientation,          LAYOUT_ORIENT_VERT,
                LAYOUT_SpaceOuter,           TRUE,
                LAYOUT_DeferLayout,          TRUE,

                LAYOUT_AddChild,             gadgets[GID_TEXTEDITOR1] = NewObject
                (   TEXTEDITOR_GetClass(),   NULL,
                    GA_ID,                   GID_TEXTEDITOR1,
                    TAG_END
                ),   
                CHILD_NominalSize,           TRUE,

                LAYOUT_AddChild,             gadgets[GID_TEXTEDITOR2] = NewObject
                (   TEXTEDITOR_GetClass(),   NULL,
                    GA_ID,                   GID_TEXTEDITOR2,
                    TAG_END
                ),
                CHILD_NominalSize,           TRUE,

                LAYOUT_AddChild,             NewObject
                (   LAYOUT_GetClass(),       NULL,
                    LAYOUT_Orientation,      LAYOUT_ORIENT_VERT,
                    GA_BackFill,             NULL,
                    LAYOUT_SpaceOuter,       TRUE,
                    LAYOUT_VertAlignment,    LALIGN_CENTER,
                    LAYOUT_HorizAlignment,   LALIGN_CENTER,
                    LAYOUT_BevelStyle,       BVS_FIELD,

                    LAYOUT_AddImage,         NewObject
                    (   LABEL_GetClass(),    NULL,
                        LABEL_Text,          "This is an example of how to use the\n",
                        LABEL_Text,          "ReAction texteditor.gadget class.\n",
                        LABEL_Text,          " \n",
                        LABEL_Text,          "As you can see, it creates two\n",
                        LABEL_Text,          "instances of the texteditor.gadget.\n",
                        LABEL_Justification, LJ_CENTRE,
                        TAG_END
                    ),
                    TAG_END
                ),

                LAYOUT_AddChild,             NewObject
                (   NULL,                    "button.gadget",
                    GA_ID,                   GID_QUIT,
                    GA_RelVerify,            TRUE,
                    GA_Text,                 "_Quit",
                    TAG_END
                ),
                CHILD_WeightedHeight,        0,
                TAG_END
            ),
            TAG_END
        );

        // Object creation successful?
        if (objects[OID_MAIN])
        {   // Open the window.
            if (window = RA_OpenWindow(objects[OID_MAIN]))
            {   ULONG wait, signal, app = (1L << AppPort->mp_SigBit);
                ULONG done = FALSE;
                ULONG result;
                UWORD code;

                // Obtain the window wait signal mask.
                GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);

                // Activate the first texteditor gadget.
                ActivateLayoutGadget(gadgets[GID_MAIN], window, NULL, (Object) gadgets[GID_TEXTEDITOR1]);

                // Input Event Loop
                while (!done)
                {   wait = Wait( signal | SIGBREAKF_CTRL_C | app );

                    if ( wait & SIGBREAKF_CTRL_C )
                        done = TRUE;
                    else
                    {   while ( (result = RA_HandleInput(objects[OID_MAIN], &code) ) != WMHI_LASTMSG )
                        {   switch (result & WMHI_CLASSMASK)
                            {
                            case WMHI_CLOSEWINDOW:
                                window = NULL;
                                done = TRUE;
                            break;
                            case WMHI_GADGETUP:
                                switch (result & WMHI_GADGETMASK)
                                {
                                case GID_QUIT:
                                    done = TRUE;
                                break;
                                default:
                                break;
                                }
                            break;
                            case WMHI_ICONIFY:
                                RA_Iconify(objects[OID_MAIN]);
                                window = NULL;
                            break;
                            case WMHI_UNICONIFY:
                                window = RA_OpenWindow(objects[OID_MAIN]);
                                if (window)
                                    GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);
                                else done = TRUE; // error re-opening window!
                            break;
                            default:
                            break;
            }   }   }   }   }

            Buffer1 = DoGadgetMethod(gadgets[GID_TEXTEDITOR1], window, NULL, GM_TEXTEDITOR_ExportText, NULL);
            Buffer2 = DoGadgetMethod(gadgets[GID_TEXTEDITOR2], window, NULL, GM_TEXTEDITOR_ExportText, NULL);
            Printf("1: %s\n2: %s\n", Buffer1, Buffer2);
            FreeVec(Buffer1);
            FreeVec(Buffer2);

            /* Disposing of the window object will also close the window if it is
             * already opened, and it will dispose of the layout object attached to it.
             */
            DisposeObject(objects[OID_MAIN]);
        } else Printf("NewObject() failed!\n");
        DeleteMsgPort(AppPort);
    } else Printf("CreateMsgPort() failed!\n");
    closelibs();

    return;
}
