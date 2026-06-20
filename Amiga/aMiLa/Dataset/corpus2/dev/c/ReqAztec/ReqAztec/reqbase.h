
/* reqlibrary.h © 1988/1989 reserved by Colin Fox and Bruce Dawson */

#ifndef REQLIBRARY_H
#define REQLIBRARY_H

#ifndef	EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef	LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif

#ifndef	INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#define	REQVERSION	1


#define	NUMPAIRS	10

struct GadgetBlock {
	struct Gadget		Gadget;
	struct Border		Border;
	WORD				Pairs[NUMPAIRS];
	struct IntuiText	Text;
};

struct StringBlock {
	struct Gadget		Gadget;
	struct StringInfo	Info;
	struct Border		Border;
	WORD				Pairs[NUMPAIRS];
};

struct PropBlock {
	struct Gadget		Gadget;
	struct PropInfo		Info;
	struct Image		Image;
};

struct ScrollBlock {
	struct Gadget		ArrowUpLt;
	struct Image		ImageUpLt;
	struct Gadget		ArrowDnRt;
	struct Image		ImageDnRt;
	struct PropBlock	Prop;
};

struct TwoImageGadget {
	struct Gadget		Gadget;
	struct Image		Image1;
	struct Image		Image2;
};

#define	ATTITUDEB	16

#define	HORIZSLIDER		(0L<<ATTITUDEB)	/*;which way the slider stands*/
#define	VERTSLIDER		(1L<<ATTITUDEB)	/*;This is so that it bypasses all gadget flags.*/



/*;         This structure is use with the TextRequester function.*/

struct TRStructure {
	char	*Text;			/* ;This is the message text, including printf() style formatting if desired.*/
	char	*Controls;		/* ;This is the address of the parameter list, if printf() style formatting is used.*/
	struct Window *Window;	/* ;This is an optional (zero if not used) pointer to a window on the screen you*/
							/* ;would like the requester to show up on.*/
	char	*MiddleText;	/* ;If non-zero, this is the text for the gadget in the lower middle (returns 2).*/
	char	*PositiveText;	/* ;If non-zero, this is the text for the gadget in the lower left hand corner (returns 1).*/
	char	*NegativeText;	/* ;If non-zero, this is the text for the gadget in the lower right (returns 0).*/
	char	*Title;			/* ;This is the title for the window.*/
	WORD	KeyMask;		/* ;This is the qualifier mask for the keyboard shortcuts.*/
							/* ;Use $FFFF to allow any qualifiers (or none).*/
							/* ;Zero means that no keyboard shortcuts are allowed.*/
	WORD	textcolor;		/* ;Color of the text.  Uses color 1 if no color specified. */
	WORD	detailcolor;	/* ;Detail and block color, as in a NewWindow structure.  If */
	WORD	blockcolor;		/* ;both are left zero, block pen will be set to 1. */
	WORD	versionnumber;	/* ;Make SURE this is set to zero. */
	LONG	rfu1;			/* ;Make SURE you leave these two zeroed also. */
	LONG	rfu2;			/* ;Make SURE you leave these two zeroed also. */
};

/* NOTE:
 *
 *		The  control  values  mentioned above are used if you choose to insert
 *	printf  style directives in your strings and should contain the address of
 *	a list of control parameters, usually on the stack.
 */


/*;         Remember,   if  you  don't  want  to  go  through  the  hassle  of	*/
/*; initializing a ExtendedColorRequester structure, you can always just call	*/
/*; ColorRequester  (as opposed to ExtendedColorRequester).  ColorRequester		*/
/*; just  takes  a  single  parameter, in D0, the color that should start out	*/
/*; being highlit.  It returns a single value, the color that was selected at	*/
/*; the end.

/*;         This structure is for use with the ExtendedColorRequester (_not_, */
/*; the ColorRequester) function. */

struct ExtendedColorRequester {
	LONG	defcolor;		/*;The color that is initially highlit. */
	APTR	window;			/*;The window the 'requester' opens up in. */
	LONG	rfu1;			/*;Who knows what these will be used for, */
	LONG	rfu2;			/*;but I'm sure we'll think of something. */
	LONG	rfu3;			/*;Until then, just keep these zeroed. */
	LONG	rfu4;			/*;Okay? */
	LONG	rfu5;
};


/*;         This structure is for use with the GetLong function.*/

#define	GLNODEFAULTB	0	/*;Set this bit in the flags if you don't want a default*/
							/*;value to show up in the get long string gadget.  For*/
							/*;some things this is much better than having a zero*/
							/*;show up.*/

#define	GLNODEFAULTM	(1<<GLNODEFAULTB)

struct GetLongStruct {
	char	*titlebar;
	LONG	defaultval;
	LONG	minlimit;
	LONG	maxlimit;
	LONG	result;
	struct Window	*window;
	WORD	versionnumber;	/* ;Make SURE this is set to zero. */
	LONG	flags;			/* Some, uh flags.  See above for bit definitions. */
	LONG	rfu2;			/* ;Make SURE you leave these two zeroed also. */
};

struct GetStringStruct {
	char	*titlebar;
	char	*stringbuffer;
	struct	Window *window;
	WORD	stringsize;		/* how many characters in the buffer */
	WORD	visiblesize;		/* how many characters show on screen */
	WORD	versionnumber;
	LONG	flags;
	LONG	rfu1;
	LONG	rfu2;
	LONG	rfu3;
};



#define	REQ_DSIZE	130
#define	REQ_FCHARS	30
#define	WILDLENGTH	30

/*
 *		These  are  the  bit  numbers  of various bits that you can set in the
 *	Flags  field of the file requester structure.  The actual values that come
 *	out of these bit numbers are defined in the set of includes below with the
 *	same  names  but  with  an  M  (for  mask) ending instead of a B (for bit)
 *	ending.
 */

#define	FRQSHOWINFOB	0	/*;Set this in Flags if you want .info files to show.  They default to hidden.*/
#define	FRQEXTSELECTB	1	/*;Set this in Flags if you want extended select.  Default is not.*/
#define	FRQCACHINGB		2	/*;Set this in Flags if you want directory caching.  Default is not.*/
#define	FRQGETFONTSB	3	/*;Set this in Flags if you want a font requester rather than a file requester.*/
#define	FRQINFOGADGETB	4	/*;Set this in Flags if you want a hide-info files gadget.*/
#define	FRQHIDEWILDSB	5	/*;Set this in Flags if you DON'T want 'show' and 'hide' string gadgets.*/
#define	FRQABSOLUTEXYB	6	/*;Use absolute x,y positions rather than centering on mouse.*/
#define	FRQCACHEPURGEB	7	/*;Purge the cache whenever the directory date stamp changes if this is set.*/
#define	FRQNOHALFCACHEB	8	/*;Don't cache a directory unless it is completely read in when this is set.*/
#define	FRQNOSORTB		9	/*;Set this in Flags if you DON'T want sorted directories.*/
#define	FRQNODRAGB		10	/*;Set this in Flags if you DON'T want a drag bar and depth gadgets.*/
#define	FRQSAVINGB		11	/*;Set this bit if you are selecting a file to save to.*/
#define	FRQLOADINGB		12	/*;Set this bit if you are selecting a file(s) to load from.*/
							/*;These two bits (save and load) aren't currently used for*/
							/*;anything, but they may be in the future, so you should*/
							/*;remember to set them.  Also, these bits make it easier if*/
							/*;somebody wants to customize the file requester for their*/
							/*;machine.  They can make it behave differently for loading*/
							/*;vs saving.*/
#define	FRQDIRONLYB		13	/*;Allow the user to select a directory, rather than a file.*/

/*
 *		These  are the mask values that you can OR into the Flags field of the
 *	file requester structure.
 */

#define	FRQSHOWINFOM	(1<<FRQSHOWINFOB)
#define	FRQEXTSELECTM	(1<<FRQEXTSELECTB)
#define	FRQCACHINGM		(1<<FRQCACHINGB)
#define	FRQGETFONTSM	(1<<FRQGETFONTSB)
#define	FRQINFOGADGETM	(1<<FRQINFOGADGETB)
#define	FRQHIDEWILDSM	(1<<FRQHIDEWILDSB)
#define	FRQABSOLUTEXYM	(1<<FRQABSOLUTEXYB)
#define	FRQCACHEPURGEM	(1<<FRQCACHEPURGEB)
#define	FRQNOHALFCACHEM	(1<<FRQNOHALFCACHEB)
#define	FRQNOSORTM		(1<<FRQNOSORTB)
#define	FRQNODRAGM		(1<<FRQNODRAGB)
#define	FRQSAVINGM		(1<<FRQSAVINGB)
#define	FRQLOADINGM		(1<<FRQLOADINGB)
#define	FRQDIRONLYM		(1<<FRQDIRONLYB)

struct ESStructure {
	struct ESStructure	*NextFile;
	WORD	NameLength;			/* Length of thefilename field, not including the terminating zero. */
	WORD	Pad;
	APTR	Node;				/* For internal use only. */
	char	thefilename[1];		/* This is a variable size field. */
};

struct FileReq {
	UWORD	VersionNumber;				/* Make sure this is zeroed for now. */
	char	*Title;						/* Hailing text */
	char	*Dir;						/* Directory array (REQ_DSIZE+1) */
	char	*File;						/* Filename array (REQ_FCHARS+1) */
	char	*PathName;					/* Complete path name array (REQ_DSIZE+REQ_FCHARS+2) */
	struct Window	*Window;			/* Window requesting or NULL */
	UWORD	MaxExtendedSelect;			/* Zero implies a maximum of 65535, as long as FRQEXTSELECT is set.*/
	UWORD	numlines;					/* Number of lines in file window. */
	UWORD	numcolumns;					/* Number of columns in file window. */
	UWORD	devcolumns;
	ULONG	Flags;						/* Various - umm - flags.  See above for more info. */
	UWORD	dirnamescolor;			/* These five colors will all default */
	UWORD	filenamescolor;			/* to color one if you don't specify */
	UWORD	devicenamescolor;		/* a color (ie; if you specify color zero). */
	UWORD	fontnamescolor;			/* If you want color zero to be used, specify */
	UWORD	fontsizescolor;			/* color 32, or some other too large number */
									/* which mods down to zero. */
	UWORD	detailcolor;			/* If both of these colors are specified as */
	UWORD	blockcolor;				/* zero then the block pen will be set to one. */
	UWORD	gadgettextcolor;		/* The color for the text of the five boolean gadgets.  Defaults to 1. */
	UWORD	textmessagecolor;		/* The color for the message at the screen top.  Defaults to 1. */
	UWORD	stringnamecolor;		/* The color for the words Drawer, File, Hide and Show.  Defaults to 3. */
	UWORD	stringgadgetcolor;		/* The color for the borders of the string gadgets.  Defaults to 3. */
									/* Unfortunately it is not possible to specify */
									/* the color of the actual text in an Intuition */
									/* string gadget. */
	UWORD	boxbordercolor;			/* The color for the boxes around the file and directory areas.  Defaults to 3. */
	UWORD	gadgetboxcolor;			/* The color for the boxes around the five boolean gadgets.  Defaults to 3. */
	UWORD	FRU_Stuff[18];				/* This area, which is reserved for */
										/* future use, should all be zero. */
	struct DateStamp	DirDateStamp;	/* A copy of the cached directories date stamp. */
										/* There should never be any need to change this. */
	UWORD	WindowLeftEdge;			/* These two fields are only used when the */
	UWORD	WindowTopEdge;			/* FRQABSOLUTEXY flag is set.  They specify */
									/* the location of the upper left hand */
									/* corner of the window. */
	UWORD	FontYSize;				/* These fields are used to return the selected */
	UWORD	FontStyle;				/* font size and style, only applicable when the */
									/* font bit is set. */

	/*If you set the extended select bit and the user extended selects, the list of filenames will start from here.*/
	struct ESStructure *ExtendedSelect;

	char	Hide[WILDLENGTH+2];		/* The wildcards text. */
	char	Show[WILDLENGTH+2];		/* More wildcards text. */
	WORD	FileBufferPos;			/* Various fields taken from the various */
	WORD	FileDispPos;			/* string gadgets so that the cursor */
	WORD	DirBufferPos;			/* can be returned to the same position */
	WORD	DirDispPos;				/* on subsequent calls. */
	WORD	HideBufferPos;
	WORD	HideDispPos;
	WORD	ShowBufferPos;
	WORD	ShowDispPos;

/**;		The  following  fields are PRIVATE!  Don't go messing with them or
 **;	wierd  things may/will happen.  If this isn't enough of a warning, go read
 **;	the one in intuition.h, that should scare you off.
 **/

	APTR	Memory;						/* Memory allocate for dir entries. */
	APTR	Memory2;					/* More memory, used for hidden files. */
	APTR	Lock;
	char	PrivateDirBuffer[REQ_DSIZE+2];	/* Used for keeping a record of which */
										/* directory we have file names for. */
	struct FileInfoBlock	*FileInfoBlock;
	WORD	NumEntries;
	WORD	NumHiddenEntries;
	WORD	filestartnumber;
	WORD	devicestartnumber;
};


/*        This is used with the RealTimeScroll function. */

struct ScrollStruct {
	ULONG	TopEntryNumber;			/*;This is the ordinal number of the first*/
									/*;displayed entry.*/
	ULONG	NumEntries;				/*;This is the total number of entries in*/
									/*;the list.*/
	UWORD	LineSpacing;			/*;This is how many pixels high each entry is.*/
	ULONG	NumLines;				/*;This is how many entries can be displayed simultaneously.*/
	struct Gadget	*PropGadget;	/*;This is a pointer to the prop gadget being monitored.*/

	void	(*RedrawAll)();			/*;This routine is used to redraw all of the*/
									/*;entries when the user moves far enough*/
									/*;that scrolling will take too long.*/

	void	(*ReadMore)();			/*;An optional routine that is called when*/
									/*;the scroll routine is waiting for movement.*/
									/*;This allows reading of new data while real*/
									/*;time scrolling.*/
	void	(*ScrollAndDraw)();		/*;This routine is called when the data needs*/
									/*;to be scrolled and updated.  This routine is*/
									/*;passed four long parameters (on the stack and*/
									/*;in D0-D3) which are, respectively:*/
									/*;D0 - entry number of first line to be drawn.*/
									/*;D1 - pixel offset to draw first line at.*/
									/*;D2 - amount to scroll before doing any drawing.*/
									/*;D3 - number of lines of data to draw.*/
	WORD	versionnumber;			/*;Make SURE this is set to zero. */
	LONG	rfu1;					/*;Make SURE you leave these two zeroed also. */
	LONG	rfu2;					/*;Make SURE you leave these two zeroed also. */
};


struct chipstuff {
	char	ArrowUp[20];		/* 16 pixels wide, 10 pixels high. */
	char	ArrowDown[20];		/* 16 pixels wide, 10 pixels high. */
	char	ArrowLeft[18];		/* 16 pixels wide, 9 pixels high. */
	char	ArrowRight[18];		/* 16 pixels wide, 9 pixels high. */
	char	Letter_R[20];		/* 16 pixels wide, 10 pixels high. */
	char	Letter_G[20];		/* 16 pixels wide, 10 pixels high. */
	char	Letter_B[20];		/* 16 pixels wide, 10 pixels high. */
	char	Letter_H[20];		/* 16 pixels wide, 10 pixels high. */
	char	Letter_S[20];		/* 16 pixels wide, 10 pixels high. */
	char	Letter_V[20];		/* 16 pixels wide, 10 pixels high. */
};

struct ReqLib {
	struct Library RLib;
	struct AbsExecBase		*SysLib;
	struct DosBase			*DosLib;
	struct IntuitionBase	*IntuiLib;
	struct GfxBase			*GfxLib;
	APTR					SegList;
	struct chipstuff		*Images;
	BYTE					Flags;
	BYTE					Pad;
	char					*ConsoleDev;	/* Not really a char*, but it should work */
	struct	IOStdReq		*ConsoleHandle;
};


/* Prototypes */

void Center(struct NewWindow *,int,int);

short SetSize(long,long);
long SetLocation(long,long,long);
long ReadLocation(long,long,short);

void Format(char *,char *,...);						/* No pragmas */

void SimpleRequest(char *title,char *fmt,...);		/* No pragmas */
short TwoGadRequest(char *title,char *fmt,...);		/* No pragmas */

short FileRequester(struct FileReq *);
void PurgeFiles(struct FileReq *);

short ColorRequester(long);
short ExtendedColorRequester(struct ExtendedColorRequester *);

void MakeGadget(struct GadgetBlock *,char *,ULONG,ULONG);
void MakeString(struct StringBlock *,char *,char *,ULONG,ULONG,long,long);
void MakeProp(struct PropBlock *,ULONG,ULONG,ULONG);
void MakeButton(struct TwoImageGadget *,struct Image *,struct Image *,long,long,long);

void MakeScrollBar(struct ScrollBlock *,long,long,long,long);

void LinkGadget(struct GadgetBlock *,char *,struct NewWindow *,long,long);
void LinkStringGadget(struct StringBlock *,char *,char *,struct NewWindow *,long,long,long,long);	/* No pragmas */
void LinkPropGadget(struct PropBlock *,struct NewWindow *,long,long,long,long,long);				/* No pragmas */

void DrawBox(struct RastPort *,long,long,long,long);

/* GetFontHeightAndWidth()			No access from C language (two results) */

void RealTimeScroll(struct ScrollStruct *);

short TextRequest(struct TRStructure *);

BOOL GetString(char *,char *,struct Window *,long,long);
BOOL GetLong(struct GetLongStruct *);

char RawKeyToAscii(long,long,APTR);

BOOL NewGetString(struct GetStringStruct *);

/************************************************************************
 *	Check if we should do the pragmas...								*
 ************************************************************************/

#ifndef	NO_PRAGMAS

	/* for Lattice */
	#ifdef LATTICE
		#ifndef PROTO_REQ_H
			#include <Proto/req.h>
		#endif
	#endif

	/* for Manx 5.0 */
	#ifdef AZTEC_C
		#ifndef	REQ_PRAGMAS_H
			#include <req_pragmas.h>
		#endif
	#endif

#endif

#endif
