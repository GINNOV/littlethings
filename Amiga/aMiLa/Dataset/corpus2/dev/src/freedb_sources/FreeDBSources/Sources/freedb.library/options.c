
#include "freedb.h"

/***********************************************************************/
/*
 * freedb.library configuration
 */

struct FREEDBS_Config opts;

/***********************************************************************/
/*
 * The one ond only static site
 */

static struct FREEDBS_Site defaultSite = {{0}, "freedb.freedb.org", 80, "80", "/~cddb/cddb.cgi", "N000.00", "W000.00", "Random freedb server", 0};

/***********************************************************************/
/*
 * struct used locally to insert sites
 */

struct FREEDBS_InsertSite
{
    STRPTR  host;
    UWORD   port;
    STRPTR  cgi;
    STRPTR  latitude;
    STRPTR  longitude;
    STRPTR  description;
};

/***********************************************************************/
/*
 * freedb.library options
 */

struct option
{
    STRPTR  opt;
    ULONG   id;
};

enum
{
    FREEDBV_ParseOption_ActiveSite = 0,
    FREEDBV_ParseOption_Site,
    FREEDBV_ParseOption_Proxy,
    FREEDBV_ParseOption_User,
    FREEDBV_ParseOption_Email,
    FREEDBV_ParseOption_RootDir,


    FREEDBV_ParseOption_SitePort = 100,
    FREEDBV_ParseOption_CGI,
};

struct option options[] =
{
    "ACTIVESITE/A/K,PORT/K/N,CGI/K,LAT/K,LONG/K,DESC/K/F",  FREEDBV_ParseOption_ActiveSite,
    "SITE/A/K,PORT/K/N,CGI/K,LAT/K,LONG/K,DESC/K/F",        FREEDBV_ParseOption_Site,
    "PROXY/A/K,PROXYPORT/K/N,USEPROXY/S",                   FREEDBV_ParseOption_Proxy,
    "USER/A/K",                                             FREEDBV_ParseOption_User,
    "EMAIL/A/K",                                            FREEDBV_ParseOption_Email,
    "ROOTDIR/A/K",                                          FREEDBV_ParseOption_RootDir,

    NULL
};

#define READSIZE    512
#define RARGSSIZE   2048
#define TOTSIZE     (READSIZE+RARGSSIZE)

static LONG ASM
parseConfigLine(REG(a0) struct FREEDBS_Config *opts,REG(a1) char *line,REG(a2) char *buf,REG(d0) ULONG bufSize)
{
    struct RDArgs   ra;
    LONG            parms[16];
    register int    i;

    for (i = 0; options[i].opt; i++)
    {
        memset(parms,0,sizeof(parms));
        ra.RDA_Source.CS_Buffer = line;
        ra.RDA_Source.CS_Length = strlen(line);
        ra.RDA_Source.CS_CurChr = 0;
        ra.RDA_DAList           = NULL;
        ra.RDA_Buffer           = buf;
        ra.RDA_BufSiz           = bufSize;
        ra.RDA_Flags            = RDAF_NOALLOC|RDAF_NOPROMPT;
        if (!ReadArgs(options[i].opt,parms,&ra)) continue;

        switch (options[i].id)
        {
            case FREEDBV_ParseOption_Site: case FREEDBV_ParseOption_ActiveSite:
            {
                struct FREEDBS_InsertSite   is;
                register struct FREEDBS_Site    *site;
                register char               *s, *t;
                long                        port;

                s = (STRPTR)parms[0];
                if (t = strchr(s,':'))
                {
                    *t++ = 0;
                    if (*t)
                    {
                        if (stcd_l(t,&port)!=strlen(t)) return FREEDBV_Err_BadNumber;
                    }
                    else return FREEDBV_Err_NoParms;
                }
                else port = parms[1] ? (LONG)GETNUM(parms[1]) : DEFAULT_PORT;

                if (port<=0 || port>65535) return FREEDBV_Err_BadNumber;

                is.host        = s;
                is.port        = port;
                is.cgi         = (STRPTR)parms[2];
                is.latitude    = (STRPTR)parms[3];
                is.longitude   = (STRPTR)parms[4];
                is.description = (STRPTR)parms[5];

                if (!(site = insertSite(&opts->sites,&is))) return FREEDBV_Err_NoMem;
                if (site==(struct FREEDBS_Site *)(-1)) break;
                if (options[i].id==FREEDBV_ParseOption_ActiveSite)
                    opts->activeSite = site;
                break;
            }

            case FREEDBV_ParseOption_Proxy:
            {
                register char   *s, *t;
                long            port;

                s = (STRPTR)parms[0];
                if (t = strchr(s,':'))
                {
                    *t++ = 0;
                    if (*t)
                    {
                        if (stcd_l(t,&port)!=strlen(t)) return FREEDBV_Err_BadNumber;
                    }
                    else return FREEDBV_Err_NoParms;
                }
                else port = parms[1] ? (LONG)GETNUM(parms[1]) : DEFAULT_PROXYPORT;

                if (port<=0 || port>65535) return FREEDBV_Err_BadNumber;

                stccpy(opts->proxy,s,sizeof(opts->proxy));
                opts->proxyPort = port;
                sprintf(opts->proxyPortString,"%ld",port);
                opts->useProxy = parms[2];
                break;
            }

            case FREEDBV_ParseOption_User:
                stccpy(opts->user,(STRPTR)parms[0],sizeof(opts->user));
                opts->flags &= ~FREEDBV_Config_Flags_NoUser;
                break;

            case FREEDBV_ParseOption_Email:
                stccpy(opts->email,(STRPTR)parms[0],sizeof(opts->email));
                break;

            case FREEDBV_ParseOption_RootDir:
                stccpy(opts->rootDir,(STRPTR)parms[0],sizeof(opts->rootDir));
                break;

            defaut:
                return 0;
                break;
        }
    }

    return 0;
}

LONG ASM
readConfig(REG(a0) struct FREEDBS_Config *opts,REG(a1) STRPTR name)
{
    register char   *readBuf, *raBuf, *s;
    register BPTR   file;

    memset(opts,0,sizeof(struct FREEDBS_Config));
    NEWLIST(LIST(&opts->sites));
    opts->defaultSite = opts->activeSite = &defaultSite;
    opts->proxyPort = DEFAULT_PROXYPORT;
    strcpy(opts->rootDir,DEFAULT_ROOTDIR);
    strcpy(opts->user,DEFAULT_USER);
    opts->flags |= FREEDBV_Config_Flags_NoUser;

    if (name==FREEDBV_ReadConfig_Env) s = FREEDBV_Config_Env;
    else if (name==FREEDBV_ReadConfig_Envarc) s = FREEDBV_Config_Envarc;
         else s = name;

    if (!(file = Open(s,MODE_OLDFILE)) && (name==FREEDBV_ReadConfig_Env))
        file = Open(FREEDBV_Config_Envarc,MODE_OLDFILE);

    if (!file) return 0;

    if (!(raBuf = allocArbitratePooled(TOTSIZE)))
    {
        Close(file);
        return FREEDBV_Err_NoMem;
    }

    readBuf = raBuf+RARGSSIZE;

    while (s = FGets(file,readBuf,READSIZE-1))
    {
        register char *t;

        for (t = s; *t && *t!='\n'; t++);
        *t++ = '\n', *t = 0;

        if (*s!='#' && *s!=';') parseConfigLine(opts,s,raBuf,RARGSSIZE);
    }

    freeArbitratePooled(raBuf,TOTSIZE);
    Close(file);

    return 0;

}

void ASM
printConfig(REG(a0) struct FREEDBS_Config *opts)
{
    register struct FREEDBS_Site    *s;
    register struct MinNode *mstate, *succ;

    debug("\nOptions:\n");
    debug("     Flags: %lx\n",opts->flags);
    debug("     Proxy: %s\n",opts->proxy);
    debug(" ProxyPort: %ld\n",opts->proxyPort);
    debug("  UseProxy: %ld\n",opts->useProxy);
    debug("      User: %s\n",opts->user);
    debug("     Email: %s\n",opts->email);
    debug("   RootDir: %s\n",opts->rootDir);

    debug("\nSites:\n");

    debug("\n");

    for (mstate = opts->sites.mlh_Head; succ = mstate->mln_Succ; mstate = succ)
    {
        s = (struct FREEDBS_Site *)mstate;

        debug("       Host: %s\n",s->host);
        debug("       Port: %ld\n",s->port);
        debug("        CGI: %s\n",s->cgi);
        debug("   Latitude: %s\n",s->latitude);
        debug("  Longitude: %s\n",s->longitude);
        debug("Description: %s\n",s->description);
        debug("\n");
    }

    debug("ActiveSite:\n");
    s = opts->activeSite;
    debug("       Host: %s\n",s->host);
    debug("       Port: %ld\n",s->port);
    debug("        CGI: %s\n",s->cgi);
    debug("   Latitude: %s\n",s->latitude);
    debug("  Longitude: %s\n",s->longitude);
    debug("Description: %s\n",s->description);
    debug("\n");
}

/***********************************************************************/
/*
 * Insert a site in a list
 */

struct FREEDBS_Site * ASM
insertSite(REG(a0) struct MinList *list,REG(a1) struct FREEDBS_InsertSite *is)
{
    register struct FREEDBS_Site    *site;
    register struct MinNode     *mstate, *succ;

    for (mstate = list->mlh_Head; succ = mstate->mln_Succ; mstate = succ)
    {
        site = (struct FREEDBS_Site *)mstate;

        if (!strcmp(site->host,is->host) && (site->port==is->port) &&
            !strcmp(site->cgi,is->cgi ? (char *)is->cgi : (char *)DEFAULT_CGI))
            break;
    }

    if (succ) return (struct FREEDBS_Site *)(-1);

    if (!(site = (list==&opts.sites) ?
        allocArbitratePooled(sizeof(struct FREEDBS_Site)) :
        AllocMem(sizeof(struct FREEDBS_Site),MEMF_PUBLIC|MEMF_CLEAR)))
        return NULL;

    stccpy(site->host,is->host,sizeof(site->host));
    site->port = is->port;
    sprintf(site->portString,"%ld",is->port);
    if (is->cgi)
        if (!stricmp(is->cgi,"-")) *site->cgi = 0;
        else stccpy(site->cgi,is->cgi,sizeof(site->cgi));
    if (is->latitude) stccpy(site->latitude,is->latitude,sizeof(site->latitude));
    if (is->longitude) stccpy(site->longitude,is->longitude,sizeof(site->longitude));
    if (is->description) stccpy(site->description,is->description,sizeof(site->description));

    AddTail(LIST(list),NODE(site));

    return site;
}

/***********************************************************************/
/*
 * Frees a list of sites
 */

void ASM
freeSites(REG(a0) struct MinList *list)
{
    register struct MinNode *mstate, *succ;
    register BOOL           ap = (list==&opts.sites);

    for (mstate = list->mlh_Head; succ = mstate->mln_Succ; mstate = succ)
        if (ap) freeArbitratePooled(mstate,sizeof(struct FREEDBS_Site));
        else FreeMem(mstate,sizeof(struct FREEDBS_Site));
}

/***********************************************************************/
/*
 * Obtain the configuration
 */

struct FREEDBS_Config * SAVEDS ASM
FreeDBObtainConfig(REG(d0) LONG shared)
{
    if (shared) ObtainSemaphoreShared(&rexxLibBase->libSem);
    else ObtainSemaphore(&rexxLibBase->libSem);

    return &opts;
}

/***********************************************************************/
/*
 * Release the configuration
 */

void SAVEDS ASM
FreeDBReleaseConfig(void)
{
    ReleaseSemaphore(&rexxLibBase->libSem);
}

/***********************************************************************/
/*
 * Free a config
 */

void SAVEDS ASM
FreeDBFreeConfig(REG(a0) struct FREEDBS_Config *opts)
{
    freeSites(&opts->sites);
    FreeMem(opts,sizeof(struct FREEDBS_Config));
}

/***********************************************************************/
/*
 * Read a config
 */

struct FREEDBS_Config * SAVEDS ASM
FreeDBReadConfig(REG(a0) STRPTR name)
{
    register struct FREEDBS_Config *opts;

    if ((opts = AllocMem(sizeof(struct FREEDBS_Config),MEMF_PUBLIC|MEMF_CLEAR)) && !readConfig(opts,name))
        return opts;
    else
        if (opts)
        {
            FreeMem(opts,sizeof(struct FREEDBS_Config));
            opts = NULL;
        }

    return opts;
}

/***********************************************************************/
/*
 * Save the config
 */

#define FPRINTFERR {err = FREEDBV_Err_CantSave; goto end;}

LONG SAVEDS ASM
FreeDBSaveConfig(REG(a0) struct FREEDBS_Config *opts,REG(a1) STRPTR name)
{
    register struct MinNode *mstate, *succ;
    register char           *buf;
    register BPTR           file;
    register LONG           err;
    register ULONG          len, l;

    len = sizeof(struct FREEDBS_Config)+64;

    for (mstate = opts->sites.mlh_Head; succ = mstate->mln_Succ; mstate = succ)
        len += sizeof(struct FREEDBS_Site)+64;

    if (!(buf = allocArbitratePooled(len)))
        return FREEDBV_Err_NoMem;

    ObtainSemaphoreShared(&rexxLibBase->libSem);

    l = snprintf(buf,len,"#\n# freedb.library configuration file\n#\n\n");

    for (mstate = opts->sites.mlh_Head; succ = mstate->mln_Succ; mstate = succ)
    {
        register struct FREEDBS_Site *s = (struct FREEDBS_Site *)mstate;

        if (!*s->host) continue;

        l += snprintf(buf+l,len-l,(s==opts->activeSite) ? "ACTIVESITE " : "SITE ");
        l += snprintf(buf+l,len-l,"%s PORT %ld CGI %s",s->host,s->port,*s->cgi ? s->cgi : "-");
        if (*s->latitude) l += snprintf(buf+l,len-l," LAT %s",s->latitude);
        if (*s->longitude) l += snprintf(buf+l,len-l," LONG %s",s->longitude);
        if (*s->description) l += snprintf(buf+l,len-l," DESC %s",s->description);
        l += snprintf(buf+l,len-l,"\n");
    }

    if (*opts->proxy)
    {
        l += snprintf(buf+l,len-l,"PROXY %s PROXYPORT %ld",opts->proxy,opts->proxyPort);
        if (opts->useProxy) l += snprintf(buf+l,len-l," USEPROXY");
        l += snprintf(buf+l,len-l,"\n");
    }

    if (*opts->user && !(opts->flags & FREEDBV_Config_Flags_NoUser))
        l += snprintf(buf+l,len-l,"USER %s\n",opts->user);

    if (*opts->email)
        l += snprintf(buf+l,len-l,"EMAIL %s\n",opts->email);

    if (*opts->rootDir && stricmp(opts->rootDir,DEFAULT_ROOTDIR))
        snprintf(buf+l,len-l,"ROOTDIR \42%s\42\n",opts->rootDir);

    if ((name==FREEDBV_SaveConfig_Env) || (name==FREEDBV_SaveConfig_Envarc))
    {
        if (!(file = Open(FREEDBV_Config_Env,MODE_NEWFILE))) FPRINTFERR;
        err = FPuts(file,buf);
        Close(file);
        if (err<0) FPRINTFERR;

        if (name==FREEDBV_SaveConfig_Envarc)
        {
            if (!(file = Open(FREEDBV_Config_Envarc,MODE_NEWFILE))) FPRINTFERR;
            err = FPuts(file,buf);
            Close(file);
            if (err<0) FPRINTFERR;
        }
    }
    else
    {
        if (!(file = Open(name,MODE_NEWFILE))) FPRINTFERR;
        err = FPuts(file,buf);
        Close(file);
        if (err<0) FPRINTFERR;
    }
    err = 0;


end:
    ReleaseSemaphore(&rexxLibBase->libSem);
    freeArbitratePooled(buf,len);

    return err;
}

/***********************************************************************/
/*
 * Re-read the configuration
 */

LONG SAVEDS ASM
FreeDBConfigChanged(void)
{
    register LONG err;

    ObtainSemaphore(&rexxLibBase->libSem);
    freeSites(&opts.sites);
    err = readConfig(&opts,FREEDBV_ReadConfig_Env);
    ReleaseSemaphore(&rexxLibBase->libSem);

    return err;
}

/***********************************************************************/
