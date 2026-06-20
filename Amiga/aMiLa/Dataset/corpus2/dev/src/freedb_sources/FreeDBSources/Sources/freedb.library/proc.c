
#include "proc.h"
#include "freedb.h"

/****************************************************************************/

#define MAXFREENUM 32

struct FREEDBS_GenericMessage
{
    struct MinNode  link;
    ULONG           size;
};

APTR ASM
allocMessage(REG(d0) ULONG size)
{
    register struct FREEDBS_GenericMessage *mstate, *succ;

    ObtainSemaphore(&rexxLibBase->libSem);

    for (mstate = (struct FREEDBS_GenericMessage *)rexxLibBase->messages.mlh_Head;
         (succ = (struct FREEDBS_GenericMessage *)mstate->link.mln_Succ) && mstate->size<size;
         mstate = succ);

    if (succ)
    {
        Remove(NODE(mstate));
        rexxLibBase->freeMessages--;
    }
    else
    {
        if (mstate = allocArbitratePooled(size)) mstate->size = size;
    }

    ReleaseSemaphore(&rexxLibBase->libSem);

    return mstate;
}

void SAVEDS ASM
FreeDBFreeMessage(REG(a0) struct FREEDBS_GenericMessage *msg)
{
    ObtainSemaphore(&rexxLibBase->libSem);

    if (rexxLibBase->freeMessages==MAXFREENUM)
    {
        freeArbitratePooled(msg,msg->size);
    }
    else
    {
        AddTail(LIST(&rexxLibBase->messages),NODE(msg));
        rexxLibBase->freeMessages++;
    }

    ReleaseSemaphore(&rexxLibBase->libSem);
}

/****************************************************************************/

#define BUFZISE     2048
#define LR_BUFSIZE   512
#define HOSTSIZE     256
#define PROXYSIZE    256
#define CGISIZE      256
#define USERSIZE      64
#define EMAILSIZE    256
#define PRGSIZE       64
#define VERSIZE       64
#define CATEGSIZE    256

/****************************************************************************/

enum
{
    FREEDBV_DispatchMsg_Flags_NtDone = 1,
};

#define SUBMIT_CGI "submit.cgi"

/****************************************************************************/

LONG
dispatchMsg(struct FREEDBS_StartMsg *msg,ULONG flags)
{
    register struct Library             *SocketBase;
    struct sockaddr_in                  sin;
    fd_set                              read;
    struct lineRead                     *lr;
    struct RDArgs                       ra;
    register LONG                       parms[16];
    register char                       buf[BUFZISE], lrBuf[sizeof(struct lineRead)+LR_BUFSIZE+1],
                                        host[HOSTSIZE], proxy[PROXYSIZE], cgi[CGISIZE],
                                        user[USERSIZE], email[EMAILSIZE], prg[PRGSIZE], ver[VERSIZE],
                                        *hostName, *errorBuffer;
    LONG                                l;
    register LONG                       err;
    register ULONG                      cmd, code, useProxy, multi, called, errorBufferLen;
    register int                        sock, len, i, status, proxyPort, hostPort, headerLen;
    register struct FREEDBS_TOC         *toc;
    register struct FREEDBS_DiscInfo    *di;
    register struct Hook                *statusHook;
    register struct Hook                *multiHook;
    register struct Hook                *sitesHook;
    register struct Hook                *lsCatHook;

    cmd            = msg->cmd;
    toc            = msg->toc;
    di             = msg->di;
    statusHook     = msg->statusHook;
    multiHook      = msg->multiHook;
    sitesHook      = msg->sitesHook;
    lsCatHook      = msg->lsCatHook;
    errorBuffer    = msg->errorBuffer;
    errorBufferLen = msg->errorBufferLen;

    switch (cmd)
    {
        case FREEDBV_Command_Query:
            if (!toc || !di) return FREEDBV_Err_NoParms;
            break;

        case FREEDBV_Command_Read:
            if (!di) return FREEDBV_Err_NoParms;
            break;

        case FREEDBV_Command_Sites:
            if (!sitesHook) return FREEDBV_Err_NoParms;
            break;

        case FREEDBV_Command_LsCat:
            if (!lsCatHook) return FREEDBV_Err_NoParms;
            break;

        case FREEDBV_Command_Submit:
        {
            register char *c;
            if (!toc || !di) return FREEDBV_Err_NoParms;

            FreeDBObtainConfig(FALSE);
            stccpy(email,msg->email ? msg->email : rexxLibBase->opts->email,EMAILSIZE);
            FreeDBReleaseConfig();

            if (!(c = strchr(email,'@')) || c==email || !*(c+1))
                return FREEDBV_Err_NoEmail;

            break;
        }

        default:
            return FREEDBV_Err_NoMem;
            break;
    }

    if (!(SocketBase = OpenLibrary("bsdsocket.library",0)) ||
        ((sock = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP))<0))
    {
        if (SocketBase)
        {
            CloseLibrary(SocketBase);
            err = FREEDBV_Err_NoSocket;
        }
        else err = FREEDBV_Err_NoSocketBase;

        return err;
    }

    lr = (struct lineRead *)lrBuf;

    err = multi = called = 0;
    status = FREEDBV_Proc_Status_Init;

    FreeDBObtainConfig(FALSE);

    stccpy(host,msg->host ? msg->host : rexxLibBase->opts->activeSite->host,HOSTSIZE);
    hostPort = msg->hostPort ? msg->hostPort : rexxLibBase->opts->activeSite->port;
    stccpy(cgi,msg->cgi ? msg->cgi : rexxLibBase->opts->activeSite->cgi,CGISIZE);
    stccpy(proxy,msg->proxy ? msg->proxy : rexxLibBase->opts->proxy,PROXYSIZE);
    proxyPort = msg->proxyPort ? msg->proxyPort : rexxLibBase->opts->proxyPort;
    useProxy = (msg->flags & FREEDBV_StartMsg_Flags_UseProxySupplied) ? msg->useProxy : rexxLibBase->opts->useProxy;
    stccpy(user,msg->user ? msg->user : rexxLibBase->opts->user,USERSIZE);
    stccpy(prg,msg->prg ? msg->prg : PRG,PRGSIZE);
    stccpy(ver,msg->ver ? msg->ver : VRSTRING,VERSIZE);

    FreeDBReleaseConfig();

    initLineRead(lr,SocketBase,sock,LRV_Type_ReqLF,LR_BUFSIZE);

    if (statusHook)
        if (err = CallHookPkt(statusHook,msg->handle,(APTR)FREEDBV_Handle_Status_ResolvingHost))
            goto end;

    if (useProxy)
    {
        hostName = proxy;
        sin.sin_port = proxyPort;
    }
    else
    {
        hostName = host;
        sin.sin_port = hostPort;
    }

    if ((long)(sin.sin_addr.s_addr = inet_addr(hostName))==INADDR_NONE)
    {
        register struct hostent *host;

        if (host = gethostbyname(hostName)) memcpy(&sin.sin_addr.s_addr,host->h_addr,4);
        else
        {
            err = useProxy ? FREEDBV_Err_NoProxy : FREEDBV_Err_NoHost;
            goto end;
        }
    }

    sin.sin_family = AF_INET;
    sin.sin_len    = sizeof(struct sockaddr_in);

    if (statusHook)
        if (err = CallHookPkt(statusHook,msg->handle,(APTR)FREEDBV_Handle_Status_Connecting))
            goto end;

    if (connect(sock,(struct sockaddr *)&sin,sizeof(sin))<0)
    {
        err = FREEDBV_Err_CantConnect;
        goto end;
    }

    if (cmd==FREEDBV_Command_Submit)
    {
        register char           *c;
        register struct TagItem hattrs[] = {FREEDBA_DiscInfo,0,
                                            FREEDBA_TOC,0,
                                            FREEDBA_Prg,0,
                                            FREEDBA_Ver,0,
                                            TAG_DONE};

        hattrs[0].ti_Data = (ULONG)di;
        hattrs[1].ti_Data = (ULONG)toc;
        hattrs[2].ti_Data = (ULONG)prg;
        hattrs[3].ti_Data = (ULONG)ver;

        if (err = FreeDBMakeHeader(hattrs))
            goto end;

        //kprintf("HEADER: [%s]\n",di->header);

        headerLen = strlen(di->header);
        c = PathPart(cgi);
        *c = 0;
        AddPart(cgi,SUBMIT_CGI,sizeof(cgi));
        if (!strcmp(cgi,SUBMIT_CGI)) strcpy(cgi,"/"SUBMIT_CGI);

        if (useProxy) len = snprintf(buf,BUFZISE,"POST http://%s:%ld%s HTTP/1.0\r\n",host,hostPort,cgi);
        else len = snprintf(buf,BUFZISE,"POST %s HTTP/1.0\r\n",cgi);

        snprintf(buf+len,BUFZISE-len,"\\
Content-length: %ld\r\n\\
Discid: %08lx\r\n\\
Category: %s\r\n\\
User-Email: %s\r\n\\
Submit-Mode: submit\r\n\r\n",headerLen,toc->discID,di->categ,email);
    }
    else
    {
        /*
         * Commons 1
         * UseProxy==1: GET http://[HOST:HOSTPORT][CGI]?cmd=
         * UseProxy==0: GET [CGI]?cmd=
        */
        if (useProxy)
            len = snprintf(buf,BUFZISE,"GET http://%s:%ld%s?cmd=",host,hostPort,cgi);
        else len = snprintf(buf,BUFZISE,"GET %s?cmd=",cgi);

        /*
         * UseProxy dependent dependent 1
         */
        switch (cmd)
        {
            register int tracks;

            // cddb+query+[DiskID]+[Tracks]+{TrackStart}+[TotSecs]
            case FREEDBV_Command_Query:
            {
                len += snprintf(buf+len,BUFZISE-len,"cddb+query+%08lx+%ld",toc->discID,tracks = toc->numTracks);

                for (i = 0; i<tracks; i++)
                    len += snprintf(buf+len,BUFZISE-len,"+%ld",toc->tracks[i].startAddr+150);

                len += snprintf(buf+len,BUFZISE-len,"+%ld",toc->min*60+toc->sec+2);

                break;
            }

            // cddb+read+[Categ]+[DiskID]
            case FREEDBV_Command_Read:
            {
                register char   *categ  = *msg->categ ? msg->categ : di->categ;
                register ULONG  discID = msg->discID ? msg->discID : di->discID;

                len += snprintf(buf+len,BUFZISE-len,"cddb+read+%s+%08lx",categ,discID);
                break;
            }

            // sites
            case FREEDBV_Command_Sites:
            {
                len += snprintf(buf+len,BUFZISE-len,"sites");
                break;
            }

            // lscat
            case FREEDBV_Command_LsCat:
            {
                len += snprintf(buf+len,BUFZISE-len,"lscat");
                break;
            }
        }

        /*
         * UseProxy dependent dependent 2
         *
         * UseProxy==1: &hello=ILoveNewYork+[PROXY]+
         * UseProxy==0: &hello=[USER]+[USER_HOST]+
         */
        if (useProxy)
            len += snprintf(buf+len,BUFZISE-len,"&hello=ILoveNewYork+%s+",Inet_NtoA(sin.sin_addr.s_addr));
        else
        {
            len += snprintf(buf+len,BUFZISE-len,"&hello=%s+",user);
            l = sizeof(struct sockaddr_in);
            if (((getsockname(sock,(struct sockaddr *)&sin,&l))>=0) && (sin.sin_addr.s_addr!=INADDR_NONE))
                len += snprintf(buf+len,BUFZISE-len,"%s+",Inet_NtoA(sin.sin_addr.s_addr));
            else len += snprintf(buf+len,BUFZISE-len,"amiga.com+");
        }

        /*
         * Common End
         * [PRG]+[VER]&proto=5 HTTP/1.0\r\nUser-Agent: PRG/VRSTRING\r\nAccept: text/plain\r\n\r\n
         */
        snprintf(buf+len,BUFZISE-len,"%s+%s&proto=5 HTTP/1.0\r\nUser-Agent: " PRG"/"VRSTRING"\r\nAccept: text/plain\r\n\r\n",prg,ver);
    }

    if (statusHook)
        if (err = CallHookPkt(statusHook,msg->handle,(APTR)FREEDBV_Handle_Status_Sending))
            goto end;

    if (send(sock,buf,strlen(buf),0)<0)
    {
        err = FREEDBV_Err_Send;
        goto end;
    }

    if (cmd==FREEDBV_Command_Submit)
    {
        if (send(sock,di->header,headerLen,0)<0)
        {
            err = FREEDBV_Err_Send;
            goto end;
        }
    }

    if (statusHook)
        if (err = CallHookPkt(statusHook,msg->handle,(APTR)FREEDBV_Handle_Status_Receiving))
            goto end;

    if (errorBuffer) *errorBuffer = 0;

    FD_ZERO(&read);

    while (1)
    {
        FD_SET(sock,&read);

        if (WaitSelect(sock+1,&read,NULL,NULL,NULL,0)<0)
        {
            err = FREEDBV_Err_Recv;
            goto end;
        }

        if (!FD_ISSET(sock,&read)) continue;

        if ((l = lineRead(lr))==0)
        {
            if (status<=FREEDBV_Proc_Status_Result) err = FREEDBV_Err_ServerError;
            goto end;
        }

        while (l>0)
        {
            register char *line = lr->line;

            switch (status)
            {
                case FREEDBV_Proc_Status_Init:
                    ra.RDA_Source.CS_Buffer  = line;
                    ra.RDA_Source.CS_Length  = strlen(line);
                    ra.RDA_Source.CS_CurChr  = 0;
                    ra.RDA_DAList            = NULL;
                    ra.RDA_Buffer            = buf;
                    ra.RDA_BufSiz            = BUFZISE;
                    ra.RDA_Flags             = RDAF_NOALLOC|RDAF_NOPROMPT;
                    if (!ReadArgs("HTTP/A,CODE/A/N,REST/A/F",parms,&ra))
                    {
                        err = FREEDBV_Err_ServerHTTPError;
                        goto end;
                    }

                    if (strnicmp("HTTP/",(STRPTR)parms[0],5))
                    {
                        err = FREEDBV_Err_ServerHTTPError;
                        goto end;
                    }

                    code = GETNUM(parms[1]);
                    if (code!=200)
                    {
                        err = FREEDBV_Err_ServerError;
                        goto end;
                    }

                    status = FREEDBV_Proc_Status_SkipHead;
                    break;

                case FREEDBV_Proc_Status_SkipHead:
                    if (line[0]=='\r' && line[1]=='\n') status = FREEDBV_Proc_Status_Result;
                    break;

                case FREEDBV_Proc_Status_Result:
                {
                    ra.RDA_Source.CS_Buffer  = line;
                    ra.RDA_Source.CS_Length  = strlen(line);
                    ra.RDA_Source.CS_CurChr  = 0;
                    ra.RDA_DAList            = NULL;
                    ra.RDA_Buffer            = buf;
                    ra.RDA_BufSiz            = BUFZISE;
                    ra.RDA_Flags             = RDAF_NOALLOC|RDAF_NOPROMPT;
                    if (!ReadArgs("CODE/A/N,REST/A/F",parms,&ra))
                    {
                        err = FREEDBV_Err_ServerError;
                        goto end;
                    }

                    code = GETNUM(parms[0]);
                    switch (code)
                    {
                        case 200:
                        {
                            switch (cmd)
                            {
                                case FREEDBV_Command_Query:
                                {
                                    register char   *t;
                                    long            discID;

                                    ra.RDA_Source.CS_Buffer  = line;
                                    ra.RDA_Source.CS_Length  = strlen(line);
                                    ra.RDA_Source.CS_CurChr  = 0;
                                    ra.RDA_DAList            = NULL;
                                    ra.RDA_Buffer            = buf;
                                    ra.RDA_BufSiz            = BUFZISE;
                                    ra.RDA_Flags             = RDAF_NOALLOC|RDAF_NOPROMPT;
                                    if (!ReadArgs("CODE/A/N,CATEG/A,DISCID/A,TA/A/F",parms,&ra))
                                    {
                                        err = FREEDBV_Err_ServerError;
                                        goto end;
                                    }

                                    if ((stch_l((STRPTR)parms[2],&discID)!=strlen((STRPTR)parms[2])) || (discID==0))
                                    {
                                        err = FREEDBV_Err_ServerError;
                                        goto end;
                                    }

                                    for (t = (STRPTR)parms[3]; *t && *t!='\n' && *t!='\r'; t++);
                                    *t = 0;

                                    if (t = strstr((STRPTR)parms[3]," / "))
                                    {
                                        *t = 0;
                                        t += 3;
                                        if (!*t) t = (STRPTR)parms[3];
                                    }
                                    else t = (STRPTR)parms[3];

                                    stccpy(di->categ,(STRPTR)parms[1],sizeof(di->categ));
                                    di->discID = discID;
                                    stccpy(di->artist,(STRPTR)parms[3],sizeof(di->artist));
                                    stccpy(di->title,t,sizeof(di->title));

                                    status = FREEDBV_Proc_Status_Ignore;

                                    break;
                                }

                                case FREEDBV_Command_Submit:
                                    status = FREEDBV_Proc_Status_Ignore;
                                    break;

                                default:
                                {
                                    status = FREEDBV_Proc_Status_Multi;
                                    break;
                                }
                            }
                            break;
                        }

                        case 210: case 211:
                        {
                            status = FREEDBV_Proc_Status_Multi;

                            switch (cmd)
                            {
                                case FREEDBV_Command_Query:
                                {
                                    multi = 1;
                                    break;
                                }

                                default:
                                    break;
                            }

                            break;
                        }

                        case 202:
                        {
                            err = FREEDBV_Err_NotFound;
                            if (errorBuffer) stccpy(errorBuffer,line,errorBufferLen);
                            goto end;
                            break;
                        }

                        default:
                        {
                            err = FREEDBV_Err_ServerError;
                            if (errorBuffer) stccpy(errorBuffer,line,errorBufferLen);
                            goto end;
                            break;
                        }
                    }
                    break;
                }

                case FREEDBV_Proc_Status_Multi:
                {
                    if (line[0]=='.') goto end;

                    switch (cmd)
                    {
                        case FREEDBV_Command_Query:
                        {
                            if (multiHook)
                            {
                                register struct FREEDBS_MultiHookMessage    *m;
                                register char                               *t;
                                long                                        discID;

                                ra.RDA_Source.CS_Buffer  = line;
                                ra.RDA_Source.CS_Length  = strlen(line);
                                ra.RDA_Source.CS_CurChr  = 0;
                                ra.RDA_DAList            = NULL;
                                ra.RDA_Buffer            = buf;
                                ra.RDA_BufSiz            = BUFZISE;
                                ra.RDA_Flags             = RDAF_NOALLOC|RDAF_NOPROMPT;
                                if (!ReadArgs("CATEG/A,DISCID/A,TA/A/F",parms,&ra))
                                {
                                    err = FREEDBV_Err_ServerError;
                                    goto end;
                                }

                                for (t = (STRPTR)parms[2]; *t && *t!='\n' && *t!='\r'; t++);
                                *t = 0;

                                if ((stch_l((STRPTR)parms[1],&discID)!=strlen((STRPTR)parms[1])) || (discID==0))
                                {
                                    err = FREEDBV_Err_ServerError;
                                    goto end;
                                }

                                if (!(m = allocMessage(sizeof(struct FREEDBS_MultiHookMessage))))
                                {
                                    err = FREEDBV_Err_NoMem;
                                    goto end;
                                }

                                if (t = strstr((STRPTR)parms[2]," / "))
                                {
                                    *t = 0;
                                    t += 3;
                                    if (!*t) t = (STRPTR)parms[2];
                                }
                                else t = (STRPTR)parms[2];

                                m->code   = code;
                                m->discID = discID;
                                sprintf(m->discIDString,"%08lx",discID);
                                stccpy(m->categ,(STRPTR)parms[0],sizeof(m->categ));
                                stccpy(m->artist,(STRPTR)parms[2],sizeof(m->artist));
                                stccpy(m->title,t,sizeof(m->title));

                                if (err = CallHookPkt(multiHook,msg->handle,m))
                                    goto end;

                                called++;
                            }
                            else status = FREEDBV_Proc_Status_Ignore;

                            break;
                        }

                        case FREEDBV_Command_Read:
                        {
                            register char *c;

                            for (c = line; *c && *c!='\n' && *c!='\r'; c++);
                            *c = 0;

                            if (err = parseLine(di,line,0)) goto end;
                            called++;

                            break;
                        }

                        case FREEDBV_Command_Sites:
                        {
                            if (sitesHook)
                            {
                                register struct FREEDBS_SitesHookMessage    *m;
                                register char                               *c;

                                ra.RDA_Source.CS_Buffer  = line;
                                ra.RDA_Source.CS_Length  = strlen(line);
                                ra.RDA_Source.CS_CurChr  = 0;
                                ra.RDA_DAList            = NULL;
                                ra.RDA_Buffer            = buf;
                                ra.RDA_BufSiz            = BUFZISE;
                                ra.RDA_Flags             = RDAF_NOALLOC|RDAF_NOPROMPT;
                                if (!ReadArgs("SITE/A,PROTO/A,PORT/A/N,CGI/A,LAT/A,LONG/A,DESC/A/F",parms,&ra))
                                {
                                    err = FREEDBV_Err_ServerError;
                                    goto end;
                                }

                                for (c = (STRPTR)parms[6]; *c && *c!='\n' && *c!='\r'; c++);
                                *c = 0;

                                if (stricmp((STRPTR)parms[1],"HTTP")) break;

                                if (!(m = allocMessage(sizeof(struct FREEDBS_SitesHookMessage))))
                                {
                                    err = FREEDBV_Err_NoMem;
                                    goto end;
                                }

                                stccpy(m->host,(STRPTR)parms[0],sizeof(m->host));
                                m->port = (UWORD)GETNUM(parms[2]);
                                sprintf(m->portString,"%ld",m->port);
                                stccpy(m->cgi,(STRPTR)parms[3],sizeof(m->cgi));
                                stccpy(m->latitude,(STRPTR)parms[4],sizeof(m->latitude));
                                stccpy(m->longitude,(STRPTR)parms[5],sizeof(m->longitude));
                                stccpy(m->description,(STRPTR)parms[6],sizeof(m->description));

                                if (err = CallHookPkt(sitesHook,msg->handle,m))
                                    goto end;

                                called++;
                            }
                            else status = FREEDBV_Proc_Status_Ignore;

                            break;
                        }

                        case FREEDBV_Command_LsCat:
                        {
                            if (lsCatHook)
                            {
                                register struct FREEDBS_LsCatHookMessage    *m;
                                register char                               *c;


                                for (c = line; *c && *c!='\n' && *c!='\r'; c++);
                                *c = 0;

                                if (!(m = allocMessage(sizeof(struct FREEDBS_LsCatHookMessage))))
                                {
                                    err = FREEDBV_Err_NoMem;
                                    goto end;
                                }

                                stccpy(m->categ,line,sizeof(m->categ));

                                if (err = CallHookPkt(lsCatHook,msg->handle,m))
                                    goto end;

                                called++;
                            }
                            else status = FREEDBV_Proc_Status_Ignore;

                            break;
                        }
                    }
                    break;
                }

                case FREEDBV_Proc_Status_Ignore:
                    break;
            }

            l = lineRead(lr);
        }

        if (l<0)
        {
            err = FREEDBV_Err_Recv;
            goto end;
        }
    }

end:
    if (status==FREEDBV_Proc_Status_Multi && !called) err = FREEDBV_Err_ServerError;

    if (statusHook && (err || !(flags & FREEDBV_DispatchMsg_Flags_NtDone)))
        CallHookPkt(statusHook,msg->handle,(APTR)(err ? FREEDBV_Handle_Status_Error : FREEDBV_Handle_Status_Done));

    if (!err)
    {
        if (multi) err = FREEDBV_Err_Multi;
        else
            if (di && (cmd==FREEDBV_Command_Read))
                err = checkDiscInfo(di,toc);
    }
    else
    {
        l = Errno();
        if (l==4) err = FREEDBV_Err_Aborted;
    }

    shutdown(sock,2);
    CloseSocket(sock);
    CloseLibrary(SocketBase);

    return err;
}

/****************************************************************************/

void SAVEDS
FreeDBProc(void)
{
    struct Process                      *me = (struct Process *)FindTask(NULL);
    register struct FREEDBS_StartMsg    *msg;
    register LONG                       err;

    WaitPort(&me->pr_MsgPort);
    msg = (struct FREEDBS_StartMsg *)GetMsg(&me->pr_MsgPort);

    switch (msg->cmd)
    {
        case FREEDBV_Command_QueryRead:
            msg->cmd = FREEDBV_Command_Query;
            if (!(err = dispatchMsg(msg,FREEDBV_DispatchMsg_Flags_NtDone)))
            {
                msg->cmd = FREEDBV_Command_Read;
                err = dispatchMsg(msg,0);
            }
            msg->cmd = FREEDBV_Command_QueryRead;
            break;

        default:
            err = dispatchMsg(msg,0);
            break;
    }

    ObtainSemaphore(&msg->handle->sem);
    msg->handle->proc = NULL;
    ReleaseSemaphore(&msg->handle->sem);

    msg->err = err;

    Forbid();
    ReplyMsg((struct Message *)msg);
    rexxLibBase->use--;
}

/****************************************************************************/
