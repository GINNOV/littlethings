/*
 *	File:					MainMenu.c
 *	Description:	Defines and handles a variable sized menu structure.
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef MAINMENU_C
#define MAINMENU_C

/*** PRIVATE INCLUDES ****************************************************************/
#include "System.h"
#include "TASK_Assign.h"
#include "TASK_About.h"
#include "TASK_Code.h"
#include "MainMenu.h"
#include "ProjectIO.h"
#include "GenerateCSource.h"
#include "GenerateESource.h"
#include "GenerateModula2Source.h"
#include "GenerateOberonSource.h"
#include "Asl.h"
#include "Designer_AREXX.h"

/*** DEFINES *************************************************************************/
#define	ID_NEWPROJECT				1
#define	ID_OPENPROJECT			2
#define	ID_APPENDPROJECT		3
#define	ID_SAVEPROJECT			4
#define	ID_SAVEPROJECTAS		5
#define	ID_GENERATESETTINGS	6
#define	ID_GENERATECSOURCE	7
#define	ID_GENERATEESOURCE	8
#define	ID_GENERATEMODULA2SOURCE	9
#define	ID_GENERATEOBERONSOURCE	10
#define	ID_ICONIFY					11
#define	ID_QUIT							12

#define	ID_SORTCOMMANDS			100
#define	ID_SORTARGUMENTS		101
#define	ID_LASTSAVED				102

#define	ID_MACROASSIGN			200
#define	ID_MACRO1						201
#define	ID_MACRO2						202
#define	ID_MACRO3						203
#define	ID_MACRO4						204
#define	ID_MACRO5						205
#define	ID_MACRO6						206
#define	ID_MACRO7						207
#define	ID_MACRO8						208
#define	ID_MACRO9						209
#define	ID_MACRO10					210
#define	ID_OTHER						211
#define	ID_STARTRECORDING		212
#define	ID_STOPRECORDING		213
#define	ID_COMMANDSHELL			214
#define	ID_LOADMACROS				215
#define	ID_SAVEMACROS				216
#define	ID_SAVEMACROSAS			217

#define	ID_OWNSCREEN				401
#define	ID_BACKDROP					402
#define	ID_CLOSEWORKBENCH		403
#define	ID_SHANGHAI					404
#define	ID_SIMPLEREFRESH		405
#define	ID_SAVEWHENEXIT			406
#define	ID_ACKNOWLEDGE			407
#define	ID_SELECTSCREENMODE	408
#define	ID_SELECTFONT				409
#define	ID_PALETTE					410
#define	ID_USESCREENFONT		411

#define	ID_OPENSETTINGS			450
#define	ID_SAVESETTINGS			451
#define	ID_SAVESETTINGSAS		452

#define	ID_ABOUT						300
#define	ID_HELPAUTHOR				301
#define	ID_HELPCONTENTS			302
#define	ID_HELPINDEX				303
#define	ID_HELPHELP					304
#define	ID_HELPCOMMANDS			305
#define	ID_HELPARGUMENTS		306
#define	ID_HELPSETTINGS			307
#define	ID_HELPMACROS				308
#define	ID_HELPFLAGS				309
#define	ID_HELPAREXX				310

/*** GLOBALS *************************************************************************/
struct Menu	*mainMenu=NULL;
STRPTR			sources[]={"C\0C", "E\0E", "M\0Modula-2", "B\0Oberon", NULL};	
static			UBYTE arexx[]="AREXX";
/*** FUNCTIONS ***********************************************************************/
BYTE AllocMainMenu(void)
{
	register BYTE i;

#ifdef MYDEBUG_H
	DebugOut("AllocMainMenu");
#endif

	for(i=0; i<MAXMACROS; i++)
	{
		if(strlen(macros[i].fullname)==0)
			strcpy(macros[i].fullname, egGetString(MSG_NOTASSIGNED));
		strcpy(macros[i].name, FilePart(macros[i].fullname));
		sprintf(macros[i].macrokey, "%ld", ((i+1)%MAXMACROS));
	}

	mainMenu=egCreateMenu(
								NM_TITLE,	egGetString(MSG_PROJECT), 				0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_NEW),						0, 0L, ID_NEWPROJECT,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_OPENPROJECT),		0, 0L, ID_OPENPROJECT,
								NM_ITEM,	egGetString(MSG_K_APPEND),				0, 0L, ID_APPENDPROJECT,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_SAVE),					0, 0L, ID_SAVEPROJECT,
								NM_ITEM,	egGetString(MSG_K_SAVEAS),				0, 0L, ID_SAVEPROJECTAS,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_GENERATESOURCE),	0, 0L, NULL,
								NM_SUB,		egGetString(MSG_K_CODEWINDOW),		0, 0L, ID_GENERATESETTINGS,
								NM_SUB,		NM_BARLABEL,											0, 0L, NULL,
								NM_SUB,		sources[0],												0, 0L, ID_GENERATECSOURCE,
								NM_SUB,		sources[1],												0, 0L, ID_GENERATEESOURCE,
								NM_SUB,		sources[2],												0, 0L, ID_GENERATEMODULA2SOURCE,
								NM_SUB,		sources[3],												0, 0L, ID_GENERATEOBERONSOURCE,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_ICONIFY),				0, 0L, ID_ICONIFY,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_QUIT),					0, 0L, ID_QUIT,

								NM_TITLE,	egGetString(MSG_EDIT),						0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_LASTSAVED),			0, 0L, ID_LASTSAVED,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_SORTCOMMANDS),	0, 0L, ID_SORTCOMMANDS,
								NM_ITEM,	egGetString(MSG_K_SORTARGUMENTS),	0, 0L, ID_SORTARGUMENTS,

								NM_TITLE,	egGetString(MSG_SETTINGS),				0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_ACKNOWLEDGE),		CHECKIT|MENUTOGGLE, 0L, ID_ACKNOWLEDGE,
								NM_ITEM,	egGetString(MSG_K_SAVEWHENEXIT),	CHECKIT|MENUTOGGLE, 0L, ID_SAVEWHENEXIT,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_SIMPLEREFRESH),	CHECKIT|MENUTOGGLE, 0L, ID_SIMPLEREFRESH,
								NM_ITEM,	egGetString(MSG_K_CLOSEWB),				CHECKIT|MENUTOGGLE, 0L, ID_CLOSEWORKBENCH,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_OWNSCREEN),			CHECKIT|MENUTOGGLE, 0L, ID_OWNSCREEN,
								NM_ITEM,	egGetString(MSG_K_BACKDROP),			CHECKIT|MENUTOGGLE, 0L, ID_BACKDROP,
								NM_ITEM,	egGetString(MSG_K_SHANGHAI),			CHECKIT|MENUTOGGLE, 0L, ID_SHANGHAI,
								NM_ITEM,	egGetString(MSG_K_USESCREENFONT),	CHECKIT|MENUTOGGLE, 0L, ID_USESCREENFONT,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_SELECTFONT),			NULL,	0L, ID_SELECTFONT,
								NM_ITEM,	egGetString(MSG_SELECTSCREENMODE),NULL, 0L, ID_SELECTSCREENMODE,
								NM_ITEM,	egGetString(MSG_ADJUSTPALETTE),		NULL, 0L, ID_PALETTE,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_OPENSETTINGS),	NULL, 0L, ID_OPENSETTINGS,
								NM_ITEM,	egGetString(MSG_K_SAVESETTINGS),	NULL, 0L, ID_SAVESETTINGS,
								NM_ITEM,	egGetString(MSG_K_SAVESETTINGSAS),NULL, 0L, ID_SAVESETTINGSAS,

								NM_TITLE,	"AREXX", (EasyRexxBase && context ? 0:NM_MENUDISABLED), 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_ASSIGN),				0, 0L, ID_MACROASSIGN,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	macros[0].macrokey,								0, 0L, ID_MACRO1,
								NM_ITEM,	macros[1].macrokey,								0, 0L, ID_MACRO2,
								NM_ITEM,	macros[2].macrokey,								0, 0L, ID_MACRO3,
								NM_ITEM,	macros[3].macrokey,								0, 0L, ID_MACRO4,
								NM_ITEM,	macros[4].macrokey,								0, 0L, ID_MACRO5,
								NM_ITEM,	macros[5].macrokey,								0, 0L, ID_MACRO6,
								NM_ITEM,	macros[6].macrokey,								0, 0L, ID_MACRO7,
								NM_ITEM,	macros[7].macrokey,								0, 0L, ID_MACRO8,
								NM_ITEM,	macros[8].macrokey,								0, 0L, ID_MACRO9,
								NM_ITEM,	macros[9].macrokey,								0, 0L, ID_MACRO10,
								NM_ITEM,	egGetString(MSG_K_OTHER),					0, 0L, ID_OTHER,
								(macro ?	NM_ITEM:NM_IGNORE), NM_BARLABEL,		0, 0L, NULL,
								(macro ?	NM_ITEM:NM_IGNORE), egGetString(MSG_K_STARTRECORDING), 0, 0L, ID_STARTRECORDING,
								(macro ?	NM_ITEM:NM_IGNORE), egGetString(MSG_K_STOPRECORDING), 0, 0L, ID_STOPRECORDING,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_COMMANDSHELL),	0, 0L, ID_COMMANDSHELL,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_K_OPENMACROS),		0, 0L, ID_LOADMACROS,
								NM_ITEM,	egGetString(MSG_K_SAVEMACROS),		0, 0L, ID_SAVEMACROS,
								NM_ITEM,	egGetString(MSG_K_SAVEMACROSAS),	0, 0L, ID_SAVEMACROSAS,

								NM_TITLE,	egGetString(MSG_HELP),						0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_HELPABOUT),				0, 0L, ID_ABOUT,
								NM_ITEM,	egGetString(MSG_HELPAUTHOR),			NULL, 0L, ID_HELPAUTHOR,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_HELPCONTENTS),		NULL, 0L, ID_HELPCONTENTS,
								NM_ITEM,	egGetString(MSG_HELPINDEX),				NULL, 0L, ID_HELPINDEX,
								NM_ITEM,	egGetString(MSG_HELPHELP),				NULL, 0L, ID_HELPHELP,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_HELPCOMMANDS),		NULL, 0L, ID_HELPCOMMANDS,
								NM_ITEM,	egGetString(MSG_HELPARGUMENTS),		NULL, 0L, ID_HELPARGUMENTS,
								NM_ITEM,	egGetString(MSG_HELPFLAGS),				NULL, 0L, ID_HELPFLAGS,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_HELPSETTINGS),		NULL, 0L, ID_HELPSETTINGS,
								NM_ITEM,	NM_BARLABEL,											0, 0L, NULL,
								NM_ITEM,	egGetString(MSG_HELPMACROS),			NULL, 0L, ID_HELPMACROS,
								NM_ITEM,	egGetString(MSG_HELPAREXXCOMMANDS),NULL, 0L, ID_HELPAREXX,

								NM_END);
	return (BYTE)mainMenu;
}

void UpdateMainMenu(void)
{
	register BYTE flag;

#ifdef MYDEBUG_H
	DebugOut("UpdateMainMenu");
#endif

	if(mainMenu && mainTask.window)
	{
		ClearMenuStrip(mainTask.window);
		egSetMenuBit(	mainTask.window, mainMenu, NM_ITEMDISABLED,
									ID_NEWPROJECT,				flag=(IsNil(commandlist)==FALSE),
									ID_APPENDPROJECT,			flag,
									ID_SAVEPROJECT,				flag,
									ID_SAVEPROJECTAS,			flag,
									ID_GENERATECSOURCE,		flag,
									ID_GENERATEESOURCE,		flag,
									ID_GENERATEMODULA2SOURCE,		flag,
									ID_GENERATEOBERONSOURCE,		flag,

									ID_SORTCOMMANDS,			commands->max,
									ID_SORTARGUMENTS,			arguments->max,

									ID_SHANGHAI,					env.ownscreen,
									ID_BACKDROP,					env.ownscreen,
									ID_USESCREENFONT,			!env.ownscreen,
									ID_SELECTFONT,				!env.usescreenfont | env.ownscreen,
									ID_CLOSEWORKBENCH,		flag=env.ownscreen,
									ID_SELECTSCREENMODE,	flag,
									ID_PALETTE,						flag,

									ID_STARTRECORDING,		!record,
									ID_STOPRECORDING,			record,

									NULL);

		egSetMenuBit(	mainTask.window, mainMenu, CHECKED,
									ID_ACKNOWLEDGE,			env.acknowledge,
									ID_SAVEWHENEXIT,		env.savewhenexit,

									ID_SIMPLEREFRESH,		env.simplerefresh,
									ID_CLOSEWORKBENCH,	env.closeworkbench,

									ID_OWNSCREEN,				env.ownscreen,
									ID_BACKDROP,				env.backdrop,
									ID_SHANGHAI,				env.shanghai,
									ID_USESCREENFONT,		env.usescreenfont,
									NULL);
		SetMenuStrip(mainTask.window, mainMenu);
	}
}

void HandleMainMenu(struct egTask *task, UWORD menuNumber)
{
	struct MenuItem	*item;
	ULONG itemnum;
	register BYTE reset=FALSE,
								loadenv=FALSE;

#ifdef MYDEBUG_H
	DebugOut("HandleMainMenu");
#endif

	while(menuNumber!=MENUNULL && task->status==STATUS_OPEN && !loadenv)
	{
		item=ItemAddress(mainMenu, menuNumber);
		itemnum=(ULONG)GTMENUITEM_USERDATA(item);
		switch(itemnum)
		{
			case ID_NEWPROJECT:
				NewProject(FALSE);
				break;
      /*******************************************************************************/
			case ID_OPENPROJECT:
				OpenProject(commandlist, project, FALSE);
				break;
			case ID_APPENDPROJECT:
				AppendProject(commandlist, project);
				break;
      /*******************************************************************************/
			case ID_SAVEPROJECT:
				SaveProject(commandlist, project);
				break;
			case ID_SAVEPROJECTAS:
				SaveProjectAs(commandlist, project);
				break;
      /*******************************************************************************/
			case ID_GENERATESETTINGS:
				OpenCodeTask(NULL, NULL, NULL);
				if(record)
					AddARexxMacroCommand(	macro,
																ER_Command,	"WINDOW CODE OPEN",
																TAG_DONE);
				break;
      /*******************************************************************************/
			case ID_GENERATECSOURCE:
				GenerateSource(MSG_GENERATECSOURCE, TRUE);
				break;
			case ID_GENERATEESOURCE:
				GenerateSource(MSG_GENERATEESOURCE, TRUE);
				break;
			case ID_GENERATEMODULA2SOURCE:
				GenerateSource(MSG_GENERATEMODULA2SOURCE, TRUE);
				break;
			case ID_GENERATEOBERONSOURCE:
				GenerateSource(MSG_GENERATEOBERONSOURCE, TRUE);
				break;
      /*******************************************************************************/
			case ID_ICONIFY:
				closemsg=MSG_ICONIFY;
				egIconify(eg, TRUE);
				break;
      /*******************************************************************************/
			case ID_QUIT:
				Quit();
				break;

			case ID_SORTCOMMANDS:
				SortCommands();
				break;
			case ID_SORTARGUMENTS:
				SortArguments();
				break;
      /*******************************************************************************/
			case ID_LASTSAVED:
				LastSaved(commandlist, project, FALSE);
				break;


			case ID_ACKNOWLEDGE:
				env.acknowledge=egIsMenuItemChecked(mainMenu, ID_ACKNOWLEDGE);
				break;
			case ID_SAVEWHENEXIT:
				env.savewhenexit=egIsMenuItemChecked(mainMenu, ID_SAVEWHENEXIT);
				break;
      /*******************************************************************************/
			case ID_SIMPLEREFRESH:
				env.simplerefresh=egIsMenuItemChecked(mainMenu, ID_SIMPLEREFRESH);
				reset=TRUE;
				break;
			case ID_CLOSEWORKBENCH:
				env.closeworkbench=egIsMenuItemChecked(mainMenu, ID_CLOSEWORKBENCH);
				CloseWB(env.closeworkbench);
				break;
      /*******************************************************************************/
			case ID_OWNSCREEN:
				env.ownscreen=egIsMenuItemChecked(mainMenu, ID_OWNSCREEN);
				reset=TRUE;
				break;
			case ID_BACKDROP:
				env.backdrop=egIsMenuItemChecked(mainMenu, ID_BACKDROP);
				reset=TRUE;
				break;
			case ID_SHANGHAI:
				env.shanghai=egIsMenuItemChecked(mainMenu, ID_SHANGHAI);
				DefaultPubScreen(mainTask.screen, env.pubname, env.shanghai);
				break;
			case ID_USESCREENFONT:
				env.usescreenfont=egIsMenuItemChecked(mainMenu, ID_USESCREENFONT);
				if(	0==Stricmp(mainTask.screen->Font->ta_Name, env.textAttr.ta_Name)	&&
						mainTask.screen->Font->ta_YSize==env.textAttr.ta_YSize						&&
						mainTask.screen->Font->ta_Style==env.textAttr.ta_Style						&&
						mainTask.screen->Font->ta_Flags==env.textAttr.ta_Flags)
					UpdateMainMenu();
				else
					reset=TRUE;
				break;
      /*******************************************************************************/
			case ID_SELECTSCREENMODE:
				reset=SelectScreenMode();
				break;
			case ID_SELECTFONT:
				reset=SelectFont();
				break;
			case ID_PALETTE:
				AdjustPalette(mainTask.window);
				break;
      /*******************************************************************************/
			case ID_OPENSETTINGS:
				reset=loadenv=OpenEnv(&env, guifile);
				break;
			case ID_SAVESETTINGS:
				WriteEnv(&env, ENVARCGUIFILE);
				WriteEnv(&env, ENVGUIFILE);
				break;
			case ID_SAVESETTINGSAS:
				SaveEnv(&env, guifile);
				break;


			case ID_MACROASSIGN:
				OpenAssignTask(NULL, NULL, NULL);
				if(record)
					AddARexxMacroCommand(	macro,
																ER_Command,	"WINDOW ASSIGN OPEN",
																TAG_DONE);
				break;
      /*******************************************************************************/
			case ID_MACRO1:
			case ID_MACRO2:
			case ID_MACRO3:
			case ID_MACRO4:
			case ID_MACRO5:
			case ID_MACRO6:
			case ID_MACRO7:
			case ID_MACRO8:
			case ID_MACRO9:
			case ID_MACRO10:
				itemnum-=ID_MACRO1;
				if(Stricmp(macros[itemnum].fullname, egGetString(MSG_NOTASSIGNED))==0)
				{
					OpenAssignTask(NULL, NULL, NULL);
					DisplayBeep(mainTask.screen);
					egActivateGadget(macrostring[itemnum], assignTask.window, NULL);
				}
				else
					if(0==RunARexxMacro(context,
												ER_MacroFile,	macros[itemnum].fullname,
												TAG_DONE))
						FailRequest(mainTask.window, MSG_NOTFOUND, (APTR)macros[itemnum].fullname, NULL);

				break;
			case ID_OTHER:
				if(FileRequest(	mainTask.window,
												MSG_RUNMACRO,
												macrofile,
												NULL,
												NULL,
												MSG_RUN))
					if(0==RunARexxMacro(context,
												ER_MacroFile,	macrofile,
												TAG_DONE))
						FailRequest(mainTask.window, MSG_NOTFOUND, (APTR)macrofile, NULL);
				break;
      /*******************************************************************************/
      case ID_COMMANDSHELL:
				OpenCommandShell();
      	break;
      /*******************************************************************************/
			case ID_STARTRECORDING:
				if(macro)
				{
					record=TRUE;
					SetAllPointers();
					UpdateMainMenu();
				}
				break;
			case ID_STOPRECORDING:
				ClearAllPointers();
				record=FALSE;
				egLockAllTasks(eg);
				if(!IsARexxMacroEmpty(macro))
				{
					if(FileRequest(	mainTask.window,
													MSG_SAVERECORDEDMACRO,
													macrofile,
													FRF_DOSAVEMODE,
													NULL,
													MSG_SAVE))
					{
						WriteARexxMacro(context, macro, macrofile, TAG_DONE);
						ClearARexxMacro(macro);
					}
				}
				UpdateMainMenu();
				egUnlockAllTasks(eg);
				break;
      /*******************************************************************************/
			case ID_LOADMACROS:
				OpenMacros(macros, macrodefinition);
				break;
			case ID_SAVEMACROS:
				SaveMacros(macros, DEFAULT_MACROS);
				break;
			case ID_SAVEMACROSAS:
				SaveMacrosAs(macros, macrodefinition);
				break;

			case ID_ABOUT:
				OpenAboutTask(NULL, NULL, NULL);
				if(record)
					AddARexxMacroCommand(	macro,
																ER_Command,	"WINDOW ABOUT OPEN",
																TAG_DONE);
				break;
			case ID_HELPAUTHOR:
				ShowHelp("AUTHOR");
				break;
      /*******************************************************************************/
			case ID_HELPCONTENTS:
				ShowHelp("MAIN");
				break;
			case ID_HELPINDEX:
				ShowHelp("INDEXNODE");
				break;
			case ID_HELPHELP:
				ShowHelp("HELP");
				break;
			case ID_HELPCOMMANDS:
				ShowHelp("COMMANDS");
				break;
			case ID_HELPARGUMENTS:
				ShowHelp("ARGUMENTS");
				break;
			case ID_HELPSETTINGS:
				ShowHelp("CODEWINDOW");
				break;
			case ID_HELPFLAGS:
				ShowHelp("SWITCHES");
				break;
			case ID_HELPMACROS:
				ShowHelp("MACROWINDOW");
				break;
			case ID_HELPAREXX:
				ShowHelp("AREXX");
				break;
		}
		menuNumber=item->NextSelect;
	}
	if(reset && SafeToQuit(MSG_RESETGUI, FALSE))
	{
			closemsg=MSG_RESETGUI;
			SETBIT(eg->flags, EG_RESET);
			egCloseAllTasks(eg);
			if(loadenv)
				ReadEnv(&env, guifile);
			egOpenAllTasks(eg);
			CLEARBIT(eg->flags, EG_RESET);
	}
}

void UpdateMacroMenu(void)
{
#ifdef MYDEBUG_H
	DebugOut("UpdateMacroMenu");
#endif

	if(mainMenu)
	{
		ClearMenuStrip(mainTask.window);
		if(LayoutMenus(	mainMenu, mainTask.VisualInfo,
										GTMN_NewLookMenus,	TRUE,
										TAG_END))
;//			egMakeHelpMenu(mainMenu, mainTask.screen);
		SetMenuStrip(mainTask.window, mainMenu);
	}
}

void NewProject(BYTE force)
{
	if(ConfirmActions(MSG_CLEAR, force))
	{
		ClearList(commandlist);
		ResetMainTask();
		*PathPart(project)='\0';
		AddPart(project, egGetString(MSG_UNNAMED), MAXCHARS-1);
		UpdateMainTask(FALSE);
		UpdateAboutTask();
		MakeMainTitle();
		env.changes=0;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,		"NEW PROJECT",
														TAG_DONE);
	}
}

void SetAllPointers(void)
{
	register struct egTask *task;

	if(record)
		for(task=eg->tasklist; task; task=task->nexttask)
			if(task->window)
				SetPointer(	task->window,
										ER_RecordPointer,
										ER_RECORDPOINTERHEIGHT,
										ER_RECORDPOINTERWIDTH,
										ER_RECORDPOINTEROFFSET,
										0);
}

void ClearAllPointers(void)
{
	register struct egTask *task;

	for(task=eg->tasklist; task; task=task->nexttask)
		if(task->window)
			ClearPointer(task->window);
}

void ShowHelp(UBYTE *topic)
{
	egShowAmigaGuide(eg, topic);
	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command, 	"HELP '%s'",
													ER_Argument,	topic,	
													TAG_DONE);

}

void OpenCommandShell(void)
{
	ARexxCommandShell(context,
										ER_Font,					topaz,
										WA_Title,					NAME " Shell",
										WA_PubScreen,			mainTask.screen,
										ER_Prompt,				DEFAULT_PROMPT,
										WA_Top,						mainTask.window->TopEdge+mainTask.window->Height,
										WA_Left,					mainTask.window->LeftEdge,
										WA_Width,					mainTask.window->Width,
										WA_Height,				100,
										WA_DragBar,				TRUE,
										WA_DepthGadget,		TRUE,
										WA_SizeGadget,		TRUE,
										WA_CloseGadget,		TRUE,
										WA_MinWidth,			70,
										WA_MinHeight,			70,
										WA_MaxWidth,			~0,
										WA_MaxHeight,			~0,
										WA_SizeBBottom,		TRUE,
										TAG_DONE);
	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,		"COMMANDSHELL OPEN",
													TAG_DONE);
}

void GenerateSource(ULONG MSG, BYTE showreq)
{
	register BYTE		ok=TRUE;
	register UBYTE	type[MAXCHARS];

#ifdef MYDEBUG_H
	DebugOut("GenerateSource");
#endif

	egLockAllTasks(eg);

	if(showreq)
		ok=FileRequest(	mainTask.window,
										MSG,
										generatefile,
										FRF_DOSAVEMODE,
										NULL,
										MSG_GENERATE);
	if(ok && OverwriteFile(generatefile))
	{
		switch(MSG)
		{
			case MSG_GENERATECSOURCE:
				GenerateCSource(commandlist, generatefile);
				strcpy(type, "C");
				break;
			case MSG_GENERATEESOURCE:
				GenerateESource(commandlist, generatefile);
				strcpy(type, "E");
				break;
			case MSG_GENERATEMODULA2SOURCE:
				GenerateModula2Source(commandlist, generatefile);
				strcpy(type, "MODULA2");
				break;
			case MSG_GENERATEOBERONSOURCE:
				GenerateOberonSource(commandlist, generatefile);
				strcpy(type, "OBERON");
				break;
		}
		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,			"GENERATE %s '%s'",
														ER_Arguments,		type,
																						(KeepContents() ? generatefile:NULL),
														TAG_DONE);
	}
	egUnlockAllTasks(eg);
	SetAllPointers();
}

void Quit(void)
{
#ifdef MYDEBUG_H
	DebugOut("SaveEnvHook");
#endif

	if(SafeToQuit(closemsg=MSG_QUIT, FALSE))
	{
		if(env.savewhenexit)
			WriteEnv(&env, ENVARCGUIFILE);
		WriteEnv(&env, ENVGUIFILE);
		if(EasyRexxBase)
			ARexxCommandShell(context, ER_Close, TRUE, TAG_DONE);
		egCloseAllTasks(eg);
	}
}

#endif
