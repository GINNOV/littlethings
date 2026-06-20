/*
 *	File:					CommandShell.h
 *	Description:	Open and handle AREXX commando shell input.  Based on
 *								example source from Commodore Amiga, Inc.
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef AREXX_COMMANDSHELL_H
#define AREXX_COMMANDSHELL_H

/*** PRIVATE INCLUDES ****************************************************************/
#include <intuition/intuition.h>
#include <devices/console.h>
#include <exec/io.h>
#include <devices/conunit.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

/*** DEFINES *************************************************************************/
#define RESETCON  "\033c"
#define CURSOFF   "\033[0 p"
#define CURSON    "\033[ p"
#define DELCHAR   "\033[P"

#define COLOR02   "\033[32m"
#define COLOR03   "\033[33m"
#define ITALICS   "\033[3m"
#define BOLD      "\033[1m"
#define UNDERLINE "\033[4m"
#define NORMAL    "\033[0m"

#define	DEFPROMPT	"EasyRexx> "

/*** FUNCTIONS ***********************************************************************/

__asm BYTE OpenConsole(	register __a0 struct ARexxContext	*context,
												register __a1 struct IOStdReq		*writereq,
												register __a2 struct IOStdReq		*readreq,
												register __a3 struct Window				*window)
{
	register BYTE error;

	writereq->io_Data		=(APTR)window;
	writereq->io_Length	=sizeof(struct Window);
	error=OpenDevice("console.device", 0, writereq, 0);
//CONFLAG_NODRAW_ON_NEWSIZE);
//CONU_SNIPMAP
	readreq->io_Device	=writereq->io_Device; /* clone required parts */
	readreq->io_Unit		=writereq->io_Unit;
	return (BYTE)(error==0);
}

__asm void ConPuts(	register __a0 struct IOStdReq *writereq,
										register __a1 UBYTE *string)
{
	writereq->io_Command=CMD_WRITE;
	writereq->io_Data		=(APTR)string;
	writereq->io_Length	=-1;
	DoIO(writereq);
}

__asm void QueueRead(	register __a0 struct IOStdReq *readreq,
											register __a1 UBYTE *whereto)
{
	readreq->io_Command	=CMD_READ;
	readreq->io_Data		=(APTR)whereto;
	readreq->io_Length	=1;
	SendIO(readreq);
}

__asm LONG ConMayGetChar(	register __a0 struct MsgPort *msgport,
													register __a1 UBYTE *whereto)
{
	register int temp;
	struct IOStdReq *readreq;

	if(!(readreq=(struct IOStdReq *)GetMsg(msgport)))
		return -1;
	temp=*whereto;								/* get the character */
	QueueRead(readreq, whereto);	/* then re-use the request block */
	return temp;
}

__asm void freeport(register __a0 struct MsgPort *port)
{
	register struct Message *msg;

	while(msg=GetMsg(port))
		ReplyMsg(msg);
	DeleteMsgPort(port);
}

__asm void commandshellcleanup(	register __a0 struct ARexxContext *context)
{
	register struct ARexxCommandShell	*shell=context->shell;

	if(shell)
	{
		if(!(CheckIO(shell->readReq)))
			AbortIO(shell->readReq);
		WaitIO(shell->readReq);
		CloseDevice(shell->writeReq);

		if(shell->commandWindow)
			CloseWindow(shell->commandWindow);
		if(shell->readReq)
			DeleteIORequest(shell->readReq);
		if(shell->readPort)
			freeport(shell->readPort);
		if(shell->writeReq)
			DeleteIORequest(shell->writeReq);
		if(shell->writePort)
			freeport(shell->writePort);

		Free(shell->prompt);
		FreeVec(context->shell);
		context->shell=NULL;
	}
}

__asm __saveds BYTE ARexxCommandShellA(	register __a1 struct ARexxContext *context,
																				register __a0 struct TagItem *taglist)
{
	struct TagItem	*tstate=taglist;
	register struct TagItem	*tag;
	register BYTE done=FALSE, error=FALSE, changeprompt=FALSE;
	struct TextFont *font=NULL;
	UBYTE *prompt;

	while(tag=NextTagItem(&tstate))
		switch(tag->ti_Tag)
		{
			case ER_Prompt:
				changeprompt=TRUE;
				prompt=(UBYTE *)tag->ti_Data;
				break;
			case ER_Close:
				if(tag->ti_Data)
				{
					commandshellcleanup(context);
					done=TRUE;
				}
				break;
			case ER_Font:
				if(tag->ti_Data)
					font=(struct TextFont *)tag->ti_Data;
				break;
		}

	if(!done)
	{
		if(context->shell)
			ActivateWindow(context->shell->commandWindow);
		else
		{
			if(context->shell=(struct ARexxCommandShell *)
								AllocVec(sizeof(struct ARexxCommandShell), MEMF_CLEAR|MEMF_PUBLIC))
			{
				register struct ARexxCommandShell	*shell=context->shell;

				if(changeprompt)
				{
					Free(shell->prompt);
					shell->prompt=StrDup(prompt);
				}

				if(shell->prompt==NULL)
					shell->prompt=StrDup(DEFPROMPT);

				if(shell->writePort=CreateMsgPort())
		    {
			    if(shell->writeReq=(struct IOStdReq *)CreateIORequest(shell->writePort, sizeof(struct IOStdReq)))
			    {
						if(shell->readPort=CreateMsgPort())
				    {
					    if(shell->readReq=(struct IOStdReq *)CreateIORequest(shell->readPort, sizeof(struct IOStdReq)))
					    {
								if(shell->commandWindow=OpenWindowTags( NULL,
											WA_IDCMP,							IDCMP_CLOSEWINDOW|IDCMP_NEWSIZE,
											WA_Flags,							WFLG_ACTIVATE|WFLG_RMBTRAP,
											TAG_MORE,							taglist,
											TAG_DONE))
								{
									if(font)
										SetFont(shell->commandWindow->RPort, font);
							    if(OpenConsole(	context,
																	shell->writeReq,
																	shell->readReq,
																	shell->commandWindow))
							    {
										ConPuts(shell->writeReq, shell->prompt);
								    QueueRead(shell->readReq, &shell->ibuf);
									}
									else
										error=TRUE;
								}
								else
									error=TRUE;
							}
							else
								error=TRUE;
						}
						else
							error=TRUE;
					}
					else
						error=TRUE;

				if(error)
					commandshellcleanup(context);
				}
			}
		}
	}
	return (BYTE)(error==FALSE);
}

__asm void InsertInBuffer(register __a0 UBYTE *buffer,
													register __d0 UBYTE c,
													register __d1 ULONG pos)
{
	register ULONG len=StrLen(buffer), i;

	switch(c)
	{
		case 127:	// DEL
			for(i=pos; i<len; i++)
				buffer[i]=buffer[i+1];
			buffer[i]='\0';
			break;
		case 8:		// backspace
			for(i=pos-1; i<len; i++)
				buffer[i]=buffer[i+1];
			buffer[i]='\0';
			break;
		default:
			buffer[len+1]='\0';
			for(i=len; i>pos; i--)
				buffer[i]=buffer[i-1];
			buffer[pos]=c;
			break;
		}
}

__asm void shiftleft(register __a0 struct ARexxCommandShell *shell)
{
	ConPuts(shell->writeReq, CURSOFF);
	while(shell->cursor--)
		ConPuts(shell->writeReq, "\b");
	ConPuts(shell->writeReq, CURSON);
	shell->cursor=0;
}

__asm void shiftright(register __a0 struct ARexxCommandShell *shell)
{
	register UBYTE buffer[]={0x9B,0x43,'\0'}, len=StrLen(shell->buffer);

	ConPuts(shell->writeReq, CURSOFF);
	while(shell->cursor++<len)
		ConPuts(shell->writeReq, buffer);
	ConPuts(shell->writeReq, CURSON);
	shell->cursor=len;
}

__asm void HandleCommandShell(register __a0 struct ARexxContext *context)
{
	register struct ARexxCommandShell	*shell=context->shell;

	if(context->signals & 1L<<shell->readPort->mp_SigBit)
	{
		LONG c;

		if(-1!=(c=ConMayGetChar(shell->readPort, &shell->ibuf)))
		{
			UBYTE buffer[4]={'\0','\0', '\0', '\0'};

			if(((c>31 && c<127) | (c>159 && c<256)) &
					shell->inbuffer!=155 && shell->inbuffer!=32 && shell->cursor<255)
			{
				buffer[0]=0x9B;
				buffer[1]=0x40;
				buffer[2]=c;
				ConPuts(shell->writeReq, buffer);
				InsertInBuffer(shell->buffer, c, shell->cursor++);
			}
			else
			{
				switch(c)
				{
					case 127:	// DEL
						ConPuts(shell->writeReq, DELCHAR);
						InsertInBuffer(shell->buffer, c, shell->cursor);
						break;
					case 8:		// Backspace
						if(shell->cursor)
						{
							if(shell->inbuffer==32)
							{
								register BYTE i, j=0, len=StrLen(shell->buffer);

								for(i=shell->cursor; i<len; i++)
									shell->buffer[j++]=shell->buffer[i];
								shiftleft(shell);
							}
							else
							{
								ConPuts(shell->writeReq, "\b");
								ConPuts(shell->writeReq, DELCHAR);
								InsertInBuffer(shell->buffer, c, shell->cursor--);
							}
						}
						break;
					case 'A':	// shift <-
						shiftleft(shell);
						break;
					case '@':	// shift ->
						shiftright(shell);
						break;
					case 68:	// left arrow
						if(shell->inbuffer==155 && shell->cursor>0)
						{
							ConPuts(shell->writeReq, "\b");
							--shell->cursor;
						}
						break;
					case 67:	// right arrow
						if(shell->inbuffer==155 && shell->cursor<StrLen(shell->buffer))
						{
							buffer[0]=0x9B;
							buffer[1]=0x43;
							ConPuts(shell->writeReq, buffer);
							++shell->cursor;
						}
						break;
					case 13:	// return
						buffer[0]=0x85;
						ConPuts(shell->writeReq, buffer);
						ConPuts(shell->writeReq, shell->prompt);
						if(StrLen(shell->buffer))
						{
							register UBYTE *sendstring;

#define	SHELLHEADER	"/**/ADDRESS '%s' %s"

							if(sendstring=(UBYTE *)AllocVec(StrLen(shell->buffer)+
																							StrLen(context->portname)+
																							StrLen(SHELLHEADER), MEMF_CLEAR))
							{
								struct TagItem taglist[4];

								SETTAG(taglist[0], ER_Context,	(ULONG)context);
								SETTAG(taglist[1], ER_Flags,		(ULONG)RXFF_STRING);
								SETTAG(taglist[2], ER_Asynch,		(ULONG)TRUE);
								SETTAG(taglist[3], TAG_DONE,		TAG_DONE);
								sprintf(sendstring, SHELLHEADER, context->portname, shell->buffer);
								SendARexxCommandA(sendstring, taglist);
								FreeVec(sendstring);
							}
						}
						shell->buffer[0]='\0';
						shell->cursor=0;
						break;
					case 3:	// ctrl-c
						commandshellcleanup(context);
						break;
				}
				if(shell)
					shell->inbuffer=c;
			}
		}
	}
	else if(context->signals & 1L<<shell->commandWindow->UserPort->mp_SigBit)
	{
		register struct IntuiMessage *imsg;

		while(imsg=(struct IntuiMessage *)GetMsg(shell->commandWindow->UserPort))
		{
			switch(imsg->Class)
			{
				case IDCMP_CLOSEWINDOW:
					ReplyMsg((struct Message *)imsg);
					commandshellcleanup(context);
					return;
					break;
				case IDCMP_NEWSIZE:
					ConPuts(shell->writeReq, RESETCON);
					ConPuts(shell->writeReq, shell->prompt);
					ConPuts(shell->writeReq, shell->buffer);
					shell->cursor=StrLen(shell->buffer);
					break;
			}
			ReplyMsg((struct Message *)imsg);
		}
	}
}

#endif
