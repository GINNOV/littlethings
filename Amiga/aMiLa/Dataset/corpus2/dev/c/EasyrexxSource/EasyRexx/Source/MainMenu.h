/*
 *	File:					MainMenu.h
 *	Description:	Defines and handles the main variable sized menu structure.
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef MAINMENU_H
#define MAINMENU_H

/*** DEFINES *************************************************************************/
#define	MACROKEYLEN					2

/*** GLOBALS *************************************************************************/
extern struct Menu	*mainMenu;

/*** PROTOTYPES **********************************************************************/
BYTE AllocMainMenu(void);
void HandleMainMenu(struct egTask *task, UWORD menuNumber);
void UpdateMacroMenu(void);
void UpdateMainMenu(void);
void NewProject(BYTE force);

void SetAllPointers(void);
void ClearAllPointers(void);
void ShowHelp(UBYTE *topic);

void OpenCommandShell(void);

void GenerateSource(ULONG MSG, BYTE showreq);
void Quit(void);

#endif
