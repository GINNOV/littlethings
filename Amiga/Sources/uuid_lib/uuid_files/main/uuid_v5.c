/* v5 UUID */

#include <proto/exec.h>
#include <proto/utility.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "uuid_v5.h"

bool uuidv5(uuid_t *uuid, uuid_t *namespace, char *name)
{

	struct MessageDigest_SHA mdsha;
	
	IUtility->MessageDigest_SHA_Init(&mdsha);
	IUtility->MessageDigest_SHA_Update(&mdsha, namespace, 16);
	IUtility->MessageDigest_SHA_Update(&mdsha, name, strlen(name));
	IUtility->MessageDigest_SHA_Final(&mdsha);
	
	IExec->CopyMem(&mdsha.mdsha_Code, &uuid->time_low, 4);
	IExec->CopyMem(&mdsha.mdsha_Code[4], &uuid->time_mid, 2);
	IExec->CopyMem(&mdsha.mdsha_Code[6], &uuid->time_hi_and_version, 2);

	uuid->clock_seq_hi_and_reserved = mdsha.mdsha_Code[8];
	uuid->clock_seq_low = mdsha.mdsha_Code[9];

	uuid->node[0] = mdsha.mdsha_Code[10];
	uuid->node[1] = mdsha.mdsha_Code[11];
	uuid->node[2] = mdsha.mdsha_Code[12];
	uuid->node[3] = mdsha.mdsha_Code[13];
	uuid->node[4] = mdsha.mdsha_Code[14];
	uuid->node[5] = mdsha.mdsha_Code[15];

	uuid->clock_seq_hi_and_reserved |= (1 << 7);
	uuid->clock_seq_hi_and_reserved &= ~(1 << 6);

	uuid->time_hi_and_version |= (1 << 12);
	uuid->time_hi_and_version &= ~(1 << 13);
	uuid->time_hi_and_version |= (1 << 14);
	uuid->time_hi_and_version &= ~(1 << 15);

	return true;
}
