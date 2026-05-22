/* uuid_v5.h */

#ifndef UUID_V5_H
#define UUID_V5_H 1

#include <stdbool.h>
#include "uuid_private.h"

bool uuidv5(uuid_t *uuid, uuid_t *namespace, char *name);

#endif
