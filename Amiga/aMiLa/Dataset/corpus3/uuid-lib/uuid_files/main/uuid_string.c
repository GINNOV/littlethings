/* UUID from string */

#include <stdio.h>

#include "uuid_string.h"

bool uuid_string(uuid_t *uuid, char *str)
{
	uint32 time_low;
	int time_mid, time_hi_and_version, clock_seq_hi_and_reserved, clock_seq_low;
	int node0, node1, node2, node3, node4, node5;
	

	int ret = sscanf(str, "%08lx-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
					&time_low,
					&time_mid,
					&time_hi_and_version,
					&clock_seq_hi_and_reserved,
					&clock_seq_low,
					&node0,
					&node1,
					&node2,
					&node3,
					&node4,
					&node5);

	if(ret == 11) {
		uuid->time_low = time_low;
		uuid->time_mid = time_mid;
		uuid->time_hi_and_version = time_hi_and_version;
		uuid->clock_seq_hi_and_reserved = clock_seq_hi_and_reserved;
		uuid->clock_seq_low = clock_seq_low;
		uuid->node[0] = node0;
		uuid->node[1] = node1;
		uuid->node[2] = node2;
		uuid->node[3] = node3;
		uuid->node[4] = node4;
		uuid->node[5] = node5;

		return true;
	} else {
		return false;
	}
}
