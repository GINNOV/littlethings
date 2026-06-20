
#include "freedb.h"

/****************************************************************************/

struct field createAppFields[] =
{
    FN("DEVICE",FREEDBA_Device,SS|I),
    FN("DEVICENAME",FREEDBA_DeviceName,SS|I),
    FN("UNIT",FREEDBA_Unit,SN|I),
    FN("LUN",FREEDBA_Lun,SN|I),
    FN("PRG",FREEDBA_Prg,SS|I),
    FN("VER",FREEDBA_Ver,SS|I),
    FN("USESPACE",FREEDBA_UseSpace,SB|I),
    FN("NOREQUESTER",FREEDBA_NoRequester,SB|I),
    FN("GETDISC",FREEDBA_GetDisc,SB|I),
    FN("LOCAL",FREEDBA_Local,SB|I),
    FN("REMOTE",FREEDBA_Remote,SB|I),
    FEND
};

RXLFUN(rx_FreeDBCreateApp)
{
    register struct TagItem attrs[FIELDSIZE(createAppFields)+1];
    register LONG           res;

    if (argv[0])
    {
        if (res = noCodeMakeTags(MTA_Msg,       msg,
                                 MTA_Stem,      argv[0],
                                 MTA_Tags,      attrs,
                                 MTA_Fields,    createAppFields,
                                 MTA_NumFields, FIELDSIZE(createAppFields),
                                 MTA_Flags,     ACTION_INIT,
                                 MTA_ErrorStem, "FREEDB",
                                 TAG_DONE)) return res;
    }
    else attrs[0].ti_Tag = TAG_DONE;

    return FreeDBCreateAppA(attrs) ? RXTRUE : RXFALSE;
}

/****************************************************************************/
