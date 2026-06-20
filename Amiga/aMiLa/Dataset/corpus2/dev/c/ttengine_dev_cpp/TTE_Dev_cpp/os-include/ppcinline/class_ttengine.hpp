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
#ifndef CLASS_TTENGINE_HPP
#define CLASS_TTENGINE_HPP

#include <proto/exec.h>
#include <ppcinline/macros.hpp>
#include <ppcinline/tte_internal.hpp>


const long TTENGINE_version = 7;

class TTEngine
{
    	Library *TTEngineBase;
    public:
    	static TTEngine *Base;


        STRPTR *TT_ObtainFamilyListA(struct TagItem *taglist)
        {
            	return LibTemplate1<STRPTR *>(-120,taglist,TTEngineBase,REG_A0);
    	}
        void TT_TextExtent(struct RastPort * rp, APTR str, WORD count, struct TextExtent * te)
        {
            LibTemplate4<void>(-72,rp,str,count,te,TTEngineBase,REG_A1,REG_A0,REG_D0,REG_A2);
        }

    	void TT_FreeFamilyList(STRPTR *lst)
    	{
        	LibTemplate1<void>(-126,lst,TTEngineBase,REG_A0);
    	}

        ULONG TT_TextLength(struct RastPort * rp, APTR str, ULONG count)
        {
            return LibTemplate3<ULONG>(-66,rp,str,count,TTEngineBase,REG_A1,REG_A0,REG_D0);
        }
        ULONG TT_TextFit(struct RastPort * rp, APTR str, UWORD count, struct TextExtent * te,
  					struct TextExtent * tec, WORD dir, UWORD cwidth, UWORD cheight)
        {
        	return LibTemplate8<ULONG>(-78,rp,str,count,te,tec,dir,cwidth,cheight,TTEngineBase,REG_A1,REG_A0,REG_D0,REG_A2,REG_A3,REG_D1,REG_D2,REG_D3);
    	}

        struct TagItem* TT_RequestA(APTR request, struct TagItem * taglist)
        {
        	return LibTemplate2<struct TagItem*>(-108,request,taglist,TTEngineBase,REG_A0,REG_A1);
    	}

        APTR TT_OpenFontA(struct TagItem * taglist)
        {
            return LibTemplate1<APTR>(-30,taglist,TTEngineBase,REG_A0);
    	}
        void TT_FreeRequest(APTR request)
        {
        	LibTemplate1<void>(-114,request,TTEngineBase,REG_A0);
    	}

        void TT_CloseFont(APTR font)
        {
            LibTemplate1<APTR>(-42,font,TTEngineBase,REG_A0);
        }
        void TT_Text(struct RastPort * rp, const char *str, ULONG count)
        {
            LibTemplate3<void>(-48,rp,str,count,TTEngineBase,REG_A1,REG_A0,REG_D0);
    	}
        BOOL TT_SetFont(struct RastPort * rp, APTR font)
        {
            return LibTemplate2<BOOL>(-36,rp,font,TTEngineBase,REG_A1,REG_A0);
        }
        ULONG TT_SetAttrsA(struct RastPort * rp, struct TagItem * taglist)
        {
            return LibTemplate2<BOOL>(-54,rp,taglist,TTEngineBase,REG_A1,REG_A0);
        }
        void TT_DoneRastPort(struct RastPort * rp)
        {
            LibTemplate1<void>(-96,rp,TTEngineBase,REG_A1);
        }
        ULONG TT_GetAttrsA(struct RastPort * rp, struct TagItem * taglist)
        {
            return LibTemplate2<ULONG>(-60,rp,taglist,TTEngineBase,REG_A1,REG_A0);
        }
        struct TT_Pixmap * TT_GetPixmapA(APTR font, APTR str, ULONG count,struct TagItem * taglist)
        {
            return LibTemplate4<struct TT_Pixmap *>(-84,font,str,count,taglist,TTEngineBase,REG_A1,REG_A2,REG_D0,REG_A0);
        }
        void TT_FreePixmap(struct TT_Pixmap * pixmap)
        {
            LibTemplate1<void>(-90,pixmap,TTEngineBase,REG_A0);
        }
        APTR TT_AllocRequest()
        {
            return LibTemplate0<APTR>(-102,TTEngineBase);
        }

        TTEngine()
        {
            TTEngineBase=OpenLibrary("ttengine.library", TTENGINE_version);
            TT_ObtainFamilyList.SetTTBase(this);
            TT_OpenFont.SetTTBase(this);
            TT_SetAttrs.SetTTBase(this);
            TT_Request.SetTTBase(this);
            TT_GetAttrs.SetTTBase(this);
            TT_GetPixmap.SetTTBase(this);

    	}
        ~TTEngine()
        {
            CloseLibrary(TTEngineBase);
            TTEngineBase=NULL;
    	}

        TTT_OpenFont TT_OpenFont;
        TTT_ObtainFamilyList TT_ObtainFamilyList;
        TTT_SetAttrs TT_SetAttrs;
        TTT_Request TT_Request;
        TTT_GetAttrs TT_GetAttrs;
        TTT_GetPixmap TT_GetPixmap;

};

inline ULONG TTT_SetAttrs::Func(struct RastPort * rp,Tag *tab)
{
    if (Base)
    	return Base->TT_SetAttrsA(rp,(struct TagItem *)tab);
    else
    	return NULL;
}
inline STRPTR *TTT_ObtainFamilyList::Func(Tag *tab)
{
    if (Base)
    	return Base->TT_ObtainFamilyListA((struct TagItem *)tab);
    else
    	return NULL;
}
inline struct TagItem *TTT_Request::Func(APTR request, Tag * tab)
{
    if (Base)
    	return Base->TT_RequestA(request,(struct TagItem *)tab);
    else
    	return NULL;
}
inline APTR TTT_OpenFont::Func(Tag *tab)
{
    if (Base)
    {
        return Base->TT_OpenFontA((struct TagItem *)tab);
    }
    else
    	return NULL;
}

inline ULONG TTT_GetAttrs::Func(struct RastPort * rp,Tag *tab)
{
    if (Base)
    	return Base->TT_GetAttrsA(rp,(struct TagItem *)tab);
    else
    	return 0;
}

inline struct TT_Pixmap *TTT_GetPixmap::Func(APTR font,APTR str,ULONG count,Tag *tab)
{
    if (Base)
    	return Base->TT_GetPixmapA(font,str,count,(struct TagItem *)tab);
    else
    	return 0;
}


#endif
