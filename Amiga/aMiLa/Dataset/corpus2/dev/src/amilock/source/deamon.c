#include <exec/types.h>
#include <exec/PORTS.h>
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <stdio.h>
#include <intuition/intuition.h>
#include <proto/all.h>
#include <string.h>
#include <stdlib.h>

#include "headers/Deamon.h"
#include "headers/Deamon_proto.h"
#include "headers/talkto_proto.h"
#include "headers/global.h"
#include "headers/error_proto.h"

#define PASSWORD PASSWD
BOOL LoginCheck(char *, char *);

struct CurrentUser 	Current = {"Nobody","NDBY",NULL,NULL,NULL};
ULONG			lock=NULL;

BOOL LoginCheck(user,pass)
char *user,*pass;
{
	FILE	*fin;
	char	User[100]="";
	char	Name[100]="";
	char	Pass[100]="";
	char	buffer[500]="";
	ULONG 	GID=0,UID=0;
	short	i=0,j=0;
	if (lock) UnLock(lock);
	retry1:
	if (!(fin = fopen(PASSWORD,"r"))){
		if (Error("Can't open password file\n")) goto retry1;
		exit(10);
	}
	if (strlen(user) < 2) {
		fclose(fin);
		lock = Lock(PASSWORD,EXCLUSIVE_LOCK);
		return FALSE;
	}
	while (!feof(fin)&&strcmp(user,User)) {
		if (!fgets(buffer,500,fin)) {
			break;
		}

		i =0;
		j=0;
		while (buffer[i] != '|') 
			User[j++] = buffer[i++];
		User[j] = NULL;
		i++;
		j = 0;
		while (buffer[i] != '|') 
			Pass[j++] = buffer[i++];
		Pass[j] = NULL;
		i++;
		j = 0;
		while (buffer[i] != '|') 
			Name[j++] = buffer[i++];
		Name[j] = NULL;
		
		sscanf(&(buffer[i+1]),"%ld|%ld",&GID,&UID);
	}

	fclose(fin);
	if ((strlen(Pass)<=1)&&(!strcmp(user,User))||(!strcmp(user,User))&&(!strcmp(pass,Pass))) {
		strcpy(Current.Login,User);
		strcpy(Current.Name,Name);
		Current.GID = GID;
		Current.UID = UID;
		Current.Locks = NULL;
		if (!strcmp("Root",User)) {
			lock = NULL;
		}
		else lock = Lock(PASSWORD,EXCLUSIVE_LOCK);
		return TRUE;
	}
	lock = Lock(PASSWORD,EXCLUSIVE_LOCK);
	return FALSE;
}

static const char __Version[]=DEAMVERST;


#if (DEBUG)
	void main()
#else
	void __main(argv)
	char 	*argv;
#endif
{
    	struct MsgPort 		*SecPort;
    	struct SecMessage 	*SecMsg;
    	ULONG 			portsig,usersig,signal;
    	BOOL 			ABORT = FALSE;
	struct CurrentUser	*User;
	
	if (FindPort(DEAMON)) {
		if (Error("Port exists, kill deamon")) {
			TalkTo(NULL,NULL,NULL,QUIT);
		}
		exit(0);
	}

	lock = Lock(PASSWORD,EXCLUSIVE_LOCK/*SHARED_LOCK*/);
	if (!lock) Error("Unable to lock data base");

    	if (SecPort = CreatePort(DEAMON, 0))
    	{
        	portsig = 1 << SecPort->mp_SigBit;
        	usersig = SIGBREAKF_CTRL_C;
        	do {
            		signal = Wait(portsig); 
            		if (signal | portsig){ 
	                	while(SecMsg = (struct SecMessage *)GetMsg(SecPort)) {
					SecMsg->Access = FALSE;
		               		if (SecMsg->Control == QUIT) {
						if (Error("Quit???")) 
						ABORT = TRUE;
						SecMsg->Access = TRUE;
					}
					else if (SecMsg->Control == WHOAMI) {
						if (!(User = malloc(sizeof(struct CurrentUser))))
							Error("Cannot Malloc()");
						strcpy(User->Name,Current.Name);
						strcpy(User->Login,Current.Login);
						User->GID = Current.GID;
						User->UID = Current.UID;
						SecMsg->UserData = User;
						User = NULL;
						SecMsg->Access = TRUE;	
					}
					else if (SecMsg->Control == LOGOUT) {
						strcpy(Current.Name,"");
						strcpy(Current.Login,"");
						Current.GID = Current.UID = NULL;
						system("login");
					}
					else if (SecMsg->Control == LOGIN) {
#if (DEBUG)
#endif
						SecMsg->Access = LoginCheck(SecMsg->User,SecMsg->Password);
#if (DEBUG)
#endif
					}
	               	    		ReplyMsg((struct Message *)SecMsg);
				}
			}
			else ABORT = FALSE;
			while (SecMsg = (struct SecMessage *)GetMsg(SecPort)) {
	               		ReplyMsg((struct Message *)SecMsg);
			}

        	} while (!ABORT);
		DeletePort(SecPort);
        }
	else Error("Couldn't create 'Security Port'");
	UnLock(lock);
}
