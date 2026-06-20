/****************************************************************/
/* USB Function Driver lister                                   */
/****************************************************************/
/*  © 2001, Thomas Graff Thøger                                 */
/* 2008, Gilles PELLETIER, some code to work with 3.1 and lower */
/****************************************************************/
/* PANDORA Step 0                                               */
/* This piece of code shows how to compile for OS4 and older OS */
/* In theory it should perform even on Kickstart 1.1 (31)       */
/* Deep diving into time abysses...                             */
/****************************************************************/
/* Modification history                                         */
/* ~~~~~~~~~~~~~~~~~~~~                                         */
/* 22-Apr-2008 some extra tags                                  */
/* 13-Mar-2008 lsusb like                                       */
/* 28-Feb-2008 first steps                                      */
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

#define USBA_Parent  (TAG_USER+0x0666000)
#define USBA_Address (TAG_USER+0x0666001)
#define USBA_HubDesc (TAG_USER+0x0666002)
#define USBA_HIDDesc (TAG_USER+0x0666003)
#define USBA_HCDID   (TAG_USER+0x0666004)

#ifdef ANAIIS
#include "v31lib.h"
#endif

/* variables */
struct Library *USBSysBase    = NULL;
#ifdef __amigaos4__ 
  struct USBSysIFace *IUSBSys = NULL ;
#endif

/* main */
int main(int argc, char *argv[])
{ 
  struct MsgPort *port ;
  int cnt = 0 ;

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
        struct UsbRawInterface *rawifc=NULL;
        char *cTmp = NULL ;

        printf( "USB opened\n" );

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
          cTmp = AllocVec(256, MEMF_CLEAR) ;

          /* request all interfaces present in the system */
          do
          {
            rawifc = USBFindInterface( rawifc, 
                                       USBA_SeeClaimed, TRUE,
                                       TAG_DONE ) ;
            if (rawifc != NULL)
            {
              /* Get ifc of current interface */
              struct USBBusDevDsc  *devdsc ;
              struct USBBusDscHead *vendsc, *prodsc ;
              ULONG address = 0xffffffff ;
              ULONG hcdid   = 0xffffffff ;

              USBGetRawInterfaceAttrs( rawifc,
                                       USBA_Address, &address,
                                       USBA_HCDID, &hcdid,
                                       USBA_DeviceDesc, &devdsc,
                                       USBA_VendorName, &vendsc,
                                       USBA_ProductName, &prodsc,
                                       TAG_DONE ) ;

              cnt++ ;
              if (address == 0xffffffff)
              {
                printf("%03d ", cnt) ;
              }
              else
              {
                printf("%ld:%03ld ", hcdid, address & 127) ;
              } 

              printf("ID %04x:%04x ", LE_WORD(devdsc->dd_VendorID), LE_WORD(devdsc->dd_Product)) ;
              if (cTmp != NULL)
              {
                if (vendsc != NULL)
                {
                  strc(vendsc, cTmp) ;
                  printf("%s", cTmp) ;
                }
                if (prodsc != NULL)
                {
                  if (vendsc != NULL)
                  {
                    printf(", ") ;
                  }
                  strc(prodsc, cTmp) ;
                  printf("%s", cTmp) ;
                }
              }
              printf("\n") ;

              USBFreeDescriptors((struct USBBusDscHead *) devdsc) ;
              USBFreeDescriptors((struct USBBusDscHead *) prodsc) ;
              USBFreeDescriptors((struct USBBusDscHead *) vendsc) ;

              USBUnlockInterface( rawifc ); /* Unlock ifc (we don't intend to use it) */
            }
          } while (rawifc != NULL) ;
#ifdef __amigaos4__
          DropInterface((struct Interface *) IUSBSys) ;
#endif
          if (cTmp != NULL)
          {
            FreeVec(cTmp) ;
          }
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


