#ifndef WINDOW_H
#define WINDOW_H

#include <proto/graphics.h>
#include <proto/intuition.h>

struct Window *openwindow(STRPTR vpmodeid, STRPTR bitdepth, STRPTR colors);

#endif
