/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AImage wrapper class                                                      *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_Image_H
#define ASAP_Image_H

extern "C"
{
 #include <Proto/Intuition.H>
}

class AImage : public Image
{
 public:
 inline BOOL PointInImage(unsigned long point);
};
//-----------------------------------------------------------------------------
BOOL AImage::PointInImage (unsigned long point)
{
 return ::PointInImage(point, this);
}

#endif