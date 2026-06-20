/** DoRev Header ** Do not edit! **
*
* Name             :  DropStrings.c
* Copyright        :  Copyright 1993 Steve Anichini. All Rights Reserved.
* Creation date    :  21-Jun-93
* Translator       :  SAS/C 5.1b
*
* Date       Rev  Author               Comment
* ---------  ---  -------------------  ----------------------------------------
* 21-Jun-93    0  Steve Anichini       Put strings in separate module.
*
*** DoRev End **/

#include "DropBox.h"
#include "window.h"

char *error[] =
{
	"",
	"DropBox requires Icon library V37+.",
	"DropBox requires Workbench library V37+.",
	"DropBox requires Graphics library V37+.",
	"DropBox requires Intuition library V37+.",
	"DropBox can't find it's icon! (This error shouldn't happen)",
	"DropBox can't open a message port.",
	"DropBox can't create an AppIcon.",
	"DropBox can't create an AppMenuItem.",
	"DropBox requires Commodities library V37+.",
	"DropBox can't create a broker.",
	"DropBox can't create a commodities filter.",
	"DropBox can't create a commodities sender.",
	"DropBox requires Gadtools library V37+.",
	"DropBox requires Utility library V37+.",
	"DropBox can't initialize it's database.",
	"DropBox can't open its window.",
	"DropBox requires IffParse library V37+.",
	"DropBox can't load the prefs file.",
	"DropBox can't save the prefs file.",
	"DropBox can't open a file requester.",
	"DropBox requires Asl library V37+.",
	"There wasn't enough memory to complete that operation.",
	"The executed command failed.",
	"There wasn't enough memory to load the preferences file.",
	"The command template is bad.",
	"A command in the template was not recognized.",
	"The destination directory could not be created.",
};

char *string[] =
{
	"DropBox",
	"DropBox 1.1 by Steve Anichini",
	"Processes the dropped items.",
	"DropBox About Window",
	"DropBox 1.1\n  by Steve Anichini\n\nCopyright 1993 Steve Anichini. All rights reserved.\nSend comments, donations, etc to:\n Steve Anichini\n 380 Grandview Ct\n Algonquin, IL 60102\n internet: zucchini@imsa.edu",
	"Proceed",
	"DropBox Warning",
	"This will erase the current configuration!\n",
	"Proceed|Cancel",
	"DropBox Warning",
	"Current configuration modified!",
	"Proceed|Save First|Cancel",
	"DropBox Message",
	"Format not recognized. Create new entry?",
	"Yes|No",
	"DropBox File Request",
	"DropBox.prefs",
	"ENVARC:",
	"#?.prefs",
	"rawkey control esc",
	"COM",
	"SOURCE",
	"DEST",
	"SOURCEDIR",
	"SOURCEFILE",
	"DropBox I/O Window"
};

/* For looking up the gadget short key */

struct GadLookUp glu[] =
{
	{ "A",GD_Add},
	{ "I",GD_Insert}
};
