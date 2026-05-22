//////////////////////////////////////////////////////////////////////////////
// PictureDT.hpp
//
// Deryk Robosson
// March 16, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __PICTUREDT_HPP__
#define __PICTUREDT_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/string.hpp"
#include "aframe:include/datatype.hpp"

//////////////////////////////////////////////////////////////////////////////
// Definitions

typedef struct
{
    struct BitMapHeader bmhd;   // format and infos
    struct BitMap *bmap;        // bitmap
    ULONG *cregs;               // color table in LoadRGB32() format
    ULONG numcolors;            // number of colors
    ULONG display_ID;           // video mode
    AFString author;            // author info
    AFString copyright;         // copyright info
    AFString annotation;        // other info
    struct FrameInfo    fri;    // Environment info on the object
    struct dtFrameBox   dtf;    // framebox struct
    LPImage             image;  // image struct
} PICTUREDT;

//////////////////////////////////////////////////////////////////////////////
// PictureDT Class

class AFPictureDT : public AFDataType
{
public:

    AFPictureDT();
    ~AFPictureDT();

    virtual char *ObjectType() { return "PictureDT"; };

    BOOL LoadPicture(char *file_name);
    BOOL LoadCMap(struct Screen*);

    PICTUREDT m_dtPicture;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __PICTUREDT_HPP__
