/*  C PDF library globals -- This file must be imported after cpdflib.h in each module.
 * Copyright (C) 1998 FastIO Systems, All Rights Reserved.
 * For conditions of use, license, and distribution, see LICENSE.txt or LICENSE.pdf.

 1998-11-20 [IO]
	Values of variables initialized here will be overwritten in function
	void _cpdf_initDocumentGolbals(void) called from cg_open() in cpdfInit.c.
	If you add any variable here, don't forget to initialize it in the
	the function _cpdf_initDocumentGolbals() as well.
*/


/* MAINDEF is defined in file cpdfInit.c. In all other files, it is not defined. */
#if defined(MAINDEF)
    int ps_pdf_mode = 0;			/* PDF=0, EPDF=1, PS=2, EPS=3, FDF=4 (not used) */
    int pdfLevelMaj = 1;			/* PDF level, do not use operators beyond these */
    int pdfLevelMin = 1;
    char **monthName;				/* see cpdfAxis.c */
    float defdomain_unit = POINTSPERINCH;	/* unit for default domain */
    int display_rotation = 270;
    int useStandardOutput = 0;			/* send output to stdout if non-zero */
    int compressionON = 0;			/* compress stream */
    char *compress_command = NULL;		/* command for LZW compression */
    char *streamFilterList = NULL;		/* for PDF stream /Filter spec */
    int launchPreview = 1;			/* launch viewer application on the output file */
    int filename_set = 0;			/* flag indicating if output filename is set explicitly */
    int fncounter = 0;				/* filename counter for a given process */
    int inTextObj = 0;				/* flag indicating within Text block between BT ET */
    CPDFviewerPrefs viewerPrefs;		/* viewer preferences such as whether outline should be open */
    CPDFplotDomain *defaultDomain = NULL;	/* default plot domain */
    CPDFplotDomain *currentDomain = NULL;	/* current plot domain */
    float x2points=1.0, y2points=1.0;		/* scaling factor for current domain */
    double xLlog, xHlog, yLlog, yHlog;		/* scaling factor for current domain (logarithmic) */
    int nMaxFonts = NMAXFONTS;			/* max number of fonts as a variable */
    int numFonts = 0;				/* number of fonts used */
    CPDFfontInfo *fontInfos = NULL;		/* array of font infos */
    int currentFont = 0;			/* current font index (into fontInfos[]) */
    int inlineImages = 0;			/* in-line image count */
    int nMaxImages = NMAXIMAGES;		/* maximum number of unique images */
    int numImages = 0;
    CPDFimageInfo *imageInfos = NULL;
    int imageFlagBCI = 0;			/* bit-0 (/ImageB), bit-1 (/ImageC), bit-2 (/ImageI) */
    int numOutlineEntries = 0;			/* total # of outline (book mark) entries */
    CPDFoutlineEntry *firstOLentry = NULL;	/* pointer to first outline entry */
    CPDFoutlineEntry *lastOLentry = NULL;	/* pointer to last outline entry */

    float font_size = 12.0;			/* current font size and info below */
    float word_spacing = 0.0;
    float char_spacing = 0.0;
    float text_rise = 0.0;
    float horiz_scaling = 100.0;		/* text horizontal scaling in percent */
    float text_leading = 0.0;

    int usePDFMemStream = 1;			/* if non-zero use memory stream for PDF generation */
    CPDFmemStream *pdfMemStream = NULL;		/* memory stream for PDF file that is currently active */
    int useContentMemStream = 1;		/* if non-zero use memory stream for Content */
    CPDFmemStream *currentMemStream = NULL;	/* memory stream for Content that is currently active */
    int currentPage =1;				/* current page number that is being drawn */
    int nMaxPages = NMAXPAGES;			/* maximum number of pages */
    int numPages =1;				/* number of pages - may be greater than actual # of pages */
    CPDFpageInfo *pageInfos = NULL;		/* array of pageInfo structure for all pages (alloc nMaxPages+1) */
    int numKids = 0;				/* actual # of pages counted for Pages object */
    int *kidsIndex = NULL;				/* object index list for kids to be written to Pages object */
    CPDFmemStream *scratchMem = NULL;		/* use this as non-overflowing scratch pad */
    FILE *fpcg = NULL; 				/* Output file */
    FILE *fpcontent = NULL;			/* Content stream (need length) */
    int  nMaxAnnots = NMAXANNOTS;		/* maximum number of annotations */
    int  numAnnots = 0;				/* count of annotations */
    CPDFannotInfo *annotInfos = NULL;		/* array of annotInfo structure for all annotations */
    char mediaBox[64];				/* MediaBox for current page*/
    char cropBox[64];				/* CropBox for current page */
    long currentByteCount = 0;			/* # of bytes written, or offset of next object */
    char creator_name[64];			/* Info: set it by cpdf_setCreator() */
    char file_title[64];			/* Info: title of PDF file */
    char file_subject[64];			/* Info: subject of PDF file */
    char file_keywords[128];			/* Info: keywords */
    char username[64];				/* user name */
    char filenamepath[1024];
    char contentfile[1024];
    int  nMaxObjects = NMAXOBJECTS;		/* maximum number of objects for xref */
    long *objByteOffset = NULL;			/* offset into object number N */
    int  *objIndex = NULL;			/* object index for selected objects */
    long startXref = 0;				/* offset of xref */
    /* Don't change these, use cpdf_setMonthNames(char *mnArray[]) for other languages. */
    char *monthNameEnglish[] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
			     	 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
    char spbuf[2048];				/* scratch buffer for sprintf */

#else
    extern int ps_pdf_mode;			/* PDF=0, EPDF=1, PS=2, EPS=3, FDF=4 */
    extern int pdfLevelMaj;			/* PDF level, do not use operators beyond these */
    extern int pdfLevelMin;
    extern char **monthName;			/* see cpdfAxis.c */
    extern float defdomain_unit;		/* unit for default domain */
    extern int display_rotation;
    extern int useStandardOutput;		/* send output to stdout if non-zero */		
    extern int compressionON;			/* compress stream */
    extern char *compress_command;		/* command for LZW compression */
    extern char *streamFilterList;		/* for PDF stream /Filter spec */
    extern int launchPreview;			/* launch viewer application on the output file */		
    extern int filename_set;			/* flag indicating if output filename is set explicitly */
    extern int fncounter;			/* filename counter for a given process */
    extern int inTextObj;			/* flag indicating within Text block, i.e., between BT ET */
    extern CPDFviewerPrefs viewerPrefs;		/* viewer preferences such as whether outline should be open */
    extern CPDFplotDomain *defaultDomain;	/* default plot domain */
    extern CPDFplotDomain *currentDomain;	/* current plot domain */
    extern float x2points, y2points;		/* scaling factor for current domain */
    extern double xLlog, xHlog, yLlog, yHlog;	/* scaling factor for current domain (logarithmic) */
    extern int nMaxFonts;			/* max number of fonts as a variable */
    extern int numFonts;			/* number of fonts used */
    extern CPDFfontInfo *fontInfos;		/* array of font infos */
    extern int currentFont;			/* current font index (into fontInfos[]) */
    extern int inlineImages;			/* in-line image count */
    extern int nMaxImages;			/* maximum number of unique images */
    extern int numImages;
    extern CPDFimageInfo *imageInfos;
    extern int imageFlagBCI;			/* bit-0 (/ImageB), bit-1 (/ImageC), bit-2 (/ImageI) */
    extern int numOutlineEntries;		/* total # of outline (book mark) entries */
    extern CPDFoutlineEntry *firstOLentry;	/* pointer to first outline entry */
    extern CPDFoutlineEntry *lastOLentry;	/* pointer to last outline entry */
    extern float font_size;			/* current font size and info below */
    extern float word_spacing;
    extern float char_spacing;
    extern float text_rise;
    extern float horiz_scaling;			/* text horizontal scaling in percent */
    extern float text_leading;

    extern int usePDFMemStream;			/* if non-zero use memory stream for PDF file */
    extern CPDFmemStream *pdfMemStream;		/* memory stream for PDF file that is currently active */
    extern int useContentMemStream;		/* if non-zero use memory stream instead of temp file */
    extern CPDFmemStream *currentMemStream;	/* memory stream currently active */
    extern int currentPage;			/* current page number that is being drawn */
    extern int nMaxPages;			/* maximum number of pages */
    extern int numPages;			/* number of pages */
    extern CPDFpageInfo *pageInfos;		/* array of pageInfo structure for all pages */
    extern int numKids;				/* actual # of pages counted for Pages object */
    extern int *kidsIndex;			/* object index list for kids to be written to Pages object */
    extern CPDFmemStream *scratchMem;		/* use this as non-overflowing scratch pad */
    extern FILE *fpcg; 				/* Output stream */
    extern FILE *fpcontent;			/* Content stream (need length) */
    extern int  nMaxAnnots;			/* maximum number of annotations */
    extern int  numAnnots;			/* # of annotations and hyperlinks */
    extern CPDFannotInfo *annotInfos;		/* array of annotInfo structure for all annotations */
    extern char mediaBox[];			/* MediaBox (letter) */
    extern char cropBox[];			/* CropBox (letter) */
    extern long currentByteCount;		/* # of bytes written, or offset of next object */
    extern char creator_name[];			/* set it by cpdf_setCreator() */
    extern char file_title[];			/* Info: title of PDF file */
    extern char file_subject[];			/* Info: subject of PDF file */
    extern char file_keywords[];		/* Info: keywords */
    extern char username[];
    extern char filenamepath[];
    extern char contentfile[];

    extern int  nMaxObjects;			/* maximum number of objects for xref */
    extern long *objByteOffset;			/* offset into object number N */
    extern int  *objIndex;			/* object index for selected objects */
    extern long startXref;			/* offset of xref */
    extern char *monthNameEnglish[];
    extern char spbuf[];			/* buffer for sprintf */

#endif


