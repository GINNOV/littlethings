#include <exec/ports.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "headers/global.h"
#include "headers/deamon.h"
#include "headers/talkto_proto.h"

static const char __Version[]=LOGINVERST;


main() {
	unsigned long	Status;

	do {
		Status = TalkTo(NULL,NULL,NULL,QUIT);
		if (!(Status == OK)) {
			printf("Kill Failed\n");
		}
	} while (!(Status == OK));
}