/*
** EZPrinter.c
** Version 1.00     By The Reaper
**
** These little routines have been written to make it easier for you to
** use the printer device in your C programs without needing to worry about
** all the allocs/opens needed.
**
** This was based on the RKRM example source but made to look a bit nicer
** and Dice 3.01 compatible.
**
** Functions:
**
** int open_printer(void)
**     Open the printer device and setup msg ports etc. Returns 0 on success
**
** void close_printer(void)
**     Should be called even if open_printer fails as it frees all
**     succesfull allocs made by open_printer()
**
** void init_printer(void)
**     Sends the init code to the printer
**
** void send_text(char *text)
**     Sends the string text to the printer. Note: Uses DoIO()
**
** void queue_write(char *text)
**     Same as send_text but uses SendIO() instead. Note: Don't forget to
**     wait for it to return! You can make an Abort gadget by calling
**     AbortIO() for the queued write.
*/

#define Prototype extern

#include <exec/types.h>
#include <devices/printer.h>
#include <devices/prtbase.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/alib_stdio_protos.h>

/* Unions */
union printerIO
{
    struct IOStdReq    ios;
    struct IODRPReq    iodrp;
    struct IOPrtCmdReq iopc;
};

/* Globals */
struct MsgPort *printMsgPort;
union printerIO *pio;

/* Prototypes */
Prototype int open_printer(void);
Prototype void close_printer(void);
Prototype void init_printer(void);
Prototype void send_text(char *text);
Prototype void queue_write(char *text);

int open_printer(void)
{
	if(printMsgPort = CreatePort(0L,0L))
	{
		if(pio = (union printerIO *)CreateExtIO(printMsgPort,sizeof(union printerIO)))
		{
			if(!(OpenDevice("printer.device",0L,(struct IORequest *)pio,0L)))
			{
				return(0L);
			}
			else return(3L);
		}
		else return(2L);
	}
	else return(1L);
}
void close_printer(void)
{
	if(pio)
	{
		CloseDevice((struct IORequest *)pio);
		DeleteExtIO((struct IORequest *)pio);
	}
	if(printMsgPort)
	{
		DeletePort(printMsgPort);
	}
}
void init_printer(void)
{
	pio->ios.io_Command = CMD_WRITE;
	pio->ios.io_Data = "\033#1";
	pio->ios.io_Length = -1L;
	
	DoIO((struct IORequest *)pio);
}
void send_text(char *text)
{
	pio->ios.io_Command = CMD_WRITE;
	pio->ios.io_Data = text;
	pio->ios.io_Length = -1L;
	
	DoIO((struct IORequest *)pio);
}
void queue_write(char *text)
{
	pio->ios.io_Command = CMD_WRITE;
	pio->ios.io_Data = text;
	pio->ios.io_Length = -1L;
	
	SendIO((struct IORequest *)pio);
}