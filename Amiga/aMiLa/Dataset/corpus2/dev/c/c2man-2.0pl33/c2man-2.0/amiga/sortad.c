/*
** $PROJECT:
**
** $VER: sortad.c 2.1 (22.01.95)
**
** by
**
** Stefan Ruppert , Windthorststraße 5 , 65439 Flörsheim , GERMANY
**
** (C) Copyright 1995
** All Rights Reserved !
**
** $HISTORY:
**
** 22.01.95 : 002.001 : initial
*/

/* ------------------------- version definitions -------------------------- */

/*FS*/ /* $STARTDEFINE: "BumpRev defines"*/
#define VERSION  2
#define REVISION 1
#define DATE "22.1.95"
#define VERS "sortad 2.1"
#define VSTRING "sortad 2.1 (22.1.95)\r\n"
#define VERSTAG "\0$VER: sortad 2.1 (22.1.95)"
/*FE*/ /* $ENDDEFINE:   */

/* ------------------------------- include -------------------------------- */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/lists.h>
#include <exec/nodes.h>

#include <dos/dos.h>

#include <clib/alib_stdio_protos.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>

#include <string.h>

struct AutoDoc
{
   struct Node ad_Node;
   BPTR ad_TempFile;
};

#define BUFFER_SIZE        1024

/* -------------------------- static data items --------------------------- */

static const STRPTR version = VERSTAG;
static const STRPTR prgname = "sortad";

/* ------------------------- template definition -------------------------- */

#define template    "FROM/M,TO,TEMPDIR/K,BASENAME/K"

enum {
   ARG_FROM,
   ARG_TO,
   ARG_TEMPDIR,
   ARG_BASENAME,
   ARG_MAX};

/* ---------------------- insert node sorted by name ---------------------- */

void insertbyname(struct List *list,struct Node *node);

void insertbyname(struct List *list,struct Node *node)
{
   struct Node *sn;
   struct Node *in = NULL;

   for(sn = list->lh_Head ; sn->ln_Succ ; sn = sn->ln_Succ)
   {
      if(Stricmp(sn->ln_Name,node->ln_Name) > 0)
      {
         in = sn->ln_Pred;
         if(!in->ln_Pred)
            in = NULL;
         break;
      }
   }

   if(!in && !sn->ln_Succ)
      in = sn->ln_Pred;

   Insert(list,node,in);
}

/* --------------------------- main entry point --------------------------- */

int main(void)
{
   struct RDArgs *args;
   ULONG para[ARG_MAX];
   STRPTR obj = prgname;
   LONG err = 0;

   LONG i;

   /* clear args buffer */
   for(i = 0 ; i < ARG_MAX ; i++)
      para[i] = 0;

   /* here set your defaults : para[ARG_#?] = default_value; */

   if((args = ReadArgs(template,(LONG *) para,NULL)))
   {
      struct List list;
      struct AutoDoc *ad;
      UBYTE *buf;
      UBYTE tmpname[50];
      ULONG task = (ULONG) FindTask(NULL);
      ULONG num = 0;
      ULONG len;
      BPTR tmpfh;
      BPTR infh  = NULL;
      BPTR outfh = NULL;
      STRPTR *files = NULL;
      STRPTR tmpdir = (para[ARG_TEMPDIR]) ? (STRPTR) para[ARG_TEMPDIR] : (STRPTR) "T:";
      STRPTR basename = (STRPTR) para[ARG_BASENAME];

      NewList(&list);

      if(!para[ARG_FROM])
         infh = Input();
      else
         files = (STRPTR *) para[ARG_FROM];

      if((buf = AllocVec(BUFFER_SIZE,MEMF_ANY)))
      {
         if(!para[ARG_TO])
            outfh = Output();
         else
            outfh = Open((STRPTR) para[ARG_TO],MODE_NEWFILE);

         if(outfh)
         {
            do
            {
               if(files && *files)
               {
                  infh = Open(*files,MODE_OLDFILE);
                  files++;
               }

               while(FGets(infh,buf,BUFFER_SIZE-1))
               {
                  sprintf(tmpname,"%ssortad%lx%lx",tmpdir,num++,task);
                  if((tmpfh = Open(tmpname,MODE_NEWFILE)))
                  {
                     STRPTR ptr = buf;

                     while(*ptr != ' ' && *ptr != '\n')
                        ptr++;
                     *ptr = '\0';

                     if(basename)
                     {
                        ptr = FilePart(buf);
                        len = strlen(basename) + 1;
                     } else
                     {
                        ptr = buf;
                        len = 0;
                     }

                     len += strlen(ptr) + 1;

                     if((ad = AllocVec(sizeof(struct AutoDoc) + len,MEMF_ANY)))
                     {
                        int ch;

                        ad->ad_Node.ln_Name = (STRPTR) (ad + 1);
                        ad->ad_TempFile     = tmpfh;
                        if(basename)
                           sprintf(ad->ad_Node.ln_Name,"%s/%s",basename,ptr);
                        else
                           strcpy(ad->ad_Node.ln_Name,ptr);

                        insertbyname(&list,&ad->ad_Node);

                        while((ch = FGetC(infh)) != '\f')
                           FPutC(tmpfh,ch);

                        if(ch == '\f')
                           FPutC(tmpfh,'\f');
                     } else
                     {
                        Close(tmpfh);
                        break;
                     }
                  } else
                     break;
               }

               if(files && infh)
               {
                  Close(infh);
                  infh = NULL;
               }
            } while(files && *files);

            FPuts(outfh,"TABLE OF CONTENTS\n\n");

            for(ad = (struct AutoDoc *) list.lh_Head ;
                ad->ad_Node.ln_Succ ;
                ad = (struct AutoDoc *) ad->ad_Node.ln_Succ)
            {
               FPrintf(outfh,"%s\n",ad->ad_Node.ln_Name);
            }

            FPutC(outfh,'\f');

            while((ad = (struct AutoDoc *) RemHead(&list)))
            {
               Seek(ad->ad_TempFile,0,OFFSET_BEGINNING);

               sprintf(tmpname,"%%s%%%lds%%s\n",78-2*strlen(ad->ad_Node.ln_Name));

               FPrintf(outfh,tmpname,ad->ad_Node.ln_Name," ",ad->ad_Node.ln_Name);
               Flush(outfh);

               while((len = Read(ad->ad_TempFile,buf,BUFFER_SIZE)))
                  Write(outfh,buf,len);

               Close(ad->ad_TempFile);

               FreeVec(ad);
            }

            if(para[ARG_TO])
               Close(outfh);

            while(num)
            {
               num--;
               sprintf(tmpname,"%ssortad%lx%lx",tmpdir,num,task);
               DeleteFile(tmpname);
            }
         }
         FreeVec(buf);
      }

      FreeArgs(args);
   }

   if(!err)
      err = IoErr();

   if(err)
   {
      PrintFault(err,obj);
      return(RETURN_ERROR);
   }

   return(RETURN_OK);
}


