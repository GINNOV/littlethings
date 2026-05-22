;/*
   failat 20
	if not exists all.sym
      sc makegst=all.sym p:all.c
   endif
   sc gst=all.sym parms=register nostackcheck optime IRApost.c
   slink lib:c.o IRApost.o to IRApost sc sd nd lib lib:sc.lib
	QUIT
*/
/*************************************************/
/*	PostProcessor for IRA v1.xx,                  */
/*	Original coded by Comedian/Hoaxers.  (08/93)  */
/* Enhanced by SiliconSurfer/Phantasm.  (12/94)  */
/*                                               */
/*	Latest updates: 08.12.94                      */
/*************************************************/


#define VERSION     "1"
#define REVISION   "06"


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <exec/memory.h>
#include <clib/exec_protos.h>
#include <pragmas/exec_pragmas.h>
#include <libraries/dosextens.h>

/* #include "exec_calls.h" */


UBYTE version[]="$VER: IRAPost V"VERSION"."REVISION" ("__DATE__")  (c)1993,94 Tim Ruehsen\n\n";


#define BUFFERLENGTH  1024
#define GETLINE       fgets(buffer,BUFFERLENGTH,sourcefile)
#define PUTLINE       fputs(buffer,destfile)
#define GETLINEFD     fgets(buffer,BUFFERLENGTH,FDfile)


char   buffer[BUFFERLENGTH];
char   sourcename[80], destname[80], incname[80], FDname[80], libname[80];
FILE  *sourcefile, *destfile, *incfile, *FDfile;
char  *buffpeek;
int    swapcount, diffcount;
char **LibCallNames;
int   *LibCallFlags;
int   *LibCallOffs;
int    LIB_CALLS;
char   BaseName[80];
int    firstbias, bias;


int    ARGC;
char **ARGV;


extern int
    onbreak(void (*)());


void Explain(char *);
void InitPrg(void);
void ExitPrg(char *, ...);
void ReadFD(void);
void TestSource(void);
void ProcessSource(void);
void ExtractLibBase(void);
void SymbolizeLibCalls(void);
void InsertSymbolicLib(char *);
void chkabort(void);
void _abort(void);
/*****************************************************************************/
void _abort(void)
{
	fflush(stdout);
	ExitPrg("***User-Break\n");
}

/*****************************************************************************/
void main(int argc, char *argv[])
{
	ARGC = argc;
	ARGV = argv;

	InitPrg();
	ReadFD();
	TestSource();
	ProcessSource();
	ExitPrg(0);
}


/*****************************************************************************/
void ProcessSource(void)
{
	printf("Analyzing and processing sourcecode...");
	ExtractLibBase();
	SymbolizeLibCalls();
	fclose(sourcefile);sourcefile=0;
	fclose(destfile);destfile=0;
	if (ARGC == 3) {
		remove(sourcename);
		rename(destname,sourcename);
	}
	printf("Done.\n");

	strlwr(libname);
	if (swapcount == 1)
		printf("Replaced %d %s.library offset with its symbolic name.\n",swapcount,libname);
	else
		printf("Replaced %d %s.library offsets with their symbolic names.\n",swapcount,libname);
	if (swapcount > 1) {
		if (diffcount == 1)
			printf("No different %s.library calls are used in the sourcecode.\n",libname);
		else
			printf("%d different %s.library calls are used in the sourcecode.\n",diffcount,libname);
	}
	printf("\n");
}
/*****************************************************************************/
void SymbolizeLibCalls(void)
{
	char ts1[80], ts2[80], ts3[80], ts4[80];
	char ts5[80], ts6[80], ts7[80], ts8[80], ts9[80], ts10[80];
	int  ts1len, ts2len, ts3len, ts4len;
	int  ts5len, ts6len, ts7len, ts8len, ts9len, ts10len;
	int  flag = 0;


	if (!stricmp("EXEC",libname))
	{
		strcpy(ts5, "\tMOVEA.L\tABSEXECBASE,A6");
		strcpy(ts6, "\tMOVE.L\t(ABSEXECBASE).W,A6");
		strcpy(ts7, "\tMOVE.L\tABSEXECBASE,A6");
		strcpy(ts8, "\tMOVEA.L\t(ABSEXECBASE).W,A6");
		strcpy(ts9, "\tMOVE.L\tABSEXECBASE.W,A6");
		strcpy(ts10,"\tMOVEA.L\tABSEXECBASE.W,A6");
	}
	else
	{
		strcpy(ts5, "\tEND");
		strcpy(ts6, "\tEND");
		strcpy(ts7, "\tEND");
		strcpy(ts8, "\tEND");
		strcpy(ts9, "\tEND");
		strcpy(ts10,"\tEND");
	}
	strcpy(ts1,"\tMOVEA.L\t");
	strcat(ts1,BaseName);
	strcpy(ts2,ts1);
	strcat(ts1,"(PC),A6");
	strcat(ts2,",A6");
	strcpy(ts3,"\tMOVE.L\t");
	strcat(ts3,BaseName);
	strcpy(ts4,ts3);
	strcat(ts3,"(PC),A6");
	strcat(ts4,",A6");

	ts1len = strlen(ts1);
	ts2len = strlen(ts2);
	ts3len = strlen(ts3);
	ts4len = strlen(ts4);
	ts5len = strlen(ts5);
	ts6len = strlen(ts6);
	ts7len = strlen(ts7);
	ts8len = strlen(ts8);
	ts9len = strlen(ts9);
	ts10len= strlen(ts10);

/*
	printf("\n%s\n",ts1);
	printf("%s\n",ts2);
	printf("%s\n",ts3);
	printf("%s\n",ts4);
	printf("%s\n",ts5);
	printf("%s\n",ts6);
	printf("%s\n",ts7);
	printf("%s\n",ts8);
*/


	swapcount = 0;
	diffcount = 0;

	while (stricmp(buffer,"\tEND\n"))
	{
		chkabort();

		/* Find line where A6 is loaded with base of library */
		do {
			GETLINE;
			PUTLINE;
		} while(strnicmp(buffer,ts1,ts1len) &&
		        strnicmp(buffer,ts2,ts2len) &&
		        strnicmp(buffer,ts3,ts3len) &&
		        strnicmp(buffer,ts4,ts4len) &&
		        strnicmp(buffer,ts5,ts5len) &&
		        strnicmp(buffer,ts6,ts6len) &&
		        strnicmp(buffer,ts7,ts7len) &&
		        strnicmp(buffer,ts8,ts8len) &&
		        strnicmp(buffer,ts9,ts9len) &&
		        strnicmp(buffer,ts10,ts10len) &&
		        stricmp(buffer,"\tEND\n"));

/*		printf("-->%s\n",buffer); */

		flag = 0;
		while ((stricmp(buffer,"\tEND\n") != 0) && (flag == 0))
		{
			chkabort();
			GETLINE;
			if(!strnicmp(buffer,"\tRTS",4))      flag = 1;
			else if(!strnicmp(buffer,"\tBRA",4)) flag = 1;
			else if(!strnicmp(buffer,"\tBSR",4)) flag = 1;
			else if(!strnicmp(buffer,"\tEXG\tA6",7)) flag = 1;
			else if((buffpeek = strstr(buffer,",A6")) ||
			        (buffpeek = strstr(buffer,",a6")))
			{
				flag = 1;
				if(!strnicmp(buffer,ts1,ts1len)) flag = 0;
				if(!strnicmp(buffer,ts2,ts2len)) flag = 0;
				if(!strnicmp(buffer,ts3,ts3len)) flag = 0;
				if(!strnicmp(buffer,ts4,ts4len)) flag = 0;
				if(!strnicmp(buffer,ts5,ts5len)) flag = 0;
				if(!strnicmp(buffer,ts6,ts6len)) flag = 0;
				if(!strnicmp(buffer,ts7,ts7len)) flag = 0;
				if(!strnicmp(buffer,ts8,ts8len)) flag = 0;
				if(!strnicmp(buffer,ts9,ts9len)) flag = 0;
				if(!strnicmp(buffer,ts10,ts10len)) flag = 0;
			} else {
				if((!strnicmp(buffer,"\tJSR\t-",6)) && (buffpeek = strstr(buffer,"(A6)")))
				{
					InsertSymbolicLib("JSR");
				}
				else if((!strnicmp(buffer,"\tJMP\t-",6)) && (buffpeek = strstr(buffer,"(A6)")))
				{
					InsertSymbolicLib("JMP");
				}
				else if(!strnicmp(buffer,"\tJSR",4)) flag = 1;
				else if(!strnicmp(buffer,"\tJMP",4)) flag = 1;
			}
			PUTLINE;
		}

	}
}
/*****************************************************************************/
void InsertSymbolicLib(char *mnemonic)
{
	long call, i=0;

	if (buffer[6]=='$') stch_l(&buffer[7],&call);
	else call = atoi(&buffer[6]);

	if ((call >= firstbias) && (call%6 == 0))
	{
		while((i<LIB_CALLS) && (call != LibCallOffs[i])) i++;
		if (i < LIB_CALLS)
		{
			sprintf(buffer,"\t%s\t_LVO%s(A6)\n", mnemonic, LibCallNames[i]);
			swapcount++;

			if (LibCallFlags[i] == 0)
			{
				fprintf(incfile,"_LVO%s\tEQU\t-%d\n", LibCallNames[i], call);
				LibCallFlags[i] = 1;
				diffcount++;
			}
		}
	}
}
/*****************************************************************************/
void ExtractLibBase(void)
{
char ID[] = "; IRA PostProcessor v"VERSION"."REVISION" ("__DATE__")  (c)1993,94 Tim Ruehsen\n\n";

	GETLINE;
	if (!strncmp(buffer, ID, 10)) GETLINE;
	fputs(ID, destfile);
	fprintf(destfile, "\tinclude\t\"%s\"\n", incname);

	do {
		chkabort();
		GETLINE;
		PUTLINE;
	} while(strnicmp(buffer,"\tSECTION",8) && stricmp(buffer,"\tEND\n"));
}
/*****************************************************************************/
void ReadFD(void)
{
int publics, functions, publicflag, len, i;

	printf("Analysing FD file (%s) ...",FDname);

	if (!(FDfile = fopen(FDname, "r")))
		ExitPrg("Couldn't open %s",FDname);

	/* if there is no ##base entry in the FD file */
	strcpy(BaseName,libname);
	strcat(BaseName,"BASE");

	publicflag = 1;
	do {
		chkabort();
		GETLINEFD;
		if (isalpha(buffer[0]) && publicflag) LIB_CALLS++;
		else if (!strncmp(buffer,"##public",8)) publicflag = 1;
		else if (!strncmp(buffer,"##privat",8)) publicflag = 0;
	} while (stricmp(buffer,"##end\n"));
	fclose(FDfile);


	if (!(FDfile = fopen(FDname, "r")))
		ExitPrg("Couldn't open %s",FDname);
	if (!(LibCallNames=(char **)AllocMem(LIB_CALLS*sizeof(char *), MEMF_CLEAR)))
		ExitPrg("AllocMem(%ul, %x) failed.", LIB_CALLS*sizeof(char *), MEMF_CLEAR);
	if (!(LibCallFlags=(int *)AllocMem(LIB_CALLS*sizeof(int), MEMF_CLEAR)))
		ExitPrg("AllocMem(%ul, %x) failed.", LIB_CALLS*sizeof(int), MEMF_CLEAR);
	if (!(LibCallOffs=(int *)AllocMem(LIB_CALLS*sizeof(int), MEMF_CLEAR)))
		ExitPrg("AllocMem(%ul, %x) failed.", LIB_CALLS*sizeof(int), MEMF_CLEAR);


	publicflag =  1;
	publics    =  0;
	functions  =  0;
	bias       = -1;
	do {
		chkabort();
		GETLINEFD;
		if (isalpha(buffer[0]))
		{
			if (publicflag)
			{
				len = strchr(buffer,'(') - buffer;
				if (!(LibCallNames[publics]=(char *)AllocMem(len+1, MEMF_CLEAR)))
					ExitPrg("AllocMem(%ul, %x) failed.", len+1, MEMF_CLEAR);
				strncpy(LibCallNames[publics], buffer, len);
				LibCallNames[publics][len] = 0;
				LibCallOffs[publics]  = bias+6*functions;
/*				printf("-%d %s\n", LibCallOffs[publics], LibCallNames[publics]); */
				publics++;
			}
			functions++;
		}
		else if (!strncmp(buffer,"##public",8)) publicflag = 1;
		else if (!strncmp(buffer,"##privat",8)) publicflag = 0;
		else if (!strncmp(buffer,"##base",6))
		{
			for(i=8;isprint(buffer[i]);i++) BaseName[i-8] = buffer[i];
			BaseName[i-8]=0;
			strupr(BaseName);
		}
		else if (!strncmp(buffer,"##bias",6))
		{
			if (bias == -1) firstbias = atoi(&buffer[7]);
			bias = atoi(&buffer[7]);
			functions = 0;
		}
	} while (stricmp(buffer,"##end\n"));
	fclose(FDfile);
	FDfile = 0;

	printf("%s ...",BaseName);
	printf("Done.\n");
}
/*****************************************************************************/
void TestSource(void)
{
	GETLINE;

	if (strnicmp(buffer,"; IRA V1",8))
		ExitPrg("The specified sourcefile is not generated by IRA v1.xx");

	PUTLINE;
}
/*****************************************************************************/
void InitPrg(void)
{
	if (onbreak(_abort)) exit(0);

	if (ARGC == 4 || ARGC == 3)
	{
		strcpy(libname, ARGV[1]);
		strupr(libname);             /* Convert to upper case */
		sprintf(FDname, "FD:%s_lib.fd", ARGV[1]);
		strcpy(sourcename, ARGV[2]);
		if (ARGC == 4) strcpy(destname, ARGV[3]);
		else           strcpy(destname, "IRAdummy.s");
		sprintf(incname, "IRA_%s.i", libname);
	}
	else Explain(ARGV[0]);

	if (!(sourcefile = fopen(sourcename, "r")))
		ExitPrg("Couldn't open %s", sourcename);

	if (!(destfile = fopen(destname, "w")))
		ExitPrg("Couldn't write to %s", destfile);

	if (!(incfile = fopen(incname, "w")))
		ExitPrg("Couldn't write to %s", incname);
}
/*****************************************************************************/
void ExitPrg(char *errtext, ...)
{
va_list arguments;
int i;

	if (errtext) {
		va_start(arguments,errtext);
		vprintf(errtext,arguments);
		printf("\n");
		va_end(arguments);
	}

	if (sourcefile) fclose(sourcefile);
	if (destfile)   fclose(destfile);
	if (incfile)    fclose(incfile);

	if (LibCallNames) {
		for(i=0;i<LIB_CALLS;i++) FreeMem(LibCallNames[i], strlen(LibCallNames[i]) + 1);
		FreeMem(LibCallNames, LIB_CALLS*sizeof(char **));
	}
	if (LibCallOffs)  FreeMem(LibCallOffs,  LIB_CALLS*sizeof(int));
	if (LibCallFlags) FreeMem(LibCallFlags, LIB_CALLS*sizeof(int));

	exit(0);
}
/*****************************************************************************/
void Explain(char *exename)
{
	printf("\nIRA PostProcessor v"VERSION"."REVISION" by Tim Ruehsen. Idea by Morten Eriksen.\n\n");
	printf("Usage: %s libname sourcefile [destfile]\n\n",exename);
	printf("'libname'    name of library who's calls are searched for.\n");
	printf("'sourcefile' must be an assembly sourcefile produced by IRA v1.xx.\n");
	printf("'destfile'   is where you want to save the new, processed assembly sourcefile.\n\n");
	ExitPrg(0);
}
/*****************************************************************************/
