/*********************************************************************/
/*                                                                   */
/*  Program name:  cbio                                              */
/*                                                                   */
/*  Purpose:  To provide standard clipboard device interface routines*/
/*            such as Open, Post, Read, Write, etc.                  */
/*  (C) 1986 Commodore-Amiga, Inc.                                   */
/* Permission given to use and distribute this code as long as this  */
/* notice remains intact.                                            */
/*********************************************************************/
#include "exec/types.h"
#include "exec/ports.h"
#include "exec/io.h"
#include "devices/clipboard.h"


struct IOClipReq clipboardIO = 0;
struct MsgPort clipboardMsgPort = 0;
struct MsgPort satisfyMsgPort = 0;

int CBOpen(unit)
int unit;
{
    int error;

    /* open the clipboard device */
    if ((error = OpenDevice("clipboard.device", unit, &clipboardIO, 0)) != 0)
        return(error);

    /* Set up the message port in the I/O request */
    clipboardMsgPort.mp_Node.ln_Type = NT_MSGPORT;
    clipboardMsgPort.mp_Flags = 0;
    clipboardMsgPort.mp_SigBit = AllocSignal(-1);
    clipboardMsgPort.mp_SigTask = (struct Task *) FindTask((char *) NULL);
    AddPort(&clipboardMsgPort);
    clipboardIO.io_Message.mn_ReplyPort = &clipboardMsgPort;

    satisfyMsgPort.mp_Node.ln_Type = NT_MSGPORT;
    satisfyMsgPort.mp_Flags = 0;
    satisfyMsgPort.mp_SigBit = AllocSignal(-1);
    satisfyMsgPort.mp_SigTask = (struct Task *) FindTask((char *) NULL);
    AddPort(&satisfyMsgPort);
    return(0);
}

CBClose()
{
    RemPort(&satisfyMsgPort);
    RemPort(&clipboardMsgPort);
    CloseDevice(&clipboardIO);
}

CBSatisfyPost(string,length)
char *string;
int length;
{
    clipboardIO.io_Offset = 0;
    writeLong("FORM");
    length += 12;
    writeLong(&length);
    writeLong("FTXT");
    writeLong("CHRS");
    length -= 12;
    writeLong(&length);

    clipboardIO.io_Command = CMD_WRITE;
    clipboardIO.io_Data = string;
    clipboardIO.io_Length = length;
    DoIO(&clipboardIO);

    clipboardIO.io_Command = CMD_UPDATE;
    return(DoIO(&clipboardIO));
}

writeLong(ldata)
LONG *ldata;
{

int status;
    clipboardIO.io_Command = CMD_WRITE;
    clipboardIO.io_Data = ldata;
    clipboardIO.io_Length = 4;
    status=(DoIO(&clipboardIO));
}

CBCutS(string,length)
char *string;
int length;
{
    clipboardIO.io_ClipID = 0;
    return(CBSatisfyPost(string,length));
}

int
CBPasteS(string)
char *string;
{
    int length=0,status=0;

    clipboardIO.io_Command = CMD_READ; /* get the FORM */
    clipboardIO.io_Data = string;
    clipboardIO.io_Length = 4;
    clipboardIO.io_Offset = 0;
    clipboardIO.io_ClipID = 0;
    status -= DoIO(&clipboardIO);
    string[4]='\0';

    if(!strcmp(string,"FORM")) { /* iff form */
        clipboardIO.io_Command = CMD_READ; /* get the total length */
        clipboardIO.io_Data = &length;
        clipboardIO.io_Length = 4;
        status -=DoIO(&clipboardIO);

        clipboardIO.io_Command = CMD_READ; /* read the chunk and body */
        clipboardIO.io_Data = string;
        clipboardIO.io_Length = 8;
        status -=DoIO(&clipboardIO);
        string[8]='\0';

        if(!strcmp(string,"FTXTCHRS")) {
        clipboardIO.io_Command = CMD_READ; /* get the length of the data */
        clipboardIO.io_Data = &length;
        clipboardIO.io_Length = 4;
        status -=DoIO(&clipboardIO);

        clipboardIO.io_Command = CMD_READ;
        clipboardIO.io_Data = string;
        clipboardIO.io_Length = length;
        status -=DoIO(&clipboardIO);
        }
    }
    /* force end of file to terminate read */
        clipboardIO.io_Command = CMD_READ;
        clipboardIO.io_Length = 1;
        clipboardIO.io_Data = 0;
        status -= DoIO(&clipboardIO);

        if(!status)return(length);
        else return(-1);
}

int
CBCurrentReadID()
{
    clipboardIO.io_Command = CBD_CURRENTREADID;
    DoIO(&clipboardIO);
    return(clipboardIO.io_ClipID);
}

int
CBCurrentWriteID()
{
    clipboardIO.io_Command = CBD_CURRENTWRITEID;
    DoIO(&clipboardIO);
    return(clipboardIO.io_ClipID);
}

BOOL
CBCheckSatisfy(idVar)
int *idVar;
{
    struct SatisfyMsg *sm;

    if (*idVar == 0)
        return(TRUE);
    if (*idVar < CBCurrentWriteID()) {
        *idVar = 0;
        return(TRUE);
    }
    if (sm = (struct SatisfyMsg *) GetMsg(&satisfyMsgPort)) {
        if (*idVar == sm->sm_ClipID)
            return(TRUE);
    }
    return(FALSE);
}

CBCut(stream, length)
char *stream;
int length;
{
    clipboardIO.io_Command = CMD_WRITE;
    clipboardIO.io_Data = stream;
    clipboardIO.io_Length = length;
    clipboardIO.io_Offset = 0;
    clipboardIO.io_ClipID = 0;
    DoIO(&clipboardIO);
    clipboardIO.io_Command = CMD_UPDATE;
    DoIO(&clipboardIO);
}

int
CBPost()
{
    clipboardIO.io_Command = CBD_POST;
    clipboardIO.io_Data = &satisfyMsgPort;
    clipboardIO.io_ClipID = 0;
    DoIO(&clipboardIO);
    return(clipboardIO.io_ClipID);
}
