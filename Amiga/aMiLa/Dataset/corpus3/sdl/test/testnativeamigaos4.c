/*
  Copyright (C) 1997-2026 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely.
*/

#include "testnative.h"

#ifdef TEST_NATIVE_AMIGAOS4

#include <proto/exec.h>
#include <proto/intuition.h>

static struct Library * MyIntuitionBase;
static struct IntuitionIFace * MyIIntuition;

static void *CreateWindowAmigaOS4(int w, int h);
static void DestroyWindowAmigaOS4(void *window);

struct MsgPort *OS4_GetSharedMessagePort();

NativeWindowFactory AmigaOS4WindowFactory = {
    "amigaos4",
    CreateWindowAmigaOS4,
    DestroyWindowAmigaOS4
};

static bool
OS4_OpenIntuition()
{
    bool result = false;

    if (MyIIntuition) {
        result = true;
    } else {
        MyIntuitionBase = IExec->OpenLibrary("intuition.library", 50);

        if (MyIntuitionBase) {
            MyIIntuition = (struct IntuitionIFace *) IExec->GetInterface(MyIntuitionBase, "main", 1, NULL);
            if (MyIIntuition) {
                result = true;
            }
        }
    }

    return result;
}

static void *
CreateWindowAmigaOS4(int w, int h)
{
    struct Window * window = NULL;

    if (OS4_OpenIntuition()) {

        struct MsgPort * userport = OS4_GetSharedMessagePort();

        if (userport) {
            window = MyIIntuition->OpenWindowTags(
                NULL,
                WA_Title, "Native window",
                WA_InnerWidth, w,
                WA_InnerHeight, h,
                WA_Flags, WFLG_CLOSEGADGET,
                WA_IDCMP, IDCMP_CLOSEWINDOW,
                WA_UserPort, userport,
                TAG_DONE);
        }
    }

    return (void *) window;
}

static void
DestroyWindowAmigaOS4(void *window)
{
    if (OS4_OpenIntuition()) {
        MyIIntuition->CloseWindow(window);

        IExec->DropInterface((struct Interface *)MyIIntuition);
        IExec->CloseLibrary(MyIntuitionBase);
    }
}

#endif

