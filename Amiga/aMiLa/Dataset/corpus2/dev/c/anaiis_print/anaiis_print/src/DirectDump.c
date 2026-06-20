/**************************************************************************/
/*                              DirectDump.c                              */
/**************************************************************************/
/* Gilles PELLETIER
 *
 * Attempts to print in 24 bit colors even with the old printer.device
 * and classic printer drivers (1.3 and higher)
 * This program load a QRT file (the picture file of early version of povray)
 * and print it.
 * If no file, it prints a palette, like rasterdump or a colorwheel.
 *
 * 25-Feb-2013 Big mystery... SetTaskPri -1 and it works...
 * 21-Feb-2013 Change C call
 * 03-Apr-2012 Suppress dither16
 * 05-Sep-2011 Constants and more tests
 * 30-Aug-2011 bidimensional arrays
 * 26-Mar-2011 This program is working (ieee1284.device is a big amount of crap)
 * 02-Feb-2011 FreeDiskObject
 * 06-Dec-2009 Zoom fix
 * 23-Nov-2009 Simplifies
 * 20-Nov-2009 Zoom, fix bug with page ejection
 * 17-Nov-2009 integrates algorithms for images to avoid to store QRT files
 * 16-Nov-2009 palettes builtin 24 bit colors
 * 12-Nov-2009 black and white + greyscale printing
 * 13-Oct-2009 mysterious end
 * 03-Sep-2009 Workbench and icons
 * 26-Feb-2009 24 bit printing
 * 15-Feb-2009 Redirectingin a file
 * 22-Jan-2009 Documenting
 * 31-Dec-2008 
 * 26-Dec-2008 Undocumented printing
 */

#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

#include <exec/memory.h>
#include <exec/io.h>
#include <exec/libraries.h>
#include <exec/devices.h>

#include <devices/printer.h>
#include <devices/prtbase.h>
#include <devices/prtgfx.h>

#include <workbench/startup.h>

#include <clib/alib_protos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/icon.h>

#include "image.h"
#include "gui.h"

/* Libraries */

extern struct Library *SysBase;
extern struct Library *DOSBase;

extern struct WBStartup *_WBenchMsg ;

void CleanExit(char *libname) ;

struct Library *OpenLib(char *libname, long version)
{
  struct Library *lib ;

  lib = OpenLibrary(libname, version) ;
  if (lib == NULL)
  {
    CleanExit(libname) ;
  }

  return lib ;
}

void OpenLibs(void)
{
} /* OpenLibs */

void CloseLibs(void)
{
} /* CloseLibs */

void CleanExit(char *s)
{
  CloseLibs() ;
  if (s != NULL)
  {
    printf("\"%s\" won't open\n", s) ;
  }

  exit(0) ;
} /* CleanExit */

/**************************************************************************
 */

struct PrinterData *PD          = NULL ;
struct PrinterExtendedData *PED = NULL ;

long Pr_Init(
struct IODRPReq *io,
long width,
long height
)
{
  long ret = PDERR_NOERR ;

  /* Master initialization */

  if (PED != NULL)
  {
    LONG __stdargs (* ped_Render)(ULONG, LONG, LONG, LONG) = PED->ped_Render ;

    /* Master initialization */
    ret = ped_Render((ULONG)io, width, height, 0) ; 
  }

  return ret ;
}

long Pr_Render(
struct PrtInfo *prtinfo,
long code, /* Only if the printer is PCC_MULTIPASS */
long rownum
)
{
  long ret = PDERR_NOERR ;

  /* Putting the pixels in a buffer */

  if (PED != NULL)
  {
    LONG __stdargs (* ped_Render)(ULONG, LONG, LONG, LONG) = PED->ped_Render ;

    /* Scale, dither and render */
    ret = ped_Render((ULONG)prtinfo, code, rownum, 1) ; 
  }

  return ret ;
}


long Pr_Write(
long numrows
)
{
  long ret = PDERR_NOERR ;

  /* Dumping a pixel buffer to the printer */

  if (PED != NULL)
  {
    LONG __stdargs (* ped_Render)(ULONG, LONG, LONG, LONG) = PED->ped_Render ;

    /* Dump buffer to printer */
    ret = ped_Render(0, 0, numrows, 2) ; 
  }

  return ret ;
}

long Pr_Clear(void)
{
  long ret = PDERR_NOERR ;

  /* Clearing and initializing the pixel buffer */

  if (PED != NULL)
  {
    LONG __stdargs (* ped_Render)(ULONG, LONG, LONG, LONG) = PED->ped_Render ;

    /* Clear and init buffer */
    ret = ped_Render(0, 0, 0, 3) ; 
  }

  return ret ;
}

long Pr_Exit(
long errorcode,
long special
)
{
  long ret = PDERR_NOERR ;

  /* Closing Down */

  if (PED != NULL)
  {
    LONG __stdargs (* ped_Render)(ULONG, LONG, LONG, LONG) = PED->ped_Render ;

    /* Close down */
    ret = ped_Render(errorcode, special, 0, 4) ; 
  }

  return ret ;
}

long Pr_PreMasterInit(
struct IODRPReq *io,
long special
)
{
  long ret = PDERR_NOERR ;

  /* Pre-Master initialization */

  if (PED != NULL)
  {
    LONG __stdargs (* ped_Render)(ULONG, LONG, LONG, LONG) = PED->ped_Render ;

    /* Pre-master init */
    ret = ped_Render((ULONG)io, special, 0, 5) ; 
  }

  return ret ;
}

/* Switching to the next color, for multi-color printers 6 */



/**/
BPTR outfile = NULL ;

LONG __stdargs (*oldwrite)(UBYTE *, ULONG) = NULL ;
LONG __stdargs __saveds PWrite(UBYTE *buffer, ULONG length)
{
  if (outfile != NULL)
  {
    return Write(outfile, buffer, length) ;
  }
  return 0 ;
}

LONG __stdargs (*oldready)(VOID) = NULL ;
LONG __stdargs PBothReady(VOID)
{
  return 0 ;
}

/**********************************************************************/
/* 4x4 internal matrix */
static UBYTE dither_matrix4x4[4][4] =
{
  {   0,  8,   2,  10 },
  {  12,  4,  14,   6 },
  {   3, 11,   1,   9 },
  {  14,  7,  13,   5 } /* 14 should be 15 but... */
} ;

/**********************************************************************/
static UBYTE dither_matrix8x8[8][8] =
{
  {  82, 168, 125, 153,  94, 164, 113, 149 },
  { 196,   7, 227,  54, 200,  11, 231,  58 },
  { 102, 129,  70, 184, 105, 141,  74, 180 },
  { 243,  39, 211,  23, 247,  43, 215,  27 },
  {  90, 160, 117, 145,  86, 172, 121, 156 },
  { 204,  15, 235,  62, 192,   3, 223,  51 },
  { 109, 137,  78, 176,  98, 133,  66, 188 },
  { 251,  47, 219,  31, 239,  35, 207,  19 }
} ;

UBYTE dither8( UBYTE v, UWORD x, UWORD y, UBYTE pen1, UBYTE pen2 )
{ 
  UBYTE pen = pen2 ;

  if (v < dither_matrix8x8[x & 0x07][y & 0x07])
  {
    pen = pen1 ;
  }

  return pen ;
} /* dither8 */

/**********************************************************************/
static UBYTE dither_matrix16x16[16][16] =
{
  {   1, 189, 244,  13,  68, 154, 251,  12,   3, 198,  69,  15, 245, 153, 116,  10 },
  { 129, 212, 107, 117, 241, 138, 179, 204, 208, 130, 203, 242, 106, 187, 248, 252 },
  {  83,  62,  23, 195,  50,  72, 192, 137,  63,  82,  25, 254,  87,  51, 254, 209 },
  { 238,  94, 161, 148,  32, 183,  74, 222, 127,  95, 182,  34, 139, 239, 172, 226 },
  {  21,  84, 218,   5,  42,  80, 217,  17, 225,  85, 186,   7,  41,  75, 253,  19 },
  { 213, 101,  55, 156,  66, 123, 196, 145, 124, 155, 102, 160, 219, 147, 177, 255 },
  { 173, 230, 205, 167, 162, 110,  98, 142, 174,  53, 169, 197, 111, 231, 246, 249 },
  {  37,  78,  89, 199,  77,  57,  27,  35,  44, 193,  70, 146, 229,  59,  29,  45 },
  {   4, 128, 180,  16, 132, 234, 114,   9,   2,  81, 210,  14, 133, 235, 115,  11 },
  { 190, 125, 141, 211, 170, 104, 214, 151,  90, 207, 118, 105, 140, 152, 120,  91 },
  { 144, 206, 221, 157,  49, 184, 158, 185, 136,  61,  99, 159,  48, 194, 215, 188 },
  { 240,  65,  26,  39,  33,  71,  73, 228,  64,  96,  24,  31,  40,  52,  76, 250 },
  {  22,  97, 191,   8,  43, 122, 200,  20, 163, 131, 121,   6, 143, 220, 236,  18 },
  { 224, 113, 109, 149, 176, 166, 165, 223, 175, 164,  86, 108, 150, 178, 216, 227 },
  { 126,  79,  54, 168, 201, 254, 237, 243,  47,  56, 181,  67, 112, 232, 119,  46 },
  {  36, 103, 233, 247, 135,  60,  30,  38,  93, 202, 100, 171, 134,  58,  28,  92 },
} ;

UBYTE dither16( UBYTE v, UWORD x, UWORD y, UBYTE pen1, UBYTE pen2 )
{ 
  UBYTE pen = pen2 ;

  if (v < dither_matrix16x16[x & 0x0f][y & 0x0f])
  {
    pen = pen1 ;
  }

  return pen ;
} /* dither16 */

UBYTE printoutfile[256] ;
UBYTE *filename ;
UWORD pagewidth, pageheight ;
UWORD iwidth, iheight ;
UBYTE rendertype ;
UBYTE density ;
BYTE template ;
UWORD radius ;
BYTE zoom ; 

void dotooltypes(struct DiskObject *dskobj)
{
  if (dskobj != NULL)
  {
    UBYTE *n = NULL ;

    n = FindToolType(dskobj->do_ToolTypes, "OUTFILE") ;
    if (n != NULL)
    {
      printoutfile[0] = 0 ;
      strncat(printoutfile, n, sizeof(printoutfile)-1) ;
    }

    n = FindToolType(dskobj->do_ToolTypes, "RENDERTYPE") ;
    if (n != NULL)
    {
      if ((strcmp(n, "12B")==0) ||
          (strcmp(n, "12")==0))
      {
        rendertype = 12 ;
      }

      if ((strcmp(n, "24B")==0) ||
          (strcmp(n, "24")==0))
      {
        rendertype = 24 ;
      }

      if ((strcmp(n, "16B")==0) ||
          (strcmp(n, "16")==0))
      {
        rendertype = 16 ;
      }
    }

    n = FindToolType(dskobj->do_ToolTypes, "DENSITY") ;
    if (n != NULL)
    {
      density = atol(n) ;

      if (density < 1) density = 1 ;
      if (density > 7) density = 7 ;
    }

    n = FindToolType(dskobj->do_ToolTypes, "TEMPLATE") ;
    if (n != NULL)
    {
      if (strcmp(n, "PALETTE")==0)
      {
        template = IMAGE_TEMPLATE_PALETTE ;
      }

      if (strcmp(n, "COLORWHEEL")==0)
      {
        template = IMAGE_TEMPLATE_COLORWHEEL ;
      }

      if (strcmp(n, "COLORSPREAD")==0)
      {
        template = IMAGE_TEMPLATE_COLORSPREAD ;
      }

      if (strcmp(n, "PALETTEREF")==0)
      {
        template = IMAGE_TEMPLATE_PALETTEREF ;
      }
    }

    n = FindToolType(dskobj->do_ToolTypes, "PAGEWIDTH") ;
    if (n != NULL)
    {
      iwidth = atol(n) ;
    }

    n = FindToolType(dskobj->do_ToolTypes, "PAGEHEIGHT") ;
    if (n != NULL)
    {
      iheight = atol(n) ;
    }

    n = FindToolType(dskobj->do_ToolTypes, "RADIUS") ;
    if (n != NULL)
    {
      radius = atol(n) ;
    }

    n = FindToolType(dskobj->do_ToolTypes, "ZOOM") ;
    if (n != NULL)
    {
      zoom = atol(n) ;
    }
  }
}

UWORD pencils[15] ;

struct Gadget stopgadget ;
struct IntuiText stopgadgettext ;
struct Image R1,R2,R3,S1,S2,S3 ;
char tmp[255] ;

int main(int argc, char *argv[])
{
  struct IODRPReq *pio ;
  struct MsgPort *port ;
  
  struct ImageDataInfo *im = NULL ;
  int im_width  = 0 ;
  int im_height = 0 ;
  UBYTE *im_R   = NULL ;
  UBYTE *im_G   = NULL ;
  UBYTE *im_B   = NULL ;

  struct PrtInfo *prtinfo = NULL ;
  struct Device *dev ;
  int err ;  
  int t = 10 ;

  UBYTE C, M, Y, K ;
  int cnt, linenum ;
  struct Window *wndw = NULL ;
  ULONG special = 0 ;
  BOOL loop ;
  BOOL abort ;
  long oldpri = 0 ;

  density    = 1 ;
  rendertype = 12 ;
  pagewidth  = 2400 ;
  pageheight = 160 ;
  iwidth     = 0 ;
  iheight    = 0 ;
  filename   = NULL ;
  printoutfile[0] = 0 ;
  template   = IMAGE_TEMPLATE_NONE ;
  radius     = 0 ;
  zoom       = 1 ;

  oldpri = SetTaskPri(FindTask(NULL), -1) ;

  OpenLibs() ;

  if (argc == 0)
  {
    if (_WBenchMsg != NULL)
    {
      struct DiskObject *dskobj ;
      dskobj = GetDiskObject(_WBenchMsg->sm_ArgList[0].wa_Name) ;
      if (dskobj != NULL)
      {
        dotooltypes(dskobj) ;
        FreeDiskObject(dskobj) ;
      }

      CurrentDir(_WBenchMsg->sm_ArgList[0].wa_Lock) ;
      if (_WBenchMsg->sm_NumArgs > 1)
      {
        CurrentDir(_WBenchMsg->sm_ArgList[1].wa_Lock) ;
        filename = _WBenchMsg->sm_ArgList[1].wa_Name ;
        dskobj = GetDiskObject(_WBenchMsg->sm_ArgList[1].wa_Name) ;
        if (dskobj != NULL)
        {
          dotooltypes(dskobj) ;
          FreeDiskObject(dskobj) ;
        }
      }
    }
  }
  else
  {
    if (argc > 1)
    {
      filename   = argv[1] ;
      rendertype = 24 ;
      density    = 7 ;
    }
    else
    {
      /* debug */
      template = IMAGE_TEMPLATE_COLORWHEEL ;
      iwidth   = 512 ;
      iheight  = 512 ;
      radius   = 250 ;
      zoom     = 2 ;
    } 
  }

  port = (struct MsgPort*) CreatePort( 0, 0 ) ;
  if (port == NULL)
  {
    printf( "Can't create port\n" ) ;
    CleanExit(NULL) ;
  }

  pio = (struct IODRPReq*)CreateExtIO( port, sizeof(struct IODRPReq)) ;
  if (pio == NULL)
  {
    printf( "Can't create io\n" ) ;
    DeletePort((struct MsgPort *)port) ;
    CleanExit(NULL) ;
  }
  
  err = OpenDevice( "printer.device", 0, (struct IORequest *)pio, 0 ) ;
  if (err != 0)
  {
    printf( "Can't open printer.device error=%d\n", err ) ;
    DeleteExtIO((struct IORequest *)pio) ;
    DeletePort((struct MsgPort *)port) ;
    CleanExit(NULL) ;
  }

  wndw = wopen(WA_Left,    20,
               WA_Top,     20,
               WA_Width,  400,
               WA_Height, 150,
               WA_Title, (ULONG)"DirectDump",
               WA_IDCMP, IDCMP_CLOSEWINDOW|
                         IDCMP_NEWSIZE|
                         IDCMP_ACTIVEWINDOW|
                         IDCMP_GADGETUP,
               WA_Flags, WFLG_SMART_REFRESH|
                         WFLG_GIMMEZEROZERO,
               TAG_DONE) ;

  if (wndw != NULL)
  {
    struct Gadget *g ;

    wsetpencils(pencils) ;

    memset(&stopgadgettext, 0, sizeof(stopgadgettext)) ;
    memset(&stopgadget, 0, sizeof(stopgadget)) ;

    g = &stopgadget ;
    g->NextGadget    = NULL ;
    g->LeftEdge      = 140 ;
    g->TopEdge       = t + 10 ;
    g->Width         = 80 ;
    g->Height        = 11 ;
    g->GadgetText    = &stopgadgettext ; 
    g->Flags         = GFLG_GADGHCOMP ;
    g->Activation    = GACT_RELVERIFY|GACT_IMMEDIATE ;
    g->GadgetType    = GTYP_BOOLGADGET ;
    g->MutualExclude = 0 ;
    g->SpecialInfo   = NULL ;
    g->GadgetID      = 1 ;
    g->UserData      = 0 ;

    stopgadgettext.FrontPen  = 1 ;
    stopgadgettext.BackPen   = 0 ;
    if (g->GadgetText != NULL)
    {
      WORD h ;

      g->GadgetText->IText = "Stop" ;
      if (g->GadgetText->ITextFont != NULL)
      {
        h = g->GadgetText->ITextFont->ta_YSize ;
      }
      else
      {
        h = 8 ;
      }

      if ( h+2 > g->Height )
      {
        g->Height = h+2 ;
      }
      g->GadgetText->LeftEdge = (g->Width-IntuiTextLength(g->GadgetText))/2 ;
      g->GadgetText->TopEdge  = 1+(g->Height-h)/2 ;
    }
    stopgadgettext.DrawMode  = JAM1 ;
    stopgadgettext.ITextFont = NULL ;
    stopgadgettext.NextText  = NULL ;
    Button_SetImage(g, &R1, &R2, &R3, &S1, &S2, &S3, pencils) ;

    AddGadget(wndw, &stopgadget, 0) ;
    RefreshGadgets(&stopgadget, wndw, NULL) ; 
    SetAPen(wndw->RPort, pencils[TEXTPEN]) ;
    DrawRect(wndw->RPort,
             9,
             stopgadget.TopEdge,
             111,
             stopgadget.TopEdge+stopgadget.Height) ;
  }

  if (1)
  {
    /* Init printer ? print nothing but initialize a lot */
    struct IOStdReq *ios = (struct IOStdReq *)pio ;
    struct IORequest *io = NULL ;
    struct IntuiMessage *msg, imsg ;

    ios->io_Command = CMD_WRITE ;
    ios->io_Data    = "\033#1" ;
    ios->io_Length  = 0 ;
    SendIO((struct IORequest *)ios) ;
    loop = TRUE ;
    abort = FALSE ;
    do
    {
      io = CheckIO((struct IORequest *)ios) ;
      if (io == NULL)
      {
      }
      else
      {
        loop = FALSE ;
      }
     
      if (wndw != NULL)
      {
        msg = (struct IntuiMessage *)GetMsg(wndw->UserPort) ;
        if (msg == NULL)
        {
        }
        else
        {
          do
          {
            imsg = *msg ;
            ReplyMsg((struct Message *)msg) ;
            switch (imsg.Class)
            {
              case IDCMP_CLOSEWINDOW :
              {
                loop = FALSE ;
                break ;
              }

              case IDCMP_GADGETUP :
              {
                switch (((struct Gadget *)imsg.IAddress)->GadgetID)
                {
                  case 1 :
                  {
                    loop = FALSE ;
                    abort = TRUE ;
                    break ;
                  }
                }
                break ;
              }
            }
            msg = (struct IntuiMessage *)GetMsg(wndw->UserPort) ;
          } while (msg != NULL) ;
        }
      }
    } while (loop) ;
    AbortIO((struct IORequest *)ios) ;
  }

  if (abort)
  {
    printf( "Can't open printer\n") ;
    CloseDevice((struct IORequest *)pio) ;
    DeleteExtIO((struct IORequest *)pio) ;
    DeletePort((struct MsgPort *)port) ;
    if (wndw != NULL) wclose(wndw) ;
    CleanExit(NULL) ;
  }

  if ((template == IMAGE_TEMPLATE_NONE) && (filename != NULL))
  {
    printf("Try to load '%s' file\n", filename) ;

    im = image_open(filename) ;
    if (im == NULL)
    {
      printf("problem to load picture\n") ;
    }
    else
    {
      im_width  = getwidth(im) ;
      im_height = getheight(im) ;
      printf("ok (%ld,%ld)\n", im_width, im_height) ;
      im_R = malloc(im_width) ;
      im_G = malloc(im_width) ;
      im_B = malloc(im_width) ;
      if (im_R == NULL || im_G == NULL || im_B == NULL)
      {
        if (im_R != NULL)
        {
          free (im_R) ;
          im_R = NULL ;
        }

        if (im_G != NULL)
        {
          free (im_G) ;
          im_G = NULL ;
        }

        if (im_B != NULL)
        {
          free (im_B) ;
          im_B = NULL ;
        }
        image_close(im) ;
        im = NULL ;
      } 
    }
  }

  if (im == NULL)
  {
    im = image_open(NULL) ;
    if (im != NULL)
    {
      im->template = template ;
      im->radius   = radius ;
      im->width    = iwidth ;
      im->height   = iheight ;
      image_init(im) ;

      im_width  = getwidth(im) ;
      im_height = getheight(im) ;

      switch (im->template)
      {
        case IMAGE_TEMPLATE_PALETTE :
        {
          printf ("use palette template\n") ;
          break ;
        }

        case IMAGE_TEMPLATE_PALETTEREF :
        {
          printf ("use reference palette template\n") ;
          break ;
        }

        case IMAGE_TEMPLATE_COLORWHEEL :
        {
          printf ("use colorwheel (%d,%d),%d\n",
                  im->width,
                  im->height,
                  im->radius) ; 
          break ;
        }

        default :
        {
          printf("default rendering (%ld,%ld)\n", im->width, im->height) ;
          break ;
        }
      }

      im_R = malloc(im_width) ;
      im_G = malloc(im_width) ;
      im_B = malloc(im_width) ;
      if (im_R == NULL || im_G == NULL || im_B == NULL)
      {
        if (im_R != NULL)
        {
          free (im_R) ;
          im_R = NULL ;
        }

        if (im_G != NULL)
        {
          free (im_G) ;
          im_G = NULL ;
        }

        if (im_B != NULL)
        {
          free (im_B) ;
          im_B = NULL ;
        }
        image_close(im) ;
        im = NULL ;
      }  
    }
  }  

  PD  = (struct PrinterData *)pio->io_Device ;
  PED = &PD->pd_SegmentData->ps_PED ; 

  /* printer.device */
  dev = (struct Device *)pio->io_Device ;
  printf( "Printer: '%s' %02u.%02u\n",
          dev->dd_Library.lib_Node.ln_Name,
          dev->dd_Library.lib_Version,
          dev->dd_Library.lib_Revision) ;
  
  /* parallel.device */
  dev = (struct Device *)PD->pd_ior0.pd_p0.IOPar.io_Device ;
  printf( "Port   : '%s' %02u.%02u\n",
          dev->dd_Library.lib_Node.ln_Name,
          dev->dd_Library.lib_Version,
          dev->dd_Library.lib_Revision) ;

  printf( "Driver : '%s' %02u.%02u\n",
          PED->ped_PrinterName,
          PD->pd_SegmentData->ps_Version,
          PD->pd_SegmentData->ps_Revision ) ;
        
  printf( "PrinterClass=%u, ColorClass=%u\n",
          PED->ped_PrinterClass,
          PED->ped_ColorClass ) ;
  
  printf( "MaxColumns=%u, NumCharSets=%u, NumRows=%u\n",
          PED->ped_MaxColumns,
          PED->ped_NumCharSets,
          PED->ped_NumRows ) ;
  
  printf( "MaxXDots=%lu, MaxYDots=%lu, XDotsInch=%u, YDotsInch=%u\n",
          PED->ped_MaxXDots, PED->ped_MaxYDots,
          PED->ped_XDotsInch, PED->ped_YDotsInch ) ;

  if (printoutfile[0] != 0)
  {
    outfile = Open(printoutfile, MODE_NEWFILE) ;
    if (outfile != NULL)
    {
      oldwrite          = PD->pd_PWrite ;
      PD->pd_PWrite     = PWrite ;
      oldready          = PD->pd_PBothReady ;
      PD->pd_PBothReady = PBothReady ;
    }
  }

  special = 0 ;
  switch (density)
  {
    case 1 : special |= SPECIAL_DENSITY1 ; break ;
    case 2 : special |= SPECIAL_DENSITY2 ; break ;
    case 3 : special |= SPECIAL_DENSITY3 ; break ;
    case 4 : special |= SPECIAL_DENSITY4 ; break ;
    case 5 : special |= SPECIAL_DENSITY5 ; break ;
    case 6 : special |= SPECIAL_DENSITY6 ; break ;
    case 7 : special |= SPECIAL_DENSITY7 ; break ;
  }

  printf("PreMasterInit %ld\n", Pr_PreMasterInit(pio, special)) ;
  printf("NEW VALUES\n") ;
  printf("MaxColumns=%u, NumCharSets=%u, NumRows=%u\n",
          PED->ped_MaxColumns,
          PED->ped_NumCharSets,
          PED->ped_NumRows ) ;
  
  printf("MaxXDots=%lu, MaxYDots=%lu, XDotsInch=%u, YDotsInch=%u\n",
          PED->ped_MaxXDots, PED->ped_MaxYDots,
          PED->ped_XDotsInch, PED->ped_YDotsInch ) ;

  if ((im_width > 0) && (im_height > 0))
  {
    if (PED->ped_MaxXDots <= 0)
    {
      /* hu... */
      pagewidth = im_width*zoom ;
    }
    else
    {
      if (im_width*zoom > PED->ped_MaxXDots)
      {
        pagewidth = PED->ped_MaxXDots ;
      }
      else
      {
        pagewidth = im_width*zoom ;
      }
    }

    if (PED->ped_MaxYDots <= 0)
    {
      /* no limit */
      pageheight = im_height*zoom ;
    }
    else
    {
      if (im_height*zoom > PED->ped_MaxYDots)
      {
        pageheight = PED->ped_MaxYDots ;
      }
      else
      {
        pageheight = im_height*zoom ;
      }
    }
  }

  prtinfo = (struct PrtInfo *)AllocMem(sizeof(struct PrtInfo), MEMF_CLEAR) ;
  if (prtinfo != NULL)
  {
    long pixcount = 0 ;
    long pixposX ;
    long pixposY ;

    if (im_width*zoom > PED->ped_MaxXDots)
    {
      pixcount = PED->ped_MaxXDots ;
    }
    else
    {
      pixcount = im_width*zoom ;
    }

    prtinfo->pi_threshold = 15 ;
    prtinfo->pi_xpos      = 0 ;
    prtinfo->pi_ColorInt  = (union colorEntry *)AllocMem(pixcount*sizeof(union colorEntry), MEMF_CLEAR) ;
    prtinfo->pi_ScaleX    = (UWORD *)AllocMem(pixcount*sizeof(UWORD), MEMF_CLEAR) ;
    prtinfo->pi_dmatrix   = (UBYTE *)AllocMem(4*4, MEMF_CLEAR) ;


    if ((prtinfo->pi_ColorInt != NULL) &&
        (prtinfo->pi_ScaleX   != NULL) &&
        (prtinfo->pi_dmatrix  != NULL))
    {
      long i, j, ii, jj ;
      long toto    = 0 ;
      long oldtoto = -1 ;
      long err ;

      printf("now printing (row=%ld pix)\n", pixcount) ;

      for ( i = 0 ; i < pixcount ; i++ )
      {
        prtinfo->pi_ScaleX[i] = 1 ;
      }

      printf("Init(%ld,%ld)\n", pagewidth, pageheight) ;

      err = Pr_Init(pio, pagewidth, pageheight) ;
      printf(">%ld\n", err) ;

      Pr_Clear() ;

      if (rendertype == 12)
      {
        /* 12 bits */
        memcpy(prtinfo->pi_dmatrix, &dither_matrix4x4[0][0], 16) ;
      }
      else
      {
        /* 24 bits */
        /* don't use internal matrix */
        for ( i = 0 ; i < 16 ; i ++ )
        {
          prtinfo->pi_dmatrix[i] = 0 ;
        }
      }

      if (im != NULL)
      {
        loop    = TRUE ;
        cnt     = 0 ;
        linenum = 0 ;

        for ( j = 0 ; (j < im_height) && loop ; j++ )
        {
          getrowX(im, j, im_R, 1) ;
          getrowX(im, j, im_G, 2) ;
          getrowX(im, j, im_B, 3) ;

          for ( jj = 0 ; (jj < zoom) && loop ; jj++)
          {
            pixposY = j*zoom + jj ;

            for ( i = 0 ; (i < im_width) && loop ; i++ )
            {
              for ( ii = 0 ; (ii < zoom) && loop ; ii++ )
              {
                pixposX = i*zoom + ii ;
                if (pixposX < pixcount)
                {
                  if (rendertype == 12)
                  {
                    /* 12 bits render */
                    C = ~(im_R[i] >> 4) & 0xf ;
                    M = ~(im_G[i] >> 4) & 0xf ;
                    Y = ~(im_B[i] >> 4) & 0xf ;
                    K = 0 ;

                    switch (PD->pd_Preferences.PrintShade)
                    {
                      case SHADE_BW :
                      case SHADE_GREYSCALE :
                      {
                        ULONG c ;
                        c = (C + M + Y)/3 ;
                        K = c ;
                        C = 0 ;
                        M = 0 ;
                        Y = 0 ;
                        break ;
                      }

                      case SHADE_COLOR :
                      {
                        switch (PED->ped_ColorClass)
                        {
                          case PCC_BW :     /* 1 black & white */
                          {
                            ULONG c ;
                            c = (C + M + Y)/3 ;
                            K = c ;
                            C = 0 ;
                            M = 0 ;
                            Y = 0 ;
                            break ;
                          }

                          case PCC_YMC :    /* 2 yellow/magenta/cyan only */
                          {
                            K = 0 ;
                            break ;
                          }

                          case PCC_YMC_BW : /* 3 yellow/magenta/cyan or black&white */
                          case PCC_YMCB :   /* 4 yellow/magenta/cyan/black */
                          {
                            UBYTE var = 15 ;

                            if (C < var) var = C ;
                            if (M < var) var = M ;
                            if (Y < var) var = Y ;

                            if (var == 15)
                            {
                              C = 0 ;
                              M = 0 ;
                              Y = 0 ;
                            }
                            else
                            {
                              C = ( C - var ) * 15 / ( 15 - var ) ;
                              M = ( M - var ) * 15 / ( 15 - var ) ;
                              Y = ( Y - var ) * 15 / ( 15 - var ) ; 
                            }
                            K = var ;
                            break ;
                          }
                        }
                        break ;
                      }
                    }
                  }
                  else
                  {
                    /* 24 bits render */
                    C = ~im_R[i] ;
                    M = ~im_G[i] ;
                    Y = ~im_B[i] ;
                    K = 0 ;

                    switch (PD->pd_Preferences.PrintShade)
                    {
                      case SHADE_BW :
                      case SHADE_GREYSCALE :
                      {
                        ULONG c ;
                        c = (C + M + Y) / 3 ;
                        K = c ;
                        C = 0 ;
                        M = 0 ;
                        Y = 0 ;
                        break ;
                      }

                      case SHADE_COLOR :
                      {
                        switch (PED->ped_ColorClass)
                        {
                          case PCC_BW :     /* 1 black & white */
                          {
                            ULONG c ;
                            c = (C + M + Y) / 3 ;
                            K = c ;
                            C = 0 ;
                            M = 0 ;
                            Y = 0 ;
                            break ;
                          }

                          case PCC_YMC :    /* 2 yellow/magenta/cyan only */
                          {
                            K = 0 ;
                            break ;
                          }

                          case PCC_YMC_BW : /* 3 yellow/magenta/cyan or black&white */
                          case PCC_YMCB :   /* 4 yellow/magenta/cyan/black */
                          {
                            UBYTE var = 255 ;

                            if (C < var) var = C ;
                            if (M < var) var = M ;
                            if (Y < var) var = Y ;
  
                            if (var == 255)
                            {
                              C = 0 ;
                              M = 0 ;
                              Y = 0 ;
                            }
                            else
                            {
                              C = ( C - var ) * 255 / ( 255 - var ) ;
                              M = ( M - var ) * 255 / ( 255 - var ) ;
                              Y = ( Y - var ) * 255 / ( 255 - var ) ; 
                            }
                            K = var ;
                            break ;
                          }
                        }
                        break ;
                      }
                    }

                    /* At his point, 0 means no dot, 15 dot in full intensity */
                    if (0 /*rendertype == 24*/)
                    {
                      C = dither16(C, pixposX, pixposY, 0, 15) ;
                      M = dither16(M, pixposX, pixposY, 0, 15) ;
                      Y = dither16(Y, pixposX, pixposY, 0, 15) ;
                      K = dither16(K, pixposX, pixposY, 0, 15) ;
                    }
                    else
                    {
                      C = dither8(C, pixposX, pixposY, 0, 15) ;
                      M = dither8(M, pixposX, pixposY, 0, 15) ;
                      Y = dither8(Y, pixposX, pixposY, 0, 15) ;
                      K = dither8(K, pixposX, pixposY, 0, 15) ;
                    }
                  }

                  prtinfo->pi_ColorInt[pixposX].colorByte[PCMYELLOW ] = Y ;
                  prtinfo->pi_ColorInt[pixposX].colorByte[PCMMAGENTA] = M ;
                  prtinfo->pi_ColorInt[pixposX].colorByte[PCMCYAN   ] = C ;
                  prtinfo->pi_ColorInt[pixposX].colorByte[PCMBLACK  ] = K ;
                  prtinfo->pi_width = pixposX ;
                } 
              } /* ii */
            } /* i */
            Pr_Render(prtinfo, 0, linenum) ;

            cnt ++ ;
            linenum++ ;

            if (cnt >= PED->ped_NumRows)
            {
              Pr_Write(cnt) ;
              Pr_Clear() ;
              cnt = 0 ;
            }
          } /* jj */

          if (wndw != NULL)
          {
            toto = j * 100 / im_height ;
            if (toto != oldtoto)
            {
              oldtoto = toto ;
              SetAPen(wndw->RPort, pencils[TEXTPEN]) ;
              DrawRect(wndw->RPort,
                       9,
                       stopgadget.TopEdge,
                       111,
                       stopgadget.TopEdge+stopgadget.Height) ;
              if (toto > 0)
              {
                SetAPen(wndw->RPort, pencils[FILLPEN]) ;
                RectFill(wndw->RPort,
                         10,
                         stopgadget.TopEdge+1,
                         10+toto,
                         stopgadget.TopEdge+stopgadget.Height-1) ;
              }

              if (toto < 100)
              {
                SetAPen(wndw->RPort, pencils[BACKGROUNDPEN]) ;
                RectFill(wndw->RPort,
                         10+toto,
                         stopgadget.TopEdge+1,
                         10+100,
                         stopgadget.TopEdge+stopgadget.Height-1) ;
              }
  
              SetAPen(wndw->RPort, pencils[SHINEPEN]) ; 
              SetDrMd(wndw->RPort, JAM1) ;
              sprintf(tmp, "%d%%", toto) ;
              Move(wndw->RPort,
                   10 + (100 - TextLength(wndw->RPort, tmp, strlen(tmp)))/2,
                   stopgadget.TopEdge + 1 + (stopgadget.Height-wndw->RPort->TxHeight)/2+wndw->RPort->TxBaseline) ;
              Text(wndw->RPort, tmp, strlen(tmp)) ;
            }

            if (1)
            {
              struct IntuiMessage *msg, imsg ;

              do
              {
                msg = (struct IntuiMessage *)GetMsg(wndw->UserPort) ;
                if (msg != NULL)
                {
                  imsg = *msg ;
                  ReplyMsg((struct Message *)msg) ;
                  switch (imsg.Class)
                  {
                    case IDCMP_CLOSEWINDOW :
                    {
                      loop = FALSE ;
                      break ;
                    }

                    case IDCMP_GADGETUP :
                    {
                      switch (((struct Gadget *)imsg.IAddress)->GadgetID)
                      {
                        case 1 :
                        {
                          loop = FALSE ;
                          break ;
                        }
                      }
                      break ;
                    }
                  }
                }
              } while (msg != NULL) ;
            }
          }
        } /* j */

        if (cnt > 0)
        {
          Pr_Write(cnt) ;
          Pr_Clear() ;
          cnt = 0 ;
        }
      }

      if (outfile == NULL)
      {
        /* desesperate workaround */
        oldready          = PD->pd_PBothReady ;
        PD->pd_PBothReady = PBothReady ;
      }
      printf("Exit  %ld\n", Pr_Exit(0, 0)) ;
      if (outfile == NULL)
      {
        PD->pd_PBothReady = oldready ;
      }
    }

    /* Free all resources */
    if (prtinfo->pi_dmatrix != NULL)
    {
      FreeMem(prtinfo->pi_dmatrix, 16) ;
      prtinfo->pi_dmatrix = NULL ;
    }

    if (prtinfo->pi_ScaleX != NULL)
    {
      FreeMem(prtinfo->pi_ScaleX, pixcount*sizeof(UWORD)) ;
      prtinfo->pi_ScaleX = NULL ;
    }

    if (prtinfo->pi_ColorInt != NULL)
    {
      FreeMem(prtinfo->pi_ColorInt, pixcount*sizeof(union colorEntry)) ;
      prtinfo->pi_ColorInt = NULL ;
    }
    FreeMem(prtinfo, sizeof(struct PrtInfo)) ;
    prtinfo = NULL ;
  }    

  printf("done\n") ;

  if (wndw != NULL)
  {
    wclose(wndw) ;
  }

  if (outfile != NULL)
  {
    PD->pd_PWrite     = oldwrite ;
    PD->pd_PBothReady = oldready ;
    Close(outfile) ;
    outfile = NULL ;
  }

  if (im_R != NULL)
  {
    free (im_R) ;
    im_R = NULL ;
  }

  if (im_G != NULL)
  {
    free (im_G) ;
    im_G = NULL ;
  }

  if (im_B != NULL)
  {
    free (im_B) ;
    im_B = NULL ;
  }

  if (im != NULL)
  {
    image_close(im) ;
    im = NULL ;
  }

  CloseDevice((struct IORequest *)pio ) ;
  DeleteExtIO((struct IORequest *)pio ) ;
  DeletePort((struct MsgPort *)port ) ;
  CloseLibs() ;

  SetTaskPri(FindTask(NULL), oldpri) ;

} /* main */
