#ifndef _VBCCINLINE_REQTOOLS_H
#define _VBCCINLINE_REQTOOLS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __rtAllocRequestA(void *, ULONG type, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define rtAllocRequestA(type, taglist) __rtAllocRequestA(ReqToolsBase, (type), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __rtAllocRequest(void *, ULONG type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define rtAllocRequest(type, ...) __rtAllocRequest(ReqToolsBase, (type), __VA_ARGS__)
#endif

void __rtFreeRequest(void *, APTR req) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define rtFreeRequest(req) __rtFreeRequest(ReqToolsBase, (req))

void __rtFreeReqBuffer(void *, APTR req) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define rtFreeReqBuffer(req) __rtFreeReqBuffer(ReqToolsBase, (req))

LONG __rtChangeReqAttrA(void *, APTR req, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define rtChangeReqAttrA(req, taglist) __rtChangeReqAttrA(ReqToolsBase, (req), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __rtChangeReqAttr(void *, APTR req, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define rtChangeReqAttr(req, ...) __rtChangeReqAttr(ReqToolsBase, (req), __VA_ARGS__)
#endif

APTR __rtFileRequestA(void *, struct rtFileRequester * filereq, char * file, char * title, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\tstw\t7,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define rtFileRequestA(filereq, file, title, taglist) __rtFileRequestA(ReqToolsBase, (filereq), (file), (title), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __rtFileRequest(void *, struct rtFileRequester * filereq, char * file, char * title, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define rtFileRequest(filereq, file, title, ...) __rtFileRequest(ReqToolsBase, (filereq), (file), (title), __VA_ARGS__)
#endif

void __rtFreeFileList(void *, struct rtFileList * filelist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define rtFreeFileList(filelist) __rtFreeFileList(ReqToolsBase, (filelist))

ULONG __rtEZRequestA(void *, char * bodyfmt, char * gadfmt, struct rtReqInfo * reqinfo, APTR argarray, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\tstw\t7,48(2)\n"
	"\tstw\t8,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define rtEZRequestA(bodyfmt, gadfmt, reqinfo, argarray, taglist) __rtEZRequestA(ReqToolsBase, (bodyfmt), (gadfmt), (reqinfo), (argarray), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __rtEZRequestTags(void *, char * bodyfmt, char * gadfmt, struct rtReqInfo * reqinfo, APTR argarray, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\tstw\t7,48(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define rtEZRequestTags(bodyfmt, gadfmt, reqinfo, argarray, ...) __rtEZRequestTags(ReqToolsBase, (bodyfmt), (gadfmt), (reqinfo), (argarray), __VA_ARGS__)
#endif

ULONG __rtGetStringA(void *, UBYTE * buffer, ULONG maxchars, char * title, struct rtReqInfo * reqinfo, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define rtGetStringA(buffer, maxchars, title, reqinfo, taglist) __rtGetStringA(ReqToolsBase, (buffer), (maxchars), (title), (reqinfo), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __rtGetString(void *, UBYTE * buffer, ULONG maxchars, char * title, struct rtReqInfo * reqinfo, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define rtGetString(buffer, maxchars, title, reqinfo, ...) __rtGetString(ReqToolsBase, (buffer), (maxchars), (title), (reqinfo), __VA_ARGS__)
#endif

ULONG __rtGetLongA(void *, ULONG * longptr, char * title, struct rtReqInfo * reqinfo, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\tstw\t7,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define rtGetLongA(longptr, title, reqinfo, taglist) __rtGetLongA(ReqToolsBase, (longptr), (title), (reqinfo), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __rtGetLong(void *, ULONG * longptr, char * title, struct rtReqInfo * reqinfo, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define rtGetLong(longptr, title, reqinfo, ...) __rtGetLong(ReqToolsBase, (longptr), (title), (reqinfo), __VA_ARGS__)
#endif

ULONG __rtFontRequestA(void *, struct rtFontRequester * fontreq, char * title, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,44(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define rtFontRequestA(fontreq, title, taglist) __rtFontRequestA(ReqToolsBase, (fontreq), (title), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __rtFontRequest(void *, struct rtFontRequester * fontreq, char * title, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define rtFontRequest(fontreq, title, ...) __rtFontRequest(ReqToolsBase, (fontreq), (title), __VA_ARGS__)
#endif

LONG __rtPaletteRequestA(void *, char * title, struct rtReqInfo * reqinfo, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tstw\t5,44(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define rtPaletteRequestA(title, reqinfo, taglist) __rtPaletteRequestA(ReqToolsBase, (title), (reqinfo), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __rtPaletteRequest(void *, char * title, struct rtReqInfo * reqinfo, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tstw\t5,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define rtPaletteRequest(title, reqinfo, ...) __rtPaletteRequest(ReqToolsBase, (title), (reqinfo), __VA_ARGS__)
#endif

ULONG __rtReqHandlerA(void *, struct rtHandlerInfo * handlerinfo, ULONG sigs, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define rtReqHandlerA(handlerinfo, sigs, taglist) __rtReqHandlerA(ReqToolsBase, (handlerinfo), (sigs), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __rtReqHandler(void *, struct rtHandlerInfo * handlerinfo, ULONG sigs, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define rtReqHandler(handlerinfo, sigs, ...) __rtReqHandler(ReqToolsBase, (handlerinfo), (sigs), __VA_ARGS__)
#endif

void __rtSetWaitPointer(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define rtSetWaitPointer(window) __rtSetWaitPointer(ReqToolsBase, (window))

ULONG __rtGetVScreenSize(void *, struct Screen * screen, ULONG * widthptr, ULONG * heightptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define rtGetVScreenSize(screen, widthptr, heightptr) __rtGetVScreenSize(ReqToolsBase, (screen), (widthptr), (heightptr))

void __rtSetReqPosition(void *, ULONG reqpos, struct NewWindow * newwindow, struct Screen * screen, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define rtSetReqPosition(reqpos, newwindow, screen, window) __rtSetReqPosition(ReqToolsBase, (reqpos), (newwindow), (screen), (window))

void __rtSpread(void *, ULONG * posarray, ULONG * sizearray, ULONG length, ULONG min, ULONG max, ULONG num) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define rtSpread(posarray, sizearray, length, min, max, num) __rtSpread(ReqToolsBase, (posarray), (sizearray), (length), (min), (max), (num))

void __rtScreenToFrontSafely(void *, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define rtScreenToFrontSafely(screen) __rtScreenToFrontSafely(ReqToolsBase, (screen))

ULONG __rtScreenModeRequestA(void *, struct rtScreenModeRequester * screenmodereq, char * title, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,44(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define rtScreenModeRequestA(screenmodereq, title, taglist) __rtScreenModeRequestA(ReqToolsBase, (screenmodereq), (title), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __rtScreenModeRequest(void *, struct rtScreenModeRequester * screenmodereq, char * title, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define rtScreenModeRequest(screenmodereq, title, ...) __rtScreenModeRequest(ReqToolsBase, (screenmodereq), (title), __VA_ARGS__)
#endif

void __rtCloseWindowSafely(void *, struct Window * win) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define rtCloseWindowSafely(win) __rtCloseWindowSafely(ReqToolsBase, (win))

APTR __rtLockWindow(void *, struct Window * win) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define rtLockWindow(win) __rtLockWindow(ReqToolsBase, (win))

void __rtUnlockWindow(void *, struct Window * win, APTR winlock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define rtUnlockWindow(win, winlock) __rtUnlockWindow(ReqToolsBase, (win), (winlock))

#endif /*  _VBCCINLINE_REQTOOLS_H  */
