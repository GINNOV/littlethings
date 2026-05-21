/* uuid.h */

#ifndef _LIBRARIES_UUID__PRIV_H_
#define _LIBRARIES_UUID__PRIV_H_ 1

#include <exec/types.h>

typedef struct {
    uint32  time_low;
    uint16  time_mid;
    uint16  time_hi_and_version;
    uint8   clock_seq_hi_and_reserved;
    uint8   clock_seq_low;
    char        node[6];
} uuid_t;

#endif
