/***************************************
  $Header: /home/amb/cxref/RCS/comment.c 1.16 1997/11/20 20:14:20 amb Exp $

  C Cross Referencing & Documentation tool. Version 1.4a.

  Collects the comments from the parser.
  ******************/ /******************
  Written by Andrew M. Bishop

  This file Copyright 1995,96 Andrew M. Bishop
  It may be distributed under the GNU Public License, version 2, or
  any higher version.  See section COPYING of the GNU Public license
  for conditions under which this file may be redistributed.
  ***************************************/

/*+ Turn on the debugging in this file. +*/
#define DEBUG 0

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "memory.h"
#include "datatype.h"
#include "cxref.h"

#ifdef AMIGA	/* olsen */
#include "amiga.h"
#endif /* AMIGA */

static void TidyCommentString(char **string);


/*+ The file that is currently being processed. +*/
extern File CurFile;

/*+ The current (latest comment). +*/
static char* cur_comment=NULL;


/*++++++++++++++++++++++++++++++++++++++
  Function that is called when a comment or part of one is seen. The comment is built up until an end of comment is signaled.

  char* c The comment text. If c==0 then it is a file (/ * * comment * * /) comment
                            if c==1 then it is the other special comment (/ * + comment + * /).
                            if c==2 then it is a normal comment (/ * comment * /).
                            if c==3 then it is not a comment.
  ++++++++++++++++++++++++++++++++++++++*/

void SeenComment(char* c)
{
 static int comment_ended=0;

 switch((int)c)
   {
   case 0:
#if DEBUG
    printf("#Comment.c# Seen comment /**\n%s\n**/\n",cur_comment);
#endif
    TidyCommentString(&cur_comment);
    if(!CurFile->comment)
       SeenFileComment(cur_comment);
    cur_comment=NULL;
    comment_ended=1;
    break;

   case 1:
#if DEBUG
    printf("#Comment.c# Seen comment /*+\n%s\n+*/\n",cur_comment);
#endif
    TidyCommentString(&cur_comment);
    if(SeenFuncIntComment(cur_comment))
       cur_comment=NULL;
    comment_ended=1;
    break;

   case 2:
#if DEBUG
    printf("#Comment.c# Seen comment /*\n%s\n*/\n",cur_comment);
#endif
    TidyCommentString(&cur_comment);
    if(!CurFile->comment)
      {SeenFileComment(cur_comment); cur_comment=NULL;}
    comment_ended=1;
    break;

   case 3:
    comment_ended=0; cur_comment=NULL;
    break;

   default:
    if(comment_ended)
      {comment_ended=0; cur_comment=NULL;}

    cur_comment=ConcatStrings(2,cur_comment,c);
   }
}


/*++++++++++++++++++++++++++++++++++++++
  Provide the current (latest) comment.

  char* GetCurrentComment Returns the current (latest) comment.
  ++++++++++++++++++++++++++++++++++++++*/

char* GetCurrentComment(void)
{
 char* c=cur_comment;

#if DEBUG
    printf("#Comment.c# GetCurrentComment returns <<<%s>>>\n",cur_comment);
#endif

 cur_comment=NULL;

 return(c);
}


/*++++++++++++++++++++++++++++++++++++++
  Set the current (latest) comment.

  char* comment The comment.
  ++++++++++++++++++++++++++++++++++++++*/

void SetCurrentComment(char* comment)
{
#if DEBUG
    printf("#Comment.c# SetCurrentComment set to <<<%s>>>\n",comment);
#endif

 cur_comment=comment;
}


/*++++++++++++++++++++++++++++++++++++++
  A function to split out the arguments etc from a comment,
  for example the function argument comments are separated using this.

  char* SplitComment Returns the required comment.

  char** original A pointer to the original comment, this is altered in the process.

  char* name The name that is to be cut out from the comment.

  A most clever function that ignores spaces so that 'char* b' and 'char *b' match.
  ++++++++++++++++++++++++++++++++++++++*/

char* SplitComment(char** original,char* name)
{
 char* c=NULL;

 if(*original)
   {
    int l=strlen(name);
    c=*original;

    do{
       int i,j,failed=0;
       char* start=c;

       while(c[0]=='\n')
          c++;

       for(i=j=0;i<l;i++,j++)
         {
          while(name[i]==' ') i++;
          while(c[j]==' ') j++;

          if(!c[j] || name[i]!=c[j])
            {failed=1;break;}
         }

       if(!failed)
         {
          char* old=*original;
          char* end=strstr(c,"\n\n");
          *start=0;
          if(end)
             *original=MallocString(ConcatStrings(2,*original,end));
          else
             if(start==*original)
                *original=NULL;
             else
                *original=MallocString(*original);
          if(end)
             *end=0;
          c=CopyString(&c[j+1]);
          Free(old);
          break;
         }
      }
    while((c=strstr(c,"\n\n")));
   }

 return(c);
}


/*++++++++++++++++++++++++++++++++++++++
  Tidy up the current comment string by snipping off trailing and leading junk.

  char **string The string that is to be tidied.
  ++++++++++++++++++++++++++++++++++++++*/

static void TidyCommentString(char **string)
{
 int whitespace;
 char *to=*string,*from=*string,*str;

 if(!*string)
    return;

 /* Remove CR characters. */

 while(*from)
   {
    if(*from=='\r')
       from++;
    else
       *to++=*from++;
   }
 *to=0;

 /* Remove leading blank lines. */

 whitespace=1;
 str=*string;
 do
   {
    if(*str!='\n')
       do
         {
          if(*str!=' ' && *str!='\t')
             whitespace=0;
         }
       while(*str && *++str!='\n');

    if(whitespace)
       *string=++str;
   }
 while(whitespace);

 /* Remove trailing blank lines. */

 whitespace=1;
 str=*string+strlen(*string)-1;
 do
   {
    if(*str!='\n')
       do
         {
          if(*str!=' ' && *str!='\t')
             whitespace=0;
         }
       while(str>*string && *--str!='\n');

    if(whitespace)
       *str--=0;
   }
 while(whitespace);

 /* Replace lines containing just whitespace with empty lines. */

 str=*string;
 do
   {
    char *start;

    whitespace=1;

    while(*str=='\n')
       str++;

    start=str;

    while(*str && *++str!='\n')
       {
        if(*str!=' ' && *str!='\t')
           whitespace=0;
       }

    if(whitespace)
      {
       char *copy=start;

       while((*start++=*str++));

       str=copy;
      }
   }
 while(*str);
}
