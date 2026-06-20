/* support: walker */

struct VBGadImage
{
   struct Gadget gadget;
   struct Image  image;
   struct Image  image2;
   SHORT         gadgetID;
   short  freeimage;
};

struct VBar
{
   struct Window *window;
   struct PropInfo propinfo;
   struct VBGadImage g;
   struct VBGadImage ta;
   struct VBGadImage ba;
};

#include "SMbar.h"