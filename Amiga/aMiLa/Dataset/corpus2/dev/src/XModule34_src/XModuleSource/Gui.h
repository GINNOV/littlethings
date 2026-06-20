/*
**	Gui.h
**
**	Copyright (C) 1993,94,95 by Bernardo Innocenti
**
**	Various definitions for the user interface.
*/


/***************/
/* WinUserData */
/***************/

/* This structure holds data needed to handle windows
 * in a nice Object oriented way (no more switchs)
 */

struct WinUserData
{
	struct MinNode		 Link;	/* Used to mantain a list of opened windows. */

	struct Window		*Win;
	struct Gadget		**Gadgets;
	UBYTE				*Keys;
	struct IBox			 WindowZoom;
	struct AppWindow	*AppWin;
	struct TextAttr		*Attr;
	struct TextFont		*Font;
	LONG				 WUDFlags;

	/* Window specific functions called in case of IDCMP_REFRESHWINDOW, IDCMP_CLOSEWINDOW,
	 * AppMessage or special IDCMP messages.
	 */
	void (*RenderWin)(void);
	void (*CloseWin)(void);
	void (*DropIcon)(struct AppMessage *);
	void *IDCMPFunc;

	/* Data used during creation */
	struct Gadget		*GList;
	struct IBox			 WindowSize;
	struct NewMenu		*NewMenu;
	UWORD				*GTypes;
	struct NewGadget	*NGad;
	ULONG				*GTags;
	ULONG				 GCount;
	ULONG				 Flags;
	ULONG				 IDCMPFlags;
	STRPTR				 Title;
};


/* Flags for WinUserData->WUDFlags */

#define WUDF_REOPENME	(1<<0)


/* the WUDS structure is used to make an array of all
 * windows with the related OpenXxxWindow() functions.
 */
struct WUDS
{
	struct WinUserData *Wud;
	LONG (*OpenWin)(void);
};



/* This structure is used by LockWindows() to
 * track modifications made to the windows.
 */
struct WindowLock
{
	struct Requester	Req;
	ULONG				OldIDCMPFlags;
	UWORD				OldMinWidth,
						OldMinHeight,
						OldMaxWidth,
						OldMaxHeight;
};



/***********/
/* ScrInfo */
/***********/

struct ScrInfo
{
    ULONG	DisplayID;		/* Display mode ID				*/
    ULONG	Width;			/* Width of display in pixels	*/
    ULONG	Height;			/* Height of display in pixels	*/
    UWORD	Depth;			/* Number of bit-planes			*/
    UWORD	OverscanType;	/* Type of overscan of display	*/
    BOOL	AutoScroll;		/* Display should auto-scroll?	*/
	BOOL	OwnPalette;
	UWORD	Colors[32];
	UBYTE PubScreenName[32];
};



/*******************/
/* File requesters */
/*******************/

/* This structure is used to reference all the file requesters.
 */
struct XMFileReq
{
	APTR	FReq;		/* Real file requester (ASL or ReqTools)				*/
	ULONG	Title;		/* Message number for title								*/
	ULONG	Flags;		/* FRF_DOSAVEMODE, FRF_DOPATTERNS, FRF_DOMULTISELECT...	*/
};

enum
{
	FREQ_LOADMOD,
	FREQ_SAVEMOD,
	FREQ_LOADINST,
	FREQ_SAVEINST,
	FREQ_LOADPATT,
	FREQ_SAVEPATT,
	FREQ_LOADMISC,
	FREQ_SAVEMISC,

	FREQ_COUNT
};



/************/
/* Switches */
/************/


struct ClearSwitches
{
	BOOL	ClearPatt,
			ClearSeq,
			ClearInstr;
};

struct SaveSwitches
{
	UWORD	SaveType;
	BOOL	SavePatt,
			SaveSeq,
			SaveInstr,
			SaveIcons,
			SaveNames;
};

struct OptSwitches
{
	BOOL	RemPatts,
			RemDupPatts,
			RemInstr,
			CutAfterLoop,
			CutEndZero;
};

struct GuiSwitches
{
	BOOL	SaveIcons,
			AskOverwrite,
			AskExit,
			Verbose,
			ShowAppIcon,
			UseReqTools,
			SmartRefresh,
			UseDataTypes,
			InstrSaveIcons;
	UWORD	InstrSaveMode;
	UWORD	SampDrawMode;
};

struct PattSwitches
{
	ULONG	TextPen, LinesPen, TinyLinesPen;
	ULONG	MaxUndoLevels,	MaxUndoMem;
	ULONG	Flags;							/* See <patteditclass.h> for possble flags */
	WORD	AdvanceTracks,	AdvanceLines;
	WORD	VScrollerPlace,	HScrollerPlace;
	UBYTE	ClipboardUnit,	Backdrop;
};


/* Instrument save modes */
enum {
	INST_8SVX,
	INST_8SVX_FIB,
	INST_RAW,
	INST_XPK
};


// Handy macros to get a gadget string/number

#define GetString(g)      (((struct StringInfo *)g->SpecialInfo)->Buffer)
#define GetNumber(g)      (((struct StringInfo *)g->SpecialInfo)->LongInt)


// Some handy definitions missing in <devices/inputevent.h>

#define IEQUALIFIER_SHIFT	(IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT)
#define IEQUALIFIER_ALT		(IEQUALIFIER_LALT | IEQUALIFIER_RALT)
#define IEQUALIFIER_COMMAND	(IEQUALIFIER_LCOMMAND | IEQUALIFIER_RCOMMAND)


// Any break flag

#define SIGBREAKFLAGS (SIGBREAKF_CTRL_C | SIGBREAKF_CTRL_D | SIGBREAKF_CTRL_E | SIGBREAKF_CTRL_F)


// XModule custom gadget Tags

/*	ti_Data is a pointer to a setup function for custom gadgets.
 *	It receives the newly allocated Gadget structure and should customize
 *	all fields it is interested in, as well as doing all necessary
 *	allocations and precalculations needed for the custom gadget.
 *	When the XMGAD_BoopsiClass tag is specified, SetupFunc() receves the
 *	BOOPSI class pointer and the NewGadget structure associated with the
 *	gadget.  SetupFunc() should return a pointer to the BOOPSI Gadget
 *	it has allocated.
 */
#define XMGAD_SetupFunc	(TAG_USER+1)


/*	ti_Data points to the BOOPSI class to pass to SetupFunc().  When this
 *	tag is specified, the gadget is _not_ allocated with the GadTools
 *	function CreateGadget(). When the window is closed with MyCloseWindow(),
 *	or when MyOpenWindow() fails after creating the object, it is your duty
 *	to DisposeObject() the gadget.
 */
#define XMGAD_BoopsiClass	(TAG_USER+2)



/********************/
/* External symbols */
/********************/

extern struct Screen	*Scr;
extern struct ScrInfo	 ScrInfo;
extern APTR				 VisualInfo;
extern struct DrawInfo	*DrawInfo;
extern CxObj			*MyBroker;
extern UWORD			 OffX, OffY;
extern UWORD			 WinLockCount;
extern ULONG			 UniqueID;
extern chip UWORD		 BlockPointer[];

extern struct IntuiMessage IntuiMsg;

extern struct MsgPort
	*WinPort,
	*PubPort,
	*AppPort,
	*FileReqPort,
	*CxPort;

extern struct TextAttr
	TopazAttr,
	ScreenAttr,
	WindowAttr,
	ListAttr,
	EditorAttr;

extern ULONG
	FileReqSig,
	AppSig,
	AudioSig,
	CxSig,
	AmigaGuideSig,
	PubPortSig,
	Signals;		// Global Wait() signals


extern struct Process *FileReqTask;
extern struct XMFileReq FileReqs[FREQ_COUNT];

extern struct WinUserData
	OptimizationWUD,
	InstrumentsWUD,
	SequenceWUD,
	ProgressWUD,
	LogWUD,
	PatternWUD,
	ClearWUD,
	SaveFormatWUD,
	ToolBoxWUD,
	SongInfoWUD,
	SampleWUD,
	PrefsWUD,
	PlayWUD,
	PattPrefsWUD,
	PattSizeWUD;

extern struct WUDS Wuds[];

extern struct List
	WindowList,
	InstrList,
	PatternsList,
	SequenceList,
	LogList,
	SongList;

extern struct SaveSwitches	SaveSwitches;
extern struct ClearSwitches	ClearSwitches;
extern struct OptSwitches	OptSwitches;
extern struct GuiSwitches	GuiSwitches;
extern struct PattSwitches	PattSwitches;

extern BOOL DoNextSelect;
extern BOOL ShowRequesters;
extern BOOL Iconified;
extern BOOL Quit;


/******************************************/
/* Window Open/Close function prototypes */
/******************************************/

LONG	OpenOptimizationWindow (void);
void	CloseOptimizationWindow (void);
LONG	OpenInstrumentsWindow (void);
void	CloseInstrumentsWindow (void);
LONG	OpenSequenceWindow (void);
void	CloseSequenceWindow (void);
LONG	OpenProgressWindow (void);
void	CloseProgressWindow (void);
LONG 	OpenLogWindow (void);
void 	CloseLogWindow (void);
LONG	OpenPatternWindow (void);
void	ClosePatternWindow (void);
LONG	OpenClearWindow (void);
void	CloseClearWindow (void);
LONG	OpenToolBoxWindow (void);
void	CloseToolBoxWindow (void);
LONG	OpenSongInfoWindow (void);
void	CloseSongInfoWindow (void);
LONG	OpenSampleWindow (void);
void	CloseSampleWindow (void);
LONG	OpenSaveFormatWindow (void);
void	CloseSaveFormatWindow (void);
LONG 	OpenPrefsWindow (void);
void	ClosePrefsWindow (void);
LONG 	OpenPlayWindow (void);
void	ClosePlayWindow (void);
LONG	OpenPattPrefsWindow (void);
void	ClosePattPrefsWindow (void);
LONG	OpenPattSizeWindow (void);
void	ClosePattSizeWindow (void);

/******************************/
/* Other functions prototypes */
/******************************/

void	UpdateInstrList		(void);
void	UpdateSongInfo		(void);
void	UpdatePatternList	(void);
void	UpdateSequenceList	(void);
void	UpdateSample		(void);
void	UpdateSampInfo		(void);
void	UpdateSampGraph		(void);
void	UpdateSampleMenu	(void);
void	UpdateGuiSwitches	(void);
void	UpdateInstrSwitches (void);
void	UpdateClearSwitches	(void);
void	UpdateSaveSwitches	(void);
void	UpdateOptSwitches	(void);
void	UpdatePrefsWindow	(void);
void	UpdatePattern		(void);
void	UpdateEditorInst	(void);
void	UpdatePlay			(void);
void	UpdatePattSize		(void);
void	UpdatePattPrefs		(void);

void	AddSongInfo			(struct SongInfo *si);
void	RemoveSongInfo		(struct SongInfo *si);
void	ToolBoxDropIcon		(struct AppMessage *msg);

void	LockWindows			(void);
void	UnlockWindows		(void);
void	RevealWindow		(struct WinUserData *wud);
void	SetGadgets			(struct WinUserData *wud, ULONG arg, ...);
void	RenderWindowTexts	(struct WinUserData *wud, struct IntuiText *texts, UWORD tnum);
void	RenderBevelBox		(struct WinUserData *wud, WORD x1, WORD y1, WORD x2, WORD y2);

LONG	AddListViewNodeA	(struct List *lv, STRPTR label, LONG *args);
LONG	AddListViewNode		(struct List *lv, STRPTR label, ...);
void	RemListViewNode		(struct Node *n);
struct Gadget *CreateGadgets	(struct WinUserData *wud);
struct Window *MyOpenWindow		(struct WinUserData *wud);
void	DeleteGadgets		(struct WinUserData *wud);
void	MyCloseWindow		(struct Window *win);
void	ReopenWindows		(void);
LONG	SetupScreen			(void);
void	CloseDownScreen		(void);
UWORD	ComputeX			(struct WinUserData *wud, UWORD value);
UWORD	ComputeY			(struct WinUserData *wud, UWORD value);
