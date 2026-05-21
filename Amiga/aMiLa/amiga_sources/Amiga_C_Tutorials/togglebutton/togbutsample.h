/*********************************************/
/*                                           */
/*       Designer (C) Ian OConnor 1994       */
/*                                           */
/*      Designer Produced C header file      */
/*                                           */
/*********************************************/



#define Win0FirstID 0
#define tAbout 0
#define bDegistir 1
#define  bDegistirString   0
#define  Win0Title   1

extern struct TextAttr topaz800;
extern struct Gadget *Win0Gadgets[2];
extern struct Gadget *Win0GList;
extern struct Window *Win0;
extern APTR Win0VisualInfo;
extern APTR Win0DrawInfo;
extern UWORD Win0GadgetTypes[];
extern struct NewGadget Win0NewGadgets[];
extern struct Library *DiskfontBase;
extern struct Library *GadToolsBase;
extern struct GfxBase *GfxBase;
extern struct IntuitionBase *IntuitionBase;
extern struct LocaleBase *LocaleBase;
extern struct Image aboutn;
extern struct Image aboutp;
extern struct Catalog *base_Catalog;

extern void RendWindowWin0( struct Window *Win, void *vi );
extern int OpenWindowWin0( void );
extern void CloseWindowWin0( void );
extern int OpenLibs( void );
extern void CloseLibs( void );
extern int MakeImages( void );
extern void FreeImages( void );
extern STRPTR GetString(LONG strnum);
extern void ClosebaseCatalog(void);
extern void OpenbaseCatalog(struct Locale *loc, STRPTR language);

