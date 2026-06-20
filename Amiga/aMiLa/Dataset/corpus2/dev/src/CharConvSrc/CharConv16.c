#include <stdarg.h>
#include <varargs.h>

#include <exec/types.h>
#include <exec/execbase.h>
#include <dos/dos.h>
#include <dos/dostags.h>
#include <dos/rdargs.h>

#include <CharTabs.h>

#define VERSION "1.6"

UBYTE *ver="\0$VER: CharConv "VERSION" ("__COMMODORE_DATE__")";

#define BUFSIZE 4096

UBYTE ibuf[BUFSIZE];
UBYTE obuf[2*BUFSIZE];

UBYTE readfrom[256];
UBYTE readto[256];

#define EOL_CR   1
#define EOL_LF   2
#define EOL_CRLF 3

extern struct ExecBase *SysBase;

#define FROM            0
#define TO              1
#define FROMCHRS        2
#define TOCHRS          3
#define LF              4
#define CR              5
#define CRLF            6
#define NOANSI          7

UBYTE *argstr="FROM/A,TO/A,FROMCHRS/A,TOCHRS/A,LF/S,CR/S,CRLF/S,NOANSI/S";
ULONG argarray[8];

UBYTE *helptxt = "\n\x1b[4m\x1b[1mCharConv "VERSION"\x1b[24m\x1b[22m © 1994 Johan Billing - \x1b[3mFREEWARE!\x1b[23m\n\n"
                 "Usage: CharConv <from> <to> <fromchrs> <tochrs> [LF/CR/CRLF/NOANSI]\n\n"
                 " Built-in charsets: IBM=PC, AMIGA=ISO, SIS=SF7, MAC\n"
                 " (Use '#' in front of the charset to force loading of *.crossdos file)\n\n";

myputs(UBYTE *str)
{
   Write(Output(),str,strlen(str));
}

void smallsprintf(UBYTE *buffer,UBYTE *ctl, ...)
{
   va_list args;

   va_start(args, ctl);
   RawDoFmt(ctl, args, (void (*))"\x16\xc0\x4e\x75", buffer);
   va_end(args);
}

void _main(void)
{
   BPTR ifp,ofp,rfp;
   UBYTE buffer[100],buf2[100];

   UBYTE *fchrs=NULL;
   UBYTE *tchrs=NULL;

   BOOL breakflag=FALSE;

   UWORD ipos,opos,ilen,c=0,lastc=0,eol=0;
   BOOL noansi=FALSE;
   BOOL ansinow=FALSE,onemore=FALSE;

   struct RDArgs *rdargs;
   struct RDArgs *myrdargs;

   if(SysBase->LibNode.lib_Version<37)
   {
      myputs("Sorry! This program requires Kickstart 2.04 or higher\n");
      _exit(0);
   }

   myrdargs = (struct RDArgs *)AllocDosObjectTags(DOS_RDARGS, TAG_DONE);

   if(!myrdargs)
   {
      PrintFault(IoErr(),NULL);
      _exit(10);
   }

   myrdargs->RDA_ExtHelp = helptxt;

   if(!(rdargs = (struct RDArgs *)ReadArgs(argstr,argarray,myrdargs)))
   {
      PrintFault(IoErr(),NULL);
      FreeDosObject(DOS_RDARGS,myrdargs);
      _exit(10);
   }

   if(stricmp(argarray[FROMCHRS],"IBM")==0 || stricmp(argarray[FROMCHRS],"PC")==0)
      fchrs=IbmToAmiga;

   else if(stricmp(argarray[FROMCHRS],"SF7")==0 || stricmp(argarray[FROMCHRS],"SIS")==0)
      fchrs=SF7ToAmiga;

   else if(stricmp(argarray[FROMCHRS],"MAC")==0)
      fchrs=MacToAmiga;

   else if(!(stricmp(argarray[FROMCHRS],"ISO")==0 || stricmp(argarray[FROMCHRS],"AMIGA")==0))
   {
      if(((UBYTE *)argarray[FROMCHRS])[0]=='#') strcpy(buf2,&((UBYTE *)argarray[FROMCHRS])[1]);
      else                                      strcpy(buf2,argarray[FROMCHRS]);

      smallsprintf(buffer,"L:FileSystem_Trans/%.50s.crossdos",buf2);

      if(!(rfp=Open(buffer,MODE_OLDFILE)))
      {
         Printf("Unknown charset \"%s\"\n",buf2);
         FreeArgs(rdargs);
         FreeDosObject(DOS_RDARGS,myrdargs);
         _exit(0);
      }
      Seek(rfp,256,OFFSET_BEGINNING);
      Read(rfp,readfrom,256);
      Close(rfp);

      fchrs=readfrom;
   }

   if(stricmp(argarray[TOCHRS],"IBM")==0 || stricmp(argarray[TOCHRS],"PC")==0)
      tchrs=AmigaToIbm;

   else if(stricmp(argarray[TOCHRS],"SF7")==0 || stricmp(argarray[TOCHRS],"SIS")==0)
      tchrs=AmigaToSF7;

   else if(stricmp(argarray[TOCHRS],"MAC")==0)
      tchrs=AmigaToMac;

   else if(!(stricmp(argarray[TOCHRS],"ISO")==0 || stricmp(argarray[TOCHRS],"AMIGA")==0))
   {
      if(((UBYTE *)argarray[TOCHRS])[0]=='#') strcpy(buf2,&((UBYTE *)argarray[TOCHRS])[1]);
      else                                    strcpy(buf2,argarray[TOCHRS]);

      smallsprintf(buffer,"L:FileSystem_Trans/%.50s.crossdos",buf2);

      if(!(rfp=Open(buffer,MODE_OLDFILE)))
      {
         Printf("Unknown charset \"%s\"\n",buf2);
         FreeArgs(rdargs);
         FreeDosObject(DOS_RDARGS,myrdargs);
         _exit(0);
      }
      Read(rfp,readto,256);
      Close(rfp);

      tchrs=readto;
   }

   if(argarray[LF])
      eol=EOL_LF;

   if(argarray[CR])
      eol=EOL_CR;

   if(argarray[CRLF])
      eol=EOL_CRLF;

   if(argarray[NOANSI])
      noansi=TRUE;

   if(!(ifp=(BPTR)Open(argarray[FROM],MODE_OLDFILE)))
   {
      Printf("Error opening \"%s\" for reading!\n",argarray[FROM]);
      FreeArgs(rdargs);
      FreeDosObject(DOS_RDARGS,myrdargs);
      _exit(0);
   }

   if(!(ofp=(BPTR)Open(argarray[TO],MODE_NEWFILE)))
   {
      Printf("Error opening \"%s\" for writing!\n",argarray[TO]);
      Close(ifp);
      FreeArgs(rdargs);
      FreeDosObject(DOS_RDARGS,myrdargs);
      _exit(0);
   }

   c=0;

   while((ilen=Read(ifp,ibuf,BUFSIZE)) && !breakflag)
   {
      opos=0;

      for(ipos=0;ipos<ilen;ipos++)
      {
         lastc=c;
         c=ibuf[ipos];

         if(c==10 || c==13)
         {
            if(!eol) obuf[opos++]=c;
            else
            {
               if((c==10 && lastc!=13) || c==13)
               {
                  switch(eol)
                  {
                     case EOL_CR:   obuf[opos++]=13;
                                    break;
                     case EOL_LF:   obuf[opos++]=10;
                                    break;
                     case EOL_CRLF: obuf[opos++]=13;
                                    obuf[opos++]=10;
                                    break;
                  }
               }
            }
         }
         else if((c==0x1b || c==0x9b) && noansi==TRUE || ansinow)
         {
            if(onemore)
            {
               ansinow=FALSE;
               onemore=FALSE;
            }
            else if(c=='#')
            {
               onemore=TRUE;
            }
            else if((c>='@' && c<='Z') || (c>='a' && c<='z'))
            {
               if(!(c=='P' && (lastc=='['||lastc==';')))
                  ansinow=FALSE;
            }
            else if(c=='6' && lastc=='(')
            {
               ansinow=FALSE;
            }
            else
            {
               ansinow=TRUE;
            }
         }
         else
         {
            if(fchrs) c=fchrs[c];
            if(tchrs) c=tchrs[c];
            if(c) obuf[opos++]=c;
         }
       }
       if(opos) Write(ofp,obuf,opos);

       if(SetSignal(0L,0L) & SIGBREAKF_CTRL_C) breakflag=TRUE;
   }

   Close(ifp);
   Close(ofp);
   FreeArgs(rdargs);
   FreeDosObject(DOS_RDARGS,myrdargs);

   if(breakflag) Printf("*** Break\n");

   _exit(0);
}

