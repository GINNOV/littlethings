/*
	This file is copyright by Tomasz Kaczanowski. You can use it for free,
    but you must add info about using this code and info about author. Remember
    also, that if you want to have new versions of this code and other codes
    for AmigaOS-like systems you should motivate author of this code. You
    can send him a small gift or mail or bug report.

    contact:
       kaczus (at) poczta (_) onet (_) pl
       or
       kaczus (at) wp (_) pl
    (_) replaced dot.
    Don't forget also about Krashan!!! - author of ttengine!
*/
#ifndef _PPCINLINE_TTE_INTERNAL_HPP
#define _PPCINLINE_TTE_INTERNAL_HPP

#include <ppcinline/macros.hpp>
#include <utility/tagitem.h>

class TTEngine;

class TTT_ObtainFamilyList:public TFloatingArgs<STRPTR *,Tag>
{
    protected:
    TTEngine *Base;
    inline STRPTR *Func(Tag *tab);

    public:
    void SetTTBase(TTEngine *B)
    {
        Base=B;
    }
};

class TTT_OpenFont:public TFloatingArgs<APTR,Tag>
{
    protected:
    TTEngine *Base;
    inline APTR Func(Tag *tab);

    public:
    void SetTTBase(TTEngine *B)
    {
        Base=B;
    }
};

class TTT_SetAttrs:public TFloatingArgs1<ULONG,struct RastPort *,Tag>
{
    protected:
    TTEngine *Base;
    inline ULONG Func(struct RastPort * rp,Tag *tab);

    public:
    void SetTTBase(TTEngine *B)
    {
        Base=B;
    }
};

class TTT_Request:public TFloatingArgs1<struct TagItem*,APTR ,Tag>
{
    protected:
    TTEngine *Base;
    inline struct TagItem *Func(APTR request, Tag* tab);

    public:
    void SetTTBase(TTEngine *B)
    {
        Base=B;
    }
};
class TTT_GetAttrs:public TFloatingArgs1<ULONG,struct RastPort *,Tag>
{
    protected:
    TTEngine *Base;
    inline ULONG Func(struct RastPort * rp,Tag *tab);

    public:
    void SetTTBase(TTEngine *B)
    {
        Base=B;
    }
};


class TTT_GetPixmap:public TFloatingArgs3<struct TT_Pixmap *,APTR,APTR,ULONG,Tag>
{
    protected:
    TTEngine *Base;
    inline struct TT_Pixmap *Func(APTR font,APTR str,ULONG count,Tag *tab);

    public:
    void SetTTBase(TTEngine *B)
    {
        Base=B;
    }
};

#endif

