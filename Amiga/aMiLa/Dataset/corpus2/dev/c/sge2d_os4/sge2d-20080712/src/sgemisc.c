#include <sge.h>

int sgeGetDistance(int x, int y, int xx, int yy) {
	int distx=xx-x;
	int disty=yy-y;

	return (int) sgeRound(sqrt(distx*distx+disty*disty));
}

