#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <intuition/intuition.h>
#include <intuition/imageclass.h>
#include <proto/intuition.h>
#include <proto/exec.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

extern struct ExecBase *SysBase;

#include "SMbarpr.h"

#define CHAR_ROW_OFFSET 10
#define CHAR_WIDTH       8

/****************************** VertScrollBar *******************************
*                                                                           *
*    VertScrollBar - Put A Scroll Bar On Right Window Edge                  *
*                                                                           *
*         *window     - pointer to window structure                         *
*         *gadget     - pointer to proportional gadget structure            *
*         *propinfo   - pointer to info structure for the proport. gadget   *
*         *image      - pointer to proportional gadget image                *
*          gadgetID   - ID number for proportional gadget                   *
*         *TAgadget   - pointer to top arrow gadget structure               *
*         *TAimage    - pointer to top arrow image structure                *
*          TAgadgetID - ID number for top arrow gadget                      *
*         *BAgadget   - pointer to bottom arrow gadget structure            *
*         *BAimage    - pointer to bottom arrow image structure             *
*          BAgadgetID - ID number for bottom arrow gadget                   *
*                                                                           *
****************************************************************************/
static const USHORT __chip _FRSTopShiftData[] =
  {0x8008,0x8208,0x8708,0x8F88,0x9FC8,0x8708,0x8708,0x8708,0x8708,0x8008};

static const USHORT __chip _FRSBottomShiftData[] =
  {0x8008,0x8708,0x8708,0x8708,0x8708,0x9FC8,0x8F88,0x8708,0x8208,0x8008};

static const struct PropInfo pi =
{
   AUTOKNOB | FREEVERT | PROPNEWLOOK,   /* Flags */
   0, 0,            /* HorizPot, VertPot     */
   0x2000, VBMAXPOS,/* HorizBody, VertBody   */
   0, 0,            /* CWidth, CHeight       */
   0, 0,            /* HPotRes, VPotRes      */
   0, 0             /* LeftBorder, TopBorder */
};

static const struct Gadget gi =
{
   NULL,                        /* NextGadget */
   -15, CHAR_ROW_OFFSET,        /* LeftEdge, TopEdge */
   CHAR_WIDTH + CHAR_WIDTH - 1, /* Width */
   -CHAR_ROW_OFFSET-32,         /* Height */
   GADGIMAGE  | 
   GADGHNONE  | 
   GRELRIGHT  | 
   GRELHEIGHT | 
   RIGHTBORDER,                 /* Flags */
   GADGIMMEDIATE | 
   FOLLOWMOUSE   |
   RELVERIFY     | 
   RIGHTBORDER,                 /* Activation */
   PROPGADGET,                  /* GadgetType */
   NULL,                        /* GadgetRender (set later) */
   NULL,                        /* SelectRender */
   NULL,                        /* GadgetText */
   0,                           /* MutualExclude */
   NULL,                        /* SpecialInfo (set later) */
   0,                           /* GadgetID (set later) */
   NULL                         /* UserData (set later) */
};

static const struct Gadget ti =
{
   NULL,                        /* NextGadget */
   -17, -31,                    /* LeftEdge, TopEdge */
   CHAR_WIDTH + CHAR_WIDTH + 1, /* Width */
   10,                          /* Height */
   GADGIMAGE  | 
   GRELRIGHT  | 
   GRELBOTTOM,                  /* Flags */
   GADGIMMEDIATE | 
   RELVERIFY,                   /* Activation */
   BOOLGADGET,                  /* GadgetType */
   NULL,                        /* GadgetRender (set later) */
   NULL,                        /* SelectRender */
   NULL,                        /* GadgetText */
   0,                           /* MutualExclude */
   NULL,                        /* SpecialInfo (set later) */
   0,                           /* GadgetID (set later) */
   NULL                         /* UserData (set later) */
};

static const struct Image tiim =
{
   0,    /* LeftEdge */
   0,    /* TopEdge  */
   10,   /* Width */
   10,   /* Height */
   1,    /* Depth */
   NULL, /* ImageData */
   1,    /* PlanePick */
   0,    /* PlaneOnOff */
   NULL  /* NextImage */
};

static struct Image * getimage(int type, struct Window *w)
{
    struct DrawInfo *drinfo;
    struct Image *image;

    if (SysBase->LibNode.lib_Version >= 36) 
    {
       drinfo = GetScreenDrawInfo( w->WScreen );

       image = (struct Image *) NewObject( NULL, "sysiclass",
        SYSIA_Size,     0,              /* normal "medium-res" for now */
        SYSIA_DrawInfo, drinfo,
        SYSIA_Which,    type,
        TAG_END );
        
        return image;
     }
     return NULL;
}

struct VBar *VBInit(struct Window *window)
{
   struct VBar *vb;

   if(!(vb = (struct VBar *)AllocMem(sizeof(struct VBar), MEMF_CLEAR)))
      return(NULL);

   memcpy(&vb->propinfo, &pi, sizeof(pi));
   memcpy(&vb->g.gadget, &gi, sizeof(gi));

   vb->g.gadget.GadgetRender = (APTR)&vb->g.image;
   vb->g.gadget.SpecialInfo = (APTR)&vb->propinfo;
   vb->g.gadget.GadgetID = vb->g.gadgetID = VB_SLIDER;

   if(SysBase->LibNode.lib_Version < 36) 
   {
      vb->g.gadget.LeftEdge = -(CHAR_WIDTH + CHAR_WIDTH - 1);
      vb->g.gadget.TopEdge = CHAR_ROW_OFFSET+10;
      vb->g.gadget.Height = -CHAR_ROW_OFFSET - 30;
   }
   else
   {
      if(SysBase->LibNode.lib_Version >= 39)
         vb->propinfo.Flags |= PROPBORDERLESS;
      vb->g.gadget.TopEdge  =  window->BorderTop+1;
      vb->g.gadget.Height   =  -window->BorderTop - 1 - 32;
      if(window->BorderRight > 8)
      {
         vb->g.gadget.LeftEdge = -(window->BorderRight-5);
         vb->g.gadget.Width    =  window->BorderRight-8;
      }
      else
      {
         vb->g.gadget.LeftEdge = -8;
         vb->g.gadget.Width    =  6;
      }
   }

   AddGadget(window,&vb->g.gadget,-1);

   memcpy(&vb->ta.gadget, &ti, sizeof(ti));

   if ((vb->ta.gadget.GadgetRender = 
            (APTR)getimage(UPIMAGE, window)) == NULL) 
   {
      memcpy(&vb->ta.image, &tiim, sizeof(tiim));
      vb->ta.image.ImageData = (USHORT *)&_FRSTopShiftData;
      vb->ta.gadget.GadgetRender = (APTR)&vb->ta.image; 
      vb->ta.gadget.LeftEdge = -(CHAR_WIDTH + CHAR_WIDTH - 1);
      vb->ta.gadget.TopEdge = CHAR_ROW_OFFSET;
      vb->ta.gadget.Flags = GADGIMAGE | GRELRIGHT;
      vb->ta.freeimage = 0;
   } 
   else
   {
      vb->ta.gadget.Flags |= GADGHIMAGE;
      vb->ta.gadget.SelectRender = 
          (APTR)getimage(UPIMAGE, window);
      vb->ta.freeimage = 1;
   }  

   vb->ta.gadget.GadgetID = VB_UP;
   AddGadget(window,&vb->ta.gadget,-1);

   memcpy(&vb->ba.gadget, &ti, sizeof(ti));
   vb->ba.gadget.TopEdge = -20;
   vb->ba.gadget.Height = 11;

   if ((vb->ba.gadget.GadgetRender = 
          (APTR)getimage(DOWNIMAGE, window)) == NULL)
   {
      memcpy(&vb->ba.image, &tiim, sizeof(tiim));
      vb->ba.image.ImageData = (USHORT *)&_FRSBottomShiftData;
      vb->ba.gadget.GadgetRender = (APTR)&vb->ba.image; 
      vb->ba.gadget.LeftEdge = -(CHAR_WIDTH + CHAR_WIDTH - 1);
      vb->ba.gadget.TopEdge = -19;
      vb->ba.freeimage = 0;
   }
   else
   {
      vb->ba.gadget.Flags |= GADGHIMAGE;
      vb->ba.gadget.SelectRender = 
          (APTR)getimage(DOWNIMAGE, window);
      vb->ba.freeimage = 1;
   }  

   vb->ba.gadget.GadgetID = VB_DOWN;

   AddGadget(window,&vb->ba.gadget,-1);
 
   RefreshGadgets(&vb->g.gadget,window,NULL);

   vb->window = window;

   return(vb);
}

/**************************** ReadVertScrollBar *****************************
*                                                                           *
*    ReadVertScrollBar - Get Position of Vertical Scroll Bar                *
*                                                                           *
*         *gadget  - pointer to proportional gadget structure               *
*                                                                           *
*         (result) - position of knob in the gadget container               *
*                                                                           *
****************************************************************************/
int VBRead(struct VBar *vb)
{
   return(vb ? vb->propinfo.VertPot : 0);
}

/********************************* UpVertSB *********************************
*                                                                           *
*    UpVertSB - Update Vertical Scroll Bar                                  *
*                                                                           *
*         *window       - pointer to window structure                       *
*         *gadget       - pointer to proportional gadget structure          *
*          KnobSize     - ratio of knob width to container width            *
*          KnobPosition - position of knob in container                     *
*                                                                           *
****************************************************************************/
int VBUpdate(struct VBar *vb, int KnobSize, int KnobPosition)
{
   int dorefresh = 0;

   assert(KnobSize <= VBMAXPOS);
   assert(KnobSize >= 0);
   assert(KnobPosition <= VBMAXPOS);
   assert(KnobPosition >= 0);

   if(vb)
   {
      if (KnobSize >=0 && KnobSize<=VBMAXPOS && 
          vb->propinfo.VertBody != KnobSize)
      {
         vb->propinfo.VertBody = KnobSize;
         dorefresh = 1;
      }

      if (KnobPosition>=0 && KnobPosition<=VBMAXPOS && 
          vb->propinfo.VertPot != KnobPosition)
      {
         vb->propinfo.VertPot = KnobPosition;
         dorefresh = 1;
      }

      if(vb->window && dorefresh)
         RefreshGadgets(&vb->g.gadget,vb->window,NULL);
   }
   return(0);
}

void VBTerm(struct VBar *vb)
{
   if(vb)
   {
      if(vb->window)
      {
         RemoveGadget(vb->window, &vb->g.gadget);
         RemoveGadget(vb->window, &vb->ta.gadget);
         RemoveGadget(vb->window, &vb->ba.gadget);
         vb->window = NULL;
         if(vb->ta.freeimage)
         {
            DisposeObject(vb->ta.gadget.GadgetRender);
            DisposeObject(vb->ta.gadget.SelectRender);
         }
         if(vb->ba.freeimage)
         {
            DisposeObject(vb->ba.gadget.GadgetRender);
            DisposeObject(vb->ba.gadget.SelectRender);
         }
      }
      FreeMem(vb, sizeof(*vb));
   }
}

int VBSelected(struct VBar *vb, int gadnum)
{
   switch(gadnum)
   {
      case VB_SLIDER: return(vb->g.gadget.Flags & SELECTED);
      case VB_UP    : return(vb->ta.gadget.Flags & SELECTED);
      case VB_DOWN  : return(vb->ba.gadget.Flags & SELECTED);
   }
   return(0);
}

