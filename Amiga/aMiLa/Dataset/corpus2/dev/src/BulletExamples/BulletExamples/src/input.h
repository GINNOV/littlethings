#ifndef INPUT_H
#define INPUT_H

#include <proto/intuition.h>

void waitclose(struct Window *w);
int getkey(struct Window *w);
int handlekey(struct Window *w);

#endif
