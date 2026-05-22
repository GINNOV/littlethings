/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_HEAP_H
#define GERMZ_HEAP_H

#include <ace/types.h>

typedef struct tHeapEntry {
	UWORD uwPriority;
	const void *pData;
} tHeapEntry;

typedef struct tHeap {
	UWORD uwMaxEntries;
	UWORD uwCount;
	tHeapEntry *pEntries;
} tHeap;

tHeap *heapCreate(UWORD uwMaxEntries);

void heapDestroy(tHeap *pHeap);

void heapPush(tHeap *pHeap, const void *pData, UWORD uwPriority);

const void *heapPop(tHeap *pHeap);

static inline void heapClear(tHeap *pHeap) {
	pHeap->uwCount = 0;
}

#endif // GERMZ_HEAP_H
