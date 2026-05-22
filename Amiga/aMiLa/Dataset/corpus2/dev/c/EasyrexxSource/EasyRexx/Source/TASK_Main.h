/*
 *	File:					TASK_Main.h
 *	Description:	Main window where most actions are triggered from.
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef TASK_MAIN_H
#define TASK_MAIN_H

/*** DEFINES *************************************************************************/
#define	ALWAYS					1
#define	KEYWORD					2
#define	NUMBER					4
#define	SWITCH					8
#define	TOGGLE					16
#define	MULTIPLE				32
#define	FINAL						64

#define	MAXDATALEN			100
#define	MAXNAMELEN			50

/*** GLOBALS *************************************************************************/
extern struct egTask	mainTask;

extern struct CommandNode	*commandnode,
													*commandbuffer;
extern struct Node				*argumentnode,
													*argumentbuffer;
extern struct List				*commandlist,
													*argumentlist;

extern UBYTE							assign,
													commandname[MAXCHARS],
													argumentname[MAXCHARS],
													windowtitle[MAXCHARS];

extern struct egGadget		*commands,
													*commandstring,
													*arguments,
													*argumentstring;
extern UWORD							activecommand,
													activeargument;
extern ULONG							closemsg;

struct CommandNode
{
	struct Node nn_Node;
	struct List *argumentlist;
};

extern struct Hook upperHook;

/*** PROTOTYPES **********************************************************************/
__asm __saveds ULONG upperHookFunc(	register __a0 struct Hook		*hook,
																		register __a2 struct SGWork	*sgw,
																		register __a1 ULONG					*msg);
__asm __saveds ULONG OpenMainTask(register __a0 struct Hook *hook,
																	register __a2 APTR	      object,
																	register __a1 APTR	      message);
__asm __saveds ULONG HandleMainTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message);
void UpdateMainTask(BYTE argumentsonly);
void ResetMainTask(void);
void GetFirstCommand(void);
void GetFirstArgument(void);

UWORD SortCommands(void);
UWORD SortArguments(void);

void GetSelectedCommand(UWORD code);
void GetSelectedArgument(UWORD code);

void CutCommand(void);
void CutArgument(void);

void PasteCommand(void);
void PasteArgument(void);

void MoveCommandUp(void);
void MoveCommandDown(void);
void MoveArgumentUp(void);
void MoveArgumentDown(void);

void CopyCommand(void);
void CopyArgument(void);

UBYTE *MakeMainTitle(void);

void AddCommand(UBYTE *);
void AddArgument(UBYTE *name);

void RenameCommand(UBYTE *name);
void RenameArgument(UBYTE *name);

#endif
