/* The little bugger */



#include <exec/types.h>
#include <exec/exec.h>
#include <exec/memory.h>
#include <exec/interrupts.h>
#include <exec/ports.h>
#include <exec/libraries.h>
#include <exec/io.h>
#include <exec/tasks.h>
#include <exec/execbase.h>
#include <devices/narrator.h>
#include <libraries/translator.h>


struct MsgPort *writeport=NULL;
extern struct MsgPort *CreatePort();
extern struct IORequest *CreateExtIO();

struct narrator_rb *writenarrator=NULL;
struct Library *TranslatorBase=NULL;

char *SampleInput;
UBYTE OutputString[500];
SHORT rtnCode;
SHORT writeError;
SHORT error;

UBYTE audChanMasks[4]={3,5,10,12};

extern struct Library *OpenLibrary();

void CleanUp(t)
char *t;
{
   printf("%s\n",t);
   if(writenarrator) {
      CloseDevice(writenarrator);
      DeleteExtIO(writenarrator,sizeof(struct narrator_rb));
   }
   
   if(writeport)
      DeletePort(writeport);
      
   if(TranslatorBase)
      CloseLibrary(TranslatorBase);
      
   exit(0);
}

void Say(s)
char *s;
{
   printf("%s ",s);
   rtnCode=Translate(s,strlen(s),OutputString,500);
   writenarrator->sex=MALE;
   writenarrator->pitch=DEFPITCH;
   writenarrator->message.io_Data=(APTR)OutputString;
   writenarrator->message.io_Length=strlen(OutputString);
   DoIO(writenarrator);
   WaitIO(writenarrator);
}   

void main(argc,argv)
int argc;
char **argv;
{
   int i;
   
   if(!(TranslatorBase=OpenLibrary("translator.library",0)))
      CleanUp("Can't open library");
      
   SampleInput="This is a test";
   
   rtnCode=Translate(SampleInput,strlen(SampleInput),OutputString,500)+100;
   
   if(!rtnCode)
      CleanUp("Can't do test translate");


   if(!(writeport=CreatePort(0L,0L)))
      CleanUp("Can't get writeport");
   
   writenarrator=(struct narrator_rb *)CreateExtIO(writeport,
   						sizeof(struct narrator_rb));
                                                
   if(!writenarrator)
      CleanUp("Can't get writenarrator");
      
   writenarrator->ch_masks=(audChanMasks);
   writenarrator->nm_masks=sizeof(audChanMasks);
   writenarrator->message.io_Data=(APTR)OutputString;
   writenarrator->message.io_Length=0;
   writenarrator->mouths=0;
   writenarrator->message.io_Command=CMD_WRITE;
   
   if(OpenDevice("narrator.device",0L,writenarrator,0L))
      CleanUp("Can't open device");
      
   for(i=1;i<argc;i++)
      Say(argv[i]);
   
   CleanUp("OK billy");
}

   
   
      
   
   
