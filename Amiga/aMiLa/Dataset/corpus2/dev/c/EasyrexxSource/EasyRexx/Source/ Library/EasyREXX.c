/*
 *	File:					EasyRexx.c
 *	Description:	A runtime shared library that simplifies application AREXX
 *								handling.
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef EASYREXX_C
#define	EASYREXX_C

#define	ER_LIB					1

/*** INCLUDES ************************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <exec/ports.h>
#include <utility/utility.h>
#include <utility/tagitem.h>
#include <rexx/storage.h>
#include <rexx/rxslib.h>
#include <rexx/errors.h>
#include <intuition/intuition.h>

#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/utility_protos.h>
#include <clib/macros.h>
#include <clib/alib_stdio_protos.h>
#include <clib/rexxsyslib_protos.h>

#include <stdlib.h>
#include <string.h>

#include <pragmas/intuition_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/rexxsyslib_pragmas.h>
#include <pragmas/graphics_pragmas.h>

/*** DEFINES *************************************************************************/
#define	GOTARGS									1
#define	PORTCREATED							2
#define	SHELLOPEN								4

#define	MYRC_ERROR							-10
#define	MYRC_UNKNOWN						-20

#define	INTERNAL_COMMANDS				1
#define	INTERNAL_COMMAND_GET		-1000

#define LIBVER									37L

#define	NOT_AVAILABLE						"N/A"

#define	SETTAG(array,tag,data)	array.ti_Tag=tag;array.ti_Data=data 

/*** GLOBALS *************************************************************************/
struct Library				*RexxSysBase=NULL,
											*UtilityBase=NULL,
											*DOSBase=NULL;
struct IntuitionBase	*IntuitionBase;
struct GfxBase				*GfxBase=NULL;	// needed for SetFont()

/*** PROTOTYPES **********************************************************************/
__asm __saveds LONG SendARexxCommandA(register __a1 UBYTE						*command,
																			register __a0 struct TagItem	*taglist);

/*** PRIVATE INCLUDES ****************************************************************/
#include "EasyRexx_rev.h"
#include <libraries/EasyRexx.h>

//#define USEFAILREQUEST
#ifdef USEFAILREQUEST
LONG FailRequest(UBYTE *format, APTR arg1, ...);
#endif


#include "myinclude:myString.h"
#include "myinclude:BitMacros.h"
#include "CommandShell.h"
#include "ARexxMacro.h"

/*** FUNCTIONS ***********************************************************************/
void __saveds __UserLibCleanup(void)
{
	if(GfxBase)
		CloseLibrary((struct Library *)GfxBase);
	if(DOSBase)
		CloseLibrary(DOSBase);
	if(UtilityBase)
		CloseLibrary(UtilityBase);
	if(RexxSysBase)
		CloseLibrary(RexxSysBase);
	if(IntuitionBase)
		CloseLibrary((struct Library *)IntuitionBase);
}

int __saveds __UserLibInit(void)
{
	if(IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library", LIBVER))
		if(RexxSysBase=OpenLibrary(RXSNAME, 0L))
			if(UtilityBase=OpenLibrary("utility.library", LIBVER))
				if(DOSBase=OpenLibrary("dos.library", LIBVER))
					if(GfxBase=(struct GfxBase *)OpenLibrary("graphics.library", LIBVER))
						return 0;
	__UserLibCleanup();
	return 1;
}

/* ********************************************************************************* */

#ifdef USEFAILREQUEST
LONG FailRequestA(UBYTE *format, APTR *args)
{
	struct EasyStruct myES;

	myES.es_StructSize		=sizeof(struct EasyStruct);
	myES.es_Title					=NAME " " VERS;
	myES.es_TextFormat		=format;
	myES.es_GadgetFormat	="OK";

	return EasyRequestArgs(NULL, &myES, NULL, args);
}

LONG FailRequest(UBYTE *format, APTR arg1, ...)
{
	return FailRequestA(format, &arg1);
}
#endif

__asm __saveds void FreeARexxContext(register __a0 struct ARexxContext *context)
{
	register ULONG i=0;
#ifdef MYDEBUG_H
	DebugOut("FreeArexxContext");
#endif

	if(context)
	{
		register struct RexxMsg *msg;

		if(ISBITSET(context->flags, PORTCREATED))
		{
			Forbid();
			while(msg=(struct RexxMsg *)GetMsg(context->port))
			{
				msg->rm_Result1=RC_FATAL;
				msg->rm_Result2=NULL;
				ReplyMsg((struct Message *)msg);
			}
			RemPort(context->port);
			Permit();
			DeleteMsgPort(context->port);
			Free(context->portname);
		}
		Forbid();
		while(msg=(struct RexxMsg *)GetMsg(context->asynchport))
		{
			ClearRexxMsg(msg, 1);
			DeleteRexxMsg(msg);
		}
		Permit();
		DeleteMsgPort(context->asynchport);
/*
		Free(context->author);
		Free(context->copyright);
		Free(context->version);
*/
		Free(context->lasterror);
/*
		while(context->reservedcommands[i].command)
		{
			Free(context->reservedcommands[i].command);
			Free(context->reservedcommands[i].cmdtemplate);
			++i;
		}
*/
		FreeVec(context->argv);
		FreeVec(context->reservedcommands);

		if(context->shell && context->shell->commandWindow)
		{
			struct TagItem taglist[]={ER_Close,	TRUE,
																TAG_DONE};
			ARexxCommandShellA(context, taglist);
		}

		if(context->rdargs)
			FreeDosObject(DOS_RDARGS, context->rdargs);
		FreeVec(context);
	}
}

__asm __saveds struct ARexxContext *AllocARexxContextA(register __a0 struct TagItem	*taglist)
{
	struct ARexxContext	*context;
	UBYTE defportname[]="EASYREXX", *portname=defportname, createport=TRUE,
				*author=NULL, *copyright=NULL, *version=NULL;
	register ULONG i=0L, maxargs=4L;
	struct TagItem	*tstate=taglist;
	register struct TagItem	*tag;
	struct ARexxCommandTable *table, *t=NULL;
	struct MsgPort	*port=NULL;

#ifdef MYDEBUG_H
	DebugOut("AllocARexxContext");
#endif

	while(tag=NextTagItem(&tstate))
		switch(tag->ti_Tag)
		{
			case ER_Portname:
				portname=(UBYTE *)tag->ti_Data;
				createport=TRUE;
				break;
			case ER_CommandTable:
				t=table=(struct ARexxCommandTable *)tag->ti_Data;
				break;
			case ER_Author:
				author=(UBYTE *)tag->ti_Data;
				break;
			case ER_Copyright:
				copyright=(UBYTE *)tag->ti_Data;
				break;
			case ER_Version:
				version=(UBYTE *)tag->ti_Data;
				break;
			case ER_Port:
				port=(struct MsgPort *)tag->ti_Data;
				createport=FALSE;
				break;
		}

	/* count maxargs */
	if(t)
	{
		while(t[i].command)
		{
			register UBYTE count=0;

			if(t[i].cmdtemplate)
			{
				register UBYTE *c=t[i].cmdtemplate;

				while(*c!='\0')
				{
					if(*c==',')
						++count;
					++c;
				}
			}
			++i;
			maxargs=MAX(maxargs, count);
		}
		maxargs=maxargs/4*4+4;
	}

	if(context=AllocVec(sizeof(struct ARexxContext), MEMF_PUBLIC|MEMF_CLEAR))
	{
		if(context->argv=(LONG *)AllocVec(sizeof(LONG)*(maxargs), MEMF_PUBLIC|MEMF_CLEAR))
		{
			if(createport)
			{
				register UBYTE destname[256];

				StrCpy(destname, portname);
				i=0;
				while(TRUE)
				{
					if(FindPort(destname))
						sprintf(destname, "%s.%ld", portname, ++i);
					else
						break;
				}
				context->portname=StrDup(destname);
				if(context->port=CreateMsgPort())
				{
					context->port->mp_Node.ln_Name=context->portname;
					context->port->mp_Node.ln_Pri	=1;
					AddPort(context->port);
					SETBIT(context->flags, PORTCREATED);
				}
			}
			else
				context->port=port;
			context->table=table;
			context->maxargs=maxargs;
			context->rdargs=AllocDosObject(DOS_RDARGS, NULL);

			context->asynchport=CreateMsgPort();

			if(author==NULL)
//				context->author		=StrDup(NOT_AVAILABLE);
				context->author		=NOT_AVAILABLE;
			else
//				context->author		=StrDup(author);
				context->author		=author;

			if(copyright==NULL)
//				context->copyright=StrDup(NOT_AVAILABLE);
				context->copyright=NOT_AVAILABLE;
			else
//				context->copyright=StrDup(copyright);
				context->copyright=copyright;

			if(version==NULL)
//				context->version	=StrDup(NOT_AVAILABLE);
				context->version	=NOT_AVAILABLE;
			else
//				context->version	=StrDup(version);
				context->version	=version;

			if(context->reservedcommands=(struct ARexxCommandTable *)
					AllocVec(sizeof(struct ARexxCommandTable)*(INTERNAL_COMMANDS+1), MEMF_CLEAR|MEMF_PUBLIC))
			{
				context->reservedcommands[0].id						=INTERNAL_COMMAND_GET;
//				context->reservedcommands[0].command			=StrDup("GET");
				context->reservedcommands[0].command			="GET";
//				context->reservedcommands[0].cmdtemplate	=StrDup("COMMANDLIST/S,AUTHOR/S,COPYRIGHT/S,VERSION/S,LASTERROR/S");
				context->reservedcommands[0].cmdtemplate	="COMMANDLIST/S,AUTHOR/S,COPYRIGHT/S,VERSION/S,LASTERROR/S";
			}
		}
		if(	context->port				&&
				context->argv				&&
				context->rdargs			&&
				context->asynchport &&
				context->reservedcommands)
			;
		else
		{
			FreeARexxContext(context);
			context=NULL;
		}
	}
	return context;
}

__asm LONG MatchCommand(register __a0 struct ARexxContext	*context,
												register __a1 STRPTR							command)
{
	register ULONG i=0;

#ifdef MYDEBUG_H
	DebugOut("MatchCommand");
#endif

	while(context->reservedcommands[i].id)
	{
		if(Stricmp(context->reservedcommands[i].command, command)==0)
			return context->reservedcommands[i].id;
		else
			++i;
	}
	i=0;

	while(context->table[i].id)
	{
		if(Stricmp(context->table[i].command, command)==0)
			return context->table[i].id;
		else
			++i;
	}
	return MYRC_UNKNOWN;
}

__asm void GetCommand(register __a0 UBYTE *command,
											register __a1 UBYTE *string)
{
	register UBYTE *s=string, *c=command;

#ifdef MYDEBUG_H
	DebugOut("GetCommand");
#endif

	while(*s!='\0' && *s!=' ' && *s!='\n')
		*c++=*s++;
	*c='\0';
}

__asm UBYTE *GetTemplate(	register __a0 struct ARexxCommandTable	*table,
													register __d0 LONG id)
{
	register ULONG i=0;

	while(table[i].command)
	{
		if(table[i].id==id)
			return table[i].cmdtemplate;
		else
			++i;
	}
	return NULL;
}

__asm LONG GetArgs(	register __a0 struct ARexxContext *context,
										register __d0 ULONG comlen,
										register __a1 UBYTE *cmdtemplate)
{
	LONG retvalue=MYRC_ERROR;

#ifdef MYDEBUG_H
	DebugOut("HandleArgs");
#endif

	if(cmdtemplate)
	{
		register ULONG i;

		memset(context->rdargs, NULL, sizeof(struct RDArgs));
		for(i=0; i<context->maxargs; i++)
			context->argv[i]=0L;
		context->rdargs->RDA_Source.CS_Buffer	=context->argcopy+comlen;
		context->rdargs->RDA_Source.CS_Length	=(LONG)StrLen(context->argcopy+comlen);

		if(NULL!=ReadArgs(cmdtemplate, context->argv, context->rdargs))
		{
			SETBIT(context->flags, GOTARGS);
			retvalue=RC_OK;
		}
	}
	else
		retvalue=RC_OK;

	return retvalue;
}

__asm __saveds void ReplyARexxMsgA(	register __a1 struct ARexxContext *context,
																		register __a0 struct TagItem			*taglist)
{
	struct TagItem	*tstate=taglist;
	register struct TagItem	*tag;
	BYTE returned=FALSE;

	context->msg->rm_Result1=context->msg->rm_Result2=NULL;

	while(tag=NextTagItem(&tstate))
		switch(tag->ti_Tag)
		{
			case ER_ReturnCode:
				context->msg->rm_Result1=(LONG)tag->ti_Data;
				if(tag->ti_Data!=RC_OK)
					returned=TRUE;
				break;
			case ER_Result2:
				if(!returned)
				{
					if(context->msg->rm_Action & RXFF_RESULT)
						context->msg->rm_Result2=(LONG)tag->ti_Data;
					returned=TRUE;
				}
				break;
			case ER_ResultString:
				if(!returned)
				{
					if(	tag->ti_Data														&&
							(context->msg->rm_Action & RXFF_RESULT) &&
							!(context->msg->rm_Result2=(LONG)CreateArgstring((UBYTE *)tag->ti_Data,
																							StrLen((UBYTE *)tag->ti_Data))))
		 				context->msg->rm_Result1=RC_ERROR;
					returned=TRUE;
				}
				break;
			case ER_ResultLong:
				if(!returned)
				{
					UBYTE string[65];

					sprintf(string, "%ld", tag->ti_Data);
	 				if((context->msg->rm_Action & RXFF_RESULT) &&
						!(context->msg->rm_Result2=(LONG)CreateArgstring(string, StrLen(string))))
			 			context->msg->rm_Result1=RC_ERROR;
			 		returned=TRUE;
				}
				break;
			case ER_ErrorMessage:
				if(tag->ti_Data)
				{
					Free(context->lasterror);
					context->lasterror=StrDup((UBYTE *)tag->ti_Data);
			 		returned=TRUE;
				}
				break;
		}
	if(context->msg->rm_Result1!=RC_OK && context->msg->rm_Result2)
	{
		DeleteArgstring((UBYTE *)context->msg->rm_Result2);
		context->msg->rm_Result2=NULL;
	}
	ReplyMsg((struct Message *)context->msg);
	Free(context->argcopy);

	if(ISBITSET(context->flags, GOTARGS))
		FreeArgs(context->rdargs);
	CLEARBIT(context->flags, GOTARGS);
}

__asm __saveds BYTE GetARexxMsg(register __a0 struct ARexxContext *context)
{
	BYTE success=FALSE;

#ifdef MYDEBUG_H
	DebugOut("HandleARexxContext");
#endif

	if(context)
	{
		struct RexxMsg *msg;

		while(msg=(struct RexxMsg *)GetMsg(context->asynchport))
		{
			--context->Queue;
			context->Result1=msg->rm_Result1;
			context->Result2=msg->rm_Result2;
			ClearRexxMsg(msg, 16);
			DeleteRexxMsg(msg);

			if(context->shell &&
				(context->Result1!=RC_OK | context->Result2!=0L))
			{
				register UBYTE	error[40],
												buffer[]={0x0D,'\0','\0'};

				sprintf(error, "*** Command returned %ld/%ld", context->Result1, context->Result2);
				ConPuts(context->shell->writeReq, buffer);
				buffer[0]=0x9B;
				buffer[1]=0x4B;
				ConPuts(context->shell->writeReq, buffer);
				buffer[0]=0x85;
				buffer[1]=0;
				ConPuts(context->shell->writeReq, error);
				ConPuts(context->shell->writeReq, buffer);
				ConPuts(context->shell->writeReq, context->shell->prompt);
				ConPuts(context->shell->writeReq, context->shell->buffer);
			}
		}

		if(	(msg=(struct RexxMsg *)GetMsg(context->port)) &&
				(msg->rm_Action & RXCODEMASK)==RXCOMM)
		{
			UBYTE command[80];

			context->msg=msg;
			context->msg->rm_Result1=RC_OK;
			context->msg->rm_Result2=0L;

			if(context->argcopy=AllocVec(StrLen(context->msg->rm_Args[0])+3, MEMF_CLEAR))
			{
				struct TagItem taglist[]={ER_ReturnCode,		0L,
																	ER_ResultString,	NULL,
																	TAG_DONE};
				sprintf(context->argcopy, "%s\n", context->msg->rm_Args[0]);
//				StrCpy(context->argcopy, context->msg->rm_Args[0]);
				GetCommand(command, context->argcopy);
//				StrCat(context->argcopy, "\n");

				if((context->id=MatchCommand(context, command))<0)
				{
					register BYTE reply=TRUE;

					if(0>(context->msg->rm_Result1=GetArgs(	context,
																								StrLen(command),
																								GetTemplate(context->reservedcommands, context->id))))
						taglist[0].ti_Data=ABS(context->msg->rm_Result1);
					else
						switch(context->id)
						{
							case INTERNAL_COMMAND_GET:
								taglist[0].ti_Data=RC_OK;
								if(ARG(context, 1))
									taglist[1].ti_Data=(ULONG)(context->author);
								else if(ARG(context, 2))
									taglist[1].ti_Data=(ULONG)(context->copyright);
								else if(ARG(context, 3))
									taglist[1].ti_Data=(ULONG)(context->version);
								else if(ARG(context, 4))
									taglist[1].ti_Data=(ULONG)(context->lasterror);
								else
								{
									UBYTE *commandlist;
									register ULONG i=0, len=0;

									while(context->reservedcommands[i].id)
										len+=StrLen(context->reservedcommands[i].command)
												+StrLen(context->reservedcommands[i++].cmdtemplate)
												+2;
									i=0;
									while(context->table[i].id)
										len+=StrLen(context->table[i].command)
												+StrLen(context->table[i++].cmdtemplate)
												+2;

									if(commandlist=(UBYTE *)AllocVec(len+1, MEMF_CLEAR))
									{
										register ULONG pos=0;

										i=0;
										while(context->reservedcommands[i].id)
										{
											sprintf(commandlist+pos, "%s %s\n",
															context->reservedcommands[i].command,
															context->reservedcommands[i].cmdtemplate);
											pos+=StrLen(context->reservedcommands[i].command)
													+StrLen(context->reservedcommands[i++].cmdtemplate)
													+2;
										}
										i=0;
										while(context->table[i].id)
										{
											sprintf(commandlist+pos, "%s %s\n",
															context->table[i].command,
															context->table[i].cmdtemplate);
											pos+=StrLen(context->table[i].command)
													+StrLen(context->table[i++].cmdtemplate)
													+2;
										}

										*(commandlist+pos-1)='\0';
										taglist[1].ti_Data=(ULONG) commandlist;
										ReplyARexxMsgA(context, taglist);
										FreeVec(commandlist);
										reply=FALSE;
									}
								}
								break;
							default:
								taglist[0].ti_Data=ABS(context->id);
								break;
						}
					if(reply)
						ReplyARexxMsgA(context, taglist);
				}
				else
				{
					if(context->msg->rm_Result1=GetArgs(context,
																							StrLen(command),
																							GetTemplate(context->table, context->id)))
					{
						taglist[0].ti_Data=ABS(context->msg->rm_Result1);
						ReplyARexxMsgA(context, taglist);
					}
					else						
						success=TRUE;
				}
			}
		}

		if(	context->shell &&
				((context->signals & 1L<<context->shell->readPort->mp_SigBit) |
				(context->signals & 1L<<context->shell->commandWindow->UserPort->mp_SigBit)))
			HandleCommandShell(context);
	}
	return success;
}

__asm __saveds LONG SendARexxCommandA(register __a1 UBYTE						*command,
																			register __a0 struct TagItem	*taglist)
{
	struct TagItem					*tstate				=taglist;
	register struct TagItem	*tag;
	struct MsgPort					*replyport,
													*toport				=NULL;
	struct RexxMsg					*rxmsg;
	LONG										success				=RC_FATAL,
													flags					=0L;
	UBYTE										defportname[]	="REXX",
													*portname			=defportname,
													doit					=TRUE,
													asynch				=FALSE;
	struct ARexxContext			*context			=NULL;

#ifdef MYDEBUG_H
	DebugOut("SendARexxCommandA");
#endif

	while(tag=NextTagItem(&tstate))
		switch(tag->ti_Tag)
		{
			case ER_Portname:
				portname=(UBYTE *)tag->ti_Data;
				break;
			case ER_Port:
				toport=(struct MsgPort *)tag->ti_Data;
				break;
			case ER_Asynch:
				asynch=(BYTE)tag->ti_Data;
				break;
			case ER_Context:
				context=(struct ARexxContext *)tag->ti_Data;
				break;
			case ER_Flags:
				flags=tag->ti_Data;
				break;
			case ER_String:
				SETBIT(flags, RXFF_STRING);
				break;
			case ER_File:
				CLEARBIT(flags, RXFF_STRING);
				break;
		}
	if(context && toport==context->port | 0==Stricmp(context->portname, portname))
		asynch=TRUE;

	if(asynch && context)
		replyport=context->asynchport;
	else if(NULL==(replyport=CreateMsgPort()))
		doit=FALSE;

	if(doit && toport==FindPort(defportname) && ISBITCLEARED(flags, RXFF_STRING))
		doit=Exists(command);

	if(doit && (rxmsg=CreateRexxMsg(replyport, NULL, NULL)))
	{
		if(rxmsg->rm_Args[0]=CreateArgstring(command, StrLen(command)))
		{
			rxmsg->rm_Action=RXCOMM|flags;

			if(toport)
				PutMsg(toport, (struct Message *)rxmsg);
			else
			{
				Forbid();
				if(toport=FindPort(portname))
					PutMsg(toport, (struct Message *)rxmsg);
				Permit();
			}

			if(asynch==FALSE && toport)
			{
				WaitPort(replyport);
				GetMsg(replyport);
				success=rxmsg->rm_Result1;
				if(context)
				{
					context->Result1=rxmsg->rm_Result1;
					context->Result2=rxmsg->rm_Result2;
				}
			}
			else
			{
				++context->Queue;
				success=RC_OK;
			}
			if(asynch==FALSE)
				ClearRexxMsg(rxmsg, 16);
		}
		if(asynch==FALSE)
			DeleteRexxMsg(rxmsg);
	}
	if(!asynch && replyport)
		DeleteMsgPort(replyport);

	return success;
}

__asm UBYTE *Upper(register __a0 UBYTE *string)
{
	register UBYTE *c=string;

	while(*c!='\0')
		*c++=ToUpper(*string++);
	return string;
}

__asm __saveds BYTE CreateARexxStemA(	register __a1 struct ARexxContext *context,
																			register __a2 UBYTE *stemname,
																			register __a0 UBYTE **vars)
											
{
	register BYTE		success=FALSE;
	register ULONG	i=0;
	register UBYTE	stem[256];

	if(context)
		while(vars[i])
		{
			sprintf(stem, "%s.%s", stemname, vars[i++]);
			SetRexxVar(context->msg, Upper(stem), vars[i], strlen(vars[i++]));
			success=TRUE;
		}

	return success;
}

#endif
