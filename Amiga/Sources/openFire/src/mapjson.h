#ifndef GUARD_OF_MAPJSON_H
#define GUARD_OF_MAPJSON_H

#include <ace/types.h>
#include "map.h"
#include "json.h"

UBYTE mapJsonGetMeta(const tJson *pJson, tMap *pMap);

void mapJsonReadTiles(const tJson *pJson, tMap *pMap);

void mapJsonReadControlPoints(const tJson *pJson);

#endif // GUARD_OF_MAPJSON_H
