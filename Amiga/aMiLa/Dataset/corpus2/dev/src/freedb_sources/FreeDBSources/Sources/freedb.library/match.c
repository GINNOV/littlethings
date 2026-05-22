
#include <ctype.h>
#include "freedb.h"

/***********************************************************************/

struct match
{
    struct FREEDBS_DiscInfo *di;
    struct AnchorPath       ap;
    char                    buf[256];
    char                    path[256];
    char                    categ[256];
    char                    title[256];
    char                    artist[256];
    char                    titles[256];
    ULONG                   flags;
};

enum
{
    FREEDBV_Match_FreeDI = 1,
    FREEDBV_Match_First  = 2,
};

/****************************************************************************/

static struct FREEDBS_DiscInfo * ASM
checkMatch(REG(a0) struct match *match,REG(d0) LONG res)
{
    while (!res)
    {
        if (match->ap.ap_Info.fib_DirEntryType<0)
        {
            register char *id;
            LONG          discID;

            id = FilePart(match->ap.ap_Buf);
            if (stch_l(id,&discID)==strlen(id))
            {
                register char categ[256], *c;

                memset(categ,0,sizeof(categ));
                strncpy(categ,match->ap.ap_Buf,PathPart(match->ap.ap_Buf)-match->ap.ap_Buf);
                c = FilePart(categ);
                if (*match->categ ? MatchPatternNoCase(match->categ,c) : 1)
                {
                    register struct TagItem attrs[] = {FREEDBA_Categ,     0,
                                                       FREEDBA_DiscID,    0,
                                                       FREEDBA_DiscInfo,  0,
                                                       TAG_DONE};

                    FreeDBClearObject(match->di);
                    attrs[0].ti_Data = (ULONG)c;
                    attrs[1].ti_Data = discID;
                    attrs[2].ti_Data = (ULONG)match->di;
                    if (!FreeDBGetLocalDiscA(attrs))
                    {
                        if ((*match->title ? MatchPatternNoCase(match->title,match->di->title) : 1) &&
                            (*match->artist ? MatchPatternNoCase(match->artist,match->di->artist) : 1))
                        {
                            if (*match->titles)
                            {
                                register int i, tracks;

                                for (i = 0, tracks = match->di->numTracks; i<tracks; i++)
                                    if (MatchPatternNoCase(match->titles,match->di->tracks[i]->title))
                                        return match->di;
                            }
                            else return match->di;
                        }
                    }
                }
            }
        }
        res = MatchNext(&match->ap);
    }

    /*if (res==ERROR_BREAK) res = FREEDBV_Err_Aborted;
    else res = FREEDBV_Err_NotFound;*/

    /*MatchEnd(&match->ap);
    if (match->flags & FREEDBV_Match_FreeDI) FreeDBFreeObject(match->di);
    freeArbitratePooled(match,sizeof(struct match));*/

    return NULL;
}

/****************************************************************************/

struct match * SAVEDS ASM
FreeDBMatchStartA(REG(a0) struct TagItem *attrs)
{
    register struct match               *match;
    register struct FREEDBS_DiscInfo    *di;
    register char                       *discID, *s;
    register LONG                       *errPtr;

    errPtr = (LONG *)GetTagData(FREEDBA_ErrorPtr,0,attrs);

    if (!(match = allocArbitratePooled(sizeof(struct match))))
    {
        if (errPtr) *errPtr = FREEDBV_Err_NoMem;
        return NULL;
    }

    if (!(di = (struct FREEDBS_DiscInfo *)GetTagData(FREEDBA_DiscInfo,0,attrs)))
    {
        if (!(di = FreeDBAllocObjectA(FREEDBV_AllocObject_DiscInfo,TAG_DONE)))
        {
            freeArbitratePooled(match,sizeof(struct match));
            if (errPtr) *errPtr = FREEDBV_Err_NoMem;
            return NULL;
        }
        match->flags |= FREEDBV_Match_FreeDI;
    }
    match->di = di;

    match->ap.ap_BreakBits  = SIGBREAKF_CTRL_C;
    match->ap.ap_Strlen = sizeof(match->buf);

    if (!(discID =(STRPTR)GetTagData(FREEDBA_DiscID,NULL,attrs))) discID = "#?";
    FreeDBObtainConfig(FALSE);
    strcpy(match->path,rexxLibBase->opts->rootDir);
    FreeDBReleaseConfig();
    if (!AddPart(match->path,"#?",sizeof(match->path)) || !AddPart(match->path,discID,sizeof(match->path)))
    {
        if (match->flags & FREEDBV_Match_FreeDI) FreeDBFreeObject(match->di);
        freeArbitratePooled(match,sizeof(struct match));
        return NULL;
    }

    if ((s = (STRPTR)GetTagData(FREEDBA_Categ,0,attrs)) && *s)
        if (ParsePatternNoCase(s,match->categ,sizeof(match->categ))<0)
            *match->categ = 0;

    if ((s = (STRPTR)GetTagData(FREEDBA_Title,0,attrs)) && *s)
        if (ParsePatternNoCase(s,match->title,sizeof(match->title))<0)
            *match->title = 0;

    if ((s = (STRPTR)GetTagData(FREEDBA_Artist,0,attrs)) && *s)
        if (ParsePatternNoCase(s,match->artist,sizeof(match->artist))<0)
            *match->artist = 0;

    if ((s = (STRPTR)GetTagData(FREEDBA_Titles,0,attrs)) && *s)
        if (ParsePatternNoCase(s,match->titles,sizeof(match->titles))<0)
            *match->titles = 0;

    match->flags |= FREEDBV_Match_First;

    return match;
}

/****************************************************************************/

struct FREEDBS_DiscInfo * SAVEDS ASM
FreeDBMatchNext(REG(a0) struct match *match)
{
    if (match->flags & FREEDBV_Match_First)
    {
        match->flags &= ~FREEDBV_Match_First;
        return checkMatch(match,MatchFirst(match->path,&match->ap));
    }

    return checkMatch(match,MatchNext(&match->ap));
}

/****************************************************************************/

void SAVEDS ASM
FreeDBMatchEnd(REG(a0) struct match *match)
{
    if (!(match->flags & FREEDBV_Match_First)) MatchEnd(&match->ap);

    if (match->flags & FREEDBV_Match_FreeDI) FreeDBFreeObject(match->di);
    freeArbitratePooled(match,sizeof(struct match));
}

/****************************************************************************/
