/****************************************************************/
/* ieee1284.c                                                   */
/****************************************************************/
/*                                                              */
/* interface between usb and ieee1284                           */
/* very limited parallel.device                                 */
/*                                                              */
/****************************************************************/
/*                                                              */
/* Modification history                                         */
/* ====================                                         */
/* 15-Mar-2011 Change task to process... prt: will work now     */
/* 12-Feb-2011 Change USBAllocRequest, use amiga.lib            */
/* 22-Jan-2011 Hangup at 100*epsize=6400                        */
/* 25-Nov-2010 This version is working!!                        */
/* 09-Jul-2009 Remove some macros                               */
/* 03-Jan-2009 Improve speed                                    */
/* 15-Dec-2008 Now bufferize at the endpoint size               */
/* 02-Dec-2008 Traces                                           */
/* 30-Nov-2008 usbprint                                         */
/* 08-Nov-2008 need to be recoded                               */
/* 19-Feb-2008 OS4 includes                                     */
/* 14-Feb-2008 register                                         */
/* 04-Oct-2007 process stuff                                    */
/* 30-Sep-2007 crash using printer.device                       */
/* 04-Sep-2007 creation                                         */
/****************************************************************/

#define BUFFERSIZE 100
#define TRACE 1
#define PRINTERPROCESS 1
#define DOOUTPUT 1

#define VERSION      1
#define REVISION     0
#define VSVERSION  "1"
#define VSREVISION "00"
#define DEV_VSTRING "ANAIIS ieee1284.device " VSVERSION "." VSREVISION " (" __DATE__ ")\r\n"
#define DEV_NAME "ieee1284.device"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

#include <exec/exec.h>
#include <clib/alib_protos.h>
#include <exec/memory.h>
#include <exec/devices.h>
#include <exec/resident.h>
#include <exec/errors.h>
#include <exec/io.h>
#include <dos/dos.h>
#include <usb/usb.h>

#include <devices/parallel.h>

#define __NOLIBBASE__
#define __USE_BASETYPE__
#include <proto/exec.h>
#if PRINTERPROCESS
#include <proto/dos.h> 
#endif
#include <proto/usbsys.h>

#include "compiler.h"

/* bRequest specific to printers */
#define USBREQC_GET_DEVICE_ID      0
#define USBREQC_GET_PORT_STATUS    1
#define USBREQC_SOFT_RESET         2

UBYTE DevName[] = { DEV_NAME } ;
UBYTE DevID[]   = { DEV_VSTRING } ;

/* query stuff */
#define NSCMD_DEVICEQUERY 0x4000

struct NSDeviceQueryResult
{
  /*
   ** Standard information
   */

  ULONG   DevQueryFormat;         /* this is type 0               */
  ULONG   SizeAvailable;          /* bytes available              */

  /*
  ** Common information (READ ONLY!)
  */
  UWORD   DeviceType;             /* what the device does         */
  UWORD   DeviceSubType;          /* depends on the main type     */
  UWORD   *SupportedCommands;     /* 0 terminated list of cmd's   */

  /* May be extended in the future! Check SizeAvailable! */
};

#define NSDEVTYPE_PARALLEL 12  /* like parallel.device */

/* commands for the process */
#define CMD_OpenUnit  (CMD_NONSTD+2100)
#define CMD_CloseUnit (CMD_NONSTD+2101)

struct SegList
{
  ULONG length ;
  ULONG next ;
  UWORD jumpcode ;
  APTR entry ;
  UWORD pad ;
} ;

/* Unit */
struct DeviceUnit
{
  struct Unit            du_Unit ;
  long                   du_Index ;
  struct Task            *du_Task ;
  struct DeviceBase      *du_DeviceBase ;
  struct MsgPort         *du_port ;
  struct IORequest       *du_openreq ;
  struct UsbRawInterface *rawifc ;
  struct UsbInterface    *ifc ;
  
  int                    interfacenum ;
  int                    altsetting ;
  UBYTE                  *wbuf ;  /* buffer */
  ULONG                  wsiz ;   /* buffer size */
  ULONG                  widx ;   /* index */
  ULONG                  writecnt ;
  ULONG                  epsize ; /* ep out size */
  struct UsbEndPoint     *ep ;    /* ep out */
  struct UsbEndPoint     *ep0 ;   /* ep0 */
} ;

/* Device */
struct DeviceBase
{
  struct Library    db_Library ;
  UWORD             pad0 ;
  BPTR              db_SegList ;
  struct Library   *db_SysBase ;
  struct Library   *db_USBSysBase ;
#if PRINTERPROCESS
  struct Library   *db_DOSBase ;
#endif
  LONG              db_Counter ;
  struct DeviceUnit db_Unit[10] ; /* 10 but only 1 is managed */

  ULONG segdata[8] ;  
} ;


#define NUM_ENTRIES(t) (sizeof(t) / sizeof(t[0]))

void ASM SDS procmainloop(void) ;

/* Send a special command to a device unit process. */
static ASM SDS void SendCmd(
A0 struct DeviceBase *db,
A1 struct DeviceUnit *du,
D0 UWORD command
)
{
  struct IORequest ior;
  struct MsgPort port;

  /* Initialize the local message reply port. */
  memset(&port,0,sizeof(port)) ;
  port.mp_Flags = PA_SIGNAL ;
  port.mp_SigBit = SIGB_SINGLE ;
  port.mp_SigTask = FindTask(NULL) ;
  NewList(&port.mp_MsgList) ;

  /* Now initialize a local I/O request. */
  memset(&ior,0,sizeof(ior)) ;
  ior.io_Message.mn_ReplyPort = &port ;
  ior.io_Message.mn_Length    = sizeof(ior) ;
  ior.io_Unit                 = (struct Unit *)du ;
  ior.io_Device               = (struct Device *)db ;
  ior.io_Command              = command ;

  /* Clear the reply port signal since it's of the
   * one shot type.
   */
  SetSignal(0,SIGF_SINGLE) ;

  PutMsg(&ior.io_Unit->unit_MsgPort,(struct Message *)&ior) ;
  WaitPort(&port) ;
}


static void ASM SDS DevBeginIO(
A1 struct IOExtPar *ior,
A6 struct DeviceBase *db
)
{
  struct DeviceUnit *du = (struct DeviceUnit *)ior->IOPar.io_Unit;

  ior->IOPar.io_Message.mn_Node.ln_Type = NT_MESSAGE ;
  ior->IOPar.io_Error                   = 0 ;

  switch(ior->IOPar.io_Command)
  {
    case CMD_READ:
    {
      ior->IOPar.io_Actual = 0 ;
      break ;
    }

    case CMD_START:
    case CMD_STOP:
    case CMD_FLUSH:
    {
      break ;
    }

    case CMD_CLEAR:
    case CMD_RESET:
    case CMD_WRITE:
    case PDCMD_QUERY:
    {
      ior->IOPar.io_Flags &= ~IOF_QUICK ;
      ior->IOPar.io_Flags |= IOPARF_QUEUED ;
      PutMsg(&du->du_Unit.unit_MsgPort, (struct Message *)ior);
      ior = NULL ;
      break ;
    }

    case PDCMD_SETPARAMS:
    {
      if (ior->io_ParFlags & PARF_SHARED)
      {
        ior->IOPar.io_Error = ParErr_DevBusy ;
      }
      break ;
    }

    case NSCMD_DEVICEQUERY:
    {
      if (ior->IOPar.io_Data != NULL && ior->IOPar.io_Length >= sizeof(struct NSDeviceQueryResult))
      {
        STATIC UWORD SupportedCommands[] =
        {
          CMD_READ,
          CMD_START,
          CMD_STOP,
          CMD_RESET,
          CMD_CLEAR,
          CMD_WRITE,
          CMD_FLUSH,
          PDCMD_QUERY,
          PDCMD_SETPARAMS,
          NSCMD_DEVICEQUERY,
          0
        } ;

        struct NSDeviceQueryResult * qr = ior->IOPar.io_Data ;
        qr->SizeAvailable               = 16 ;
        qr->DeviceType                  = NSDEVTYPE_PARALLEL ;
        qr->DeviceSubType               = 0 ;
        qr->SupportedCommands           = SupportedCommands ;
        ior->IOPar.io_Actual = 16;
      }
      else
      {
        ior->IOPar.io_Error = IOERR_BADLENGTH;
      }
      break ;
    }

    default:
    {
      ior->IOPar.io_Error = IOERR_NOCMD ;
      break ;
    }
  }

  if (ior != NULL)
  {
    if (!(ior->IOPar.io_Flags & IOF_QUICK))
    {
      if (ior->IOPar.io_Message.mn_ReplyPort != NULL)
      {
        ReplyMsg((struct Message *)ior) ;
      }
    }
  }
}

/* Attempt to abort an I/O request that is current being processed. */
static long ASM SDS DevAbortIO(
A1 struct IOExtPar *ior,
A6 struct DeviceBase *db
)
{
  LONG result = 0 ;

  Forbid() ;

  /* Is this request possibly in use? */
  if(ior->IOPar.io_Message.mn_Node.ln_Type != NT_REPLYMSG &&
     !(ior->IOPar.io_Flags & IOF_QUICK))
  {
    /* Is this request still queued? */
    if(ior->IOPar.io_Flags & IOPARF_QUEUED)
    {
      /* Remove it from the queue. */
      Remove((struct Node *)ior);

      ior->IOPar.io_Flags &= ~IOPARF_QUEUED ;
      ior->IOPar.io_Flags |= IOPARF_ABORT ;

      result = IOERR_ABORTED ;
      ior->IOPar.io_Error = result ;

      ReplyMsg((struct Message *)ior);
    }
  }

  Permit();

  return result ;
}

/* Initialize device driver. */
static struct DeviceBase * ASM SDS DevInit(
A0 BPTR segList,
D0 struct DeviceBase *db,
A6 struct Library *ExecBase
)
{
  struct DeviceBase *result = NULL;
  ULONG i ;

  db->db_SysBase = ExecBase ;
  db->db_SegList = segList;
  db->db_Library.lib_Version  = VERSION ;
  db->db_Library.lib_Revision = REVISION;

  db->db_Library.lib_Node.ln_Type = NT_DEVICE ;
  db->db_Library.lib_Node.ln_Name = DevName ;
  db->db_Library.lib_Flags = LIBF_SUMUSED|LIBF_CHANGED ;
  db->db_Library.lib_IdString = DevID ;
  
  db->db_Counter = 0;

  /* Initialize the individual units. */
  memset(db->db_Unit,0,sizeof(db->db_Unit));

  for (i = 0 ; i < NUM_ENTRIES(db->db_Unit) ; i++)
  {
    db->db_Unit[i].du_Task  = NULL ;
    db->db_Unit[i].du_Index = i ;

    db->db_Unit[i].du_Unit.unit_MsgPort.mp_Flags = PA_SIGNAL ;
    db->db_Unit[i].du_Unit.unit_MsgPort.mp_SigBit = SIGBREAKB_CTRL_F ;
    NewList(&db->db_Unit[i].du_Unit.unit_MsgPort.mp_MsgList) ;

    db->db_Unit[i].du_Unit.unit_flags   = 0 ;
    db->db_Unit[i].du_Unit.unit_pad     = 0 ;
    db->db_Unit[i].du_Unit.unit_OpenCnt = 0 ;
  }
  result = db ;

  if (result == NULL)
  {
    FreeMem((BYTE *)db - db->db_Library.lib_NegSize,
             db->db_Library.lib_NegSize + db->db_Library.lib_PosSize);
  }

  return result ;
}

/****************************************************************************/
/* Open the device driver. */
static long ASM SDS DevOpen(
D0 ULONG unitNumber,
D1 ULONG flags,
A1 struct IOExtPar *ior,
A6 struct DeviceBase *db
)
{
  LONG result = ParErr_InitErr ;
#if PRINTERPROCESS
  struct Library *DOSBase = NULL ;
  struct SegList *segptr  = NULL ;
  struct MsgPort *process = NULL ;
#endif

  if ((unitNumber >= 0) && (unitNumber < NUM_ENTRIES(db->db_Unit)))
  {
    struct DeviceUnit * du = &db->db_Unit[unitNumber] ;

    if (db->db_Library.lib_OpenCnt == 0)
    {
      /* First time the library is opened */
      db->db_USBSysBase = NULL ;
#if PRINTERPROCESS
      db->db_DOSBase = OpenLibrary("dos.library", 0) ;
#endif
    }
    db->db_Library.lib_OpenCnt++ ;

    /* If this unit is not currently in use,
     * launch the associated process.
     */
    if (du->du_Unit.unit_OpenCnt == 0)
    {
      du->du_DeviceBase = db ;
      du->du_Unit.unit_OpenCnt++;

#if PRINTERPROCESS
      /* Create process */
      segptr = (struct SegList *)((UBYTE *)db->segdata + 4) ;
      segptr = (struct SegList *)MKBADDR(segptr) ;
      segptr = (struct SegList *)BADDR(segptr) ;
      segptr->length   = 16 ;
      segptr->next     = 0 ;
      segptr->jumpcode = 0x4ef9 ;
      segptr->entry    = (APTR) procmainloop ;
      
      DOSBase = db->db_DOSBase ;
      if (DOSBase != NULL)
      {
        process = CreateProc(db->db_Library.lib_Node.ln_Name, 0, MKBADDR(segptr), 8000) ;
      }
      if (process == NULL)
      {
        du->du_Task = NULL ;
      }
      else
      {
        du->du_Task = (struct Task *)(((UBYTE *)process) - sizeof(struct Task)) ;
      }
#else
      /* Create task */
      du->du_Task = CreateTask(db->db_Library.lib_Node.ln_Name,
                               0,
                               procmainloop,
                               8000) ;
#endif

      if (du->du_Task != NULL)
      {
        du->du_Unit.unit_MsgPort.mp_SigTask = du->du_Task ;
        du->du_Task->tc_UserData = du ;

        Signal(du->du_Task, SIGF_SINGLE) ;

        SendCmd(db, du, CMD_OpenUnit) ;

#if TRACE
        if (db->db_USBSysBase != NULL)
        {
          struct Library *USBSysBase = db->db_USBSysBase ; 
          if (TRACE)
          {
            USBLogPuts(0, DevName, "Open") ;
          }
        }
#endif

        ior->IOPar.io_Unit = (struct Unit *)du ;
        ior->IOPar.io_Message.mn_Node.ln_Type = NT_REPLYMSG ;
        //ior->IOPar.io_Unit->unit_OpenCnt++ ;
        ior->io_Status = 0 ;

        //db->db_Library.lib_OpenCnt++ ;

        db->db_Library.lib_Flags &= ~LIBF_DELEXP ;
        result = 0 ;
      }

      //du->du_Unit.unit_OpenCnt-- ;
    }

    //db->db_Library.lib_OpenCnt-- ;
  }
  else
  {
    result = IOERR_OPENFAIL ;
  }

  if (result != 0)
  {
    ior->IOPar.io_Device = NULL ;
    ior->IOPar.io_Unit   = NULL ;
  }
  else
  {
    ior->io_Status |= IOPTF_RWDIR | IOPTF_PARSEL | IOPTF_PAPEROUT ; 
  }

  ior->IOPar.io_Error = result ;

  return result ;
}

/****************************************************************************/

/* Remove this driver from memory, if possible. */
static BPTR ASM SDS DevExpunge(
A6 struct DeviceBase * db
)
{
  BPTR result = 0 ;

  if (db->db_Library.lib_OpenCnt == 0)
  {
    result = db->db_SegList ;

    Remove((struct Node *)db) ;
    
    FreeMem((BYTE *)db - db->db_Library.lib_NegSize,
            db->db_Library.lib_NegSize + db->db_Library.lib_PosSize) ;
  }
  else
  {
    db->db_Library.lib_Flags |= LIBF_DELEXP ;
  }

  return result ;
}

/****************************************************************************/

/* Close a device unit. */
static BPTR ASM SDS DevClose(
A1 struct IOExtPar * ior,
A6 struct DeviceBase * db
)
{
  BPTR result = 0 ;

  if (db->db_USBSysBase != NULL)
  {
    struct Library *USBSysBase = db->db_USBSysBase ;

#if TRACE
    if (TRACE)
    {
      USBLogPuts(0, DevName, "Close") ;
    }
#endif
  }

  if(ior->IOPar.io_Unit != NULL)
  {
    struct DeviceUnit * du = (struct DeviceUnit *)ior->IOPar.io_Unit ;

    ior->IOPar.io_Unit->unit_OpenCnt = 0 ; /* !!!!! */
    if (ior->IOPar.io_Unit->unit_OpenCnt == 0)
    {
      SendCmd(db, du, CMD_CloseUnit) ;

    }
  }

  db->db_Library.lib_OpenCnt-- ;

  if(db->db_Library.lib_OpenCnt == 0)
  {
#if PRINTERPROCESS
    if (db->db_DOSBase != NULL)
    {
      CloseLibrary(db->db_DOSBase) ;
      db->db_DOSBase = NULL ; 
    }
#endif

    db->db_USBSysBase = NULL ;

    ior->IOPar.io_Device  = NULL ;
    ior->IOPar.io_Unit    = NULL ;

    if (db->db_Library.lib_Flags & LIBF_DELEXP)
    {
      result = DevExpunge(db) ;
    }
  }

  return result ;
}

/****************************************************************************/

/* The reserved function; always returns zero. */
static ULONG DevReserved(void)
{
  return 0 ;
}

/****************************************************************************/

/* This defines the data initialization data structure for
 * libraries and devices.
 */
struct DevInitData
{
  ULONG did_LibraryBaseSize ;
  APTR  did_FunctionVector ;
  APTR  did_InitTable ;
  APTR  did_InitRoutine ;
} ;

/****************************************************************************/

/* Function table */
static const APTR DevFunctionVector[] =
{
  DevOpen,
  DevClose,
  DevExpunge,
  DevReserved,
  DevBeginIO,
  DevAbortIO,
  (APTR)-1
} ;

/* Initialization table */
const struct DevInitData DevInitData =
{
  sizeof(struct DeviceBase),
  DevFunctionVector,
  NULL,
  DevInit
} ;

static UBYTE vers[] = { "$VER:" DEV_VSTRING "" } ;

#undef SysBase
#undef USBSysBase

long ASM SDS printerstatus(
A0 struct USBIOReq *usbior,
A1 struct UsbEndPoint *ep0,
D0 int interfacenum,
A2 UBYTE *status
)
{
  struct USBBusSetupData ubsd ;

  ubsd.sd_RequestType    = USBSDT_DIR_DEVTOHOST|USBSDT_TYP_CLASS|USBSDT_REC_INTERFACE /* 0xa1 */ ;
  ubsd.sd_Request        = USBREQC_GET_PORT_STATUS ;
  ubsd.sd_Value          = LE_WORD(0) ;
  ubsd.sd_Index          = LE_WORD(interfacenum) ;
  ubsd.sd_Length         = LE_WORD(1) ;
                              
  usbior->io_Error       = 0 ;
  usbior->io_Length      = 1 ;
  usbior->io_Data        = status ;
  usbior->io_Actual      = 0 ;
  usbior->io_Offset      = 0 ;
  usbior->io_SetupData   = &ubsd ;
  usbior->io_SetupLength = sizeof(ubsd) ;
  usbior->io_Command     = CMD_READ ;
  usbior->io_EndPoint    = ep0 ;

#if DOOUTPUT
  return DoIO((struct IORequest *)usbior) ;
#else
  return 0 ;
#endif
}

void ASM SDS procmainloop(void)
{
  struct Library      *USBSysBase = NULL ;
  struct DeviceBase   *db         = NULL ;
  struct DeviceUnit   *du         = NULL ;
  struct Task         *me         = NULL ;
  struct IOStdReq     *ior        = NULL ;
  struct USBNotifyMsg *nmsg       = NULL ;
  struct USBIOReq     *usbior     = NULL ;

  BOOL                loop        = FALSE ;
  
  Wait(SIGF_SINGLE) ;
  
  me = FindTask(NULL) ;
  du = me->tc_UserData ;

  db = du->du_DeviceBase ;
  du->du_port = CreatePort(NULL, 0) ;
  if (du->du_port != NULL)
  {
    du->du_openreq = CreateExtIO(du->du_port, sizeof(struct IORequest)) ;
    if (du->du_openreq != NULL)
    {
      if (OpenDevice("anaiis.device", 0, du->du_openreq, 0) == 0)
      {
        if (db->db_USBSysBase == NULL)
        {
          db->db_USBSysBase = (struct Library *) du->du_openreq->io_Device ;
        }
      }
      else
      {
        if (OpenDevice("usbsys.device", 0, du->du_openreq, 0) == 0 )
        {
          if (db->db_USBSysBase == NULL)
          {
            db->db_USBSysBase = (struct Library *) du->du_openreq->io_Device ;
          }
        }
      } 
    }
  }
  USBSysBase = db->db_USBSysBase ;
  
  loop = TRUE ;
  do
  {
    Wait( (1 << du->du_Unit.unit_MsgPort.mp_SigBit) |
          (1 << du->du_port->mp_SigBit) ) ;

    //Forbid() ;
    
    do
    {
      ior = (struct IOStdReq *)GetMsg(&du->du_Unit.unit_MsgPort) ;
      if (ior != NULL)
      {
        ior->io_Flags &= ~IOPARF_QUEUED ;

        //Permit() ;

        if (loop)
        {
          switch (ior->io_Command)
          {
            case CMD_OpenUnit :
            {
              long error = -1 ;
              UBYTE epaddress = 0 ;
              struct USBBusDscHead *dsclist ;
              struct USBBusDscHead *dsc ;

#if TRACE
              if (TRACE)
              {
                USBLogPuts(0, DevName, "OpenUnit") ;
              }
#endif

              db = (struct DeviceBase *)ior->io_Device ;
              if (db != NULL)
              {
                USBSysBase = db->db_USBSysBase ;
                if (USBSysBase != NULL)
                {
                  du->rawifc = USBFindInterface( NULL,
                                                 USBA_Class, 7,
                                                 USBA_Subclass, 1,
                                                 TAG_END ) ;
                  if (du->rawifc == NULL)
                  {
#if TRACE
                    if (TRACE)
                    {
                      USBLogPuts(1, DevName, "no interface") ;
                    }
#endif
                  }
                  else
                  {
#if TRACE
                    if (TRACE)
                    {
                      USBLogPuts(0, DevName, "  FindInterface") ;
                    }
#endif

                    du->ifc = USBClaimInterface(du->rawifc, (APTR)1L, du->du_port) ;
                    if (du->ifc == NULL)
                    {
#if TRACE
                      if (TRACE)
                      {
                        USBLogPuts(1, DevName, "  can't claim interface") ;
                      }
#endif
                    }
                    else
                    {
#if TRACE
                      if (TRACE)
                      {
                        USBLogPuts(0, DevName, "  ClaimInterface") ;
                      }
#endif

                      dsclist = USBIntGetAltSetting(du->du_openreq,
                                                    du->ifc,
                                                    NULL) ;
                      if (dsclist == NULL)
                      {
                        error = -2 ;
#if TRACE
                        if (TRACE)
                        {
                          USBLogPuts(1, DevName, "  IntGetAltSetting fail") ;
                        }
#endif
                      }
                      else
                      {
                        error = -3 ;
                        dsc = dsclist ;
                        while (dsc != NULL)
                        {
                          switch (dsc->dh_Type)
                          {
                            case USBDESC_INTERFACE :
                            {
                              struct USBBusIntDsc *intdsc = (struct USBBusIntDsc *)dsc ;
                              du->altsetting   = intdsc->id_AltSetting ;
                              du->interfacenum = intdsc->id_InterfaceID ;
                              break ;
                            }

                            case USBDESC_ENDPOINT :
                            {
                              struct USBBusEPDsc epdsccp = *(struct USBBusEPDsc *)dsc ;
 
                              switch (epdsccp.ed_Attributes)
                              {
                                case USBEPTT_BULK :
                                {
                                  if (epdsccp.ed_Address & USBEPADR_DIR_IN)
                                  {
                                    /* IN : don't care */
                                  }
                                  else
                                  {
                                    /* OUT */
                                    epaddress  = epdsccp.ed_Address ;
                                    du->epsize = LE_WORD(epdsccp.ed_MaxPacketSize) ;
                                    error = 0 ;
                                  }
                                  break ;
                                }

                                case USBEPTT_INTERRUPT :
                                {
                                  /* don't care at all */
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

                      if (error == 0)
                      {
                        du->ep  = USBGetEndPoint(NULL, du->ifc, epaddress) ;
                        du->ep0 = USBGetEndPoint(NULL, du->ifc, 0) ;
                        if ((du->ep0 != NULL) && (du->ep != NULL))
                        {
#if TRACE
                          if (TRACE)
                          {
                            ULONG args[1] ;

                            args[0] = USBIntSetAltSettingA(du->du_openreq,
                                                           du->ifc,
                                                           du->altsetting,
                                                           NULL) ;

                            USBLogVPrintf(0, DevName, "  IntSetAltSetting %ld\n", args) ;
                          }
#endif

                          du->wbuf = NULL ;
                          du->wsiz = 0 ;
                          du->widx = 0 ;
                          du->writecnt = 0 ;

                          if (du->epsize > 0)
                          {
                            du->wsiz = du->epsize*BUFFERSIZE ;
                            du->wbuf = AllocMem(du->wsiz + 1, MEMF_CLEAR|MEMF_PUBLIC) ;
                          }

#if TRACE
                          if (TRACE)
                          {
                            ULONG args[2] ;

                            args[0] = (ULONG)du->wbuf ;
                            args[1] = (ULONG)du->wsiz ;

                            USBLogVPrintf(0, DevName, "  Buffer at 0x%08lx (%ld bytes)\n", args) ; 
                          }
#endif
                          usbior = USBAllocRequest(du->du_openreq, USBA_TraceIO, TRACE, TAG_END) ;
                        }
                        else
                        {
#if TRACE
                          if (TRACE)
                          {
                            USBLogPuts(1, DevName, "no endpoint") ;
                          }
#endif
                        }
                      }
                      else
                      {
#if TRACE
                        if (TRACE)
                        {
                          USBLogPuts(1, DevName, "FAIL") ;
                        }
#endif
                      }
                    }
                  }
                }
              }
              break ;
            }

            case CMD_CloseUnit :
            { 
              if (USBSysBase != NULL)
              {
                UBYTE status = 0 ;
                long error   = 0 ;
                long retry   = 4 ;
                ULONG args[2] ;

                if (du->widx > 0)
                {
                  /* buffer is not empty */

                  if (usbior != NULL)
                  {
                    do
                    {
#if 0
                      error = printerstatus(usbior,
                                            du->ep0,
                                            du->interfacenum,
                                            &status) ;
#else
                      error  = 0 ;
                      status = 0x18 ;
#endif
                      switch (error)
                      {
                        case 0  : /* no error */
                        {
                          if ( (status & 0x08) && /* Not Error */
                               (status & 0x10) && /* Select */
                              !(status & 0x20))   /* Not Paper Empty */
                          {
                            retry = 0 ;
                            usbior->io_Error       = 0 ;
                            usbior->io_Length      = du->widx ;
                            usbior->io_Data        = du->wbuf ;
                            usbior->io_Actual      = 0 ;
                            usbior->io_Offset      = 0;
                            usbior->io_SetupData   = NULL ;
                            usbior->io_SetupLength = 0 ;
                            usbior->io_Command     = CMD_WRITE ;
                            usbior->io_EndPoint    = du->ep ;
#if DOOUTPUT
                            DoIO((struct IORequest *)usbior) ;
#endif

                            du->writecnt ++ ;
#if TRACE
                            if (TRACE)
                            {
                              args[0] = du->writecnt ;
                              args[1] = du->widx ;

                              USBLogVPrintf(0, DevName, " [%ld]Write %ld bytes (final)\n", args) ;
                            }
#endif
                            switch (usbior->io_Error)
                            {
                              case 0 :
                              {
                                retry = 0 ;
                                break ;
                              }

                              default :
                              {
                                retry-- ;
                                break ;
                              }
                            }
                          }
                          else
                          {
                            retry-- ;
                          }
                          break ;
                        }

                        default :
                        {
                          retry-- ;
                          break ;
                        }
                      }
                    } while (retry > 0) ;
                  }
                  du->widx = 0 ;
                }

                if (usbior != NULL)
                {
                  USBFreeRequest(usbior) ;
                  usbior = NULL ;
                }

#if TRACE
                if (TRACE)
                {
                  USBLogPuts(0, DevName, " CloseUnit") ;
                }
#endif
              }

              if (du->wbuf != NULL)
              {
                FreeMem(du->wbuf, du->wsiz + 1) ;
                du->wbuf = NULL ;
              }

              loop = FALSE ;
              break ;
            }

            case CMD_CLEAR :
            {
              if (USBSysBase != NULL)
              {
#if TRACE
                if (TRACE)
                {
                  USBLogPuts(0, DevName, " Clear") ;
                }
#endif
              }
              break ;
            }

            case CMD_RESET :
            {
              if (USBSysBase != NULL)
              {
#if TRACE
                if (TRACE)
                {
                  USBLogPuts(0, DevName, " Reset") ;
                }
#endif
              }
              break ;
            }

            case PDCMD_QUERY :
            {
              long  error  = ParErr_LineErr ;
              UBYTE status = 0 ;

              ((struct IOExtPar *)ior)->io_Status = IOPTF_PAPEROUT|IOPTF_PARBUSY ;
              ior->io_Error  = ParErr_LineErr ;

              if ((USBSysBase != NULL) && (du->ep0 != NULL))
              {
                if (usbior != NULL)
                {
#if 0
                  error = printerstatus(usbior,
                                        du->ep0,
                                        du->interfacenum,
                                        &status) ;
#else
                  error  = 0 ;
                  status = 0x18 ;
#endif
                  switch (error)
                  {
                    case 0 :
                    {
                      if ((status & 0x08) && /* Not Error */
                          (status & 0x10))   /* Select */
                      {
                        ((struct IOExtPar *)ior)->io_Status = 0 ;
                        ior->io_Error  = 0 ;
                      }
               
                      if (status & 0x20)   /* Paper empty */
                      {
                        ((struct IOExtPar *)ior)->io_Status |= IOPTF_PAPEROUT ;
                        ior->io_Error  = ParErr_LineErr ;
                      }
                      break ;
                    }

                    default :
                    {
                      ((struct IOExtPar *)ior)->io_Status = IOPTF_PAPEROUT|IOPTF_PARBUSY ;
                      ior->io_Error  = ParErr_LineErr ;
                      break ;
                    }
                  }
                }
              }
              
              if (USBSysBase != NULL)
              {
#if TRACE
                if (TRACE)
                {
                  ULONG args[3] ;

                  args[0] = ior->io_Error ;
                  args[1] = status ;
                  args[2] = ((struct IOExtPar *)ior)->io_Status ;

                  USBLogVPrintf(0, DevName, "Query err=%ld usb=0x%02lx sta=0x%02lx\n", args) ;
                }
#endif
              }
              break ;
            }

            case CMD_WRITE :
            {
              if ((USBSysBase != NULL) && (du->ep != NULL))
              {
                if (usbior != NULL)
                {
                  UBYTE status ;
                  UBYTE *src, *dst ;
                  int  retry    = 0 ;
                  long totalen  = 0 ;
                  long wlen     = 0 ;
                  long error    = 0 ;
                  
                  totalen = ior->io_Length ;
                  if (totalen == -1)
                  {
                    totalen = strlen((char *)ior->io_Data) ;
                  }
                  
                  wlen = 0 ;
                  src  = ior->io_Data ;

                  do
                  {
                    dst = &du->wbuf[du->widx] ;
                    while ((wlen < totalen) && (du->widx < du->wsiz))
                    {
                      *dst++ = *src++ ;
                      du->widx++ ;
                      wlen++ ;
                    }

#if TRACE
                    if (TRACE)
                    {
                      ULONG args[4] ;

                      args[0] = wlen ;
                      args[1] = totalen ;
                      args[2] = du->widx ;
                      args[3] = du->wsiz ;
                      USBLogVPrintf(0, DevName, "  Attempt to write %ld/%ld %ld [%ld]\n", args) ;
                    }
#endif
                    if (du->widx >= du->wsiz)
                    {
                      retry = 0 ;
                      do
                      {
#if 0
                        error = printerstatus(usbior,
                                              du->ep0,
                                              du->interfacenum,
                                              &status) ;
#else
                        error  = 0 ;
                        status = 0x18 ;
#endif

                        switch (error)
                        {
                          case 0  : /* no error */
                          {
                            if ( (status & 0x08) && /* Not Error */
                                 (status & 0x10) && /* Select */
                                !(status & 0x20))   /* Not Paper Empty */
                            {
                              usbior->io_Error       = 0 ;
                              usbior->io_Length      = du->wsiz ;
                              usbior->io_Data        = du->wbuf ;
                              usbior->io_Actual      = 0 ;
                              usbior->io_Offset      = 0;
                              usbior->io_SetupData   = NULL ;
                              usbior->io_SetupLength = 0 ;
                              usbior->io_Command     = CMD_WRITE ;
                              usbior->io_EndPoint    = du->ep ;
#if DOOUTPUT
                              DoIO((struct IORequest *)usbior) ;
#endif

                              du->writecnt ++ ;
#if TRACE
                              if (TRACE)
                              {
                                ULONG args[3] ;

                                args[0] = du->writecnt ;
                                args[1] = du->wsiz ;
                                args[2] = usbior->io_Error ;
                                
                                USBLogVPrintf(0, DevName, "  [%ld]Write %ld bytes (error=%ld)\n", args) ;
                              }
#endif

                              switch (usbior->io_Error)
                              {
                                case 0 :
                                {
                                  retry = 0 ;
                                  break ;
                                }

                                default :
                                {
                                  retry-- ;
                                  break ;
                                }
                              }
                            }
                            else
                            {
                              retry-- ;
                            }
                            break ;
                          }

                          default :
                          {
                            retry-- ;
                            break ;
                          }
                        }

                        do
                        {
                          nmsg = (struct USBNotifyMsg *)GetMsg(du->du_port) ;
                          if (nmsg != NULL)
                          {
                            switch (nmsg->Type)
                            {
                              case USBNM_TYPE_FUNCTIONDETACH  :
                              case USBNM_TYPE_INTERFACEDETACH :
                              {
                                loop = FALSE ;
                                break ;
                              }
                            }
                            ReplyMsg((struct Message *) nmsg) ;
                          }
                        } while (nmsg != NULL) ;
                      } while ((retry > 0) && loop) ;

                      du->widx = 0 ;
                    }
                  } while ((wlen < totalen) && loop) ;
                  
                  if (error == 0)
                  {
                    ior->io_Actual = wlen ;
                    ((struct IOExtPar *)ior)->io_Status = 0 ;
                    ior->io_Error  = 0 ;
#if TRACE
                    if (TRACE)
                    {
                      ULONG args[1] ;

                      args[0] = ior->io_Actual ;
                      USBLogVPrintf(0, DevName, "Write %ld bytes\n", args) ;
                    }
#endif
                  }
                  else
                  {
                    ((struct IOExtPar *)ior)->io_Status = IOPTF_PAPEROUT|IOPTF_PARBUSY ;
                    ior->io_Error  = ParErr_LineErr ;
#if TRACE
                    if (TRACE)
                    {
                      ULONG args[1] ;

                      USBLogVPrintf(0, DevName, "Write (Paper out/Busy)\n", args) ;
                    }
#endif 
                  }
                  
                  if (!loop)
                  {
                    du->widx = 0 ;
                  }
                }
                else
                {
#if TRACE
                  if (TRACE)
                  {
                    /* Error ? */
                    USBLogPuts(0, DevName, "Write without eps") ;
                  }
#endif

                  ((struct IOExtPar *)ior)->io_Status = IOPTF_PAPEROUT|IOPTF_PARBUSY ;
                  ior->io_Error  = ParErr_LineErr ;
                }
              }
              else
              {
                /* error */
                ((struct IOExtPar *)ior)->io_Status = IOPTF_PAPEROUT|IOPTF_PARBUSY ;
                ior->io_Error  = ParErr_LineErr ;
              }
              break ;
            }
          }
        }
        else
        {
          /* abort io to do ? */
        }

        if (1)
        {
          ULONG iocmd = ior->io_Command ;
          ULONG tsk   = (ULONG)ior->io_Message.mn_ReplyPort->mp_SigTask ;

          ReplyMsg((struct Message *)ior) ;
#if TRACE
          if (TRACE)
          {
            ULONG args[3] ;

            args[0] = (ULONG)iocmd ;
            args[1] = (ULONG)tsk ;
            USBLogVPrintf(0, DevName, "Replied %ld 0x%08lx\n", args) ;
          }
#endif
        }

        //Forbid() ;
      }
    } while (ior != NULL) ;

    //Permit() ;

    do
    {
      nmsg = (struct USBNotifyMsg *)GetMsg(du->du_port) ;
      if (nmsg != NULL)
      {
        switch (nmsg->Type)
        {
          case USBNM_TYPE_FUNCTIONDETACH  :
          case USBNM_TYPE_INTERFACEDETACH :
          {
            loop = FALSE ;
            break ;
          }
        }
        ReplyMsg((struct Message *) nmsg) ;
      }
    } while (nmsg != NULL) ;
  } while (loop) ;
  
  /* free resources */

  if (du->ifc != NULL)
  {
    USBDeclaimInterface(du->ifc) ;
    du->ifc = NULL ;
  }

  if (du->rawifc != NULL)
  {
    USBUnlockInterface(du->rawifc) ;
    du->rawifc = NULL ;
  }

  if (USBSysBase != NULL)
  {
#if TRACE
    if (TRACE)
    {
      USBLogPuts(0, DevName, "Unit process ended") ;
    }
#endif
  }

  if (du->du_openreq != NULL)
  {
    CloseDevice(du->du_openreq) ;
    DeleteExtIO(du->du_openreq) ;
    du->du_openreq = NULL ;
  }

  if (du->du_port != NULL)
  {
    DeletePort(du->du_port) ;
    du->du_port = NULL ;
  }

  Forbid() ;
  du->du_Task = NULL ;
}
