/*	XModule.h
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Use 4 chars wide TABs to read this source
**
**	Public structures, constants & external variables definition.
*/

#ifndef	DOS_DOS_H
#include <dos/dos.h>
#endif /* DOS_DOS_H */

#ifndef	EXEC_NODES_H
#include <exec/nodes.h>
#endif /* EXEC_NODES_H */

#include <string.h>
#include "XModule_rev.h"
#include "Locale.h"


/* Version information: updated auto-magically on every compilation ;-) */

#define XMODULEVER	VERS
#define XMODULEDATE	"(" DATE ")"
#define XMODULECOPY	"Copyright © 1993,94,95 by Bernardo Innocenti"



/*************************/
/* Constants Definitions */
/*************************/

/* Maximum values */
#define MAXINSTRUMENTS	 64			/* Maximum number of instruments loaded			*/
#define MAXTABLENOTE	 (12*6+1)	/* Number of entries in note conversion table	*/
#define MAXTABLEEFFECTS	 20			/* Number of entries in effect conversion table	*/
#define MAXPATTERNS		128			/* Maximum number of patterns					*/
#define MAXTRACKS		 32			/* Maximum number of tracks in a pattern		*/
#define MAXPATTLINES  32768			/* Maximum number of lines in a pattern			*/
#define MAXPOSITIONS  32768			/* Maximum number of song positions				*/
#define MAXINSTNAME		 32
#define MAXSONGNAME		 32
#define MAXAUTHNAME		 64
#define MAXPATTNAME		 16
#define	SEQUENCE_QUANTUM 32			/* Multiples of SEQUENCE_QUANTUM positions are
									 * allocated in the sequence array
									 */

#define PATHNAME_MAX	108			/* Maximum length of an AmigaDOS path name		*/

/* Default values */
#define DEF_PATTLEN		 64
#define DEF_NUMTRACKS	  4
#define DEF_SONGSPEED	  6
#define DEF_SONGTEMPO	125


/* Specific error return values */
#define ERR_NOTMODULE	ERROR_OBJECT_WRONG_TYPE	/* File format not recognized		*/
#define ERR_READWRITE	100						/* Read() or Write() had a problem,
												 * check IoErr() for details.
												 */


/***********************************/
/* Module formats known by XModule */
/***********************************/

enum {
	FMT_XMODULE,
	FMT_NTRACKER,
	FMT_PTRACKER,
	FMT_STRACKER,
	FMT_OKTALYZER,
	FMT_MED,
	FMT_OCTAMED,
	FMT_TAKETRACKER,
	FMT_SCREAMTRACKER,
	FMT_STARTREKKER,
	FMT_MIDI,
	FMT_FASTTRACKER2,			/* TODO */
	FMT_SMUS,					/* TODO */
	FMT_TEX,					/* TODO */

	FMT_UNKNOWN = -1
};



/***********/
/* Effects */
/***********/

#ifndef XMODULE_CLASS_H
enum {
	EFF_NULL,				/* $00 */
	EFF_PORTAMENTOUP,		/* $01 */
	EFF_PORTAMENTODOWN,		/* $02 */
	EFF_TONEPORTAMENTO,		/* $03 */
	EFF_VIBRATO,			/* $04 */
	EFF_TONEPVOLSLIDE,		/* $05 */
	EFF_VIBRATOVOLSLIDE,	/* $06 */
	EFF_TREMOLO,			/* $07 */
	EFF_UNUSED,				/* $08 */
	EFF_SAMPLEOFFSET,		/* $09 */
	EFF_VOLSLIDE,			/* $0A */
	EFF_POSJUMP,			/* $0B */
	EFF_SETVOLUME,			/* $0C */
	EFF_PATTERNBREAK,		/* $0D */
	EFF_MISC,				/* $0E */
	EFF_SETSPEED,			/* $0F */
	EFF_SETTEMPO,			/* $10 */
	EFF_ARPEGGIO,			/* $11 */

	EFF_COUNT				/* $12 */
};
#endif /* XMODULE_CLASS_H */



/*************************/
/* Structure definitions */
/*************************/

struct Instrument
{
	UWORD	 InstType;			/* Instrument type (See defs)	*/
	UWORD	 Volume;			/* Volume (max $40)				*/
	UBYTE	 Name[MAXINSTNAME];	/* Instrument Name				*/
	BYTE	*SampleData;		/* Sampled data					*/
	ULONG	 Length;			/* Length of instr				*/
	ULONG	 Repeat;			/* Loop start (No loop = 0)		*/
	ULONG	 Replen;			/* Loop size (No loop = 1)		*/
	WORD	 FineTune;			/* Instrument FineTune (-8..+7)	*/
	UWORD	 Flags;				/* Unused						*/
};



/* Instrument->InstType */
#ifndef XMODULE_CLASS_H
enum {
	ITYPE_SAMPLE8,		/* 8 bit sampled waveform				*/
	ITYPE_SAMPLE16,		/* TODO: 16 bit sampled waveform		*/
	ITYPE_SYNTH,		/* TODO: Synthetic instrument			*/
	ITYPE_HYBRID,		/* TODO: Both Synth & Sample			*/
	ITYPE_MIDI			/* TODO: Played by external MIDI device	*/
};
#endif /* XMODULE_CLASS_H */



/* Pass this value to AllocVec() to allocate sample memory */
#define MEMF_SAMPLE	MEMF_ANY


#ifndef XMODULE_CLASS_H
struct Note
{
	UBYTE Note;
	UBYTE Inst;
	UBYTE EffNum;
	UBYTE EffVal;
};
#endif /* XMODULE_CLASS_H */



struct Pattern
{
	UWORD	Tracks;					/* Support for variable number of tracks	*/
	UWORD	Lines;					/* Number of lines in pattern				*/
	UBYTE	PattName[MAXPATTNAME];
	struct Note *Notes[MAXTRACKS];	/* Pointers to the lines					*/
};



struct SongInfo
{
	struct Node Link;			/* Link for the song list					*/
	UWORD	Length;				/* Number of positions in song				*/
	UWORD	MaxTracks;			/* Number of tracks in song					*/
	UWORD	NumPatterns;		/* Number of patterns in song				*/
	UWORD	NumInstruments;		/* Unused									*/
	UWORD	GlobalSpeed;		/* Default song speed						*/
	UWORD	GlobalTempo;		/* Default song tempo						*/
	UWORD	Restart;			/* Position to restart from					*/
	UWORD	CurrentPatt;
	UWORD	CurrentPos;
	UWORD	CurrentInst;
	UWORD	Flags;				/* See definitions below					*/

	/* Data beyond this is longword aligned */

	ULONG	Changes;			/* Number of changes made to this song		*/
	UWORD	*Sequence;			/* Pointer to song sequence					*/
	struct Pattern PattData[MAXPATTERNS];
	struct Instrument Inst[MAXINSTRUMENTS];
	UBYTE	ActiveTracks[MAXTRACKS];	/* Active Tracks (0 = disabled)		*/
	UBYTE	SongName[MAXSONGNAME];		/* Song name						*/
	UBYTE	Author[MAXAUTHNAME];		/* Author of song					*/
	UBYTE	SongPath[PATHNAME_MAX];		/* Original song path				*/
	void	*Pool;						/* The memory pool where song data
										 * must be allocated from.
										 */
};

/* Flags for SongInfo->Flags */

/* No flags are defined yet */



/***********************/
/* Function Prototypes */
/***********************/

/* From "App.c" */
void	HandleAppMessage		(void);
void	AddAppWin				(struct WinUserData *wud);
void	RemAppWin				(struct WinUserData *wud);
LONG	CreateAppIcon			(void (*handler) (struct AppMessage *am));
void	DeleteAppIcon			(void);
void	Iconify					(void);
void	DeIconify				(void);
LONG	SetupApp				(void);
void	CleanupApp				(void);

/* From "Audio.c" */
void	HandleAudio				(void);
void	PlaySample				(BYTE *samp, ULONG len, UWORD vol, UWORD per);
ULONG	SetupAudio				(void);
void	CleanupAudio			(void);

/* From "Misc.c" */
struct Library *MyOpenLibrary	(STRPTR name, ULONG ver);
void	CantOpenLib				(STRPTR name, LONG vers);
void	KillMsgPort				(struct MsgPort *mp);
struct TextAttr *CopyTextAttr	(struct TextAttr *source, struct TextAttr *dest);
UWORD	CmpTextAttr				(struct TextAttr *ta1, struct TextAttr *ta2);
void	FilterName				(STRPTR name);
struct DiskObject *GetProgramIcon (void);
LONG	PutIcon					(STRPTR source, STRPTR dest);
void	InstallGfxFunctions		(void);

/* From "Gui.c" (More functions prototyped in "Gui.h") */
LONG	HandleGui				(void);

/* From "Rexx.c" */
void	HandleRexxMsg			(void);
LONG	CreateRexxPort			(void);
void	DeleteRexxPort			(void);

/* From "Requesters.c" */
STRPTR	FileRequest				(ULONG freq, STRPTR file);
LONG	StartFileRequest		(ULONG freq, void (*func)(STRPTR file, ULONG num, ULONG count));
void	HandleFileRequest		(void);
LONG	ShowRequestStr			(STRPTR text, STRPTR gtext, APTR args);
LONG	ShowRequestArgs			(ULONG msg, ULONG gadgets, APTR args);
LONG	ShowRequest				(ULONG msg, ULONG gadgets, ...);
void	FreeFReq				(void);
LONG	SetupRequesters			(void);
LONG	ScrModeRequest			(struct ScrInfo *scrinfo);
LONG	FontRequest				(struct TextAttr *ta, ULONG flags);

/* From "ToolBoxWin.c" */
void ToolBoxOpenModule			(STRPTR file, ULONG num, ULONG count);

/* From "OptimizationWin.c" */
void OptPerformClicked			(void);

/* From "Help.c" */
void HandleHelp					(struct IntuiMessage *msg);
void HandleAmigaGuide			(void);
void CleanupHelp				(void);

/* From "Cx.c" */
LONG	SetupCx					(void);
void	HandleCx				(void);
void	CleanupCx				(void);

/* From "ProgressWin.c" */
void	DisplayAction			(ULONG msg);
LONG	DisplayProgress			(LONG Num, LONG Max);
void	ShowMessage				(ULONG msg, ...);
void	ShowString				(STRPTR s, LONG *args);
void	ShowFault				(ULONG msg, BOOL req);

/* From "PlayWin.c" */
LONG	SetupPlayer				(void);
void	CleanupPlayer			(void);

/* From "Compress.c" */
BPTR	DecompressFile			(STRPTR name, UWORD type);
void	DecompressFileDone		(void);
LONG	CruncherType			(BPTR file);

/* From "Instr.c" */
LONG	LoadInstrument			(struct Instrument *inst, const STRPTR filename);
LONG	SaveInstrument			(struct Instrument *inst, const STRPTR filename);
LONG	Load8SVXInstrument		(struct Instrument *inst, struct IFFHandle *iff);
LONG	Save8SVXInstrument		(struct Instrument *inst, struct IFFHandle *iff);
void	FreeInstr				(struct Instrument *inst);
void	OptimizeInstruments		(struct SongInfo *si);
void	RemDupInstruments		(struct SongInfo *si);
void	RemUnusedInstruments	(struct SongInfo *si);
void	RemapInstruments		(struct SongInfo *si);
void	SampChangeSign8			(UBYTE *samp, ULONG len);

/* From "Song.c" */
struct SongInfo *AllocSongInfo	(void);
void			 FreeSongInfo	(struct SongInfo *si);
void			 FixSong		(struct SongInfo *si);
void			 GuessAuthor	(struct SongInfo *si);
UWORD			*SetSongLen		(struct SongInfo *si, ULONG len);
struct SongInfo *NewSong		(void);
struct SongInfo *LoadModule		(struct SongInfo *oldsong, const STRPTR name);
LONG			 SaveModule		(struct SongInfo *si, const STRPTR name, UWORD type);
ULONG			 CalcInstSize	(struct SongInfo *si);
ULONG			 CalcSongSize	(struct SongInfo *si);
ULONG			 CalcSongTime	(struct SongInfo *si);

/* From "Operators.c" */
UWORD			 InsertPattern	(struct SongInfo *si, UWORD patnum);
struct SongInfo *MergeSongs		(struct SongInfo *songa, struct SongInfo *songb);
struct SongInfo *JoinSongs		(struct SongInfo *songa, struct SongInfo *songb);
void			 RemovePattern	(struct SongInfo *si, UWORD patnum, UWORD newpatt);
void			 RemDupPatterns (struct SongInfo *si);
void			 DiscardPatterns (struct SongInfo *si);
void			 CutPatterns	(struct SongInfo *si);
UWORD			 AllocTracks	(struct Note **arr, UWORD lines, UWORD tracks);	/* Note the reversed order! */
void			 FreeTracks		(struct Note **arr, UWORD lines, UWORD tracks);	/* Note the reversed order! */
struct Pattern	*AddPattern		(struct SongInfo *si, UWORD tracks, UWORD lines);
LONG			 CopyPattern	(struct Pattern *src, struct Pattern *dest);

/* From Prefs.c */
LONG			LoadPrefs		(const STRPTR filename);
LONG			SavePrefs		(const STRPTR filename);

/* From Locale.c */
void			SetupLocale		(void);
void			CleanupLocale	(void);

/* From SaveXModule.c */
LONG			SaveXModule		(struct SongInfo *si, BPTR fh);
LONG			SaveSong		(struct IFFHandle *iff, struct SongInfo *si);
LONG			SaveSequence	(struct IFFHandle *iff, struct SongInfo *si);
LONG			SavePatterns	(struct IFFHandle *iff, struct SongInfo *si);
LONG			SaveInstruments	(struct IFFHandle *iff, struct SongInfo *si, UWORD lastinstr);
LONG			SavePattern		(struct IFFHandle *iff, struct Pattern *patt);
LONG			WriteNameChunk	(struct IFFHandle *iff, STRPTR name);

/* From GetXModule.c */
LONG			GetXModule		(struct SongInfo *si, BPTR fh);
LONG			GetSong			(struct IFFHandle *iff, struct SongInfo *si);
LONG			GetPattern		(struct IFFHandle *iff, struct Pattern *patt);

/* From "GetTracker.c" */
LONG			GetTracker		(struct SongInfo *si, BPTR fp, UWORD st_type);
LONG			IsTracker		(BPTR file);

/* From "GetOktalyzer.c" */
LONG			GetOktalyzer	(struct SongInfo *si, BPTR fp);

/* From "GetMED.c" */
LONG			GetMED			(struct SongInfo *si, BPTR fp);

/* From "SaveTracker.c" */
LONG			SaveTracker		(struct SongInfo *si, BPTR fs, UWORD st_type);

/* From "SaveOktalyzer.c" */
LONG			SaveOktalyzer	(struct SongInfo *si, BPTR fp);

/* From "SaveMED.c" */
LONG			SaveMED			(struct SongInfo *si, BPTR fp, UWORD med_type);

/* From "GetS3M.c" */
LONG			GetS3M			(struct SongInfo *si, BPTR fp);

/* From "SaveMIDI.c" */
UWORD			SaveMIDI		(struct SongInfo *si, BPTR fp);

/* From "Startup.asm" */
extern void		_XCEXIT			(LONG err);
extern void		SPrintf			(UBYTE *buff, const STRPTR formatstr, ...);
extern void __stdargs VSPrintf	(UBYTE *buff, const STRPTR formatstr, void *argv);


/* Memory pools support */

#define AllocPooled(p,s)	AsmAllocPooled(p, s, SysBase)
#define FreePooled(p,m,s)	AsmFreePooled(p, m, s, SysBase)
#define AllocVecPooled(p,s)	AsmAllocVecPooled(p, s, SysBase)
#define FreeVecPooled(p,m)	AsmFreeVecPooled(p, m, SysBase)
#define CAllocPooled(p,s)	AsmCAllocPooled(p, s, SysBase)

extern __asm void *AsmAllocPooled		(register __a0 void *pool, register __d0 ULONG size, register __a6 struct ExecBase *SysBase);
extern __asm void *AsmFreePooled		(register __a0 void *pool, register __a1 void *drop, register __d0 ULONG size, register __a6 struct ExecBase *SysBase);
extern __asm void *AsmCAllocPooled		(register __a0 void *pool, register __d0 ULONG size, register __a6 struct ExecBase *SysBase);
extern __asm void *AsmAllocVecPooled	(register __a0 void *pool, register __d0 ULONG size, register __a6 struct ExecBase *SysBase);
extern __asm void *AsmFreeVecPooled		(register __a0 void *pool, register __a1 void *drop, register __a6 struct ExecBase *SysBase);


/* Use these macros if the corresponding functions are not available. */
extern ULONG (*ReadAPen)(struct RastPort *RPort);
extern ULONG (*ReadBPen)(struct RastPort *RPort);
extern ULONG (*ReadDrMd)(struct RastPort *RPort);

/* Other functions */
#ifdef __SASC
#define min(a,b) __builtin_min(a,b)
#define max(a,b) __builtin_max(a,b)
#endif /* __SASC */

/********************/
/* Global variables */
/********************/

extern struct ExecBase		*SysBase;
extern struct Library		*DOSBase;
extern struct IntuitionBase	*IntuitionBase;
extern struct GfxBase		*GfxBase;
extern struct Library		*LayersBase;
extern struct Library		*UtilityBase;
extern struct Library		*GadToolsBase;
extern struct Library		*AslBase;
extern struct Library		*ReqToolsBase;
extern struct Library		*IFFParseBase;
extern struct Library		*WorkbenchBase;
extern struct Library		*IconBase;
extern struct Library		*DiskfontBase;
extern struct Library		*CxBase;
extern struct Library		*KeymapBase;
extern struct Library		*LocaleBase;

extern struct SongInfo		*songinfo;
extern UBYTE				 Effects[MAXTABLEEFFECTS][4];
extern const UWORD			 TrackerNotes[];
extern const ULONG			 TakeTrackerIDs[32];

extern struct WBStartup		*WBenchMsg;
extern struct Process		*ThisTask;
extern void					*Pool;
extern struct Catalog		*Catalog;
extern STRPTR	AppStrings[];
extern BOOL 	Kick30;
extern BOOL		Verbose;
extern BPTR		StdOut;
extern LONG		LastErr;
extern UBYTE	PubPortName[];

extern BYTE		CxPri;
extern UBYTE	CxPopKey[32];
extern BOOL		CxPopup;

extern LONG		IconX;
extern LONG		IconY;
extern UBYTE	IconName[16];

extern UBYTE	Version[];
extern UBYTE	BaseName[];	/* All caps		*/
extern UBYTE	PrgName[];	/* Mixed case	*/

/* End XModule.h */
