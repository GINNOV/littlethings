#ifndef _SGEARRAY_H
#define _SGEARRAY_H

typedef struct {
	Uint32 numberOfElements;
	void **element;
	void (*freeFunction)(Uint32, void *);
} SGEARRAY;

SGEARRAY *sgeArrayNew(void);
SGEARRAY *sgeAutoArrayNew(void (*function)(Uint32, void *));
void sgeArrayDestroy(SGEARRAY *a);

void sgeArrayAdd(SGEARRAY *a, void *e);
void sgeArrayInsert(SGEARRAY *a, Uint32 offset, void *e);
void sgeArrayReplace(SGEARRAY *a, Uint32 offset, void *e);
void *sgeArrayGet(SGEARRAY *a, Uint32 offset);
void sgeArrayRemove(SGEARRAY *a, Uint32 offset);
void sgeArrayForEach(SGEARRAY *a, void function(Uint32, void *));

#endif
