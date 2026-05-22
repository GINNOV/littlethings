/*
 * RConfig -- Replacement Library Configuration
 *   Copyright 1992 by Anthon Pang, Omni Communications Products
 *
 * Source File: rconfig.c
 * Description: main IDCMP loop
 * Comments: main() located here
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <utility/tagitem.h>
#include <dos/dos.h>
#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <libraries/asl.h>
#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>
#include <clib/asl_protos.h>
#include <stdarg.h>

#include "rc2.h"                /* GUI */
#include "rconfig_rev.h"        /* revision info */

static char *VERSION_TAG=VERSTAG;

/*
 *  Global variables
 */
extern void *SysBase;
extern int Enable_Abort;
struct GadToolsBase     *GadToolsBase;
struct GfxBase          *GfxBase;
struct IntuitionBase    *IntuitionBase;
struct Library          *AslBase;

struct Gadget *IObject;
ULONG IClass;
UWORD Code;
UWORD Qualifier;

int alloca_mode=0;
int setjmp_mode=0;
int main_mode=0;
int stkchk_mode=0;

int pathlength=0;

struct FileRequester *fr;
struct TagItemA frtags[] = {
    ASL_Hail,       (ULONG *)"New Output Directory",
    ASL_ExtFlags1,  (ULONG *)FIL1F_NOFILES,
    TAG_DONE
};


#define THRESHHOLD  2768    /* min. threshhold */
#define STACKSIZE   8192    /* must be greater than threshhold */
#define CONTEXTSIZE 128     /* arbitrary minimum */

int integer_mode=0;     /* 32 bits vs 16 bits */
int data_mode=0;        /* small model vs large model */

#if 0     /* -ss option works */
#define Say(s) Write(Output(), (char*)(s), sizeof(s))
#else
void Say(char s[]) { Write(Output(), (char*)(s), strlen(s)); }
#endif

/* on/off is bit 0 */
#define TOGGLE_SIMPLE(v)    v = (~v) & 1

/* on/off is bit 1 */
#define TOGGLE_MASK(v)      v = (v & 1) | ((~v) & 2)

#define UPDATE_CYCLE(v,g)   GT_SetGadgetAttrs(RConfigGadgets[g], \
      RConfigWnd, NULL, GTCY_Active, v & 1, TAG_END)
#define UPDATE_TOGGLE(v,g)  GT_SetGadgetAttrs(RConfigGadgets[g], \
      RConfigWnd, NULL, GTCB_Checked, v & 2 ? TRUE : FALSE, TAG_END)
#define UPDATE_TOGGLE_SIMPLE(v,g)   GT_SetGadgetAttrs(RConfigGadgets[g], \
      RConfigWnd, NULL, GTCB_Checked, v & 1, TAG_END)

/* cycle value is bit 0 */
#define CYCLE_SIMPLE(v)     v = (~v) & 1
#define CYCLE_MASK(v)       v = (v & 2) | ((~v) & 1)

#define FWDKEYCYCLE(v) if (v==3) v = 0; else if (v==2) v = 3; else v |= 2;
#define RVSKEYCYCLE(v) if (v==3) v = 2; else if (v==2) v = 0; else v = 3;

extern long ReadIMsg(struct Window *iwnd);
extern void ClearMsgPort(struct MsgPort *mport);
extern void GenLib();

int RConfigWndProc();

void main() {
    int ok=0;

    if (((struct ExecBase *)SysBase)->LibNode.lib_Version < 37) {
        Say("RConfig requires Amiga OS 2.04 or above.\n");
        exit(10);
    }

    Enable_Abort = 0;

    GfxBase = (struct GfxBase *)OpenLibrary((UBYTE*)"graphics.library", 37l);
    if (GfxBase) {
        IntuitionBase = (struct IntuitionBase *)OpenLibrary((UBYTE*)"intuition.library", 37l);
        if (IntuitionBase) {
            GadToolsBase = (struct GadToolsBase *)OpenLibrary((UBYTE*)"gadtools.library", 37l);
            if (GadToolsBase) {
                AslBase = (struct Library *)OpenLibrary((UBYTE*)"asl.library", 37l);
                if (AslBase) {
                    if (fr = (struct FileRequester *)AllocAslRequest(ASL_FileRequest, (struct TagItem *)frtags)) {
                        ok = RConfigWndProc();
                        FreeAslRequest(fr);
                    } else {
                        Say("Unable to create file requester\n");
                    }
                    CloseLibrary((struct Library *)AslBase);
                } else {
                    Say("Unable to open asl.library\n");
                }
                CloseLibrary((struct Library *)GadToolsBase);
            } else {
                Say("Unable to open gadtools.library\n");
            }
            CloseLibrary((struct Library *)IntuitionBase);
        } else {
            Say("Unable to open intuition.library\n");
        }
        CloseLibrary((struct Library *)GfxBase);
    } else {      
        Say("Unable to open graphics.library\n");
    }

    if (ok) ok=20;

    exit(ok);
}

struct EasyStruct myAbout = {
    sizeof(struct EasyStruct),
    0,
    (UBYTE *)"About RConfig",
    (UBYTE *)"         RConfig v1.1\n\n"             \
             " Replacement Library Manager\n\n"     \
             "Copyright 1992 by Anthon Pang,\n"     \
             " Omni Communications Products\n\n"    \
             "    Freely Redistributable",
    (UBYTE *)"Continue"
};

int RConfigWndProc() {
    int notok;
    UWORD menu, item, sub, sel;
    struct MenuItem *Next;

    notok = SetupScreen();
    if (notok) {
        Say("Unable to setup screen\n");

RConfigWndProcFail:

        CloseDownScreen();
        return 1; /* error */
    }

    notok = OpenRConfigWindow();
    if (notok) {
        Say("Unable to open window\n");

RConfigWndProcFailOther:

        CloseRConfigWindow();
        goto RConfigWndProcFail;
    }

    while (1) {
        WaitPort(RConfigWnd->UserPort);
        while(ReadIMsg(RConfigWnd)) {

            switch (IClass) {
              case IDCMP_REFRESHWINDOW:
                GT_BeginRefresh(RConfigWnd);
                RConfigRender(); /* re-draw texts and boxes */
                GT_EndRefresh(RConfigWnd, TRUE);
                break;

              case IDCMP_MENUPICK:
                sel = Code;
                while (sel != MENUNULL) {
                    menu = MENUNUM(Code);
                    item = ITEMNUM(Code);
                    sub  = SUBNUM(Code);

                    switch (menu) {
                      case 0:
                        switch (item) {
                          case 0:
                            EasyRequest(NULL, &myAbout, NULL);
                            break;

                          case 2:
                            if (AslRequest(fr, NULL))
                                pathlength = strlen(fr->rf_Dir);
                            break;

                          case 4:
                            goto RConfigQuit;
                            break; /* not reached */
                        }
                        break;
                    }
                    Next = ItemAddress(RConfigMenus, (unsigned long)sel);
                    sel = Next->NextSelect;
                }
                break;

              case IDCMP_CLOSEWINDOW:
                goto RConfigQuit;
                break;

              case IDCMP_GADGETUP:
                switch (IObject->GadgetID) {
                  case GD_ALLOCA_CHK:
                    TOGGLE_MASK(alloca_mode);
                    break;
                  case GD_STKCHK_CHK:
                    TOGGLE_MASK(stkchk_mode);
                    break;
                  case GD_SETJMP_CHK:
                    TOGGLE_SIMPLE(setjmp_mode);
                    break;
                  case GD_MAIN_CHK:
                    TOGGLE_MASK(main_mode);
                    break;
                  case GD_ALLOCA_TYPE:
                    CYCLE_MASK(alloca_mode);
                    break;
                  case GD_STKCHK_TYPE:
                    CYCLE_MASK(stkchk_mode);
                    break;
                  case GD_MAIN_TYPE:
                    CYCLE_MASK(main_mode);
                    break;
                  case GD_INTEGER_SIZE:
                    CYCLE_SIMPLE(integer_mode);
                    break;
                  case GD_DATA_SIZE:
                    CYCLE_SIMPLE(data_mode);
                    break;
                  case GD_CANCEL:
                    goto RConfigQuit;
                    break;
                  case GD_GENLIB:
                    GenLib();
                    break;
                  case GD_Flags:
                    CCOPTS();
                    break;
                }
                break;

              case IDCMP_VANILLAKEY:
                switch (Code) {
                  case 'g':
                  case 'G':
                    /* flash button? */
                    GenLib();
                    break;
                  case 'i':
                  case 'I':
                    CYCLE_SIMPLE(integer_mode);
                    UPDATE_CYCLE(integer_mode, GD_INTEGER_SIZE);
                    break;
                  case 'd':
                  case 'D':
                    CYCLE_SIMPLE(data_mode);
                    UPDATE_CYCLE(data_mode, GD_DATA_SIZE);
                    break;
                  case 'j':
                  case 'J':
                    TOGGLE_SIMPLE(setjmp_mode);
                    UPDATE_TOGGLE_SIMPLE(setjmp_mode, GD_SETJMP_CHK);
                    break;
                  case 'a':
                    FWDKEYCYCLE(alloca_mode);
                    UPDATE_TOGGLE(alloca_mode, GD_ALLOCA_CHK);
                    UPDATE_CYCLE(alloca_mode, GD_ALLOCA_TYPE);
                    break;
                  case 'A':
                    RVSKEYCYCLE(alloca_mode);
                    UPDATE_TOGGLE(alloca_mode, GD_ALLOCA_CHK);
                    UPDATE_CYCLE(alloca_mode, GD_ALLOCA_TYPE);
                    break;
                  case 'm':
                    FWDKEYCYCLE(main_mode);
                    UPDATE_TOGGLE(main_mode, GD_MAIN_CHK);
                    UPDATE_CYCLE(main_mode, GD_MAIN_TYPE);
                    break;
                  case 'M':
                    RVSKEYCYCLE(main_mode);
                    UPDATE_TOGGLE(main_mode, GD_MAIN_CHK);
                    UPDATE_CYCLE(main_mode, GD_MAIN_TYPE);
                    break;
                  case 's':
                    FWDKEYCYCLE(stkchk_mode);
                    UPDATE_TOGGLE(stkchk_mode, GD_STKCHK_CHK);
                    UPDATE_CYCLE(stkchk_mode, GD_STKCHK_TYPE);
                    break;
                  case 'S':
                    RVSKEYCYCLE(stkchk_mode);
                    UPDATE_TOGGLE(stkchk_mode, GD_STKCHK_CHK);
                    UPDATE_CYCLE(stkchk_mode, GD_STKCHK_TYPE);
                    break;
                }
                break;
            }
        }
    }

RConfigQuit:
    ClearMsgPort(RConfigWnd->UserPort);

    CloseRConfigWindow();

    CloseDownScreen();

    return 0;
}
