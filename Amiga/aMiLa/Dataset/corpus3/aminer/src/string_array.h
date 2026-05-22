/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _STRING_ARRAY_H_
#define _STRING_ARRAY_H_

#include <ace/utils/file.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Array of string pointers terimnated with nullptr
 */

#define STRING_ARRAY_EMPTY_POS ((char*)-1)
#define STRING_ARRAY_TERMINATOR ((char*)0)

char **stringArrayCreateFromFd(tFile *pFile);

void stringArrayDestroy(char **pArray);

UWORD stringArrayGetCount(const char * const *pArray);

#ifdef __cplusplus
}
#endif

#endif // _STRING_ARRAY_H_
