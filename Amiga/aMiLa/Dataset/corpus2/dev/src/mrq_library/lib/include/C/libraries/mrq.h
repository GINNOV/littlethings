/* WARNING!!! I'm not sure if all C includes for mrq.library v1.12 */
/* are error free!!! I'm still working on it. Be careful!          */

#ifndef LIBRARIES_MISTERQ_H
#define LIBRARIES_MISTERQ_H 1

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef LIBRARIES_REQTOOLS_H
#include <libraries/reqtools.h>
#endif

#define DOSLIB_ERROR  0x01
#define GFXLIB_ERROR  0x02
#define REQLIB_ERROR  0x04
#define INTLIB_ERROR  0x08
#define ASLLIB_ERROR  0x10
#define CYBERLIB_EROR 0x20

#define AGA_DISPLAY   0xf000
#define CGX_DISPLAY   0xff00

struct MisterQBase
{
   struct DosLibrary *DOSBase;               // adresy bazowe otwartych bibliotek
   struct GfxBase *GfxBase;
   struct IntuitionBase *IntuitionBase;
   struct ReqToolsBase *ReqToolsBase;
   struct Library *AslBase;
   struct Library *CyberGfxBase;

   LONG _szer;                           // szerokoôê ekranu
   LONG _wys;                            // wysokoôê ekranu
   LONG chmaxx;                          // szerokoôê okna wyôwietlania
   LONG chmaxy;                          // wysokoôê okna wyôwietlania
   UWORD ChunkyMode;                     // tryb pracy C2P w zaleûnoôêi od koôci GFX (AGA_DISPLAY,CGX_DISPLAY)
   struct RastPort *s_RastPort;          // rastport ekranu otwartego za pomocâ MOpenScreen()
   struct Screen *WB_Base;               // adres struktury Screen ekranu WB. Pole wypeînia procedura MOpenScreen()
   struct ViewPort *WB_ViewPort;         // adres struktury ViewPort ekranu WB. Pole wypeînia procedura MOpenScreen()
   struct Screen *s_ScreenBase;          // adres struktury Screen ostatnio otwartego ekranu. Pole wypeînia procedura MOpenScreen()

   PLANEPTR _bitplan0;                   // wskaúniki na bitplany otwartego ekranu.
   PLANEPTR _bitplan1;                   // Pola wypeînia procedura MOpenScreen()
   PLANEPTR _bitplan2;           
   PLANEPTR _bitplan3;           
   PLANEPTR _bitplan4;           
   PLANEPTR _bitplan5;           
   PLANEPTR _bitplan6;           
   PLANEPTR _bitplan7;           

   LONG LibraryError;                  // która z otwieranych bibliotek przez MisterQInit() sië nie otwarîa.
   LONG BestModeTags;                  // !private!   Pole wypeînia procedura MOpenScreen()
   LONG ScreenTags;                    // !private! (Tagi otwieranego ekranu)  Pole wypeînia procedura MOpenScreen()
   struct BitMap *BitMapSTR;           // adres struktury Bitmap ostatnio otwartego ekranu. Pole wypeînia procedura MOpenScreen()
   struct FileRequest *FileRequest;    // adres struktury FileRequest ostatnio otwartego requestera do wyboru plików                                                

   STRPTR _FileName;                   // adres îaïcucha tekstowego - nazwy pliku
   STRPTR _DirName;                    // adres îaïcucha tekstowego - nazwy katalogu
   STRPTR _Path;                       // adres îaïcucha tekstowego - peînej ôcieûki dostëpu wraz z plikiem

   LONG _FileSize;                     // dîugoôê ostatnio wczytanego pliku
   APTR _FileAddr;                     // adres ostatnio wczytanego pliku
   STRPTR tabdec1;                     // adres ciâgu ASCII liczby dziesiëtnej z zerami - zakres +/- 2 miliardy  
   STRPTR tabdec2;                     // adres ciâgu ASCII liczby dziesiëtnej bez pierwszych zer, zakres ten sam  
   STRPTR tabhex1;                     // adres ciâgu ASCII liczby szesnastkowej.  
   STRPTR tabroman1;                   // adres ciâgu ASCII liczby rzymskiej.
   WORD _kolor0;                       // kolor 0 tekstu patrz funkcja WyswTXT
   WORD _kolor1;                       // kolor 1 tekstu patrz funkcja WyswTXT                        

   struct Window *s_WinBase;           // adres struktury Window otwartego okna na ostatnio otwartym screenie - patrz MOpenScreen()
   struct Library *GadToolsBase;       // adres bazowy biblioteki gadtools
   APTR Screen_Tags;                   // opcjonalnie adres Tagów dla nowo otwieranego ekranu - patrz MOpenScreen()
   WORD Precc;                         // wîâczenie 'precyzyjnej (do 1 pixela) procedury C2P
   struct Window *WindowTags;          // !Private!  (wskaúnik na tymczasowâ strukturë window)
   struct Screen *ScrSTR;              // !Private!  (wskaúnik na tymczasowâ strukturë Screen)
   APTR buff1;                         // !Private!  (wskaúnik na osiem bajtów dla C2P)


};

struct MScreen
{
   struct Window *s_Win_Base;      // adres struktury window otwartego okna backdrop
   struct Screen *s_ScreenBase;    // adres struktury screen otwartego ekranu
   struct RastPort *s_RastPort;    // adres rastportu otwartego ekranu
   struct BitMap *s_BitMap_STR;    // adres struktury bitmap otwartego ekranu
   LONG  s_BestModeTags;           // !private!
   LONG s_ScreenTags;              // !private!
   PLANEPTR s_bitplan0;            // adresy bitplanów
   PLANEPTR s_bitplan1;
   PLANEPTR s_bitplan2;
   PLANEPTR s_bitplan3;
   PLANEPTR s_bitplan4;
   PLANEPTR s_bitplan5;
   PLANEPTR s_bitplan6;
   PLANEPTR s_bitplan7;

   LONG s_ModeID;                   // tryb otwartego ekranu
   struct MsgPort *s_UserPort;      // userport okna backdrop na ekranie
   struct ViewPort *s_ViewPort;     // ViewPort otwartego ekranu
   APTR s_RasInfo;                  // RasInfo otwartego ekranu
   LONG s_Height;                   // wysokoôê otwartego ekranu
   LONG s_Width;                    // szerokoôê otwartego ekranu
   LONG s_OffSet;                   // odstëp pomiëdzy dwoma ekranami (w trybie double buffer)
   APTR s_WindowTags;               // !private! (wskaúnik na tagi dla OpenWindowTagList() )

};

#endif  /* !MISTERQ_MISTERQ_H */
