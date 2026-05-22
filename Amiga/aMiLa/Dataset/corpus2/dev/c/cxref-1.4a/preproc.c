/***************************************
  $Header: /home/amb/cxref/RCS/preproc.c 1.13 1997/07/25 19:10:11 amb Exp $

  C Cross Referencing & Documentation tool. Version 1.4a.

  Collects the pre-processing instruction stuff.
  ******************/ /******************
  Written by Andrew M. Bishop

  This file Copyright 1995,96,97 Andrew M. Bishop
  It may be distributed under the GNU Public License, version 2, or
  any higher version.  See section COPYING of the GNU Public license
  for conditions under which this file may be redistributed.
  ***************************************/

/*+ Control the output of debugging information for this file. +*/
#define DEBUG 0

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/stat.h>

#ifdef AMIGA /* olsen */
#include "amiga.h"
#endif /* AMIGA */

#include "memory.h"
#include "datatype.h"
#include "cxref.h"

/*+ The file that is currently being processed. +*/
extern File CurFile;

/*+ The name of the include directories specified on the command line. +*/
extern char **option_incdirs;

/*+ The number of include directories on the command line. +*/
extern int option_nincdirs;

/*+ When in a header file, this is set to 1, to allow most of the stuff to be skipped. +*/
int in_header=0;

/*+ The current #include we are looking at. +*/
static Include cur_inc=NULL;

/*+ The current #define we are looking at. +*/
static Define cur_def=NULL;

/*+ The depth of includes. +*/
static int inc_depth=0;

/*+ The type of include at this depth. +*/
static char *inc_type=NULL;

/*+ The working directory. +*/
static char *cwd=NULL;


static Include NewIncludeType(char *name);
static Define NewDefineType(char *name);


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when an included file is seen in the current file.

  char *name The name of the file from the source code.
  ++++++++++++++++++++++++++++++++++++++*/

void SeenInclude(char *name)
{
#if DEBUG
 printf("#Preproc.c# #include %s\n",name);
#endif

 if(!inc_type || inc_depth==0 || inc_type[inc_depth-1]==LOCAL)
   {
    Include inc,*t=&CurFile->includes;
    int inc_scope=(*name=='"')?LOCAL:GLOBAL;
    int i;

    name++;
    name[strlen(name)-1]=0;

    if(inc_scope==LOCAL && option_nincdirs)
       for(i=0;i<option_nincdirs;i++)
         {
          char *newname=CanonicaliseName(ConcatStrings(3,option_incdirs[i],"/",name));
          struct stat buf;

          if(!lstat(newname,&buf))
            {name=newname;break;}
         }

    for(i=0;i<inc_depth;i++)
      {
       while(*t && (*t)->next)
          t=&(*t)->next;
       t=&(*t)->includes;
      }

    inc=NewIncludeType(name);

    inc->comment=MallocString(GetCurrentComment());
    inc->scope=inc_scope;

    AddToLinkedList(*t,Include,inc);

    cur_inc=inc;
   }
 else
    cur_inc=NULL;
}


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when a comment is seen following a #include.
  ++++++++++++++++++++++++++++++++++++++*/

void SeenIncludeComment(void)
{
 char* comment=GetCurrentComment();

#if DEBUG
 printf("#Preproc.c# #include trailing comment '%s' for %s\n",comment,cur_inc->name);
#endif

 if(!cur_inc->comment)
    cur_inc->comment=MallocString(comment);
}


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when a change in current file is seen.

  char *name The pathname of the included file as determined by gcc.

  int flag The flags that GCC leaves in the file
  ++++++++++++++++++++++++++++++++++++++*/

void SeenFileChange(char *name,int flag)
{
 if(!cwd)
   {
    cwd=(char*)Malloc(256);
    if(!getcwd(cwd,255))
       cwd[0]=0;
   }

#if DEBUG
 printf("#Preproc.c# FileChange - %s %s (flag=%d)\n",flag&2?"Included ":"Return to",name,flag);
#endif

 name=CanonicaliseName(name);

 if(!strncmp(name,cwd,strlen(cwd)))
    name=name+strlen(cwd);

 /* Store the information. */

 if(flag&2 && (!inc_type || inc_depth==0 || inc_type[inc_depth-1]==LOCAL) && !cur_inc)
    if(flag&8)
       SeenInclude(ConcatStrings(3,"<",name,">"));
    else
       SeenInclude(ConcatStrings(3,"\"",name,"\""));

 cur_inc=NULL;

 if(flag&2)
   {
    inc_depth++;

    if(!inc_type)
       inc_type=(char*)Malloc(16);
    else
       if(!(inc_depth%16))
          inc_type=(char*)Realloc(inc_type,(unsigned)(inc_depth+16));

    if(inc_depth>1 && inc_type[inc_depth-2]==GLOBAL)
       inc_type[inc_depth-1]=GLOBAL;
    else
       inc_type[inc_depth-1]=(flag&8)?GLOBAL:LOCAL;
   }
 else
    inc_depth--;

 if(inc_type && inc_depth>0)
    in_header=inc_type[inc_depth-1];
 else
    in_header=0;
}


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when a #define is seen in the current file.

  char* name The name of the #defined symbol.
  ++++++++++++++++++++++++++++++++++++++*/

void SeenDefine(char* name)
{
 Define def;

#if DEBUG
 printf("#Preproc.c# Defined name '%s'\n",name);
#endif

 def=NewDefineType(name);

 def->comment=MallocString(GetCurrentComment());

 AddToLinkedList(CurFile->defines,Define,def);

 cur_def=def;
}


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when a comment is seen in a #define definition.
  ++++++++++++++++++++++++++++++++++++++*/

void SeenDefineComment(void)
{
 char* comment=GetCurrentComment();

#if DEBUG
 printf("#Preproc.c# #define inline comment '%s' in %s\n",comment,cur_def->name);
#endif

 if(!cur_def->comment)
    cur_def->comment=MallocString(comment);
}


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when a #define value is seen in the current file.

  char* value The value of the #defined symbol.
  ++++++++++++++++++++++++++++++++++++++*/

void SeenDefineValue(char* value)
{
#if DEBUG
 printf("#Preproc.c# #define value '%s' for %s\n",value,cur_def->name);
#endif

 cur_def->value=MallocString(value);
}


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when a #define function argument is seen in the current definition.

  char* name The argument.
  ++++++++++++++++++++++++++++++++++++++*/

void SeenDefineFunctionArg(char* name)
{
#if DEBUG
 printf("#Preproc.c# #define Function arg '%s' in %s()\n",name,cur_def->name);
#endif

 AddToStringList2(cur_def->args,name,SplitComment(&cur_def->comment,name),0,0);
}


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when a comment is seen in a #define function definition.
  ++++++++++++++++++++++++++++++++++++++*/

void SeenDefineFuncArgComment(void)
{
 char* comment=GetCurrentComment();

#if DEBUG
 printf("#Preproc.c# #define Function arg comment '%s' in %s()\n",comment,cur_def->name);
#endif

 if(!cur_def->args->s2[cur_def->args->n-1])
    cur_def->args->s2[cur_def->args->n-1]=MallocString(comment);
}


/*++++++++++++++++++++++++++++++++++++++
  Tidy up all of the local variables in case of a problem and abnormal parser termination.
  ++++++++++++++++++++++++++++++++++++++*/

void ResetPreProcAnalyser(void)
{
 in_header=0;

 cur_inc=NULL;
 cur_def=NULL;

 inc_depth=0;

 if(inc_type) Free(inc_type);
 inc_type=NULL;

 if(cwd) Free(cwd);
 cwd=NULL;
}


/*++++++++++++++++++++++++++++++++++++++
  Create a new Include datatype.

  Include NewIncludeType Return the new Include type.

  char *name The name of the new include.
  ++++++++++++++++++++++++++++++++++++++*/

static Include NewIncludeType(char *name)
{
 Include inc=(Include)Calloc(1,sizeof(struct _Include));

 inc->name=MallocString(name);

 return(inc);
}


/*++++++++++++++++++++++++++++++++++++++
  Delete the specified Include type.

  Include inc The Include type to be deleted.
  ++++++++++++++++++++++++++++++++++++++*/

void DeleteIncludeType(Include inc)
{
 if(inc->comment) Free(inc->comment);
 if(inc->name)    Free(inc->name);
 if(inc->includes)
   {
    Include p=inc->includes;
    do{
       Include n=p->next;
       DeleteIncludeType(p);
       p=n;
      }
    while(p);
   }
 Free(inc);
}


/*++++++++++++++++++++++++++++++++++++++
  Create a new Define datatype.

  Define NewDefineType Return the new Define type.

  char *name The name of the new define.
  ++++++++++++++++++++++++++++++++++++++*/

static Define NewDefineType(char *name)
{
 Define def=(Define)Calloc(1,sizeof(struct _Define));

 def->name=MallocString(name);
 def->args=NewStringList2();

 return(def);
}


/*++++++++++++++++++++++++++++++++++++++
  Delete the specified Define type.

  Define def The Define type to be deleted.
  ++++++++++++++++++++++++++++++++++++++*/

void DeleteDefineType(Define def)
{
 if(def->comment) Free(def->comment);
 if(def->name)    Free(def->name);
 if(def->value)   Free(def->value);
 if(def->args)    DeleteStringList2(def->args);
 Free(def);
}
