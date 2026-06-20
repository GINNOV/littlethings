#ifndef _VBCCINLINE_INTUITION_H
#define _VBCCINLINE_INTUITION_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __OpenIntuition(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define OpenIntuition() __OpenIntuition(IntuitionBase)

VOID __Intuition(void *, struct InputEvent * iEvent) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define Intuition(iEvent) __Intuition(IntuitionBase, (iEvent))

UWORD __AddGadget(void *, struct Window * window, struct Gadget * gadget, ULONG position) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AddGadget(window, gadget, position) __AddGadget(IntuitionBase, (window), (gadget), (position))

BOOL __ClearDMRequest(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define ClearDMRequest(window) __ClearDMRequest(IntuitionBase, (window))

VOID __ClearMenuStrip(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define ClearMenuStrip(window) __ClearMenuStrip(IntuitionBase, (window))

VOID __ClearPointer(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define ClearPointer(window) __ClearPointer(IntuitionBase, (window))

BOOL __CloseScreen(void *, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define CloseScreen(screen) __CloseScreen(IntuitionBase, (screen))

VOID __CloseWindow(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define CloseWindow(window) __CloseWindow(IntuitionBase, (window))

LONG __CloseWorkBench(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define CloseWorkBench() __CloseWorkBench(IntuitionBase)

VOID __CurrentTime(void *, ULONG * seconds, ULONG * micros) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define CurrentTime(seconds, micros) __CurrentTime(IntuitionBase, (seconds), (micros))

BOOL __DisplayAlert(void *, ULONG alertNumber, CONST_STRPTR string, ULONG height) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define DisplayAlert(alertNumber, string, height) __DisplayAlert(IntuitionBase, (alertNumber), (string), (height))

VOID __DisplayBeep(void *, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define DisplayBeep(screen) __DisplayBeep(IntuitionBase, (screen))

BOOL __DoubleClick(void *, ULONG sSeconds, ULONG sMicros, ULONG cSeconds, ULONG cMicros) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define DoubleClick(sSeconds, sMicros, cSeconds, cMicros) __DoubleClick(IntuitionBase, (sSeconds), (sMicros), (cSeconds), (cMicros))

VOID __DrawBorder(void *, struct RastPort * rp, CONST struct Border * border, LONG leftOffset, LONG topOffset) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define DrawBorder(rp, border, leftOffset, topOffset) __DrawBorder(IntuitionBase, (rp), (border), (leftOffset), (topOffset))

VOID __DrawImage(void *, struct RastPort * rp, struct Image * image, LONG leftOffset, LONG topOffset) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define DrawImage(rp, image, leftOffset, topOffset) __DrawImage(IntuitionBase, (rp), (image), (leftOffset), (topOffset))

VOID __EndRequest(void *, struct Requester * requester, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define EndRequest(requester, window) __EndRequest(IntuitionBase, (requester), (window))

struct Preferences * __GetDefPrefs(void *, struct Preferences * preferences, LONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define GetDefPrefs(preferences, size) __GetDefPrefs(IntuitionBase, (preferences), (size))

struct Preferences * __GetPrefs(void *, struct Preferences * preferences, LONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define GetPrefs(preferences, size) __GetPrefs(IntuitionBase, (preferences), (size))

VOID __InitRequester(void *, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define InitRequester(requester) __InitRequester(IntuitionBase, (requester))

struct MenuItem * __ItemAddress(void *, CONST struct Menu * menuStrip, ULONG menuNumber) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define ItemAddress(menuStrip, menuNumber) __ItemAddress(IntuitionBase, (menuStrip), (menuNumber))

BOOL __ModifyIDCMP(void *, struct Window * window, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define ModifyIDCMP(window, flags) __ModifyIDCMP(IntuitionBase, (window), (flags))

VOID __ModifyProp(void *, struct Gadget * gadget, struct Window * window, struct Requester * requester, ULONG flags, ULONG horizPot, ULONG vertPot, ULONG horizBody, ULONG vertBody) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,8(2)\n"
	"\tstw\t10,12(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,16(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define ModifyProp(gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody) __ModifyProp(IntuitionBase, (gadget), (window), (requester), (flags), (horizPot), (vertPot), (horizBody), (vertBody))

VOID __MoveScreen(void *, struct Screen * screen, LONG dx, LONG dy) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define MoveScreen(screen, dx, dy) __MoveScreen(IntuitionBase, (screen), (dx), (dy))

VOID __MoveWindow(void *, struct Window * window, LONG dx, LONG dy) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define MoveWindow(window, dx, dy) __MoveWindow(IntuitionBase, (window), (dx), (dy))

VOID __OffGadget(void *, struct Gadget * gadget, struct Window * window, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define OffGadget(gadget, window, requester) __OffGadget(IntuitionBase, (gadget), (window), (requester))

VOID __OffMenu(void *, struct Window * window, ULONG menuNumber) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define OffMenu(window, menuNumber) __OffMenu(IntuitionBase, (window), (menuNumber))

VOID __OnGadget(void *, struct Gadget * gadget, struct Window * window, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define OnGadget(gadget, window, requester) __OnGadget(IntuitionBase, (gadget), (window), (requester))

VOID __OnMenu(void *, struct Window * window, ULONG menuNumber) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define OnMenu(window, menuNumber) __OnMenu(IntuitionBase, (window), (menuNumber))

struct Screen * __OpenScreen(void *, CONST struct NewScreen * newScreen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define OpenScreen(newScreen) __OpenScreen(IntuitionBase, (newScreen))

struct Window * __OpenWindow(void *, CONST struct NewWindow * newWindow) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define OpenWindow(newWindow) __OpenWindow(IntuitionBase, (newWindow))

ULONG __OpenWorkBench(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define OpenWorkBench() __OpenWorkBench(IntuitionBase)

VOID __PrintIText(void *, struct RastPort * rp, CONST struct IntuiText * iText, LONG left, LONG top) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define PrintIText(rp, iText, left, top) __PrintIText(IntuitionBase, (rp), (iText), (left), (top))

VOID __RefreshGadgets(void *, struct Gadget * gadgets, struct Window * window, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define RefreshGadgets(gadgets, window, requester) __RefreshGadgets(IntuitionBase, (gadgets), (window), (requester))

UWORD __RemoveGadget(void *, struct Window * window, struct Gadget * gadget) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define RemoveGadget(window, gadget) __RemoveGadget(IntuitionBase, (window), (gadget))

VOID __ReportMouse(void *, LONG flag, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define ReportMouse(flag, window) __ReportMouse(IntuitionBase, (flag), (window))

BOOL __Request(void *, struct Requester * requester, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define Request(requester, window) __Request(IntuitionBase, (requester), (window))

VOID __ScreenToBack(void *, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define ScreenToBack(screen) __ScreenToBack(IntuitionBase, (screen))

VOID __ScreenToFront(void *, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define ScreenToFront(screen) __ScreenToFront(IntuitionBase, (screen))

BOOL __SetDMRequest(void *, struct Window * window, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define SetDMRequest(window, requester) __SetDMRequest(IntuitionBase, (window), (requester))

BOOL __SetMenuStrip(void *, struct Window * window, struct Menu * menu) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define SetMenuStrip(window, menu) __SetMenuStrip(IntuitionBase, (window), (menu))

VOID __SetPointer(void *, struct Window * window, UWORD * pointer, LONG height, LONG width, LONG xOffset, LONG yOffset) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define SetPointer(window, pointer, height, width, xOffset, yOffset) __SetPointer(IntuitionBase, (window), (pointer), (height), (width), (xOffset), (yOffset))

VOID __SetWindowTitles(void *, struct Window * window, CONST_STRPTR windowTitle, CONST_STRPTR screenTitle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define SetWindowTitles(window, windowTitle, screenTitle) __SetWindowTitles(IntuitionBase, (window), (windowTitle), (screenTitle))

VOID __ShowTitle(void *, struct Screen * screen, LONG showIt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define ShowTitle(screen, showIt) __ShowTitle(IntuitionBase, (screen), (showIt))

VOID __SizeWindow(void *, struct Window * window, LONG dx, LONG dy) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define SizeWindow(window, dx, dy) __SizeWindow(IntuitionBase, (window), (dx), (dy))

struct View * __ViewAddress(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define ViewAddress() __ViewAddress(IntuitionBase)

struct ViewPort * __ViewPortAddress(void *, CONST struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define ViewPortAddress(window) __ViewPortAddress(IntuitionBase, (window))

VOID __WindowToBack(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define WindowToBack(window) __WindowToBack(IntuitionBase, (window))

VOID __WindowToFront(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-312\n"
	"\tbctrl";
#define WindowToFront(window) __WindowToFront(IntuitionBase, (window))

BOOL __WindowLimits(void *, struct Window * window, LONG widthMin, LONG heightMin, ULONG widthMax, ULONG heightMax) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-318\n"
	"\tbctrl";
#define WindowLimits(window, widthMin, heightMin, widthMax, heightMax) __WindowLimits(IntuitionBase, (window), (widthMin), (heightMin), (widthMax), (heightMax))

struct Preferences * __SetPrefs(void *, CONST struct Preferences * preferences, LONG size, LONG inform) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-324\n"
	"\tbctrl";
#define SetPrefs(preferences, size, inform) __SetPrefs(IntuitionBase, (preferences), (size), (inform))

LONG __IntuiTextLength(void *, CONST struct IntuiText * iText) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-330\n"
	"\tbctrl";
#define IntuiTextLength(iText) __IntuiTextLength(IntuitionBase, (iText))

BOOL __WBenchToBack(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-336\n"
	"\tbctrl";
#define WBenchToBack() __WBenchToBack(IntuitionBase)

BOOL __WBenchToFront(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-342\n"
	"\tbctrl";
#define WBenchToFront() __WBenchToFront(IntuitionBase)

BOOL __AutoRequest(void *, struct Window * window, CONST struct IntuiText * body, CONST struct IntuiText * posText, CONST struct IntuiText * negText, ULONG pFlag, ULONG nFlag, ULONG width, ULONG height) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,0(2)\n"
	"\tstw\t9,4(2)\n"
	"\tstw\t10,8(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,12(2)\n"
	"\tli\t3,-348\n"
	"\tbctrl";
#define AutoRequest(window, body, posText, negText, pFlag, nFlag, width, height) __AutoRequest(IntuitionBase, (window), (body), (posText), (negText), (pFlag), (nFlag), (width), (height))

VOID __BeginRefresh(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-354\n"
	"\tbctrl";
#define BeginRefresh(window) __BeginRefresh(IntuitionBase, (window))

struct Window * __BuildSysRequest(void *, struct Window * window, CONST struct IntuiText * body, CONST struct IntuiText * posText, CONST struct IntuiText * negText, ULONG flags, ULONG width, ULONG height) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,0(2)\n"
	"\tstw\t9,4(2)\n"
	"\tstw\t10,8(2)\n"
	"\tli\t3,-360\n"
	"\tbctrl";
#define BuildSysRequest(window, body, posText, negText, flags, width, height) __BuildSysRequest(IntuitionBase, (window), (body), (posText), (negText), (flags), (width), (height))

VOID __EndRefresh(void *, struct Window * window, LONG complete) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-366\n"
	"\tbctrl";
#define EndRefresh(window, complete) __EndRefresh(IntuitionBase, (window), (complete))

VOID __FreeSysRequest(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-372\n"
	"\tbctrl";
#define FreeSysRequest(window) __FreeSysRequest(IntuitionBase, (window))

LONG __MakeScreen(void *, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-378\n"
	"\tbctrl";
#define MakeScreen(screen) __MakeScreen(IntuitionBase, (screen))

LONG __RemakeDisplay(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-384\n"
	"\tbctrl";
#define RemakeDisplay() __RemakeDisplay(IntuitionBase)

LONG __RethinkDisplay(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-390\n"
	"\tbctrl";
#define RethinkDisplay() __RethinkDisplay(IntuitionBase)

APTR __AllocRemember(void *, struct Remember ** rememberKey, ULONG size, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-396\n"
	"\tbctrl";
#define AllocRemember(rememberKey, size, flags) __AllocRemember(IntuitionBase, (rememberKey), (size), (flags))

VOID __FreeRemember(void *, struct Remember ** rememberKey, LONG reallyForget) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-408\n"
	"\tbctrl";
#define FreeRemember(rememberKey, reallyForget) __FreeRemember(IntuitionBase, (rememberKey), (reallyForget))

ULONG __LockIBase(void *, ULONG dontknow) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-414\n"
	"\tbctrl";
#define LockIBase(dontknow) __LockIBase(IntuitionBase, (dontknow))

VOID __UnlockIBase(void *, ULONG ibLock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-420\n"
	"\tbctrl";
#define UnlockIBase(ibLock) __UnlockIBase(IntuitionBase, (ibLock))

LONG __GetScreenData(void *, APTR buffer, ULONG size, ULONG type, CONST struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-426\n"
	"\tbctrl";
#define GetScreenData(buffer, size, type, screen) __GetScreenData(IntuitionBase, (buffer), (size), (type), (screen))

VOID __RefreshGList(void *, struct Gadget * gadgets, struct Window * window, struct Requester * requester, LONG numGad) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tli\t3,-432\n"
	"\tbctrl";
#define RefreshGList(gadgets, window, requester, numGad) __RefreshGList(IntuitionBase, (gadgets), (window), (requester), (numGad))

UWORD __AddGList(void *, struct Window * window, struct Gadget * gadget, ULONG position, LONG numGad, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-438\n"
	"\tbctrl";
#define AddGList(window, gadget, position, numGad, requester) __AddGList(IntuitionBase, (window), (gadget), (position), (numGad), (requester))

UWORD __RemoveGList(void *, struct Window * remPtr, struct Gadget * gadget, LONG numGad) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-444\n"
	"\tbctrl";
#define RemoveGList(remPtr, gadget, numGad) __RemoveGList(IntuitionBase, (remPtr), (gadget), (numGad))

VOID __ActivateWindow(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-450\n"
	"\tbctrl";
#define ActivateWindow(window) __ActivateWindow(IntuitionBase, (window))

VOID __RefreshWindowFrame(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-456\n"
	"\tbctrl";
#define RefreshWindowFrame(window) __RefreshWindowFrame(IntuitionBase, (window))

BOOL __ActivateGadget(void *, struct Gadget * gadgets, struct Window * window, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-462\n"
	"\tbctrl";
#define ActivateGadget(gadgets, window, requester) __ActivateGadget(IntuitionBase, (gadgets), (window), (requester))

VOID __NewModifyProp(void *, struct Gadget * gadget, struct Window * window, struct Requester * requester, ULONG flags, ULONG horizPot, ULONG vertPot, ULONG horizBody, ULONG vertBody, LONG numGad) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,8(2)\n"
	"\tstw\t10,12(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,16(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,20(2)\n"
	"\tli\t3,-468\n"
	"\tbctrl";
#define NewModifyProp(gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody, numGad) __NewModifyProp(IntuitionBase, (gadget), (window), (requester), (flags), (horizPot), (vertPot), (horizBody), (vertBody), (numGad))

LONG __QueryOverscan(void *, ULONG displayID, struct Rectangle * rect, LONG oScanType) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-474\n"
	"\tbctrl";
#define QueryOverscan(displayID, rect, oScanType) __QueryOverscan(IntuitionBase, (displayID), (rect), (oScanType))

VOID __MoveWindowInFrontOf(void *, struct Window * window, struct Window * behindWindow) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-480\n"
	"\tbctrl";
#define MoveWindowInFrontOf(window, behindWindow) __MoveWindowInFrontOf(IntuitionBase, (window), (behindWindow))

VOID __ChangeWindowBox(void *, struct Window * window, LONG left, LONG top, LONG width, LONG height) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-486\n"
	"\tbctrl";
#define ChangeWindowBox(window, left, top, width, height) __ChangeWindowBox(IntuitionBase, (window), (left), (top), (width), (height))

struct Hook * __SetEditHook(void *, struct Hook * hook) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-492\n"
	"\tbctrl";
#define SetEditHook(hook) __SetEditHook(IntuitionBase, (hook))

LONG __SetMouseQueue(void *, struct Window * window, ULONG queueLength) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-498\n"
	"\tbctrl";
#define SetMouseQueue(window, queueLength) __SetMouseQueue(IntuitionBase, (window), (queueLength))

VOID __ZipWindow(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-504\n"
	"\tbctrl";
#define ZipWindow(window) __ZipWindow(IntuitionBase, (window))

struct Screen * __LockPubScreen(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-510\n"
	"\tbctrl";
#define LockPubScreen(name) __LockPubScreen(IntuitionBase, (name))

VOID __UnlockPubScreen(void *, CONST_STRPTR name, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-516\n"
	"\tbctrl";
#define UnlockPubScreen(name, screen) __UnlockPubScreen(IntuitionBase, (name), (screen))

struct List * __LockPubScreenList(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-522\n"
	"\tbctrl";
#define LockPubScreenList() __LockPubScreenList(IntuitionBase)

VOID __UnlockPubScreenList(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-528\n"
	"\tbctrl";
#define UnlockPubScreenList() __UnlockPubScreenList(IntuitionBase)

STRPTR __NextPubScreen(void *, CONST struct Screen * screen, STRPTR namebuf) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-534\n"
	"\tbctrl";
#define NextPubScreen(screen, namebuf) __NextPubScreen(IntuitionBase, (screen), (namebuf))

VOID __SetDefaultPubScreen(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-540\n"
	"\tbctrl";
#define SetDefaultPubScreen(name) __SetDefaultPubScreen(IntuitionBase, (name))

UWORD __SetPubScreenModes(void *, ULONG modes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-546\n"
	"\tbctrl";
#define SetPubScreenModes(modes) __SetPubScreenModes(IntuitionBase, (modes))

UWORD __PubScreenStatus(void *, struct Screen * screen, ULONG statusFlags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-552\n"
	"\tbctrl";
#define PubScreenStatus(screen, statusFlags) __PubScreenStatus(IntuitionBase, (screen), (statusFlags))

struct RastPort * __ObtainGIRPort(void *, struct GadgetInfo * gInfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-558\n"
	"\tbctrl";
#define ObtainGIRPort(gInfo) __ObtainGIRPort(IntuitionBase, (gInfo))

VOID __ReleaseGIRPort(void *, struct RastPort * rp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-564\n"
	"\tbctrl";
#define ReleaseGIRPort(rp) __ReleaseGIRPort(IntuitionBase, (rp))

VOID __GadgetMouse(void *, struct Gadget * gadget, struct GadgetInfo * gInfo, WORD * mousePoint) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-570\n"
	"\tbctrl";
#define GadgetMouse(gadget, gInfo, mousePoint) __GadgetMouse(IntuitionBase, (gadget), (gInfo), (mousePoint))

VOID __GetDefaultPubScreen(void *, STRPTR nameBuffer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-582\n"
	"\tbctrl";
#define GetDefaultPubScreen(nameBuffer) __GetDefaultPubScreen(IntuitionBase, (nameBuffer))

LONG __EasyRequestArgs(void *, struct Window * window, CONST struct EasyStruct * easyStruct, ULONG * idcmpPtr, CONST APTR args) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-588\n"
	"\tbctrl";
#define EasyRequestArgs(window, easyStruct, idcmpPtr, args) __EasyRequestArgs(IntuitionBase, (window), (easyStruct), (idcmpPtr), (args))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __EasyRequest(void *, struct Window * window, CONST struct EasyStruct * easyStruct, ULONG * idcmpPtr, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-588\n"
	"\tbctrl";
#define EasyRequest(window, easyStruct, ...) __EasyRequest(IntuitionBase, (window), (easyStruct), __VA_ARGS__)
#endif

struct Window * __BuildEasyRequestArgs(void *, struct Window * window, CONST struct EasyStruct * easyStruct, ULONG idcmp, CONST APTR args) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-594\n"
	"\tbctrl";
#define BuildEasyRequestArgs(window, easyStruct, idcmp, args) __BuildEasyRequestArgs(IntuitionBase, (window), (easyStruct), (idcmp), (args))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Window * __linearvarargs __BuildEasyRequest(void *, struct Window * window, CONST struct EasyStruct * easyStruct, ULONG idcmp, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-594\n"
	"\tbctrl";
#define BuildEasyRequest(window, easyStruct, ...) __BuildEasyRequest(IntuitionBase, (window), (easyStruct), __VA_ARGS__)
#endif

LONG __SysReqHandler(void *, struct Window * window, ULONG * idcmpPtr, LONG waitInput) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-600\n"
	"\tbctrl";
#define SysReqHandler(window, idcmpPtr, waitInput) __SysReqHandler(IntuitionBase, (window), (idcmpPtr), (waitInput))

struct Window * __OpenWindowTagList(void *, CONST struct NewWindow * newWindow, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-606\n"
	"\tbctrl";
#define OpenWindowTagList(newWindow, tagList) __OpenWindowTagList(IntuitionBase, (newWindow), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Window * __linearvarargs __OpenWindowTags(void *, CONST struct NewWindow * newWindow, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-606\n"
	"\tbctrl";
#define OpenWindowTags(newWindow, ...) __OpenWindowTags(IntuitionBase, (newWindow), __VA_ARGS__)
#endif

struct Screen * __OpenScreenTagList(void *, CONST struct NewScreen * newScreen, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-612\n"
	"\tbctrl";
#define OpenScreenTagList(newScreen, tagList) __OpenScreenTagList(IntuitionBase, (newScreen), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Screen * __linearvarargs __OpenScreenTags(void *, CONST struct NewScreen * newScreen, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-612\n"
	"\tbctrl";
#define OpenScreenTags(newScreen, ...) __OpenScreenTags(IntuitionBase, (newScreen), __VA_ARGS__)
#endif

VOID __DrawImageState(void *, struct RastPort * rp, struct Image * image, LONG leftOffset, LONG topOffset, ULONG state, CONST struct DrawInfo * drawInfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,40(2)\n"
	"\tli\t3,-618\n"
	"\tbctrl";
#define DrawImageState(rp, image, leftOffset, topOffset, state, drawInfo) __DrawImageState(IntuitionBase, (rp), (image), (leftOffset), (topOffset), (state), (drawInfo))

BOOL __PointInImage(void *, ULONG point, struct Image * image) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-624\n"
	"\tbctrl";
#define PointInImage(point, image) __PointInImage(IntuitionBase, (point), (image))

VOID __EraseImage(void *, struct RastPort * rp, struct Image * image, LONG leftOffset, LONG topOffset) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-630\n"
	"\tbctrl";
#define EraseImage(rp, image, leftOffset, topOffset) __EraseImage(IntuitionBase, (rp), (image), (leftOffset), (topOffset))

APTR __NewObjectA(void *, struct IClass * classPtr, CONST_STRPTR classID, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-636\n"
	"\tbctrl";
#define NewObjectA(classPtr, classID, tagList) __NewObjectA(IntuitionBase, (classPtr), (classID), (tagList))

VOID __DisposeObject(void *, APTR object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-642\n"
	"\tbctrl";
#define DisposeObject(object) __DisposeObject(IntuitionBase, (object))

ULONG __SetAttrsA(void *, APTR object, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-648\n"
	"\tbctrl";
#define SetAttrsA(object, tagList) __SetAttrsA(IntuitionBase, (object), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __SetAttrs(void *, APTR object, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-648\n"
	"\tbctrl";
#define SetAttrs(object, ...) __SetAttrs(IntuitionBase, (object), __VA_ARGS__)
#endif

ULONG __GetAttr(void *, ULONG attrID, APTR object, ULONG * storagePtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-654\n"
	"\tbctrl";
#define GetAttr(attrID, object, storagePtr) __GetAttr(IntuitionBase, (attrID), (object), (storagePtr))

ULONG __SetGadgetAttrsA(void *, struct Gadget * gadget, struct Window * window, struct Requester * requester, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-660\n"
	"\tbctrl";
#define SetGadgetAttrsA(gadget, window, requester, tagList) __SetGadgetAttrsA(IntuitionBase, (gadget), (window), (requester), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __SetGadgetAttrs(void *, struct Gadget * gadget, struct Window * window, struct Requester * requester, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-660\n"
	"\tbctrl";
#define SetGadgetAttrs(gadget, window, requester, ...) __SetGadgetAttrs(IntuitionBase, (gadget), (window), (requester), __VA_ARGS__)
#endif

APTR __NextObject(void *, APTR objectPtrPtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-666\n"
	"\tbctrl";
#define NextObject(objectPtrPtr) __NextObject(IntuitionBase, (objectPtrPtr))

struct IClass * __MakeClass(void *, CONST_STRPTR classID, CONST_STRPTR superClassID, CONST struct IClass * superClassPtr, ULONG instanceSize, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tli\t3,-678\n"
	"\tbctrl";
#define MakeClass(classID, superClassID, superClassPtr, instanceSize, flags) __MakeClass(IntuitionBase, (classID), (superClassID), (superClassPtr), (instanceSize), (flags))

VOID __AddClass(void *, struct IClass * classPtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-684\n"
	"\tbctrl";
#define AddClass(classPtr) __AddClass(IntuitionBase, (classPtr))

struct DrawInfo * __GetScreenDrawInfo(void *, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-690\n"
	"\tbctrl";
#define GetScreenDrawInfo(screen) __GetScreenDrawInfo(IntuitionBase, (screen))

VOID __FreeScreenDrawInfo(void *, struct Screen * screen, struct DrawInfo * drawInfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-696\n"
	"\tbctrl";
#define FreeScreenDrawInfo(screen, drawInfo) __FreeScreenDrawInfo(IntuitionBase, (screen), (drawInfo))

BOOL __ResetMenuStrip(void *, struct Window * window, struct Menu * menu) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-702\n"
	"\tbctrl";
#define ResetMenuStrip(window, menu) __ResetMenuStrip(IntuitionBase, (window), (menu))

VOID __RemoveClass(void *, struct IClass * classPtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-708\n"
	"\tbctrl";
#define RemoveClass(classPtr) __RemoveClass(IntuitionBase, (classPtr))

BOOL __FreeClass(void *, struct IClass * classPtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-714\n"
	"\tbctrl";
#define FreeClass(classPtr) __FreeClass(IntuitionBase, (classPtr))

struct ScreenBuffer * __AllocScreenBuffer(void *, struct Screen * sc, struct BitMap * bm, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-768\n"
	"\tbctrl";
#define AllocScreenBuffer(sc, bm, flags) __AllocScreenBuffer(IntuitionBase, (sc), (bm), (flags))

VOID __FreeScreenBuffer(void *, struct Screen * sc, struct ScreenBuffer * sb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-774\n"
	"\tbctrl";
#define FreeScreenBuffer(sc, sb) __FreeScreenBuffer(IntuitionBase, (sc), (sb))

ULONG __ChangeScreenBuffer(void *, struct Screen * sc, struct ScreenBuffer * sb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-780\n"
	"\tbctrl";
#define ChangeScreenBuffer(sc, sb) __ChangeScreenBuffer(IntuitionBase, (sc), (sb))

VOID __ScreenDepth(void *, struct Screen * screen, ULONG flags, APTR reserved) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-786\n"
	"\tbctrl";
#define ScreenDepth(screen, flags, reserved) __ScreenDepth(IntuitionBase, (screen), (flags), (reserved))

VOID __ScreenPosition(void *, struct Screen * screen, ULONG flags, LONG x1, LONG y1, LONG x2, LONG y2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tli\t3,-792\n"
	"\tbctrl";
#define ScreenPosition(screen, flags, x1, y1, x2, y2) __ScreenPosition(IntuitionBase, (screen), (flags), (x1), (y1), (x2), (y2))

VOID __ScrollWindowRaster(void *, struct Window * win, LONG dx, LONG dy, LONG xMin, LONG yMin, LONG xMax, LONG yMax) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tstw\t10,20(2)\n"
	"\tli\t3,-798\n"
	"\tbctrl";
#define ScrollWindowRaster(win, dx, dy, xMin, yMin, xMax, yMax) __ScrollWindowRaster(IntuitionBase, (win), (dx), (dy), (xMin), (yMin), (xMax), (yMax))

VOID __LendMenus(void *, struct Window * fromwindow, struct Window * towindow) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-804\n"
	"\tbctrl";
#define LendMenus(fromwindow, towindow) __LendMenus(IntuitionBase, (fromwindow), (towindow))

ULONG __DoGadgetMethodA(void *, struct Gadget * gad, struct Window * win, struct Requester * req, Msg message) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-810\n"
	"\tbctrl";
#define DoGadgetMethodA(gad, win, req, message) __DoGadgetMethodA(IntuitionBase, (gad), (win), (req), (message))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __DoGadgetMethod(void *, struct Gadget * gad, struct Window * win, struct Requester * req, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-810\n"
	"\tbctrl";
#define DoGadgetMethod(gad, win, req, ...) __DoGadgetMethod(IntuitionBase, (gad), (win), (req), __VA_ARGS__)
#endif

VOID __SetWindowPointerA(void *, struct Window * win, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-816\n"
	"\tbctrl";
#define SetWindowPointerA(win, taglist) __SetWindowPointerA(IntuitionBase, (win), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __SetWindowPointer(void *, struct Window * win, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-816\n"
	"\tbctrl";
#define SetWindowPointer(win, ...) __SetWindowPointer(IntuitionBase, (win), __VA_ARGS__)
#endif

BOOL __TimedDisplayAlert(void *, ULONG alertNumber, CONST_STRPTR string, ULONG height, ULONG time) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-822\n"
	"\tbctrl";
#define TimedDisplayAlert(alertNumber, string, height, time) __TimedDisplayAlert(IntuitionBase, (alertNumber), (string), (height), (time))

VOID __HelpControl(void *, struct Window * win, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-828\n"
	"\tbctrl";
#define HelpControl(win, flags) __HelpControl(IntuitionBase, (win), (flags))

ULONG __GetSkinInfoAttrA(void *, struct DrawInfo * drawinfo, ULONG attr, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-918\n"
	"\tbctrl";
#define GetSkinInfoAttrA(drawinfo, attr, taglist) __GetSkinInfoAttrA(IntuitionBase, (drawinfo), (attr), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __GetSkinInfoAttr(void *, struct DrawInfo * drawinfo, ULONG attr, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-918\n"
	"\tbctrl";
#define GetSkinInfoAttr(drawinfo, attr, ...) __GetSkinInfoAttr(IntuitionBase, (drawinfo), (attr), __VA_ARGS__)
#endif

ULONG __GetDrawInfoAttr(void *, struct DrawInfo * drawinfo, ULONG attr, ULONG * errorPtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-936\n"
	"\tbctrl";
#define GetDrawInfoAttr(drawinfo, attr, errorPtr) __GetDrawInfoAttr(IntuitionBase, (drawinfo), (attr), (errorPtr))

VOID __WindowAction(void *, struct Window * window, ULONG action, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-942\n"
	"\tbctrl";
#define WindowAction(window, action, tags) __WindowAction(IntuitionBase, (window), (action), (tags))

BOOL __TransparencyControl(void *, struct Window * window, ULONG method, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-948\n"
	"\tbctrl";
#define TransparencyControl(window, method, tags) __TransparencyControl(IntuitionBase, (window), (method), (tags))

VOID __ScrollWindowRasterNoFill(void *, struct Window * win, LONG dx, LONG dy, LONG xMin, LONG yMin, LONG xMax, LONG yMax) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tstw\t10,20(2)\n"
	"\tli\t3,-954\n"
	"\tbctrl";
#define ScrollWindowRasterNoFill(win, dx, dy, xMin, yMin, xMax, yMax) __ScrollWindowRasterNoFill(IntuitionBase, (win), (dx), (dy), (xMin), (yMin), (xMax), (yMax))

Boopsiobject ** __GetMonitorList(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-966\n"
	"\tbctrl";
#define GetMonitorList(tags) __GetMonitorList(IntuitionBase, (tags))

void __FreeMonitorList(void *, Boopsiobject ** list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-972\n"
	"\tbctrl";
#define FreeMonitorList(list) __FreeMonitorList(IntuitionBase, (list))

ULONG __ScreenbarControlA(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-978\n"
	"\tbctrl";
#define ScreenbarControlA(tags) __ScreenbarControlA(IntuitionBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __ScreenbarControl(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-978\n"
	"\tbctrl";
#define ScreenbarControl(...) __ScreenbarControl(IntuitionBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_INTUITION_H  */
