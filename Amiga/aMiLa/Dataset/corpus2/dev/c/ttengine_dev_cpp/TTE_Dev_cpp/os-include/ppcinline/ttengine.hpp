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
#ifndef _PPCINLINE_TTENGINE_HPP
#define _PPCINLINE_TTENGINE_HPP
#include <proto/exec.h>
#include <ppcinline/macros.hpp>
#include <ppcinline/tte_internal.hpp>
#include <ppcinline/class_ttengine.hpp>



inline STRPTR *TT_ObtainFamilyListA(struct TagItem *taglist)
{
    if (TTEngine::Base)
    	return TTEngine::Base->TT_ObtainFamilyListA(taglist);
    else
    	return NULL;
}

inline void TT_TextExtent(struct RastPort * rp, APTR str, WORD count, struct TextExtent * te)
{
    if (TTEngine::Base)
        TTEngine::Base->TT_TextExtent(rp,str,count,te);
}


inline void TT_FreeFamilyList(STRPTR *lst)
{
    if (TTEngine::Base)
    	TTEngine::Base->TT_FreeFamilyList(lst);
}
inline ULONG TT_TextLength(struct RastPort * rp, APTR str, ULONG count)
{
    if (TTEngine::Base)
    	return TTEngine::Base->TT_TextLength(rp,str,count);
    else
    	return 0;
}
inline ULONG TT_TextFit(struct RastPort * rp, APTR str, UWORD count, struct TextExtent * te,
  			struct TextExtent * tec, WORD dir, UWORD cwidth, UWORD cheight)
{
	if (TTEngine::Base)
    	return TTEngine::Base->TT_TextFit(rp,str,count,te,tec,dir,cwidth,cheight);
   	else
    	return 0;
}
inline void TT_FreeRequest(APTR request)
{
    if (TTEngine::Base)
    	TTEngine::Base->TT_FreeRequest(request);
}

struct TagItem* TT_RequestA(APTR request, struct TagItem * taglist)
{
    if (TTEngine::Base)
    	return TTEngine::Base->TT_RequestA(request,taglist);
    else
    	return NULL;
}


inline APTR TT_OpenFontA(struct TagItem * taglist)
{
    if (TTEngine::Base)
    	return TTEngine::Base->TT_OpenFontA(taglist);
    else
    	return NULL;
}
inline void TT_CloseFont(APTR font)
{
    if (TTEngine::Base)
    	TTEngine::Base->TT_CloseFont(font);
}
inline void TT_Text(struct RastPort * rp, const char *str, ULONG count)
{
    if (TTEngine::Base)
    	TTEngine::Base->TT_Text(rp,str,count);
}
inline BOOL TT_SetFont(struct RastPort * rp, APTR font)
{
    if (TTEngine::Base)
    	return TTEngine::Base->TT_SetFont(rp,font);
    else
    	return FALSE;
}

inline ULONG TT_SetAttrsA(struct RastPort * rp, struct TagItem * taglist)
{
    if (TTEngine::Base)
    	return TTEngine::Base->TT_SetAttrsA(rp,taglist);
    else
    	return 0;
}


inline void TT_DoneRastPort(struct RastPort * rp)
{
    if (TTEngine::Base)
    	TTEngine::Base->TT_DoneRastPort(rp);
}



inline ULONG TT_GetAttrsA(struct RastPort * rp, struct TagItem * taglist)
{
    if (TTEngine::Base)
    	return TTEngine::Base->TT_GetAttrsA(rp,taglist);
    else
    	return 0;
}
inline struct TT_Pixmap * TT_GetPixmapA(APTR font, APTR str, ULONG count, struct TagItem * taglist)
{
	if (TTEngine::Base)
    	return TTEngine::Base->TT_GetPixmapA(font,str,count,taglist);
	else
    	return NULL;
}
inline void TT_FreePixmap(struct TT_Pixmap * pixmap)
{
	if (TTEngine::Base)
    	TTEngine::Base->TT_FreePixmap(pixmap);
}
inline APTR TT_AllocRequest()
{
	if (TTEngine::Base)
    	return TTEngine::Base->TT_AllocRequest();
    else
    	return NULL;
}




#endif
/*


#ifdef USE_INLINE_STDARG

#include <stdarg.h>

#define TT_GetAttrs(__p0, ...) \
	({ULONG _tags[] = { __VA_ARGS__ }; \
	TT_GetAttrsA(__p0, (struct TagItem *)_tags);})

#define TT_GetPixmap(__p0, __p1, __p2, ...) \
	({ULONG _tags[] = { __VA_ARGS__ }; \
	TT_GetPixmapA(__p0, __p1, __p2, (struct TagItem *)_tags);})

*/
