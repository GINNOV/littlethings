#include <stdlib.h>
#include <exec/types.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <stdio.h>
#include <string.h>
#include <intuition/intuition.h>
#include <proto/all.h>
#include <clib/dos_protos.h>

#include "headers/talkto_proto.h"
#include "headers/deamon.h"
#include "headers/Error_proto.h"
#include "headers/global.h"

BOOL Error(char *);

int CXBRK(void) { return(0); }
int chkabort(void) {return(0);}

struct CurrentUser	*ID;

BOOL SafePutToPort(struct Message *, STRPTR);

unsigned long TalkTo(User,Pass,Pass1,contr)
char		*User,*Pass,*Pass1;
unsigned long 	contr;
{
   	struct MsgPort 		*SecReplyPort;
    	struct SecMessage 	*Secmsg, *reply;
	unsigned long		sys;

#if (DEBUG)
fprintf(stderr,"talking to \n");
#endif
	if (!FindPort(DEAMON)) {
		if (!system(BOOTDEAM)) {
			Error("cannot open Deamon");
			exit(1);
		}
	}
    	if (SecReplyPort = CreatePort(0,0)) {
        	if (Secmsg = (struct SecMessage *) AllocMem(sizeof(struct SecMessage), MEMF_PUBLIC | MEMF_CLEAR)){
            		Secmsg->LoginMsg.mn_Node.ln_Type = NT_MESSAGE;             
            		Secmsg->LoginMsg.mn_Length = sizeof(struct SecMessage);    
            		Secmsg->LoginMsg.mn_ReplyPort = SecReplyPort;
            		strcpy(Secmsg->User,User);
            		strcpy(Secmsg->Password,Pass);
			Secmsg->Control = contr;

            		if (SafePutToPort((struct Message *)Secmsg,DEAMON)) {
#if (DEBUG)
	fprintf(stderr,"waiting\n");
#endif
		                WaitPort(SecReplyPort);
#if (DEBUG)
	fprintf(stderr,"got the\n");
#endif
                		if (reply = (struct SecMessage *)GetMsg(SecReplyPort)) {
					sys = Secmsg->Access;
				}
				if (contr == WHOAMI) {
					ID = Secmsg->UserData;
				}
					
      			}
            		else {
				Error("Can't find 'Secport'");
	            		FreeMem(Secmsg, sizeof(struct SecMessage));
				return FALSE;
			}
        	}
        	else Error("Couldn't get memory");
        	DeletePort(SecReplyPort);
    	}
    	else Error("Couldn't create SecReplyPort");
#if (DEBUG)
fprintf(stderr,"finished talking\n");
#endif
	if (sys) return OK;
	else return -1;
}


BOOL SafePutToPort(struct Message *message, STRPTR portname)
{
    struct MsgPort *port;

    Forbid();
    port = FindPort(portname);
    if (port) PutMsg(port, message);
    Permit();
    return (BOOL)(port ? TRUE : FALSE);
}