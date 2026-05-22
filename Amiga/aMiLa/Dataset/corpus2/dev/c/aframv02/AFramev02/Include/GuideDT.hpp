//////////////////////////////////////////////////////////////////////////////
// GuideDT.hpp
//
// Deryk Robosson
// April 7, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __GUIDEDT_HPP__
#define __GUIDEDT_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/datatype.hpp"
#include <libraries/amigaguide.h>
#include <proto/amigaguide.h>

//////////////////////////////////////////////////////////////////////////////
// Definitions

extern struct Library *AmigaGuideBase;

typedef struct
{
    STRPTR              buffer;     // buffer pointer
    ULONG               bufferlen;  // buffer length
    AFString            fontname;   // font name
    struct TextFont     *tf;        // textfont pointer
    TEXTATTR            ta;         // text attributes
} GUIDEDT;

//////////////////////////////////////////////////////////////////////////////
// GuideDT Class

class AFGuideDT : public AFDataType
{
public:

    AFGuideDT();
    ~AFGuideDT();

    virtual char *ObjectType() { return "GuideDT"; };

    void DestroyObject();
    BOOL LoadGuide(char *file_name, struct Screen *screen);
    BOOL SaveGuide(char *file_name, ULONG savetype);

    GUIDEDT     m_dtGuide;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __GUIDEDT_HPP__
