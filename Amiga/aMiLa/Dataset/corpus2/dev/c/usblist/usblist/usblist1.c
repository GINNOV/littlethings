/****************************************************************/
/* USB Function Driver lister                                   */
/****************************************************************/
/* © 2001, Thomas Graff Thøger                                  */
/* © 2008, Gilles Gillou Pelletier                              */
/* This piece of code should work with 3.1 and lower            */
/****************************************************************/
/* PANDORA Step 1                                               */
/* usblist1 displays more data than usblist                     */
/* I use this piece of code to test my USB stack ANAIIS         */
/* Very huge work                                               */
/*                                                              */
/*   USBFindInterface()                                         */
/*   USBGetRawInterfaceAttrs()                                  */
/*   USBNextDescriptor()                                        */
/*   USBFreeDescriptors()                                       */
/*                                                              */
/*   DoIO()                                                     */
/*                                                              */
/*   USBAllocRequest()                                          */
/*   USBClaimInterface()                                        */
/*   USBGetEndPoint()                                           */
/*   USBEPControlXfer()                                         */
/*   USBDeclaimInterface()                                      */
/*   USBFreeRequest()                                           */
/*                                                              */
/*   USBLogPuts()                                               */
/*   USBLogVPrintf()                                            */
/*                                                              */
/****************************************************************/
/* Modification history                                         */
/* ~~~~~~~~~~~~~~~~~~~~                                         */
/* 22-Apr-2008 Code cleaning                                    */
/* 07-Apr-2008 Add Claim and Declaim interface (dead code)      */
/* 03-Apr-2008 HID and HUB                                      */
/* 13-Mar-2008 verbose                                          */
/* 02-Mar-2008 try to print usb unicode strings                 */
/*             correct ugly code                                */
/****************************************************************/

/* To have a full OS4.0 compatibility, remove the following     */
/* definition */
#define ANAIIS 1

/* Includes */
#include <stdio.h>
#include <stdlib.h>

#include <exec/exec.h>
#include <usb/usb.h>
#include <usb/hub.h>

#include <devices/newstyle.h>

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
struct Library *USBSysBase  = NULL;
#ifdef __amigaos4__ 
struct USBSysIFace *IUSBSys = NULL ;
#endif

/* some missed defines */
#define USBA_Parent  (TAG_USER+0x0666000)
#define USBA_Address (TAG_USER+0x0666001)
#define USBA_HubDesc (TAG_USER+0x0666002)
#define USBA_HIDDesc (TAG_USER+0x0666003)
#define USBA_HCDID   (TAG_USER+0x0666004)

#ifndef USBDESC_HID
#define USBDESC_HID 0x21
#endif

struct USBHIDDescriptor
{
  UBYTE bLength ;
  UBYTE bDescriptorType ;
  UWORD bcdHID ;
  UBYTE bCountryCode ;
  UBYTE bNumDescriptorType ;
  UBYTE bXDescriptorType ;
  UBYTE bXDescriptorLengthL ;
  UBYTE bXDescriptorLengthH ;
} ;

/* Hub Descriptor  GET_DESCRIPTOR with 0x2900 */
/* bDescriptorType = 0x29 */
#ifndef USBDESC_HUB
#define USBDESC_HUB 0x29
#endif
struct USBHubDescriptor
{
  UBYTE bLength ;
  UBYTE bDescriptorType ;
  UBYTE bNbrPorts ;
  UBYTE bHubCharacteristicsL ; /* 68000 will work ! */
  UBYTE bHubCharacteristicsH ; /* 68000 will work ! */
  UBYTE bPwrOn2PwrGood ;
  UBYTE bHubContrCurrent ;
  UBYTE bDeviceRemovable ;
  UBYTE bPortPwrCtlMask ;
} ;

void printdsc(struct USBBusDscHead *dsc)
{
  switch (dsc->dh_Type)
  {
    case USBDESC_DEVICE :
    {
      struct USBBusDevDsc *devdsc = (struct USBBusDevDsc *)dsc ;
      printf("DEVICE (id=%d,len=%d)\n", devdsc->Head.dh_Type, devdsc->Head.dh_Length) ;
      printf(" USBVer %04x\n", LE_WORD(devdsc->dd_USBVer)) ;
      printf(" Class %d\n", devdsc->dd_Class) ;
      printf(" SubClass %d\n", devdsc->dd_Subclass) ;
      printf(" Protocol %d\n", devdsc->dd_Protocol) ;
      printf(" MaxPacketSize0 %d\n", devdsc->dd_MaxPacketSize0) ;
      printf(" VendorID %04x\n", LE_WORD(devdsc->dd_VendorID)) ;
      printf(" Product %04x\n", LE_WORD(devdsc->dd_Product)) ;
      printf(" DevVer %04x\n", LE_WORD(devdsc->dd_DevVer)) ;
      printf(" ManufacturerStr %d\n", devdsc->dd_ManufacturerStr) ;
      printf(" ProductStr %d\n", devdsc->dd_ProductStr) ;
      printf(" SerialStr %d\n", devdsc->dd_SerialStr) ;
      printf(" NumConfigs %d\n", devdsc->dd_NumConfigs) ;
      break ;
    }

    case USBDESC_CONFIGURATION :
    {
      struct USBBusCfgDsc *cfgdsc = (struct USBBusCfgDsc *)dsc ;
      printf("CONFIGURATION (id=%d,len=%d)\n", cfgdsc->Head.dh_Type, cfgdsc->Head.dh_Length) ;
      printf(" TotalLength %d\n", LE_WORD(cfgdsc->cd_TotalLength)) ;
      printf(" NumInterfaces %d\n", cfgdsc->cd_NumInterfaces) ;
      printf(" ConfigID %d\n", cfgdsc->cd_ConfigID) ;
      printf(" ConfigStr %d\n", cfgdsc->cd_ConfigStr) ;
      printf(" Attributes %d\n", cfgdsc->cd_Attributes) ;
      printf(" MaxPower %d (%d mA)\n", cfgdsc->cd_MaxPower, cfgdsc->cd_MaxPower*2) ;
      break ;
    }

    case USBDESC_INTERFACE :
    {
      struct USBBusIntDsc *intdsc = (struct USBBusIntDsc *)dsc ;
      printf("INTERFACE (id=%d,len=%d)\n", intdsc->Head.dh_Type, intdsc->Head.dh_Length) ;
      printf(" InterfaceID %d\n", intdsc->id_InterfaceID) ;
      printf(" AltSetting %d\n", intdsc->id_AltSetting) ;
      printf(" NumEndPoints %d\n", intdsc->id_NumEndPoints) ;
      printf(" Class %d\n", intdsc->id_Class) ;
      printf(" SubClass %d\n", intdsc->id_Subclass) ;
      printf(" Protocol %d\n", intdsc->id_Protocol) ;
      printf(" InterfaceStr %d\n", intdsc->id_InterfaceStr) ;
      break ;
    }

    case USBDESC_ENDPOINT :
    {
      struct USBBusEPDsc * epdsc = (struct USBBusEPDsc *)dsc ;
      printf("EP (id=%d,len=%d)\n", epdsc->Head.dh_Type, epdsc->Head.dh_Length) ;
      printf(" Address %02x\n", epdsc->ed_Address) ;
      printf(" Attributes %02x\n", epdsc->ed_Attributes) ;
      printf(" MaxPacketSize %d\n", LE_WORD(epdsc->ed_MaxPacketSize)) ;
      printf(" Interval %d ms\n", epdsc->ed_Interval) ;
      break ;
    }

    case USBDESC_HID :
    {
      struct USBHIDDescriptor *hiddsc = (struct USBHIDDescriptor *)dsc ;
      LONG i, num ;
      UBYTE *c ; 
    
      printf("HID (id=%d,len=%d)\n", hiddsc->bDescriptorType, hiddsc->bLength) ;
      printf(" bcdHID %04x\n", LE_WORD(hiddsc->bcdHID)) ;
      printf(" bCountryCode %d\n", hiddsc->bCountryCode) ;
      printf(" bNumDescriptorType %d\n", hiddsc->bNumDescriptorType) ;
      num = hiddsc->bNumDescriptorType ;
      c = (UBYTE *)dsc ;
      c += 6 ;
      for (i=0; i<num; i++)
      {
        printf(" bXDescriptorType %d\n", c[0]) ;
        printf(" wXDescriptorLength %d\n", LE_WORD(c[1] << 8 | c[2])) ;
        c += 3 ;
      }
      break ;
    }

    case USBDESC_HUB :
    {
      struct USBHubDescriptor *hubdsc = (struct USBHubDescriptor *)dsc ;
      printf("HUB (id=%d,len=%d)\n", hubdsc->bDescriptorType, hubdsc->bLength) ;
      printf(" bNbrPorts %d\n", hubdsc->bNbrPorts) ;
      printf(" bHubCharacteristics 0x%04x\n", LE_WORD(hubdsc->bHubCharacteristicsL << 8 | hubdsc->bHubCharacteristicsH)) ;
      printf(" bPwrOn2PwrGood 0x%02x\n", hubdsc->bPwrOn2PwrGood) ;
      printf(" bHubContrCurrent 0x%02x\n", hubdsc->bHubContrCurrent) ;
      printf(" bDeviceRemovable 0x%02x\n", hubdsc->bDeviceRemovable) ;
      printf(" bPortPwrCtrMask 0x%02x\n", hubdsc->bPortPwrCtlMask) ;
      break ;
    }

    default :
    {
      printf(" Length %d\n", dsc->dh_Length) ;
      printf(" Type   %d\n", dsc->dh_Type) ;
      break ;
    }
  }
}

void printcommand(UWORD cmd)
{
  char *strcmd = NULL ;

  switch (cmd)
  {
    case CMD_INVALID       : strcmd ="INVALID"; break ;
    case CMD_RESET         : strcmd ="RESET"; break ;
    case CMD_READ          : strcmd ="READ"; break ;
    case CMD_WRITE         : strcmd ="WRITE"; break ;
    case CMD_UPDATE        : strcmd ="UPDATE"; break ;
    case CMD_CLEAR         : strcmd ="CLEAR"; break ;
    case CMD_STOP          : strcmd ="STOP"; break ;
    case CMD_START         : strcmd ="START"; break ;
    case CMD_FLUSH         : strcmd ="FLUSH"; break ;
    case NSCMD_DEVICEQUERY : strcmd ="DEVICEQUERY"; break ;
    case NSCMD_TD_READ64   : strcmd ="TD_READ64"; break ;
    case NSCMD_TD_WRITE64  : strcmd ="TD_WRITE64"; break ;
    case NSCMD_TD_SEEK64   : strcmd ="TD_SEEK64"; break ;
    case NSCMD_TD_FORMAT64 : strcmd ="TD_FORMAT64"; break ;
    case NSCMD_ETD_READ64  : strcmd ="ETD_READ64"; break ;
    case NSCMD_ETD_WRITE64 : strcmd ="ETD_WRITE64"; break ;
    case NSCMD_ETD_SEEK64  : strcmd ="ETD_SEEK64"; break ;
    case NSCMD_ETD_FORMAT64: strcmd ="ETD_FORMAT64"; break ;
  }

  printf(" %04x %s\n", cmd, (strcmd == NULL)?"":strcmd) ;
}

void dumpData(UBYTE *data, long datalength)
{
  long i ;
  int cnt = 0 ;

  for (i=0; i<datalength; i++)
  {
    printf("%02x", data[i]) ;
    if (cnt > 16)
    {
      printf("\n") ;
      cnt = 0 ;
    }
    else
    {
      cnt ++ ;
    }
  }

  if (!(cnt == 0))
  {
    printf("\n") ;
  }
}

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

  int cnt = 0 ;
  int verbose = 0 ;
  int showhid = 0 ;
  int showhub = 0 ;
  int showcaps = 0 ;

  if (argc > 1)
  {
    cnt = 1 ;
    while (cnt < argc)
    {
      if (strcmp(argv[cnt], "-vv")==0)
      {
        verbose  = 2 ;
        showhid  = 1 ;
        showhub  = 1 ;
        showcaps = 1 ;
      }
      else if (strcmp(argv[cnt], "-anaiisvv")==0)
      {
        verbose  = 2 ;
        showhid  = 2 ;
        showhub  = 2 ;
        showcaps = 1 ;
      }
      else if (strcmp(argv[cnt], "-v")==0)
      {
        verbose = 1 ;
      }
      else if (strcmp(argv[cnt], "-hid")==0)
      {
        showhid = 1 ;
      }
      else if (strcmp(argv[cnt], "-hub")==0)
      {
        showhub = 1 ;
      }
#ifdef ANAIIS
      else if (strcmp(argv[cnt], "-anaiishid")==0)
      {
        showhid = 2 ;
      }
      else if (strcmp(argv[cnt], "-anaiishub")==0)
      {
        showhub = 2 ;
      }
#endif
      else if (strcmp(argv[cnt], "-caps")==0)
      {
        showcaps = 1 ;
      }
      else if (strcmp(argv[cnt], "?")==0)
      {
        cnt = argc ;
        printf("Usage: %s [-modifiers]\n", argv[0]) ;
        printf("-caps show device capabilities\n") ;
        printf("-hid show HID\n") ;
        printf("-hub show HUB\n") ;
#ifdef ANAIIS
        printf("-anaiishid show HID in dangerous mode\n") ;
        printf("-anaiishub show HUB in dangerous mode\n") ;
#endif
        printf("-v   unused verbosity\n") ;
        printf("-vv  strong verbosity\n") ;

        return 0 ;
      }
      else
      {
      }

      cnt++ ;
    }
  }

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
          printf("USBSysBase at 0x%08lx\n", USBSysBase) ;

          if (verbose > 1)
          {
            USBLogPuts(0, "usblist1", "Hello!") ;
            USBLogPrintf(0, "usblist1", "USBSysBase at 0x%08lx\n", (char *)USBSysBase) ;
          }

          if (showcaps)
          {
            struct USBIOReq *usio = NULL ;

            usio = CreateIORequest(port, sizeof(struct USBIOReq)) ;
            if (usio != NULL)
            {
              struct NSDeviceQueryResult ndsqr ;
              memcpy(usio, ioreq, sizeof(struct IORequest)) ;

              memset(&ndsqr, 0, sizeof(ndsqr)) ;

              usio->io_Command = NSCMD_DEVICEQUERY ;
              usio->io_Data    = &ndsqr ;
              usio->io_Length  = sizeof(ndsqr) ;

              DoIO((struct IORequest *)usio) ;
              if (usio->io_Error == 0)
              {
                printf("%s %d.%d\n", USBSysBase->lib_Node.ln_Name, USBSysBase->lib_Version, USBSysBase->lib_Revision) ;
                printf("DeviceType    %d\n", ndsqr.DeviceType) ;
                printf("DeviceSubType %d\n", ndsqr.DeviceSubType) ;
                if (ndsqr.SupportedCommands != NULL)
                {
                  UWORD *ptr = ndsqr.SupportedCommands;
                  while (*ptr != 0)
                  {
                    printcommand(*ptr) ;
                    ptr ++ ;
                  }
                }
              }
              else
              {
                printf("Error=%d\n", usio->io_Error) ;
              }
              DeleteIORequest(usio) ;
            }
          }

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
          cnt = 0 ;	
          /* request all interfaces present in the system */
          do
          {
            rawifc = USBFindInterface( rawifc, 
                                       USBA_SeeClaimed, TRUE,
                                       TAG_DONE ) ;
            if (rawifc != NULL)
            {
              /* Get some data from interface */
              struct USBBusDevDsc *devdsc = NULL ;
              struct USBBusIntDsc *intdsc = NULL ;
              struct USBBusCfgDsc *cfgdsc = NULL ;
              struct USBBusDscHead *vendorname = NULL ;
              struct USBBusDscHead *productname = NULL ;
              struct USBBusDscHead *serialname = NULL ;
              struct USBBusDscHead *interfacename = NULL ;
              struct USBBusDscHead *dsc = NULL ;
              struct USBBusDscHead *hub = NULL ;
              struct USBBusDscHead *hid = NULL ;
              long address = -1 ;
              long speed   = -1 ;
              long parent  = -1 ;
              long dsccnt  = 0 ;
          
              cnt ++ ;
              printf("[%d] rawifc at 0x%08lx\n", cnt, rawifc) ;

              USBGetRawInterfaceAttrs( rawifc,
                                       USBA_DeviceDesc, &devdsc,
                                       USBA_ConfigurationDesc, &cfgdsc,
                                       USBA_InterfaceDesc, &intdsc,
                                       USBA_VendorName, &vendorname,
                                       USBA_ProductName, &productname,
                                       USBA_SerialName, &serialname,
                                       USBA_InterfaceName, &interfacename,
                                       USBA_Parent, &parent,
                                       USBA_Address, &address,
                                       USBA_DeviceSpeed, &speed,
                                       TAG_DONE ) ;

              if ((cTmp != NULL) && (vendorname != NULL))
              {
                strc(vendorname, cTmp) ;
                printf("vendor=\"%s\"\n", cTmp);
              }
              if ((cTmp != NULL) && (productname != NULL))
              {
                strc(productname, cTmp) ;
                printf("product=\"%s\"\n", cTmp) ;
              }
              if ((cTmp != NULL) && (serialname != NULL))
              {
                strc(serialname, cTmp) ;
                printf("serial=\"%s\"\n", cTmp) ;
              }
              if ((cTmp != NULL) && (interfacename != NULL))
              {
                strc(interfacename, cTmp) ;
                printf("interface=\"%s\"\n", cTmp) ;
              }

              if (devdsc != NULL)
              {
                if (verbose > 0)
                {
                  printf("parent=0x%08lx address=%ld speed=%ld\n", parent, address, speed) ;
                  printdsc((struct USBBusDscHead *)devdsc) ;
                }
                else
                {
                  printf("parent=0x%08lx address=%ld speed=%ld\n", parent, address, speed) ;
                  printf("deb USB vers %04x\n", LE_WORD(devdsc->dd_USBVer)) ;
                  printf("dev ID %04lx:%04x\n", LE_WORD(devdsc->dd_VendorID), LE_WORD(devdsc->dd_Product)) ;
                  printf("dev vers=0x%04x\n", LE_WORD(devdsc->dd_USBVer)) ;
                  printf("dev class=%d subclass=%d protocol=%d\n",
                         (int)devdsc->dd_Class,
                         (int)devdsc->dd_Subclass,
                         (int)devdsc->dd_Protocol) ;
                }
                if ((showhub) && 
                    (devdsc->dd_Class    == 9) &&
                    (devdsc->dd_Subclass == 0) &&
                    (devdsc->dd_Protocol == 0))
                {
                  if (showhub == 1)
                  {
                    USBGetRawInterfaceAttrs( rawifc,
                                             USBA_HubDesc, &hub,
                                             TAG_DONE ) ;
                    if (hub != NULL)
                    {
                      printdsc((struct USBBusDscHead *)hub) ;
                    }
                    USBFreeDescriptors((struct USBBusDscHead *) hub) ;
                  }
                  else
                  {
                    struct USBIOReq *usbio ;
                    struct UsbEndPoint *dcp ;
                    struct UsbInterface *ifc ;

                    ifc = USBClaimInterface(rawifc, (APTR)1, NULL) ;
                    if (ifc == NULL)
                    {
                      printf("HUB ERROR : can't get interface\n") ;
                    }
                    else
                    {
                      printf("HUB: got interface at 0x%08lx\n", ifc) ;
                      /* Get Endpoint 0 */
                      dcp = USBGetEndPoint(NULL, ifc, 0) ; 
                      if (dcp == NULL)
                      {
                        printf("HUB ERROR : can't get endpoint 0\n") ;
                      }                        
                      else
                      {
                        usbio = USBAllocRequest(ioreq, NULL) ;
                        if (usbio == NULL)
                        {
                          printf("HUB ERROR : can't allocate request\n") ;
                        }
                        else
                        {
                          LONG err ;
                          char hubdsc[10] ;

                          err = USBEPControlXfer( (struct IORequest *)usbio, /* openreq */
                                                  dcp,   /* usep */
                                                  USBREQC_GET_DESCRIPTOR, /* rcmd */
                                                  USBSDT_DIR_DEVTOHOST|USBSDT_TYP_CLASS, /* rtype */
                                                  0x0029, /* rval */
                                                  0, /* ridx */
                                                  &hubdsc, /* buf */
                                                  9, /* buflen */
                                                  NULL /* taglist */ ) ;
                          if (err == USBERR_NOERROR)
                          {
                            printdsc((struct USBBusDscHead *)hubdsc) ;
                          }
                          else
                          {
                            printf("HUB ERROR : Xfer error %ld\n", err) ;
                          }
                          USBFreeRequest(usbio) ;
                        }
                      }
                      USBDeclaimInterface(ifc) ;
                    }
                  }
                }
              }

              if (cfgdsc != NULL)
              {
                if ((verbose > 0) || showhid)
                {
                  dsc = (struct USBBusDscHead *)cfgdsc ;
                  dsccnt = 0 ;
                  while (dsc != NULL)
                  {
                    dsccnt++ ;
                    //printf("  Descriptor #%d\n", dsccnt) ;
                    if (verbose > 0)
                    { 
                      printdsc(dsc) ;
                    }

                    if (dsc->dh_Type == USBDESC_HID)
                    {
                      if (showhid)
                      {
                        if (showhid == 1)
                        {
                          USBGetRawInterfaceAttrs( rawifc,
                                                   USBA_HIDDesc, &hid,
                                                   TAG_DONE ) ;
                          if (hid != NULL)
                          {
                            dumpData((char *)hid, ((char *)hid)[0]) ;                           
                            printdsc((struct USBBusDscHead *)hid) ;
                          }
                          USBFreeDescriptors((struct USBBusDscHead *) hid) ;
                        }
                        else
                        {
                          struct USBHIDDescriptor *hiddsc = (struct USBHIDDescriptor *)dsc ;
                          struct USBIOReq *usbio ;
                          UBYTE *hidbuffer ;
                          ULONG hidlen ;
                          struct UsbEndPoint *dcp ;
                          struct UsbInterface *ifc ;
                        
                          hidlen = LE_WORD(hiddsc->bXDescriptorLengthL << 8 | hiddsc->bXDescriptorLengthH) ;
                          if (hidlen > 0)
                          {
                            hidbuffer = AllocVec(hidlen, MEMF_CLEAR) ;
                            if (hidbuffer == NULL)
                            {
                              printf("HID ERROR : can't allocate %ld bytes for buffer\n", hidlen) ;
                            }
                            else
                            {
                              ifc = USBClaimInterface(rawifc, (APTR)1, NULL) ;
                              if (ifc == NULL)
                              {
                                printf("HID ERROR : Can't get interface\n") ;
                              }
                              else
                              {
                                printf("HID : got interface at 0x%08lx\n", ifc) ;
                                /* Get Endpoint 0 */
                                dcp = USBGetEndPoint(NULL, ifc, 0) ; 
                                if (dcp == NULL)
                                {
                                  printf("HID ERROR : can't get endpoint 0\n") ;
                                }                        
                                else
                                {
                                  usbio = USBAllocRequest(ioreq, NULL) ;
                                  if (usbio == NULL)
                                  {
                                    printf("HID ERROR : can't allocate request\n") ;
                                  }
                                  else
                                  {
                                    LONG err ;

                                    printf(" HID 0x%02x (%ld bytes)\n", hiddsc->bXDescriptorType, hidlen) ;
                                     
                                    err = USBEPControlXfer( (struct IORequest *)usbio, /* openreq */
                                                            dcp,   /* usep */
                                                            USBREQC_GET_DESCRIPTOR, /* rcmd */
                                                            USBSDT_DIR_DEVTOHOST|USBSDT_REC_INTERFACE, /* rtype */
                                                            hiddsc->bXDescriptorType, /* rval */
                                                            0, /* ridx */
                                                            hidbuffer, /* buf */
                                                            hidlen, /* buflen */
                                                            NULL /* taglist */ ) ;
                                    if (err == USBERR_NOERROR)
                                    {
                                      dumpData(hidbuffer, hidlen) ;
                                    }
                                    else
                                    {
                                      printf("HID ERROR : Xfer error %ld\n", err) ;
                                    }
                                    USBFreeRequest(usbio) ;
                                  }
                                }
                                USBDeclaimInterface(ifc) ;
                              }
                              FreeVec(hidbuffer) ;
                            }
                          }
                          else
                          {
                            printf("HID ERROR : id=0x%02x size=%ld\n", hiddsc->bXDescriptorType, hidlen) ;
                          }
                        }
                      }
                    }
                    dsc = USBNextDescriptor(dsc) ;  
                  }
                }
                else
                {
                  printf("cfg numints=%d\n", (int)cfgdsc->cd_NumInterfaces) ;
                  printf("cfg maxpower=%d (%d mA)\n",
                         (int)cfgdsc->cd_MaxPower,
                         (int)cfgdsc->cd_MaxPower*2) ;
                }
              }

              if (intdsc != NULL)
              {
                if (verbose > 0)
                {
                  printdsc((struct USBBusDscHead *)intdsc) ;
                }
                else
                {
                  printf("int InterfaceID=%d\n", (int)intdsc->id_InterfaceID) ;
                  printf("int AltSetting=%d\n", (int)intdsc->id_AltSetting) ;
                  printf("int class=%d subclass=%d protocol=%d\n",
                         (int)intdsc->id_Class,
                         (int)intdsc->id_Subclass,
                         (int)intdsc->id_Protocol) ;
                }
              }

              USBFreeDescriptors((struct USBBusDscHead *) devdsc) ;
              USBFreeDescriptors((struct USBBusDscHead *) cfgdsc) ;
              USBFreeDescriptors((struct USBBusDscHead *) intdsc) ;
              USBFreeDescriptors((struct USBBusDscHead *) vendorname) ;
              USBFreeDescriptors((struct USBBusDscHead *) productname) ;
              USBFreeDescriptors((struct USBBusDscHead *) serialname) ;
              USBFreeDescriptors((struct USBBusDscHead *) interfacename) ;

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

        if (verbose > 1)
        {
          USBLogPuts(0, "usblist1", "Bye!") ;
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


