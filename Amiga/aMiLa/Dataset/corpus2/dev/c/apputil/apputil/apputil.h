/*
 * apputil.h
 * =========
 * Application utility functions.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#ifndef APPUTIL_H
#define APPUTIL_H

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <libraries/gadtools.h>
#include <utility/tagitem.h>
#include <workbench/startup.h>


/* Maximum basename length. */
#define MAXBASENAMELEN 30


/* A menu action. */
typedef VOID (*MenuAction)(VOID);
/* A menu action for ckecked menu items. */
typedef VOID (*CheckedMenuAction)(BOOL checked);


/* Creates the button class. */
extern Class *CreateButtonClass(VOID);

/* Erases all gadgets. */
extern VOID EraseGadgets(struct Gadget *gads, struct Window *win,
			 struct Requester *req);
/* Erases up to numGads gadgets. */
extern VOID EraseGList(struct Gadget *gads, struct Window *win,
		       struct Requester *req, LONG numGads);
/* Checks if a point is inside a gadget. */
extern BOOL PointInGadget(ULONG point, struct Gadget *gad);

/* Initializes locale information. */
extern VOID InitLocaleInfo(STRPTR catalog, STRPTR language, UWORD version);
/* Disposes locale information. */
extern VOID DisposeLocaleInfo(VOID);
/* Returns a localized string */
extern STRPTR GetLocString(ULONG strId);

/* Creates localized menus. */
extern struct Menu *CreateLocMenusA(struct NewMenu *newMenu, APTR vi,
				    struct TagItem *tagList);
/* Creates localized menus. */
extern struct Menu *CreateLocMenus(struct NewMenu *newMenu, APTR vi,
				   ULONG tag, ...);
/* Processes menu events. */
extern VOID ProcessMenuEvents(struct Window *win, UWORD menuNum);

/* Reads command line arguments. */
extern struct RDArgs *ReadArgsCLI(STRPTR template, LONG *array);
/* Reads WB ToolTypes. */
extern struct RDArgs *ReadArgsWB(STRPTR template, LONG *array,
				 struct WBStartup *sm);
/* Disposes arguments. */
extern VOID FreeArgsCLIWB(struct RDArgs *rdargs);

/* Blocks input to a window. */
extern BOOL BlockWindow(struct Window *win, struct Requester *req);
/* Unblocks input to a window. */
extern VOID UnblockWindow(struct Window *win, struct Requester *req);
/* Brings up a message requester. */
extern LONG MessageRequesterA(struct Window *win, STRPTR title,
			      STRPTR textFmt, STRPTR gadFmt, APTR argList);
/* Brings up a message requester. */
extern LONG MessageRequester(struct Window *win, STRPTR title,
			     STRPTR textFmt, STRPTR gadFmt, APTR arg, ...);

/* Initializes application settings. */
extern BOOL InitSettings(STRPTR path, STRPTR basename, VOID *buf, LONG len);
/* Disposes settings. */
extern VOID DisposeSettings(VOID);
/* Loads application settings. */
extern BOOL LoadSettings(STRPTR path, VOID *buf, LONG len);
/* Saves application settings. */
extern BOOL SaveSettings(STRPTR basename, VOID *buf, LONG len);
/* Saves application settings. */
extern BOOL SaveSettingsAs(STRPTR path, VOID *buf, LONG len);

/* Initializes window position. */
extern VOID SetupWindowPosition(struct Screen *scr,
				WORD scrWidth, WORD scrHeight,
				WORD winWidth, WORD winHeight,
				WORD *left, WORD *top,
				WORD *zoomLeft, WORD *zoomTop);
/* Calculates the extent of a window title bar. */
extern VOID TitleBarExtent(struct Screen *scr, STRPTR title,
			   WORD *width, WORD *height);

/* Returns the length of a string. */
extern LONG strlen(STRPTR s);
/* Copys the contents of a string. */
extern VOID strcpy(STRPTR dest, STRPTR src);

#endif /* APPUTIL_H */
