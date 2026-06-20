
#include <ctype.h>
#include "freedb.h"

/***********************************************************************/

enum
{
    FREEDBV_Item_DISCID = 0,
    FREEDBV_Item_DTITLE,
    FREEDBV_Item_DYEAR,
    FREEDBV_Item_DGENRE,
    FREEDBV_Item_EXTD,
    FREEDBV_Item_PLAYORDER,
    FREEDBV_Item_TTITLE,
    FREEDBV_Item_EXTT,
};

#define FREEDBV_ItemName_DISCID     "DISCID"
#define FREEDBV_ItemName_DTITLE     "DTITLE"
#define FREEDBV_ItemName_DYEAR      "DYEAR"
#define FREEDBV_ItemName_DGENRE     "DGENRE"
#define FREEDBV_ItemName_EXTD       "EXTD"
#define FREEDBV_ItemName_PLAYORDER  "PLAYORDER"
#define FREEDBV_ItemName_TTITLE     "TTITLE"
#define FREEDBV_ItemName_EXTT       "EXTT"

struct cmdSearch
{
    STRPTR  name;
    ULONG   len;
    ULONG   id;
    ULONG   flags;
};

static struct cmdSearch cs[] =
{
    FREEDBV_ItemName_DISCID,        sizeof(FREEDBV_ItemName_DISCID),        FREEDBV_Item_DISCID,        0,
    FREEDBV_ItemName_DTITLE,        sizeof(FREEDBV_ItemName_DTITLE),        FREEDBV_Item_DTITLE,        0,
    FREEDBV_ItemName_DYEAR,         sizeof(FREEDBV_ItemName_DYEAR),         FREEDBV_Item_DYEAR,         0,
    FREEDBV_ItemName_DGENRE,        sizeof(FREEDBV_ItemName_DGENRE),        FREEDBV_Item_DGENRE,        0,
    FREEDBV_ItemName_EXTD,          sizeof(FREEDBV_ItemName_EXTD),          FREEDBV_Item_EXTD,          0,
    FREEDBV_ItemName_PLAYORDER,     sizeof(FREEDBV_ItemName_PLAYORDER),     FREEDBV_Item_PLAYORDER,     0,
    FREEDBV_ItemName_TTITLE,        sizeof(FREEDBV_ItemName_TTITLE),        FREEDBV_Item_TTITLE,        0,
    FREEDBV_ItemName_EXTT,          sizeof(FREEDBV_ItemName_EXTT),          FREEDBV_Item_EXTT,          0,

    NULL
};

LONG SAVEDS ASM
parseLine(REG(a0) struct FREEDBS_DiscInfo *di,REG(a1) STRPTR line, REG(d0) int l)
{
    register APTR   pool = FREEDBM_OBJ(di)->pool;
    register char   *s, *t;
    register int    i;

    for (s = line; isspace(*s); s++);
    if (!*s) return 0;

    for (t = s; *t && *t!='\n' && *t!='\r'; t++);
    if (*t) *t = 0;

    if (*s=='#')
    {
        if (di->flags & FREEDBV_DiscInfo_Flags_HeaderDone) return 0;

        if (di->header)
        {
            ULONG hlen, slen, len;

            hlen = *((LONG *)di->header-1);
            slen = strlen(s)+1;
            len  = strlen(di->header);

            if (len+slen+512>hlen)
            {
                register char *header;

                if (!(header = AllocVecPooled(pool,1<<hlen))) return FREEDBV_Err_NoMem;
                sprintf(header,"%s\n%s",di->header,s);
                FreeVecPooled(pool,di->header);
                di->header = header;
            }
            else
            {
                strcat(di->header,"\n");
                strcat(di->header,s);
            }
        }
        else
        {
            if (!(di->header = AllocVecPooled(pool,2048))) return FREEDBV_Err_NoMem;
            strcpy(di->header,s);
        }

        return 0;
    }

    di->flags |= FREEDBV_DiscInfo_Flags_HeaderDone;

    for (t = s; *s && *s!='='; s++);
    if (!*s) return 0;

    for (s++; isspace(*s); s++);
    if (!*s) return 0;

    for (i = 0; cs[i].name; i++) if (!strnicmp(cs[i].name,t,cs[i].len-1)) break;

    if (!cs[i].name) return 0;

    switch (cs[i].id)
    {
        case FREEDBV_Item_DISCID:
        {
            LONG v;

            if (stch_l(s,&v)==0) return 0;
            di->discID = v;
            sprintf(di->discIDString,"%08lx",v);
            break;
        }

        case FREEDBV_Item_DTITLE:
            if (t = strstr(s," / "))
            {
                *t = 0;
                t += 3;
                if (!*t) t = NULL;
            }
            else t = NULL;

            if (t)
            {
                stccpy(di->title,t,sizeof(di->title));
                stccpy(di->artist,s,sizeof(di->artist));
                di->flags |= FREEDBV_DiscInfo_Flags_Artist;
            }
            else stccpy(di->title,s,sizeof(di->title));
            break;

        case FREEDBV_Item_DYEAR:
        {
            LONG v;

            if (stcd_l(s,&v)!=4) return 0;
            di->year = v;
            break;
        }

        case FREEDBV_Item_DGENRE:
            stccpy(di->genre,s,sizeof(di->genre));
            break;

        case FREEDBV_Item_EXTD:
            if (di->extd)
            {
                STRPTR  m;

                if (!(m = AllocVecPooled(pool,strlen(di->extd)+strlen(s)+2)))
                    return FREEDBV_Err_NoMem;

                strcpy(m,di->extd);
                strcat(m," ");
                strcat(m,s);
                FreeVecPooled(pool,di->extd);
                di->extd = m;
            }
            else
            {
                if (!(di->extd = AllocVecPooled(pool,strlen(s)+1)))
                    return FREEDBV_Err_NoMem;
                strcpy(di->extd,s);
            }
            break;

        case FREEDBV_Item_PLAYORDER:
            stccpy(di->playOrder,s,sizeof(di->playOrder));
            break;

        case FREEDBV_Item_TTITLE:
        {
            LONG v;

            t += sizeof(FREEDBV_ItemName_TTITLE)-1;
            if ((stcd_l(t,&v)!=s-t-1) || (v<0) || (v>=FREEDBV_MAXTRACKS))
                return 0;

            if (di->tracks[v]) return 0;

            if (!(di->tracks[v] = AllocVecPooled(pool,sizeof(struct FREEDBS_TrackInfo))))
                return FREEDBV_Err_NoMem;

            if (t = strstr(s," / "))
            {
                *t = 0;
                t += 3;
                if (!*t) t = NULL;
            }
            else t = NULL;

            if (t)
            {
                stccpy(di->tracks[v]->title,t,sizeof(di->tracks[v]->title));
                di->tracks[v]->flags |= FREEDBV_TrackInfo_Flags_Artist;
                di->flags |= FREEDBV_DiscInfo_Flags_MultiArtist;
                stccpy(di->tracks[v]->artist,s,sizeof(di->tracks[v]->artist));
            }
            else stccpy(di->tracks[v]->title,s,sizeof(di->tracks[v]->title));

            di->numTracks = v+1;

            break;
        }

        case FREEDBV_Item_EXTT:
        {
            LONG v;

            t += sizeof(FREEDBV_ItemName_EXTT)-1;
            if ((stcd_l(t,&v)!=s-t-1) || (v<0) || (v>=FREEDBV_MAXTRACKS))
                return 0;

            if (!di->tracks[v] && !(di->tracks[v] = AllocVecPooled(pool,sizeof(struct FREEDBS_TrackInfo))))
                return FREEDBV_Err_NoMem;

            if (di->tracks[v]->extd)
            {
                STRPTR  m;

                if (!(m = AllocVecPooled(pool,strlen(di->tracks[v]->extd)+strlen(s)+2)))
                    return FREEDBV_Err_NoMem;

                strcpy(m,di->tracks[v]->extd);
                strcat(m," ");
                strcat(m,s);
                FreeVecPooled(pool,di->tracks[v]->extd);
                di->tracks[v]->extd = m;
            }
            else
            {
                if (!(di->tracks[v]->extd = AllocVecPooled(pool,strlen(s)+1)))
                    return FREEDBV_Err_NoMem;
                strcpy(di->tracks[v]->extd,s);
            }

            break;
        }

        default:
            break;
    }

    return 0;
}

/****************************************************************************/

LONG ASM
checkDiscInfo(REG(a0) struct FREEDBS_DiscInfo *di,REG(a1) struct FREEDBS_TOC *toc)
{
    register int i, tracks;

    if (toc && toc->numTracks) di->numTracks = toc->numTracks;

    if (((tracks = di->numTracks)==0) || !*di->title)
        return FREEDBV_Err_BadFormat;

    for (i = tracks; i<FREEDBV_MAXTRACKS; i++)
        if (di->tracks[i] && di->tracks[i]->extd)
            return FREEDBV_Err_BadFormat;

    for (i = 0; i<tracks; i++)
        if (!di->tracks[i]) di->tracks[i] = &emptyTrack;

    return 0;
}

/****************************************************************************/

LONG
readLocalDisc(STRPTR name,struct FREEDBS_DiscInfo *di,struct FREEDBS_TOC *toc,char *buf,ULONG bufSize)
{
    register BPTR   file;
    register STRPTR line;
    register LONG   err;
    register int    i;

    if (!(file = Open(name,MODE_OLDFILE))) return FREEDBV_Err_NotFound;

    for (err = 0, i = 1; !err && (line = FGets(file,buf,bufSize)); i++)
        err = parseLine(di,line,i);

    if (!err) err = checkDiscInfo(di,toc);
    Close(file);

    return err;
}

/****************************************************************************/

LONG
callMultiHook(struct Hook *multiHook,struct FREEDBS_DiscInfo *di)
{
    register struct FREEDBS_MultiHookMessage    *msg;
    register LONG                               err;

    if (!(msg = allocMessage(sizeof(struct FREEDBS_MultiHookMessage))))
        return FREEDBV_Err_NoMem;

    msg->code   = 0;
    msg->discID = di->discID;
    sprintf(msg->discIDString,"%08lx",di->discID);
    stccpy(msg->categ,di->categ,sizeof(msg->categ));
    stccpy(msg->artist,di->artist,sizeof(msg->artist));
    stccpy(msg->title,di->title,sizeof(msg->title));

    err = CallHookPkt(multiHook,NULL,msg);
    FreeDBClearObject(di);

    return err;
}

/****************************************************************************/

#define WORKSIZE    512
#define IDSIZE      16
#define TOTSIZE     (WORKSIZE+IDSIZE)

LONG SAVEDS ASM
FreeDBGetLocalDiscA(REG(a0) struct TagItem *attrs)
{
    register struct FREEDBS_DiscInfo    *di;
    register struct FREEDBS_TOC         *toc;
    register struct Hook                *multiHook;
    register struct Process             *me;
    register struct Window              *win;
    register char                       *buf, *ID, *categ;
    register ULONG                      discID, noReq, found;
    LONG                                err;

    categ     = (STRPTR)GetTagData(FREEDBA_Categ,0,attrs);
    discID    = GetTagData(FREEDBA_DiscID,0,attrs);
    di        = (struct FREEDBS_DiscInfo *)GetTagData(FREEDBA_DiscInfo,0,attrs);
    toc       = (struct FREEDBS_TOC *)GetTagData(FREEDBA_TOC,0,attrs);
    multiHook = (struct Hook *)GetTagData(FREEDBA_MultiHook,0,attrs);
    noReq     = GetTagData(FREEDBA_NoRequester,0,attrs);

    if (!di) return FREEDBV_Err_NoParms;

    if (!discID)
        if (toc && toc->discID) discID = toc->discID;
        else
            if (di->discID) discID = di->discID;
            else return FREEDBV_Err_NoParms;

    if (!(buf = allocArbitratePooled(TOTSIZE)))
        return FREEDBV_Err_NoMem;

    ID = buf+WORKSIZE;

    FreeDBObtainConfig(FALSE);
    strcpy(buf,rexxLibBase->opts->rootDir);
    FreeDBReleaseConfig();

    sprintf(ID,"%08lx",discID);

    err = found = 0;

    if (noReq)
    {
        me = (struct Process *)FindTask(NULL);
        win = me->pr_WindowPtr;
        me->pr_WindowPtr = (struct Window *)-1;
    }

    if (categ)
    {
        struct FileInfoBlock __aligned  fib;
        register BPTR                   lock;

        if (!(lock = Lock(buf,SHARED_LOCK)) || !Examine(lock,&fib) || (fib.fib_DirEntryType<0))
        {
            if (lock) UnLock(lock);
            err = FREEDBV_Err_NoRootDir;
            goto end;
        }
        UnLock(lock);

        if (!AddPart(buf,categ,WORKSIZE) || !AddPart(buf,ID,WORKSIZE)) err = FREEDBV_Err_NotFound;
        else
            if (!(err = readLocalDisc(buf,di,toc,buf,WORKSIZE)))
            {
                strcpy(di->categ,categ);
                found = 1;
            }
    }
    else
    {
        struct FileInfoBlock __aligned  dfib = {0};
        register BPTR                   lock, oldDir;

        if (!(lock = Lock(buf,SHARED_LOCK)) || !Examine(lock,&dfib) || (dfib.fib_DirEntryType<0))
        {
            if (lock) UnLock(lock);
            err = FREEDBV_Err_NoRootDir;
            goto end;
        }

        oldDir = CurrentDir(lock);

        while (!err && ExNext(lock,&dfib))
        {
            register BPTR dir;

            if ((dfib.fib_DirEntryType<0) || !(dir = Lock(dfib.fib_FileName,SHARED_LOCK)))
                continue;

            strcpy(buf,dfib.fib_FileName);
            if (AddPart(buf,ID,WORKSIZE))
            {
                register BPTR file;

                if (file = Lock(buf,SHARED_LOCK))
                {
                    struct FileInfoBlock __aligned ffib = {0};

                    if (Examine(file,&ffib) && (ffib.fib_DirEntryType<0))
                    {
                        if (found==1)
                            if (!multiHook) err = FREEDBV_Err_Multi;
                            else err = callMultiHook(multiHook,di);

                        if (!err && !(err = readLocalDisc(buf,di,toc,buf,WORKSIZE)))
                        {
                            strcpy(di->categ,dfib.fib_FileName);
                            if (found>0) err = callMultiHook(multiHook,di);
                            found++;
                        }
                    }

                    UnLock(file);
                }
            }
            else err = FREEDBV_Err_NotFound;

            UnLock(dir);
        }

        CurrentDir(oldDir);
        UnLock(lock);
    }

    if (!err)
        if (found==0) err = FREEDBV_Err_NotFound;
        else if (found>1) err = FREEDBV_Err_Multi;

end:
    if (noReq) me->pr_WindowPtr = win;
    if (buf) freeArbitratePooled(buf,TOTSIZE);

    return err;
}

/****************************************************************************/

LONG SAVEDS ASM
FreeDBMakeHeader(REG(a0) struct TagItem * attrs)
{
    register struct FREEDBS_DiscInfo    *di;
    register struct FREEDBS_TOC         *toc;
    register APTR                       pool;
    register char                       *header, *prg, *ver;
    register ULONG                      size, len, discID, bumpRev;
    register int                        i, numTracks;

    discID  = GetTagData(FREEDBA_DiscID,0,attrs);
    di      = (struct FREEDBS_DiscInfo *)GetTagData(FREEDBA_DiscInfo,0,attrs);
    toc     = (struct FREEDBS_TOC *)GetTagData(FREEDBA_TOC,0,attrs);
    bumpRev = GetTagData(FREEDBA_BumpRev,0,attrs);
    prg     = (STRPTR)GetTagData(FREEDBA_Prg,(ULONG)PRG,attrs);
    ver     = (STRPTR)GetTagData(FREEDBA_Ver,(ULONG)VRSTRING,attrs);

    if (!di) return FREEDBV_Err_NoParms;

    if (!discID)
        if (toc && toc->discID) discID = toc->discID;
        else
            if (di->discID) discID = di->discID;
            else return FREEDBV_Err_NoParms;

    if (toc)
        if (toc->numTracks) numTracks = toc ->numTracks;
        else return NULL;
    else
        if (di->numTracks) numTracks = di ->numTracks;
        else return FREEDBV_Err_NoParms;

    pool = FREEDBM_OBJ(di)->pool;

    size = 256 + (strlen(prg) + strlen(ver))*2 + strlen(di->title) +
           strlen(di->artist) + (di->extd ? strlen(di->extd) : 0);

    for (i = 0; i<numTracks; i++)
        size += 32 + strlen(di->tracks[i]->title) +
                strlen(di->tracks[i]->artist) +
                (di->tracks[i]->extd ? strlen(di->tracks[i]->extd) : 0);

    if (!(header = AllocVecPooled(pool,size)))
        return FREEDBV_Err_NoMem;

    if (di->header) FreeVecPooled(pool,di->header);
    di->header = header;

    len = snprintf(header,size,"# xmcd CD database file\n#\n");
    if (toc)
    {
        len += snprintf(header+len,size-len,"# Track frame offsets:\n");

        for (i = 0; i<numTracks; i++)
            len += snprintf(header+len,size-len,"#\t%ld\n",toc->tracks[i].startAddr+150);


        len += snprintf(header+len,size-len,"#\n# Disc length: %ld seconds\n#\n",toc->min*60+toc->sec+2);
    }

    if (bumpRev) di->revision++;

    len += snprintf(header+len,size-len,"# Revision: %ld\n# Processed by: " VERS "\n",di->revision);
    len += snprintf(header+len,size-len,"# Submitted via: %s %s\n",prg,ver);
    len += snprintf(header+len,size-len,"#\n");
    len += snprintf(header+len,size-len,"DISCID=%08lx\n",discID);

    if (*di->artist) len += snprintf(header+len,size-len,"DTITLE=%s / %s\n",di->artist,di->title);
    else len += snprintf(header+len,size-len,"DTITLE=%s\n",di->title);

    if (*di->genre) len += snprintf(header+len,size-len,"DGENRE=%s\n",di->genre);

    if (di->year>0) len += snprintf(header+len,size-len,"DYEAR=%ld\n",di->year);

    for (i = 0; i<numTracks; i++)
    {
        register struct FREEDBS_TrackInfo *track = di->tracks[i];

        if (track->flags & FREEDBV_TrackInfo_Flags_Artist)
            len += snprintf(header+len,size-len,"TTITLE%ld=%s / %s\n",i,track->artist,track->title);
        else len += snprintf(header+len,size-len,"TTITLE%ld=%s\n",i,track->title);
    }

    len += snprintf(header+len,size-len,"EXTD=%s\n",di->extd ? (char *)di->extd : (char *)"");

    for (i = 0; i<numTracks; i++)
        len += snprintf(header+len,size-len,"EXTT%ld=%s\n",i,di->tracks[i]->extd ? (char *)di->tracks[i]->extd : (char *)"");

    /*len += */snprintf(header+len,size-len,"PLAYORDER=%s\n",di->playOrder);

    return 0;
}

/****************************************************************************/

enum
{
    SAVEF_OverWrite  = 1,
    SAVEF_NoReq      = 2,
    SAVEF_OrigHeader = 4,
};

LONG SAVEDS ASM
FreeDBSaveLocalDiscA(REG(a0) struct TagItem * attrs)
{
    register struct FREEDBS_DiscInfo    *di;
    register struct FREEDBS_TOC         *toc;
    struct FileInfoBlock __aligned      fib;
    register struct Process             *me;
    register struct Window              *win;
    register BPTR                       lock;
    register char                       *buf, *ID, *categ;
    register BPTR                       file;
    register ULONG                      discID, flags;
    register LONG                       err;

    file = NULL;
    flags = 0;

    categ     = (STRPTR)GetTagData(FREEDBA_Categ,0,attrs);
    discID    = GetTagData(FREEDBA_DiscID,0,attrs);
    di        = (struct FREEDBS_DiscInfo *)GetTagData(FREEDBA_DiscInfo,0,attrs);
    toc       = (struct FREEDBS_TOC *)GetTagData(FREEDBA_TOC,0,attrs);
    flags    |= (GetTagData(FREEDBA_OverWrite,0,attrs) ? SAVEF_OverWrite : 0) |
                (GetTagData(FREEDBA_NoRequester,0,attrs) ? SAVEF_NoReq : 0) |
                (GetTagData(FREEDBA_OrigHeader,0,attrs) ? SAVEF_OrigHeader : 0);

    if (!di) return FREEDBV_Err_NoParms;

    if (!discID)
        if (toc && toc->discID) discID = toc->discID;
        else
            if (di->discID) return FREEDBV_Err_NoParms;

    if (!categ)
        if (di->categ) categ = di->categ;
        else return FREEDBV_Err_NoParms;

    if (flags & SAVEF_OrigHeader)
        if (!di->header) flags &= ~SAVEF_OrigHeader;

    if (!(flags & SAVEF_OrigHeader) && (err = FreeDBMakeHeader(attrs)))
        return err;

    if (!(buf = allocArbitratePooled(TOTSIZE)))
        return FREEDBV_Err_NoMem;

    ID = buf + WORKSIZE;

    FreeDBObtainConfig(FALSE);
    strcpy(buf,rexxLibBase->opts->rootDir);
    FreeDBReleaseConfig();

    if (flags & SAVEF_NoReq)
    {
        me = (struct Process *)FindTask(NULL);
        win = me->pr_WindowPtr;
        me->pr_WindowPtr = (struct Window *)-1;
    }

    if (!(lock = Lock(buf,SHARED_LOCK)) || !Examine(lock,&fib) || (fib.fib_DirEntryType<0))
    {
        if (lock) UnLock(lock);
        err = FREEDBV_Err_NoRootDir;
        goto end;
    }
    UnLock(lock);

    err = FREEDBV_Err_CantSave;

    if (!(AddPart(buf,categ,WORKSIZE))) goto end;

    if (!(lock = Lock(buf,SHARED_LOCK)))
    {
        register BPTR dir;

        if (!(dir = CreateDir(buf))) goto end;
        UnLock(dir);
    }
    else
    {
        if (!Examine(lock,&fib) || fib.fib_DirEntryType<0) goto end;
    }

    sprintf(ID,"%08lx",discID);
    if (!AddPart(buf,ID,TOTSIZE)) goto end;
    if (lock = Lock(buf,SHARED_LOCK))
    {
        if (!Examine(lock,&fib) || (fib.fib_DirEntryType>0)) goto end;
        UnLock(lock);
        if (!(flags & SAVEF_OverWrite))
        {
            err = FREEDBV_Err_FileExists;
            goto end;
        }
    }

    if (file = Open(buf,MODE_NEWFILE))
    {
        if (FPrintf(file,di->header)>=0) err = 0;
        Close(file);
    }

end:
    if (flags & SAVEF_NoReq) me->pr_WindowPtr = win;
    if (file && err) DeleteFile(buf);
    if (buf) freeArbitratePooled(buf,TOTSIZE);

    return err;
}

/****************************************************************************/
