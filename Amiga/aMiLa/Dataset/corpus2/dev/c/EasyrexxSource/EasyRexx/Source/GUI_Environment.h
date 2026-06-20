/*
 *	File:					GUI_Environment.h
 *	Description:	Standard GUI environment for all private applications
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef GUI_ENVIRONMENT_H
#define GUI_ENVIRONMENT_H

/*** INCLUDES ************************************************************************/
#include <exec/types.h>
#include <libraries/EasyGadgets.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <libraries/locale.h>
#include <pragmas/locale_pragmas.h>
#include <clib/locale_protos.h>

#include "eg:macros.h"
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/EasyGadgets_protos.h>

/*** ScreenNotify.library support ***************************************************/
#include <libraries/screennotify.h>

/*** DEFINES *************************************************************************/
#define	egGetString(MSG)	GetString(&li, MSG)
#define MAXCOLORS					16

#define	AUTHOR						"Ketil Hunn"

/*** GLOBALS *************************************************************************/
extern struct EasyGadgets		*eg;
extern struct IntuitionBase	*IntuitionBase;
extern struct GfxBase				*GfxBase;
extern struct Library				*EasyGadgetsBase,	*GadToolsBase,		*LocaleBase,
														*UtilityBase,			*IFFParseBase,		*AslBase,
														*DiskfontBase;

struct ScreenInfo
{
	ULONG DisplayID,
				DisplayWidth,
				DisplayHeight;
	UWORD	DisplayDepth,
				OverscanType;
	BOOL	AutoScroll;
};

extern struct TextAttr Topaz8;
extern struct TextAttr	*fontattr;
extern struct TextFont	*font,
												*topaz;

struct GUIEnv
{
	struct ScreenInfo	screeninfo;
//	char	lockpubscreen[MAXCHARS];

	struct TextAttr	textAttr;

	UWORD colors[MAXCOLORS];

	struct egCoords	fontrequester,
									screenrequester,
									filerequester;

	UBYTE pubname[MAXPUBSCREENNAME+1];

	BYTE	ownscreen,
				closeworkbench,
				savewhenexit,
				acknowledge,
				simplerefresh,
				shanghai,
				backdrop,
				lockedscreen,
				usescreenfont;
	ULONG	changes;
};

extern struct GUIEnv env;

/*** APPLICATION PRIVATES ************************************************************/
#include <libraries/reqtools.h>
#include <clib/reqtools_protos.h>
extern struct ReqToolsBase	*ReqToolsBase;

#include "List.h"
#include "MainMenu.h"

#define LIBVER							37L

#define	NAME								"ARexx Interface Designer"
#define	REVISIONFILE				"ARexx Interface Designer_rev.h"
#define	CATALOG							"Designer.catalog"
#define CATALOGVERSION			31L
#define	CATALOGDESCRIPTION	"Designer_locale.h"

#define	GUIFILE							NAME ".prefs"
#define	ENVGUIFILE					"ENV:" GUIFILE
#define	ENVARCGUIFILE				"ENVARC:" GUIFILE
#define	DEFAULT_PROJECTDIR	"Projects"

#define	COPYRIGHT						"© 1994, 1995 " AUTHOR
#define	HELPDOCUMENT				"Docs/Designer.guide"
#define	PORTNAME						"AREXX_INTERFACE_DESIGNER"

/*** TOOLTYPES ***/
#define	DEFAULT_MACROS			"Designer.macros"
#define	DEFAULT_MACRO				"AREXX/macro.rexx"
#define	DEFAULT_PUBSCREEN		""
#define	DEFAULT_PORTNAME		"MYREXX_PORT"

/*** TOOLTYPES ***/
#define FROM_TOOLTYPE				"FROM"
#define LANGUAGE_TOOLTYPE		"LANGUAGE"
#define AUTHOR_TOOLTYPE			"AUTHOR"
#define COPYRIGHT_TOOLTYPE	"COPYRIGHT"
#define VERSION_TOOLTYPE		"VERSION"
#define PORTNAME_TOOLTYPE		"PORTNAME"
#define	PUBSCREEN_TOOLTYPE	"PUBSCREEN"
#define	MACROS_TOOLTYPE			"MACROS"
#define	DEBUG_TOOLTYPE			"DEBUG"

/*** APPLICATION PRIVATES: GLOBALS ***************************************************/
extern UBYTE	startdir[MAXCHARS],
							project[MAXCHARS],
							guifile[MAXCHARS],
							macrodefinition[MAXCHARS],
							macrofile[MAXCHARS];

/*** LOCALE LANGUAGE CATALOGS HANDLING ***********************************************/
#define	CATCOMP_NUMBERS
#include CATALOGDESCRIPTION
extern struct LocaleInfo		li;
extern struct Locale				*locale;	

/*** PROTOTYPES **********************************************************************/
extern STRPTR __asm GetString(register __a0 struct LocaleInfo *li,register __d0 ULONG id);
LONG FailRequestA(struct Window *window, ULONG MESSAGE, APTR *args);
LONG FailRequest(struct Window *window, ULONG MESSAGE, APTR arg1, ...);
int FailAlert(ULONG MSG_ERROR);

struct Library *myOpenLibrary(STRPTR libraryname, ULONG version);
BYTE OpenResources(void);
void CloseResources(void);

void SetColors(struct ColorMap *colormap, UWORD *colors);
void CloseWB(BYTE close);
void UseDefaultEnv(struct GUIEnv *env);
BYTE OpenGUIEnvironmentA(struct egTask **tasks);
BYTE OpenGUIEnvironment(struct egTask *task1, ...);
void CloseGUIEnvironment(void);
BYTE GetTooltypes(int argc, char **argv);

LONG ConfirmActions(ULONG MSG_ACTION, BYTE force);
BYTE SafeToQuit(ULONG msg, BYTE force);
UBYTE *GetPubScreenName(struct Screen *screen, STRPTR name);
__asm __saveds UBYTE *GetUniquePubScreenName(	register __a0 UBYTE *destname,
																								register __a1 UBYTE *basename);
void DefaultPubScreen(struct Screen *screen, char * pubname, BOOL doit);
BYTE SelectScreenMode(void);
BYTE SelectFont(void);
void AdjustPalette(struct Window *window);


LONG ReadEnv(struct GUIEnv *env, char *file);
LONG WriteEnv(struct GUIEnv *env, char *file);
BYTE OpenEnv(struct GUIEnv *env, char *file);
LONG SaveEnv(struct GUIEnv *env, char *file);

#endif
