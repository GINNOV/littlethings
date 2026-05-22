#ifndef _PROC_H
#define _PROC_H

#include <proto/exec.h>
#include <proto/socket.h>
#include <bsdsocket/socketbasetags.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/tcp.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netdb.h>
#include <dos/dostags.h>
#include "lineread.h"

/***********************************************************************/

struct FREEDBS_StartMsg
{
    struct Message          link;
    struct FREEDBS_Handle   *handle;
    ULONG                   cmd;
    ULONG                   flags;
    LONG                    err;
    struct FREEDBS_TOC      *toc;
    struct FREEDBS_DiscInfo *di;
    char                    categ[256];
    ULONG                   discID;
    struct Hook             *statusHook;
    struct Hook             *multiHook;
    struct Hook             *sitesHook;
    struct Hook             *lsCatHook;
    char                    *host;
    int                     hostPort;
    char                    *cgi;
    char                    *proxy;
    int                     proxyPort;
    ULONG                   useProxy;
    char                    *user;
    char                    *email;
    char                    *prg;
    char                    *ver;
    char                    *errorBuffer;
    ULONG                   errorBufferLen;
};

enum
{
    FREEDBV_StartMsg_Flags_UseProxySupplied = 1,
};

struct FREEDBS_Handle
{
    struct SignalSemaphore  sem;
    struct MsgPort          port;
    int                     sig;
    struct Process          *proc;
    ULONG                   flags;
    struct FREEDBS_StartMsg msg;
    struct MsgPort          *pp;
};

enum
{
    FREEDBV_Handle_Flags_InUse = 1,
};

/***********************************************************************/

enum
{
    FREEDBV_Proc_Status_Init = 0,
    FREEDBV_Proc_Status_SkipHead,
    FREEDBV_Proc_Status_Result,
    FREEDBV_Proc_Status_Multi,
    FREEDBV_Proc_Status_Ignore,
};

/***********************************************************************/

#endif /* _PROC_H */
