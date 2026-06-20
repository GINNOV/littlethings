/****************************************************************/
/* usbprint.c                                                   */
/****************************************************************/
/*                                                              */
/* Print a file on the first usb printer interface found        */
/* GP                                                           */
/*                                                              */
/****************************************************************/
/*                                                              */
/* Modification history                                         */
/* ====================                                         */
/* 10-Feb-2013 List printer interfaces                          */
/* 02-Feb-2013 Add function driver title                        */
/* 15-May-2011 Add buffers argument                             */
/* 11-Oct-2010 TagItems                                         */
/* 07-Oct-2010 Traces                                           */
/* 05-Jan-2009 Maybe some problems with huge files...           */
/* 03-Jan-2009 Improve speed                                    */
/* 10-Nov-2008 errors                                           */
/* 31-Oct-2008 select printer                                   */
/* 27-Sep-2008 print a file                                     */
/****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <time.h>

#include <exec/exec.h>
#include <usb/usb.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/usbsys.h>

/* remove the following include to be 2.04 and higher compatible only */
#define WB33_COMPATIBLE
#define WB33_BESTCODE
#define WB33_PORTS
#define WB33_IO
#include "v31lib.h"

/* bRequest (sd_Request) specific to printers */
#define USBREQC_GET_DEVICE_ID      0
#define USBREQC_GET_PORT_STATUS    1
#define USBREQC_SOFT_RESET         2

char tmp[255] ;
char *prgname = "usbprint" ;

void DumpBuf( UBYTE *buf, ULONG len )
{
  while (len--)
  {
    printf("%02lx", (ULONG)(*buf)) ;
    buf++;
  }
  printf("\n") ;
}

struct Library *USBSysBase = NULL ;

int main(int argc, char *argv[])
{
  FILE *f = NULL ;
  long datasize  = 0 ;
  long totalsize = 0 ;
  long chunksize = 64 ;
  long readsize  = 0 ;
  long error     = 0 ;
  long retry     = 0 ;
  long nbuffers  = 1 /* 1000 */ ; /* 64 * 1000 = 64000 */
  unsigned char *data = NULL ;
  struct MsgPort *port ;
  struct IORequest *openreq ;
  struct UsbRawInterface *rawifc ;
  struct UsbInterface *ifc ;
  BOOL loop    = FALSE ;
  BOOL success = FALSE ;
  long nbprinters = 0 ;
  struct USBNotifyMsg *nmsg ;
  struct USBIOReq *usbior ;
  struct USBBusEPDsc epdsc ;
  struct UsbEndPoint *ep = NULL ;
  struct UsbEndPoint *ep0 = NULL ;
  int altsetting, interfacenum ;
  BOOL checkportstatus = FALSE ;
  BOOL debugprint      = FALSE ;
  BOOL printerlist     = FALSE ;
  BOOL helpme          = FALSE ;
  BOOL reset           = FALSE ;
  BOOL fileok          = FALSE ;
  int len = 0 ;
  int i ;
  int maxargc = argc ;
  time_t t1, t2 ;
  struct Library *SysBase = *(struct Library **)4 ;

  if (((struct Library *)SysBase)->lib_Version < 31)
  {
    printf("System version too old\n") ;
    exit(20) ;
  } 

  if (argc > 1)
  {
    if (argc > 1)
    {
      int i ;
      for ( i = 1 ; i < argc ; i++ )
      {
        if (stricmp("help", argv[i]) == 0)
        {
          helpme = TRUE ;
          maxargc -- ;
        }

        if (stricmp("list", argv[i]) == 0)
        {
          printerlist = TRUE ;
          maxargc -- ;
        }

        if (stricmp("check", argv[i]) == 0)
        {
          checkportstatus = TRUE ;
          maxargc -- ;
        }

        if (stricmp("reset", argv[i]) == 0)
        {
          reset = TRUE ;
          maxargc -- ;
        }

        if (stricmp("debug", argv[i]) == 0)
        {
          debugprint = TRUE ;
          maxargc -- ;
        }

        if (strncmp("buffers=", argv[i], 8) == 0)
        {
          nbuffers = atol(&argv[i][8]) ;
          if (nbuffers < 1)
          {
            nbuffers = 1 ;
          }
          maxargc -- ;
        }

        if (i == 1)
        {
          if (maxargc == argc)
          {
            fileok = TRUE ;
          }
        }
      }
    }

    //printf("USBPrinter (%ld, %ld) %s\n", argc, maxargc, argv[1]) ;
  }
  else
  {
    printerlist = TRUE ;
  }

  if (helpme)
  {
    printf("Usage: %s file [CHECK][RESET][DEBUG][BUFFERS=][LIST]\n", argv[0]) ;
    printf("Send data to a usb ieee1284 device via ANAIIS stack\n") ;
    exit(10) ;
  } 

  port = CreateMsgPort() ;
  if (port != NULL)
  {
    openreq = CreateIORequest( port, sizeof( struct IORequest ) ) ;
    if (openreq != NULL)
    {
      if (OpenDevice("anaiis.device", 0, openreq, 0) == 0)
      {
        success = TRUE ;
        USBSysBase = (struct Library *) openreq->io_Device ;
      }
      else
      {
        if (OpenDevice("usbsys.device", 0, openreq, 0) == 0 )
        {
          success = TRUE ;
          USBSysBase = (struct Library *) openreq->io_Device;
        }
      }

      if (success)
      {
        nbprinters = 0 ;

        rawifc = NULL ;
        do
        {
          rawifc = USBFindInterface( rawifc,
                                     USBA_Class, 7,
                                     USBA_Subclass, 1,
                                     TAG_END ) ;
          if (rawifc != NULL)
          {
            ifc = USBClaimInterface(rawifc, (APTR) 1L, NULL) ;
            if (ifc != NULL)
            {
              UBYTE status = 0 ;
              struct USBBusSetupData ubsd ;
              struct USBBusIntDsc  *intdsc = NULL ;
              struct USBBusCfgDsc  *cfgdsc = NULL ;
              struct USBBusDscHead *prodsc = NULL ;
              nbprinters ++ ;

              USBGetRawInterfaceAttrs(rawifc,
                                      USBA_InterfaceDesc, &intdsc,
                                      USBA_ConfigurationDesc, &cfgdsc,
                                      USBA_ProductName, &prodsc,
                                      TAG_DONE) ;

              ep0 = USBGetEndPoint(NULL, ifc, 0) ;

              if ((ep0 != NULL) && (intdsc != NULL))
              {
                usbior = USBAllocRequest(openreq, USBA_TraceIO, debugprint, TAG_END) ;
                if (usbior != NULL)
                {
                  memset(&ubsd, 0, sizeof(ubsd)) ;

                  len = 1 ;
                  ubsd.sd_RequestType = USBSDT_DIR_DEVTOHOST|USBSDT_TYP_CLASS|USBSDT_REC_INTERFACE /* 0xa1 */ ;
                  ubsd.sd_Request     = USBREQC_GET_PORT_STATUS ;
                  ubsd.sd_Value       = LE_WORD(0) ;
                  ubsd.sd_Index       = LE_WORD(intdsc->id_InterfaceID) ;
                  ubsd.sd_Length      = LE_WORD(len) ;

                  usbior->io_Error       = 0 ;
                  usbior->io_Length      = len ;
                  usbior->io_Data        = &status ;
                  usbior->io_Offset      = 0;
                  usbior->io_SetupData   = &ubsd ;
                  usbior->io_SetupLength = sizeof(ubsd) ;
                  usbior->io_Command     = CMD_READ ;
                  usbior->io_EndPoint    = ep0 ;
                  DoIO((struct IORequest *)usbior) ;

                  len = 2 ;
                  tmp[0] = 0 ;
                  tmp[1] = 0 ;
                  ubsd.sd_RequestType = USBSDT_DIR_DEVTOHOST|USBSDT_TYP_CLASS|USBSDT_REC_INTERFACE /* 0xa1 */ ;
                  ubsd.sd_Request     = USBREQC_GET_DEVICE_ID ;
                  ubsd.sd_Value       = LE_WORD(cfgdsc->cd_ConfigID) ;
                  ubsd.sd_Index       = LE_WORD(intdsc->id_AltSetting << 8 | intdsc->id_InterfaceID) ;
                  ubsd.sd_Length      = LE_WORD(len) ;
                    
                  usbior->io_Error       = 0 ;
                  usbior->io_Length      = len ;
                  usbior->io_Data        = tmp ;
                  usbior->io_Actual      = 0 ;
                  usbior->io_Offset      = 0 ;
                  usbior->io_SetupData   = &ubsd ;
                  usbior->io_SetupLength = sizeof(ubsd) ;
                  usbior->io_Command     = CMD_READ ;
                  usbior->io_EndPoint    = ep0 ;
                  DoIO((struct IORequest *)usbior) ;

                  len = (tmp[1] << 8 | tmp[0]) ;
                  if (len > 0)
                  {
                    len += 2 ;
                    ubsd.sd_RequestType = USBSDT_DIR_DEVTOHOST|USBSDT_TYP_CLASS|USBSDT_REC_INTERFACE /* 0xa1 */ ;
                    ubsd.sd_Request     = USBREQC_GET_DEVICE_ID ;
                    ubsd.sd_Value       = LE_WORD(cfgdsc->cd_ConfigID) ;
                    ubsd.sd_Index       = LE_WORD(intdsc->id_AltSetting << 8 | intdsc->id_InterfaceID) ;
                    ubsd.sd_Length      = LE_WORD(len) ;
                    
                    usbior->io_Error       = 0 ;
                    usbior->io_Length      = len ;
                    usbior->io_Data        = tmp ;
                    usbior->io_Actual      = 0 ;
                    usbior->io_Offset      = 0 ;
                    usbior->io_SetupData   = &ubsd ;
                    usbior->io_SetupLength = sizeof(ubsd) ;
                    usbior->io_Command     = CMD_READ ;
                    usbior->io_EndPoint    = ep0 ;
                    DoIO((struct IORequest *)usbior) ;

                    /* make a C string */
                    for (i=0; i<len-2; i++)
                    {
                      tmp[i] = tmp[i+2] ;
                    }
                    tmp[len-2] = 0 ;
                  }
                  else
                  {
                    tmp[0] = 0 ;
                    if ((prodsc->dh_Length) && (prodsc->dh_Type == USBDESC_STRING))
                    {
                      char *c = (char *)prodsc ;
                      c += 2 ;
                      len = (prodsc->dh_Length - 2) / 2 ;
                      for ( i = 0 ; i < len ; i ++ )
                      {
                        tmp[i] = *c++;
                        c++ ;
                      }
                      tmp[len] = 0 ;
                    }
                  }

                  if ((debugprint) || (printerlist))
                  {
                    printf("printer#%ld (%ld,%ld,%ld) (cfg=%ld,int=%ld,alt=%ld) status=%02lx ",
                           nbprinters,
                           intdsc->id_Class,
                           intdsc->id_Subclass,
                           intdsc->id_Protocol,
                           cfgdsc->cd_ConfigID,
                           intdsc->id_InterfaceID,
                           intdsc->id_AltSetting,
                           status) ;
                    printf("\"%s\"\n", tmp) ;

                    if (1)
                    {
                      ULONG args[8] ;
                      args[0] = nbprinters ;
                      args[1] = intdsc->id_Class ;
                      args[2] = intdsc->id_Subclass ;
                      args[3] = intdsc->id_Protocol ;
                      args[4] = cfgdsc->cd_ConfigID ;
                      args[5] = intdsc->id_InterfaceID ;
                      args[6] = intdsc->id_AltSetting ;
                      args[7] = status ;
                      USBLogVPrintf(0, prgname, "printer#%ld (%ld,%ld,%ld) (cfg=%ld,int=%ld,alt=%ld) status=%02lx\n", args) ;
                    }
                  }
                  USBFreeRequest(usbior) ;
                }
              }
              USBFreeDescriptors((struct USBBusDscHead *) intdsc) ;
              USBFreeDescriptors((struct USBBusDscHead *) cfgdsc) ;
              USBFreeDescriptors((struct USBBusDscHead *) prodsc) ;
              USBDeclaimInterface( ifc ) ;
            }
            USBUnlockInterface( rawifc ) ;
          }
        } while (rawifc != NULL) ;
        
        if (nbprinters == 0)
        {
          if ((debugprint) || (printerlist))
          {
            USBLogPuts(1, prgname, "sorry, no printer!") ;
            printf("Sorry, no printer!\n") ;
          }
          error = -1 ;
        }
        else
        {
          if (nbprinters > 1)
          {
            if ((debugprint) || (printerlist))
            {
              printf("%ld printer interfaces are present\n", nbprinters) ;

              if (1)
              {
                ULONG args[1] ;
                args[0] = nbprinters ;
                USBLogVPrintf(0, prgname, "%ld printer interfaces are present\n", args) ;
              }
            }

            if (debugprint)
            {
              printf("using the first printer interface found\n") ;
              USBLogPuts(0, prgname, "using the first printer interface found") ;
            }
            error = 0 ;
          }
          else
          {
            error = 0 ;
          }

          if (printerlist)
          {
            error = 1 ;
          }
        }

        if (error == 0)
        {
          rawifc = USBFindInterface( NULL,
                                     USBA_Class, 7,
                                     USBA_Subclass, 1,
                                     TAG_END ) ;
          if (rawifc != NULL)
          {
            ifc = USBClaimInterface( rawifc, (APTR) 1L, port ) ;
            if (ifc != NULL)
            {
              struct USBBusDscHead *dsclist ;
              struct USBBusDscHead *dsc ;

              dsclist = USBIntGetAltSetting(openreq,
                                            ifc,
                                            NULL) ;
              if (dsclist != NULL)
              {
                error = -3 ;
                dsc = dsclist ;
                while (dsc != NULL)
                {
                  if (debugprint)
                  {
                    //printf("%ld (%ld bytes)\n", dsc->dh_Type, dsc->dh_Length) ;
                  }

                  switch (dsc->dh_Type)
                  {
                    case USBDESC_INTERFACE :
                    {
                      struct USBBusIntDsc *intdsc = (struct USBBusIntDsc *)dsc ;
                      altsetting   = intdsc->id_AltSetting ;
                      interfacenum = intdsc->id_InterfaceID ;
                      break ;
                    }

                    case USBDESC_ENDPOINT :
                    {
                      struct USBBusEPDsc epdsccp = *(struct USBBusEPDsc *)dsc ;
 
                      switch (epdsccp.ed_Attributes)
                      {
                        case USBEPTT_BULK :
                        {
                          if (epdsccp.ed_Address & 0x80)
                          {
                            // IN
                          }
                          else
                          {
                            // OUT
                            
                            if (debugprint)
                            {
                              printf("endpoint 0x%02lx\n", epdsccp.ed_Address) ;

                              if (1)
                              {
                                ULONG args[1] ;
                                args[0] = epdsccp.ed_Address ;
                                USBLogVPrintf(0, prgname, "endpoint 0x%02lx\n", args) ;
                              }
                            }

                            epdsc = epdsccp ;
                            error = 0 ;
                          }
                          break ;
                        }

                        case USBEPTT_INTERRUPT :
                        {
                          break ;
                        }
                      }
                      break ;
                    }
                  }
                  dsc = USBNextDescriptor(dsc) ;
                }
                USBFreeDescriptors(dsclist) ;
              }
              else
              {
                if (debugprint)
                {
                  puts( "Error getting interface!" ) ;
                  USBLogPuts(-1, prgname, "Error getting interface") ;
                }
                error = -2 ;
              }

              if (error == 0)
              {
                usbior = USBAllocRequest(openreq, USBA_TraceIO, debugprint, TAG_END) ;
                if (usbior != NULL)
                {
                  ep = USBGetEndPoint(NULL, ifc, epdsc.ed_Address) ;
                  if (ep == NULL)
                  {
                    if (debugprint)
                    {
                      printf("can't get ep %02x\n", epdsc.ed_Address) ;

                      if (1)
                      {
                        ULONG args[1] ;
                        args[0] = epdsc.ed_Address ;
                        USBLogVPrintf(-1, prgname, "can't get ep %ld\n", args) ;
                      }
                    }
                  }
                  else
                  {
                    chunksize = nbuffers * LE_WORD(epdsc.ed_MaxPacketSize) ;
                  }

                  ep0 = USBGetEndPoint(NULL, ifc, 0) ;
                  if (ep0 == NULL)
                  {
                    printf("can't get ep0\n") ;
                    USBLogPuts(-1, prgname, "can't get ep0"); 
                  }

                  if (debugprint)
                  {
                    printf("ep  %02x 0x%08lx\n", epdsc.ed_Address, ep) ;
                    printf("ep0    0x%08lx\n", ep0) ;  
                  }

                  USBIntSetAltSettingA(openreq, ifc, altsetting, NULL) ;
                  if (debugprint)
                  {
                    printf("altsetting %ld\n", altsetting) ;
                  }

                  USBSetInterfaceAttrs(ifc, USBA_FD_Title, "usbprint", TAG_DONE) ;

                  if (reset)
                  {
                    struct USBBusSetupData ubsd ;

                    ubsd.sd_RequestType = USBSDT_DIR_HOSTTODEV|USBSDT_TYP_CLASS|USBSDT_REC_INTERFACE /* 0x21 */ ;
                    ubsd.sd_Request     = USBREQC_SOFT_RESET ;
                    ubsd.sd_Value       = LE_WORD(0) ;
                    ubsd.sd_Index       = LE_WORD(interfacenum) ;
                    ubsd.sd_Length      = LE_WORD(0) ;
                 
                    usbior->io_Error       = 0 ;
                    usbior->io_Length      = 0 ;
                    usbior->io_Data        = NULL ;
                    usbior->io_Actual      = 0 ;
                    usbior->io_Offset      = 0 ;
                    usbior->io_SetupData   = &ubsd ;
                    usbior->io_SetupLength = sizeof(ubsd) ;
                    usbior->io_Command     = CMD_READ ;
                    usbior->io_EndPoint    = ep0 ;

                    DoIO((struct IORequest *)usbior) ;

                    error = usbior->io_Error ;
                    if (debugprint)
                    {
                      printf("reset (1.1 version) (error=%ld)\n", error) ;
                    }

                    if (error != 0)
                    {
                      usbior->io_Error = 0 ;
                      ubsd.sd_RequestType = USBSDT_DIR_HOSTTODEV|USBSDT_TYP_CLASS|USBSDT_REC_OTHER /* 0x23 */ ;
                      DoIO((struct IORequest *)usbior) ;

                      error = usbior->io_Error ;
                      if (debugprint)
                      {
                        printf("reset (1.0 version...) (error=%ld)\n", error) ;
                      }
                    }
                  }

                  if (fileok)
                  {
                    f = fopen(argv[1], "rb") ;
                    if (f != NULL)
                    {
                      fseek(f, 0, SEEK_END) ;
                      datasize = ftell(f) ;
                      fseek(f, 0, SEEK_SET) ;
                      if (datasize <= 0)
                      {
                        printf("huups %ld bytes\n", datasize) ;
                      }
                      else
                      {
                        data = malloc(chunksize) ;
                        if (data == NULL)
                        {
                          printf("Can't allocate %ld bytes\n", chunksize) ;
                        }
                        else
                        {
                          time(&t1) ;
                          loop = TRUE ;
                          do
                          {
                            readsize = fread(data, 1, chunksize, f) ;
                            if (readsize <= 0)
                            {
                              loop = FALSE ;
                            }
                            else
                            {
                              if (debugprint)
                              {
                                printf("read %ld bytes, ", readsize) ;
                              }

                              retry = 10 ;
                              do 
                              {
                                UBYTE status = 0x18 ;

                                if (checkportstatus)
                                {
                                  struct USBBusSetupData ubsd ;

                                  ubsd.sd_RequestType = USBSDT_DIR_DEVTOHOST|USBSDT_TYP_CLASS|USBSDT_REC_INTERFACE /* 0xa1 */ ;
                                  ubsd.sd_Request     = USBREQC_GET_PORT_STATUS ;
                                  ubsd.sd_Value       = LE_WORD(0) ;
                                  ubsd.sd_Index       = LE_WORD(interfacenum) ;
                                  ubsd.sd_Length      = LE_WORD(1) ;

                                  status = 0 ;
                              
                                  usbior->io_Error       = 0 ;
                                  usbior->io_Length      = 1 ;
                                  usbior->io_Data        = &status ;
                                  usbior->io_Actual      = 0 ;
                                  usbior->io_Offset      = 0 ;
                                  usbior->io_SetupData   = &ubsd ;
                                  usbior->io_SetupLength = sizeof(ubsd) ;
                                  usbior->io_Command     = CMD_READ ;
                                  usbior->io_EndPoint    = ep0 ;

                                  DoIO((struct IORequest *)usbior) ;

                                  error = usbior->io_Error ;
                                  if (debugprint)
                                  {
                                    printf("status %02lx (error=%ld)\n", status, error) ;
                                  }
                                }

                                if ( (status & 0x08) && /* Not Error */
                                     (status & 0x10) && /* Select */
                                    !(status & 0x20))   /* Not Paper Empty */
                                {
                                  usbior->io_Error       = 0 ;
                                  usbior->io_Length      = readsize ;
                                  usbior->io_Data        = data ;
                                  usbior->io_Actual      = 0 ;
                                  usbior->io_Offset      = 0;
                                  usbior->io_SetupData   = NULL ;
                                  usbior->io_SetupLength = 0 ;
                                  usbior->io_Command     = CMD_WRITE ;
                                  usbior->io_EndPoint    = ep ;

                                  DoIO((struct IORequest *)usbior) ;

                                  error = usbior->io_Error ;
                                  switch (error)
                                  {
                                    case 0 :
                                    {
                                      totalsize += readsize ;
                                      retry = 0 ;
                                      if (debugprint)
                                      {
                                        printf("write %ld bytes (%ld bytes)\n", readsize, totalsize) ;
                                      }
                                      break ;
                                    }

                                    default :
                                    {
                                      Delay(5) ;
                                      printf(" error %ld, retry #%ld\n", error, 9-retry) ;
                                      retry-- ;
                                      if (retry == 0)
                                      {
                                        printf("Can't print\n") ;
                                        loop = FALSE ;
                                      }
                                      break ;
                                    }
                                  }
                                }
                                else
                                {
                                  printf("printer not ready, status=%02lx\n", status) ;
                                  Delay(10) ;
                                  retry = 10 ;
                                }

                                do
                                {
                                  nmsg = (struct USBNotifyMsg *)GetMsg(port) ;
                                  if (nmsg != NULL)
                                  {
                                    printf("got notification Type=%ld ObjRef=%ld\n", nmsg->Type, nmsg->ObjRef) ;
                                    switch(nmsg->Type) 
                                    {
                                      case USBNM_TYPE_FUNCTIONDETACH :
                                      case USBNM_TYPE_INTERFACEDETACH :
                                      {
                                        loop = FALSE ;
                                        break ;
                                      }
                                    }
                                    ReplyMsg((struct Message *) nmsg) ;
                                  }
                                } while (nmsg != NULL) ;
                              } while (loop && retry > 0) ;
                            }
                          } while (loop) ;

                          time(&t2) ;

                          printf("wrote %ld bytes in %ld seconds\n", totalsize, t2-t1) ;
                          if (t2-t1 > 0)
                          {
                            printf("%ld bytes per second\n", totalsize/(t2-t1)) ;
                          }
                          free(data) ;
                          data = NULL ;
                          datasize = 0 ;
                        }
                      }
                      fclose(f) ;
                      f = NULL ;
                      printf("done\n") ;
                    }
                    else
                    {
                      printf("Can't open file %s\n", argv[1]) ;
                    }
                  }
                  USBFreeRequest(usbior) ;
                }
              }
              /* Declaim ifc */
              USBDeclaimInterface( ifc ) ;
            }
            /* Unlock ifc */
            USBUnlockInterface( rawifc ) ;
          }
        }
        CloseDevice(openreq) ;
      }
      else
      {
        printf("Sorry, no usb stack\n") ;
      }
      DeleteIORequest(openreq) ;
    }
    DeleteMsgPort(port) ;
  }
  printf ("Bye\n") ;

  return 0 ;
}

