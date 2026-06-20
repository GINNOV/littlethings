
#include <stdio.h>
#include <assert.h>

#include <intuition/screens.h>
#include <intuition/intuition.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>
#include <graphics/gfxmacros.h>
#include <exec/interrupts.h>
#include <exec/memory.h>
#include <hardware/blit.h>
#include <graphics/rpattr.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/layers_protos.h>
#include <clib/graphics_protos.h>

#include "Screen.h"

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))

__far extern struct Custom custom;

static struct Interrupt cis;

struct copperdata
{
    struct ViewPort *vp;
    WORD sigBit;
    struct Task *task;
};

static struct copperdata cdata;

__saveds __asm __regargs static LONG mycopper(register __a1 struct copperdata *cd)
{
    if (!(cd->vp->Modes & VP_HIDE))
    {
        Signal(cd->task, 1L << cd->sigBit);
    }
    return(0);
}

struct Window *openscreen(struct windowuser *wu)
{
    struct Screen *s;

    if (!(s = OpenScreenTags(NULL,
        SA_LikeWorkbench,   TRUE,
        SA_Title,           "GameX © 2023 CoreDigital Group",
        SA_ShowTitle,       FALSE,
        SA_Quiet,           TRUE,
        SA_Exclusive,       TRUE,
        SA_BackFill,        LAYERS_NOBACKFILL,
        SA_Depth,           3,
        TAG_DONE)))
        printf("Couldn't open screen.\n");
    else
    {
        struct Window *w;

        if (!(w = OpenWindowTags(NULL,
            WA_CustomScreen,    s,
            WA_Left,            0,
            WA_Top,             0,
            WA_Width,           s->Width,
            WA_Height,          s->Height,
            WA_Backdrop,        TRUE,
            WA_Borderless,      TRUE,
            WA_Activate,        TRUE,
            WA_RMBTrap,         TRUE,
            WA_SimpleRefresh,   TRUE,
            WA_NoCareRefresh,   TRUE,
            WA_BackFill,        LAYERS_NOBACKFILL,
            WA_IDCMP,           IDCMP_RAWKEY|IDCMP_MOUSEMOVE|IDCMP_MOUSEBUTTONS,
            WA_ReportMouse,     TRUE,
            WA_MouseQueue,      2,
            TAG_DONE)))
            printf("Couldn't open window.\n");
        else
        {
            w->UserData = (APTR)wu;
            wu->w = w;

            if (!(wu->li = NewLayerInfo()))
                printf("Couldn't create layer info.\n");
            else
            {
                InstallLayerInfoHook(wu->li, LAYERS_NOBACKFILL);
                return(w);
            }
            CloseWindow(w);
        }
        CloseScreen(s);
    }
    return(NULL);
}

void closescreen(struct windowuser *wu)
{
    struct Layer *top;
    struct Screen *s = wu->w->WScreen;

    while (top = wu->li->top_layer)
    {
        DeleteLayer(0, top);
    }

    DisposeLayerInfo(wu->li);
    CloseWindow(wu->w);
    CloseScreen(s);
}

WORD instcopper(struct windowuser *wu)
{
    cis.is_Code = (void(*)())mycopper;
    cis.is_Data = (APTR)&cdata;
    cis.is_Node.ln_Pri = 0;

    cdata.vp = &wu->w->WScreen->ViewPort;
    cdata.task = FindTask(NULL);

    if (!((cdata.sigBit = AllocSignal(-1)) != -1))
        printf("Couldn't alloc signal.\n");
    else
    {
        struct UCopList *ucl;

        if (!(ucl = AllocMem(sizeof(*ucl), MEMF_PUBLIC|MEMF_CLEAR)))
            printf("Couldn't alloc mem.\n");
        else
        {
            CINIT(ucl, 3);
            CWAIT(ucl, 200, 0);
            CMOVE(ucl, custom.intreq, INTF_SETCLR|INTF_COPER);
            CEND(ucl);

            Forbid();
            cdata.vp->UCopIns = ucl;
            Permit();

            RethinkDisplay();

            AddIntServer(INTB_COPER, &cis);

            SetTaskPri(cdata.task, 2);
            return(cdata.sigBit);
        }
        FreeSignal(cdata.sigBit);
    }
    return(-1);
}

void remcopper(void)
{
    SetTaskPri(cdata.task, 0);
    RemIntServer(INTB_COPER, &cis);
    FreeSignal(cdata.sigBit);
}

struct Layer *createlayer(struct windowuser *wu, struct rpuser *rpu, WORD x0, WORD y0, WORD x1, WORD y1)
{
    struct Layer *l;

    if (!(rpu->l = l = CreateUpfrontHookLayer(wu->li, wu->w->RPort->BitMap, x0, y0, x1, y1, LAYERSIMPLE, LAYERS_NOBACKFILL, NULL)))
        printf("Couldn't create layer.\n");
    else
    {
        l->rp->RP_User = (APTR)rpu;
        return(l);
    }
    return(NULL);
}

struct Layer *movelayer(struct windowuser *wu, struct rpuser *rpu, WORD x0, WORD y0, WORD x1, WORD y1)
{
    struct Layer *l = rpu->l;

    if (createlayer(wu, rpu, x0, y0, x1, y1))
    {
        /* Draw before deleting */

        DeleteLayer(0, l);
        return(rpu->l);
    }
    return(NULL);
}

void rectfillcr(struct RastPort *rp, WORD x0, WORD y0, WORD x1, WORD y1)
{
    LONG bpen, mask;
    struct Custom *c = &custom;
    struct BitMap *dbm = rp->BitMap;
    WORD i;
    WORD width = (x1 - x0 + 1) >> 4, height = y1 - y0 + 1;
    LONG offset = (y0 * dbm->BytesPerRow) + ((x0 >> 4) << 1);
    assert(width > 0);

    GetRPAttrs(rp,
        RPTAG_BPen,         &bpen,
        RPTAG_WriteMask,    &mask,
        TAG_DONE);

    OwnBlitter();

    for (i = 0; i < dbm->Depth; i++)
    {
        if (mask & 1)
        {
            WaitBlit();
            c->bltcon0 = A_TO_D|DEST;
            c->bltcon1 = 0;
            c->bltadat = -(bpen & 1);
            c->bltdpt  = dbm->Planes[i] + offset;
            c->bltdmod = dbm->BytesPerRow - (width << 1);
            c->bltafwm = 0xffff;
            c->bltalwm = 0xffff;
            c->bltsize = (height << HSIZEBITS) | width;
        }
        mask >>= 1;
        bpen >>= 1;
    }

    DisownBlitter();
}

void blttilecr(struct BitMap *sbm, WORD xsrc, WORD ysrc, struct RastPort *rp, WORD xdest, WORD ydest, WORD width, WORD height)
{
    LONG mask;
    struct Custom *c = &custom;
    struct BitMap *dbm = rp->BitMap;
    WORD i;
    LONG soffset = (ysrc * sbm->BytesPerRow) + ((xsrc >> 4) << 1);
    LONG doffset = (ydest * dbm->BytesPerRow) + ((xdest >> 4) << 1);

    GetRPAttrs(rp,
        RPTAG_WriteMask,    &mask,
        TAG_DONE);

    width >>= 4;
    assert(width > 0);

    OwnBlitter();

    for (i = 0; i < dbm->Depth; i++)
    {
        if (mask & 1)
        {
            WaitBlit();
            c->bltcon0 = A_TO_D|SRCA|DEST;
            c->bltcon1 = 0;
            c->bltapt  = sbm->Planes[i] + soffset;
            c->bltdpt  = dbm->Planes[i] + doffset;
            c->bltamod = sbm->BytesPerRow - (width << 1);
            c->bltdmod = dbm->BytesPerRow - (width << 1);
            c->bltafwm = 0xffff;
            c->bltalwm = 0xffff;
            c->bltsize = (height << HSIZEBITS) | width;
        }
        mask >>= 1;
    }

    DisownBlitter();
}

void rectfill(struct RastPort *rp, WORD x0, WORD y0, WORD x1, WORD y1)
{
    struct ClipRect *cr;
    struct Rectangle *lb = &rp->Layer->bounds;

    x0 += lb->MinX;
    x1 += lb->MinX;
    y0 += lb->MinY;
    y1 += lb->MinY;

    for (cr = rp->Layer->ClipRect; cr != NULL; cr = cr->Next)
    {
        if (!cr->lobs)
        {
            struct Rectangle *crb = &cr->bounds;

            WORD xs = MAX(x0, crb->MinX);
            WORD xe = MIN(x1, crb->MaxX);
            WORD ys = MAX(y0, crb->MinY);
            WORD ye = MIN(y1, crb->MaxY);

            if (xs < xe && ys < ye)
            {
                rectfillcr(rp, xs, ys, xe, ye);
            }
        }
    }
}

void blttile(struct BitMap *sbm, WORD xsrc, WORD ysrc, struct RastPort *rp, WORD xdest, WORD ydest, WORD width, WORD height)
{
    struct ClipRect *cr;
    struct Rectangle *lb = &rp->Layer->bounds;

    xdest += lb->MinX;
    ydest += lb->MinY;

    for (cr = rp->Layer->ClipRect; cr != NULL; cr = cr->Next)
    {
        if (!cr->lobs)
        {
            struct Rectangle *crb = &cr->bounds;

            WORD xs = MAX(xdest, crb->MinX);
            WORD xe = MIN(xdest + width - 1, crb->MaxX);
            WORD ys = MAX(ydest, crb->MinY);
            WORD ye = MIN(ydest + height - 1, crb->MaxY);

            WORD offx = xs - xdest;
            WORD offy = ys - ydest;

            if (xs < xe && ys < ye)
            {
                blttilecr(sbm, xsrc + offx, ysrc + offy, rp, xs, ys, xe - xs + 1, ye - ys + 1);
            }
        }
    }
}
