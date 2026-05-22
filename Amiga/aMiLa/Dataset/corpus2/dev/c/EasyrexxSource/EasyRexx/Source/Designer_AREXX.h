/*
 *	File:					Designer_AREXX.h
 *	Description:	
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef AREXX_INTERFACE
#define AREXX_INTERFACE

/*** INCLUDES ************************************************************************/
#include <libraries/easyrexx.h>

/*** DEFINES *************************************************************************/
#define	DEFAULT_PROMPT	"AREXX> "
#define	MAXMACROS				10

/*** GLOBALS *************************************************************************/
extern struct Library						*EasyRexxBase;
extern struct ARexxContext			*context;
extern struct ARexxCommandTable commandTable[];
extern BYTE											record;
extern ARexxMacro								macro;

struct Macro
{
	UBYTE macrokey[2],		/* menu shortcut key	*/
				name[108],			/* macro name.  only 30 is used today, but it may be
												** extended in the future...
												*/
				fullname[108];	/* full macro name		*/
};

extern struct Macro macros[MAXMACROS];

/*** PROTOTYPES **********************************************************************/
void myHandleARexx(struct ARexxContext *c);
LONG ReadMacros(struct Macro *macros, UBYTE *file);
LONG OpenMacros(struct Macro *macros, UBYTE *file);
LONG SaveMacros(struct Macro *macros, UBYTE *file);
LONG SaveMacrosAs(struct Macro *macros, UBYTE *file);

LONG KeepContents(void);
__asm UBYTE *ARexxInput(register __a0 UBYTE *string);
