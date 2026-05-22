#include <exec/ports.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "headers/global.h"
#include "headers/deamon.h"
#include "headers/talkto_proto.h"

static const char __Version[]=WHOAMIVERST;

extern struct CurrentUser *ID;

main() {

	ULONG	Status;

	Status = TalkTo(NULL,NULL,NULL,WHOAMI);
	if (!(Status == OK)) {
		printf("Who Am I Failed\n");
	}
	else {
		printf("%s\n",ID->Login);
		printf("%s\n",ID->Name);
		printf("UID %ld GID %ld\n",ID->UID,ID->GID);
		if (!ID->Locks) {
			printf("currently No restrictions\n");
		}
	}
}