#include <sge.h>

static void sgePathFinderInfoFree(Uint32 id, void *data) {
	sgePathFinderInfoDestroy((SGEPATHFINDERINFO *)data);
}

SGEPATHFINDER *sgePathFinderNew(int width, int height) {
	SGEPATHFINDER *ret;
	sgeNew(ret, SGEPATHFINDER);
	ret->width=width;
	ret->height=height;
	sgeMalloc(ret->map, unsigned char, width*height);
	ret->path=sgeAutoArrayNew(&sgePathFinderInfoFree);
	ret->useDiagonal=1;
	return ret;
}

SGEPATHFINDER *sgePathFinderNewDiagonal(int width, int height, int diagonal) {
	SGEPATHFINDER *ret=sgePathFinderNew(width, height);
	sgePathFinderDiagonal(ret, diagonal);
	return ret;
}

void sgePathFinderDestroy(SGEPATHFINDER *p) {
	if (p->map!=NULL) {
		sgeFree(p->map);
	}
	sgeArrayDestroy(p->path);
	sgeFree(p);
}

inline void sgePathFinderDiagonal(SGEPATHFINDER *p, int diagonal) {
	p->useDiagonal=diagonal;
}

SGEPATHFINDERINFO *sgePathFinderInfoNew(int x, int y, int startWeight, int targetWeight, void *parent) {
	SGEPATHFINDERINFO *ret;
	sgeNew(ret, SGEPATHFINDERINFO);
	ret->x=x;
	ret->y=y;
	ret->startWeight=startWeight;
	ret->targetWeight=targetWeight;
	ret->parent=parent;
	return ret;
}

void sgePathFinderInfoDestroy(SGEPATHFINDERINFO *pi) {
	sgeFree(pi);
}

void sgePathFinderSet(SGEPATHFINDER *p, int x, int y, int value) {
	p->map[y*p->width+x]=(unsigned char) value;
}

int sgePathFinderGet(SGEPATHFINDER *p, int x, int y) {
	if ( (x<0) || (x>p->width-1) ) return 1;
	if ( (y<0) || (y>p->height-1) ) return 1;
	return (int)p->map[y*p->width+x];
}

static int sgePathFinderIsClosed(SGEPATHFINDER *p, unsigned char *map, int x, int y) {
	if ( (x<0) || (x>p->width-1) ) return 1;
	if ( (y<0) || (y>p->height-1) ) return 1;
	return (int)map[y*p->width+x];
}

int sgePathFinderFind(SGEPATHFINDER *p, int startx, int starty, int destx, int desty) {
	int found=0;
	SGEARRAY *openList;
	SGEARRAY *closedList;
	unsigned char *scannedMap;
	SGEPATHFINDERINFO *pi=NULL;
	SGEPATHFINDERINFO *opi=NULL;
	int x,y;
	int dist;
	int newweight;
	int idx;
	int xstart, xend, xstep;

	sgeMalloc(scannedMap, unsigned char, p->width*p->height);
	openList=sgeArrayNew();
	closedList=sgeArrayNew();
	sgeArrayAdd(openList,sgePathFinderInfoNew(startx, starty, 0, 0, NULL));

	while ( (!found) && (openList->numberOfElements) ) {
		pi=sgeArrayGet(openList, 0);
		sgeArrayRemove(openList, 0);
		if ( (pi->x==destx) && (pi->y==desty) ) {
			sgeArrayAdd(closedList, pi);
			found=1;
			continue;
		}
		for (y=pi->y-1;y<pi->y+2;y++) {
			if (p->useDiagonal==ENABLE_DIAGONAL) {
				xstart=pi->x-1;
				xend=pi->x+2;
				xstep=1;
			} else {
				if (y==pi->y) {
					xstart=pi->x-1;
					xend=pi->x+2;
					xstep=2;
				} else {
					xstart=pi->x;
					xend=pi->x+1;
					xstep=1;
				}
			}
			for (x=xstart;x<xend;x+=xstep) {
				if (
						(!sgePathFinderIsClosed(p, scannedMap, x, y)) &&
						(!sgePathFinderGet(p, x, y)) &&
						((x!=pi->x) || (y!=pi->y))
				) {
					dist=sgeGetDistance(x<<7,y<<7,destx<<7,desty<<7);
					if (openList->numberOfElements) {
						newweight=pi->startWeight+1+dist;

						opi=sgeArrayGet(openList,0);
						idx=1;
						while (
								(opi->startWeight+opi->targetWeight<=newweight) &&
								(idx<openList->numberOfElements)
						) {
							opi=sgeArrayGet(openList,idx++);
						}
						if (idx==openList->numberOfElements) {
							sgeArrayAdd(openList,sgePathFinderInfoNew(x, y, pi->startWeight+1, dist, pi));
						} else {
							sgeArrayInsert(openList,idx-1,sgePathFinderInfoNew(x, y, pi->startWeight+1, dist, pi));
						}
					} else {
						sgeArrayAdd(openList,sgePathFinderInfoNew(x, y, pi->startWeight+1, dist, pi));
					}
					scannedMap[y*p->width+x]=1;
				}
			}
		}
		sgeArrayAdd(closedList, pi);
	}

	sgeFree(scannedMap);

	while (openList->numberOfElements) {
		opi=sgeArrayGet(openList,0);
		sgePathFinderInfoDestroy(opi);
		sgeArrayRemove(openList,0);
	}
	sgeArrayDestroy(openList);

	sgeArrayDestroy(p->path);
	p->path=sgeAutoArrayNew(&sgePathFinderInfoFree);

	if (!found) {
		while (closedList->numberOfElements) {
			opi=sgeArrayGet(closedList,0);
			sgePathFinderInfoDestroy(opi);
			sgeArrayRemove(closedList,0);
		}
		sgeArrayDestroy(closedList);
		return 0;
	}

	while (pi->parent!=NULL) {
		opi=(SGEPATHFINDERINFO *)pi->parent;
		sgeArrayInsert(p->path, 0, sgePathFinderInfoNew(pi->x, pi->y, 0, 0, NULL));
		pi=opi;
	}
	while (closedList->numberOfElements) {
		opi=sgeArrayGet(closedList,0);
		sgePathFinderInfoDestroy(opi);
		sgeArrayRemove(closedList,0);
	}
	sgeArrayDestroy(closedList);

	return 1;
}

