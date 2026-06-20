#include <exec/ports.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "headers/global.h"
#include "headers/deamon.h"
#include "headers/talkto_proto.h"

static const char __Version[]=LOGOUTVERST;

void __main(argv)
char *argv;
{
	ULONG	Status;

	Status = TalkTo(NULL,NULL,NULL,LOGOUT);	/*send signal to deamon to start login*/
	if (!(Status == OK)) {
		printf("logout Failed\n");
	}
}