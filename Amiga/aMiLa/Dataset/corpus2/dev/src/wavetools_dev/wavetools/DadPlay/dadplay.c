/*
 *  Wavetools 16 bit-raw stereo sample player CLI-only version
 *  Reads a file and plays it using dad_audio.device
 *  gcc dadplay.c -lauto -noixemul -o dadplay
 */



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>

#include <dos/dos.h>
#include <dos/rdargs.h>
#include <workbench/startup.h>
#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/memory.h>
#include <exec/ports.h>
#include <devices/dad_audio.h>

void Dad_Send(struct IOStdReq *iob, ULONG data, ULONG length, ULONG offset, UWORD command, UBYTE flags)
{
   iob->io_Data    = (void *)data;
   iob->io_Length  = length;
   iob->io_Offset  = offset;
   iob->io_Command = command;
   iob->io_Flags   = flags;
   SendIO(iob);
}

int Dad_DoIO(struct IOStdReq *iob, ULONG data, ULONG length, ULONG offset, UWORD command, UBYTE flags)
{
   iob->io_Data    = (void *)data;
   iob->io_Length  = length;
   iob->io_Offset  = offset;
   iob->io_Command = command;
   iob->io_Flags   = flags;
   DoIO(iob);
}


int Cleanup(file,buf,buf_len,dev,io,port)
{
   if (file) Close(file);
   if (buf) FreeMem(buf,buf_len);
   if (!dev) CloseDevice((struct IOStdReq *)io);
   if (io) DeleteExtIO(io,sizeof(struct IOStdReq));
   if (port) DeletePort(port);
}

static char version_string[] ="$VER: dadplay 0.1 (1995-11-09)";

int main (int argc, char *argv[])
{
  char **fname;
  long damping=0,frequency = 22050; /* 0<= damping<=63 ,  frequency =< 48000 */
  char devicename[16] = DAD_DEVICENAME;
  struct WBStartup *argmsg;
  struct WBArg *wb_arg;
  UWORD ktr;
  int errorcode = 0; /* 0= all is fine */
  struct RDArgs *rdargs = NULL;
  LONG argarray[3] = {0,0,0};
  char programname[20];
  struct Task *thistask=NULL;
  int mysignal=0;
  struct MsgPort *myport = NULL;
  struct IOStdReq *iorequest=NULL; /* allokeras senare 48 bytes */
  int deviceopen = -1;
  FILE *filehandle=NULL;
  LONG nrof_bytesread = 0;
  UBYTE *buffer=NULL; /* allokeras senare */
  char 	Template[]="FILE/M,D=DAMPING/N,F=FREQ/N";

  int buffer_length = 51200;	/* length of buffer in chip mem */



  /* standard libraries are auto-opened here by GCC libauto.a (gotta love it!)*/

  thistask = (struct Task *)FindTask(NULL);
  GetProgramName (programname, 19);

/*****************************************************
** Handle arguments                                 **
*****************************************************/
  if (argc == 0) {
    argmsg = (struct WBStartup *)argv;
    wb_arg = argmsg->sm_ArgList;
    strcpy (programname, wb_arg->wa_Name);
    if (argmsg->sm_NumArgs <= 1)
      printf("only one file names \n");
    else {
      wb_arg++;
      for (ktr = 1; ktr < argmsg->sm_NumArgs; ktr++, wb_arg++)
        if (wb_arg->wa_Lock != NULL)
        /*  olddir = CurrentDir (wb_arg->wa_Lock);
          animate_file (wb_arg->wa_Name, opt);
          CurrentDir (olddir);
          olddir = NULL;
        */
        printf("many files named\n");
    }
  }else {

    if ((rdargs = (struct RDArgs *)ReadArgs((UBYTE *)Template,argarray, NULL)) != NULL) {
      if (argarray[1]) damping = *(LONG *)argarray[1];
      if (argarray[2]) frequency = *(LONG *)argarray[2];
      fname = (char **)argarray[0];
      if (fname == NULL || *fname == NULL){ /* lazy eval */
        printf("Usage: %s\n", Template);
      }
      else{
	FreeArgs (rdargs); /* Free structure, but after you copy the args!! */
        rdargs = NULL;
        if ((myport = (struct MsgPort *)CreatePort((char *)NULL,0)) != NULL) {
          if ((iorequest = (struct IOStdReq *)CreateExtIO(myport,sizeof(struct IOStdReq))) != NULL) {
            if ((deviceopen = OpenDevice("dad_audio.device",0,(struct IOStdReq *)iorequest,0)) == 0) {
              if ((buffer = (UBYTE *)AllocMem(buffer_length,MEMF_CHIP|MEMF_CLEAR)) != NULL) {
                if ((filehandle = (FILE *)Open(*fname,MODE_OLDFILE)) != NULL){
                  /*******************
                  ** Setup hardware **
                  *******************/
		  Dad_Send(iorequest,(DADF_SETFLAG | DADF_INIT),0,0,DADCMD_INIT2,IOF_QUICK);	/* try init2   */

		  Dad_Send(iorequest,damping,0,0,DADCMD_OUTPUTDAMP,IOF_QUICK);	/* set damping   */
		  Dad_Send(iorequest,frequency,0,0,DADCMD_REPLAYFREQ,IOF_QUICK);/* set frequency */
		  /*******************
		  **Stoopid playloop**
		  *******************/
                  nrof_bytesread = buffer_length;
		  while((nrof_bytesread = Read(filehandle,buffer,buffer_length)) == buffer_length) {
		    nrof_bytesread = Read(filehandle,buffer_length);				/* Read data */
		    Dad_DoIO(iorequest,(LONG)buffer,buffer_length,0,CMD_WRITE,IOF_QUICK);       /* Play data, and wait for it to finish */
		  }
       		  Dad_DoIO(iorequest,(LONG)buffer,nrof_bytesread,0,CMD_WRITE,IOF_QUICK);	/* Play half finished buffer 		*/
		  while(!CheckIO(iorequest)){
		  }
		}
              }
            }
          }
        }
        Cleanup(filehandle,buffer,buffer_length,deviceopen,iorequest,myport);
      }
    }
  }
}
