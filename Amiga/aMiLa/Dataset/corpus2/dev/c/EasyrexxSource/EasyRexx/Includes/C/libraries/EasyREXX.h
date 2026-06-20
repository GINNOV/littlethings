/*
 *	File:					EasyRexx.h
 *	Description:	Headerfile for the easyrexx.library
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 *	Set Tab=2 for best readability
 *
 */

#ifndef LIBRARIES_EASYREXX_H
#define LIBRARIES_EASYREXX_H

/*** PRIVATE INCLUDES ****************************************************************/
#ifndef	EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef REXX_ERRORS_H
#include <rexx/errors.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

/*** DEFINES *************************************************************************/
#define	EASYREXXNAME				"easyrexx.library"
#define	EASYREXXVERSION			3L

#ifndef EASYREXX_NOMACROS

#define	ER_SHELLSIGNALS(c)	((c)->shell ? (1L<<(c)->shell->readPort->mp_SigBit | 1L<<(c)->shell->commandWindow->UserPort->mp_SigBit): 0)
#define	ER_SIGNALDUMMY(c)		(	1L<<(c)->port->mp_SigBit | \
															1L<<(c)->asynchport->mp_SigBit | \
															ER_SHELLSIGNALS(c))
#define	ER_SIGNAL(c)				(c ? ER_SIGNALDUMMY(c):0L)
#define	ER_SAFETOQUIT(c)		(c ? ((c)->Queue==0):0)
#define	ER_SETSIGNALS(c,s)	if(c) (c)->signals=s
#define	ER_ISSHELLOPEN(c)		((c)->shell==NULL ? 0:1)

#define ARG(c,i)						((c)->argv[i])
#define	ARGNUMBER(c,i)			(*((LONG *)(c)->argv[i]))
#define	ARGSTRING(c,i)			((STRPTR)(c)->argv[i])
#define	ARGBOOL(c,i)				((c)->argv[i]==NULL ? 0:1)

#define	GETRC(c)						(c ? (c)->Result1:NULL)
#define	GETRESULT1(c)				GETRC(c)
#define	GETRESULT2(c)				(c ? (c)->Result2:NULL)

#define	TABLE_END						NULL,NULL,NULL,NULL

#endif

/*** GLOBALS *************************************************************************/

/* The EasyRexx structures are READ-ONLY */
struct ARexxCommandTable
{
	LONG		id;
	STRPTR	command,
					cmdtemplate;
	APTR		userdata;
};

struct ARexxCommandShell
{
	struct Window		*commandWindow;
	struct MsgPort	*readPort,
									*writePort;
	struct IOStdReq	*readReq,
									*writeReq;
	UBYTE						*prompt,
									buffer[256],
									ibuf,
									inbuffer;
	BYTE						cursor;
	struct TextFont	*font;
};

struct ARexxContext
{
	struct MsgPort						*port;
	struct ARexxCommandTable	*table;
	UBYTE											*argcopy,
														*portname,
														maxargs;
	struct RDArgs							*rdargs;
	struct RexxMsg						*msg;
	ULONG											flags;

	LONG											id,
														*argv;
	ULONG											Queue;			/* FROM HERE AND DOWN: ONLY AVAILABLE FROM V2 */

	UBYTE											*author,
														*copyright,
														*version,
														*lasterror;
	struct ARexxCommandTable	*reservedcommands;
	struct ARexxCommandShell	*shell;
	ULONG											signals;
	LONG											Result1,
														Result2;
	struct MsgPort						*asynchport;
};

/* V3.0 *****************************************************************************/
struct ARexxMacroData
{
	struct List *list;
};

typedef	struct ARexxMacroData *	ARexxMacro;
typedef BYTE										(*ARexxFunc)(struct ARexxContext *c);

#ifndef NO_RECORDPOINTER

#define	ER_RECORDPOINTERWIDTH		16
#define	ER_RECORDPOINTERHEIGHT	17
#define	ER_RECORDPOINTEROFFSET -1

static UWORD __chip ER_RecordPointer[] =
{
  0x0000, 0x0000,

  0xc000, 0x4000,
  0x7000, 0xb000,
  0x3c00, 0x4c00,
  0x3f00, 0x4300,
  0x1fc0, 0x20c0,
  0x1fc0, 0x2000,
  0x0f00, 0x1100,
  0x0d80, 0x1280,
  0x04c0, 0x0940,
  0x0460, 0x08a0,
  0x0020, 0x0040,
  0x0000, 0x0000,
  0x0000, 0xe798,
  0x0000, 0x9424,
  0x0000, 0xe720,
  0x0000, 0x9424,
  0x0000, 0x9798,

  0x0000, 0x0000,
};
#endif

/************************************************************************************/

#ifndef CLIB_EASYREXX_PROTOS_H
#include <clib/easyrexx_protos.h>
#endif

/***** TAGS *************************************************************************/
#define	ER_TagBase					(TAG_USER)
#define	ER_Portname					(ER_TagBase+1)	/* Name of AREXX port									*/
#define	ER_CommandTable			(ER_TagBase+2)	/* Table of supported AREXX commands	*/
#define	ER_ReturnCode				(ER_TagBase+3)	/* Primary result (return code)				*/
#define	ER_Result						(ER_ReturnCode)	/* Alias for ER_ReturnCode						*/
#define	ER_Result1					(ER_ReturnCode)	/* Alias for ER_ReturnCode						*/
#define	ER_Result2					(ER_TagBase+4)	/* Secondary result (string)					*/
#define	ER_Port							(ER_TagBase+5)	/* Use already created port						*/
#define	ER_ResultString			(ER_TagBase+6)	/* Secondary result (string)					*/
#define	ER_ResultLong				(ER_TagBase+7)	/* Secondary result (long)						*/

/***** EASYREXX V2 TAGS ***********************************************************/
#define	ER_Asynch						(ER_TagBase+8)	/* Send ARexx command asyncronously		*/
#define	ER_Context					(ER_TagBase+9)	/* Pointer to an ARexxContext					*/
#define	ER_Author						(ER_TagBase+10)	/* Pointer to an author string				*/
#define	ER_Copyright				(ER_TagBase+11)	/* Pointer to an copyright string			*/
#define	ER_Version					(ER_TagBase+12)	/* Pointer to an version string				*/
#define	ER_Prompt						(ER_TagBase+13)	/* Pointer to a prompt string					*/
#define	ER_Close						(ER_TagBase+14)	/* Close CommandShell									*/
#define	ER_ErrorMessage			(ER_TagBase+15)	/* Pointer to an error message				*/
#define	ER_Flags						(ER_TagBase+16)	/* LONG of flags											*/
#define ER_Font							(ER_TagBase+17) /* Pointer to a struct TextFont *			*/

/***** EASYREXX V3 TAGS ***********************************************************/
#define	ER_Macro						(ER_TagBase+18)	/* Pointer to ARexxMacro							*/
#define	ER_MacroFile				(ER_TagBase+19)	/* Pointer to a macrofile							*/
#define	ER_Record						(ER_TagBase+20)	/* Really record macro command				*/
#define	ER_File							(ER_TagBase+21)	/* Send file													*/
#define	ER_String						(ER_TagBase+22)	/* Send string												*/
#define	ER_Command					(ER_TagBase+23)	/* Pointer to commandstring						*/
#define	ER_Arguments				(ER_TagBase+24)	/* Var-array of arguments							*/
#define	ER_Argument					(ER_Arguments)
#define	ER_ArgumentsLength	(ER_TagBase+25)	/* CharLength of command+arguments		*/
#define	ER_ArgumentLength		(ER_ArgumentsLength)

#endif
