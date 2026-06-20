/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AView wrapper class                                                       *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AView_H
#define ASAP_AView_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class AView : public View
{
 public:
 inline UWORD CalcIVG(struct ViewPort * vp);
 inline void InitView();
 inline void LoadView();
 inline ULONG MrgCop();
};
//----------------------------------------------------------------------------
UWORD AView::CalcIVG (struct ViewPort * vp)
{
 return ::CalcIVG(this, vp);
}
//----------------------------------------------------------------------------
void AView::InitView ()
{
 ::InitView(this);
}
//----------------------------------------------------------------------------
void AView::LoadView ()
{
 ::LoadView(this);
}
//----------------------------------------------------------------------------
ULONG AView::MrgCop ()
{
 return ::MrgCop(this);
}

#endif
