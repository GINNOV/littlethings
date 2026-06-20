
#include <dos/dosextens.h>
#include <dos/filehandler.h>
#include "freedb.h"

/****************************************************************************/

ULONG SAVEDS ASM
findDevice(REG(a0) STRPTR name,REG(a1) char *buf,REG(d0) int bufSize,REG(a2) UWORD *unit)
{
    register char           n[512], *f, *t;
    register struct DosList *dl;
    register ULONG          res = 0;

    for (f = name, t = n; *f && *f!=':';) *t++ = ToUpper(*f++);
    *t = 0;

    dl = LockDosList(LDF_DEVICES|LDF_READ);
    if (dl = FindDosEntry(dl,n,LDF_DEVICES))
    {
        register struct DeviceNode          *dn;
        register struct FileSysStartupMsg   *sum;

        dn = (struct DeviceNode *)dl;
        if (dn && (sum = (struct FileSysStartupMsg *)BADDR(dn->dn_Startup)))
        {
            register UBYTE *b;

            b = BADDR(sum->fssm_Device);
            if (b && b[0]<bufSize-1)
            {
                memcpy(buf,b+1,b[0]);
                buf[b[0]] = 0;
                *unit = sum->fssm_Unit;
                res = 1;
            }
        }
    }
    UnLockDosList(LDF_DEVICES|LDF_READ);

    return res;
}

/****************************************************************************/

static ULONG
cddbSum(ULONG n)
{
    ULONG   ret;

    ret = 0;

    while (n>0)
    {
        ret = ret + (n % 10);
        n = n / 10;
    }

    return ret;
}

/****************************************************************************/

enum
{
    FREEDBV_ReadToc_Flags_FreeTOCData   =  1,
    FREEDBV_ReadToc_Flags_CloseTimerDev =  2,
    FREEDBV_ReadToc_Flags_FreeSig       =  4,
    FREEDBV_ReadToc_Flags_CloseDev      =  8,
    FREEDBV_ReadToc_Flags_FreeTOC       = 16,
    FREEDBV_ReadToc_Flags_SecondQuery   = 32,
};

#define SENSESIZE   32
#define DEVBUFSIZE  256
#define TOTSIZE     (FREEDBV_TOCSIZE+sizeof(struct IOStdReq)+sizeof(struct timerequest)+sizeof(struct MsgPort)+sizeof(struct SCSICmd)+SENSESIZE+DEVBUFSIZE)

#define TIMEOUT     10

LONG SAVEDS ASM
FreeDBReadTOCA(REG(a0) struct TagItem *attrs)
{
    FREEDB_Command10            cmd = {FREEDBC_READTOC};
    register APTR               pool;
    struct MsgPort              *port;
    register struct IOStdReq    *req;
    struct timerequest          *tr;
    struct SCSICmd              *scsi;
    register struct FREEDBS_TOC *toc, **TOCPtr;
    register UBYTE              *sense, *TOCData, *track, *ntrack, tracks, *device, *deviceName, *devBuf;
    register LONG               err;
    register ULONG              a, b, n, t, v1, v2, flags;
    register int                sig, i;
    UWORD                       unit;
    register UBYTE              lun;

    flags      = 0;
    TOCPtr     = (struct FREEDBS_TOC **)GetTagData(FREEDBA_TOCPtr,0,attrs);
    toc        = (struct FREEDBS_TOC *)GetTagData(FREEDBA_TOC,0,attrs);
    device     = (STRPTR)GetTagData(FREEDBA_Device,0,attrs);
    unit       = (UWORD)GetTagData(FREEDBA_Unit,0,attrs);
    lun        = (UBYTE)GetTagData(FREEDBA_Lun,0,attrs);
    deviceName = (STRPTR)GetTagData(FREEDBA_DeviceName,0,attrs);
    pool       = (APTR)GetTagData(FREEDBA_Pool,0,attrs);

    if ((!TOCPtr && !toc) || (!device && !deviceName)) return FREEDBV_Err_NoParms;

    if ((sig = AllocSignal(-1))==-1) return FREEDBV_Err_NoMem;
    flags |= FREEDBV_ReadToc_Flags_FreeSig;

    if (!(TOCData = allocArbitratePooled(TOTSIZE)))
    {
        err = FREEDBV_Err_NoMem;
        goto end;
    }
    flags |= FREEDBV_ReadToc_Flags_FreeTOCData;

    req    = (struct IOStdReq *)(TOCData+FREEDBV_TOCSIZE);
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
    else flags |= FREEDBV_ReadToc_Flags_CloseTimerDev;

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
    flags |= FREEDBV_ReadToc_Flags_CloseDev;

    if (!toc)
    {
        if (pool) toc = AllocPooled(pool,sizeof(struct FREEDBS_TOC));
        else toc = FreeDBAllocObjectA(FREEDBV_AllocObject_TOC,NULL);
        if (!toc)
        {
            err = FREEDBV_Err_NoMem;
            goto end;
        }
        flags |= FREEDBV_ReadToc_Flags_FreeTOC;
    }

    FREEDBM_SETLUN(cmd,lun);
    FREEDBM_SETWORD(cmd,7,FREEDBV_TOCSIZE);

    req->io_Command = HD_SCSICMD;
    req->io_Data    = scsi;
    req->io_Length  = sizeof(struct SCSICmd);

    scsi->scsi_Data        = (USHORT *)TOCData;
    scsi->scsi_Length      = FREEDBV_TOCSIZE;
    scsi->scsi_Flags       = SCSIF_AUTOSENSE|SCSIF_READ;
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

            err = FREEDBV_Err_NoTOC;
            goto end;
        }

        if (CheckIO((struct IORequest *)req))
        {
            AbortIO((struct IORequest *)tr);
            WaitIO((struct IORequest *)tr);

            if (err = WaitIO((struct IORequest *)req))
            {
                register UBYTE skey = FREEDBM_Sense_SenseKey(sense);

                if (!(flags & FREEDBV_ReadToc_Flags_SecondQuery) && (skey==0x6 || skey==0x0b))
                {
                    flags |= FREEDBV_ReadToc_Flags_SecondQuery;
                    tr->tr_time.tv_secs    = TIMEOUT;
                    tr->tr_time.tv_micro   = 0;

                    SendIO((struct IORequest *)req);
                    SendIO((struct IORequest *)tr);
                }
                else
                {
                    register UBYTE asc = FREEDBM_Sense_ASC(sense);

                    if (skey==0x0 || skey==0x5) err = FREEDBV_Err_NotCD;
                    else if (skey==0x2 && asc==0x3a) err = FREEDBV_Err_NoMedium;
                         else err = FREEDBV_Err_NoTOC;
                    goto end;
                }
            }
            else break;
        }
    }

    track  = FREEDBM_TOCBlock_TOCData(TOCData);
    tracks = FREEDBM_TOCHeader_Length(TOCData)/FREEDBV_TOCBlock_TOCDataSize;

    toc->firstTrack = FREEDBM_TOCHeader_FirstTrack(TOCData);
    toc->lastTrack  = FREEDBM_TOCHeader_LastTrack(TOCData);
    toc->numTracks  = toc->lastTrack-toc->firstTrack+1;

    if (toc->lastTrack<toc->firstTrack || (tracks>FREEDBV_MAXTRACKS) || (toc->numTracks!=tracks-1))
    {
        err = FREEDBV_Err_BadTOC;
        goto end;
    }

    for (i = 0; i<tracks; i++)
    {
        register struct FREEDBS_Track   *t;
        register int                    tn = FREEDBM_TOCData_TrackNumber(track);

        t = toc->tracks+i;

        t->track = tn;

        a = FREEDBM_TOCData_AbsAddr(track);
        if (a<0)
        {
            err = FREEDBV_Err_BadTOC;
            goto end;
        }

        t->startAddr  = a;
        t->startMin   = ((v1 = a/75)/60);
        t->startSec   = (v1%60);
        t->startFrame = (a%75);

        if (tn==0xaa) continue;

        ntrack = track + 8;

        b = FREEDBM_TOCData_AbsAddr(ntrack);
        if (b<a)
        {
            err = FREEDBV_Err_BadTOC;
            goto end;
        }

        t->endAddr  = b;
        t->frames   = (v2 = b-a);
        t->endMin   = ((v1 = b/75)/60);
        t->endSec   = (v1 % 60);
        t->endFrame = (b % 75);

        t->min      = ((v1 = v2/75)/60);
        t->sec      = (v1%60);
        t->frame    = (v2%75);

        t->ADR          = FREEDBM_TOCData_ADR(track);
        t->audio        = FREEDBM_TOCData_AudioTrack(track);
        t->preEmp       = FREEDBM_TOCData_PreEmp(track);
        t->copyPerm     = FREEDBM_TOCData_CopyPerm(track);
        t->fourChannels = FREEDBM_TOCData_4Channels(track);

        track = ntrack;
    }

    toc->startAddress = toc->tracks[0].startAddr;
    toc->endAddress   = toc->tracks[tracks-1].startAddr;
    toc->frames       = v2 = toc->endAddress-toc->startAddress;
    toc->min          = (v1 = v2/75)/60;
    toc->sec          = v1%60;
    toc->frame        = v2%75;

    for (n = i = 0; i<tracks-1; i++) n += cddbSum(toc->tracks[i].startMin*60+toc->tracks[i].startSec+2);
    t = (toc->tracks[tracks-1].startMin * 60 + toc->tracks[tracks-1].startSec) - (toc->tracks[0].startMin * 60 + toc->tracks[0].startSec);
    n = ((n % 0xff)<<24 | t<<8 | (tracks-1));
    toc->discID = n;

    err = 0;

end:
    if (err)
    {
        if (flags & FREEDBV_ReadToc_Flags_FreeTOC)
        {
            if (pool) FreePooled(pool,toc,sizeof(struct FREEDBS_TOC));
            else FreeDBFreeObject(toc);
        }
    }
    else if (TOCPtr) *TOCPtr = toc;

    if (flags & FREEDBV_ReadToc_Flags_CloseTimerDev) CloseDevice((struct IORequest *)tr);
    if (flags & FREEDBV_ReadToc_Flags_CloseDev) CloseDevice((struct IORequest *)req);
    if (flags & FREEDBV_ReadToc_Flags_FreeTOCData) freeArbitratePooled(TOCData,TOTSIZE);
    if (flags & FREEDBV_ReadToc_Flags_FreeSig) FreeSignal(sig);

    return err;
}

/****************************************************************************/
