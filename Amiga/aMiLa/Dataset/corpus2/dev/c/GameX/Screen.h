
#ifndef SCREEN_H
#define SCREEN_H

#include <exec/types.h>

struct windowuser
{
    struct Window *w;
    struct Layer_Info *li;
    struct BitMap *gfx;
};

struct rpuser
{
    struct Layer *l;
    void (*draw)(struct rpuser *rpu);
};

struct Window *openscreen(struct windowuser *wu);
void closescreen(struct windowuser *wu);
WORD instcopper(struct windowuser *wu);
void remcopper(void);
struct Layer *createlayer(struct windowuser *wu, struct rpuser *rpu, WORD x0, WORD y0, WORD x1, WORD y1);
struct Layer *movelayer(struct windowuser *wu, struct rpuser *rpu, WORD x0, WORD y0, WORD x1, WORD y1);

void rectfill(struct RastPort *rp, WORD x0, WORD y0, WORD x1, WORD y1);
void blttile(struct BitMap *sbm, WORD xsrc, WORD ysrc, struct RastPort *rp, WORD xdest, WORD ydest, WORD width, WORD height);

#endif /* SCREEN_H */
