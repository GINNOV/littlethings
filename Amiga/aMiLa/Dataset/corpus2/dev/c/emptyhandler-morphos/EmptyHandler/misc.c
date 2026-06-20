/*
    MISC.c
    ------
    DOS-Packet-Routinen
    grob angelehnt an eine ältere Routinensammlung
    von Phillip Lindsay

    Diese Version von Oliver Wagner, © Amiga-DOS

*/

#include <proto/exec.h>
#include <proto/dos.h>

/* Packet zurückgeben, mit entsprechenden Returncodes */

void returnpacket(struct ExecBase *SysBase, struct DosPacket *packet, struct Process *p, long res1, long res2)
{
    struct Message *msg;
    struct MsgPort *replyport;

    /* Return-Codes setzen */
    packet->dp_Res1=res1;
    packet->dp_Res2=res2;
    /* ReplyPort holen */
    replyport=packet->dp_Port;
    /* Zeiger auf die Exec-Message des Packets */
    msg=packet->dp_Link;
    /* Packet-Port zurücksetzen */
    packet->dp_Port=&p->pr_MsgPort;
    /* Message und Packet verbinden */
    msg->mn_Node.ln_Name=(char *)packet;
    msg->mn_Node.ln_Succ=NULL;
    msg->mn_Node.ln_Pred=NULL;
    /* und Message abschicken */
    PutMsg(replyport,msg);
}


struct DosPacket *getpacket(struct ExecBase *SysBase, struct Process *p)
{
    struct MsgPort *port;
    struct Message *msg;

    /* Port unseres Process */
    port = &p->pr_MsgPort;
    /* Auf Nachricht warten */
    WaitPort(port);
    /* Nachricht abholen */
    msg = GetMsg(port);
    /* Packet extrahieren und zurückgeben */
    return((struct DosPacket *)msg->mn_Node.ln_Name);
}

