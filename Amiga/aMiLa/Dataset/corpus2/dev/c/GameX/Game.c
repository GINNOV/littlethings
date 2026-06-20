
#include <stdlib.h>

#include <graphics/rpattr.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>

#include "Screen.h"
#include "IFF.h"

#define ESC_KEY 0x45

WORD pos[8][10];

void loop(struct windowuser *wu, struct rpuser *rpu, WORD cop)
{
    ULONG sigs[] =
    {
        1L << cop,
        1L << wu->w->UserPort->mp_SigBit
    }, total;
    BOOL done = FALSE;
    BOOL refresh = FALSE;
    WORD cx = wu->w->MouseX & 0xfff0, cy = wu->w->MouseY & 0xfff0;
    UBYTE text[] = "GameX Demo 1 - Window + Animated Scenery";

    total = sigs[0]|sigs[1];

    SetSignal(0L, sigs[0]);

    while (!done)
    {
        ULONG result = Wait(total);

        if (result & sigs[0])
        {
            refresh = TRUE;
            if (refresh)
            {
                WORD x, y;

                if (rpu[0].l->DamageList->RegionRectangle)
                {
                    BeginUpdate(rpu[0].l);
                    rectfill(rpu[0].l->rp, 0, 0, 639, 255);
                    Move(rpu[0].l->rp, 0, rpu[0].l->rp->Font->tf_Baseline);
                    Text(rpu[0].l->rp, text, sizeof(text) - 1);
                    EndUpdate(rpu[0].l, TRUE);
                }

                SetBPen(rpu[1].l->rp, 7);
                rectfill(rpu[1].l->rp, 0, 0, 319, 19);



                static WORD frame = 0;

                for (y = 1; y < 6; y++)
                {
                    for (x = 0; x < 10; x++)
                    {
                        if (pos[y][x])
                        {
                            if (frame == 0)
                            {
                            #if 0
                                pos[y][x] = 1 + (rand() % 3);
                            #endif
                            }
                        }

                        WORD xpos = (pos[y][x] % 4);
                        WORD ypos = (pos[y][x] / 4);

                        if (xpos < 3 && frame == 0)
                        {
                            xpos = rand() % 3;
                            pos[y][x] = (ypos * 4) + xpos;
                        }

                        blttile(wu->gfx, xpos << 5, ypos * 20, rpu[1].l->rp, x << 5, y * 20, 32, 20);
                    }
                }
                if (++frame == 16)
                {
                    frame = 0;
                }

                refresh = FALSE;
            }
        }

        if (result & sigs[1])
        {
            struct IntuiMessage *msg;

            while (msg = (struct IntuiMessage *)GetMsg(wu->w->UserPort))
            {
                ULONG class = msg->Class;
                WORD code = msg->Code;
                WORD mx = msg->MouseX;
                WORD my = msg->MouseY;

                ReplyMsg((struct Message *)msg);

                if (class == IDCMP_RAWKEY)
                {
                    if (code == ESC_KEY)
                    {
                        done = TRUE;
                    }
                }
                else if (class == IDCMP_MOUSEMOVE)
                {
                    cx = mx & 0xfff0;
                    cy = my & 0xfff0;

                    WORD x = cx;
                    WORD y = cy;

                    if (x - 160 < 0)
                    {
                        x = 160;
                    }
                    if (y - 64 < 0)
                    {
                        y = 64;
                    }
                    if (x + 160 > 640)
                    {
                        x = 480;
                    }
                    if (y + 64 > 192)
                    {
                        y = 192 - 64;
                    }
                    x -= 160;
                    y -= 64;

                    if (rpu[1].l->bounds.MinX != x || rpu[1].l->bounds.MinY != y)
                    {
                        movelayer(wu, rpu + 1, x, y, x + 319, y + (20 * 6) - 1);
                        SetRPAttrs(rpu[1].l->rp,
                            RPTAG_BPen,         3,
                            RPTAG_WriteMask,    7,
                            TAG_DONE);
                        refresh = TRUE;
                    }
                }
            }
        }
    }
}

int main(void)
{
    struct windowuser wu;
    struct rpuser rpu[2];
    WORD x, y;
    WORD map[] =
    {
        0, 3, 4, 7
    };

    for (y = 0; y < 8; y++)
    {
        for (x = 0; x < 10; x++)
        {
            pos[y][x] = map[rand() % 4];
        }
    }

    if (openscreen(&wu))
    {
        WORD cop;

        if (wu.gfx = loadilbm("Data/Tree.bsh", wu.w->WScreen->ViewPort.ColorMap))
        {
            MakeScreen(wu.w->WScreen);
            RethinkDisplay();

            if ((cop = instcopper(&wu)) != -1)
            {
                if (createlayer(&wu, rpu, 0, 0, 639, 255))
                {
                    if (createlayer(&wu, rpu + 1, 0, 0, 319, 20 * 6 - 1))
                    {
                        SetRPAttrs(rpu[0].l->rp,
                            RPTAG_APen, 1,
                            RPTAG_BPen, 0,
                            TAG_DONE);

                        SetRPAttrs(rpu[1].l->rp,
                            RPTAG_BPen, 0,
                            TAG_DONE);

                        SetWriteMask(rpu[0].l->rp, 7);
                        SetWriteMask(rpu[1].l->rp, 7);

                        loop(&wu, rpu, cop);

                        DeleteLayer(0, rpu[1].l);
                    }
                    DeleteLayer(0, rpu[0].l);
                }
                remcopper();
            }
            FreeBitMap(wu.gfx);
        }
        closescreen(&wu);
    }
    return(0);
}
