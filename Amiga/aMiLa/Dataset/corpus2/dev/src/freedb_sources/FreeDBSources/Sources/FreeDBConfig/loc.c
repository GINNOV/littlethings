
#include "class.h"

/***********************************************************************/

static ULONG ids[] =
{
    MSG_User,
    MSG_User_Help,
    MSG_Email,
    MSG_Email_Help,
    MSG_RootDir,
    MSG_RootDir_Help,
    MSG_RootDirASLTitle,
    MSG_Proxy,
    MSG_Proxy_Help,
    MSG_ProxyPort,
    MSG_ProxyPort_Help,
    MSG_UseProxy,
    MSG_UseProxy_Help,

    MSG_Sites_Host,
    MSG_Sites_Port,
    MSG_Sites_CGI,
    MSG_Sites_Lat,
    MSG_Sites_Long,
    MSG_Sites_Desc,
    MSG_Sites_Help,

    MSG_Host,
    MSG_Host_Help,
    MSG_Port,
    MSG_Port_Help,
    MSG_CGI,
    MSG_CGI_Help,
    MSG_Lat,
    MSG_Lat_Help,
    MSG_Long,
    MSG_Long_Help,
    MSG_Desc,
    MSG_Desc_Help,

    MSG_Add,
    MSG_Add_Help,
    MSG_Del,
    MSG_Del_Help,
    MSG_Active,
    MSG_Active_Help,

    MSG_Save,
    MSG_Save_Help,
    MSG_Use,
    MSG_Use_Help,
    MSG_Apply,
    MSG_Apply_Help,
    MSG_Cancel,
    MSG_Cancel_Help,
    MSG_Stop,
    MSG_Stop_Help,

    MSG_Reading,
    MSG_Read,
    MSG_CantRead,
    MSG_Download,

    -1
};

static STRPTR staticStrings[] =
{
    "Us_er",
    "User name. Default ILoveNewYork .",
    "E_mail",
    "User email. Must be supplied\nfor submiting.",
    "R_ootDir",
    "Root drawer. Default FREEDB: .",
    "Select the RootDir",
    "_Proxy",
    "Proxy name.",
    "Prox_y port",
    "Proxy port.\n0<port<65536.",
    "Use pro_xy",
    "Use proxy flag.",

    "\33bHost",
    "\33bPort",
    "\33b\33cCGI",
    "\33bLatitude",
    "\33bLongitude",
    "\33b\33cDescription",
    "freedb sites list.",

    "Host",
    "Host name.",
    "Port",
    "Host port.\n0<port<65536.",
    "CGI",
    "freedb CGI location.",
    "Lat",
    "Host latitude.",
    "Long",
    "Host longitude.",
    "Desc",
    "Host description.",

    "Add",
    "Add a host.",
    "Del",
    "Delete the active host.",
    "Active",
    "Make the active host the default one.",

    "_Save",
    "Save configuration.",
    "_Use",
    "Use configuration.",
    "_Apply",
    "Use configuration without exiting.",
    "_Cancel",
    "Exit without save.",
    "_Stop",
    "Interrupt remote connections.",

    "Reading config...",
    "Config read.",
    "Can't read config.",
    "Sites downloaded.",
};

STRPTR localizedStrings[sizeof(ids)/sizeof(ULONG)-1];
STRPTR *strings;

/***********************************************************************/

void ASM
initStrings(REG(a0) struct libBase *base)
{
    register STRPTR *s, *ss;
    register LONG   *id;

    if ((base->localeBase = OpenLibrary("locale.library",37)) &&
        (base->cat = OpenCatalogA(NULL,CATNAME,NULL)))
    {
        strings = localizedStrings;

        for (id = ids, s = strings, ss = staticStrings; *id!=-1; id++, s++, ss++)
            *s = GetCatalogStr(libBase->cat,*id,*ss);
    }
    else strings = staticStrings;
}

/***********************************************************************/
