
#include <ctype.h>
#include "freedb.h"

/***********************************************************************/

LONG ASM SAVEDS
FreeDBSetDiscInfoA(REG(a0) struct FREEDBS_DiscInfo *di,REG(a1) struct TagItem *attrs)
{
    register APTR           pool = FREEDBM_OBJ(di)->pool;
    register struct TagItem *tag;
    struct TagItem          *tstate;
    register LONG           res;

    for (res = 0, tstate = attrs; tag = NextTagItem(&tstate); )
    {
        register ULONG tidata = tag->ti_Data;

        switch(tag->ti_Tag)
        {
            case FREEDBA_Tracks:
                if (tidata<FREEDBV_MAXTRACKS)
                {
                    register int i;

                    FreeDBClearObject(di);

                    for (i = 0; i<tidata; i++)
                        di->tracks[i] = &emptyTrack;

                    di->numTracks = tidata;
                }
                res++;
                break;

            case FREEDBA_DiscID:
                sprintf(di->discIDString,"%08lx",di->discID = tidata);
                res++;
                break;

            case FREEDBA_Year:
                di->year = tidata;
                res++;
                break;

            case FREEDBA_Categ:
                if (tidata) stccpy(di->categ,(STRPTR)tidata,sizeof(di->categ));
                else *di->categ = 0;
                res++;
                break;

            case FREEDBA_Genre:
                if (tidata) stccpy(di->genre,(STRPTR)tidata,sizeof(di->genre));
                else *di->genre = 0;
                res++;
                break;

            case FREEDBA_Title:
                if (tidata) stccpy(di->title,(STRPTR)tidata,sizeof(di->title));
                else *di->title = 0;
                res++;
                break;

            case FREEDBA_Artist:
                if (tidata)
                {
                    stccpy(di->artist,(STRPTR)tidata,sizeof(di->artist));
                    di->flags |= FREEDBV_DiscInfo_Flags_Artist;
                }
                else
                {
                    *di->artist = 0;
                    di->flags &= ~FREEDBV_DiscInfo_Flags_Artist;
                }
                res++;
                break;

            case FREEDBA_Extd:
            {
                if (tidata)
                {
                    register STRPTR e;

                    if (e = AllocVecPooled(pool,strlen((STRPTR)tidata)+1))
                    {
                        strcpy(e,(STRPTR)tidata);
                        if (di->extd) FreeVecPooled(pool,di->extd);
                        di->extd = e;
                        res++;
                    }
                }
                else
                {
                    if (di->extd)
                    {
                        FreeVecPooled(pool,di->extd);
                        di->extd = NULL;
                    }
                }
                break;
            }

            case FREEDBA_PlayOrder:
                if (tidata) stccpy(di->playOrder,(STRPTR)tidata,sizeof(di->playOrder));
                else *di->playOrder = 0;
                res++;
                break;
        }
    }

    return res;
}

/***********************************************************************/

LONG ASM SAVEDS
FreeDBSetDiscInfoTrackA(REG(a0) struct FREEDBS_DiscInfo *di,REG(d0) ULONG t,REG(a1) struct TagItem *attrs)
{
    register APTR                       pool = FREEDBM_OBJ(di)->pool;
    register struct FREEDBS_TrackInfo   *track;
    register struct TagItem             *tag;
    struct TagItem                      *tstate;
    register LONG                       res;

    if (t>=FREEDBV_MAXTRACKS)
        return 0;

    if (di->tracks[t]==&emptyTrack)
    {
        if (!(track = AllocVecPooled(pool,sizeof(struct FREEDBS_TrackInfo))))
            return 0;
        di->tracks[t]= track;
    }
    else track = di->tracks[t];

    for (res = 0, tstate = attrs; tag = NextTagItem(&tstate); )
    {
        register STRPTR tidata = (STRPTR)tag->ti_Data;

        switch(tag->ti_Tag)
        {
            case FREEDBA_Title:
                if (tidata) stccpy(track->title,tidata,sizeof(track->title));
                else *track->title = 0;
                res++;
                break;

            case FREEDBA_Artist:
                if (tidata)
                {
                    stccpy(track->artist,tidata,sizeof(track->artist));
                    track->flags |= FREEDBV_TrackInfo_Flags_Artist;
                }
                else
                {
                    register int i;

                    *track->artist = 0;
                    track->flags &= ~FREEDBV_TrackInfo_Flags_Artist;

                    di->flags &= ~FREEDBV_DiscInfo_Flags_MultiArtist;

                    for (i = 0; i<FREEDBV_MAXTRACKS; i++)
                    {
                        if (!di->tracks[i] || di->tracks[i]==&emptyTrack)
                            continue;

                        if (di->tracks[i]->flags & FREEDBV_TrackInfo_Flags_Artist)
                        {
                            di->flags |= FREEDBV_DiscInfo_Flags_MultiArtist;
                            break;
                        }
                    }
                }
                res++;
                break;

            case FREEDBA_Extd:
            {
                if (tidata)
                {
                    register STRPTR e;

                    if (e = AllocVecPooled(pool,strlen(tidata)+1))
                    {
                        strcpy(e,tidata);
                        if (track->extd) FreeVecPooled(pool,track->extd);
                        track->extd = e;
                        res++;
                    }
                }
                else
                {
                    if (track->extd)
                    {
                        FreeVecPooled(pool,track->extd);
                        track->extd = NULL;
                    }
                }
                break;
            }
        }
    }

    return res;
}

/***********************************************************************/
