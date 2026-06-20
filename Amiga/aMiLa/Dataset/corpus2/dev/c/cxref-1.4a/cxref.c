/***************************************
  $Header: /home/amb/cxref/RCS/cxref.c 1.35 1997/11/20 19:57:39 amb Exp $

  C Cross Referencing & Documentation tool. Version 1.4a.
  ******************/ /******************
  Written by Andrew M. Bishop

  This file Copyright 1995,96,97 Andrew M. Bishop
  It may be distributed under the GNU Public License, version 2, or
  any higher version.  See section COPYING of the GNU Public license
  for conditions under which this file may be redistributed.
  ***************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#ifndef __SASC	/* olsen: does not exist with SAS/C */
#include <sys/wait.h>
#endif /* __SASC */
#include <sys/stat.h>
#include <unistd.h>

#ifdef AMIGA	/* olsen */
#include "amiga.h"
#endif /* AMIGA */

#include "parse-yy.h"
#include "memory.h"
#include "datatype.h"
#include "cxref.h"

/*+ The default value of the CPP command. +*/
#ifdef CXREF_CPP
#define CPP_COMMAND CXREF_CPP
#else
#define CPP_COMMAND "gcc -E -C -dD -dI"
#endif

/*+ The name of the file to read the configuration from. +*/
#define CXREF_CONFIG_FILE ".cxref"


static void Usage(int verbose);
static int ParseConfigFile(void);
static int ParseOptions(int nargs,char **args,int is_argv);

static int DocumentTheFile(char* name);
static FILE* popen_execvp(char** command);
static int pclose_execvp(FILE* f);

static char** cpp_command;              /*+ The actual cpp command that is built up, adding -D, -U and -I options. +*/
static int cpp_command_num=0;           /*+ The number of arguments to the cpp command. +*/

/*+ The command line switch that sets the format of the output, +*/
int option_all_comments=0,              /*+ use all comments. +*/
    option_verbatim_comments=0,         /*+ insert the comments verbatim into the output. +*/
    option_block_comments=0,            /*+ remove the leading block comment marker. +*/
    option_no_comments=0,               /*+ ignore all comments. +*/
    option_xref=0,                      /*+ do cross referencing. +*/
    option_warn=0,                      /*+ produce warnings. +*/
    option_index=0,                     /*+ produce an index. +*/
    option_raw=0,                       /*+ produce raw output. +*/
    option_latex=0,                     /*+ produce latex output. +*/
    option_html=0;                      /*+ produce html output. +*/

/*+ The option to control the mode of operation. +*/
int option_delete=0;

/*+ The command line switch for the output name, +*/
char *option_odir=".",                  /*+ the directory to use. +*/
     *option_name="cxref",              /*+ the base part of the name. +*/
     *option_root=NULL;                 /*+ the source tree root directory. +*/

/*+ The name of the include directories specified on the command line. +*/
char **option_incdirs=NULL;

/*+ The number of include directories on the command line. +*/
int option_nincdirs=0;

/*+ The current file that is being processed. +*/
File CurFile=NULL;


/*++++++++++++++++++++++++++++++++++++++
  The main function that calls the parser.

  int main Returns the status, zero for normal termination, else an error.

  int argc The command line number of arguments.

  char** argv The actual command line arguments
  ++++++++++++++++++++++++++++++++++++++*/

int main(int argc,char** argv)
{
 int i;
 char *root_prefix=NULL;

 #ifdef AMIGA /* olsen */
 {
   expand_args(argc,argv,&argc,&argv,0,1);
 }
 #endif /* AMIGA */

 if(argc==1)
    Usage(1);

 cpp_command=(char**)Malloc(8*sizeof(char*));
 cpp_command[cpp_command_num++]=MallocString(CPP_COMMAND);

 for(i=1;i<strlen(CPP_COMMAND);i++)
    if(cpp_command[0][i]==' ')
       cpp_command[0][i]=0;
    else
       if(cpp_command[0][i-1]==0)
         {
          if((cpp_command_num%8)==6)
             cpp_command=(char**)Realloc(cpp_command,(cpp_command_num+10)*sizeof(char*));
          cpp_command[cpp_command_num++]=&cpp_command[0][i];
         }

 option_incdirs=(char**)Malloc(8*sizeof(char*));
 option_incdirs[0]=".";
 option_nincdirs=1;

 /* Parse the command line options. */

 if(ParseOptions(argc-1,&argv[1],1))
    Usage(0);

 /* Parse the options in .cxref in this directory. */

 if(ParseConfigFile())
    Usage(0);

 /* Change directory. */

 if(option_root)
   {
    char *here=(char*)Malloc(512),*there=(char*)Malloc(512);

    if(!getcwd(there,255))
      {fprintf(stderr,"cxref: Error cannot get current working directory (1).\n");exit(1);}
    if(chdir(option_root))
      {fprintf(stderr,"cxref: Error cannot change directory to '%s'.\n",option_root);exit(1);}
    if(!getcwd(here,255))
      {fprintf(stderr,"cxref: Error cannot get current working directory (2).\n");exit(1);}

    if(!strncmp(here,there,strlen(here)))
       root_prefix=there+strlen(here)+1;
    else
      {fprintf(stderr,"cxref: Error the -R option has not specified a parent directory of the current one.\n");exit(1);}

    for(i=1;i<cpp_command_num;i++)
       if(cpp_command[i][0]=='-' && cpp_command[i][1]=='I')
         {
          if(cpp_command[i][2]==0)
            {
             if(cpp_command[++i][0]!='/')
                cpp_command[i]=MallocString(CanonicaliseName(ConcatStrings(3,root_prefix,"/",cpp_command[i])));
            }
          else if(cpp_command[i][2]!='/')
             cpp_command[i]=MallocString(ConcatStrings(2,"-I",CanonicaliseName(ConcatStrings(3,root_prefix,"/",cpp_command[i]+2))));
         }

    for(i=0;i<option_nincdirs;i++)
       if(*option_incdirs[i]!='/')
          option_incdirs[i]=MallocString(CanonicaliseName(ConcatStrings(3,root_prefix,"/",option_incdirs[i])));

    if(ParseConfigFile())
       Usage(0);
   }

 /* Process each file. */

 for(i=1;i<argc;i++)
    if(argv[i])
      {
       char *filename=CanonicaliseName(root_prefix?ConcatStrings(3,root_prefix,"/",argv[i]):argv[i]);

       if(!option_delete)
         {
          CurFile=NewFile(filename);

          if(!DocumentTheFile(filename))
            {
             if(option_xref)
                CrossReference(CurFile);

             if(option_raw || option_warn)
                WriteWarnRawFile(CurFile);
             if(option_latex)
                WriteLatexFile(CurFile);
             if(option_html)
                WriteHTMLFile(CurFile);
            }

          ResetLexer();
          ResetParser();
          ResetPreProcAnalyser();
          ResetTypeAnalyser();
          ResetVariableAnalyser();
          ResetFunctionAnalyser();

          DeleteFile(CurFile);
          CurFile=NULL;
         }
       else
         {
          CrossReferenceDelete(filename);

          WriteLatexFileDelete(filename);
          WriteHTMLFileDelete(filename);
         }

       TidyMemory();
      }

 /* Create the index */

 if(option_index)
   {
    StringList files;
    StringList2 funcs,vars,types;

    files=NewStringList();
    funcs=NewStringList2();
    vars=NewStringList2();
    types=NewStringList2();

    CreateAppendix(files,funcs,vars,types);

    if(option_raw||option_warn)
       WriteWarnRawAppendix(files,funcs,vars,types);
    if(option_latex)
       WriteLatexAppendix(files,funcs,vars,types);
    if(option_html)
       WriteHTMLAppendix(files,funcs,vars,types);

    DeleteStringList(files);
    DeleteStringList2(funcs);
    DeleteStringList2(vars);
    DeleteStringList2(types);

    TidyMemory();
   }

 /* Tidy up */

 Free(cpp_command[0]);
 Free(cpp_command);

 Free(option_incdirs);

 PrintMemoryStatistics();

 return(0);
}


/*++++++++++++++++++++++++++++++++++++++
  Print out the usage instructions.

  int verbose If true then output a long version of the information.
  ++++++++++++++++++++++++++++++++++++++*/

static void Usage(int verbose)
{
 fputs("\n"
       "              C Cross Referencing & Documenting tool - Version 1.4a\n"
       "              -----------------------------------------------------\n"
       "\n"
       "(c) Andrew M. Bishop 1995,96,97  [       amb@gedanken.demon.co.uk ]\n"
       "                                 [http://www.gedanken.demon.co.uk/]\n"
       "\n"
       "Usage: cxref filename [ ... filename]\n"
       "             [-Odirname] [-Nbasename] [-Rdirname]\n"
       "             [-all-comments] [-no-comments]\n"
       "             [-verbatim-comments] [-block-comments]\n"
       "             [-xref[-all][-file][-func][-var][-type]]\n"
       "             [-warn[-all][-comment][-xref]]\n"
       "             [-index[-all][-file][-func][-var][-type]]\n"
       "             [-raw] [-latex|-latex2e] [-html]\n"
       "             [-Idirname] [-Ddefine] [-Udefine]\n"
       "             [-CPP cpp_program] [-- cpp_arg [ ... cpp_arg]]\n"
       "\n"
       "Usage: cxref filename [ ... filename] -delete\n"
       "             [-Odirname] [-Nbasename] [-Rdirname]\n"
       "\n",
       stderr);

 if(verbose)
    fputs("filename ...           : Files to document.\n"
          "-delete                : Delete all references to the named files.\n"
          "\n"
          "-Odirname              : The output directory for the documentation.\n"
          "-Nbasename             : The base filename for the output documentation.\n"
          "-Rdirname              : The root directory of the source tree.\n"
          "\n"
          "-all-comments          : Use all comments.\n"
          "-verbatim-comments     : Insert the comments verbatim in the output.\n"
          "-block-comments        : The comments are in block style.\n"
          "-no-comments           : Ignore all of the comments.\n"
          "\n"
          "-xref[-*]              : Do cross referencing (of specified types).\n"
          "-warn[-*]              : Produce warnings (of comments or cross references).\n"
          "\n"
          "-index[-*]             : Produce a cross reference index (of specified types).\n"
          "\n"
          "-raw                   : Produce raw output.\n"
          "-latex | -latex2e      : Produce LaTeX output (version 2.09 or 2e).\n"
          "-html                  : Produce HTML output (version 2.0).\n"
          "\n"
          "-I*, -D*, -U*          : The usual compiler switches.\n"
          "-CPP cpp_program       : The cpp program to use.\n"
          "                       : (default '" CPP_COMMAND "')\n"
          "-- cpp_arg ...         : All arguments after the '--' are passed to cpp.\n"
          "\n"
          "The file .cxref in the current directory can also contain any of these arguments\n"
          "one per line, (except for filename and -delete).\n",
          stderr);
 else
    fputs("Run cxref with no arguments to get more verbose help\n",
          stderr);

 exit(1);
}


/*++++++++++++++++++++++++++++++++++++++
  Read in the options from the configuration file.

  int ParseConfigFile Returns the values returned by ParseOptions().
  ++++++++++++++++++++++++++++++++++++++*/

static int ParseConfigFile(void)
{
 FILE *file=fopen(CXREF_CONFIG_FILE,"r");
 char **lines=NULL;
 int nlines=0;
 char data[129];

 if(file)
   {
    while(fgets(data,80,file))
      {
       char *d=data+strlen(data)-1;

       if(*data=='#')
          continue;

       while(d>=data && (*d=='\r' || *d=='\n' || *d==' '))
          *d--=0;

       if(d<data)
          continue;

       if(!lines)
          lines=(char**)Malloc(8*sizeof(char*));
       else if((nlines%8)==7)
          lines=(char**)Realloc(lines,(nlines+9)*sizeof(char*));

       if((!strncmp(data,"-I",2) || !strncmp(data,"-D",2) || !strncmp(data,"-U",2) ||
           !strncmp(data,"-O",2) || !strncmp(data,"-N",2) || !strncmp(data,"-R",2)) &&
          (data[2]==' ' || data[2]=='\t'))
         {
          int i=2;
          while(data[i]==' ' || data[i]=='\t')
             data[i++]=0;
          lines[nlines++]=MallocString(data);
          lines[nlines++]=MallocString(data+i);
         }
       else if(!strncmp(data,"-CPP",4) &&
               (data[4]==' ' || data[4]=='\t'))
         {
          int i=4;
          while(data[i]==' ' || data[i]=='\t')
             data[i++]=0;
          lines[nlines++]=MallocString(data);
          lines[nlines++]=MallocString(data+i);
         }
       else
          if(*data)
             lines[nlines++]=MallocString(data);
      }

    if(nlines)
      {
       if(ParseOptions(nlines,lines,0))
          return(1);

       Free(lines);
      }

    fclose(file);
   }

 return(0);
}

/*++++++++++++++++++++++++++++++++++++++
  Parse the options from the command line or from the .cxref file.

  int ParseOptions Return 1 if there is an error.

  int nargs The number of arguments.

  char **args The actual arguments

  int is_argv Set to true if these are the argc,argv values.
  ++++++++++++++++++++++++++++++++++++++*/

static int ParseOptions(int nargs,char **args,int is_argv)
{
 int i,end_of_args=0;
 int cpp_original_num=cpp_command_num;

 for(i=0;i<nargs;i++)
   {
    if(end_of_args)
      {
       if((cpp_command_num%8)==6)
          cpp_command=(char**)Realloc(cpp_command,(cpp_command_num+10)*sizeof(char*));
       cpp_command[cpp_command_num++]=args[i];
       if(is_argv) args[i]=NULL;
       continue;
      }

    if(!strncmp(args[i],"-I",2) || !strncmp(args[i],"-D",2) || !strncmp(args[i],"-U",2))
      {
       char *incdir=NULL;
       if((cpp_command_num%8)==6)
          cpp_command=(char**)Realloc(cpp_command,(cpp_command_num+10)*sizeof(char*));
       cpp_command[cpp_command_num++]=args[i];
       if(args[i][2]==0)
         {
          if(args[i][1]=='I')
             incdir=args[i+1];
          if(i==nargs-1)
            {fprintf(stderr,"cxref: The -%c option requires a following argument.\n",args[i][1]);return(1);}
          if(is_argv) args[i]=NULL;
          if((cpp_command_num%8)==6)
             cpp_command=(char**)Realloc(cpp_command,(cpp_command_num+10)*sizeof(char*));
          cpp_command[cpp_command_num++]=args[++i];
         }
       else
          if(args[i][1]=='I')
             incdir=&args[i][2];
       if(is_argv) args[i]=NULL;

       if(incdir)
         {
          if((option_nincdirs%8)==0)
             option_incdirs=(char**)Realloc(option_incdirs,(option_nincdirs+8)*sizeof(char*));
          option_incdirs[option_nincdirs++]=incdir;
         }
       continue;
      }

    if(!strcmp(args[i],"-CPP"))
      {
       char **old=cpp_command,*command;
       int j,old_num=cpp_command_num;

       if(args[i][4]==0)
         {
          if(i==nargs-1)
            {fprintf(stderr,"cxref: The -CPP option requires a following argument.\n");return(1);}
          if(is_argv) args[i]=NULL;
          command=args[++i];
         }
       else
          command=&args[i][4];

       cpp_command_num=0;
       cpp_command=(char**)Malloc(8*sizeof(char*));
       cpp_command[cpp_command_num++]=MallocString(command);

       for(j=1;j<strlen(command);j++)
          if(cpp_command[0][j]==' ')
             cpp_command[0][j]=0;
          else
             if(cpp_command[0][j-1]==0)
               {
                if((cpp_command_num%8)==6)
                   cpp_command=(char**)Realloc(cpp_command,(cpp_command_num+10)*sizeof(char*));
                cpp_command[cpp_command_num++]=&cpp_command[0][j];
               }

       for(j=cpp_original_num;j<old_num;j++)
         {
          if((cpp_command_num%8)==6)
             cpp_command=(char**)Realloc(cpp_command,(cpp_command_num+10)*sizeof(char*));
          cpp_command[cpp_command_num++]=old[j];
         }

       cpp_original_num=cpp_command_num;
       Free(old[0]); Free(old);

       if(is_argv) args[i]=NULL;
       continue;
      }

    if(!strncmp(args[i],"-O",2))
      {
       if(args[i][2]==0)
         {
          if(i==nargs-1)
            {fprintf(stderr,"cxref: The -O option requires a following argument.\n");return(1);}
          if(is_argv) args[i]=NULL;
          option_odir=args[++i];
         }
       else
          option_odir=&args[i][2];
       if(is_argv) args[i]=NULL;
       continue;
      }

    if(!strncmp(args[i],"-N",2))
      {
       if(args[i][2]==0)
         {
          if(i==nargs-1)
            {fprintf(stderr,"cxref: The -N option requires a following argument.\n");return(1);}
          if(is_argv) args[i]=NULL;
          option_name=args[++i];
         }
       else
          option_name=&args[i][2];
       if(is_argv) args[i]=NULL;
       continue;
      }

    if(!strncmp(args[i],"-R",2))
      {
       if(args[i][2]==0)
         {
          if(i==nargs-1)
            {fprintf(stderr,"cxref: The -R option requires a following argument.\n");return(1);}
          if(is_argv) args[i]=NULL;
          option_root=args[++i];
         }
       else
          option_root=&args[i][2];
       if(is_argv) args[i]=NULL;
       continue;
      }

    if(!strcmp(args[i],"-delete"))
      {option_delete=1; if(is_argv)args[i]=NULL; continue;}

    if(!strcmp(args[i],"-all-comments"))
      {option_all_comments=1; if(is_argv)args[i]=NULL; continue;}

    if(!strcmp(args[i],"-verbatim-comments"))
      {option_verbatim_comments=1; if(is_argv)args[i]=NULL; continue;}

    if(!strcmp(args[i],"-block-comments"))
      {option_block_comments=1; if(is_argv)args[i]=NULL; continue;}

    if(!strcmp(args[i],"-no-comments"))
      {option_no_comments=1; if(is_argv)args[i]=NULL; continue;}

    if(!strncmp(args[i],"-xref",5))
      {
       char* p=&args[i][5];

       if(!*p)
          option_xref=XREF_ALL;
       else
          while(*p)
            {
             if(!strncmp(p,"-all" ,4)) {option_xref|=XREF_ALL ; p=&p[4]; continue;}
             if(!strncmp(p,"-file",5)) {option_xref|=XREF_FILE; p=&p[5]; continue;}
             if(!strncmp(p,"-func",5)) {option_xref|=XREF_FUNC; p=&p[5]; continue;}
             if(!strncmp(p,"-var" ,4)) {option_xref|=XREF_VAR ; p=&p[4]; continue;}
             if(!strncmp(p,"-type",5)) {option_xref|=XREF_TYPE; p=&p[5]; continue;}
             break;
            }
       if(is_argv) args[i]=NULL;
       continue;
      }

    if(!strncmp(args[i],"-warn",5))
      {
       char* p=&args[i][5];

       if(!*p)
          option_warn=WARN_ALL;
       else
          while(*p)
            {
             if(!strncmp(p,"-all"    ,4)) {option_warn|=WARN_ALL    ; p=&p[4]; continue;}
             if(!strncmp(p,"-comment",8)) {option_warn|=WARN_COMMENT; p=&p[8]; continue;}
             if(!strncmp(p,"-xref"   ,5)) {option_warn|=WARN_XREF   ; p=&p[5]; continue;}
             break;
            }
       if(is_argv) args[i]=NULL;
       continue;
      }

    if(!strncmp(args[i],"-index",6))
      {
       char* p=&args[i][6];

       if(!*p)
          option_index=INDEX_ALL;
       else
          while(*p)
            {
             if(!strncmp(p,"-all" ,4)) {option_index|=INDEX_ALL ; p=&p[4]; continue;}
             if(!strncmp(p,"-file",5)) {option_index|=INDEX_FILE; p=&p[5]; continue;}
             if(!strncmp(p,"-func",5)) {option_index|=INDEX_FUNC; p=&p[5]; continue;}
             if(!strncmp(p,"-var" ,4)) {option_index|=INDEX_VAR ; p=&p[4]; continue;}
             if(!strncmp(p,"-type",5)) {option_index|=INDEX_TYPE; p=&p[5]; continue;}
             break;
            }
       if(is_argv) args[i]=NULL;
       continue;
      }

    if(!strcmp(args[i],"-raw"))
      {option_raw=1; if(is_argv)args[i]=NULL; continue;}

    if(!strcmp(args[i],"-latex"))
      {option_latex=1; if(is_argv)args[i]=NULL; continue;}
    if(!strcmp(args[i],"-latex2e"))
      {option_latex=2; if(is_argv)args[i]=NULL; continue;}

    if(!strcmp(args[i],"-html"))
      {option_html=1; if(is_argv)args[i]=NULL; continue;}

    if(!strcmp(args[i],"--"))
      {end_of_args=1; if(is_argv)args[i]=NULL; continue;}

    if(args[i][0]=='-')
      {fprintf(stderr,"cxref: Unknown option '%s'.\n",args[i]);return(1);}

    if(!is_argv)
      {fprintf(stderr,"cxref: File names '%s' only allowed on command line.\n",args[i]);return(1);}
   }

 if(option_warn&WARN_XREF && !option_xref)
    fprintf(stderr,"cxref: Warning using '-warn-xref' without '-xref'.\n");

 return(0);
}


/*++++++++++++++++++++++++++++++++++++++
  Canonicalise a file name by removing '/../', '/./' and '//' references.

  char *CanonicaliseName Returns the argument modified.

  char *name The original name
  ++++++++++++++++++++++++++++++++++++++*/

char *CanonicaliseName(char *name)
{
 char *match;

 while((match=strstr(name,"/../")))
   {
    char *prev=match; match+=4;
    while(prev>name && *--prev!='/');
    if(prev!=name)prev++;
    while((*prev++=*match++));
   }

 while((match=strstr(name,"/./")) || (match=strstr(name,"./"))==name)
   {
    char *prev=match; match+=(*match=='/')?3:2;
    while((*prev++=*match++));
   }

 while((match=strstr(name,"//")))
   {
    char *prev=match; match+=2;
    while((*prev++=*match++));
   }

 match=&name[strlen(name)-2];
 if(match>=name && !strcmp(match,"/."))
    *match=0;

 match=&name[strlen(name)-3];
 if(match>=name && !strcmp(match,"/.."))
    if(match==name)
       *match=0;
    else
       while(match>name && *--match!='/')
          *match=0;

 return(name);
}


/*++++++++++++++++++++++++++++++++++++++
  Calls CPP for the file to get all of the needed information.

  int DocumentTheFile Returns 1 in case of error, else 0.

  char* name The name of the file to document.

  The CPP is started as a sub-process, (using popen to return a FILE* for lex to use).
  ++++++++++++++++++++++++++++++++++++++*/

static int DocumentTheFile(char* name)
{
 struct stat stat_buf;
 int error1,error2;

 if(stat(name,&stat_buf)==-1)
   {fprintf(stderr,"cxref: Cannot access the file '%s'\n",name);return(1);}

 #ifdef AMIGA /* olsen */
 {
   printf("Documenting \"%s\"...\n",name);
 }
 #endif /* AMIGA */

 cpp_command[cpp_command_num  ]=name;
 cpp_command[cpp_command_num+1]=NULL;

 yyin=popen_execvp(cpp_command);

 if(!yyin)
   {fprintf(stderr,"cxref: Failed to start the cpp command\n");exit(1);}

 yyrestart(yyin);

#if YYDEBUG
 yydebug=(YYDEBUG==3);
#endif

 error1=yyparse();

 error2=pclose_execvp(yyin);

 #ifdef AMIGA /* olsen */
 {
   /* Perform garbage collection for the parser. */
   alloca(0);
 }
 #endif /* AMIGA */

 if(error2)
    fprintf(stderr,"cxref: The preprocessor exited abnormally on '%s'\n",name);

 return(error1||error2);
}

#ifndef AMIGA /* olsen */
/*+ The process id of the pre-processor. +*/
static int popen_pid;

/*++++++++++++++++++++++++++++++++++++++
  A popen function that takes a list of arguments not a string.

  FILE* popen_execvp Returns a file descriptor.

  char** command The command arguments.
  ++++++++++++++++++++++++++++++++++++++*/

static FILE* popen_execvp(char** command)
{
 int fdr[2];

 if(pipe(fdr)==-1)
   {fprintf(stderr,"cxref: Can not pipe for the cpp command.\n");exit(1);}

 if((popen_pid=fork())==-1)
   {fprintf(stderr,"cxref: Can not fork for the cpp command.\n");exit(1);}

 if(popen_pid)                   /* The parent */
   {
    close(fdr[1]);
   }
 else                            /* The child */
   {
    close(1);
    dup(fdr[1]);
    close(fdr[1]);

    close(fdr[0]);

    execvp(command[0],command);
    fprintf(stderr,"cxref: Can not execvp for the cpp command.\n");
    exit(1);
   }

 return(fdopen(fdr[0],"r"));
}


/*++++++++++++++++++++++++++++++++++++++
  Close the file to the to the preprocessor

  int pclose_execvp Return the error status.

  FILE* f The file to close.
  ++++++++++++++++++++++++++++++++++++++*/

static int pclose_execvp(FILE* f)
{
 int ret;

 waitpid(popen_pid,&ret,0);
 fclose(f);

 return(ret);
}
#endif /* AMIGA */
