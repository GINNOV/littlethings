/* v4 UUID */

#include <proto/exec.h>
#include <stdio.h>

#include "uuid_v4.h"

bool uuidv4(uuid_t *uuid)
{
	FILE *rndf = NULL;
	if(rndf = fopen("RANDOM:", "r")) {
		fread(uuid, 1, 16, rndf);
		fclose(rndf);
	} else {
		return false;
	}
	
	uuid->clock_seq_hi_and_reserved |= (1 << 7);
	uuid->clock_seq_hi_and_reserved &= ~(1 << 6);

	uuid->time_hi_and_version &= ~(1 << 12);
	uuid->time_hi_and_version &= ~(1 << 13);
	uuid->time_hi_and_version |= (1 << 14);
	uuid->time_hi_and_version &= ~(1 << 15);
	
	return true;
}
