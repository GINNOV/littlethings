#ifndef _OF_CACHE_H_
#define _OF_CACHE_H_

#include <ace/types.h>

UBYTE cacheIsValid(const char *szPath);

void cacheGenerateChecksum(const char *szPath);

#endif // _OF_CACHE_H_
