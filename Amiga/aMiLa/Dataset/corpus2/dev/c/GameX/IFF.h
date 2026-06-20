
#ifndef IFF_H
#define IFF_H

#include <exec/types.h>

#define RGB(c) ((c)|((c)<<8)|((c)<<16)|((c)<<24))

struct BitMap *loadilbm(STRPTR name, struct ColorMap *cm);

#endif
