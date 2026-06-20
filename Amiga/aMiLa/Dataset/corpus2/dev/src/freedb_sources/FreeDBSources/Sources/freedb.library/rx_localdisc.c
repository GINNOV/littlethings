
#include "freedb.h"

/****************************************************************************/

struct setStruct discInfoSS[] =
{
    "NUMTRACKS",    "%ld",  'L',    OFFSET(FREEDBS_DiscInfo,numTracks),
    "YEAR",         "%ld",  'L',    OFFSET(FREEDBS_DiscInfo,year),
    "CATEG",        NULL,   'a',    OFFSET(FREEDBS_DiscInfo,categ),
    "GENRE",        NULL,   'a',    OFFSET(FREEDBS_DiscInfo,genre),
    "TITLE",        NULL,   'a',    OFFSET(FREEDBS_DiscInfo,title),
    "ARTIST",       NULL,   'a',    OFFSET(FREEDBS_DiscInfo,artist),
    "PLAYORDER",    NULL,   'a',    OFFSET(FREEDBS_DiscInfo,playOrder),
    NULL
};

/****************************************************************************/

LONG
setDisc(struct RexxMsg *msg,STRPTR stem,struct FREEDBS_DiscInfo *di)
{
    register char   buf[NAMESIZE], id[32], *s;
    register LONG   res;
    register        i, tracks;

    if (res = setStructU(msg,stem,di,discInfoSS))
        return res;

    sprintf(buf,"%s.DISCID",stem);
    sprintf(id,"%08lx",di->discID);
    if (res = setRexxVarU(msg,buf,id,strlen(id),RexxSysBase))
        return res;

    s = di->extd ? di->extd : "";
    sprintf(buf,"%s.EXTD",stem);
    if (res = setRexxVarU(msg,buf,s,strlen(s),RexxSysBase))
        return res;

    sprintf(buf,"%s.MULTIARTIST",stem);
    if (res = setRexxVarU(msg,buf,(di->flags & FREEDBV_DiscInfo_Flags_MultiArtist) ? "1" : "0" ,1,RexxSysBase))
        return res;

    for (i = 0, tracks = di->numTracks; i<tracks; i++)
    {
        struct FREEDBS_TrackInfo *track = di->tracks[i];

        sprintf(buf,"%s.%ld.TITLE",stem,i);
        if (res = setRexxVarU(msg,buf,track->title,strlen(track->title),RexxSysBase))
            return res;

        sprintf(buf,"%s.%ld.ARTIST",stem,i);
        if (res = setRexxVarU(msg,buf,track->artist,strlen(track->artist),RexxSysBase))
            return res;

        s = track->extd ? track->extd : "";
        sprintf(buf,"%s.%ld.EXTD",stem,i);
        if (res = setRexxVarU(msg,buf,s,strlen(s),RexxSysBase))
            return res;
    }

    return 0;
}

/****************************************************************************/

struct hookData
{
    struct RexxMsg          *msg;
    STRPTR                  stem;
    struct FREEDBS_DiscInfo *di;
    ULONG                   count;
};

/****************************************************************************/

LONG SAVEDS ASM
mfun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_MultiHookMessage *msg,REG(a2) APTR handle)
{
    struct hookData *hd = hook->h_Data;
    register char   buf[NAMESIZE], discID[16];

    sprintf(buf,"%s.%ld.CATEG",hd->stem,hd->count);
    if (setRexxVarU(hd->msg,buf,msg->categ,strlen(msg->categ),RexxSysBase))
        return FREEDBV_Err_NoMem;

    sprintf(discID,"%08lx",msg->discID);
    sprintf(buf,"%s.%ld.DISCID",hd->stem,hd->count);
    if (setRexxVarU(hd->msg,buf,discID,strlen(discID),RexxSysBase))
        return FREEDBV_Err_NoMem;

    sprintf(buf,"%s.%ld.TITLE",hd->stem,hd->count);
    if (setRexxVarU(hd->msg,buf,msg->title,strlen(msg->title),RexxSysBase))
        return FREEDBV_Err_NoMem;

    sprintf(buf,"%s.%ld.ARTIST",hd->stem,hd->count);
    if (setRexxVarU(hd->msg,buf,msg->artist,strlen(msg->artist),RexxSysBase))
        return FREEDBV_Err_NoMem;

    hd->count++;

    return 0;
}

/***************************************************************************/

RXLFUN(rx_FreeDBGetLocalDisc)
{
    struct hookData                     hd;
    struct Hook                         mhook;
    register struct FREEDBS_DiscInfo    *di;
    register struct FREEDBS_TOC         *toc;
    register struct TagItem             attrs[8];
    register STRPTR                     categ = NULL;
    register LONG                       res;
    LONG                                discID;
    register int                        i;

    if (!(di = FreeDBAllocObjectA(FREEDBV_AllocObject_DiscInfoTOC,NULL))) return 3;

    toc = FREEDBM_GETTOCFROMDI(di);

    if (!argv[1] || argv[1][LengthArgstring(argv[0])-1]==':' || stch_l(argv[1],&discID)!=8)
    {
        attrs[0].ti_Tag  = FREEDBA_TOC;
        attrs[0].ti_Data = (ULONG)toc;
        attrs[1].ti_Tag  = FREEDBA_DeviceName;
        attrs[1].ti_Data = (ULONG)(argv[1] ? (char *)argv[1] : "CD0");
        attrs[2].ti_Tag  = TAG_DONE;

        if (res = FreeDBReadTOCA(attrs))
        {
            result->value.intVal = res;
            res = BOXTYPE(RBINT);
            goto end;
        }

        discID = 0;
    }
    else if (argv[2]) categ = argv[2];

    hd.msg   = msg;
    hd.stem  = argv[0];
    hd.di    = di;
    hd.count = 0;

    mhook.h_Entry = (APTR)mfun;
    mhook.h_Data  = &hd;

    attrs[0].ti_Tag  = FREEDBA_DiscInfo;
    attrs[0].ti_Data = (ULONG)di;
    attrs[1].ti_Tag  = FREEDBA_TOC;
    attrs[1].ti_Data = (ULONG)toc;
    attrs[2].ti_Tag  = FREEDBA_MultiHook;
    attrs[2].ti_Data = (ULONG)&mhook;

    i = 3;

    if (discID)
    {
        attrs[i].ti_Tag    = FREEDBA_DiscID;
        attrs[i++].ti_Data = discID;

        if (categ)
        {
            attrs[i].ti_Tag    = FREEDBA_Categ;
            attrs[i++].ti_Data = (ULONG)categ;
        }
    }

    attrs[i].ti_Tag  = TAG_DONE;

    if (res = FreeDBGetLocalDiscA(attrs))
    {
        if (res==FREEDBV_Err_Multi)
        {
            register char buf[NAMESIZE];

            sprintf(buf,"%s.NUM",argv[0]);
            if (!(res = setRexxVarU_d(msg,buf,hd.count,RexxSysBase)))
                res = FREEDBV_Err_Multi;
        }

        result->value.intVal = res;
        res = BOXTYPE(RBINT);
    }
    else
        if (!(res = setDisc(msg,argv[0],di))) res = RXFALSE;

end:
    FreeDBFreeObject(di);
    return res;
}

/****************************************************************************/
