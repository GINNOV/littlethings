/****************************************************************/
/* USB                                                          */
/****************************************************************/
/* © 2008, Gilles PELLETIER                                     */
/* This piece of code should work with 3.1 and lower            */
/****************************************************************/
/*                                                              */
/*   USBLogPuts()                                               */
/*   USBLogVPrintf()                                            */
/*                                                              */
/****************************************************************/
/* Modification history                                         */
/* ~~~~~~~~~~~~~~~~~~~~                                         */
/* 22-Apr-2008                                                  */
/****************************************************************/

/* To have a full OS4.0 compatibility, remove the following     */
/* definition */
#define ANAIIS 1

/* Includes */
#include <stdio.h>

#include <exec/exec.h>
#include <usb/usb.h>

#include <proto/exec.h>
#include <proto/usbsys.h>

#include "unistr.h"

/* Defines */
#ifndef NULL
#define NULL 0L
#endif

#ifdef ANAIIS
#include "v31lib.h"
#endif

/* variables */
struct Library *USBSysBase    = NULL;
#ifdef __amigaos4__ 
  struct USBSysIFace *IUSBSys = NULL ;
#endif

/* Varargs version of USBLogVPrintf() */
void USBLogPrintf(
LONG err,
char *context,
char *fmt,
...
)
{
  USBLogVPrintf(err, context, fmt, (ULONG *)(&fmt)+1) ;
}

/* main */
int main(int argc, char *argv[])
{ 
  struct MsgPort *port ;

  port = CreateMsgPort() ;
  if (port != NULL)
  {
    struct IORequest *ioreq;

    ioreq = CreateIORequest(port, sizeof(struct IORequest)) ;
    if (ioreq != NULL)
    {
      int od ;

      od = OpenDevice("usbsys.device", 0, ioreq, 0) ;
#ifdef ANAIIS
      if (od != 0)
      { 
        od = OpenDevice("anaiis.device", 0, ioreq, 0) ;
      }
#endif
      if (od != 0)
      {
        printf("Can't open \"usbsys.device\"\n");
      }
      else
      {
        USBSysBase = (struct Library *) ioreq->io_Device;
        if (USBSysBase == NULL)
        {
          printf("Assertion: USBSysBase is NULL\n") ;
        }
        else
        {
#ifdef __amigaos4__        
          /* request interface */
          IUSBSys = (struct USBSysIFace *) GetInterface(USBSysBase, "main", 1, NULL);
	  if (IUSBSys == NULL)
          {
            printf("Cannot obtain USBSys interface\n");
            CloseDevice( ioreq ) ;
            DeleteIORequest( ioreq ) ;
            DeleteMsgPort( port ) ;
            return 10 ;
          }
#endif
          /* Do Some Hello to log */
          USBLogPuts(0,argv[0], "hello usb stack, I'm a buggy program") ;
          USBLogPrintf(-1, argv[0], "It is a severe error\n") ; 
          USBLogPrintf(0, argv[0], "It is an informative message\n") ;
          USBLogPrintf(1, argv[0], "It is a warning message\n") ;
          USBLogPrintf(666, argv[0], "It is an idiot message\n") ;
          USBLogPrintf(0, argv[0], "I have %ld cows and %ld horses\n", 50, 3) ;
          USBLogPrintf(0, argv[0], "The usbsys.device is located at 0x%08lx\n", USBSysBase) ; 
          USBLogPuts(0, "context is here", "Have a good day") ;

          printf("See logs on your stack\n") ;
#ifdef __amigaos4__
          DropInterface((struct Interface *) IUSBSys) ;
#endif
        }

        CloseDevice( ioreq ) ;
      }
      
      DeleteIORequest( ioreq ) ;
    }

    DeleteMsgPort( port ) ;
  }

  printf( "Bye!\n" ) ;
  return 0 ;
}
