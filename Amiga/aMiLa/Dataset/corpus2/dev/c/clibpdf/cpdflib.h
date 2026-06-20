/* cpdflib.h -- C language API definitions for ClibPDF library
 * Copyright (C) 1998 FastIO Systems, All Rights Reserved.
 * For conditions of use, license, and distribution, see LICENSE.txt or LICENSE.pdf.
------------------------------------------------------------------------------------
*/


#ifndef __CLIBPDF_H__
#define __CLIBPDF_H__

#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


#ifdef _WIN32
/* 4305 is loss of precision, e.g., by assigning double to float.
   but I am tired of VC++ generating errors on OK things like:
   float a = 1.23;
   Somehow, VC++ thinks 1.23 is 'const double'
   So, here is a pragma to turn off that waring until I find a
   switch that makes it treat 1.23 as float as well.
*/
#pragma warning (disable: 4305 4244)
/* #pragma warning (disable: 4244) */

#endif

/* Change these parameters if you are using ClibPDF to create REALLY large PDF files
   all the time.  These are default values, but may be changed by calling
   cpdf_setDocumentLimits() before cpdf_open().
*/
#define NMAXOBJECTS 2000        /* maximum number of objects for XREF */
#define NMAXFONTS   100     /* maximum number of fonts */
#define NMAXPAGES   100     /* maximum number of pages */
#define NMAXIMAGES  100     /* maximum number of different images */
#define NMAXANNOTS  100     /* maximum number of annotations and links */

/* --------------------------------------------------------------------------------- */
#ifndef YES
  #define YES       1
#endif
#ifndef NO
  #define NO        0
#endif

/* for use with cpdf_createTimeAxis(), and  cpdf_createTimeAxis() */
#define LINEAR      0
#define LOGARITHMIC 1
#define TIME        2

/* for use with cpdf_setTimeAxisNumberFormat() */
#define MONTH_NUMBER    0
#define MONTH_NAME  1
#define YEAR_FULL   0
#define YEAR_4DIGIT 0
#define YEAR_2DIGIT 1

/* mesh interval and offset parameters for cpdf_setLinearMeshParams() */
#define X_MESH      0
#define Y_MESH      1

/* for cpdf_init() */
#define PORTRAIT    0
#define LANDSCAPE   1
#define inch        72.0
#define cm      28.3464566929
#define POINTSPERINCH   72.0        /* number of points per inch */
#define POINTSPERCM 28.3464566929   /* number of points per cm */
#define POINTSPERMM 2.83464566929   /* number of points per mm */

/* Conv factor to get char height of char '0' from font size.
   0.676 for Times-Roman, 0.688 for Times-Bold, 0.703 for Helvetica, 0.71 for Helvetica-Bold.
   This does vary from one char to another.  The number below is a compromize value.
*/
#define FONTSIZE2HEIGHT     0.7

/* standard page sizes in points */
#define LETTER          "0 0 612 792"
#define LEGAL           "0 0 612 1008"
#define A4          "0 0 595 842"
#define B5          "0 0 499 708"
#define C5          "0 0 459 649"
#define DL          "0 0 312 624"
#define EXECUTIVE       "0 0 522 756"
#define COMM10          "0 0 297 684"
#define MONARCH         "0 0 279 540"
#define FILM35MM        "0 0 528 792"

#define DEFAULT_PAGESIZE    LETTER

/* Log axis tick/number selector masks */
#define LOGAXSEL_1      0x0002
#define LOGAXSEL_13     0x000A
#define LOGAXSEL_125        0x0026
#define LOGAXSEL_12468      0x0156
#define LOGAXSEL_12357      0x00AE
#define LOGAXSEL_123456789  0x03FE
#define LOGAXSEL_MIN        0x0001
#define LOGAXSEL_MAX        0x0400

/* Text Rendering Mode: cpdf_setTextRenderingMode() */
#define TEXT_FILL       0
#define TEXT_STROKE     1
#define TEXT_FILL_STROKE    2
#define TEXT_INVISIBLE      3
#define TEXT_FILL_CLIP      4
#define TEXT_STROKE_CLIP    5
#define TEXT_FILL_STROKE_CLIP   6
#define TEXT_CLIP       7

/* Text centering mode: cpdf_rawTextAligned(), cpdf_textAligned() */
#define TEXTPOS_LL  0   /* lower left */
#define TEXTPOS_LM  1   /* lower middle */
#define TEXTPOS_LR  2   /* lower right */
#define TEXTPOS_ML  3   /* middle left */
#define TEXTPOS_MM  4   /* middle middle */
#define TEXTPOS_MR  5   /* middle right */
#define TEXTPOS_UL  6   /* upper left */
#define TEXTPOS_UM  7   /* upper middle */
#define TEXTPOS_UR  8   /* upper right */

/* For in-line image placement function: cpdf_placeInLineImage() */
#define IMAGE_MASK  0
#define CS_GRAY     1
#define CS_RGB      2
#define CS_CMYK     3

/* For cpdf_pointer() */
#define PTR_RIGHT   0
#define PTR_DOWN    1
#define PTR_LEFT    2
#define PTR_UP      3

/* Page transition types: cpdf_setPageTransition() */
#define TRANS_NONE  0
#define TRANS_SPLIT 1
#define TRANS_BLINDS    2
#define TRANS_BOX   3
#define TRANS_WIPE  4
#define TRANS_DISSOLVE  5
#define TRANS_GLITTER   6


typedef enum {
    SECOND,
    MINUTE,
    HOUR,
    DAY,
    MONTH,
    YEAR
} CPDFtimeTypes;

typedef enum {
    CPDF_Root,
    CPDF_Catalog,
    CPDF_Outlines,
    CPDF_Pages,
    CPDF_Page,
    CPDF_Contents,
    CPDF_ProcSet,
    CPDF_Annots,
    CPDF_Info,
} CPDFobjTypes;


/* 2 x 3 matrix for CTM */
typedef struct {
    float a; float b;       /*  a   b   0  */
    float c; float d;       /*  c   d   0  */
    float x; float y;       /*  x   y   1  */
} CPDFctm;


typedef struct {
    int objIndex;
    char *name;
    char *baseFont;
    char *encoding;
} CPDFfontInfo;

typedef struct {
    int pageMode;   /* This really belongs directly to Catalog obj, but here for convenience */
    int hideToolbar;    /* when YES, tool bar in viewer will be hidden */
    int hideMenubar;    /* when YES, menu bar in viewer will be hidden */
    int hideWindowUI;   /* when YES, GUI elements in doc window will be hidden */
    int fitWindow;  /* when YES, instructs the viewer to resize the doc window to the page size */
    int centerWindow;   /* when YES, instructs the viewer to move the doc window to the screen's center */
    int pageLayout; /* Specifies 1-page display or two-page columnar displays */
    int nonFSPageMode;  /* Specifies pageMode coming out of the full-screen display mode */
} CPDFviewerPrefs;

/* Values for pageMode and nonFSPageMode */
#define PM_NONE     0   /* default - neither outline nor thumbnails will be visible */
#define PM_OUTLINES 1   /* open the doc with outline visible */
#define PM_THUMBS   2   /* open the doc with thumbnails visible */
#define PM_FULLSCREEN   3   /* open the doc in full screen mode */

#define PL_SINGLE   0   /* default - one page at a time */
#define PL_1COLUMN  1   /* display pages in one column */
#define PL_2LCOLUMN 2   /* 2-column display, with odd pages on the left */
#define PL_2RCOLUMN 3   /* 2-column display, with odd pages on the right */


/* Image file type */
/* Only Baseline JPEG image files are supported currently. */
#define JPEG_IMG        0
#define G4FAX_IMG       1
#define G3FAX_IMG       2
#define TIFF_IMG        3
#define GIF_IMG         4

typedef struct {
    int objIndex;
    char *name;     /* Im0, Im1, etc */
    int type;       /* image file type */
    int process;        /* M_SOF# -- jpeg process  */
    int width;      /* # of pixels horizontal */
    int height;     /* # of pixels vertical */
    int ncomponents;    /* # of color components */
    int bitspersample;  /* bits per sample */
    long filesize;      /* # of bytes in file */
    char *filepath;     /* path to image file */
} CPDFimageInfo;

/* Annotation, hyperlink info object */
#define ANNOT_TEXT  0
#define ANNOT_LINK  1

typedef struct {
    int objIndex;
    int type;       /* annotation or link type */
    float xLL;
    float yLL;
    float xUR;
    float yUR;          /* annotation box */
    char *content_link;     /* annotation text content or link URI specification */
    char *annot_title;      /* annotation box title */
} CPDFannotInfo;

typedef struct {
    unsigned long   magic_number;   /* to check stream validity */
    char  *buffer;      /* pointer to buffer's beginning */
    /* char  *buf_ptr; */       /* current buffer pointer */
    int   count;        /* # of bytes currently in buffer */
    int   bufSize;      /* Total size of buffer -- bufSize expands as needed. */
} CPDFmemStream;


/* Structure for outline (bookmark) linked list */
typedef struct _cpdf_outline CPDFoutlineEntry;
struct _cpdf_outline {
    int objIndex;       /* serialized object index (for xref) */
    int count;          /* total number of sub entries (descendants) */
    int dest_page;      /* page number set by cpdf_pageInit() */
    int open;           /* if zero, all subsections under this entry will be closed */
    char *dest_attribute;   /* Destination spec after "3 0 R" part */
    char *title;        /* title string */
    CPDFoutlineEntry *parent;   /* pointer to parent outline entry */
    CPDFoutlineEntry *prev; /* pointer to previous outline entry */
    CPDFoutlineEntry *next; /* pointer to next outline entry */
    CPDFoutlineEntry *first;    /* pointer to first outline entry */
    CPDFoutlineEntry *last; /* pointer to last outline entry */
};

/* Outline (book mark) destination modes (see page 95, Table 6.20 of THE PDF Reference) */
#define DEST_NULL       0   /* keep current display location and zoom */
#define DEST_XYZ        1   /* /XYZ left top zoom (equivalent to above) */
#define DEST_FIT        2   /* /Fit  */
#define DEST_FITH       3   /* /FitH top */
#define DEST_FITV       4   /* /FitV left */
#define DEST_FITR       5   /* /FitR left bottom right top */
#define DEST_FITB       6   /* /FitB   (fit bounding box to window) PDF-1.1 */
#define DEST_FITBH      7   /* /FitBH top   (fit width of bounding box to window) PDF-1.1 */
#define DEST_FITBV      8   /* /FitBV left   (fit height of bounding box to window) PDF-1.1 */

#define OL_SUBENT       1   /* add as sub-entry */
#define OL_SAME         0   /* add outline at the same level */
#define OL_OPEN         1   /* outline open */
#define OL_CLOSED       0   /* outline closed (all subentries under this) */

#define  DOMAIN_MAGIC_NUMBER    0xdada3333

typedef struct _cpdf_domain {
    unsigned long magic;        /* domain magic number */
    /* struct _cpdf_domain *parent; */ /* pointer to parent domain, null if the parent is the entire page. */
    float xloc, yloc;       /* coordinate of lower-left corner of this domain in parents domain */
    float width, height;        /* width and height of this domain in parents domain */
    float xvalL, xvalH;     /* low- and high-limit values of the X axis of the domain */
    float yvalL, yvalH;     /* low- and high-limit values of the Y axis of the domain */
    struct tm xvTL, xvTH;       /* low- and high-limit values for time X axis of the domain */
    int xtype, ytype;       /* axis flags: 0=linear, 1=log, 2=time */
    int polar;          /* reserved */
    int enableMeshMajor;
    int enableMeshMinor;
    char *meshDashMajor;        /* dash array spec for major mesh lines */
    char *meshDashMinor;        /* dash array spec for minor mesh lines */
    float meshLineWidthMajor;
    float meshLineWidthMinor;
    float meshLineColorMajor[3];
    float meshLineColorMinor[3];
    /* int numChildren; */      /* # of child domains */
    /* struct _cpdf_domain **children; */   /* array of pointers to child plot domains */
    /* for linear X axis */
    float xvalFirstMeshLinMajor;    /* value of first major mesh line */
    float xvalFirstMeshLinMinor;    /* value of first minor mesh line */
    float xmeshIntervalLinMajor;    /* mesh interval for linear axis */
    float xmeshIntervalLinMinor;
    /* for linear Y axis */
    float yvalFirstMeshLinMajor;    /* value of first major mesh line */
    float yvalFirstMeshLinMinor;    /* value of first minor mesh line */
    float ymeshIntervalLinMajor;    /* mesh interval for linear axis */
    float ymeshIntervalLinMinor;
} CPDFplotDomain;

#define AXIS_MAGIC_NUMBER   0xafafafaf

typedef struct {
    unsigned long magic;        /* axis magic number */
    CPDFplotDomain *plotDomain; /* pointer to parent domain, null if the parent is the entire page. */
    float angle;            /* angle of axis, 0.0 for X-axis, 90.0 for Y-axis */
    int   type;         /* 0=linear, 1=logarithmic, 2=time */
    float xloc, yloc;       /* location of the beginning of axis relative to domain's xloc, yloc */
    float length;           /* length of axis in points */
    float axisLineWidth;        /* width of axis line in points */
    float valL, valH;       /* high and low values of the axis (for numbering and ticks) */
    struct tm vTL, vTH;     /* low- and high-limit values for time X axis of the domain */
    int   ticEnableMajor;       /* 0=No tics, 1=Enabled (regular), 2=Free style (list provided) */
    int   ticEnableMinor;       /* 0=No tics, 1=Enabled (regular), 2=Free style (list provided) */
    float ticLenMajor;      /* length of major ticks in points */
    float ticLenMinor;      /* length of minor ticks in points */
    float tickWidthMajor;       /* linewidth for major ticks */
    float tickWidthMinor;
    int   ticPosition;      /* tick position: 0=CWside (below X), 1=Middle, 2=CCWside (above X) */
    int   numPosition;      /* number (label) position: 0=CWside (below X),  2=CCWside (above X) */

    int   numEnable;        /* 0=No #s, 1=Enabled (regular), 2=Free style (list provided) */
    float ticNumGap;        /* gap (in points) between tic end and number */
    float numFontSize;
    int   useMonthName;     /* non-zero for using month names rather than numbers */
    int   use2DigitYear;        /* non-zero value will use 2-digit year for display */
    int   horizNumber;      /* number text is horizontal if non-zero */
    int   numStyle;         /* axis number style regular, exponent etc. */
    /* int   numPrecision; */   /* # of digits after decimal point */
    char  *numFormat;       /* set axis number format */
    char  *numFontName;

    float numLabelGap;      /* gap (in points) between number and axis label */
    float labelFontSize;
    int   horizLabel;
    char  *labelFontName;       /* Font name for axis label */
    char  *labelEncoding;       /* Font encoding for axis label */
    char  *axisLabel;       /* Axis label string, if NULL, no label is shown */

    /* for linear axis */
    float valFirstTicLinMajor;  /* value of first major tick */
    float valFirstTicLinMinor;  /* value of first minor tick */
    float ticIntervalLinMajor;  /* tick interval for linear axis, Major ticks will be numbered. */
    float ticIntervalLinMinor;
    /* for log axis */
    int   ticSelectorLog;       /* log axis tick enable mask */
    int   numSelectorLog;       /* log axis number enable mask */
} CPDFaxis;


/* Describes attributes and resources used on each page.
   Each one of these corresponds to one Page object.
*/
typedef struct {
    int pagenum;            /* page number from cpdf_pageInit() call */
    int objIndex;           /* obj index of itself */
    int parent;         /* obj index of parent Pages object */
    int contents;           /* obj index of Contents stream for this page */
    CPDFmemStream  *pageMemStream;  /* page content memory stream */
    CPDFplotDomain *defDomain;  /* default domain for this page */
    int orientation;        /* page orientation */
    int npFont;         /* # of fonts used on this page */
    int npImage;            /* # of images used on this page */
    int npAnnot;            /* # of annotations on for this page */
    int *fontIdx;           /* x[NMAXFONTS]- list of fonts as an array of indices into fontInfos[] */
    int *imageIdx;          /* x[NMAXIMAGES]- list of images as an array of indices into imageInfos[] */
    int *annotIdx;          /* x[NMAXANNOTS]- list of annotations and links as above */
        char *mediaBox;         /* MediaBox () */
        char *cropBox;          /* CropBox () */
    FILE *fppage;           /* file stream pointer for this page */
    char *contentfile;      /* file for Content stream -- only when memory strem is not used */
    float duration;         /* if > 0.0 in seconds, the page will be displayed for that period */
    char *transition;       /* transition effects */
} CPDFpageInfo;



extern CPDFplotDomain *defaultDomain;   /* default plot domain */
extern CPDFplotDomain *currentDomain;   /* current plot domain */

/* Public API functions ---------------------------------------------------------- */
void cpdf_setDocumentLimits(int maxPages, int maxFonts, int maxImages, int maxAnnots, int maxObjects);
void cpdf_setViewerPreferences(int pageMode, int hideTools, int hideMenus, int hideWinUI,
            int fitWin, int centerWin, int pageLayout, int nonFSpmode);
void cpdf_open(int pspdf);
void cpdf_enableCompression(int compressON);
void cpdf_useContentMemStream(int flag);
void cpdf_setCompressionFilter(char *command, char *decodefilters);
void cpdf_setDefaultDomainUnit(float defunit);
void cpdf_init(void);
int  cpdf_pageInit(int pagenum, int rot, char *mediaboxstr, char *cropboxstr);
void cpdf_finalizeAll(void);
int  cpdf_savePDFmemoryStreamToFile(char *file);
char *cpdf_getBufferForPDF(int *length);
void cpdf_close(void);
int  cpdf_launchPreview(void);
int  cpdf_openPDFfileInViewer(char *pdffilepath);
void cpdf_setCreator(char *pname);
void cpdf_setTitle(char *pname);
void cpdf_setSubject(char *pname);
void cpdf_setKeywords(char *pname);
int  cpdf_comments(char *comments);

/* Page related public functions */
int  cpdf_setCurrentPage(int page);
void cpdf_finalizePage(int page);
void cpdf_setPageSize(char *mboxstr, char *cboxstr);        /* e.g., "0 0 612 792" */
void cpdf_setBoundingBox(int LLx, int LLy, int URx, int URy);
void cpdf_setMediaBox(int LLx, int LLy, int URx, int URy);
void cpdf_setCropBox(int LLx, int LLy, int URx, int URy);

/* page duration and transition */
void cpdf_setPageDuration(float seconds);
int cpdf_setPageTransition(int type, float duration, float direction, int HV, int IO);


/* Annotation and hyper link functions */
void cpdf_setAnnotation(float xll, float yll, float xur, float yur, char *title, char *str);
void cpdf_setActionURL(float xll, float yll, float xur, float yur, char *linkspec);
void cpdf_rawSetAnnotation(float xll, float yll, float xur, float yur, char *title, char *str);
void cpdf_rawSetActionURL(float xll, float yll, float xur, float yur, char *linkspec);
int cpdf_includeTextFileAsAnnotation(float xll, float yll, float xur, float yur, char *title, char *filename);
int cpdf_rawIncludeTextFileAsAnnotation(float xll, float yll, float xur, float yur, char *title, char *filename);

/* ==== Text and Font functions ================================================ */
void cpdf_beginText(int clipmode);
void cpdf_endText(void);

/* convenient text functions */
void cpdf_text(float x, float y, float orientation, char *textstr);
void cpdf_rawText(float x, float y, float orientation, char *textstr);
void cpdf_textAligned(float x, float y, float orientation, int alignmode, char *textstr);
void cpdf_rawTextAligned(float x, float y, float orientation, int alignmode, char *textstr);

/* primitive PDF text operator functions */
void cpdf_textShow(char *txtstr);
void cpdf_textCRLFshow(char *txtstr);
void cpdf_textCRLF();
void cpdf_setNextTextLineOffset(float x, float y);
void cpdf_rawSetNextTextLineOffset(float x, float y);
void cpdf_setTextRise(float rise);
void cpdf_setTextRenderingMode(int mode);
void cpdf_setTextMatrix(float a, float b, float c, float d, float x, float y);
void cpdf_concatTextMatrix(float a, float b, float c, float d, float x, float y);
void cpdf_rotateText(float degrees);
void cpdf_skewText(float alpha, float beta);
void cpdf_setTextPosition(float x, float y);
void cpdf_rawSetTextPosition(float x, float y);
void cpdf_setTextLeading(float leading);
void cpdf_setHorizontalScaling(float scale);
void cpdf_setCharacterSpacing(float spacing);
void cpdf_setWordSpacing(float spaceing);
char *cpdf_escapeSpecialChars(char *instr);

int   cpdf_setFont(char *basefontname, char *encodename, float size);
float cpdf_stringWidth(unsigned char *str);
void multiplyCTM(CPDFctm *T, const CPDFctm *S);

/* Plot Domain functions */
CPDFplotDomain *cpdf_createPlotDomain(float x, float y, float w, float h,
            float xL, float xH, float yL, float yH,
            int xtype, int ytype, int reserved);
CPDFplotDomain *cpdf_createTimePlotDomain(float x, float y, float w, float h,
            struct tm *xTL, struct tm *xTH, float yL, float yH,
            int xtype, int ytype, int reserved);
void cpdf_freePlotDomain(CPDFplotDomain *aDomain);
CPDFplotDomain *cpdf_setPlotDomain(CPDFplotDomain *aDomain);
void cpdf_clipDomain(CPDFplotDomain *aDomain);
void cpdf_fillDomainWithGray(CPDFplotDomain *aDomain, float gray);
void cpdf_fillDomainWithRGBcolor(CPDFplotDomain *aDomain, float r, float g, float b);
void cpdf_setMeshColor(CPDFplotDomain *aDomain, float meshMajorR, float meshMajorG, float meshMajorB,
               float meshMinorR, float meshMinorG, float meshMinorB);
void cpdf_drawMeshForDomain(CPDFplotDomain *aDomain);
void cpdf_setLinearMeshParams(CPDFplotDomain *aDomain, int xy, float mesh1ValMajor, float intervalMajor,
                          float mesh1ValMinor, float intervalMinor);
void cpdf_suggestMinMaxForLinearDomain(float vmin, float vmax, float *recmin, float *recmax);
void cpdf_suggestLinearDomainParams(float vmin, float vmax, float *recmin, float *recmax,
        float *tic1ValMajor, float *intervalMajor,
        float *tic1ValMinor, float *intervalMinor);
float x_Domain2Points(float x);
float y_Domain2Points(float y);

/* Axis functions */
CPDFaxis *cpdf_createAxis(float angle, float axislength, int typeflag, float valL, float valH);
CPDFaxis *cpdf_createTimeAxis(float angle, float axislength, int typeflag, struct tm *vTL, struct tm *vTH);
void cpdf_freeAxis(CPDFaxis *anAx);
void cpdf_drawAxis(CPDFaxis *anAx);
void cpdf_attachAxisToDomain(CPDFaxis *anAx, CPDFplotDomain *domain, float x, float y);
void cpdf_setAxisLineParams(CPDFaxis *anAx, float axLineWidth, float ticLenMaj, float ticLenMin,
                float tickWidMaj, float tickWidMin);
void cpdf_setTicNumEnable(CPDFaxis *anAx, int ticEnableMaj, int ticEnableMin, int numEnable);
void cpdf_setAxisTicNumLabelPosition(CPDFaxis *anAx, int ticPos, int numPos, int horizNum, int horizLab);
void cpdf_setAxisNumberFormat(CPDFaxis *anAx, char *format, char *fontName, float fontSize);
void cpdf_setTimeAxisNumberFormat(CPDFaxis *anAx, int useMonName, int use2DigYear, char *fontName, float fontSize);
void cpdf_setAxisLabel(CPDFaxis *anAx, char *labelstring, char *fontName, char *encoding, float fontSize);
void cpdf_setLinearAxisParams(CPDFaxis *anAx, float tic1ValMajor, float intervalMajor,
                          float tic1ValMinor, float intervalMinor);
void cpdf_setLogAxisTickSelector(CPDFaxis *anAx, int ticselect);
void cpdf_setLogAxisNumberSelector(CPDFaxis *anAx, int numselect);

float vAxis2Points(float x);


/* Drawing and path constructions functions */
/* These functions use current (scaled linear or log) coordinate system for (x, y) */
void cpdf_moveto(float x, float y);
void cpdf_lineto(float x, float y);
void cpdf_rmoveto(float x, float y);
void cpdf_rlineto(float x, float y);
void cpdf_curveto(float x1, float y1, float x2, float y2, float x3, float y3);
void cpdf_rect(float x, float y, float w, float h);
void cpdf_quickCircle(float xc, float yc, float r);     /* center (x,y) and radius r */
void cpdf_arc(float x, float y, float r, float sangle, float eangle, int moveto0);
void cpdf_circle(float x, float y, float r);

/* These use raw, point-based coordinate system for (x,y) */
void cpdf_rawMoveto(float x, float y);
void cpdf_rawLineto(float x, float y);
void cpdf_rawRmoveto(float x, float y);
void cpdf_rawRlineto(float x, float y);
void cpdf_rawCurveto(float x1, float y1, float x2, float y2, float x3, float y3);
void cpdf_rawRect(float x, float y, float w, float h);
void cpdf_rawQuickCircle(float xc, float yc, float r);  /* center (x,y) and radius r */
void cpdf_rawArc(float x, float y, float r, float sangle, float eangle, int moveto0);
void cpdf_rawCircle(float xc, float yc, float r);

/* Operations on current path */
void cpdf_closepath(void);
void cpdf_stroke(void);
void cpdf_fill(void);
void cpdf_eofill(void);
void cpdf_fillAndStroke(void);
void cpdf_eofillAndStroke(void);
void cpdf_clip(void);
void cpdf_eoclip(void);
void cpdf_newpath(void);


/* Color functions */
void cpdf_setgray(float gray);              /* set both fill and stroke grays */
void cpdf_setrgbcolor(float r, float g, float b);   /* set both fill and stroke colors */
void cpdf_setgrayFill(float gray);
void cpdf_setgrayStroke(float gray);
void cpdf_setrgbcolorFill(float r, float g, float b);
void cpdf_setrgbcolorStroke(float r, float g, float b);
void cpdf_setcmykcolorFill(float c, float m, float y, float k);
void cpdf_setcmykcolorStroke(float c, float m, float y, float k);


/* Graphics state functions */
void cpdf_gsave(void);
void cpdf_grestore(void);
void cpdf_setdash(char *dashspec);
void cpdf_nodash(void);
void cpdf_concat(float a, float b, float c, float d, float e, float f);
void cpdf_rawConcat(float a, float b, float c, float d, float e, float f);
void cpdf_rotate(float angle);
void cpdf_translate(float xt, float yt);
void cpdf_rawTranslate(float xt, float yt);
void cpdf_scale(float sx, float xy);
void cpdf_setlinewidth(float width);
void cpdf_setflat(int flatness);    /* flatness = 0 .. 100 */
void cpdf_setlinejoin(int linejoin);    /* linejoin = 0(miter), 1(round), 2(bevel) */
void cpdf_setlinecap(int linecap);  /* linecap = 0(butt end), 1(round), 2(projecting square) */
void cpdf_setmiterlimit(float miterlimit);
void cpdf_setstrokeadjust(int flag);        /* PDF-1.2 */

/* Data point Marker funcitons */
void cpdf_marker(float x, float y, int markertype, float size);
void cpdf_pointer(float x, float y, int direction, float size);
void cpdf_errorbar(float x, float y1, float y2, float capsize);
void cpdf_highLowClose(float x, float vhigh, float vlow, float vclose, float ticklen);

/* raw (point-based) versions of marker and other plot symbols above */
void cpdf_rawMarker(float x, float y, int markertype, float size);
void cpdf_rawPointer(float x, float y, int direction, float size);
void cpdf_rawErrorbar(float x, float y1, float y2, float capsize);
void cpdf_rawHighLowClose(float x, float vhigh, float vlow, float vclose, float ticklen);

/* Image related functions */
int cpdf_rawImportImage(char *imagefile, int type, float x, float y, float angle,
    float *width, float *height, float *xscale, float *yscale, int gsave);
int cpdf_importImage(char *imagefile, int type, float x, float y, float angle,
    float *width, float *height, float *xscale, float *yscale, int gsave);
int read_JPEG_header(char *filename, CPDFimageInfo *jInfo);

int cpdf_placeInLineImage(void *imagedata, int len,
        float x, float y, float angle, float width, float height,
        int pixwidth, int pixheight, int bitspercomp, int CSorMask, int gsave);
int cpdf_rawPlaceInLineImage(void *imagedata, int len,
        float x, float y, float angle, float width, float height,
        int pixwidth, int pixheight, int bitspercomp, int CSorMask, int gsave);


/* Memory stream:  most are in cpdfMemBuf.c */
CPDFmemStream *cpdf_openMemoryStream(void);
void cpdf_closeMemoryStream(CPDFmemStream *memStream);
int cpdf_writeMemoryStream(CPDFmemStream *memStream, char *data, int len);
void cpdf_getMemoryBuffer(CPDFmemStream *memStream, char **streambuf, int *len, int *maxlen);
int cpdf_saveMemoryStreamToFile(CPDFmemStream *stream, const char *name);
CPDFmemStream *cpdf_setCurrentMemoryStream(CPDFmemStream *memStream);   /* cpdfInit.c */
int cpdf_memPutc(int ch, CPDFmemStream *memStream);
int cpdf_memPuts(char *str, CPDFmemStream *memStream);
void cpdf_clearMemoryStream(CPDFmemStream *aMstrm);

/* Outline (book mark) functions */
CPDFoutlineEntry *cpdf_addOutlineEntry(CPDFoutlineEntry *afterThis, int sublevel, int open, int page,
        char *title, int mode, float p1, float p2, float p3, float p4);

/* Misc functions */
void  cpdf_setPDFLevel(int major, int minor);
void  cpdf_useStdout(int flag);
char  *cpdf_getOutputFilename(void);
void  cpdf_setOutputFilename(char *file);
float tm_to_NumDays(struct tm *fromDate, struct tm *toDate);
char  *timestring(int fmt);
int   isLeapYear(int year);
long  getFileSize(char *file);
void  rotate_xyCoordinate(float x, float y, float angle, float *xrot, float *yrot);
float getMantissaExp(float v, int *iexp);
int cpdf_setMonthNames(char *mnArray[]);
int _cpdf_freeMonthNames(void);

/* =============================================================================== */
/* Private Functions and Macros: DO NOT CALL THESE FUNCTIONS. */

/*
#define  COUNT_BYTES_OUT(s,fp)  {currentByteCount += strlen(s); fputs((s), (fp));}
*/
void _cpdf_pdfWrite(char *s);
void _cpdf_initDocumentGolbals(void);

long _cpdf_WriteCatalogObject(int objNumber);
long _cpdf_WriteOutlinesObject(int objNumber);
long _cpdf_WritePagesObject(int objNumber);
long _cpdf_WritePageObject(CPDFpageInfo *pInf);
long _cpdf_WriteContentsFromFile(CPDFpageInfo *pInf);
long _cpdf_WriteContentsFromMemory(CPDFpageInfo *pInf);
long _cpdf_WriteProcSetArray(int objNumber);
long _cpdf_WriteFont(int objNumber, char *fontName, char *baseFont, char *encoding);
long _cpdf_WriteImage(CPDFimageInfo *imgInf);
long _cpdf_WriteAnnotation(CPDFannotInfo *aInf);
long _cpdf_WriteProducerDate(int objNumber);
long _cpdf_WriteXrefTrailer(int objNumber);

/* Page related private functions */
int  _cpdf_freeAllPageInfos(void);

/* Annotation and hyper link private functions */
int  _cpdf_freeAllAnnotInfos(void);

/* Text related private functions */
void _cpdf_resetTextCTM(void);

/* Font related private functions */
int  _cpdf_freeAllFontInfos(void);
int isNewFont(char *basefontname, char *encodename, int *fontFound);

/* Image related private functions */
int isNewImage(char *filepath, int *imageFound);
int  _cpdf_freeAllImageInfos(void);


void str_append_int(char *buf, int num);
int  _cpdf_file_open(void);
void _cpdf_file_close(void);

/* Domain related (private) */
void _do_meshLines_X(CPDFplotDomain *aDomain);
void _do_meshLines_Y(CPDFplotDomain *aDomain);

/* Axis related (private) */
void _do_oneTick(CPDFaxis *anAx, float vt, float ticlen);
void _do_linearTics(CPDFaxis *anAx);
void _do_logTics(CPDFaxis *anAx);
void _do_timeTics(CPDFaxis *anAx);
char *fix_trailingZeros(char *sstr);
void _do_oneNumber(CPDFaxis *anAx, float v, float ticlen);
void _do_oneTimeNumber(CPDFaxis *anAx, float v, struct tm *vtm, int majorBumpVar, float ticlen);

void _do_linearNumbers(CPDFaxis *anAx);
void _do_logNumbers(CPDFaxis *anAx);
void _do_timeNumbers(CPDFaxis *anAx);
void _do_axisLabel(CPDFaxis *anAx);
int _bittest(int aNumber, int bitpos);
void _setDefaultTimeBumpVar(float fndays, int *minorBumpVar, int *majorBumpVar, int *minorBump, int *majorBump);
float _bump_tm_Time(struct tm *rT, struct tm *vT, int bumpVar, int bump);
void _printfTime(struct tm *vtm);
char *_yearFormat(int year, int flag);

/* memory stream debug function */

void _checkMemMagic(char *idstr, CPDFmemStream *memStream);
void _cpdf_malloc_check(void *buf);

/* Private outline (book mark) functions */
char *_cpdf_dest_attribute(int mode, float p1, float p2, float p3, float p4);
void _cpdf_serializeOutlineEntries(int *objCount, CPDFoutlineEntry *first, CPDFoutlineEntry *last);
void _cpdf_WriteOutlineEntries(CPDFoutlineEntry *first, CPDFoutlineEntry *last);
long _cpdf_WriteOneOutlineEntry(CPDFoutlineEntry *olent);
void _cpdf_freeAllOutlineEntries(CPDFoutlineEntry *first, CPDFoutlineEntry *last);


/* Private functions for arc drawing */
void _cpdf_arc_small(float x, float y, float r, float midtheta, float htheta, int mvlnto0, int ccwcw);


#ifdef MacOS8
void SetFileInfo(char *fileName, OSType fileType, OSType fileCreator);

#endif


/* #define NUMPSFONTS 35 */
#define NUMPSFONTS 14

#ifdef MAINDEF
char *cpdf_fontnamelist[] = {
    "Helvetica",
    "Helvetica-Bold",
    "Helvetica-Oblique",
    "Helvetica-BoldOblique",
    "Times-Roman",
    "Times-Bold",
    "Times-Italic",
    "Times-BoldItalic",
    "Courier",
    "Courier-Bold",
    "Courier-Oblique",
    "Courier-BoldOblique",
    "Symbol",
    "ZapfDingbats",

    "AvantGarde-Book",
    "AvantGarde-BookOblique",
    "AvantGarde-Demi",
    "AvantGarde-DemiOblique",
    "Bookman-Demi",
    "Bookman-DemiItalic",
    "Bookman-Light",
    "Bookman-LightItalic",
    "Helvetica-Narrow",
    "Helvetica-Narrow-Bold",
    "Helvetica-Narrow-Oblique",
    "Helvetica-Narrow-BoldOblique",
    "NewCenturySchlbk-Roman",
    "NewCenturySchlbk-Italic",
    "NewCenturySchlbk-Bold",
    "NewCenturySchlbk-BoldItalic",
    "Palatino-Roman",
    "Palatino-Italic",
    "Palatino-Bold",
    "Palatino-BoldItalic",
    "ZapfChancery-MediumItalic"
};


#else
    extern char *cpdf_fontnamelist[];
#endif


#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif  /*  __CLIBPDF_H__  */

