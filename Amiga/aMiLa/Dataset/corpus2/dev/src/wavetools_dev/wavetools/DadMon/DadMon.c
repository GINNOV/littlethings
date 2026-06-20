/*
** Dad Monitor
*/

char version_string[] = "$VER: DadMon 0.17 (95.11.15)";

#include <intuition/intuitionbase.h>
#include <exec/nodes.h>
#include <exec/tasks.h>
#include <libraries/dos.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <devices/dad_audio.h>

/*
** Global Variables
*/
LONG FREQUENCY,INPUTGAIN,WIN_LEFT, WIN_TOP, WIN_WIDTH, WIN_HEIGHT, UPDATE;
char *filename;	/* global filename pointer pointer, ugly but...*/


struct IOStdReq *create_dadaudio() {

	LONG error;
	struct MsgPort *dadport;
	struct IOStdReq *dadmsg;

	if ((dadport = (struct MsgPort *)CreatePort(0,0)) == NULL)
		exit(1);
	if ((dadmsg = (struct IOStdReq *)CreateExtIO(dadport,sizeof(struct IOStdReq))) == NULL)
		exit(1);
	if ((error = OpenDevice(DAD_DEVICENAME,0,(struct IOStdReq *)dadmsg,0)) != 0)
		exit(1);
	return(dadmsg);
}




void Monitor(void){
	struct IntuiMessage *message;
	struct UserPort *winport;
	UWORD l_sample=0,r_sample=0;
        int class;
	UWORD *dad_dma_buffer;
	ULONG dad_dma_length=0;

	FILE *filehandle=NULL;
	char *chipmembuf;
        UWORD *long_aligned_buffer;
        ULONG address_temp;
	ULONG dad_max_buffer_size = 8084;	/* this number is from monitoring the device */
	struct IOStdReq *dadio=NULL;
        int buffer_size = 64000;
	int QUIT = 0;  				/* exit flag */

	/*
	** Maybe MEMF_24BITDMA is good too?
	** It should be for reading but I want to write buffer to disk. ie.chipmem?
	*/
	if ((chipmembuf = (char *)AllocMem(buffer_size,MEMF_CHIP|MEMF_CLEAR)) == NULL)
		QUIT = 1;
	address_temp = (LONG)chipmembuf + 1;	/* add one long word so next operation stays within memblock */
	address_temp &=	0xFFFFFFFC;		/* truncate address to nearest longword */
	long_aligned_buffer = (UWORD *)address_temp;

        if ((winport = (struct UserPort *)OpenFace(WIN_LEFT, WIN_TOP, WIN_WIDTH, WIN_HEIGHT)) == NULL)
        	QUIT = 1; 		/* open the window  and get a messageport ,wital we use it to quit sampling!! */

	if ((dadio = create_dadaudio()) == NULL)
		QUIT = 1;			/* open dad_audio.device */

 	/*
 	** WARNING no Fail open test
 	*/
	if (filename) {
		if ((filehandle = (FILE *)Open(filename,MODE_NEWFILE)) == NULL)
			QUIT = 1;
	}

	/* setup hardware */
        if (QUIT == 0){

	/* NOTE:
	**	I dont know how much of this stuff is needed
	**	maybe only INIT2 and only once
	**	mainly I put it all here to mimic what wavetools does
	**	as seen by devmon.
	*/
		dadio->io_Data    = (void *)(DADF_SETFLAG | DADF_INIT);		/* reset hardware		*/
   	   	dadio->io_Length  = 0;
		dadio->io_Offset  = 0;
		dadio->io_Command = DADCMD_INIT2;
		dadio->io_Flags   = 0;
		DoIO((struct IOStdReq *)dadio);

		dadio->io_Data    = 0x0;
   	   	dadio->io_Length  = 0;
		dadio->io_Offset  = 0;
		dadio->io_Command = DADCMD_INIT1;
		dadio->io_Flags   = 0;
		DoIO((struct IOStdReq *)dadio);			/* io_Actual is some address but I dont use it here */

		dadio->io_Data    = (void *)(DADF_SETFLAG | DADF_INIT);		/* reset hardware again		*/
   	   	dadio->io_Length  = 0;
		dadio->io_Offset  = 0;
		dadio->io_Command = DADCMD_INIT2;
		dadio->io_Flags   = IOF_QUICK;
		DoIO((struct IOStdReq *)dadio);
	/*
	** these are definitly needed if you are going to sample
	** unless you fancy relying on standard values :)
	*/

		dadio->io_Data    = (void *)0x0;		/* Damping on line out */
   	   	dadio->io_Length  = 0;
		dadio->io_Offset  = 0;
		dadio->io_Command = DADCMD_OUTPUTDAMP;
		dadio->io_Flags   = IOF_QUICK;
		DoIO((struct IOStdReq *)dadio);

		dadio->io_Data    = (void *)INPUTGAIN;		/* Gain on line in	*/
   	   	dadio->io_Length  = 0;
		dadio->io_Offset  = 0;
		dadio->io_Command = DADCMD_INPUTGAIN;
		dadio->io_Flags   = IOF_QUICK;
		DoIO((struct IOStdReq *)dadio);

		dadio->io_Data    = (void *)FREQUENCY;		/* Replay frequency	*/
   	   	dadio->io_Length  = 0;
		dadio->io_Offset  = 0;
		dadio->io_Command = DADCMD_REPLAYFREQ;
		dadio->io_Flags   = IOF_QUICK;
		DoIO((struct IOStdReq *)dadio);

		dadio->io_Data    = (void *)FREQUENCY;		/* Sampling frequency	*/
   	   	dadio->io_Length  = 0;
		dadio->io_Offset  = 0;
		dadio->io_Command = DADCMD_SAMPLEFREQ;
		dadio->io_Flags   = IOF_QUICK;
		DoIO((struct IOStdReq *)dadio);

		dadio->io_Data    = 0x0;			/* you dont have to give an address to this */
   	   	dadio->io_Length  = 0;
		dadio->io_Offset  = DAD_BUFFER_SETUP;
		dadio->io_Command = DADCMD_BUFFER;
		dadio->io_Flags   = IOF_QUICK;
		DoIO((struct IOStdReq *)dadio);
                dad_dma_length = dadio->io_Actual;		/* maximum buffer length returned ie. the length of internal buffers*/

        }

	while (QUIT == 0) {

		dadio->io_Data    = long_aligned_buffer;
   		dadio->io_Length  = dad_dma_length;		/* When we did SET_BUFFER (above) we got a return value */
		dadio->io_Offset  = -1;				/* it works with Offset=0, but it returns with io_Offset = -1 so why not use -1*/
		dadio->io_Command = CMD_READ;
		dadio->io_Flags   = IOF_QUICK;
		SendIO((struct IOStdReq *)dadio);		/* read into chipmem buffer	*/
                WaitIO(dadio);					/* wait for io to finish 	*/

		/*
		** Dump Chip buffer to disk,
		** length = last number of bytes sampled into buffer. ie. io_Actual.
		*/
		if(filehandle != NULL){
			Write(filehandle,long_aligned_buffer,dadio->io_Actual);
		}
		else {
			l_sample = *(WORD *)long_aligned_buffer;
			r_sample = *(WORD *)(long_aligned_buffer+1);
			MoveFace(l_sample,r_sample);
		}

		dadio->io_Data    = 0x0;		/* relative adressing		*/
   		dadio->io_Length  = dadio->io_Actual;	/* rewind the buffer to start 	*/
		dadio->io_Offset  = DAD_BUFFER_SWITCH;	/* swap buffers on card		*/
		dadio->io_Command = DADCMD_BUFFER;  	/* buffer command 		*/
		dadio->io_Flags   = 0;
		DoIO((struct IOStdReq *)dadio);
		dad_dma_length = dadio->io_Actual;	/* buffer command always returns next readbuffers length */

       		while (message = (struct IntuiMessage *)GetMsg(winport)) {
			if ((class = message->Class) == CLOSEWINDOW) {
				ReplyMsg((struct Msg *)message);
				QUIT=1;		/* close window to quit*/
			}
			else if (class == NEWSIZE) {
				ReplyMsg((struct Message *)message);
				FreshFace();
			}
			else if (class == CHANGEWINDOW)
				ReplyMsg((struct Msg *)message);
		}/* while */


	} /* while */

	/*
	** Free resources
	*/
	if (winport) CloseFace();		/* window stuff */
	if (chipmembuf) FreeMem(chipmembuf,buffer_size);
	if(filehandle) Close(filehandle);
	if (dadio) {
		WaitIO(dadio);	/* wait till all is clear */
		CloseDevice((struct IORequest *)dadio);
		DeleteExtIO((struct IORequest *)dadio);
	}

}


/*
** Template string and variables used for command line arguments.
*/
#define TEMPLATE "FILE/M,F=FREQUENCY/N,G=INPUTGAIN/N,L=LEFT/N,T=TOP/N,W=WIDTH/N,H=HEIGHT/N,UPDATE/N"


int main(int argc, char *argv[]) {
	struct Task *thistask;
	struct RdArgs *ra;
	LONG args[8] = { 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L };
  	struct WBStartup *argmsg;
  	struct WBArg *wb_arg;
	char programname[20];


        /*thistask = (struct Task *)FindTask(NULL);*/
  	/*GetProgramName (programname, 19);*/
        if (argc == 0) {
        	exit(0);	/* bailout if launched from WB */
	}else {
  		if (ra = (struct RdArgs *)ReadArgs(TEMPLATE, args, NULL)) {

			filename   = (args[0] ? *(char **)args[0] : NULL);
			FREQUENCY  = (args[1] ? *(LONG *)args[1] : 44100);
			INPUTGAIN  = (args[2] ? *(LONG *)args[2] : 0);
			WIN_LEFT   = (args[3] ? *(LONG *)args[3] : 0);
			WIN_TOP    = (args[4] ? *(LONG *)args[4] : 0);
			WIN_WIDTH  = (args[5] ? *(LONG *)args[5] : 130);
			WIN_HEIGHT = (args[6] ? *(LONG *)args[6] : 100);
			UPDATE     = (args[7] ? *(LONG *)args[7] : 1);
			if (UPDATE < 1)			/* A value of 0 would be unacceptable.*/
				UPDATE = 1;
		} else {
			/*
			** IF nothing was given, does RdArgs still allocate?
			** set defaults here just in case.
			*/
			filename = NULL;
			FREQUENCY  = 44100;
			INPUTGAIN  = 0;
			WIN_LEFT   = 0;
			WIN_TOP    = 0;
			WIN_WIDTH  = 130;
			WIN_HEIGHT = 100;
			UPDATE     = 1;
		}
		/*
		** Dump values to stdout.
		*/

		printf("%s\n",version_string);
		if (filename) printf("Output    : %s\n",filename);
		printf("Frequency : %i\n",FREQUENCY);
		printf("Inputgain : %i\n",INPUTGAIN);
		printf("Win Left  : %i\n",WIN_LEFT);
		printf("Win Top   : %i\n",WIN_TOP);
		printf("Win Width : %i\n",WIN_WIDTH);
		printf("Win Height: %i\n",WIN_HEIGHT);
		printf("Update    : %i\n",UPDATE);

	        /*
        	** Do the monitoring stuff
	        */
		Monitor();
		if(ra) FreeArgs(ra);	/* dump args */
        }

}
