/****************************************************************/
/* USB Interface lister                                         */
/****************************************************************/
/* © 2008, Gilles PELLETIER                                     */
/* This piece of code should work with 3.1 and lower            */
/****************************************************************/
/* Modification history                                         */
/* ~~~~~~~~~~~~~~~~~~~~                                         */
/* 28-Aug-2008 more code                                        */
/* 22-Apr-2008 some extra tags                                  */
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

/* ANAIIS reserved tags */
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

struct myrawint
{
  struct UsbRawInterface *rawifc ;
  int isfree ;
} ;

struct myrawint *FindIfc(
struct myrawint *array,
int max,
struct UsbRawInterface *rawifc
)
{
  int cnt = 0 ;
  int found = 0 ;
  while ((cnt < max) && !found)
  {
    if (array->rawifc == rawifc)
    {
      found = 1 ;
    }
    else
    {
      cnt ++ ;
      array ++ ;
    }
  }

  if (found) return array ;
  return NULL ;
}

/* main */
int main(int argc, char *argv[])
{ 
  struct MsgPort *port ;
  int cnt    = 0 ;
  int intcnt = 0 ;
  struct myrawint *myrawintarray = NULL ;
  struct myrawint *myint = NULL ;

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


          /* quick request all interfaces present in the system */
          intcnt = 0 ;
          rawifc = NULL ;
          do
          {
            rawifc = USBFindInterface( rawifc, 
                                       USBA_SeeClaimed, TRUE,
                                       TAG_DONE ) ;
            if (rawifc != NULL)
            {
              intcnt ++ ;
              USBUnlockInterface( rawifc ); /* Unlock ifc (we don't intend to use it) */
            }
          } while (rawifc != NULL) ;

          myrawintarray = (struct myrawint *)AllocVec(sizeof(struct myrawint)*intcnt, MEMF_CLEAR) ;
          if (myrawintarray != NULL)
          {
            /* Fill array */
            cnt = 0 ;
            rawifc = NULL ;
            do
            {
              rawifc = USBFindInterface( rawifc, 
                                         USBA_SeeClaimed, TRUE,
                                         TAG_DONE ) ;
              if (rawifc != NULL)
              {
                myrawintarray[cnt].rawifc = rawifc ;
                myrawintarray[cnt].isfree = 0 ;
                cnt ++ ;
                USBUnlockInterface( rawifc ); /* Unlock ifc (we don't intend to use it) */
              }
            } while ((rawifc != NULL) && (cnt < intcnt)) ;
            
            
            /* Mark free interfaces */
            cnt = 0 ;
            rawifc = NULL ;
            do
            {
              rawifc = USBFindInterface( rawifc,
                                         USBA_SeeClaimed, FALSE,
                                         TAG_DONE ) ;
              if (rawifc != NULL)
              {
                myint = FindIfc(myrawintarray, intcnt, rawifc) ;
                if (myint != NULL)
                {
                  myint->isfree = 1 ;
                }
                USBUnlockInterface( rawifc ); /* Unlock ifc (we don't intend to use it) */
              }
            } while ((rawifc != NULL) && (cnt < intcnt)) ;

            /* request all interfaces present in the system */
            rawifc = NULL ;
            do
            {
              rawifc = USBFindInterface( rawifc, 
                                         USBA_SeeClaimed, TRUE,
                                         TAG_DONE ) ;
              if (rawifc != NULL)
              {
                /* Get ifc of current interface */
                struct USBBusDevDsc  *devdsc = NULL ;
                struct USBBusIntDsc  *intdsc = NULL ;
                struct USBBusDscHead *vendsc = NULL, *prodsc = NULL ;
                ULONG address = 0xffffffff ;
                ULONG hcdid   = 0xffffffff ;

                USBGetRawInterfaceAttrs( rawifc,
                                         USBA_Address, &address,
                                         USBA_HCDID, &hcdid,
                                         USBA_DeviceDesc, &devdsc,
                                         USBA_InterfaceDesc, &intdsc,
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

                myint = FindIfc(myrawintarray, intcnt, rawifc) ;
                if (myint == NULL)
                {
                  printf("!????! ") ;
                }
                else
                {
                  if (myint->isfree)
                  {
                    printf(" free  ") ;
                  }
                  else
                  {
                    printf("in use ") ;
                  }
                }

                if (devdsc != NULL)
                {
                  printf("ID %04x:%04x ",
                         LE_WORD(devdsc->dd_VendorID),
                         LE_WORD(devdsc->dd_Product)) ;
                }

                if (intdsc != NULL)
                {
                  printf("(%d,%d,%d) ",
                         intdsc->id_Class,
                         intdsc->id_Subclass,
                         intdsc->id_Protocol) ;
                }
 
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
                USBFreeDescriptors((struct USBBusDscHead *) intdsc) ;
                USBFreeDescriptors((struct USBBusDscHead *) prodsc) ;
                USBFreeDescriptors((struct USBBusDscHead *) vendsc) ;

                USBUnlockInterface( rawifc ); /* Unlock ifc (we don't intend to use it) */
              }
            } while (rawifc != NULL) ;

            FreeVec(myrawintarray) ;
          }
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


