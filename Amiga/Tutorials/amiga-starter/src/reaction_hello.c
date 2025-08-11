/* src/reaction_hello.c - minimal ReAction window for OS3 + vbcc */

#define __NOLIBBASE__   /* we'll open the bases ourselves */
#include <exec/types.h>
#include <exec/libraries.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/utility.h>
#include <clib/alib_protos.h>   /* <-- varargs stubs like DoMethod() */

#include <classes/window.h>
#include <gadgets/layout.h>
#include <gadgets/button.h>
#include <images/label.h>

/* Required global bases for OS3 proto stubs */
struct IntuitionBase *IntuitionBase = NULL;
struct UtilityBase   *UtilityBase   = NULL;

int main(void)
{
    struct Window *win = NULL;
    Object *win_obj = NULL;

    IntuitionBase = (struct IntuitionBase*)OpenLibrary("intuition.library", 39);
    if (!IntuitionBase) return 10;

    UtilityBase = (struct UtilityBase*)OpenLibrary("utility.library", 39);
    if (!UtilityBase) { CloseLibrary((struct Library*)IntuitionBase); return 11; }

    Object *btn = NewObject(NULL, "button.gadget",
        GA_Text, (ULONG)"Close",
        TAG_DONE);

    Object *root = NewObject(NULL, "layout.gadget",
        LAYOUT_SpaceOuter, TRUE,
        LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
        LAYOUT_AddChild, (ULONG)btn,   /* add child at creation time */
        TAG_DONE);

    win_obj = NewObject(NULL, "window.class",
        WA_Title,        (ULONG)"ReAction Hello",
        WA_DragBar,      TRUE,
        WA_CloseGadget,  TRUE,
        WA_DepthGadget,  TRUE,
        WA_Activate,     TRUE,
        WINDOW_Position, WPOS_CENTERSCREEN,
        WINDOW_Layout,   (ULONG)root,
        TAG_DONE);

    if (!win_obj) goto clean;

    /* Open BOOPSI window object and get struct Window */
    win = (struct Window *)DoMethod(win_obj, WM_OPEN);
    if (!win) goto clean;

    /* Basic loop: quit on close gadget */
    for (;;) {
        ULONG code = 0;
        ULONG result = DoMethod(win_obj, WM_HANDLEINPUT, &code);
        if (result == WMHI_CLOSEWINDOW || result == WMHI_LASTMSG) break;
    }

clean:
    if (win_obj) DoMethod(win_obj, WM_CLOSE);
    if (win_obj) DisposeObject(win_obj);

    if (UtilityBase)   CloseLibrary((struct Library*)UtilityBase);
    if (IntuitionBase) CloseLibrary((struct Library*)IntuitionBase);
    return 0;
}