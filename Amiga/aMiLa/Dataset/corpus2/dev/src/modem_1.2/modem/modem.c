/*
 * Modem setup/dialer program.  Usage is: modem [-d Device] [-n number]
 * 
 * $Revision: 1.4 $ $Author: srn $ $Log: modem.c,v $
 * Revision 1.4  1993/12/12  14:06:07  srn
 * Added BAUD optin
 *
 * Revision 1.3  1993/11/20  14:39:30  srn
 * Fixed version string.
 *
 * Revision 1.2  1993/10/09  11:58:15  srn
 * Fixed bug with extraneous characters after ^C.
 *
 * Revision 1.1  1993/09/04  11:42:33  srn
 * Initial revision
 *
 */

/*
        This program is copyright 1990, 1993 Stephen Norris. 
        May be freely distributed provided this notice remains intact.
*/


#include <exec/types.h>
#include <devices/serial.h>
#include <dos/dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <clib/dos_protos.h>

#include "t:DateHeader.h"
#define VERSIONTEXT "Modem 1.2 " __AMIGADATE__;
const char Version[] = "$VER:" VERSIONTEXT;

const char Template[] = "DEVICE,UNIT/N,BAUD/N";
char   *Device = "serial.device";
int     Unit = 0;
int	Baud = 0;	/* Baud rate requested from command line. */

int     SerOpen = FALSE;	/* Flag set if the serial device is open. */

struct MsgPort *SerialMP = NULL;	/* Port for replies to io messages to go

					   * to. */
struct IOExtSer *SerialIO = NULL;	/* Data structure used for

					 * messages to device. */
struct IOExtSer *IncomingIO = NULL;	/* Structure for incoming

					 * characters. */
void    OpenAll( void );
void    CloseAll( void );

void
OpenAll()
{
	if ((SerialMP = (struct MsgPort *) CreatePort(0, 0)) == NULL) {
		printf("Can't create message port.\n");
		CloseAll();
		exit(30);
	}
	if ((SerialIO = (struct IOExtSer *) CreateExtIO(SerialMP, sizeof(struct IOExtSer))) == NULL) {
		printf("Can't allocate storage for ExtIO.\n");
		CloseAll();
		exit(30);
	}
	if ((IncomingIO = (struct IOExtSer *) CreateExtIO(SerialMP, sizeof(struct IOExtSer))) == NULL) {
		printf("Can't allocate storage for ExtIO.\n");
		CloseAll();
		exit(30);
	}
	SerialIO->io_SerFlags = SERF_SHARED;	/* Turn on SHARED Mode */

	if ((SerOpen = !OpenDevice(Device, (long) Unit, SerialIO, 0L)) == NULL) {
		printf("Can't open %s unit %ld.\n", Device, (long) Unit);
		CloseAll();
		exit(30);
	}

	if (Baud != 0){
		/* Set baud rate if needed. */
		SerialIO->io_Baud = Baud;
		SerialIO->IOSer.io_Command = SDCMD_SETPARAMS;
		if (DoIO(SerialIO) != NULL) {
			printf("Unable to set baud rate.\n");
		}
	}
	memcpy(IncomingIO, SerialIO, sizeof(struct IOExtSer));

	if (!conInit()){
		printf("Console setup failed.\n");
		CloseAll();
		exit(30);
	}
}

void
CloseAll()
{

	conClose();

	if (SerOpen)
		CloseDevice(SerialIO);

	if (IncomingIO)
		DeleteExtIO(IncomingIO);

	if (SerialIO)
		DeleteExtIO(SerialIO);

	if (SerialMP)
		DeletePort(SerialMP);
}

void
Break()
{
	printf("*** Break\n");
	while (WaitForChar(Input(), 10))
		getchar();
	CloseAll();
	exit(30);
}

void
main(int argc, char *argv[])
{
	struct	RDArgs *Args;
	long	*ArgRes[3] = {0, 0, 0};
	int 	Done = 0;

	/* Handle arguments. */
	if ((Args = ReadArgs(Template, ArgRes, NULL)) == NULL){
		printf("Usage: %s\n", Template);
		CloseAll();
		exit(30);
	}

	if (ArgRes[0] != 0){
		Device = strdup((char *)ArgRes[0]);
	}
	if (ArgRes[1] != 0){
		Unit = *ArgRes[1];
	}
	if (ArgRes[2] != 0){
		Baud = *ArgRes[2];
	}

	FreeArgs(Args);

	OpenAll();
	onbreak(Break);

	while (!Done) {
		char    Buffer;
		int     length;
		char   *InBuffer;

		if (WaitForChar(Input(), 100000)) {
			Buffer = getchar();
			if (Buffer == '\n')
				Buffer = '\r';

			SerialIO->IOSer.io_Command = CMD_WRITE;
			SerialIO->IOSer.io_Length = 1;
			SerialIO->IOSer.io_Data = (APTR) &Buffer;
			if (DoIO(SerialIO) != NULL) {
				printf("Write failed with error %d.\n", SerialIO->IOSer.io_Error);
				CloseAll();
				exit(30);
			}
		}
		/* Serial input? */
		IncomingIO->IOSer.io_Command = SDCMD_QUERY;
		IncomingIO->IOSer.io_Actual = 0;
		if (DoIO(IncomingIO) != NULL) {
			printf("Failed SDCMD_QUERY\n");
			CloseAll();
			exit(30);
		}
		if ((length = IncomingIO->IOSer.io_Actual) > 0) {
			if ((InBuffer = malloc(length+1)) == NULL) {
				printf("Out of memory\n");
				CloseAll();
				exit(30);
			}
			IncomingIO->IOSer.io_Command = CMD_READ;
			IncomingIO->IOSer.io_Length = length;
			IncomingIO->IOSer.io_Data = InBuffer;
			if (DoIO(IncomingIO) != NULL) {
				printf("Failed read.\n");
				free(InBuffer);
				CloseAll();
				exit(30);
			}
			Write (Output(), InBuffer, length);

			free(InBuffer);
		}
	}
	CloseAll();
	exit(0);
}
