
/*********************************************************************
*
*	CLIPBOARD support functions.
*	====================================================
*	$VER: 1.0 - D. Keletsekis  (30 July 1998)
*
*	This is a set of four functions for simple use of the
*	clipboard. It is loosely based on example code I found
*	on aminet, by Commodore, but which did not work (for me 
*	at least..) I thought someone else might benefit from it 
*	since it took some effort to get it to work properly.
*	
*	There are four main functions provided for Opening, 
*	Closing, Reading and Writing to the clipboard. 
*	Posting etc are not supported.
*	
*	This code is public domain in all respects.
*
**********************************************************************/

#include "exec/types.h"
#include "exec/ports.h"
#include "exec/io.h"
#include "devices/clipboard.h"

// Function Prototypes
struct IOClipReq *ClipOpen (LONG);
void ClipClose (struct IOClipReq *);
UBYTE *ClipRead (struct IOClipReq *);
int ClipWrite (struct IOClipReq *, UBYTE *, LONG);
void writeLong (struct IOClipReq *, APTR);

// --------------------------------------------------------------------
//	Open Clipboard unit
//	unit = The Cliboard Unit you want opened (0 - 255)
//	return : Handle (IOClipReq structure *) or NULL for error
// --------------------------------------------------------------------

struct IOClipReq *ClipOpen (LONG unit)
{
    struct IOClipReq *clip=NULL;
    struct MsgPort *port=NULL;
    LONG error;
    BOOL ok=0;

    // get structures..
    if (clip = (struct IOClipReq *)AllocVec(sizeof(struct IOClipReq), MEMF_CLEAR))
    {   if (port = (struct MsgPort *)AllocVec(sizeof(struct MsgPort), MEMF_CLEAR))
            ok = 1;
    }
    if (!ok) goto enderror;

    // open the clipboard device
    if (error = OpenDevice("clipboard.device", unit, (struct IORequest *)clip, 0))
    {   PutStr ("Could not open ClipBoard\n");
	goto enderror;
    }

    // Set up the message port in the I/O request
    if ((port->mp_SigBit = AllocSignal(-1)) >= 0)
    {   port->mp_Node.ln_Type = NT_MSGPORT;
        port->mp_Flags   = 0;
        port->mp_SigTask = (struct Task *) FindTask((char *) NULL);
        AddPort(port);
        clip->io_Message.mn_ReplyPort = port;
        return (clip);
    }
    else
        CloseDevice((struct IORequest *)clip);
        // end with error..

    enderror:
    if (clip) FreeVec (clip);
    if (port) FreeVec (port);
    return (NULL);
}

// --------------------------------------------------------------------
//	Close clipboard
//	clip = handle you received from ClipOpen()
// --------------------------------------------------------------------

void ClipClose (struct IOClipReq *clip)
{
    struct MsgPort *port;
    
    if (clip)
    {   if (port = clip->io_Message.mn_ReplyPort)
        {   RemPort (port);
	    FreeSignal (port->mp_SigBit);
            FreeVec (port);
        }
        CloseDevice((struct IORequest *)clip);
        FreeVec (clip);
}   }


// --------------------------------------------------------------------
//	Read text from the Clipboard
//	clip   = handle you received from ClipOpen()
//	return = pointer to string - which you MUST FreeVec() - or NULL
// --------------------------------------------------------------------

UBYTE *ClipRead (struct IOClipReq *clip)
{
    int length=0, formlen=0, status=0;
    UBYTE *buff = NULL;	// AllocVec'd !!
    UBYTE tbf[10];

    clip->io_Command = CMD_READ; // get the FORM
    clip->io_Data = tbf;
    clip->io_Length = 4;
    clip->io_Offset = 0;
    clip->io_ClipID = 0;
    status -= DoIO((struct IORequest *)clip);
    tbf[4]='\0';

    if(!strcmp(tbf,"FORM"))
    {
        clip->io_Command = CMD_READ; // get the total length
        clip->io_Data = (UBYTE *)&formlen;
        clip->io_Length = 4;
        status -=DoIO((struct IORequest *)clip);

        clip->io_Command = CMD_READ; // read the FTXTCHRS
        clip->io_Data = tbf;
        clip->io_Length = 8;
        status -=DoIO((struct IORequest *)clip);
        tbf[8]='\0';

        if(!strcmp(tbf,"FTXTCHRS"))
        {
           clip->io_Command = CMD_READ; // get the length of the data
           clip->io_Data = (UBYTE *)&length;
           clip->io_Length = 4;
           status -=DoIO((struct IORequest *)clip);

           // read the data
           buff = (UBYTE *)AllocVec(length+16, MEMF_ANY);
           clip->io_Command = CMD_READ;
           clip->io_Data = buff;  // may be NULL if alloc failed
           clip->io_Length = length;
           status -=DoIO((struct IORequest *)clip);
           
           if (buff) buff[length] = '\0';
           else status -= 1;

	   if ((formlen - length) == 13) // read in byte if odd length
           {   clip->io_Command = CMD_READ;
               clip->io_Data = NULL;
               clip->io_Length = 1;
               status -=DoIO((struct IORequest *)clip);
           }
        }
    }
    // read with offset past the end of the clip to signify the end..
    clip->io_Command = CMD_READ;
    clip->io_Length = 1;
    clip->io_Data = NULL;
    DoIO((struct IORequest *)clip);

    if (status)  // error occured
    {   if (buff) FreeVec (buff);
        PutStr ("Error reading from clipboard\n");
        return(NULL);
    }

    return (buff);    // must be freeveced !!!
}

// --------------------------------------------------------------------
//	Write text to the clipboard
//	clip   = handle you received from ClipOpen()
//	string = the text you want to write
//	length = length of string or -1 meaning strlen(string)
//	return : 0 for OK - error status otherwise
// --------------------------------------------------------------------

ClipWrite (struct IOClipReq *clip, UBYTE *string, LONG length)
{
    LONG len, status=0, addlen=0;
    UBYTE pad = '\0';
    
    // get length (if -1 is passed)
    len = length;
    if (len < 0) len = strlen(string);
    // if data is of odd length, we must add a padding byte
    // I don't why this is done - I just do as I'm told.. 
    if (len % 2) addlen = 1;

    // set id & offset to 0, clearing previous writes
    clip->io_ClipID = 0;
    clip->io_Offset = 0;

    // write the IFF header
    writeLong(clip, "FORM");
    len += (12 + addlen);
    writeLong(clip, &len);
    writeLong(clip, "FTXT");
    writeLong(clip, "CHRS");
    len -= (12 + addlen);
    writeLong(clip, &len);

    // write the data
    clip->io_Command = CMD_WRITE;
    clip->io_Data = string;
    clip->io_Length = len;
    status -=DoIO((struct IORequest *)clip);

    if (addlen)  // add padding byte if data is odd length
    {  clip->io_Command = CMD_WRITE;
       clip->io_Data = &pad;
       clip->io_Length = 1;
       status -=DoIO((struct IORequest *)clip);
    }

    // tell clipboard we're done..
    clip->io_Command = CMD_UPDATE;
    status -=DoIO((struct IORequest *)clip);
    if (status) PutStr ("Error writing to the clipboard\n");
    return (status);
}

// --------------------------------------------------------------------
//	private function to write 4 bytes to the clipboard
// --------------------------------------------------------------------

void writeLong (struct IOClipReq *clip, APTR ldata)
{
    clip->io_Command = CMD_WRITE;
    clip->io_Data = ldata;
    clip->io_Length = 4;
    DoIO((struct IORequest *)clip);
}

