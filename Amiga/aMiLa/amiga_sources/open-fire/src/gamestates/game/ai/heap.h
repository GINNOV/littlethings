#ifndef GUARD_OF_GAMESTATES_GAME_AI_HEAP_H
#define GUARD_OF_GAMESTATES_GAME_AI_HEAP_H

#include <ace/types.h>

typedef struct _tHeapEntry {
	UWORD uwPriority;
	void *pData;
} tHeapEntry;

typedef struct _tHeap {
	UWORD uwMaxEntries;
	UWORD uwCount;
	tHeapEntry *pEntries;
} tHeap;

tHeap *heapCreate(UWORD uwMaxEntries);

void heapDestroy(tHeap *pHeap);

void heapPush(tHeap *pHeap, void *pData, UWORD uwPriority);

void *heapPop(tHeap *pHeap);

static inline void heapClear(tHeap *pHeap) {
	pHeap->uwCount = 0;
}

#endif // GUARD_OF_GAMESTATES_GAME_AI_HEAP_H
