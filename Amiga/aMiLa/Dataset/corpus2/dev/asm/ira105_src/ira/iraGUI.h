/*********************************************/
/*                                           */
/*       Designer (C) Ian OConnor 1994       */
/*                                           */
/*      Designer Produced C header file      */
/*                                           */
/*********************************************/



#define IRAPref0FirstID 0
#define Win0_Gad0 0
#define Win0_Gad1 1
#define Win0_Gad2 2
#define IRAPref0_Gad3 3
#define IRAPref0_Gad4 4
#define IRAPref0_Gad5 5
#define IRAPref0_Gad6 6
#define IRAPref0_Gad7 7
#define IRAPref0_Gad10 8
#define IRAPref0_Gad11 9
#define IRAPref0_Gad13 10
#define IRAPref0_Gad14 11
#define IRAPref0_Gad15 12
#define IRAPref0_Gad16 13
#define IRAPref0_Gad17 14
#define IRAPref0_Gad18 15
#define IRAPref0_Gad19 16
#define IRAPref0_Gad20 17
#define  Win0_Gad0String0   0
#define  Win0_Gad0String1   1
#define  Win0_Gad0String2   2
#define  Win0_Gad0String3   3
#define  Win0_Gad0String4   4
#define  Win0_Gad0String5   5
#define  Win0_Gad1String0   6
#define  Win0_Gad1String1   7
#define  Win0_Gad2String0   8
#define  Win0_Gad2String1   9
#define  IRAPref0_Gad15String0   10
#define  IRAPref0_Gad15String1   11
#define  IRAPref0_Gad15String2   12
#define  IRAPref0_Gad15String3   13
#define  IRAPref0_Gad15String4   14
#define  IRAPref0_Gad15String5   15
#define  IRAPref0_Gad15String6   16
#define  IRAPref0_Gad15String7   17
#define  Win0_Gad0String   18
#define  Win0_Gad1String   19
#define  Win0_Gad2String   20
#define  IRAPref0_Gad3String   21
#define  IRAPref0_Gad4String   22
#define  IRAPref0_Gad5String   23
#define  IRAPref0_Gad6String   24
#define  IRAPref0_Gad7String   25
#define  IRAPref0_Gad10String   26
#define  IRAPref0_Gad11String   27
#define  IRAPref0_Gad13String   28
#define  IRAPref0_Gad14String   29
#define  IRAPref0_Gad15String   30
#define  IRAPref0_Gad16String   31
#define  IRAPref0_Gad17String   32
#define  IRAPref0_Gad18String   33
#define  IRAPref0_Gad19String   34
#define  IRAPref0_Gad20String   35
#define  IRAPref0Title   36

extern struct TextAttr topaz800;
extern struct Gadget *IRAPref0Gadgets[18];
extern struct Gadget *IRAPref0GList;
extern struct Window *IRAPref0;
extern APTR IRAPref0VisualInfo;
extern APTR IRAPref0DrawInfo;
extern ULONG IRAPref0GadgetTags[];
extern UWORD IRAPref0GadgetTypes[];
extern struct NewGadget IRAPref0NewGadgets[];
extern struct Library *DiskfontBase;
extern struct Library *GadToolsBase;
extern struct GfxBase *GfxBase;
extern struct IntuitionBase *IntuitionBase;
extern struct LocaleBase *LocaleBase;
extern struct Catalog *base_Catalog;

extern void RendWindowIRAPref0( struct Window *Win, void *vi );
extern int OpenWindowIRAPref0( void );
extern void CloseWindowIRAPref0( void );
extern int OpenLibs( void );
extern void CloseLibs( void );
extern int OpenDiskFonts( void );
extern STRPTR GetString(LONG strnum);
extern void ClosebaseCatalog(void);

