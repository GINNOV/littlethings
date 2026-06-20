/*
**      $VER: libfuncs.c 43.20 (4.9.98)
**
**      datatype functions
**
**      (C) Copyright 1996-98 Andreas R. Kleinert
**      All Rights Reserved.
*/


#define V43_DT                /* yes, we make use of the new V43 API here */

#define __USE_SYSBASE

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */

#ifndef EXEC_MEMORY_H
#include <exec/memory.h>
#endif /* EXEC_MEMORY_H */

#ifndef GRAPHICS_GFXBASE_H
#include <graphics/gfxbase.h>
#endif /* GRAPHICS_GFXBASE_H */

#ifndef GRAPHICS_VIEW_H
#include <graphics/view.h>
#endif /* GRAPHICS_VIEW_H */

#include <intuition/icclass.h>
#include <datatypes/pictureclass.h>

#ifdef V43_DT
#include <cybergraphics/cybergraphics.h>  /* CyberGraphX */
#endif /* V43_DT */

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/datatypes.h>

#include <clib/alib_protos.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <class/classbase.h>
#include "libfuncs.h"


#define LibVer(x) ( ((struct Library *) x)->lib_Version )


Class * __saveds __asm ObtainPicClass ( register __a6 struct ClassBase *cb)
{
 return (cb->cb_Class);
}

ULONG setdtattrs (struct ClassBase * cb, Object * o, ULONG data,...)
{
 return (SetDTAttrsA (o, NULL, NULL, (struct TagItem *) & data));
}

ULONG getdtattrs (struct ClassBase * cb, Object * o, ULONG data,...)
{
 return (GetDTAttrsA (o, (struct TagItem *) & data));
}

extern char __aligned ExLibName [];

Class *initClass (struct ClassBase * cb)
{
 Class *cl;

 if (cl = MakeClass (&ExLibName[0], PICTUREDTCLASS, NULL, NULL, 0L))
  {
   cl->cl_Dispatcher.h_Entry = (HOOKFUNC) Dispatch;
   cl->cl_UserData = (ULONG) cb;
   AddClass (cl);
  }

 return (cl);
}

ULONG __saveds __asm Dispatch ( register __a0 Class * cl, register __a2 Object * o, register __a1 Msg msg)
{
 struct ClassBase *cb = (struct ClassBase *) cl->cl_UserData;
 ULONG retval = NULL;

 switch (msg->MethodID)
  {
   case OM_NEW:
    {
     if (retval = DoSuperMethodA (cl, o, msg))
      {
       if (!GetGfxData(cb, cl, (Object *) retval, ((struct opSet *) msg)->ops_AttrList))
        {
         CoerceMethod (cl, (Object *) retval, OM_DISPOSE);
         return NULL;
        }
      }
     break;
    }
   default:
    {
     retval = (ULONG) DoSuperMethodA (cl, o, msg);
     break;
    }
  }

 return(retval);
}

ULONG __saveds __stdargs DTS_ReadIntoBitMap(struct ClassBase *cb, Object * o, Class *cl, struct TagItem * attrs);
ULONG __saveds __stdargs DTS_ReadIntoBitMap43(struct ClassBase *cb, Object * o, Class *cl, struct TagItem * attrs);

ULONG __saveds __asm GetGfxData ( register __a6 struct ClassBase * cb, register __a0 Class * cl, register __a2 Object * o, register __a1 struct TagItem * attrs)
{
 ULONG retval;
 extern struct Library *SuperClassBase;

#ifdef V43_DT

 if(LibVer(SuperClassBase) > 42) retval = DTS_ReadIntoBitMap43(cb, o, cl, attrs);
  else                           retval = DTS_ReadIntoBitMap(  cb, o, cl, attrs);

#else

 retval = DTS_ReadIntoBitMap(  cb, o, cl, attrs);

#endif /* V43_DT */

 return(retval);
}

ULONG __saveds __stdargs DTS_GetBestModeID(ULONG width, ULONG height, ULONG depth);
ULONG __saveds __stdargs DTS_SkipComment(BPTR handle, UBYTE *buf);

ULONG __saveds __stdargs DTS_ReadIntoBitMap(struct ClassBase *cb, Object * o, Class *cl, struct TagItem * attrs)
{
 struct BitMapHeader *bmhd;

 BOOL success = TRUE;

 struct RastPort __aligned trp;
 struct RastPort __aligned rp;

 struct BitMap *bm, *tbm;

 ULONG i, width, height, depth, maxval;

 UBYTE *readname, *buffer, *id;

 struct ColorRegister *cmap;
 LONG *cregs;

 BPTR fh;

 UBYTE wstr[16], hstr[16], dstr[16];
 UWORD ID = (UWORD) 0;
 ULONG source_type;


 /* we can't handle clipboard, ram or other access modes */

 source_type = (ULONG) GetTagData (DTA_SourceType, DTST_FILE, attrs);
 if(source_type != DTST_FILE)
  {
   SetIoErr(ERROR_OBJECT_WRONG_TYPE);
   return(FALSE);
  }

 readname = (UBYTE *) GetTagData (DTA_Name, NULL, attrs);
 getdtattrs (cb, o, PDTA_BitMapHeader, &bmhd, TAG_DONE, NULL);


 fh = Open(readname, MODE_OLDFILE);
 if(!fh)
  {
   SetIoErr(ERROR_OBJECT_NOT_FOUND);
   return(FALSE);
  }

 FRead(fh, &ID, 2, 1);
 FRead(fh, &wstr[0], 1, 1); /* filter CR */

 id = (UBYTE *) &ID;
 if(id[1] != '5')
  {
   SetIoErr(ERROR_OBJECT_WRONG_TYPE);
   Close(fh);
   return(FALSE);
  }


 /* get Width */

 for(i=0; i<16; i++)
  {
   if(!FRead(fh, &wstr[i], 1, 1))
    {
     Close(fh);
     return(FALSE);
    }

   if(  wstr[i]=='#') i = DTS_SkipComment(fh, wstr);
   if( (wstr[i]==' ') || (wstr[i]==0xa) || (wstr[i]==13) )
    {
     wstr[i] = (UBYTE) '\0';
     break;
    }
  }

 /* get Height */

 for(i=0; i<16; i++)
  {
   if(!FRead(fh, &hstr[i], 1, 1))
    {
     Close(fh);
     return(FALSE);
    }

   if(  hstr[i]=='#') i = DTS_SkipComment(fh, hstr);
   if( (hstr[i]==' ') || (hstr[i]==0xa) || (hstr[i]==13) )
    {
     hstr[i] = (UBYTE) '\0';
     break;
    }
  }

 /* Maxval */

 for(i=0; i<16; i++)
  {
   if(!FRead(fh, &dstr[i], 1, 1))
    {
     Close(fh);
     return(FALSE);
    }

   if(  dstr[i]=='#') i = DTS_SkipComment(fh, dstr);
   if( (dstr[i]==' ') || (dstr[i]==0xa) || (dstr[i]==13) )
    {
     dstr[i] = (UBYTE) '\0';
     break;
    }
  }

 width  = (ULONG) atol(wstr);
 height = (ULONG) atol(hstr);
 maxval = (ULONG) atol(dstr);
 if(maxval > 255)
  {
   Close(fh);
   return(FALSE);
  }

 bmhd->bmh_Width  = (bmhd->bmh_PageWidth  = width);
 bmhd->bmh_Height = (bmhd->bmh_PageHeight = height);
 depth            = (bmhd->bmh_Depth = 8);

 setdtattrs(cb, o, PDTA_NumColors,      256,
                   TAG_DONE,            NULL);

 getdtattrs(cb, o, PDTA_ColorRegisters, (ULONG) &cmap,
                   PDTA_CRegs,          &cregs,
                   TAG_DONE,            NULL);

 if( (!cmap) || (!cregs) )
  {
   success = FALSE;
  }else
  {
   if(tbm = AllocBitMap (bmhd->bmh_Width, 1, bmhd->bmh_Depth, BMF_CLEAR, NULL))
    {
     InitRastPort (&trp);
     trp.BitMap = tbm;

     if (bm = AllocBitMap (bmhd->bmh_Width, bmhd->bmh_Height, bmhd->bmh_Depth, BMF_CLEAR, NULL))
      {
       InitRastPort (&rp);
       rp.BitMap = bm;

       buffer = (APTR) AllocVec(width + 1024, MEMF_CLEAR|MEMF_PUBLIC);
       if(buffer)
        {
         for(i=0; i<height; i++)
          {
           FRead(fh, buffer, width, 1);

           WritePixelLine8(&rp, 0, i, width, buffer, &trp);
          }

         for(i=0; i<maxval; i++)
          {
           cmap->red   = i * (256 / maxval);
           cmap->green = i * (256 / maxval);
           cmap->blue  = i * (256 / maxval);
           cmap++;

           cregs[i * 3    ] = ((LONG)i * (256 / maxval))<<24;
           cregs[i * 3 + 1] = ((LONG)i * (256 / maxval))<<24;
           cregs[i * 3 + 2] = ((LONG)i * (256 / maxval))<<24;
          }

         cmap->red   = 255;
         cmap->green = 255;
         cmap->blue  = 255;
         cmap++;

         cregs[i * 3    ] = ((LONG)255)<<24;
         cregs[i * 3 + 1] = ((LONG)255)<<24;
         cregs[i * 3 + 2] = ((LONG)255)<<24;

         setdtattrs (cb, o,
                     DTA_ObjName,       readname,
                     DTA_NominalHoriz,  bmhd->bmh_Width,
                     DTA_NominalVert,   bmhd->bmh_Height,
                     PDTA_BitMap,       bm,
                     PDTA_ModeID,       DTS_GetBestModeID(bmhd->bmh_Width, bmhd->bmh_Height, 8),
                     TAG_DONE);

         FreeVec(buffer);
        }else
        {
         WaitBlit(); // not really required prior WritePixelLine() took place
         FreeBitMap(bm);

         success = FALSE;
         SetIoErr (ERROR_NO_FREE_STORE);
        }

      }else
      {
       success = FALSE;
       SetIoErr (ERROR_NO_FREE_STORE);
      }

     WaitBlit(); // required
     FreeBitMap(tbm);
    }else
    {
     success = FALSE;
     SetIoErr (ERROR_NO_FREE_STORE);
    }
  }

 Close(fh);

 return(success);
}

#ifdef V43_DT

ULONG __saveds __stdargs DTS_ReadIntoBitMap43(struct ClassBase *cb, Object * o, Class *cl, struct TagItem * attrs)
{
 struct BitMapHeader *bmhd;

 BOOL success = TRUE;

 ULONG i, width, height, depth, maxval;

 UBYTE *readname, *buffer;

 BPTR fh;

 UBYTE wstr[16], hstr[16], dstr[16], *id;
 UWORD ID;
 ULONG source_type;


 /* we can't handle clipboard, ram or other access modes */

 source_type = (ULONG) GetTagData (DTA_SourceType, DTST_FILE, attrs);
 if(source_type != DTST_FILE)
  {
   SetIoErr(ERROR_OBJECT_WRONG_TYPE);
   return(FALSE);
  }

 readname = (UBYTE *) GetTagData (DTA_Name, NULL, attrs);
 getdtattrs (cb, o, PDTA_BitMapHeader, &bmhd, TAG_DONE, NULL);


 fh = Open(readname, MODE_OLDFILE);
 if(!fh)
  {
   SetIoErr(ERROR_OBJECT_NOT_FOUND);
   return(FALSE);
  }

 FRead(fh, &ID, 2, 1);
 FRead(fh, &wstr[0], 1, 1); /* filter CR */


 id = (UBYTE *) &ID;
 if(id[1] == '5')
  {
   /* for P5 with 256 grayscales, the V40 code does suffice */

   Close(fh);
   return( DTS_ReadIntoBitMap(cb, o, cl, attrs) );
  }

 /* get Width */

 for(i=0; i<16; i++)
  {
   if(!FRead(fh, &wstr[i], 1, 1))
    {
     Close(fh);
     return(FALSE);
    }

   if(  wstr[i]=='#') i = DTS_SkipComment(fh, wstr);
   if( (wstr[i]==' ') || (wstr[i]==0xa) || (wstr[i]==13) )
    {
     wstr[i] = (UBYTE) '\0';
     break;
    }
  }

 /* get Height */

 for(i=0; i<16; i++)
  {
   if(!FRead(fh, &hstr[i], 1, 1))
    {
     Close(fh);
     return(FALSE);
    }

   if(  hstr[i]=='#') i = DTS_SkipComment(fh, hstr);
   if( (hstr[i]==' ') || (hstr[i]==0xa) || (hstr[i]==13) )
    {
     hstr[i] = (UBYTE) '\0';
     break;
    }
  }

 /* Maxval */

 for(i=0; i<16; i++)
  {
   if(!FRead(fh, &dstr[i], 1, 1))
    {
     Close(fh);
     return(FALSE);
    }

   if(  dstr[i]=='#') i = DTS_SkipComment(fh, dstr);
   if( (dstr[i]==' ') || (dstr[i]==0xa) || (dstr[i]==13) )
    {
     dstr[i] = (UBYTE) '\0';
     break;
    }
  }

 width  = (ULONG) atol(wstr);
 height = (ULONG) atol(hstr);
 maxval = (ULONG) atol(dstr);
 if(maxval > 255)
  {
   Close(fh);
   return(FALSE);
  }

 bmhd->bmh_Width  = (bmhd->bmh_PageWidth  = width);
 bmhd->bmh_Height = (bmhd->bmh_PageHeight = height);
 depth            = (bmhd->bmh_Depth = 24);

 setdtattrs(cb, o,
            DTA_ObjName,      readname,
            DTA_NominalHoriz, bmhd->bmh_Width,
            DTA_NominalVert,  bmhd->bmh_Height,
            PDTA_SourceMode,  PMODE_V43,
            PDTA_ModeID,      DTS_GetBestModeID(bmhd->bmh_Width, bmhd->bmh_Height, 8),
            TAG_DONE);


 buffer = (APTR) AllocVec(width*3 + 1024, MEMF_CLEAR|MEMF_PUBLIC);
 if(buffer)
  {
   ULONG i;

   for(i=0; i<height; i++)
    {
     FRead(fh, buffer, width*3, 1);
     DoSuperMethod(cl, o, PDTM_WRITEPIXELARRAY, buffer, RECTFMT_RGB, width*3, 0, i, width, 1);
    }

   FreeVec(buffer);
  }else
  {
   success = FALSE;
   SetIoErr (ERROR_NO_FREE_STORE);
  }

 Close(fh);

 return(success);
}

#endif /* V43_DT */

ULONG __saveds __stdargs DTS_GetBestModeID(ULONG width, ULONG height, ULONG depth)
{
 ULONG mode_id = NULL;

 mode_id = BestModeID(BIDTAG_NominalWidth,  width,
                      BIDTAG_NominalHeight, height,
                      BIDTAG_DesiredWidth,  width,
                      BIDTAG_DesiredHeight, height,
                      BIDTAG_Depth,         depth,
                      TAG_END);

 if(mode_id == INVALID_ID)
  {
   /* Uses OverScan values for checking. */
   /* Assumes an ECS-System.             */

        if((width > 724) && (depth < 3)) mode_id = SUPER_KEY;
   else if((width > 362) && (depth < 5)) mode_id = HIRES_KEY;
   else                                  mode_id = LORES_KEY;

   if(!ModeNotAvailable(mode_id | PAL_MONITOR_ID))    /* for PAL  Systems */
    {
     if(height > 283) mode_id |= LACE;

     mode_id |= PAL_MONITOR_ID;
    }else
    {
     if(!ModeNotAvailable(mode_id | NTSC_MONITOR_ID)) /* for NTSC Systems */
      {
       if(height > 241) mode_id |= LACE;

       mode_id |= NTSC_MONITOR_ID;
      }
    }
  }

 return(mode_id);
}

ULONG __saveds __stdargs DTS_SkipComment(BPTR handle, UBYTE *buf)
{
 do
  {
   FRead(handle, buf, 1, 1);
  } while( (*buf!=0xa) && (*buf!=13) );

 FRead(handle, buf, 1, 1);

 return(0L);
}
