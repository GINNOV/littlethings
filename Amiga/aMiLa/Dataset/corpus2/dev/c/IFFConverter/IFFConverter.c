/*
**     $VER: IFFConverter.c V0.02 (08-07-95)
**
**     Author:  Gerben Venekamp
**     Updates: 13-06-95  Version 0.01     Intital module
**              08-07-95  Version 0.02     'ErrorHandler' added for
**                                         flexable error handling.
**              12-11-95  Version 0.03     Tooltypes added
**
**
**  IFFConverter is as its name suggest an IFF Converter. It Converters
**  IFF ILBM pictures to a RAW format.
**  Here the 'main' function has its place. 'Main' initializes and starts
**  IFFConverter. Also, functions for freeing the system resources and
**  error handling are included.
**
*/


#include <dos/dos.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <workbench/startup.h>
#include <proto/dos.h>
#include <proto/gadtools.h>
#include <proto/icon.h>
#include <proto/intuition.h>

#include "IFFConverter.h"
#include "ErrorText.h"

// Include version number in main module
static char VersionI[] = VersionText;

// Define prototypes
void CleanExit(int);
void CleanLibExit(int);
LONG ErrorHandler(enum enum_ErrorNumber, APTR, ...);
void __asm exit(register __d0 LONG ReturnValue);

LONG DisplayError(struct Window *, ULONG, STRPTR, STRPTR, STRPTR, APTR);
void GetArguments(ULONG, char *);
void GetToolTypes(struct WBStartup *);
LONG MyDisplayError(APTR, APTR, APTR);
void PreRelease(void);


/*
**  This is where is all begins.....
**
**  main will call all neseccary initializations in order to start
**  IFFConverter. If something goes wrong during any of the initialization
**  functions, the function will generate an error message and quit
**  imediately after acknoledgement. Control is given back to the system
**  and *not* to the main function!
**
*/
void __saveds main()
{
   extern ULONG argc;
   extern char *argv;

   OpenLibraries();   // For savety reasons, make this the first function in main.
   GetArguments(argc, argv);
   PreRelease();
   GetDiskFonts();
   AllocateMemory();
   OpenScreens();
   InitGadgets();
   OpenWindows();
   AllocAsl_Requests();
   HandleIntuiMessages();
   CleanExit(0);
}


/*
**  GetArgument(argc, argv)
**
**  pre:
**  post:
**
*/
void GetArguments(ULONG argc, char *argv)
{
   if( argc == 0 )      // WorkBench 'argc' == 0 ; Shell 'argc' >= 1
      GetToolTypes( (struct WBStartup *) argv );

   // Well, one or more arguments. So, we're called from shell
   if( argc > 1 )
   {
      // Converter is called with arguments
      char ArgumentsError[] = "Sorry, no argements accepted in this version.\n" \
                              "Try a later version or register and I will implement argumets\n";

      BPTR Stdout = Output();
      
      Write( Stdout, &ArgumentsError, sizeof(ArgumentsError) );
   }

}


/*
**  GetToolTypes()
**
**     Get the .info file for the ToolTypes.
**     The first and only argument given through 'argv' is the name of
**     the program itself. This will help us to get the .info file.
**     'GetDiskObject' attaches the .info extention automaticly.
**
**  pre:  None.
**  post: None.
**
*/
void GetToolTypes(struct WBStartup *startup)
{
   register UWORD i = 0;
   struct DiskObject *diskobj;
   char **ToolTypes;
   STRPTR temp, Destination;

   if( !(diskobj = GetDiskObject(startup->sm_ArgList->wa_Name)) )
      return;
   
   ToolTypes = diskobj->do_ToolTypes;
   
   // Extract GraphicsDrawer
   if( temp = FindToolType(ToolTypes, "GraphicsDrawer") )
   {
      GraphicsDrawerSize = StringLength(temp) + 1;
      AllocThisMem(&GraphicsDrawer, GraphicsDrawerSize, MEMF_CLEAR );
      Destination = GraphicsDrawer;
      while( *Destination++ = *temp ++ );
   }

   // Extract FileMode
   if( temp = FindToolType(ToolTypes, "FileMode") )
      while( CYL_FileMode[i] )
      {
         if( StringCompare(temp, CYL_FileMode[i]) )
            GT_FileMode[3] = i;
         i++;
      }
   
   // Extract RenderMode
   if( temp = FindToolType(ToolTypes, "RenderMode") )
   {
      i = 0;
      while( CYL_RenderMode[i] )
      {
         if( StringCompare(temp, CYL_RenderMode[i]) )
            GT_RenderMode[3] = i;
         i++;
      }
   }
   
   // Extract DrawCross
   if( temp = FindToolType(ToolTypes, "DrawCross") )
      if( StringCompare(temp, "TRUE" ) )
      {
         PanelGadgets[GD_DrawCross].MyGadgetTags = &MakeChecked;
         DrawHairCross = TRUE;
      }
      else
      {
         PanelGadgets[GD_DrawCross].MyGadgetTags = &UnmakeChecked;
         DrawHairCross = FALSE;
      }
   else
      DrawHairCross = FALSE;


   // Extract ByteBoundry
   if( temp = FindToolType(ToolTypes, "ByteBoundry") )
   {
      i = 0;
      while( MXL_ByteBoundry[i] )
      {
         if( StringCompare(temp, MXL_ByteBoundry[i]) )
            GT_ByteBoundry[3] = ByteBoundry = i;
         i++;
      }
   }
   
   // Extract TAB1
   if( temp = FindToolType(ToolTypes, "TAB1") )
      TAB1 = ConvertDecimal(temp);

   // Extract TAB2
   if( temp = FindToolType(ToolTypes, "TAB2") )
      TAB2 = ConvertDecimal(temp);

   // Extract NumberOfItems1
   if( temp = FindToolType(ToolTypes, "NumberOfItems1") )
      NumberOfItems1 = ConvertDecimal(temp);

   // Extract NumberOfItems2
   if( temp = FindToolType(ToolTypes, "NumberOfItems2") )
      NumberOfItems2 = ConvertDecimal(temp);

   // Extract BLPCON3OrMask
   if( temp = FindToolType(ToolTypes, "BPLCON3OrMask") )
   {
      Destination = BPLCON3OrMask;
         for(i=0; i<4; i++)
            *Destination++ = *temp++;
   }

   FreeDiskObject(diskobj);
}


/*
**  num = ErrorHandler(ErrorNumber, ArgList)
**
**     Handles all error generated during execution of the program.
**     Some errors may return to the system by calling 'CleanExit'
**     So, no guarentees that this function will return always.
**
**  pre:  ErrorNumber - Number of error to handle.
**        ArgList - Addition arguments for error message. NULL for
**                  no arguments.
**  post: num - Whatever EasyRequest returns. See AutoDocs for more
**              information on EasyRequest.
**
*/
LONG ErrorHandler(enum IFF_ErrorNumber ErrorNumber, APTR ArgList, ...)
{
   register APTR IFFerror_attr;
   register APTR IFFerror_message;
   register enum ErrorExitType ErrorExit;
   register LONG num;

   switch( ErrorNumber )
   {
      case IFFerror_NoIntuition:
         CleanLibExit(RETURN_FAIL);    // Terminate IFFConverter

      case IFFerror_NoLibrary:
         IFFerror_attr    = IFFerror__NULL_Title_Okay;
         IFFerror_message = EST_OpenLibErr;
         ErrorExit        = Lib_Exit;
         break;
      
      case IFFerror_NoMemory:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_AllocMemErr;
         ErrorExit        = Clean_Exit;
         break;
         
      case IFFerror_NoMemoryDoReturn:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_AllocMemErr;
         ErrorExit        = No_Exit;
         break;
         
      case IFFerror_NoLock:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_LockErr;
         ErrorExit        = Clean_Exit;
         break;
         
      case IFFerror_NoLockDoReturn:
         IFFerror_attr    = IFFerror__PanelWindow_Title_RetryCancel;
         IFFerror_message = EST_LockErr;
         ErrorExit        = No_Exit;
         break;
         
      case IFFerror_GadCreate:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_GadCreate;
         ErrorExit        = Clean_Exit;
         break;
         
      case IFFerror_OpenErr:
         IFFerror_attr    = IFFerror__NULL_Title_Okay;
         IFFerror_message = EST_OpenErr;
         ErrorExit        = Clean_Exit;
         break;
         
      case IFFerror_NoVisIErr:
         IFFerror_attr    = IFFerror__NULL_Title_Okay;
         IFFerror_message = EST_NoVisIErr;
         ErrorExit        = Clean_Exit;
         break;
         
      case IFFerror_AllocErr:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_AllocErr;
         ErrorExit        = Clean_Exit;
         break;
         
      case IFFerror_NotFound:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_NotFound;
         ErrorExit        = No_Exit;
         break;
         
      case IFFerror_Fail:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_Fail;
         ErrorExit        = No_Exit;
         break;
         
      case IFFerror_NoIFFErr:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_NoIFFErr;
         ErrorExit        = No_Exit;
         break;
         
      case IFFerror_AslNoFreeStore:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_AslNoFreeStore;
         ErrorExit        = Clean_Exit;
         break;
         
      case IFFerror_AslNoMoreEntries:
         IFFerror_attr    = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message = EST_AslNoMoreEntries;
         ErrorExit        = No_Exit;
         break;
         
      case IFFerror_NotImplemented:
         IFFerror_attr     = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message  = EST_NotImplemented;
         ErrorExit         = No_Exit;
         break;
      
      case IFFerror_NotOpen:
         IFFerror_attr     = IFFerror__PanelWindow_Title_Okay;
         IFFerror_message  = EST_OpenErr;
         ErrorExit         = No_Exit;
         break;
         
      case IFFerror_FileExistsAsk:
         IFFerror_attr     = IFFerror__PanelWindow_Title_ROverWC;
         IFFerror_message  = EST_FileExistsAsk;
         ErrorExit         = No_Exit;
         break;
   }

   num = MyDisplayError(IFFerror_attr, IFFerror_message, &ArgList);
   
   switch( ErrorExit )
   {
      case Lib_Exit:
         CleanLibExit(RETURN_FAIL);
      case Clean_Exit:
         CleanExit(RETURN_FAIL);
      case No_Exit:
         return( num );             // Return the result of DisplayError.
   }
}


/*
**  CleanExit(ReturnValue)
**
**     Exits the program. Before you can actualy leave the program you
**     must give back all alloceted memory and structures, opened
**     libraries and devices, etc. So, that's done here for you, before
**     we quit.
**
**  pre:  ReturnValue - Error number to be passed on to exit(rv).
**  post: None.
**
*/
void CleanExit(int ReturnValue)
{
   FreeAsl_Requests();
   CloseWindows();
   FreeGadgets(FirstGadget);
   CloseScreens();
   FreeMemory();
   CloseFonts();
   CloseLibraries();    // Close all open Libraries
   
   exit(ReturnValue);
}


/*
**  CleanLibExit(ReturnValue)
**
**     Like 'CleanExit' but no all libraries need to be open, assuming
**     so is dangerous. 'CleanLibExit' NEVER uses possible open libraries.
**     This means that 'CleanLibExit' only tries to close all opened
**     libraries through 'CloseLibraries'. Nothing else should be opened,
**     allocated or anything else other than opend libraries.
**
**  pre:  ReturnValue - Error number to be passed on to exit(rv).
**  post: None.
**
*/
void CleanLibExit(int ReturnValue)
{
   CloseLibraries();   // Save to call, because exec.library is always open!
   
   exit(ReturnValue);
}


/*
**  PreRelease()
**
**     Shows a message to notify the user that he/she is using the
**     pre-release version of IFFConverter. In it is stated that this
**     version is *NOT* guaranteed to be in perfect working order. Nor
**     all functions have to be implemented. Use of it is on the user
**     own risk! This sub-routine returns when the user acknowleges
**     the message.
**
** pre:  None.
** post: None.
**
*/
void PreRelease()
{
   struct EasyStruct PreReleaseES = {
      sizeof (struct EasyStruct),
      0,
      "Pre-release note:",
      {
         "\n"
         "IFFConverter V" VersionQ "\n\n"
         "Using this version is done on your own risk. This version\n"
         "is under construction. Which means that I can give no\n"
         "guarentees about its behaviour. In other words, some\n"
         "functions may have been implemented but they may behave\n"
         "not the way you'd expect, or even cause a software-failure\n"
         "So, I suggest you'd better get V1.0+ of IFFConverter and\n"
         "*not* use this pre-release version.\n"
      },
      "I'm supposed to be intelligent",
   };
   
   ULONG iflags = 0;
   
   EasyRequest(NULL, &PreReleaseES, &iflags);   // Show EasyRequester
}



/*
**  num = DisplayError(ErrorWindow, IDCMPFlags, ErrorTitle, ErrorText,
**                     ErrorGadgets, ArgList)
**
**     Displays an Error (or Message) through an EasyRequest. Take
**     adventage of this function, DisplayError does the initialistions
**     for you, so you don't have to be bored.
**
**  pre:  ErrorWindow  - Pointer to the window on which EasyRequest will
**                        be shown.
**        IDCMPFlags   - Your IDCMPFlags for EasyRequest.
**        ErrorTitle   - What's the name of your EasyRequest Window.
**        ErrorText    - What's the text to displayed by EasyRequest.
**        ErrorGadgets - What are your Gadgets EasyRequest will use.
**        ArgList      - Pointer to a list of arguments to be passed on
**                       to EasyRequestArgs.
**  post: num - Whatever EasyRequest returns. See AutoDocs for more
**              information on EasyRequest.
**
*/
LONG DisplayError(struct Window *ErrorWindow, ULONG IDCMPFlags, STRPTR ErrorTitle, STRPTR ErrorText, STRPTR ErrorGadgets, APTR ArgList)
{
   struct EasyStruct ES_ErrorMessage;
   ULONG IFlags = IDCMPFlags;
   
   ES_ErrorMessage.es_StructSize = sizeof (struct EasyStruct);
   ES_ErrorMessage.es_Flags = 0;
   ES_ErrorMessage.es_Title = ErrorTitle;
   ES_ErrorMessage.es_TextFormat = ErrorText;
   ES_ErrorMessage.es_GadgetFormat = ErrorGadgets;

   return( EasyRequestArgs(ErrorWindow, &ES_ErrorMessage, &IFlags, ArgList) );
}


/*
**  num = MyDisplayError( IFFerror_attr[], IFFerror_message, ArgList )
**
**     Pre-process data for DisplayError. All necessary data is to be
**     found in the array IFFError_attr and IFFerror_message.
**
**  pre:  IFFerror_attr - Address of array containing information on
**                        the error message. See DisplayError and ErrorText.h
**                        for more information.
**        IFFerror_message - Address of message to be displayed.
**  post: num - Whatever DisplayError returns.
**
*/
LONG MyDisplayError(APTR IFFerror_attr[], APTR IFFerror_message, APTR ArgList)
{
   if( IFFerror_attr[0] == NULL )
      return( DisplayError(NULL, NULL, IFFerror_attr[1], IFFerror_message, IFFerror_attr[2], ArgList) );
   else
   {
      APTR *Temp = IFFerror_attr[0];
      return( DisplayError( *Temp, NULL, IFFerror_attr[1], IFFerror_message, IFFerror_attr[2], ArgList) );
   }
}
