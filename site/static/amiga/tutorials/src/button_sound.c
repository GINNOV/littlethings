/*
 * button_sound.c
 * Interactive Audio Playback in C using AmigaOS 3.0+ DataTypes
 */

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/datatypes.h>
#include <datatypes/soundclass.h>
#include <stdio.h>
#include <stdlib.h>

#define WIN_WIDTH       320
#define WIN_HEIGHT      100
#define BUTTON_LEFT     50
#define BUTTON_TOP      30
#define BUTTON_RIGHT    270
#define BUTTON_BOTTOM   70
#define PEN_PRIMARY     1
#define PEN_SECONDARY   2

struct Library *DOSBase       = NULL;
struct Library *GfxBase       = NULL;
struct Library *IntuitionBase = NULL;
struct Library *DataTypesBase = NULL;
struct Window  *win           = NULL;
Object         *sound_obj     = NULL;

static void cleanup(int status) {
    if (sound_obj)     DisposeDTObject(sound_obj);
    if (win)           CloseWindow(win);
    if (DataTypesBase) CloseLibrary(DataTypesBase);
    if (DOSBase)       CloseLibrary(DOSBase);
    if (IntuitionBase) CloseLibrary(IntuitionBase);
    if (GfxBase)       CloseLibrary(GfxBase);
    exit(status);
}

static void draw_button(int pressed) {
    UWORD fill_pen = pressed ? PEN_SECONDARY : PEN_PRIMARY;
    UWORD text_pen = pressed ? PEN_PRIMARY   : PEN_SECONDARY;
    if (!win || !win->RPort) return;
    SetAPen(win->RPort, fill_pen);
    RectFill(win->RPort, BUTTON_LEFT, BUTTON_TOP, BUTTON_RIGHT, BUTTON_BOTTOM);
    SetAPen(win->RPort, text_pen);
    Move(win->RPort, 110, 52);
    Text(win->RPort, "Play Sound", 10);
}

int main(void) {
    GfxBase       = OpenLibrary("graphics.library", 39);
    IntuitionBase = OpenLibrary("intuition.library", 39);
    DOSBase       = OpenLibrary("dos.library", 39);
    DataTypesBase = OpenLibrary("datatypes.library", 39);
    if (!GfxBase || !IntuitionBase || !DOSBase || !DataTypesBase) {
        puts("Error: Requires AmigaOS 3.0+ (V39) libraries.");
        cleanup(20);
    }

    sound_obj = NewDTObject("sound.8svx", DTA_SourceType, DTST_FILE, DTA_GroupID, GID_SOUND, TAG_END);
    if (!sound_obj) {
        puts("Error: Could not load sound.8svx from current directory.");
        cleanup(20);
    }

    win = OpenWindowTags(NULL,
        WA_Left, 20, WA_Top, 20, WA_Width, WIN_WIDTH, WA_Height, WIN_HEIGHT,
        WA_Title, (ULONG)"C Sound Player",
        WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_MOUSEBUTTONS,
        WA_Flags, WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET | WFLG_ACTIVATE,
        TAG_END);
    if (!win) {
        puts("Error: Could not open window.");
        cleanup(20);
    }

    draw_button(0);

    BOOL running = TRUE;
    while (running) {
        struct IntuiMessage *msg;
        Wait(1L << win->UserPort->mp_SigBit);
        while ((msg = (struct IntuiMessage *)GetMsg(win->UserPort))) {
            ULONG msgClass = msg->Class;
            UWORD msgCode  = msg->Code;
            WORD  mouseX   = msg->MouseX;
            WORD  mouseY   = msg->MouseY;
            ReplyMsg((struct Message *)msg);

            if (msgClass == IDCMP_CLOSEWINDOW) {
                running = FALSE;
            } else if (msgClass == IDCMP_MOUSEBUTTONS) {
                if (msgCode == SELECTDOWN) {
                    if (mouseX >= BUTTON_LEFT && mouseX <= BUTTON_RIGHT &&
                        mouseY >= BUTTON_TOP  && mouseY <= BUTTON_BOTTOM) {
                        draw_button(1);
                        DoDTMethod(sound_obj, NULL, NULL, DTM_PLAY, NULL, SNDA_DEST_AUDION, 0, TAG_END);
                    }
                } else if (msgCode == SELECTUP) {
                    draw_button(0);
                }
            }
        }
    }

    cleanup(0);
    return 0;
}
