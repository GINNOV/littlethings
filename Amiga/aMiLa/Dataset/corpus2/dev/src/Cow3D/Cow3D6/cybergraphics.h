#ifndef CYBERGRAPHICS_CYBERGRAPHICS_H
#define CYBERGRAPHICS_CYBERGRAPHICS_H

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef GRAPHICS_DISPLAYINFO_H
#include <graphics/displayinfo.h>
#endif

/*                                                          */
/*  Definition of CyberModeNode (Returned in AllocModeList) */
/*                                                          */

struct CyberModeNode
 {
  struct Node Node;
  char   ModeText[DISPLAYNAMELEN];
  ULONG  DisplayID;
  USHORT Width;
  USHORT Height;
  USHORT Depth;
  APTR   DisplayTagList;  /* taglist with extended ModeID information */
 };

/*                                  */
/* Parameters for GetCyberMapAttr() */
/*                                  */

#define CYBRMATTR_XMOD        0x80000001 /* function returns BytesPerRow if its called with this parameter */
#define CYBRMATTR_BPPIX       0x80000002 /* BytesPerPixel shall be returned */
#define CYBRMATTR_DISPADR     0x80000003 /* do not use this ! private tag */
#define CYBRMATTR_PIXFMT      0x80000004 /* the pixel format is returned */
#define CYBRMATTR_WIDTH       0x80000005 /* returns width in pixels */
#define CYBRMATTR_HEIGHT      0x80000006 /* returns height in lines */
#define CYBRMATTR_DEPTH       0x80000007 /* returns bits per pixel */
#define CYBRMATTR_ISCYBERGFX  0x80000008 /* returns -1 if supplied bitmap is a cybergfx one */
#define CYBRMATTR_ISLINEARMEM 0x80000009 /* returns -1 if supplied bitmap is linear accessable */

/*                                 */
/* Parameters for GetCyberIDAttr() */
/*                                 */

#define CYBRIDATTR_PIXFMT 0x80000001 /* the pixel format is returned */
#define CYBRIDATTR_WIDTH  0x80000002 /* returns visible width in pixels */
#define CYBRIDATTR_HEIGHT 0x80000003 /* returns visible height in lines */
#define CYBRIDATTR_DEPTH  0x80000004 /* returns bits per pixel */
#define CYBRIDATTR_BPPIX  0x80000005 /* BytesPerPixel shall be returned */

/*                              */
/* Tags for CyberModeRequest()  */
/*                              */

#define CYBRMREQ_TB          (TAG_USER+0x40000)

/*            */
/* FilterTags */
/*            */

#define CYBRMREQ_MinDepth    CYBRMREQ_TB+0  /* Minimum depth for displayed screenmode */
#define CYBRMREQ_MaxDepth    CYBRMREQ_TB+1  /* Maximum depth  "       "        " */
#define CYBRMREQ_MinWidth    CYBRMREQ_TB+2  /* Minumum width  "       "        " */
#define CYBRMREQ_MaxWidth    CYBRMREQ_TB+3  /* Maximum width  "       "        " */
#define CYBRMREQ_MinHeight   CYBRMREQ_TB+4  /* Minumum height "       "        " */
#define CYBRMREQ_MaxHeight   CYBRMREQ_TB+5  /* Minumum height "       "        " */
#define CYBRMREQ_CModelArray CYBRMREQ_TB+6

#define CYBRMREQ_WinTitle    CYBRMREQ_TB+20
#define CYBRMREQ_OKText      CYBRMREQ_TB+21
#define CYBRMREQ_CancelText  CYBRMREQ_TB+22

#define CYBRMREQ_Screen      CYBRMREQ_TB+30  /* Screen you wish the Requester to open on */

/*                            */
/* Tags for BestCyberModeID() */
/*                            */

#define CYBRBIDTG_TB  (TAG_USER+0x50000)

/* FilterTags */

#define CYBRBIDTG_Depth         CYBRBIDTG_TB+0
#define CYBRBIDTG_NominalWidth  CYBRBIDTG_TB+1
#define CYBRBIDTG_NominalHeight CYBRBIDTG_TB+2
#define CYBRBIDTG_MonitorID     CYBRBIDTG_TB+3
#define CYBRBIDTG_BoardName     CYBRBIDTG_TB+5

/*                                    */
/* definition of divers pixel formats */
/*                                    */

#define PIXFMT_LUT8     0
#define PIXFMT_RGB15    1
#define PIXFMT_BGR15    2
#define PIXFMT_RGB15PC  3
#define PIXFMT_BGR15PC  4
#define PIXFMT_RGB16    5
#define PIXFMT_BGR16    6
#define PIXFMT_RGB16PC  7
#define PIXFMT_BGR16PC  8
#define PIXFMT_RGB24    9
#define PIXFMT_BGR24   10
#define PIXFMT_ARGB32  11
#define PIXFMT_BGRA32  12
#define PIXFMT_RGBA32  13

/*                                                        */
/* SrcRectangle formats defines for xxxPixelArray calls() */
/*                                                        */

#define RECTFMT_RGB   0
#define RECTFMT_RGBA  1
#define RECTFMT_ARGB  2
#define RECTFMT_LUT8  3
#define RECTFMT_GREY8 4

/*                                    */
/* Parameters for CVideoCtrlTagList() */
/*                                    */

#define SETVC_DPMSLevel  0x88002001

#define DPMS_ON      0   /* Full operation                             */
#define DPMS_STANDBY 1   /* Optional state of minimal power reduction  */
#define DPMS_SUSPEND 2   /* Significant reduction of power consumption */
#define DPMS_OFF     3   /* Lowest level of power consumption          */

/*                              */
/* Tags for LockBitMapTagList() */
/*                              */

#define LBMI_WIDTH       0x84001001
#define LBMI_HEIGHT      0x84001002
#define LBMI_DEPTH       0x84001003
#define LBMI_PIXFMT      0x84001004
#define LBMI_BYTESPERPIX 0x84001005
#define LBMI_BYTESPERROW 0x84001006
#define LBMI_BASEADDRESS 0x84001007

#endif
