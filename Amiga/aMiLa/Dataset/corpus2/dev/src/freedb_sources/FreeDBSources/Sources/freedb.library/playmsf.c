
#include "freedb.h"

/****************************************************************************/

enum
{
    FREEDBV_PlayMSF_Flags_FreeMem       =  1,
    FREEDBV_PlayMSF_Flags_CloseTimerDev =  2,
    FREEDBV_PlayMSF_Flags_FreeSig       =  4,
    FREEDBV_PlayMSF_Flags_CloseDev      =  8,
    FREEDBV_PlayMSF_Flags_FreeTOC       = 16,
    FREEDBV_PlayMSF_Flags_SecondQuery   = 32,
};

#define SENSESIZE   32
#define DEVBUFSIZE  256
#define TOTSIZE     (sizeof(struct IOStdReq)+sizeof(struct timerequest)+sizeof(struct MsgPort)+sizeof(struct SCSICmd)+SENSESIZE+DEVBUFSIZE)

#define TIMEOUT     10

LONG SAVEDS ASM
FreeDBPlayMSFA(REG(a0) struct TagItem *attrs)
{
    FREEDB_Command10            cmd = {FREEDBC_PLAYAUDIOMSF};
    struct MsgPort              *port;
    register struct IOStdReq    *req;
    struct timerequest          *tr;
    struct SCSICmd              *scsi;
    register UBYTE              *sense, *device, *deviceName, *devBuf;
    register LONG               err;
    register ULONG              flags;
    register int                sig;
    UWORD                       unit;
    register UBYTE              lun, fromM, fromS, fromF, toM, toS, toF;

    flags      = 0;

    device     = (STRPTR)GetTagData(FREEDBA_Device,0,attrs);
    unit       = (UWORD)GetTagData(FREEDBA_Unit,0,attrs);
    lun        = (UBYTE)GetTagData(FREEDBA_Lun,0,attrs);
    deviceName = (STRPTR)GetTagData(FREEDBA_DeviceName,0,attrs);
    fromM      = (UBYTE)GetTagData(FREEDBA_FromM,0,attrs);
    fromS      = (UBYTE)GetTagData(FREEDBA_FromS,0,attrs);
    fromF      = (UBYTE)GetTagData(FREEDBA_FromF,0,attrs);
    toM        = (UBYTE)GetTagData(FREEDBA_ToM,0,attrs);
    toS        = (UBYTE)GetTagData(FREEDBA_ToS,0,attrs);
    toF        = (UBYTE)GetTagData(FREEDBA_ToF,0,attrs);

    if ((sig = AllocSignal(-1))==-1) return FREEDBV_Err_NoMem;
    flags |= FREEDBV_PlayMSF_Flags_FreeSig;

    if (!(req = allocArbitratePooled(TOTSIZE)))
    {
        err = FREEDBV_Err_NoMem;
        goto end;
    }
    flags |= FREEDBV_PlayMSF_Flags_FreeMem;

    tr     = (struct timerequest *)((UBYTE *)req+sizeof(struct IOStdReq));
    port   = (struct MsgPort *)((UBYTE *)tr+sizeof(struct timerequest));
    scsi   = (struct SCSICmd *)((UBYTE *)port+sizeof(struct MsgPort));
    sense  = (UBYTE *)scsi+sizeof(struct SCSICmd);
    devBuf = sense+SENSESIZE;

    INITPORT(port,sig);

    INITMESSAGE(tr,port,sizeof(struct timerequest));
    if (OpenDevice(TIMERNAME,UNIT_MICROHZ,(struct IORequest *)tr,0))
    {
        err = FREEDBV_Err_NoMem;
        goto end;
    }
    else flags |= FREEDBV_PlayMSF_Flags_CloseTimerDev;

    if (!device)
    {
        if (!findDevice(deviceName,devBuf,DEVBUFSIZE,&unit))
        {
            err = FREEDBV_Err_NoDevice;
            goto end;
        }

        device = devBuf;
    }

    INITMESSAGE(req,port,sizeof(struct IOStdReq));
    if (OpenDevice(device,unit,(struct IORequest *)req,0))
    {
        err = FREEDBV_Err_NoOpenDevice;
        goto end;
    }
    flags |= FREEDBV_PlayMSF_Flags_CloseDev;

    FREEDBM_SETLUN(cmd,lun);
    cmd[3] = fromM;
    cmd[4] = fromS;
    cmd[5] = fromF;
    cmd[6] = toM;
    cmd[7] = toS;
    cmd[8] = toF;

    req->io_Command = HD_SCSICMD;
    req->io_Data    = scsi;
    req->io_Length  = sizeof(struct SCSICmd);

    scsi->scsi_Data        = 0;
    scsi->scsi_Length      = 0;
    scsi->scsi_Flags       = SCSIF_AUTOSENSE|SCSIF_WRITE;
    scsi->scsi_SenseData   = sense;
    scsi->scsi_SenseLength = SENSESIZE;
    scsi->scsi_SenseActual = 0;
    scsi->scsi_Status      = 0;
    scsi->scsi_Command     = cmd;
    scsi->scsi_CmdLength   = sizeof(cmd);

    tr->tr_node.io_Command = TR_ADDREQUEST;
    tr->tr_time.tv_secs    = TIMEOUT;
    tr->tr_time.tv_micro   = 0;

    SendIO((struct IORequest *)req);
    SendIO((struct IORequest *)tr);

    while (1)
    {
        if (Wait(SIGBREAKF_CTRL_C|(1<<sig)) & SIGBREAKF_CTRL_C)
        {
            AbortIO((struct IORequest *)req);
            AbortIO((struct IORequest *)tr);
            WaitIO((struct IORequest *)req);
            WaitIO((struct IORequest *)tr);

            err = FREEDBV_Err_Aborted;
            goto end;
        }

        if (CheckIO((struct IORequest *)tr))
        {
            WaitIO((struct IORequest *)tr);

            AbortIO((struct IORequest *)req);
            WaitIO((struct IORequest *)req);

            err = FREEDBV_Err_CantPlay;
            goto end;
        }

        if (CheckIO((struct IORequest *)req))
        {
            AbortIO((struct IORequest *)tr);
            WaitIO((struct IORequest *)tr);

            if (err = WaitIO((struct IORequest *)req))
            {
                register UBYTE skey = FREEDBM_Sense_SenseKey(sense);

                if (!(flags & FREEDBV_PlayMSF_Flags_SecondQuery) && (skey==0x6 || skey==0x0b))
                {
                    flags |= FREEDBV_PlayMSF_Flags_SecondQuery;
                    tr->tr_time.tv_secs    = TIMEOUT;
                    tr->tr_time.tv_micro   = 0;

                    SendIO((struct IORequest *)req);
                    SendIO((struct IORequest *)tr);
                }
                else
                {
                    register UBYTE asc = FREEDBM_Sense_ASC(sense);

                    if (skey==0x0) err = FREEDBV_Err_NotCD;
                    else if (skey==0x2 && asc==0x3a) err = FREEDBV_Err_NoMedium;
                         else err = FREEDBV_Err_CantPlay;
                    goto end;
                }
            }
            else goto end;
        }
    }

end:
    if (flags & FREEDBV_PlayMSF_Flags_CloseTimerDev) CloseDevice((struct IORequest *)tr);
    if (flags & FREEDBV_PlayMSF_Flags_CloseDev) CloseDevice((struct IORequest *)req);
    if (flags & FREEDBV_PlayMSF_Flags_FreeMem) freeArbitratePooled(req,TOTSIZE);
    if (flags & FREEDBV_PlayMSF_Flags_FreeSig) FreeSignal(sig);

    return err;
}

/****************************************************************************/
