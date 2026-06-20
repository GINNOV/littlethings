/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ATextAttr wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_TextAttr_H
#define ASAP_TextAttr_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class ATextAttr : public TextAttr
{
 public:
 inline WORD WeighTAMatch(TextAttr *reqTextAttr, TagItem *targetTags);
 inline WORD WeighTAMatchTags(TextAttr *reqTextAttr, unsigned long tag1Type, ...);
};

//-----------------------------------------------------------------------------
WORD ATextAttr::WeighTAMatch (TextAttr *reqTextAttr, TagItem *targetTags )
{
 return ::WeighTAMatch (reqTextAttr, this, targetTags);
}
//-----------------------------------------------------------------------------
WORD ATextAttr::WeighTAMatchTags (TextAttr *reqTextAttr, unsigned long tag1Type, ...)
{
 return ::WeighTAMatch(reqTextAttr, this, (TagItem *) &tag1Type);
}

#endif
