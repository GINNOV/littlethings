
#include "freedb.h"

/****************************************************************************/

/* rx_localdisc.c */
LONG setDisc(struct RexxMsg *msg,STRPTR stem,struct FREEDBS_DiscInfo *di);

/****************************************************************************/

struct field matchFields[] =
{
    FN("ARTIST",FREEDBA_Artist,SS|I),
    FN("CATEG",FREEDBA_Categ,SS|I),
    FN("DISCID",FREEDBA_DiscID,SS|I),
    FN("TITLE",FREEDBA_Title,SS|I),
    FN("TTITLES",FREEDBA_Titles,SS|I),
    FEND
};

RXLFUN(rx_FreeDBMatch)
{
    register struct TagItem attrs[FIELDSIZE(matchFields)];
    register APTR           match;
    register STRPTR         stem;
    register LONG           res;

    if (stem = argv[0])
    {
        if (res = noCodeMakeTags(MTA_Msg,       msg,
                                 MTA_Stem,      stem,
                                 MTA_Tags,      attrs,
                                 MTA_Fields,    matchFields,
                                 MTA_NumFields, FIELDSIZE(matchFields),
                                 MTA_Flags,     ACTION_INIT,
                                 MTA_ErrorStem, "FREEDB",
                                 TAG_DONE)) return res;
    }
    else
    {
        attrs[0].ti_Tag = TAG_DONE;
        res = 0;
    }

    if (match = FreeDBMatchStartA(attrs))
    {
        register struct FREEDBS_DiscInfo    *di;
        register char                       buf[64];
        register int                        i;

        for (i = 0; !res && (di = FreeDBMatchNext(match)); i++)
        {
            sprintf(buf,"%s.%ld",stem,i);
            res = setDisc(msg,buf,di);
        }

        FreeDBMatchEnd(match);

        if (!res)
        {
            sprintf(buf,"%s.NUM",stem);
            res = setRexxVarU_d(msg,buf,i,RexxSysBase);
        }

        if (!res) res = RXFALSE;
    }
    else res = 3;

    return res;
}

/****************************************************************************/
