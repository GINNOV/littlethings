/**************************************************************************/
/*                             gui.c                                      */
/**************************************************************************/
/* Misc routines to manage intuition objects                              */
/* GP 2009                                                                */
/**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/gfxmacros.h>
#include <intuition/intuition.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include "gui.h"

/* NextTagItem, from utility.library compatible with all systems */
struct TagItem *MyNextTagItem(struct TagItem **tagListPtr)
{
  struct TagItem *ti = NULL ;

  if (tagListPtr != NULL)
  {
    if (*tagListPtr != NULL)
    {
      int loop = TRUE ;
      while (loop)
      {
        switch ((*tagListPtr)->ti_Tag)
        {
	    case TAG_END :
          {
            /* Terminate array of TagItems */
            (*tagListPtr) = NULL ;
            loop = FALSE ;
            ti = NULL ;
            break ;
          }

          case TAG_IGNORE:
          {
            /* Ignore this item, not end of array */
            (*tagListPtr) ++;
            break ;
          }

          case TAG_MORE:
          {
            /* ti_Data is pointer to another array of TagItems */
            *tagListPtr = (struct TagItem *)(*tagListPtr)->ti_Data ;
            if (tagListPtr == NULL)
            {
              loop = FALSE ;
              ti = NULL ;
            }
            break ;
          }

          case TAG_SKIP:
          {
            /* skip this and the next ti_Data items */
            (*tagListPtr) += (*tagListPtr)->ti_Data + 1 ;
	      break ;
          }

          default:
          {
            loop = FALSE ;
	      ti = (struct TagItem *)(*tagListPtr)++ ;
            break ;
          }
        }
      }
    }
  }
  return ti ;
}

struct Window *wopen(Tag tags, ...)
{
  struct TagItem pretags[] = { {WA_Left, 20},
                               {WA_Top, 0},
                               {WA_Width, 300},
                               {WA_Height, 60},
                               {WA_MinWidth, 80},
                               {WA_MinHeight, 20},
                               {WA_MaxWidth, -1},
                               {WA_MaxHeight, -1},
                               {WA_CloseGadget, -1},
                               {WA_SizeGadget, -1},
                               {WA_DragBar, -1},
                               {WA_Activate, -1},
                               {WA_NoCareRefresh, 0},
                               {WA_IDCMP, IDCMP_CLOSEWINDOW|
                                          IDCMP_NEWSIZE|
                                          IDCMP_ACTIVEWINDOW|
                                          IDCMP_MOUSEMOVE|
                                          IDCMP_MOUSEBUTTONS|
                                          IDCMP_REFRESHWINDOW|
                                          IDCMP_MENUPICK|
                                          IDCMP_RAWKEY},
                               {WA_Flags, WFLG_CLOSEGADGET|
                                          WFLG_SIZEGADGET|
                                          WFLG_DRAGBAR|
                                          WFLG_DEPTHGADGET|
                                          WFLG_NEWLOOKMENUS},
                               {TAG_END, TAG_END},
                               {TAG_END, TAG_END}} ;

  struct Window *w = NULL ;

  if (tags != NULL)
  {
    pretags[15].ti_Tag = TAG_MORE; pretags[15].ti_Data = (ULONG)&tags ;
  }

  if (0 && ((struct Library *)IntuitionBase)->lib_Version >= 36)
  {
    w = OpenWindowTagList(NULL, pretags) ;
  }
  else
  {
    struct NewWindow nw ;
    struct TagItem *ti ;
    struct TagItem *tstate = pretags ;

    memset(&nw, 0, sizeof(nw)) ;

    if (((struct Library *)IntuitionBase)->lib_Version < 36)
    {
      nw.DetailPen = 0 ;
      nw.BlockPen  = 1 ;
    }
    else
    {
      nw.DetailPen = 1 ;
      nw.BlockPen  = 2 ;
    }
    nw.Type       = WBENCHSCREEN ;
    nw.Flags      = 0 ;
    nw.IDCMPFlags = 0 ;
    do
    {
      ti = MyNextTagItem(&tstate) ;
      if (ti != NULL)
      {
        switch (ti->ti_Tag)
        {
          case WA_Left :
          {
            nw.LeftEdge   = ti->ti_Data ;
            break ;
          }

          case WA_Top :
          {
            nw.TopEdge    = ti->ti_Data ;
            break ;
          }

          case WA_Width :
          {
            nw.Width      = ti->ti_Data ;
            break ;
          }

          case WA_Height :
          {
            nw.Height     = ti->ti_Data ;
            break ;
          }

          case WA_IDCMP :
          {
            nw.IDCMPFlags |= ti->ti_Data ;
            break ;
          }

          case WA_Flags :
          {
            nw.Flags      |= ti->ti_Data ;
            break ;
          }

          case WA_Title :
          {
            nw.Title = (UBYTE *)ti->ti_Data ;
            break ;
          }

          case WA_MinWidth :
          {
            nw.MinWidth = ti->ti_Data ;
            break ;
          }

          case WA_MinHeight :
          {
            nw.MinHeight = ti->ti_Data ;
            break ;
          }

          case WA_MaxWidth :
          {
            if (ti->ti_Data == -1)
            {
              if (((struct Library *)IntuitionBase)->lib_Version >= 33)
              {
                nw.MaxWidth = ti->ti_Data ;
              }
              else
              {
                nw.MaxWidth = 640 ;
              }
            }
            else
            {
              nw.MaxWidth = ti->ti_Data ;
            }
          }

          case WA_MaxHeight :
          {
            if (ti->ti_Data == -1)
            {
              if (((struct Library *)IntuitionBase)->lib_Version >= 33)
              {
                nw.MaxHeight = ti->ti_Data ;
              }
              else
              {
                nw.MaxHeight = 200 ;
              }
            }
            else
            {
              nw.MaxHeight = ti->ti_Data ;
            }
            break ;
          }

          case WA_CloseGadget :
          {
            if (ti->ti_Data)
            {
              nw.Flags |= WFLG_CLOSEGADGET ;
            }
            else
            {
              nw.Flags &= ~WFLG_CLOSEGADGET ;
            }
            break ;
          }
          
          case WA_SizeGadget :
          {
            if (ti->ti_Data)
            {
              nw.Flags |= WFLG_SIZEGADGET ;
            }
            else
            {
              nw.Flags &= ~WFLG_SIZEGADGET ;
            }
            break ;
          }

          case WA_DragBar :
          {
            if (ti->ti_Data)
            {
              nw.Flags |= WFLG_DRAGBAR ;
            }
            else
            {
              nw.Flags &= ~WFLG_DRAGBAR ;
            }
            break ;
          }

          case WA_Activate :
          {
            if (ti->ti_Data)
            {
              nw.Flags |= WFLG_ACTIVATE ;
            }
            else
            {
              nw.Flags &= ~WFLG_ACTIVATE ;
            }
            break ;
          }

          case WA_NoCareRefresh :
          {
            if (ti->ti_Data)
            {
              nw.Flags |= WFLG_NOCAREREFRESH ;
            }
            else
            {
              nw.Flags &= ~WFLG_NOCAREREFRESH ;
            }
            break ;
          }
        }
      }
    } while (ti != NULL) ;

    w = OpenWindow(&nw) ;
  }

  return w ;
}

void wclose(struct Window *w)
{
  CloseWindow(w) ;
}


void wsetpencils(UWORD *pencils)
{
  /* get gui pencils */
  BOOL penok = FALSE ;
  if (((struct Library *)IntuitionBase)->lib_Version >= 36)
  {
    struct Screen *s = LockPubScreen(NULL) ;
    if (s != NULL)
    {
      struct DrawInfo *drinfo = GetScreenDrawInfo(s) ;    
      if (drinfo != NULL)
      {
        int i ;
        for (i=0; i<drinfo->dri_NumPens; i++)
        {
          if (i < 15)
          {
            pencils[i] = drinfo->dri_Pens[i] ;
          }
        }
        penok = TRUE ;
        FreeScreenDrawInfo(s, drinfo) ;
      }
      UnlockPubScreen(NULL, s) ;
    }
  }

  if (!penok)
  {
    if (((struct Library *)IntuitionBase)->lib_Version < 36)
    {
      /* 0 blue   */
      /* 1 white  */
      /* 2 black  */
      /* 3 orange */
      pencils[DETAILPEN]        = 2 ; /**/
      pencils[BLOCKPEN]         = 1 ;
      pencils[TEXTPEN]          = 2 ;
      pencils[SHINEPEN]         = 1 ;
      pencils[SHADOWPEN]        = 2 ;
      pencils[FILLPEN]          = 3 ;
      pencils[FILLTEXTPEN]      = 2 ;
      pencils[BACKGROUNDPEN]    = 0 ;
      pencils[HIGHLIGHTTEXTPEN] = 3 ;
    }
    else
    {
      /* 0 grey   */
      /* 1 black  */
      /* 2 white  */
      /* 3 blue   */
      pencils[DETAILPEN]        = 1 ; /**/
      pencils[BLOCKPEN]         = 2 ;
      pencils[TEXTPEN]          = 1 ;
      pencils[SHINEPEN]         = 2 ;
      pencils[SHADOWPEN]        = 1 ;
      pencils[FILLPEN]          = 3 ;
      pencils[FILLTEXTPEN]      = 1 ;
      pencils[BACKGROUNDPEN]    = 0 ;
      pencils[HIGHLIGHTTEXTPEN] = 3 ;
      //if (0)
      //{
      //  pencils[BARDETAILPEN]     = 0 ;
      //  pencils[BARBLOCKPEN]      = 0 ;
      //  pencils[BARTRIMPEN]       = 0 ;
      //}
    }
  }
}

void Button_SetImage
( struct Gadget *G,
  struct Image *R1, struct Image *R2, struct Image *R3,
  struct Image *S1, struct Image *S2, struct Image *S3,
  UWORD *pencils
)
{ 
  WORD w,h;

  G->Flags |= GFLG_GADGIMAGE|GFLG_GADGHIMAGE;
    
  w=G->Width;
  h=G->Height;
   
  R3->LeftEdge=1;
  R3->TopEdge=1;
  R3->Width=w-1;
  R3->Height=h-1;
  R3->Depth=0;
  R3->ImageData=NULL;
  R3->PlanePick=0x00;
  R3->PlaneOnOff=pencils[BACKGROUNDPEN];
  R3->NextImage=NULL;
  
  R2->LeftEdge=0;
  R2->TopEdge=0;
  R2->Width=w;
  R2->Height=h;
  R2->Depth=0;
  R2->ImageData=NULL;
  R2->PlanePick=0x00;
  R2->PlaneOnOff=pencils[SHINEPEN];
  R2->NextImage=R3;
  
  R1->LeftEdge=1;
  R1->TopEdge=1;
  R1->Width=w;
  R1->Height=h;
  R1->Depth=0;
  R1->ImageData=NULL;
  R1->PlanePick=0x00;
  R1->PlaneOnOff=pencils[SHADOWPEN];
  R1->NextImage=R2;
  
  S3->LeftEdge=1;
  S3->TopEdge=1;
  S3->Width=w-1;
  S3->Height=h-1;
  S3->Depth=0;
  S3->ImageData=NULL;
  S3->PlanePick=0x00;
  S3->PlaneOnOff=pencils[FILLPEN];
  S3->NextImage=NULL;
  
  S2->LeftEdge=0;
  S2->TopEdge=0;
  S2->Width=w;
  S2->Height=h;
  S2->Depth=0;
  S2->ImageData=NULL;
  S2->PlanePick=0x00;
  S2->PlaneOnOff=pencils[SHADOWPEN];
  S2->NextImage=S3;
  
  S1->LeftEdge=1;
  S1->TopEdge=1;
  S1->Width=w;
  S1->Height=h;
  S1->Depth=0;
  S1->ImageData=NULL;
  S1->PlanePick=0x00;
  S1->PlaneOnOff=pencils[SHINEPEN];
  S1->NextImage=S2;

  G->GadgetRender=R1;
  G->SelectRender=S1;
}

void DrawRect(
struct RastPort *rp,
LONG x0,
LONG y0,
LONG x1,
LONG y1
)
{
  Move(rp, x0, y0) ;
  Draw(rp, x1, y0) ;
  Draw(rp, x1, y1) ;
  Draw(rp, x0, y1) ;
  Draw(rp, x0, y0) ;
} /* DrawRect */

