/* v1 UUID */

#include <proto/exec.h>
#include <stdio.h>

#include "store.h"
#include "uuid_v1.h"

#define GREGTOAMIGASECS (uint64)12471757200ULL

bool uuidv1(uuid_t *uuid)
{
	uint64 uuidtime = store_get_timestamp();
	
	if(uuidtime == 0ULL) return false;

	uuid->time_low = (uint32)(uuidtime & 0xFFFFFFFF);
	uuid->time_mid = (uint16)((uuidtime >> 32) & 0xFFFF);
	uuid->time_hi_and_version = (uint16)((uuidtime >> 48) & 0x0FFF);

	UBYTE *mac = store_get_mac();
	UBYTE *clockseq = store_get_clockseq();
	
	uuid->clock_seq_low = clockseq[0];
	uuid->clock_seq_hi_and_reserved = clockseq[1];
	
	uuid->node[0] = mac[0];
	uuid->node[1] = mac[1];
	uuid->node[2] = mac[2];
	uuid->node[3] = mac[3];
	uuid->node[4] = mac[4];
	uuid->node[5] = mac[5];
	
	uuid->clock_seq_hi_and_reserved |= (1 << 7);
	uuid->clock_seq_hi_and_reserved &= ~(1 << 6);

	uuid->time_hi_and_version |= (1 << 12);
	uuid->time_hi_and_version &= ~(1 << 13);
	uuid->time_hi_and_version &= ~(1 << 14);
	uuid->time_hi_and_version &= ~(1 << 15);
	
	return true;
}
