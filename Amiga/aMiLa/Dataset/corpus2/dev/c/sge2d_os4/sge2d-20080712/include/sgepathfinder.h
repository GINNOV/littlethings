#ifndef _SGEPATHFINDER_H
#define _SGEPATHFINDER_H

#define DISABLE_DIAGONAL 0
#define ENABLE_DIAGONAL 1

typedef struct {
	int x;
	int y;
	int startWeight;
	int targetWeight;
	void *parent;
} SGEPATHFINDERINFO;

typedef struct {
	int width;
	int height;
	unsigned char *map;
	SGEARRAY *path;
	int useDiagonal;
} SGEPATHFINDER;

SGEPATHFINDER *sgePathFinderNew(int width, int height);
SGEPATHFINDER *sgePathFinderNewDiagonal(int width, int height, int diagonal);
void sgePathFinderDestroy(SGEPATHFINDER *p);

SGEPATHFINDERINFO *sgePathFinderInfoNew(int x, int y, int startWeight, int targetWeight, void *parent);
void sgePathFinderInfoDestroy(SGEPATHFINDERINFO *pi);

inline void sgePathFinderDiagonal(SGEPATHFINDER *p, int diagonal);
void sgePathFinderSet(SGEPATHFINDER *p, int x, int y, int value);
int sgePathFinderGet(SGEPATHFINDER *p, int x, int y);
int sgePathFinderFind(SGEPATHFINDER *p, int startx, int starty, int destx, int desty);

#endif
