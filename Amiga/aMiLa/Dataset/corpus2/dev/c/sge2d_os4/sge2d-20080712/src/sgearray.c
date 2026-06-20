#include <sge.h>

SGEARRAY *sgeArrayNew() {
	SGEARRAY *ret;
	sgeNew(ret, SGEARRAY);
	ret->numberOfElements=0;
	ret->freeFunction=NULL;
	sgeMalloc(ret->element, void *, 1);
	return ret;
}

SGEARRAY *sgeAutoArrayNew(void (*function)(Uint32, void *)) {
	SGEARRAY *ret=sgeArrayNew();
	ret->freeFunction=function;
	return ret;
}

void sgeArrayDestroy(SGEARRAY *a) {
	if (a->freeFunction!=NULL) {
		while (a->numberOfElements>0) {
			sgeArrayRemove(a, 0);
		}
	}
	sgeFree(a->element);
	sgeFree(a);
}

void sgeArrayAdd(SGEARRAY *a, void *e) {
	a->numberOfElements++;
	sgeRealloc(a->element, void *, a->numberOfElements);
	a->element[a->numberOfElements-1]=e;
}

void sgeArrayInsert(SGEARRAY *a, Uint32 offset, void *e) {
	if (offset>=a->numberOfElements) {
		sgeArrayAdd(a, e);
		return;
	}

	sgeRealloc(a->element, void *, ++a->numberOfElements);
	memmove(a->element+offset+1,a->element+offset,(a->numberOfElements-offset-1)*sizeof(void *));
	a->element[offset]=e;
}

void sgeArrayReplace(SGEARRAY *a, Uint32 offset, void *e) {
	if (offset>=a->numberOfElements) {
		return;
	}

	a->element[offset]=e;
}

void *sgeArrayGet(SGEARRAY *a, Uint32 offset) {
	if (offset<a->numberOfElements) {
		return a->element[offset];
	}
	return NULL;
}

void sgeArrayRemove(SGEARRAY *a, Uint32 offset) {
	if (a->numberOfElements>0) {
		if (a->freeFunction!=NULL) {
			(a->freeFunction)(offset, a->element[offset]);
		}
		memmove(a->element+offset,a->element+offset+1,(a->numberOfElements-offset-1)*sizeof(void *));
		a->numberOfElements--;
	}
}

void sgeArrayForEach(SGEARRAY *a, void function(Uint32, void *)) {
	Uint32 i;
	for (i=0;i<a->numberOfElements;i++) {
		function(i, a->element[i]);
	}
}

