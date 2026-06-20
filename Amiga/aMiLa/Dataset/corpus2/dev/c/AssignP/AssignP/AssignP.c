/************************************************************************
 *                                                                      *
 *  AssignP - trap easyrequests for non existant device or volumes      *
 *                                                                      *
 *  (originally based on AssignX by Steve Tibbet, but has been          *
 *   completely rewritten several times)                                *
 *                                                                      *
 *  All changes made: put into the Public Domain.                       *
 *                                                                      *
 *  rewritten and enhanced by Andreas R. Kleinert                       *
 *  Andreas_Kleinert@t-online.de                                        *
 *                                                                      *
 *  No Assembler - 100 percent C                                        *
 *                                                                      *
 * V1.03 (23.1.97):                                                     *
 *                 - fixed ASL problem                                  *
 *                 - now background tool                                *
 *                 - using SAS/C V6.57                                  *
 *                 - renamed to AssignP                                 *
 *                 - etc.                                               *
 *                                                                      *
 * V1.02 :                                                              *
 *                 - private version                                    *
 *                 - using SAS/C V6.55                                  *
 *                 - needs 3.1 (V40) now                                *
 *                 - and more                                           *
 *                                                                      *
 * V1.01 :                                                              *
 *                 - renamed to "DAssignX"                              *
 *                 - made necessary changes to run it on a              *
 *                   3.0-locale-WB                                      *
 *                 - used SAS/C V6.00                                   *
 *                                                                      *
 ************************************************************************/

#define __USE_SYSBASE

#include <exec/memory.h>
#include <intuition/intuitionbase.h>
#include <libraries/gadtools.h>

#include <string.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/asl.h>

#define N (NULL)

struct AbortedList
{
 struct AbortedList *Next;
 char Name[256];
};

struct IntuitionBase *IntuitionBase   = N;
struct Library       *AslBase         = N;
struct Remember      *Remember        = N;
struct AbortedList   *AbortedRequests = N;

char __aligned *checktext [] =
{
 "Benötige den Datenträger",
 "Please insert volume",
 ""
};


APTR __far NewEasyVec;
long __far __asm (*OrigEasyVec)(register __a0 struct Window        *Win_a0,
                                register __a1 struct EasyStruct    *EZ_a1,
                                register __a2 ULONG                *idcmp,
                                register __a3 ULONG                *args,
                                register __a6 struct IntuitionBase *IntuitionBase);


ULONG __saveds __asm NewEasy(register __a0 struct Window     *Win_a0,
                             register __a1 struct EasyStruct *EZ_a1,
                             register __a2 ULONG             *idcmp,
                             register __a3 ULONG             *args,
                             register __a6 struct IntuitionBase *IntuitionBase_a6)
{
 struct Window     *Win = Win_a0;
 struct EasyStruct *EZ  = EZ_a1;
 ULONG retval = 0, catch = 0, case_true = FALSE, i, found = 0;
 UBYTE *oldstr = N;
 struct IntuitionBase *IntuitionBase = IntuitionBase_a6;


 for(i=0; checktext[i][0]; i++)
  {
   if(args)
    {
     if(!strncmp(  (char *)args[0], checktext[i], strlen(checktext[i]))) { case_true = TRUE; found = i; }
    }

   if(EZ)
    {
     if(!strncmp(EZ->es_TextFormat, checktext[i], strlen(checktext[i]))) { case_true = TRUE; found = i; }
    }
  }

 if(case_true)
  {
   struct AbortedList *AL=AbortedRequests;

   while (AL)
    {
     if (stricmp((char *)AL->Name, (char *)args[1])==0) return(0);

     AL=AL->Next;
    }

   oldstr = EZ->es_GadgetFormat;

   EZ->es_GadgetFormat = "Try again|Mount|Assign|Cancel Forever|Cancel";

   catch=1;
  }

 retval = OrigEasyVec(Win, EZ, idcmp, args, IntuitionBase);

 if(catch)
  {
   EZ->es_GadgetFormat = oldstr;

   switch(retval)
    {
     case 2:
            {
             UBYTE *strbuffer;


             retval = 0; /* until success */

             strbuffer = (UBYTE *) AllocVec(512, MEMF_CLEAR|MEMF_PUBLIC);
             if(strbuffer)
              {
               strcpy(strbuffer, "C:Mount ");
               strcat(strbuffer, (char *) args[1]);

               SystemTagList(strbuffer, N);

               retval = 1;

               FreeVec(strbuffer);
              }

             break;
            }
     case 3:
            {
             UBYTE *strbuffer;


             retval = 0; /* until success */

             strbuffer = (UBYTE *) AllocVec(1024, MEMF_CLEAR|MEMF_PUBLIC);
             if(strbuffer)
              {
               UBYTE *buff, *FullName;
               struct FileRequester *request;
               struct TagItem __aligned tags[4];


               buff     = &strbuffer[0];
               FullName = &strbuffer[512];

               strcpy(buff, "AssignP: Assign for '");
               strcat(buff, (char *)args[1]);
               strcat(buff, "':");

               tags[0].ti_Tag  = (Tag)   ASL_Hail;
               tags[0].ti_Data = (ULONG) buff;

               tags[1].ti_Tag  = (Tag)   ASL_OKText;
               tags[1].ti_Data = (ULONG) "Assign";

               tags[2].ti_Tag  = (Tag)   ASL_CancelText;
               tags[2].ti_Data = (ULONG) "Cancel";

               tags[3].ti_Tag  = (Tag)   TAG_DONE;
               tags[3].ti_Data = (ULONG) N;

               request = AllocAslRequest(ASL_FileRequest, N);
               if(request)
                {
                 if(AslRequest(request, &tags[0]))
                  {
                   ULONG len;
                   BPTR  lock;

                   strcpy(FullName, request->rf_Dir);

                   len = strlen(FullName);
                   if(len)
                    {
                     len--;

                     if(   (FullName[len] != ':')
                         &&(FullName[len] != '/')
                         &&(FullName[len] != ' ') ) strcat(FullName, "/");
                    }

                   strcat(FullName, request->rf_File);

                   lock=Lock(FullName, ACCESS_READ);
                   if(lock)
                    {
                     retval = 1;
                     AssignLock((char *)args[1], lock);
                    }
                  }
                 FreeAslRequest(request);
                }

               FreeVec(strbuffer);
              }

             break;
            }
     case 4:
            {
             struct AbortedList *AL;

             AL = (struct AbortedList *) AllocRemember(&Remember, strlen((char *)args[1])+sizeof(struct AbortedList)+2, MEMF_CLEAR|MEMF_PUBLIC);
             if(AL)
              {
               strcpy(AL->Name, (char *)args[1]);

               AL->Next=AbortedRequests;
               AbortedRequests=AL;
              }

             break;
            }
        }
  }

 return(retval);
}

/* *************************************************** */
/* *                                                 * */
/* * Compiler Stuff for BackgroundIO                 * */
/* *                                                 * */
/* *************************************************** */

long  __stack        = 2048;
char *__procname     = "AssignP";
long  __priority     = 1;
long  __BackGroundIO = 1;           /* TRUE : We DO BackGroundIO !     */

extern BPTR _Backstdout;            /* NULL, if started from Workbench */

void __regargs __chkabort(void) { }
void __regargs _CXBRK(void)     { }

char vertext [] = "\0$VER: AssignP V1.03 (private)";


typedef unsigned long (*FUNCCAST)();

long main(long argc, char **argv)
{
 long retval = 0;

 APTR task;

 Forbid();
 task = FindTask(N);
 Permit();

 if(task) SetTaskPri(task, __priority);


 IntuitionBase = (APTR) OpenLibrary("intuition.library", 40);
 if(IntuitionBase)
  {
   AslBase = (APTR) OpenLibrary("asl.library", 40);
   if(AslBase)
    {
     OrigEasyVec = (long (* __asm )(register __a0 struct Window        *Win_a0,
                                    register __a1 struct EasyStruct    *EZ_a1,
                                    register __a2 ULONG                *idcmp,
                                    register __a3 ULONG                *args,
                                    register __a6 struct IntuitionBase *IntuitionBase)) SetFunction((APTR)IntuitionBase, -588, (APTR)NewEasy);
     if(OrigEasyVec)
      {
       if(task) SetTaskPri(task, -10);
       Wait(SIGBREAKF_CTRL_C);
       if(task) SetTaskPri(task, 1);

       NewEasyVec= (APTR) SetFunction((APTR)IntuitionBase, -588, (APTR)OrigEasyVec);

       if(NewEasyVec!=NewEasy)
        {
         ULONG idcmp = N;
         struct EasyStruct estr;

         estr.es_StructSize   = sizeof(struct EasyStruct);
         estr.es_Flags        = N;
         estr.es_Title        = "AssignP Request";
         estr.es_TextFormat   = "Error while removing from system !\n"
                                "There were more patches !"
                                "Do a reset soon !";
         estr.es_GadgetFormat = "Ok";

         EasyRequestArgs(N, &estr, (ULONG *) &idcmp, N);
        }

       FreeRemember(&Remember, TRUE);

      }else retval = 20;

     CloseLibrary(AslBase);

    }else retval = 20;

   CloseLibrary(IntuitionBase);

  }else retval = 20;

 return(retval);
}
