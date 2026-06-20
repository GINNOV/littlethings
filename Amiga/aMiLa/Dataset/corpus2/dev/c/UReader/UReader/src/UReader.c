/****************************************************************************/
/*                             UReader.c                                    */
/****************************************************************************/
/*
 * "unicode" text reader in "more" utility style
 *
 * use space or enter key to scroll pages.
 * use backspace to rewind file.
 *
 * Gilles Pelletier September-October 2008
 *
 * Show the use of two kind of libraries to display UTF-8 or UCS-16 strings
 * Very exciting to see my old A2000 rivals with the latest PC Vista 
 *
 * ucode.library
 *
 * ttengine.library
 *
 * History
 * ~~~~~~~
 * 15-Sep-2011 Fix a bad mistake: aligment on even address for 68000!
 *             Add mouse pointers
 * 14-sep-2011 Missing FreeDiskObject
 * 07-jui-2010 Add fixed spacing
 * 25-nov-2008 Add spacex, spacey, fgpen, bgpen
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <exec/types.h>

#include <intuition/intuition.h>
#include <workbench/startup.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/icon.h>
#include <proto/intuition.h>
#include <proto/graphics.h>

#include "pointers.h"

#ifdef UREADER_TTENGINE
#include <libraries/ttengine.h>
#include <proto/ttengine.h>
#else
#include <libraries/ucode.h>
#include <proto/ucode.h>
#endif

extern struct WBStartup *_WBenchMsg ;

#define FILE_UNKNOWN 0
#define FILE_UNI_BE  1
#define FILE_UNI     2
#define FILE_UTF_8   3
#define FILE_TEXT    4           

#define EOL -8

/* open a window */
struct Window *wopen(char *title)
{

  return OpenWindowTags(NULL, WA_Left, 20,
                              WA_Top, 0,
                              WA_Width, 500,
                              WA_Height, 256,
                              WA_MinWidth, 80,
                              WA_MinHeight, 20,
                              WA_MaxWidth, -1,
                              WA_MaxHeight, -1,
                              WA_CloseGadget, -1,
                              WA_SizeGadget, -1,
                              WA_DragBar, -1,
                              WA_Activate, -1,
                              WA_NoCareRefresh, -1,
                              WA_IDCMP, IDCMP_CLOSEWINDOW|
                                        IDCMP_GADGETUP|
                                        IDCMP_GADGETDOWN|
                                        IDCMP_NEWSIZE|
                                        IDCMP_ACTIVEWINDOW|
                                        IDCMP_MOUSEMOVE|
                                        IDCMP_MOUSEBUTTONS|
                                        IDCMP_REFRESHWINDOW|
                                        IDCMP_RAWKEY,
                              WA_Flags, WFLG_SIZEGADGET|
                                        WFLG_DRAGBAR|
                                        WFLG_DEPTHGADGET|
                                        WFLG_CLOSEGADGET|
                                        WFLG_REPORTMOUSE|
                                        WFLG_SIMPLE_REFRESH|
                                        WFLG_GIMMEZEROZERO,
                              WA_Title, (ULONG)title,
                              TAG_END) ;
}

/* close a window */
void wclose(struct Window *w)
{
  CloseWindow(w) ;
}

/* wait something */
void waituser(struct Window *w)
{
  struct Message *msg ;

  WaitPort(w->UserPort) ;
  do
  {
    msg = GetMsg(w->UserPort) ;
    if (msg != NULL)
    {
      ReplyMsg(msg) ;
    }
  } while (msg != NULL) ;
}

#if UREADER_TTENGINE
struct Library  *TTEngineBase ;
#else
struct Library *UcodeBase ;
struct xxp_path *upath ;
#endif

void openlibs(void)
{
#if UREADER_TTENGINE
  TTEngineBase = OpenLibrary("ttengine.library", 0) ;
#else
  UcodeBase = OpenLibrary("UCODE:ucode.library", xxp_uver) ;
  if (UcodeBase != NULL)
  {
    upath = TLUstart(0, 0, 0) ;
  }
#endif
}

void closelibs(void)
{
#if UREADER_TTENGINE
  if (TTEngineBase != NULL)
  {
    CloseLibrary(TTEngineBase) ;
  }
#else
  if (UcodeBase != NULL)
  {
    if (upath != NULL)
    {
      TLUfinish(upath) ;
    }
    CloseLibrary(UcodeBase) ;
  }
#endif
}

#if UREADER_TTENGINE
/* utf-8 is included in this marvellous library, but there is no way to count characters */
/* This is not the *official* way, but it's my code 8) */

long utf8_charcount(UBYTE *src)
{
  long cnt = 0 ;

  while (src[0] != 0)
  {
    if (src[0] & 0x80)
    {
      if (src[0] & 0x40)
      {
        if (src[0] & 0x20)
        {
          if (src[0] & 0x10)
          {
            if (src[0] & 0x08)
            {
              src ++ ;
              cnt ++ ;
            }
            else
            {
              /* 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx */
              src += 4 ;
              cnt ++ ;
            }
          }
          else
          {
            /* 1110xxxx 10xxxxxx 10xxxxxx */
            cnt ++ ;
            src += 3 ;
          }
        }
        else
        {
          /* 110xxxx 10xxxxxx */
          cnt ++ ;
          src += 2 ; 
        }
      }
      else
      {
        /* bad */
        //cnt ++ ;
        src ++ ;
      }
    }
    else
    {
      /* 0xxxxxxx */
      cnt ++ ;
      src ++ ;
    }
  }

  return cnt ;
}

long utf16_charcount(UWORD *src)
{
  long cnt = 0 ;

  while (*src++ != 0)
  {
    cnt++ ;
  }

  return cnt ;
}


#else
#define REPLACEMENT_CHAR 0x0020

/* utf8 to utf16 conversion quick and dirty from scratch */
/* This is not the *official* way, but it's my code 8) */

void convUTF8toUTF16(
UBYTE *src,
UBYTE *dst,
ULONG maxsize
)
{ 
  ULONG value ;

  /* UTF-8 coding                                      */
  /* value         characters                          */
  /* 7 bits        0xxxxxxx                            */
  /* 8 to 11 bits  110xxxxx 10xxxxxx                   */
  /* 12 to 16 bits 1110xxxx 10xxxxxx 10xxxxxx          */
  /* 17 to 21 bits 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx */

  while ((src[0] != 0) && (maxsize > 0))
  {
    if (src[0] & 0x80)
    {
      if (src[0] & 0x40)
      {
        if (src[0] & 0x20)
        {
          if (src[0] & 0x10)
          {
            if (src[0] & 0x08)
            {
              /* bad */
              value = REPLACEMENT_CHAR ;
              src ++ ;
            }
            else
            {
              /* 11110 4 chars */
              if ((src[1] & 0x80) && !(src[1] & 0x40) &&
                  (src[2] & 0x80) && !(src[2] & 0x40) &&
                  (src[3] & 0x80) && !(src[3] & 0x40))
              {
                value = ((src[3] & 0x3f) <<  0) |
                        ((src[2] & 0x3f) <<  6) |
                        ((src[1] & 0x3f) << 12) |
                        ((src[0] & 0x07) << 18) ;
                src += 4 ;
              }
              else
              {
                /* bad */
                value = REPLACEMENT_CHAR ;
                src ++ ;
              }
            }
          }
          else
          {
            /* 1110 3 chars */
            if ((src[1] & 0x80) && !(src[1] & 0x40) &&
                (src[2] & 0x80) && !(src[2] & 0x40))
            {
              value = ((src[2] & 0x3f) <<  0) |
                      ((src[1] & 0x3f) <<  6) |
                      ((src[0] & 0x0f) << 12) ;  
              src += 3 ;
            }
            else
            {
              /* bad */
              value = REPLACEMENT_CHAR ;
              src ++ ;
            }
          }
        }
        else
        {
          /* 110 2 chars */
          if ((src[1] & 0x80) && !(src[1] & 0x40))
          {
            value = ((src[1] & 0x3f) << 0) |
                    ((src[0] & 0x1f) << 6) ;
            src += 2 ;
          }
          else
          {
            /* bad */
            value = REPLACEMENT_CHAR ;
            src ++ ;
          }
        }
      }
      else
      {
        /* 10 bad !! */
        value = REPLACEMENT_CHAR ;
        src ++ ;
      }
    }
    else
    {
      /* 7bits */
      value = *src++ ;
    }

    if (value > 0x0000ffff)
    {
      value = REPLACEMENT_CHAR ;
    }

    dst[0] = (value & 0xff00) >> 8 ;
    dst[1] = (value & 0x00ff) >> 0 ;
    dst     += 2 ;
    maxsize -= 2 ;
  }

  /* terminate the destination string */
  dst[0] = 0 ;
  dst[1] = 0 ;
}
#endif

struct UReaderData
{ 
  FILE *file ;

  BOOL cr ; /* CR + LF, LF */
  BOOL refresh ;
  int antialias ;

  int filetype ;
  int beginoffset ;
  int endoffset ;
  int offset ;

  UBYTE fgpen ;
  UBYTE bgpen ;
  UBYTE spacex ;
  UBYTE spacey ;
  UBYTE spacing ;
  UBYTE pad ; /* the following must be word aligned !! */

  UBYTE bigline[512+2] ;
  UBYTE spareline[512+2] ;
} ;

void usage(void)
{
#if UREADER_TTENGINE
  printf("Supposed to work with \"ttengine.library\" and a unicode true type font\n") ; 
  printf("Usage\n") ;
  printf("%s <filename>", "UReaderTTEngine") ;
#else
  printf("Supposed to work with \"ucode.library\"\n") ;
  printf("Usage\n") ;
  printf("%s <filename>\n", "UReader") ;
#endif
}

void wrefresh(
struct Window *wndw,
struct UReaderData *data
)
{
  int c ;
  int line = 0 ;
  WORD xpos, ypos ;
  WORD pos ;
  int offset ;
  WORD wint[4] ;
  WORD wbox[4] ;
  ULONG res ;
  WORD h ;

  if (data == NULL)
    return ;

  if (!data->refresh)
    return ;

  data->refresh = FALSE ;

  if (wndw != NULL)
  {
    /* xpos of top of interior */
    wint[0] = wndw->BorderLeft ;

    /* width of window interior */
    wint[2] = wndw->Width - (wint[0] + wndw->BorderRight) ;
 
    /* -ypos of top of window interior */  
    wint[1] = wndw->BorderTop ;

    /* height of window interior */
    wint[3] = wndw->Height - (wint[1] + wndw->BorderBottom) ;

    wbox[0] = 0 ;
    wbox[1] = 0 ;
    wbox[2] = wint[2] ;
    wbox[3] = wint[3] ;

    offset = data->offset ;
    fseek(data->file, offset, SEEK_SET) ;

    c     = 0 ;
    xpos  = 1 ;
    ypos  = 0 ;
    do
    {
      AnimPointer(wndw, line) ;

      pos = 0 ;
      data->bigline[0] = 0 ;
      data->bigline[1] = 0 ;
      do
      {
        /* get a character */
        switch (data->filetype)
        {
          case FILE_UNI :
          {
            c = fgetc(data->file) ;
            if (c != EOF)
            {
              offset++ ;
              data->bigline[pos+1] = c ;
               c = fgetc(data->file) ;
               if (c != EOF)
               {
                 offset++ ;
                 data->bigline[pos] = c ;
               }
            }
            break ;
          }

          case FILE_UNI_BE :
          {
            c = fgetc(data->file) ;
            if (c != EOF)
            {
              offset++ ;
              data->bigline[pos] = c ;
              c = fgetc(data->file) ;
              if (c != EOF)
              {
                offset++ ;
                data->bigline[pos+1] = c ;
              }
            }
            break ;
          }

          case FILE_UTF_8 :
          case FILE_TEXT  :
          {
            c = fgetc(data->file) ;
            if (c != EOF)
            {
              offset++ ;
              data->bigline[pos] = c ;
            }
            break ;
          }
        }

        /* store it of process commands */
        switch (data->filetype)
        {
          case FILE_UNI :
          case FILE_UNI_BE :
          {
            if ((data->bigline[pos]   == 0x00) &&
                (data->bigline[pos+1] == 0x0d))
            {
              /* c = EOL ; */ /* CR */
              data->bigline[pos]   = 0x00 ;
              data->bigline[pos+1] = 0x00 ;
              data->cr = TRUE ;
            }
            else if ((data->bigline[pos]   == 0x00) &&
                     (data->bigline[pos+1] == 0x0a))
            {
              c = EOL ; /* LF */
              data->bigline[pos]   = 0x00 ;
              data->bigline[pos+1] = 0x00 ;
            }
            else if ((data->bigline[pos]   == 0x00) &&
                     (data->bigline[pos+1] == 0x09))
            {
              /* TAB to do */
              data->bigline[pos]   = 0x00 ;
              data->bigline[pos+1] = 0x20 ;
              pos += 2 ;
              data->bigline[pos]   = 0x00 ;
              data->bigline[pos+1] = 0x20 ;
              pos += 2 ;
              data->bigline[pos]   = 0x00 ;
              data->bigline[pos+1] = 0x20 ;
              pos += 2 ;
            }    
            else if (0 &&
                     (data->bigline[pos]   == 0x00) &&
                     (data->bigline[pos+1] == 0x20))
            {
              data->bigline[pos]   = 0x00 ;
              data->bigline[pos+1] = 0xa0 ;
            }
            else
            {
              pos += 2 ;
            }
            break ;
          }

          case FILE_UTF_8 :
          case FILE_TEXT :
          { 
            if (data->bigline[pos] == 0x0d)
            {
              /* c = EOL ; */ /* CR */
              data->bigline[pos] = 0x00 ;
            }
            else if (data->bigline[pos] == 0x0a)
            {
              c = EOL ; /* LF */
              data->bigline[pos] = 0x00 ;
            }
            else if (data->bigline[pos] == 0x09)
            {
              /* TAB to do */
              data->bigline[pos] = 0x20 ;
              pos++ ;
              data->bigline[pos] = 0x20 ;
              pos++ ;
              data->bigline[pos] = 0x20 ;
              pos++ ;
            }
            else if (0 &&
                     (data->bigline[pos] == 0x20))
            {
              
            }
            else
            {
              pos += 1 ;
            }
            break ;
          }

          default :
          {
            c = EOF ;
            break ;
          }
        }

        if (c == EOF)
        {
          data->bigline[pos]   = 0x00 ;
          data->bigline[pos+1] = 0x00 ;
        }
      } while ((c != EOF) && (c != EOL) && (pos < sizeof(data->bigline))) ;

      if (pos > 0)
      {
#if UREADER_TTENGINE
        /* no conversion, ttengine will do it */
#else
        if (data->filetype == FILE_UTF_8)
        {
          memcpy(data->spareline, data->bigline, sizeof(data->bigline)) ;
          convUTF8toUTF16(data->spareline, data->bigline, sizeof(data->bigline) - 2) ;
        }
#endif
      }

      if (pos > 0)
      {
        /* shows the line on window */

#if UREADER_TTENGINE
        if (TTEngineBase != NULL)
        {
          int len = 0 ;
          int encoding = 0 ;
          ULONG fh = 0 ;

          switch (data->filetype)
          {
            case FILE_TEXT :
            {
              len = strlen(data->bigline) ;
              encoding = TT_Encoding_Default ;
              break ;
            }

            case FILE_UTF_8 :
            {
              len = utf8_charcount(data->bigline) ;
              encoding = TT_Encoding_UTF8 ;
              break ;
            }

            case FILE_UNI :
            case FILE_UNI_BE :
            {
              len = utf16_charcount((UWORD*)data->bigline) ;
              encoding = TT_Encoding_UTF16_BE ;
              break ;
            }
          }

          TT_SetAttrs(wndw->RPort,
                      TT_Window, (ULONG)wndw,
                      TT_Antialias, data->antialias,
                      TT_Encoding, encoding,
                      TAG_END) ;
          Move(wndw->RPort, xpos, ypos + wndw->BorderTop) ;
          SetAPen(wndw->RPort, data->fgpen) ;
          SetBPen(wndw->RPort, data->bgpen) ;
          SetDrMd(wndw->RPort, JAM2) ;

          TT_Text(wndw->RPort, data->bigline, len) ;

          TT_GetAttrs(wndw->RPort,
                      TT_FontHeight, &fh,
                      TAG_END) ;

          if (fh <= 0)
          {
            fh = 11 ;
          }

          h = fh + data->spacey ;
        }
        else
        {
          switch (data->filetype)
          {
            case FILE_TEXT :
            {
              Move(wndw->RPort, xpos, ypos + wndw->BorderTop) ;
              SetAPen(wndw->RPort, data->fgpen) ;
              SetBPen(wndw->RPort, data->bgpen) ;
              SetDrMd(wndw->RPort, JAM2) ;
              Text(wndw->RPort, data->bigline, strlen(data->bigline)) ;
              h = wndw->RPort->TxHeight ;
              if (h <= 0)
              {
                h = 11 ;
              }
              h += data->spacey ;
              break ;
            }

            default :
            {
              h = 11 ;
              break ;
            }
          }
        }
#else
        switch (data->filetype)
        {
          case FILE_TEXT :
          {
            Move(wndw->RPort, xpos, ypos + wndw->BorderTop) ;
            SetAPen(wndw->RPort, data->fgpen) ;
            SetBPen(wndw->RPort, data->bgpen) ;
            SetDrMd(wndw->RPort, JAM2) ;
            Text(wndw->RPort, data->bigline, strlen(data->bigline)) ;
            h = wndw->RPort->TxHeight + data->spacey ;
            break ;
          }

          default :
          {
            ULONG flags = data->spacing ;
            UBYTE fgpen = data->fgpen ;
            UBYTE bgpen = data->bgpen ;
            UBYTE space = data->spacex ;
 
            if ((UcodeBase != NULL) && (upath != NULL))
            {
              res = TLUstring( xpos,
                               ypos,
                               &wbox, /* wbox                     */
                               &wint, /* wint                     */
                               flags,
                               fgpen,
                               bgpen,
                               space, /* character spacing */
                               upath,
                               wndw->RPort, /* wndw's rastport */
                               &data->bigline[0],
                               NULL ) ;
              /* in res we have:      */
              /* bits 0-15  width     */
              /* bits 16-23 descender */
              /* bits 24-31 ascender  */
              /* h = ((res & 0x00ff0000) >> 16) + ((res & 0xff000000) >> 24) ; */

              h = ((res & 0x00ff0000) >> 16) + upath->xxp_uwbl ;
             
              if (h <= 0)
              {
                h = 11 ;
              }
              h += data->spacey ;
            }
            break ;
          }
        }
#endif
      }
      
      ypos += h ;
      line ++ ;
    } while ((c != EOF) && (ypos < wndw->Height)) ;

    ChangePointer(wndw, CURSOR_PREFS) ;
    data->endoffset = offset ;
  }
}

/* clears the window */
void wclear(
struct Window *wndw,
struct UReaderData *data
)
{
  SetAPen(wndw->RPort, data->bgpen) ;
  RectFill(wndw->RPort, 0, 0, wndw->Width, wndw->Height) ;
}

UBYTE fontname[256] ;
int fontsize    = 11 ;
int spacing     = 11 ;
int spacex      = 1 ;
int spacey      = 1 ;
int fgpen       = 1 ;
int bgpen       = 0 ;
#if UREADER_TTENGINE
UWORD fontstyle = 0 ;
#else
UWORD fontstyle = TLU_STYLE_SS ;
#endif

void dotooltypes(struct DiskObject *dskobj)
{
  UBYTE *n = NULL ;

  n = FindToolType(dskobj->do_ToolTypes, "FONTNAME") ;
  if (n != NULL)
  {
    strcpy(fontname, n) ;
  }

  n = FindToolType(dskobj->do_ToolTypes, "FONTSIZE") ;
  if (n != NULL)
  {
    fontsize = atoi(n) ;
    if (fontsize <= 0) fontsize = 11 ;
  }

  n = FindToolType(dskobj->do_ToolTypes, "FONTSTYLE") ;
  if (n != NULL)
  {
    if (strlen(n)==2)
    {
      fontstyle = (n[0] << 8) | (n[1] << 0) ;
    }
  }

  n = FindToolType(dskobj->do_ToolTypes, "SPACING") ;
  if (n != NULL)
  {
    spacing = atoi(n) ;
    if (spacing <   0) spacing = 0 ;
    if (spacing > 127) spacing = 127 ;
  }

  n = FindToolType(dskobj->do_ToolTypes, "SPACEX") ;
  if (n != NULL)
  {
    spacex = atoi(n) ;
  }

  n = FindToolType(dskobj->do_ToolTypes, "SPACEY") ;
  if (n != NULL)
  {
    spacey = atoi(n) ;
  }

  n = FindToolType(dskobj->do_ToolTypes, "FGPEN") ;
  if (n != NULL)
  {
    fgpen = atoi(n) ;
  }

  n = FindToolType(dskobj->do_ToolTypes, "BGPEN") ;
  if (n != NULL)
  {
    bgpen = atoi(n) ;
  }
}

int main(int argc, char *argv[])
{
  unsigned char header[5] ;
  char ctype[40] ;
  char wtitle[80] ;
  int c ;
  int i ;
  struct UReaderData *data = NULL ;
  struct DiskObject *dskobj = NULL ;
  struct Window *wndw ;
  char *filename = NULL ;
  struct Message *msg ;
  struct IntuiMessage imsg ;
  BOOL loop ;
#if UREADER_TTENGINE
  APTR font = NULL ;
#endif
  if (((struct Library *)IntuitionBase)->lib_Version < 36)
  {
    printf("Sorry, kickstart v36 and higher required\n") ;
    exit(0) ;
  }

  /* strcpy(fontname, "FONTS:l_10646.ttf") ; */
  strcpy(fontname, "FONTS:code2000.ttf") ;

  fontsize = 11 ;

  if (argc == 0)
  {
    if (_WBenchMsg != NULL)
    {
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
      else
      {
        usage() ;
        exit(0) ;
      }
    }
  }
  else
  {
    if (argc <= 1)
    {
      usage() ;
      exit(0) ;
    }

    filename = argv[1] ;
  }

  openlibs() ;

  data = malloc(sizeof(struct UReaderData)) ;
  if (data != NULL)
  {
    data->file = fopen(filename, "rb") ;
    if (data->file != NULL)
    {
      i = 0 ;
      c = 0 ;
      for (i = 0; i < sizeof(header); i++) 
      {
        header[i] = 0 ;

        if (c != EOF)
        {
          c = fgetc(data->file) ;
          if (c != EOF)
          {
            header[i] = c ;
          }
        }
      }

      ctype[0] = 0 ;
      data->filetype    = FILE_UNKNOWN ;
      data->beginoffset = 0 ;

      if ((header[0] == 0xff) &&
          (header[1] == 0xfe))
      {
        strcpy(ctype, "unicode") ;
        data->filetype = FILE_UNI ;
        data->beginoffset = 2 ;
      }
      else if ((header[0] == 0xfe) &&
               (header[1] == 0xff))
      {
        strcpy(ctype, "unicode big endian") ;
        data->filetype = FILE_UNI_BE ;
        data->beginoffset = 2 ;
      }
      else if ((header[0] == 0xef) &&
               (header[1] == 0xbb) &&
               (header[2] == 0xbf))
      {
        strcpy(ctype, "UTF-8") ;
        data->filetype = FILE_UTF_8 ;
        data->beginoffset = 3 ;
      }
      else
      {
        strcpy(ctype, "TEXT") ;
        data->filetype = FILE_TEXT ;
        data->beginoffset = 0 ;
      }

      if (data->filetype != FILE_UNKNOWN)
      {
        sprintf(wtitle, "%-30.30s - %s file", filename, ctype) ;
        wndw = wopen(wtitle) ;
        if (wndw == NULL)
        {
          printf("can't open window\n") ;
        }
        else
        {
          ChangePointer(wndw, CURSOR_BUSY) ;

          data->offset    = data->beginoffset ;
          data->fgpen     = fgpen ;
          data->bgpen     = bgpen ;
          data->spacex    = spacex ;
          data->spacey    = spacey ;
          data->spacing   = spacing ;
          data->antialias = 2 /* TT_Antialias_On */ ;
          data->refresh   = TRUE ;

#if UREADER_TTENGINE
          if (TTEngineBase != NULL)
          {
            UBYTE text[256] ;

            SetAPen(wndw->RPort, data->bgpen) ;
            RectFill(wndw->RPort, 0, 0, wndw->Width, wndw->Height) ;

            sprintf(text, "%s %ld.%ld",
                    TTEngineBase->lib_Node.ln_Name,
                    TTEngineBase->lib_Version,
                    TTEngineBase->lib_Revision) ;

            Move(wndw->RPort, 10, 10) ;
            SetAPen(wndw->RPort, data->fgpen) ;
            SetBPen(wndw->RPort, data->bgpen) ;
            SetDrMd(wndw->RPort, JAM2) ;
            Text(wndw->RPort, text, strlen(text)) ;

            sprintf(text, "Loading font... please wait") ;
            Move(wndw->RPort, 10, 20) ;
            Text(wndw->RPort, text, strlen(text)) ;

            font = TT_OpenFont(TT_FontFile, (ULONG)fontname,
                               TT_FontSize, (ULONG)fontsize,
                               TAG_END) ;
            if (font == NULL)
            {
              sprintf(text, "can't open font \"%s\" size %ld",
                      fontname, 
                      fontsize ) ;
            }
            else
            {
              sprintf(text, "Font \"%s\" size %ld loaded",
                      fontname, 
                      fontsize ) ;
            }
            
            Move(wndw->RPort, 10, 20) ;
            Text(wndw->RPort, text, strlen(text)) ;

            if (!TT_SetFont(wndw->RPort, font))
            {
              sprintf(text, "TT_SetFont failed") ;

              Move(wndw->RPort, 10, 30) ;
              Text(wndw->RPort, text, strlen(text)) ;

              TT_CloseFont(font) ;
              font = NULL ;
            }
          }
          else
          {
            UBYTE text[256] ;

            sprintf(text, "TTEngine.library %ld needed", 6) ;

            Move(wndw->RPort, 10, 10) ;
            SetAPen(wndw->RPort, data->fgpen) ;
            SetBPen(wndw->RPort, data->bgpen) ;
            SetDrMd(wndw->RPort, JAM2) ;
            Text(wndw->RPort, text, strlen(text)) ;

            Delay(50) ;
          }
#else
          if ((UcodeBase != NULL) && (upath != NULL))
          {
            UBYTE text[256] ;

            sprintf(text, "%s %ld.%ld",
                    UcodeBase->lib_Node.ln_Name,
                    UcodeBase->lib_Version,
                    UcodeBase->lib_Revision) ;

            Move(wndw->RPort, 10, 10) ;
            SetAPen(wndw->RPort, data->fgpen) ;
            SetBPen(wndw->RPort, data->bgpen) ;
            SetDrMd(wndw->RPort, JAM2) ;
            Text(wndw->RPort, text, strlen(text)) ;

            Delay(10) ;

            TLUset(fontsize,
                   TLU_WIDTH_NORMAL,
                   fontstyle,
                   1,
                   0,
                   0,
                   upath,
                   NULL,
                   NULL,
                   NULL) ;
          }       
#endif
          data->refresh = TRUE ;
          wclear(wndw, data) ;
          ChangePointer(wndw, CURSOR_PREFS) ;

          loop = TRUE ;
          do
          {
            wrefresh(wndw, data) ;
            
            WaitPort(wndw->UserPort) ;
            do
            {
              msg = GetMsg(wndw->UserPort) ;
              if (msg != NULL)
              {
                imsg = *(struct IntuiMessage *)msg ;
                ReplyMsg(msg) ;

                switch (imsg.Class)
                {
                  case IDCMP_CLOSEWINDOW :
                  {
                    loop = FALSE ;
                    break ;
                  }

                  case IDCMP_RAWKEY :
                  {
                    //printf("%02x\n", imsg.Code) ;
                    switch(imsg.Code)
                    {
                      case 0x41 : /* backspace */
                      {
                        wclear(wndw, data) ;
                        data->offset  = data->beginoffset ;
                        data->refresh = TRUE ;
                        break ;
                      }

                      case 0x40 : /* space */
                      case 0x44 : /* cr */
                      {
                        wclear(wndw, data) ;
                        data->offset  = data->endoffset ;
                        data->refresh = TRUE ;
                        break ;
                      }
                    }
                    break ;
                  }

                  case IDCMP_NEWSIZE :
                  case IDCMP_REFRESHWINDOW :
                  {
                    wclear(wndw, data) ;
                    data->refresh = TRUE ;
                    break ;
                  }
                }
              }
            } while (msg != NULL) ;
          } while (loop) ;

#if UREADER_TTENGINE
          if (TTEngineBase != NULL)
          {
            TT_DoneRastPort(wndw->RPort) ;
          }

          if (font != NULL)
          {
            TT_CloseFont(font) ;
            font = NULL ;
          }
#endif
          wclose(wndw) ;
        }
      }

      fclose(data->file) ;
    }
    free(data) ;
  }

  closelibs() ;
}
