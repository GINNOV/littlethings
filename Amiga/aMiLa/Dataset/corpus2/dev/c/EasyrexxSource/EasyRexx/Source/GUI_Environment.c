/*
 *	File:					GUI_Environment.c
 *	Description:	Standard GUI environment for all private applications
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef GUI_ENVIRONMENT_C
#define GUI_ENVIRONMENT_C

/*** INCLUDES ************************************************************************/
#include "System.h"
#include "GUI_Environment.h"
#include "Asl.h"
#include "Designer_AREXX.h"
#include "DesignerIcon.c"
#include "myinclude:MyTooltypeArgs.h"
#include "myinclude:MyIFFfunctions.h"
#include "ProjectIO.h"
#include "myinclude:Exists.h"

#include "intuition/intuitionbase.h"
#include <intuition/screens.h>
#include "graphics/gfxbase.h"
#include <libraries/Asl.h>
#include <graphics/modeid.h>
#include <clib/iffparse_protos.h>
#include <libraries/iffparse.h>
#include <prefs/prefhdr.h>

/*** DEFINES *************************************************************************/
#define  ID_XGUI	MAKE_ID('X','G','U','I')

#define	ID_ACKN	MAKE_ID('A','C','K','N')		// acknowledge
#define	ID_EXIT	MAKE_ID('E','X','I','T')		// save settings when exit
#define	ID_SREF	MAKE_ID('S','R','E','F')		// simple refresh
#define	ID_CLWB	MAKE_ID('C','L','W','B')		// close workbench
#define	ID_OSCR	MAKE_ID('O','S','C','R')		// own screen
#define	ID_BACK	MAKE_ID('B','A','C','K')		// backdrop
#define	ID_SHAI	MAKE_ID('S','H','A','I')		// shanghai
#define	ID_SFNT	MAKE_ID('S','F','N','T')		// use screen's font

#define ID_SCRN	MAKE_ID('S','C','R','N')		// screeninfo
#define ID_FONT	MAKE_ID('F','O','N','T')		// font
#define ID_FNAM	MAKE_ID('F','N','A','M')		// name of font
#define ID_COLS	MAKE_ID('C','O','L','S')		// colortable

#define	ID_MCOO	MAKE_ID('M','C','O','O')		// main window coordinates
#define	ID_CCOO	MAKE_ID('T','C','O','O')		// code window coordinates
#define	ID_XCOO	MAKE_ID('A','C','O','O')		// assign macros window coordinates
#define	ID_ACOO	MAKE_ID('D','C','O','O')		// about window coordinates

#define	ID_CWIN	MAKE_ID('C','W','I','N')		// code window status
#define	ID_XWIN	MAKE_ID('X','W','I','N')		// assign window status
#define	ID_AWIN	MAKE_ID('A','W','I','N')		// about window status

#define	ID_FIRQ	MAKE_ID('F','I','R','Q')		// file requester coordinates
#define	ID_FORQ	MAKE_ID('F','O','R','Q')		// font requester coordinates
#define	ID_SCRQ	MAKE_ID('S','C','R','Q')		// screenmode requester coordinates

/*** GLOBALS *************************************************************************/
struct EasyGadgets		*eg;
struct IntuitionBase	*IntuitionBase;
struct GfxBase				*GfxBase;
struct Library				*EasyGadgetsBase,	*GadToolsBase,		*LocaleBase,
											*UtilityBase,			*IFFParseBase,		*AslBase,
											*DiskfontBase;

struct LocaleInfo			li;
struct Locale					*locale;	

struct GUIEnv					env;

struct TextAttr				*fontattr	=NULL;
struct TextFont				*font			=NULL,
											*topaz		=NULL;

struct TextAttr				Topaz8={"topaz.font", 8, 0, FPF_ROMFONT};

UBYTE									egname[]=EASYGADGETSNAME,
											guiname[MAXCHARS];

/*** APPLICATION PRIVATES ************************************************************/
#include <libraries/reqtools.h>
struct ReqToolsBase	*ReqToolsBase=NULL;

#include "TASK_Code.h"
#include "TASK_Assign.h"
#include "TASK_About.h"

UBYTE		startdir[MAXCHARS],
				language[MAXCHARS],
				project[MAXCHARS]=DEFAULT_PROJECTDIR,
				helpfile[MAXCHARS],
				guifile[MAXCHARS]=ENVARCGUIFILE,
				macrodefinition[MAXCHARS]=DEFAULT_MACROS,
				macrofile[MAXCHARS]=DEFAULT_MACRO;

/*** ERROR MESSAGE FUNCTIONS *********************************************************/
LONG FailRequestA(struct Window *window, ULONG MESSAGE, APTR *args)
{
	struct EasyStruct myES;

#ifdef MYDEBUG_H
	DebugOut("FailRequestA");
#endif

	myES.es_StructSize		=sizeof(struct EasyStruct);
	myES.es_Title					=NAME;
	myES.es_TextFormat		=egGetString(MESSAGE);
	myES.es_GadgetFormat	="OK";

	DisplayBeep((window==NULL ? NULL : window->WScreen));

	return EasyRequestArgs(window, &myES, NULL, args);
}

LONG FailRequest(struct Window *window, ULONG MESSAGE, APTR arg1, ...)
{
	return FailRequestA(window, MESSAGE, &arg1);
}

int FailAlert(ULONG MSG_ERROR)
{
#ifdef MYDEBUG_H
	DebugOut("FailAlert");
#endif
	return egDisplayAlert(RECOVERY_ALERT, egGetString(MSG_ERROR), 300);
}

void openreqtools(void)
{
	if(ReqToolsBase==NULL)
		if(NULL==(ReqToolsBase=(struct ReqToolsBase *)OpenLibrary(REQTOOLSNAME, REQTOOLSVERSION)))
			FailRequest(mainTask.window, MSG_LIBRARYNOTFOUND, (APTR)REQTOOLSNAME, (APTR)REQTOOLSVERSION, NULL);
}

/*** LIBRARIES FUNCTIONS *************************************************************/
struct Library *myOpenLibrary(STRPTR libraryname, ULONG version)
{
	register struct Library *library;

#ifdef MYDEBUG_H
	DebugOut("myOpenLibrary");
#endif

	if(NULL==(library=OpenLibrary((UBYTE *)libraryname, version)))
		FailRequest(NULL, MSG_LIBRARYNOTFOUND, (APTR)libraryname, (APTR)version, NULL);

	return library;
}

BYTE OpenResources(void)
{
#ifdef MYDEBUG_H
	DebugOut("OpenResources");
#endif

#ifdef AREXX_INTERFACE
	if(EasyRexxBase=OpenLibrary(EASYREXXNAME, EASYREXXVERSION))
		context=AllocARexxContext(ER_CommandTable,	commandTable,
															ER_Author,				AUTHOR,
															ER_Copyright,			COPYRIGHT,
															ER_Version,				VERS,
															ER_Portname,			PORTNAME,
															TAG_DONE);
#endif

	LocaleBase=OpenLibrary("locale.library", 38L);

	if(IntuitionBase=(struct IntuitionBase *)myOpenLibrary("intuition.library", LIBVER))
		if(GfxBase=(struct GfxBase*)myOpenLibrary("graphics.library", LIBVER))
			if(GadToolsBase=myOpenLibrary("gadtools.library", LIBVER))
				if(UtilityBase=myOpenLibrary(UTILITYNAME, LIBVER))
					if(IFFParseBase=myOpenLibrary("iffparse.library", LIBVER))
						if(AslBase=myOpenLibrary(AslName, LIBVER))
							if(DiskfontBase=myOpenLibrary("diskfont.library", LIBVER))
								if(EasyGadgetsBase=myOpenLibrary(EASYGADGETSNAME, EASYGADGETSVERSION))
									if(EasyGadgetsBase->lib_Version==EASYGADGETSVERSION)
										return TRUE;
									else
										FailRequest(NULL, MSG_LIBRARYNOTFOUND, (APTR)egname, (APTR)EASYGADGETSVERSION, NULL);
	return FALSE;
}

void CloseResources(void)
{
#ifdef MYDEBUG_H
	DebugOut("CloseResources");
#endif

	if(ReqToolsBase)
		CloseLibrary((struct Library *)ReqToolsBase);

	if(EasyGadgetsBase)
		CloseLibrary(EasyGadgetsBase);
	if(DiskfontBase)
		CloseLibrary(DiskfontBase);
	if(AslBase)
		CloseLibrary(AslBase);
	if(IFFParseBase)
		CloseLibrary(IFFParseBase);
	if(UtilityBase)
		CloseLibrary(UtilityBase);
	if(GadToolsBase)
		CloseLibrary(GadToolsBase);
	if(GfxBase)
		CloseLibrary((struct Library *)GfxBase);
	if(IntuitionBase)
		CloseLibrary((struct Library *)IntuitionBase);

	if(LocaleBase)
		CloseLibrary(LocaleBase);

#ifdef MYDEBUG_H
	DebugOut("Closing EasyRexxBase");
#endif

#ifdef AREXX_INTERFACE
	if(EasyRexxBase)
	{
		FreeARexxContext(context);
		CloseLibrary(EasyRexxBase);
	}
#endif

#ifdef MYDEBUG_H
	DebugOut("done closing resources");
#endif

}

/*** GENERAL GUI FUNCTIONS ***********************************************************/
void SetColors(struct ColorMap *colormap, UWORD *colors)
{
	register short i;

#ifdef MYDEBUG_H
	DebugOut("SetColors");
#endif

	for(i=0; i<MAXCOLORS; i++)
		colors[i]=GetRGB4(colormap, i);
}

UBYTE *GetPubScreenName(struct Screen *screen, STRPTR name)
{
	register struct List	*list;
	register struct Node	*node;

	if(list=LockPubScreenList())
	{
		for(every_node)
			if(((struct PubScreenNode *)node)->psn_Screen==screen)
			{
				strcpy(name, node->ln_Name);
				break;
			}
		UnlockPubScreenList();
	}
	return name;
}

void DefaultPubScreen(struct Screen *screen, char * pubname, BOOL doit)
{
#ifdef MYDEBUG_H
	DebugOut("DefaultPubScreen");
#endif
	if(doit)
	{
		PubScreenStatus(screen, 0);
		SetDefaultPubScreen(pubname);
		SetPubScreenModes(SHANGHAI|POPPUBSCREEN);
	}
	else
	{
		PubScreenStatus(screen, PSNF_PRIVATE);
		SetDefaultPubScreen(NULL);
		SetPubScreenModes(0);
	}
}


__asm __saveds struct List *CopyPubScreenList(void)
{
	struct List *publist, *list;
	struct Node	*node;

#ifdef MYDEBUG_H
	DebugOut("egCopyPubScreenList");
#endif

	if(publist=InitList())
	{
		if(list=LockPubScreenList())
			for(every_node)
				AddNode(publist, NULL, node->ln_Name);
		UnlockPubScreenList();
	}
	return publist;
}

__asm __saveds UBYTE *GetUniquePubScreenName(	register __a0 UBYTE *destname,
																							register __a1 UBYTE *basename)
{
	struct List	*list;

#ifdef MYDEBUG_H
	DebugOut("egGetUniquePubScreenName");
#endif
	
	if(list=CopyPubScreenList())
	{
		register struct Node	*node;
		register BYTE					found=FALSE;
		register LONG					i=1;

		while(!found)
		{
			sprintf(destname, "%s.%ld", basename, i);

			for(every_node)
				if(Stricmp(node->ln_Name, destname)==0)
				{
					found=TRUE;
					++i;
					break;
				}
			if(!found)
				break;
			found=FALSE;
		}
		FreeList(list);
	}
	return destname;
}

void CloseWB(BYTE close)
{
#ifdef MYDEBUG_H
	DebugOut("CloseWB");
#endif

	if(close)
	{
		if(!CloseWorkBench())
			FailRequest(NULL, MSG_COULDNOTCLOSEWB, NULL);
	}
	else
		if(!OpenWorkBench())
			FailRequest(NULL, MSG_COULDNOTOPENWB, NULL);
}


BYTE OpenGUIEnvironmentA(struct egTask **tasks)
{
	BYTE success=FALSE;

#ifdef MYDEBUG_H
	DebugOut("OpenGUIEnvironment");
#endif

	topaz=OpenFont(&Topaz8);

	if(LocaleBase)
	{
		locale=OpenLocale(NULL);
		li.li_LocaleBase = LocaleBase;
		li.li_Catalog=OpenCatalog(locale,
															CATALOG,
														  (*language=='*' ? TAG_IGNORE: OC_Language),	language,
															OC_Version, 	CATALOGVERSION,
														  TAG_DONE);
	}

	strcpy(helpfile, startdir);
	AddPart(helpfile, HELPDOCUMENT, MAXCHARS-1);

	if(eg=egAllocEasyGadgets(	EG_Basename,				NAME,
														EG_HelpDocument,		helpfile,
														EG_AppIcon,					&AppIcon,
														EG_WorkbenchNotify,	TRUE,
														TAG_DONE))
	{
		egLinkTasksA(eg, tasks);

		UseDefaultEnv(&env);
		if(Exists(ENVGUIFILE))
			ReadEnv(&env, ENVGUIFILE);

		if(Exists(macrodefinition))
			ReadMacros(macros, macrodefinition);

		if(env.ownscreen)
			CloseWB(env.closeworkbench);

		success=TRUE;
	}
	return success;
}

BYTE OpenGUIEnvironment(struct egTask *task1, ...)
{
	return OpenGUIEnvironmentA(&task1);
}

void CloseGUIEnvironment(void)
{
#ifdef MYDEBUG_H
	DebugOut("CloseGUIEnvironment");
#endif

	if(env.ownscreen)
		CloseWB(FALSE);

	FreeAslRequesters();

	if(eg)
		egFreeEasyGadgets(eg);

	if(LocaleBase)
	{
		CloseCatalog(li.li_Catalog);
		if(locale)
			CloseLocale(locale);
	}

	free(env.textAttr.ta_Name);

	if(topaz)
		CloseFont(topaz);
}

void UseDefaultEnv(struct GUIEnv *env)
{
	struct Screen		*screen;
	struct DrawInfo	*drawinfo;
	ULONG						modeID;

#ifdef MYDEBUG_H
	DebugOut("UseDefaultEnv");
#endif

	if(NULL==(screen=LockPubScreen(env->pubname)))
		screen=LockPubScreen(NULL);

	if(screen)
	{
		if(drawinfo=GetScreenDrawInfo(screen))
		{
			if((modeID=GetVPModeID(&(screen->ViewPort)))!=INVALID_ID)
			{
				env->screeninfo.DisplayID				=modeID;
				env->screeninfo.DisplayWidth		=screen->Width;
				env->screeninfo.DisplayHeight		=screen->Height;
				env->screeninfo.DisplayDepth		=drawinfo->dri_Depth;
				env->screeninfo.OverscanType		=OSCAN_TEXT;
				env->screeninfo.AutoScroll			=TRUE;
				env->closeworkbench							=FALSE;

//				strcpy(env->fontname, screen->Font->ta_Name);
				env->textAttr.ta_Name						=strdup(screen->Font->ta_Name);
				env->textAttr.ta_YSize					=screen->Font->ta_YSize;
				env->textAttr.ta_Style					=screen->Font->ta_Style;
				env->textAttr.ta_Flags					=screen->Font->ta_Flags;

				env->usescreenfont							=TRUE;
				env->acknowledge								=TRUE;

				SetColors(screen->ViewPort.ColorMap, env->colors);
			}
	    FreeScreenDrawInfo(screen, drawinfo);
		}
		UnlockPubScreen(NULL, screen);
	}
}

BYTE GetTooltypes(int argc, char **argv)
{
	register UBYTE	**tooltypes=ArgArrayInit(argc, argv);

	strcpy(language,				ArgString(tooltypes,	LANGUAGE_TOOLTYPE, "*"));
	AddPart(project,				ArgString(tooltypes,	FROM_TOOLTYPE, egGetString(MSG_UNNAMED)), MAXCHARS-1);
	strcpy(env.pubname,			ArgString(tooltypes,	PUBSCREEN_TOOLTYPE, "*"));
	strcpy(macrodefinition,	ArgString(tooltypes,	MACROS_TOOLTYPE, DEFAULT_MACROS));

	strcpy(code.author,			ArgString(tooltypes,	AUTHOR_TOOLTYPE, AUTHOR));
	strcpy(code.copyright,	ArgString(tooltypes,	COPYRIGHT_TOOLTYPE, COPYRIGHT));
	strcpy(code.version,		ArgString(tooltypes,	VERSION_TOOLTYPE, VERS));
	strcpy(code.portname,		ArgString(tooltypes,	PORTNAME_TOOLTYPE, DEFAULT_PORTNAME));

#ifdef MYDEBUG_H
	debugarg=1+ArgBool(tooltypes,	DEBUG_TOOLTYPE);
#endif

	ArgArrayDone();

	return TRUE;
}

LONG ConfirmActions(ULONG MSG_ACTION, BYTE force)
{
	LONG retvalue=1;

#ifdef MYDEBUG_H
	DebugOut("ConfirmActions");
#endif

	if(force || mainTask.window==NULL)
		return TRUE;
	if(env.acknowledge && env.changes>0 && !IsNil(commandlist))
	{
		UBYTE buttons[MAXCHARS];

		sprintf(buttons, egGetString(MSG_PROJECTCHANGEDBUTTONS),
											egGetString(MSG_ACTION), egGetString(MSG_ACTION));

		switch(egRequest(	mainTask.window,
											NAME,
											egGetString(MSG_PROJECTCHANGED),
											buttons,
											(APTR)env.changes,
											(APTR)FilePart(project),
											(APTR)egGetString(MSG_ACTION)))
		{
			case 2:
				WriteIFF(commandlist, project);
			case 1:
				retvalue=1;
				break;
			case 0:
				retvalue=0;
				break;
		}
	}

	return retvalue;
}

BYTE SafeToQuit(ULONG MSG_ACTION, BYTE force)
{
	register BYTE safe=TRUE;

#ifdef MYDEBUG_H
	DebugOut("SafeToQuit");
#endif

	if(!env.lockedscreen)
	{
		while(TRUE)
		{
			ULONG visitors;

			if(visitors=egCountVisitors(mainTask.screen))
			{
				DisplayBeep(mainTask.screen);
				if(0==egRequest(	mainTask.window,
													NAME,
			 										egGetString(MSG_STILLVISITORS),
	 												egGetString(MSG_RETRYCANCEL),
													(APTR)egGetString(MSG_ACTION),
													(APTR)visitors))
				{
					safe=FALSE;
					break;
				}
			}
			else
			{
				safe=TRUE;
				break;
			}
		}
	}

	if(safe==TRUE && MSG_ACTION==MSG_QUIT)
		if(0==ConfirmActions(MSG_ACTION, force))
			safe=FALSE;

	return safe;
}

BYTE SelectFont(void)
{
	BYTE reset;

	egLockAllTasks(eg);
	reset=FontRequest(mainTask.window,
										MSG_SELECTFONT,
										&env.textAttr,
										FOF_DOSTYLE,
										MSG_OK);
	egUnlockAllTasks(eg);
/*
	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,		"CHANGE FONT",
//													(KeepContents() ? ER_ArgumentString:TAG_IGNORE),	file,
													TAG_DONE);
*/
	return reset;
}

void AdjustPalette(struct Window *window)
{
#ifdef MYDEBUG_H
	DebugOut("AdjustPalette");
#endif

	egLockAllTasks(eg);

	openreqtools();
	if(ReqToolsBase)
	{
		struct Process	*myproc=(struct Process *)FindTask(NULL);
		APTR						oldwinptr=myproc->pr_WindowPtr;
		myproc->pr_WindowPtr=window;

		rtPaletteRequest(	egGetString(MSG_ADJUSTPALETTE),
											NULL,
											RT_Locale,	locale,
											RT_ReqPos,	REQPOS_CENTERSCR,
											TAG_DONE);

		myproc->pr_WindowPtr=oldwinptr;
	}
	SetColors(mainTask.screen->ViewPort.ColorMap, env.colors);
/*
	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,		"CHANGE PALETTE",
//													(KeepContents() ? ER_ArgumentString:TAG_IGNORE),	file,
													TAG_DONE);
*/
	egUnlockAllTasks(eg);
}

BYTE RT_SelectScreen(struct Window *window, struct ScreenInfo *screeninfo)
{
	BYTE success=FALSE;

#ifdef MYDEBUG_H
	DebugOut("RT_SelectScreen");
#endif

	openreqtools();
	if(ReqToolsBase)
	{
		struct Process	*myproc;
		APTR						oldwinptr;
		struct rtScreenModeRequester *scrmodereq=rtAllocRequest(RT_SCREENMODEREQ, NULL);

		myproc=(struct Process *)FindTask(NULL);
		oldwinptr=myproc->pr_WindowPtr;
		myproc->pr_WindowPtr=window;

		if(scrmodereq)
			if(rtScreenModeRequest(	scrmodereq,
															GetString(&li, MSG_SELECTSCREENMODE),
															RTSC_Flags,	SCREQF_OVERSCANGAD|
																					SCREQF_AUTOSCROLLGAD|
																					SCREQF_SIZEGADS|
																					SCREQF_DEPTHGAD|
																					SCREQF_GUIMODES,
															RTSC_MinWidth,	MINSCREENWIDTH,
															RTSC_MinHeight,	MINSCREENHEIGHT,
															TAG_DONE))
			{
				screeninfo->DisplayID			=scrmodereq->DisplayID;
				screeninfo->DisplayWidth	=scrmodereq->DisplayWidth;
				screeninfo->DisplayHeight	=scrmodereq->DisplayHeight;
				screeninfo->DisplayDepth	=scrmodereq->DisplayDepth;
				screeninfo->OverscanType	=scrmodereq->OverscanType;
				screeninfo->AutoScroll		=scrmodereq->AutoScroll;

				success=TRUE;
			}
		myproc->pr_WindowPtr=oldwinptr;
/*
		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,		"CHANGE SCREENMODE",
//														(KeepContents() ? ER_ArgumentString:TAG_IGNORE),	file,
														TAG_DONE);
*/
	}
	return success;
}

BYTE SelectScreenMode(void)
{
	register BYTE reset=FALSE;

	egLockAllTasks(eg);

	if(KickStart<38)
	{
		if(RT_SelectScreen(mainTask.window, &env.screeninfo))
			reset=TRUE;
	}
	else if(ScreenModeRequest(mainTask.window,
														MSG_SELECTSCREENMODE,
														&env.screeninfo,
														TRUE,
														MSG_OK))
		reset=TRUE;
	egUnlockAllTasks(eg);
/*	
	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,		"CHANGE SCREENMODE",
//													(KeepContents() ? ER_ArgumentString:TAG_IGNORE),	file,
													TAG_DONE);
*/
	return reset;
}

/** GUI Environment I/O *************************************************************/
LONG ReadEnv(struct GUIEnv *env, char *file)
{
	struct IFFHandle *iff;
	struct ContextNode	*cn;
	long error=0;

#ifdef MYDEBUG_H
	DebugOut("ReadEnv");
#endif

	if(iff=AllocIFF())
	{
		if(iff->iff_Stream=Open(file, MODE_OLDFILE))
		{
			InitIFFasDOS (iff);
			if(!(error=OpenIFF(iff, IFFF_READ)))
			{
				ParseIFF(iff, IFFPARSE_RAWSTEP);
				if(cn=CurrentChunk(iff))
				{
					if(cn->cn_ID!=ID_FORM & cn->cn_Type!=ID_XGUI)
						error=IFFERR_NOTIFF;
					else
					{
						while(TRUE)
						{
							error=ParseIFF(iff, IFFPARSE_RAWSTEP);
							if(error==IFFERR_EOC)
								continue;
							else if(error)
								break;

							if(cn=CurrentChunk(iff))
							{
								switch(cn->cn_ID)
								{
									case ID_ACKN:
										ReadChunkBytes(iff, (APTR)&env->acknowledge, cn->cn_Size);
										break;
									case ID_EXIT:
										ReadChunkBytes(iff, (APTR)&env->savewhenexit, cn->cn_Size);
										break;
									case ID_SREF:
										ReadChunkBytes(iff, (APTR)&env->simplerefresh, cn->cn_Size);
										break;
									case ID_CLWB:
										ReadChunkBytes(iff, (APTR)&env->closeworkbench, cn->cn_Size);
										break;
									case ID_OSCR:
										ReadChunkBytes(iff, (APTR)&env->ownscreen, cn->cn_Size);
										break;
									case ID_BACK:
										ReadChunkBytes(iff, (APTR)&env->backdrop, cn->cn_Size);
										break;
									case ID_SHAI:
										ReadChunkBytes(iff, (APTR)&env->shanghai, cn->cn_Size);
										break;
									case ID_SFNT:
										ReadChunkBytes(iff, (APTR)&env->usescreenfont, cn->cn_Size);
										break;

									case ID_MCOO:
										ReadChunkBytes(iff, (APTR)&mainTask.coords, cn->cn_Size);
										CLEARBIT(mainTask.flags, TASK_NOSIZE);
										break;
									case ID_CCOO:
										ReadChunkBytes(iff, (APTR)&codeTask.coords, cn->cn_Size);
										if(codeTask.coords.Width)
											CLEARBIT(codeTask.flags, TASK_NOSIZE);
										break;
									case ID_XCOO:
										ReadChunkBytes(iff, (APTR)&assignTask.coords, cn->cn_Size);
										if(assignTask.coords.Width)
											CLEARBIT(assignTask.flags, TASK_NOSIZE);
										break;
									case ID_ACOO:
										ReadChunkBytes(iff, (APTR)&aboutTask.coords, cn->cn_Size);
										if(aboutTask.coords.Width)
											CLEARBIT(aboutTask.flags, TASK_NOSIZE);
										break;

									case ID_CWIN:
										ReadChunkBytes(iff, (APTR)&codeTask.status, cn->cn_Size);
										break;
									case ID_XWIN:
										ReadChunkBytes(iff, (APTR)&assignTask.status, cn->cn_Size);
										break;
									case ID_AWIN:
										ReadChunkBytes(iff, (APTR)&aboutTask.status, cn->cn_Size);
										break;

									case ID_FONT:
										ReadChunkBytes(iff, (APTR)&env->textAttr, cn->cn_Size);
										break;
									case ID_FNAM:
										{
											register UBYTE font[MAXCHARS];

											ReadChunkBytes(iff, (APTR)font, cn->cn_Size);
											if(strlen(font))
											{
												free(env->textAttr.ta_Name);
												env->textAttr.ta_Name=strdup(font);
											}
										}
										break;
									case ID_SCRN:
										ReadChunkBytes(iff, (APTR)&env->screeninfo, cn->cn_Size);
										break;
									case ID_COLS:
										ReadChunkBytes(iff, (APTR)env->colors, cn->cn_Size);
										break;
									case ID_FIRQ:
										ReadChunkBytes(iff, (APTR)&env->filerequester, cn->cn_Size);
										break;
									case ID_FORQ:
										ReadChunkBytes(iff, (APTR)&env->fontrequester, cn->cn_Size);
										break;
									case ID_SCRQ:
										ReadChunkBytes(iff, (APTR)&env->screenrequester, cn->cn_Size);
										break;
								}
							}
						}
					}
				}
				else
					error=IFFERR_NOTIFF;
				CloseIFF(iff);
			}
			Close(iff->iff_Stream);
		}
		else
			FailRequest(mainTask.window, MSG_NOTFOUND, (APTR)file, NULL);
		FreeIFF(iff);
	}
	if(error==IFFERR_NOTIFF)
		FailRequest(mainTask.window, MSG_IFFERROR2, NULL);
	else if(error<IFFERR_NOMEM)
		FailRequest(mainTask.window, MSG_IFFERROR1, NULL);

	return error;
}

LONG WriteEnv(struct GUIEnv *env, char *file)
{
	struct IFFHandle *iff;
	long error;

#ifdef MYDEBUG_H
	DebugOut("WriteGUI");
#endif

	if(iff=AllocIFF())
	{
		if(iff->iff_Stream=Open(file, MODE_NEWFILE))
		{
			InitIFFasDOS(iff);
			if(!(error=OpenIFF(iff, IFFF_WRITE)))
			{
				register LONG size;

				PushChunk(iff, ID_PREF, ID_FORM, IFFSIZE_UNKNOWN);

				myWriteChunkData(iff, ID_ACKN, (APTR)&env->acknowledge);
				myWriteChunkData(iff, ID_EXIT, (APTR)&env->savewhenexit);
				myWriteChunkData(iff, ID_SREF, (APTR)&env->simplerefresh);
				myWriteChunkData(iff, ID_CLWB, (APTR)&env->closeworkbench);
				myWriteChunkData(iff, ID_OSCR, (APTR)&env->ownscreen);
				myWriteChunkData(iff, ID_BACK, (APTR)&env->backdrop);
				myWriteChunkData(iff, ID_SHAI, (APTR)&env->shanghai);
				myWriteChunkData(iff, ID_SFNT, (APTR)&env->usescreenfont);

				myWriteChunkStruct(iff, ID_MCOO, (APTR)&mainTask.coords, size=sizeof(struct egCoords));
				myWriteChunkStruct(iff, ID_CCOO, (APTR)&codeTask.coords, size);
				myWriteChunkStruct(iff, ID_XCOO, (APTR)&assignTask.coords, size);
				myWriteChunkStruct(iff, ID_ACOO, (APTR)&aboutTask.coords, size);

				myWriteChunkStruct(iff, ID_FIRQ, (APTR)&env->filerequester, size);
				myWriteChunkStruct(iff, ID_FORQ, (APTR)&env->fontrequester, size);
				myWriteChunkStruct(iff, ID_SCRQ, (APTR)&env->screenrequester, size);

				myWriteChunkStruct(iff, ID_CWIN, (APTR)&codeTask.status, size=sizeof(BYTE));
				myWriteChunkStruct(iff, ID_XWIN, (APTR)&assignTask.status, size);
				myWriteChunkStruct(iff, ID_AWIN, (APTR)&aboutTask.status, size);

				myWriteChunkStruct(iff, ID_SCRN, (APTR)&env->screeninfo, sizeof(env->screeninfo));

				PushChunk(iff, 0, ID_COLS, IFFSIZE_UNKNOWN);
				WriteChunkBytes(iff, (APTR)env->colors, sizeof(env->colors));
				PopChunk(iff);

				myWriteChunkStruct(iff, ID_FONT, (APTR)&env->textAttr, sizeof(struct TextAttr));

				PushChunk(iff, 0, ID_FNAM, IFFSIZE_UNKNOWN);
				WriteChunkBytes(iff, env->textAttr.ta_Name, strlen(env->textAttr.ta_Name)+1);
				PopChunk(iff);

				PopChunk(iff);
				CloseIFF(iff);
			}
			Close(iff->iff_Stream);
		}
		FreeIFF(iff);
	}
	return error;
}

BYTE OpenEnv(struct GUIEnv *env, char *file)
{
	BYTE success;
#ifdef MYDEBUG_H
	DebugOut("OpenEnv");
#endif

	egLockAllTasks(eg);
	if(success=FileRequest(	mainTask.window,
													MSG_SELECTGUI,
													file,
													NULL,
													NULL,
													MSG_OK))
	{
		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,		"OPEN ENVIRONMENT '%s'",
														ER_Argument,	(KeepContents() ? file:NULL),
														TAG_DONE);
	}
	egUnlockAllTasks(eg);

	return success;
}

LONG SaveEnv(struct GUIEnv *env, char *file)
{
	long error=0;
#ifdef MYDEBUG_H
	DebugOut("SaveEnv");
#endif

	egLockAllTasks(eg);
	if(FileRequest(	mainTask.window,
									MSG_SELECTGUI,
									file,
									FRF_DOSAVEMODE,
									NULL,
									MSG_OK))
		if(OverwriteFile(file))
		{
			if(record)
				AddARexxMacroCommand(	macro,
															ER_Command,		"SAVE ENVIRONMENT AS",
															ER_Argument,	(KeepContents() ? file:NULL),
															TAG_DONE);
			error=WriteEnv(env, file);
		}
	egUnlockAllTasks(eg);
	return error;
}

#endif
