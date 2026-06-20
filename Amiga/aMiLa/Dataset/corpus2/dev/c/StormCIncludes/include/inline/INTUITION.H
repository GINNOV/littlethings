#ifndef _INLINE_INTUITION_H
#define _INLINE_INTUITION_H

#ifndef INTUITION_BASE_NAME
#define INTUITION_BASE_NAME IntuitionBase
#endif

#define OpenIntuition() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 30))((struct Library *) INTUITION_BASE_NAME)

#define Intuition(iEvent) \
	((VOID (*)(struct InputEvent * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 36))(iEvent, (struct Library *) INTUITION_BASE_NAME)

#define AddGadget(window, gadget, position) \
	((UWORD (*)(struct Window * __asm("a0"), struct Gadget * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 42))(window, gadget, position, (struct Library *) INTUITION_BASE_NAME)

#define ClearDMRequest(window) \
	((BOOL (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 48))(window, (struct Library *) INTUITION_BASE_NAME)

#define ClearMenuStrip(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 54))(window, (struct Library *) INTUITION_BASE_NAME)

#define ClearPointer(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 60))(window, (struct Library *) INTUITION_BASE_NAME)

#define CloseScreen(screen) \
	((BOOL (*)(struct Screen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 66))(screen, (struct Library *) INTUITION_BASE_NAME)

#define CloseWindow(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 72))(window, (struct Library *) INTUITION_BASE_NAME)

#define CloseWorkBench() \
	((LONG (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 78))((struct Library *) INTUITION_BASE_NAME)

#define CurrentTime(seconds, micros) \
	((VOID (*)(ULONG * __asm("a0"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 84))(seconds, micros, (struct Library *) INTUITION_BASE_NAME)

#define DisplayAlert(alertNumber, string, height) \
	((BOOL (*)(ULONG __asm("d0"), CONST_STRPTR __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 90))(alertNumber, string, height, (struct Library *) INTUITION_BASE_NAME)

#define DisplayBeep(screen) \
	((VOID (*)(struct Screen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 96))(screen, (struct Library *) INTUITION_BASE_NAME)

#define DoubleClick(sSeconds, sMicros, cSeconds, cMicros) \
	((BOOL (*)(ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 102))(sSeconds, sMicros, cSeconds, cMicros, (struct Library *) INTUITION_BASE_NAME)

#define DrawBorder(rp, border, leftOffset, topOffset) \
	((VOID (*)(struct RastPort * __asm("a0"), CONST struct Border * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 108))(rp, border, leftOffset, topOffset, (struct Library *) INTUITION_BASE_NAME)

#define DrawImage(rp, image, leftOffset, topOffset) \
	((VOID (*)(struct RastPort * __asm("a0"), struct Image * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 114))(rp, image, leftOffset, topOffset, (struct Library *) INTUITION_BASE_NAME)

#define EndRequest(requester, window) \
	((VOID (*)(struct Requester * __asm("a0"), struct Window * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 120))(requester, window, (struct Library *) INTUITION_BASE_NAME)

#define GetDefPrefs(preferences, size) \
	((struct Preferences * (*)(struct Preferences * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 126))(preferences, size, (struct Library *) INTUITION_BASE_NAME)

#define GetPrefs(preferences, size) \
	((struct Preferences * (*)(struct Preferences * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 132))(preferences, size, (struct Library *) INTUITION_BASE_NAME)

#define InitRequester(requester) \
	((VOID (*)(struct Requester * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 138))(requester, (struct Library *) INTUITION_BASE_NAME)

#define ItemAddress(menuStrip, menuNumber) \
	((struct MenuItem * (*)(CONST struct Menu * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 144))(menuStrip, menuNumber, (struct Library *) INTUITION_BASE_NAME)

#define ModifyIDCMP(window, flags) \
	((BOOL (*)(struct Window * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 150))(window, flags, (struct Library *) INTUITION_BASE_NAME)

#define ModifyProp(gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 156))(gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody, (struct Library *) INTUITION_BASE_NAME)

#define MoveScreen(screen, dx, dy) \
	((VOID (*)(struct Screen * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 162))(screen, dx, dy, (struct Library *) INTUITION_BASE_NAME)

#define MoveWindow(window, dx, dy) \
	((VOID (*)(struct Window * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 168))(window, dx, dy, (struct Library *) INTUITION_BASE_NAME)

#define OffGadget(gadget, window, requester) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 174))(gadget, window, requester, (struct Library *) INTUITION_BASE_NAME)

#define OffMenu(window, menuNumber) \
	((VOID (*)(struct Window * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 180))(window, menuNumber, (struct Library *) INTUITION_BASE_NAME)

#define OnGadget(gadget, window, requester) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 186))(gadget, window, requester, (struct Library *) INTUITION_BASE_NAME)

#define OnMenu(window, menuNumber) \
	((VOID (*)(struct Window * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 192))(window, menuNumber, (struct Library *) INTUITION_BASE_NAME)

#define OpenScreen(newScreen) \
	((struct Screen * (*)(CONST struct NewScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 198))(newScreen, (struct Library *) INTUITION_BASE_NAME)

#define OpenWindow(newWindow) \
	((struct Window * (*)(CONST struct NewWindow * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 204))(newWindow, (struct Library *) INTUITION_BASE_NAME)

#define OpenWorkBench() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 210))((struct Library *) INTUITION_BASE_NAME)

#define PrintIText(rp, iText, left, top) \
	((VOID (*)(struct RastPort * __asm("a0"), CONST struct IntuiText * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 216))(rp, iText, left, top, (struct Library *) INTUITION_BASE_NAME)

#define RefreshGadgets(gadgets, window, requester) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 222))(gadgets, window, requester, (struct Library *) INTUITION_BASE_NAME)

#define RemoveGadget(window, gadget) \
	((UWORD (*)(struct Window * __asm("a0"), struct Gadget * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 228))(window, gadget, (struct Library *) INTUITION_BASE_NAME)

#define ReportMouse(flag, window) \
	((VOID (*)(LONG __asm("d0"), struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 234))(flag, window, (struct Library *) INTUITION_BASE_NAME)

#define Request(requester, window) \
	((BOOL (*)(struct Requester * __asm("a0"), struct Window * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 240))(requester, window, (struct Library *) INTUITION_BASE_NAME)

#define ScreenToBack(screen) \
	((VOID (*)(struct Screen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 246))(screen, (struct Library *) INTUITION_BASE_NAME)

#define ScreenToFront(screen) \
	((VOID (*)(struct Screen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 252))(screen, (struct Library *) INTUITION_BASE_NAME)

#define SetDMRequest(window, requester) \
	((BOOL (*)(struct Window * __asm("a0"), struct Requester * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 258))(window, requester, (struct Library *) INTUITION_BASE_NAME)

#define SetMenuStrip(window, menu) \
	((BOOL (*)(struct Window * __asm("a0"), struct Menu * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 264))(window, menu, (struct Library *) INTUITION_BASE_NAME)

#define SetPointer(window, pointer, height, width, xOffset, yOffset) \
	((VOID (*)(struct Window * __asm("a0"), UWORD * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 270))(window, pointer, height, width, xOffset, yOffset, (struct Library *) INTUITION_BASE_NAME)

#define SetWindowTitles(window, windowTitle, screenTitle) \
	((VOID (*)(struct Window * __asm("a0"), CONST_STRPTR __asm("a1"), CONST_STRPTR __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 276))(window, windowTitle, screenTitle, (struct Library *) INTUITION_BASE_NAME)

#define ShowTitle(screen, showIt) \
	((VOID (*)(struct Screen * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 282))(screen, showIt, (struct Library *) INTUITION_BASE_NAME)

#define SizeWindow(window, dx, dy) \
	((VOID (*)(struct Window * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 288))(window, dx, dy, (struct Library *) INTUITION_BASE_NAME)

#define ViewAddress() \
	((struct View * (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 294))((struct Library *) INTUITION_BASE_NAME)

#define ViewPortAddress(window) \
	((struct ViewPort * (*)(CONST struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 300))(window, (struct Library *) INTUITION_BASE_NAME)

#define WindowToBack(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 306))(window, (struct Library *) INTUITION_BASE_NAME)

#define WindowToFront(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 312))(window, (struct Library *) INTUITION_BASE_NAME)

#define WindowLimits(window, widthMin, heightMin, widthMax, heightMax) \
	((BOOL (*)(struct Window * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 318))(window, widthMin, heightMin, widthMax, heightMax, (struct Library *) INTUITION_BASE_NAME)

#define SetPrefs(preferences, size, inform) \
	((struct Preferences * (*)(CONST struct Preferences * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 324))(preferences, size, inform, (struct Library *) INTUITION_BASE_NAME)

#define IntuiTextLength(iText) \
	((LONG (*)(CONST struct IntuiText * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 330))(iText, (struct Library *) INTUITION_BASE_NAME)

#define WBenchToBack() \
	((BOOL (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 336))((struct Library *) INTUITION_BASE_NAME)

#define WBenchToFront() \
	((BOOL (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 342))((struct Library *) INTUITION_BASE_NAME)

#define AutoRequest(window, body, posText, negText, pFlag, nFlag, width, height) \
	((BOOL (*)(struct Window * __asm("a0"), CONST struct IntuiText * __asm("a1"), CONST struct IntuiText * __asm("a2"), CONST struct IntuiText * __asm("a3"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 348))(window, body, posText, negText, pFlag, nFlag, width, height, (struct Library *) INTUITION_BASE_NAME)

#define BeginRefresh(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 354))(window, (struct Library *) INTUITION_BASE_NAME)

#define BuildSysRequest(window, body, posText, negText, flags, width, height) \
	((struct Window * (*)(struct Window * __asm("a0"), CONST struct IntuiText * __asm("a1"), CONST struct IntuiText * __asm("a2"), CONST struct IntuiText * __asm("a3"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 360))(window, body, posText, negText, flags, width, height, (struct Library *) INTUITION_BASE_NAME)

#define EndRefresh(window, complete) \
	((VOID (*)(struct Window * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 366))(window, complete, (struct Library *) INTUITION_BASE_NAME)

#define FreeSysRequest(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 372))(window, (struct Library *) INTUITION_BASE_NAME)

#define MakeScreen(screen) \
	((LONG (*)(struct Screen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 378))(screen, (struct Library *) INTUITION_BASE_NAME)

#define RemakeDisplay() \
	((LONG (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 384))((struct Library *) INTUITION_BASE_NAME)

#define RethinkDisplay() \
	((LONG (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 390))((struct Library *) INTUITION_BASE_NAME)

#define AllocRemember(rememberKey, size, flags) \
	((APTR (*)(struct Remember ** __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 396))(rememberKey, size, flags, (struct Library *) INTUITION_BASE_NAME)

#define FreeRemember(rememberKey, reallyForget) \
	((VOID (*)(struct Remember ** __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 408))(rememberKey, reallyForget, (struct Library *) INTUITION_BASE_NAME)

#define LockIBase(dontknow) \
	((ULONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 414))(dontknow, (struct Library *) INTUITION_BASE_NAME)

#define UnlockIBase(ibLock) \
	((VOID (*)(ULONG __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 420))(ibLock, (struct Library *) INTUITION_BASE_NAME)

#define GetScreenData(buffer, size, type, screen) \
	((LONG (*)(APTR __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), CONST struct Screen * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 426))(buffer, size, type, screen, (struct Library *) INTUITION_BASE_NAME)

#define RefreshGList(gadgets, window, requester, numGad) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 432))(gadgets, window, requester, numGad, (struct Library *) INTUITION_BASE_NAME)

#define AddGList(window, gadget, position, numGad, requester) \
	((UWORD (*)(struct Window * __asm("a0"), struct Gadget * __asm("a1"), ULONG __asm("d0"), LONG __asm("d1"), struct Requester * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 438))(window, gadget, position, numGad, requester, (struct Library *) INTUITION_BASE_NAME)

#define RemoveGList(remPtr, gadget, numGad) \
	((UWORD (*)(struct Window * __asm("a0"), struct Gadget * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 444))(remPtr, gadget, numGad, (struct Library *) INTUITION_BASE_NAME)

#define ActivateWindow(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 450))(window, (struct Library *) INTUITION_BASE_NAME)

#define RefreshWindowFrame(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 456))(window, (struct Library *) INTUITION_BASE_NAME)

#define ActivateGadget(gadgets, window, requester) \
	((BOOL (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 462))(gadgets, window, requester, (struct Library *) INTUITION_BASE_NAME)

#define NewModifyProp(gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody, numGad) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), LONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 468))(gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody, numGad, (struct Library *) INTUITION_BASE_NAME)

#define QueryOverscan(displayID, rect, oScanType) \
	((LONG (*)(ULONG __asm("a0"), struct Rectangle * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 474))(displayID, rect, oScanType, (struct Library *) INTUITION_BASE_NAME)

#define MoveWindowInFrontOf(window, behindWindow) \
	((VOID (*)(struct Window * __asm("a0"), struct Window * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 480))(window, behindWindow, (struct Library *) INTUITION_BASE_NAME)

#define ChangeWindowBox(window, left, top, width, height) \
	((VOID (*)(struct Window * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 486))(window, left, top, width, height, (struct Library *) INTUITION_BASE_NAME)

#define SetEditHook(hook) \
	((struct Hook * (*)(struct Hook * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 492))(hook, (struct Library *) INTUITION_BASE_NAME)

#define SetMouseQueue(window, queueLength) \
	((LONG (*)(struct Window * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 498))(window, queueLength, (struct Library *) INTUITION_BASE_NAME)

#define ZipWindow(window) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 504))(window, (struct Library *) INTUITION_BASE_NAME)

#define LockPubScreen(name) \
	((struct Screen * (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 510))(name, (struct Library *) INTUITION_BASE_NAME)

#define UnlockPubScreen(name, screen) \
	((VOID (*)(CONST_STRPTR __asm("a0"), struct Screen * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 516))(name, screen, (struct Library *) INTUITION_BASE_NAME)

#define LockPubScreenList() \
	((struct List * (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 522))((struct Library *) INTUITION_BASE_NAME)

#define UnlockPubScreenList() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 528))((struct Library *) INTUITION_BASE_NAME)

#define NextPubScreen(screen, namebuf) \
	((STRPTR (*)(CONST struct Screen * __asm("a0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 534))(screen, namebuf, (struct Library *) INTUITION_BASE_NAME)

#define SetDefaultPubScreen(name) \
	((VOID (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 540))(name, (struct Library *) INTUITION_BASE_NAME)

#define SetPubScreenModes(modes) \
	((UWORD (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 546))(modes, (struct Library *) INTUITION_BASE_NAME)

#define PubScreenStatus(screen, statusFlags) \
	((UWORD (*)(struct Screen * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 552))(screen, statusFlags, (struct Library *) INTUITION_BASE_NAME)

#define ObtainGIRPort(gInfo) \
	((struct RastPort * (*)(struct GadgetInfo * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 558))(gInfo, (struct Library *) INTUITION_BASE_NAME)

#define ReleaseGIRPort(rp) \
	((VOID (*)(struct RastPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 564))(rp, (struct Library *) INTUITION_BASE_NAME)

#define GadgetMouse(gadget, gInfo, mousePoint) \
	((VOID (*)(struct Gadget * __asm("a0"), struct GadgetInfo * __asm("a1"), WORD * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 570))(gadget, gInfo, mousePoint, (struct Library *) INTUITION_BASE_NAME)

#define GetDefaultPubScreen(nameBuffer) \
	((VOID (*)(STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 582))(nameBuffer, (struct Library *) INTUITION_BASE_NAME)

#define EasyRequestArgs(window, easyStruct, idcmpPtr, args) \
	((LONG (*)(struct Window * __asm("a0"), CONST struct EasyStruct * __asm("a1"), ULONG * __asm("a2"), CONST APTR __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 588))(window, easyStruct, idcmpPtr, args, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define EasyRequest(window, easyStruct, idcmpPtr, tags...) \
	({ULONG _tags[] = {tags}; EasyRequestArgs((window), (easyStruct), (idcmpPtr), () _tags);})
#endif

#define BuildEasyRequestArgs(window, easyStruct, idcmp, args) \
	((struct Window * (*)(struct Window * __asm("a0"), CONST struct EasyStruct * __asm("a1"), ULONG __asm("d0"), CONST APTR __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 594))(window, easyStruct, idcmp, args, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define BuildEasyRequest(window, easyStruct, idcmp, tags...) \
	({ULONG _tags[] = {tags}; BuildEasyRequestArgs((window), (easyStruct), (idcmp), () _tags);})
#endif

#define SysReqHandler(window, idcmpPtr, waitInput) \
	((LONG (*)(struct Window * __asm("a0"), ULONG * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 600))(window, idcmpPtr, waitInput, (struct Library *) INTUITION_BASE_NAME)

#define OpenWindowTagList(newWindow, tagList) \
	((struct Window * (*)(CONST struct NewWindow * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 606))(newWindow, tagList, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define OpenWindowTags(newWindow, tags...) \
	({ULONG _tags[] = {tags}; OpenWindowTagList((newWindow), (ULONG) _tags);})
#endif

#define OpenScreenTagList(newScreen, tagList) \
	((struct Screen * (*)(CONST struct NewScreen * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 612))(newScreen, tagList, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define OpenScreenTags(newScreen, tags...) \
	({ULONG _tags[] = {tags}; OpenScreenTagList((newScreen), (ULONG) _tags);})
#endif

#define DrawImageState(rp, image, leftOffset, topOffset, state, drawInfo) \
	((VOID (*)(struct RastPort * __asm("a0"), struct Image * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), ULONG __asm("d2"), CONST struct DrawInfo * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 618))(rp, image, leftOffset, topOffset, state, drawInfo, (struct Library *) INTUITION_BASE_NAME)

#define PointInImage(point, image) \
	((BOOL (*)(ULONG __asm("d0"), struct Image * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 624))(point, image, (struct Library *) INTUITION_BASE_NAME)

#define EraseImage(rp, image, leftOffset, topOffset) \
	((VOID (*)(struct RastPort * __asm("a0"), struct Image * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 630))(rp, image, leftOffset, topOffset, (struct Library *) INTUITION_BASE_NAME)

#define NewObjectA(classPtr, classID, tagList) \
	((APTR (*)(struct IClass * __asm("a0"), CONST_STRPTR __asm("a1"), CONST struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 636))(classPtr, classID, tagList, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define NewObject(classPtr, classID, tags...) \
	({ULONG _tags[] = {tags}; NewObjectA((classPtr), (classID), (ULONG) _tags);})
#endif

#define DisposeObject(object) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 642))(object, (struct Library *) INTUITION_BASE_NAME)

#define SetAttrsA(object, tagList) \
	((ULONG (*)(APTR __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 648))(object, tagList, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetAttrs(object, tags...) \
	({ULONG _tags[] = {tags}; SetAttrsA((object), (ULONG) _tags);})
#endif

#define GetAttr(attrID, object, storagePtr) \
	((ULONG (*)(ULONG __asm("d0"), APTR __asm("a0"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 654))(attrID, object, storagePtr, (struct Library *) INTUITION_BASE_NAME)

#define SetGadgetAttrsA(gadget, window, requester, tagList) \
	((ULONG (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), CONST struct TagItem * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 660))(gadget, window, requester, tagList, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetGadgetAttrs(gadget, window, requester, tags...) \
	({ULONG _tags[] = {tags}; SetGadgetAttrsA((gadget), (window), (requester), (ULONG) _tags);})
#endif

#define NextObject(objectPtrPtr) \
	((APTR (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 666))(objectPtrPtr, (struct Library *) INTUITION_BASE_NAME)

#define MakeClass(classID, superClassID, superClassPtr, instanceSize, flags) \
	((struct IClass * (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), CONST struct IClass * __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 678))(classID, superClassID, superClassPtr, instanceSize, flags, (struct Library *) INTUITION_BASE_NAME)

#define AddClass(classPtr) \
	((VOID (*)(struct IClass * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 684))(classPtr, (struct Library *) INTUITION_BASE_NAME)

#define GetScreenDrawInfo(screen) \
	((struct DrawInfo * (*)(struct Screen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 690))(screen, (struct Library *) INTUITION_BASE_NAME)

#define FreeScreenDrawInfo(screen, drawInfo) \
	((VOID (*)(struct Screen * __asm("a0"), struct DrawInfo * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 696))(screen, drawInfo, (struct Library *) INTUITION_BASE_NAME)

#define ResetMenuStrip(window, menu) \
	((BOOL (*)(struct Window * __asm("a0"), struct Menu * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 702))(window, menu, (struct Library *) INTUITION_BASE_NAME)

#define RemoveClass(classPtr) \
	((VOID (*)(struct IClass * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 708))(classPtr, (struct Library *) INTUITION_BASE_NAME)

#define FreeClass(classPtr) \
	((BOOL (*)(struct IClass * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 714))(classPtr, (struct Library *) INTUITION_BASE_NAME)

#define AllocScreenBuffer(sc, bm, flags) \
	((struct ScreenBuffer * (*)(struct Screen * __asm("a0"), struct BitMap * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 768))(sc, bm, flags, (struct Library *) INTUITION_BASE_NAME)

#define FreeScreenBuffer(sc, sb) \
	((VOID (*)(struct Screen * __asm("a0"), struct ScreenBuffer * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 774))(sc, sb, (struct Library *) INTUITION_BASE_NAME)

#define ChangeScreenBuffer(sc, sb) \
	((ULONG (*)(struct Screen * __asm("a0"), struct ScreenBuffer * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 780))(sc, sb, (struct Library *) INTUITION_BASE_NAME)

#define ScreenDepth(screen, flags, reserved) \
	((VOID (*)(struct Screen * __asm("a0"), ULONG __asm("d0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 786))(screen, flags, reserved, (struct Library *) INTUITION_BASE_NAME)

#define ScreenPosition(screen, flags, x1, y1, x2, y2) \
	((VOID (*)(struct Screen * __asm("a0"), ULONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 792))(screen, flags, x1, y1, x2, y2, (struct Library *) INTUITION_BASE_NAME)

#define ScrollWindowRaster(win, dx, dy, xMin, yMin, xMax, yMax) \
	((VOID (*)(struct Window * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 798))(win, dx, dy, xMin, yMin, xMax, yMax, (struct Library *) INTUITION_BASE_NAME)

#define LendMenus(fromwindow, towindow) \
	((VOID (*)(struct Window * __asm("a0"), struct Window * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 804))(fromwindow, towindow, (struct Library *) INTUITION_BASE_NAME)

#define DoGadgetMethodA(gad, win, req, message) \
	((ULONG (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), Msg __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 810))(gad, win, req, message, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define DoGadgetMethod(gad, win, req, tags...) \
	({ULONG _tags[] = {tags}; DoGadgetMethodA((gad), (win), (req), (ULONG) _tags);})
#endif

#define SetWindowPointerA(win, taglist) \
	((VOID (*)(struct Window * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 816))(win, taglist, (struct Library *) INTUITION_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetWindowPointer(win, tags...) \
	({ULONG _tags[] = {tags}; SetWindowPointerA((win), (ULONG) _tags);})
#endif

#define TimedDisplayAlert(alertNumber, string, height, time) \
	((BOOL (*)(ULONG __asm("d0"), CONST_STRPTR __asm("a0"), ULONG __asm("d1"), ULONG __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 822))(alertNumber, string, height, time, (struct Library *) INTUITION_BASE_NAME)

#define HelpControl(win, flags) \
	((VOID (*)(struct Window * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) INTUITION_BASE_NAME) - 828))(win, flags, (struct Library *) INTUITION_BASE_NAME)

#endif /*  _INLINE_INTUITION_H  */
