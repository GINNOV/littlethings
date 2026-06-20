/*******************************************/
/*					   */
/*	       GenPragma v1.0		   */
/*	   © 1992-94 David Kinder	   */
/*					   */
/*  A utility to generate #pragma headers  */
/*  from function description (FD) files.  */
/*					   */
/*******************************************/

#include <stdio.h>
#include <intuition/intuition.h>
#include <libraries/asl.h>
#include <libraries/dos.h>
#include <libraries/gadtools.h>
#include "front.h"

#include <pragmas/asl.h>	/* Using pragma files is more convenient, */
#include <pragmas/dos.h>	/* hence this program... */
#include <pragmas/gadtools.h>
#include <pragmas/intuition.h>

#define SFX_FD "_lib.fd"
#define SFX_PRAG ".h"

char TWspec[] = "";
extern struct WBStartup *WBenchMsg;
char TGen[] = "T:Gen.        ";
char LineBuf[256];

ULONG  GenTags[] = {TAG_DONE};
ULONG LoadTags[] = {ASLFR_TitleText,"Select files to process",
		    ASLFR_InitialPattern,"#?_lib.fd",
		    ASLFR_Flags1,FRF_DOMULTISELECT,
		    ASLFR_RejectIcons,TRUE,
		    ASLFR_SleepWindow,TRUE,
		    ASLFR_Window,NULL,TAG_DONE};
ULONG SaveTags[] = {ASLFR_TitleText,"Select pragma directory",
		    ASLFR_Flags1,FRF_DOSAVEMODE,
		    ASLFR_Flags2,FRF_DRAWERSONLY,
		    ASLFR_SleepWindow,TRUE,
		    ASLFR_Window,NULL,TAG_DONE};
ULONG CheckTag[] = {GTCB_Checked,0,TAG_DONE};
ULONG MutlXTag[] = {GTMX_Active,0,TAG_DONE};

struct EasyStruct ErrReq =
{sizeof(struct EasyStruct),0,"GenPragma",NULL,"Okay"};

struct AslBase *AslBase;
struct Library *GadToolsBase;
struct GfxBase *GfxBase;
struct IntuitionBase *IntuitionBase;
struct UtilityBase *UtilityBase;
struct FileRequester *MyFileReq;
BPTR OldLock,TempLock;
FILE *FD,*Out,*Tmp;
BOOL IsPDC = TRUE,Private = FALSE,Comment = FALSE,Panel = FALSE;

_abort()
{
   if ((WBenchMsg == NULL) && (Panel == FALSE))
   {
      fflush(stdout);
      Write(Output(),"***Break\n",9);
      CleanExit(10L);                       /* Clean up after ^C */
   }
}

main(int argc, char **argv)
{
   sprintf(&TGen[6],"%lx",FindTask(NULL));  /* Prepare temporary filename */
   if (argc < 2) PutUpWindow();
   if (!strcmp(argv[1],"?"))                /* Display template? */
   {
      printf("\x9b1mGenPragma v1.0\x9b0m © 1992-94 ");
      printf("\x9b4mDavid Kinder\x9b0m\n\n");
      printf("Format: %s [<fd file> [<pragma file>]]\n",argv[0]);
      printf("\t[PDC|LATTICE|SAS] [PRIVATE] [COMMENT]\n");
      CleanExit(0L);
   }
   GenFromCLI(argc,argv);
}

GenFromCLI(int argc, char **argv)
/* Use CLI arguments to process an FD (Function Definition) file */
{
int i = 1;
char *OutFile = NULL;

   while(++i < argc)                /* Process arguments */
   {
      strlow(argv[i]);
      if (!strcmp(argv[i],"pdc"))   /* PDC and SAS compilers require */
      { 			    /* that pragma arguments be specified */
	 IsPDC = TRUE; continue;    /* in a different order */
      }
      if (!strcmp(argv[i],"lattice"))
      {
	 IsPDC = FALSE; continue;
      }
      if (!strcmp(argv[i],"sas"))
      {
	 IsPDC = FALSE; continue;
      }
      if (!strcmp(argv[i],"private"))   /* Do we want to use even system */
      { 				/* private functions? */
	 Private = TRUE; continue;
      }
      if (!strcmp(argv[i],"comment"))
      {
	 Comment = TRUE; continue;
      }
      if (i != 2) Error("Unknown argument");    /* If not an option, is */
      OutFile = argv[i];			/* argv[i] a filename? */
   }
   strcpy(LineBuf,argv[1]);         /* Append "_lib.fd" to input filename */
   strlow(LineBuf);                 /* if not already present */
   if (strstr(LineBuf,SFX_FD) == NULL) strcat(LineBuf,SFX_FD);

   if ((FD = fopen(LineBuf,"r")) == NULL) Error("Cannot open input file");
   if (OutFile == NULL)
   {
      Generate(stdout);
      CleanExit(0L);
   }
   if ((Tmp = fopen(TGen,"w")) == NULL) Error("Cannot open temporary file");
   fprintf(Tmp,"GEN:%s\n",OutFile);
   Generate(Tmp);
   fclose(FD); FD = NULL;
   fclose(Tmp);
   UseTmpFile();
   CleanExit(0L);
}

PutUpWindow() /* Display window generated with GadToolsBox */
{
struct IntuiMessage *MyIMsg;
struct Gadget *GadgAddr;
ULONG Class;
USHORT Code;

   OpenLibs();
   Panel = TRUE;
   if (SetupScreen() != 0) CleanExit(10L);
   if (OpenFrontWindow() != 0) CleanExit(10L);
   LoadTags[11] = (ULONG)FrontWnd;
   SaveTags[9] = (ULONG)FrontWnd;

   while(TRUE)
   {
      WaitPort(FrontWnd->UserPort);
      while((MyIMsg = GT_GetIMsg(FrontWnd->UserPort)) != NULL)
      {
	 Class = MyIMsg->Class;
	 Code = MyIMsg->Code;
	 GadgAddr = (struct Gadget *)MyIMsg->IAddress;
	 GT_ReplyIMsg(MyIMsg);

	 switch (Class)
	 {
	    case IDCMP_CLOSEWINDOW:
	       CleanExit(0L);
	       break;
	    case IDCMP_REFRESHWINDOW:
	       GT_BeginRefresh(FrontWnd);
	       FrontRender();
	       GT_EndRefresh(FrontWnd,TRUE);
	       break;
	    case IDCMP_GADGETUP:
	       if (GadgAddr->GadgetID == 3)
	       {
		  GoGadget();
		  FrontRender();
	       }
	       break;
	    case IDCMP_GADGETDOWN:
	       if (GadgAddr->GadgetID == 0) IsPDC = Swap(IsPDC);
	       break;
	    case IDCMP_VANILLAKEY:
	       if (tolower(Code) == 'r')
	       {
		  CheckTag[1] = Swap(FrontGadgets[1]->Flags&GFLG_SELECTED);
		  GT_SetGadgetAttrsA(FrontGadgets[1],FrontWnd,NULL,CheckTag);
	       }
	       if (tolower(Code) == 'c')
	       {
		  CheckTag[1] = Swap(FrontGadgets[2]->Flags&GFLG_SELECTED);
		  GT_SetGadgetAttrsA(FrontGadgets[2],FrontWnd,NULL,CheckTag);
	       }
	       if (tolower(Code) == 'p')
	       {
		  IsPDC = TRUE;
		  MutlXTag[1] = 0;
		  GT_SetGadgetAttrsA(FrontGadgets[0],FrontWnd,NULL,MutlXTag);
	       }
	       if (tolower(Code) == 's')
	       {
		  IsPDC = FALSE;
		  MutlXTag[1] = 1;
		  GT_SetGadgetAttrsA(FrontGadgets[0],FrontWnd,NULL,MutlXTag);
	       }
	       if (tolower(Code) == 'g')
	       {
		  GoGadget();
		  FrontRender();
	       }

	 }
      }
   }
}

BOOL Swap(BOOL Boolean) /* Swap state of boolean */
{
   Boolean = (Boolean == FALSE) ? TRUE : FALSE ;
   return(Boolean);
}

GoGadget()
/* Use file requester to pick source and destination, and call Generate() */
{
int i = 0;

   Private = (FrontGadgets[1]->Flags&GFLG_SELECTED) ? TRUE : FALSE;
   Comment = (FrontGadgets[2]->Flags&GFLG_SELECTED) ? TRUE : FALSE;

   if ((MyFileReq = AllocAslRequest(ASL_FileRequest,GenTags)) == NULL)
   {
      Error("No memory");
      return;
   }
   if (AslRequest(MyFileReq,LoadTags) == NULL) return;

   if ((TempLock = Lock(MyFileReq->fr_Drawer,SHARED_LOCK)) == NULL)
   {
      CleanGadget();
      Error("Cannot access source directory");
      return;
   }
   OldLock = CurrentDir(TempLock);
   if ((Tmp = fopen(TGen,"w")) == NULL)
   {
      CleanGadget();
      Error("Cannot open temporary file");
      return;
   }
   if (MyFileReq->fr_NumArgs == 0)
   {
      if (GoDoGen(MyFileReq->fr_File) == FALSE)
      {
	 fclose(Tmp); Tmp = NULL;
	 DeleteFile(TGen);
	 CleanGadget();
	 return;
      }
   }
   else
   {
      while(i < MyFileReq->fr_NumArgs)
      {
	 if (GoDoGen(MyFileReq->fr_ArgList[i++].wa_Name) == FALSE)
	 {
	    fclose(Tmp); Tmp = NULL;
	    DeleteFile(TGen);
	    CleanGadget();
	    return;
	 }
      }
   }
   fclose(Tmp); Tmp = NULL;
   CurrentDir(OldLock);
   UnLock(TempLock); TempLock = NULL;

   if (AslRequest(MyFileReq,SaveTags) == NULL)
   {
      DeleteFile(TGen);
      CleanGadget();
      return;
   }
   if ((TempLock = Lock(MyFileReq->fr_Drawer,SHARED_LOCK)) == NULL)
   {
      DeleteFile(TGen);
      CleanGadget();
      Error("Cannot access pragma directory");
      return;
   }
   OldLock = CurrentDir(TempLock);
   UseTmpFile();
   CleanGadget();
}

CleanGadget()
{
   if (MyFileReq != NULL)
   {
      FreeAslRequest(MyFileReq); MyFileReq = NULL;
   }
   if (TempLock != NULL)
   {
      CurrentDir(OldLock);
      UnLock(TempLock);
   }
}

BOOL GoDoGen(char *NameFD)
{
   if ((FD = fopen(NameFD,"r")) == NULL)
   {
      Error("Cannot open input file");
      return(FALSE);
   }
   strcpy(strstr(NameFD,SFX_FD),SFX_PRAG);
   fprintf(Tmp,"GEN:%s\n",NameFD);
   Generate(Tmp);
   fclose(FD); FD = NULL;
   return(TRUE);
}

Generate(FILE *Pragma) /* Main routine */
{
int LibBias,NumArgs,ArgType;
char Arg1[32], Arg2[32], LibBase[32], ArgList[16];
char *Token;
char ArgReg;
BOOL OutStat = TRUE;

   while(!feof(FD))
   {
      fgets(LineBuf,256,FD);                    /* Get a line of data */
      if (!strncmp(LineBuf,"*",1))              /* Is it a comment? */
      {
	 if (Comment == TRUE)
	 {
	    LineBuf[strlen(LineBuf)-1] = 0;
	    fprintf(Pragma,"/%s */\n",LineBuf);
	 }
	 continue;
      }
      if (!strncmp(LineBuf,"##",2))             /* Is it an option? */
      {
	 sscanf(LineBuf,"%s %s",Arg1,Arg2);     /* Process options */
	 if (!strcmp(Arg1,"##private")) OutStat = Private;
	 if (!strcmp(Arg1,"##public")) OutStat = TRUE;
	 if (!strcmp(Arg1,"##end")) break;
	 if (!strcmp(Arg1,"##bias")) LibBias = atoi(Arg2);
	 if (!strcmp(Arg1,"##base")) strcpy(LibBase,&Arg2[1]);
	 continue;
      }
      if (OutStat == TRUE)
      {
	 strtok(LineBuf,"(");       /* Found a function, so extract the */
	 strtok(NULL,"(");          /* function name and arguments and */
	 ArgList[0] = 0;	    /* calculate library offset */
	 for(NumArgs = 0; (Token = strtok(NULL,",/")) != NULL;)
	 {
	    ArgType = atoi(&Token[1]);  /* Argument in Dx represented */
	    ArgReg = toupper(Token[0]); /* by 0-7, in Ax by 8-14 */
	    if ((ArgReg == 'A') || (ArgReg == 'D'))
	    {
	       if (ArgReg == 'A') ArgType+=8;
	       sprintf(&ArgList[NumArgs++],"%.1x",ArgType);
	    }
	 }
	 if (IsPDC == FALSE) strrev(ArgList);
	 fprintf(Pragma,"#pragma libcall %s %s %x %s0%x\n",
	    LibBase,LineBuf,LibBias,ArgList,NumArgs);
      }
      LibBias+=6;	/* Increment library offset for next function */
   }
}

UseTmpFile() /* Remove processed data from temporary file */
{
   if ((Tmp = fopen(TGen,"r")) == NULL)
   {
      Error("Cannot open temporary file");
      return;
   }
   while(!feof(Tmp))
   {
      fgets(LineBuf,256,Tmp);
      if (!strncmp(LineBuf,"GEN:",4))   /* Find file header (ie. "GEN:") */
      {
	 LineBuf[strlen(LineBuf)-1] = 0;
	 if (Out != NULL) fclose(Out);
	 if ((Out = fopen(&LineBuf[4],"w")) == NULL)
	 {
	    fclose(Tmp); Tmp = NULL;
	    DeleteFile(TGen);
	    Error("Cannot open output file");
	    return;
	 }
      }
      else
      {
	 fputs(LineBuf,Out);    /* If not header output data */
      }
   }
   fclose(Out); Out = NULL;
   fclose(Tmp); Tmp = NULL;
   DeleteFile(TGen);
}

OpenLibs()
{
   if ((IntuitionBase = OpenLibrary("intuition.library",37L)) == NULL)
      CleanExit(10L);
   if ((GadToolsBase = OpenLibrary("gadtools.library",37L)) == NULL)
      CleanExit(10L);
   if ((GfxBase = OpenLibrary("graphics.library",37L)) == NULL)
      CleanExit(10L);
   if ((UtilityBase = OpenLibrary("utility.library",37L)) == NULL)
      CleanExit(10L);
   if ((AslBase = OpenLibrary("asl.library",37L)) == NULL)
      Error("Cannot open asl.library");
}

CleanExit(LONG ErrCode) /* Clear up nicely even if an error occured */
{
   if (Panel == TRUE)
   {
      CloseFrontWindow();
      CloseDownScreen();
   }
   CheckCloseLib(AslBase);
   CheckCloseLib(GfxBase);
   CheckCloseLib(IntuitionBase);
   CheckCloseLib(GadToolsBase);
   CheckCloseLib(UtilityBase);
   if (MyFileReq != NULL) FreeAslRequest(MyFileReq);
   if (FD != NULL) fclose(FD);
   if (Out != NULL) fclose(Out);
   if (Tmp != NULL)
   {
      fclose(Tmp);
      DeleteFile(TGen);
   }
   exit(ErrCode);
}

CheckCloseLib(struct Library *lib)
/* Close library if library pointer non-zero */
{
   if (lib != NULL) CloseLibrary(lib);
}

Error(char *ErrString) /* Output error and abort */
{
   if ((WBenchMsg != NULL) || (Panel == TRUE))
   {
      ErrReq.es_TextFormat = ErrString;
      EasyRequestArgs(FrontWnd,ErrReq,NULL,NULL);
   }
   else
   {
      fflush(stdout);
      fprintf(stderr,"%s\n",ErrString);
   }
   if (Panel == FALSE) CleanExit(10L);
}

strlow(char *ct) /* Turn string to lowercase */
{
int i;

   for(i = 0; ct[i] = tolower(ct[i]); i++ < strlen(ct));
}

strrev(char *ct) /* Reverse string */
{
int i = 0;
char c;

   while(i < (strlen(ct)/2))
   {
      c = ct[i];
      ct[i] = ct[strlen(ct)-i-1];
      ct[strlen(ct)-i-1] = c;
      i++;
   }
}

