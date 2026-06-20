
#include "freedb.h"

/****************************************************************************/

struct setStruct TOCSS[] =
{
    "FIRSTTRACK",   "%ld",  'L',    OFFSET(FREEDBS_TOC,firstTrack),
    "LASTTRACK",    "%ld",  'L',    OFFSET(FREEDBS_TOC,lastTrack),
    "STARTADDR",    "%ld",  'L',    OFFSET(FREEDBS_TOC,startAddress),
    "ENDADDR",      "%ld",  'L',    OFFSET(FREEDBS_TOC,endAddress),
    "FRAMES",       "%ld",  'L',    OFFSET(FREEDBS_TOC,frames),
    "MIN",          "%ld",  'L',    OFFSET(FREEDBS_TOC,min),
    "SEC",          "%ld",  'L',    OFFSET(FREEDBS_TOC,sec),
    "FRAME",        "%ld",  'L',    OFFSET(FREEDBS_TOC,frame),
    "NUMTRACKS",    "%ld",  'L',    OFFSET(FREEDBS_TOC,numTracks),

    NULL
};

struct setStruct trackSS[] =
{
    "TRACK",        "%ld",  'L',    OFFSET(FREEDBS_Track,track),
    "STARTADDR",    "%ld",  'L',    OFFSET(FREEDBS_Track,startAddr),
    "ENDADDR",      "%ld",  'L',    OFFSET(FREEDBS_Track,endAddr),
    "FRAMES",       "%ld",  'L',    OFFSET(FREEDBS_Track,frames),
    "STARTMIN",     "%ld",  'L',    OFFSET(FREEDBS_Track,startMin),
    "STARTSEC",     "%ld",  'L',    OFFSET(FREEDBS_Track,startSec),
    "STARTFRAME",   "%ld",  'L',    OFFSET(FREEDBS_Track,startFrame),
    "ENDMIN",       "%ld",  'L',    OFFSET(FREEDBS_Track,endMin),
    "ENDSEC",       "%ld",  'L',    OFFSET(FREEDBS_Track,endSec),
    "ENDFRAME",     "%ld",  'L',    OFFSET(FREEDBS_Track,endFrame),
    "MIN",          "%ld",  'L',    OFFSET(FREEDBS_Track,min),
    "SEC",          "%ld",  'L',    OFFSET(FREEDBS_Track,sec),
    "FRAME",        "%ld",  'L',    OFFSET(FREEDBS_Track,frame),
    "ADR",          "%ld",  'L',    OFFSET(FREEDBS_Track,ADR),
    "AUDIO",        "%ld",  'B',    OFFSET(FREEDBS_Track,audio),
    "COPYPERM",     "%ld",  'B',    OFFSET(FREEDBS_Track,copyPerm),
    "PREEMPHASIS",  "%ld",  'B',    OFFSET(FREEDBS_Track,preEmp),
    "FOURCHANNELS", "%ld",  'B',    OFFSET(FREEDBS_Track,fourChannels),

    NULL
};

/****************************************************************************/

RXLFUN(rx_FreeDBTOC)
{
    struct FREEDBS_TOC      *toc;
    register LONG           res;
    register struct TagItem attrs[] = {FREEDBA_TOCPtr,   0,
                                       FREEDBA_DeviceName, 0,
                                       TAG_DONE};

    attrs[0].ti_Data = (ULONG)&toc;
    attrs[1].ti_Data = (ULONG)argv[0];

    if (!(res = FreeDBReadTOCA(attrs)))
    {
        if (!(res = setStructU(msg,argv[1],toc,TOCSS)))
        {
            register char buf[BUFSIZE], id[32];

            sprintf(buf,"%s.DISCID",argv[1]);
            sprintf(id,"%08lx",toc->discID);

            if (!(res = setRexxVarU(msg,buf,id,strlen(id),RexxSysBase)))
            {
                register    i, tracks = toc->numTracks;

                for (i = 0; !res && i<tracks; i++)
                {
                    sprintf(buf,"%s.%ld",argv[1],i);
                    res = setStructU(msg,buf,&toc->tracks[i],trackSS);
                }
            }
        }

        if (!res) res = RXFALSE;
    }
    else
    {
        result->value.intVal = res;
        res = BOXTYPE(RBINT);
    }

    FreeDBFreeObject(toc);

    return res;
}

/****************************************************************************/

