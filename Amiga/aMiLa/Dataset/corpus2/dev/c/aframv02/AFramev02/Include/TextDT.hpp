//////////////////////////////////////////////////////////////////////////////
// TextDT.hpp
//
// Deryk Robosson
// March 17, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __TEXTDT_HPP__
#define __TEXTDT_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/datatype.hpp"

//////////////////////////////////////////////////////////////////////////////
// Definitions

typedef struct
{
    STRPTR              buffer;     // buffer pointer
    ULONG               bufferlen;  // buffer length
    AFString            fontname;   // font name
    struct  List        *linelist;  // line list pointer
    struct  TextFont    *tf;        // textfont pointer
    TEXTATTR            ta;         // text attributes
} TEXTDT;

//////////////////////////////////////////////////////////////////////////////
// TextDT Class

class AFTextDT : public AFDataType
{
public:

    AFTextDT();
    ~AFTextDT();

    virtual char *ObjectType() { return "TextDT"; };

    BOOL LoadText(char *file_name,struct Screen*);
    UBYTE* GetBuffer(UBYTE *buffer);
    ULONG GetBufferSize();
    BOOL SetBuffer(UBYTE *buffer,ULONG size);
    BOOL SetDTFont(struct TextFont *textfont);
    BOOL SetDTFontAttr(TEXTATTR ta);

    TEXTDT    m_dtText;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __TEXTDT_HPP__
