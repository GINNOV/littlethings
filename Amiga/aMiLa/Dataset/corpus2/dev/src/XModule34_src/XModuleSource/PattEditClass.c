/*
**	PattEditClass.c
**
**	Copyright (C) 1995 Bernardo Innocenti
**
**	Pattern Editor gadget class
*/

#include <string.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/nodes.h>
#include <exec/ports.h>
#include <utility/tagitem.h>
#include <utility/hooks.h>
#include <devices/inputevent.h>

#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>
#include <intuition/imageclass.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <graphics/text.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/keymap_protos.h>
#include <clib/alib_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/keymap_pragmas.h>

#include "XModule.h"
#include "PattEditClass.h"


/* Some handy definitions missing in <devices/inputevent.h> */
#define IEQUALIFIER_SHIFT	(IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT)
#define IEQUALIFIER_ALT		(IEQUALIFIER_LALT | IEQUALIFIER_RALT)
#define IEQUALIFIER_COMMAND	(IEQUALIFIER_LCOMMAND | IEQUALIFIER_RCOMMAND)



/* Private class instance data */

struct PattEditData
{
	struct Pattern	*Patt;
	struct TextFont	*EditorFont;
	struct Window	*MyWindow;

	/* These are the actual Gadget position and size,
	 * regardless of any GREL_#? flag.
	 */
	struct IBox		 GBounds;

	/* These are the actual editing area position and size. */
	struct IBox		 TBounds;

	UWORD			 FontXSize;
	UWORD			 FontYSize;

	/* Pens used to draw various pattern editor elements */
	ULONG			 LinesPen;
	ULONG			 TinyLinesPen;
	ULONG			 TextPen;

	ULONG			 Flags;			/* See definitions in <PattEditClass.h>			*/

	/* Routine used to convert a note into its ASCII representation
	 * This routine is passed the pointer to the note and a buffer
	 * with TRACKWIDTH characters to fill in.
	 */
	void			(*Note2ASCIIFunc)(struct Note *note, UBYTE *s);

	/* How many tracks and lines we can fit in the gadget bounds */
	UWORD			 DisplayTracks;
	UWORD			 DisplayLines;

	WORD			 LeftTrack;
	WORD			 TopLine;

	/* Current cursor position */
	WORD			 Track;
	WORD			 Line;
	WORD			 Column;

	UWORD			 CurrentInst;

	UWORD			 CursState;
	UWORD			 CursLinePos;	/* Cursor line position (0 = not drawn)			*/
	struct Rectangle CursRect;		/* Cursor Position to erase it quickly.			*/

	/* Cursor advancement */
	WORD			 AdvanceTracks;
	WORD			 AdvanceLines;

	/* Range marking info */
	UWORD			 RangeStartTrack;
	UWORD			 RangeStartLine;
	UWORD			 RangeEndTrack;
	UWORD			 RangeEndLine;

	/* Backup cursor position for mouse right button undo operation */
	WORD			 BackupTrack;
	WORD			 BackupLine;
	WORD			 BackupColumn;

	/* This variable holds a counter for the optimized scroller update.
	 * When the pattern is scrolling, updates are only sent after
	 * a specific amount of scrolling operations have occurred.
	 */
 	UWORD			 SliderCounter;

	struct Rectangle RangeRect;		/* Backup of range rect to erase it quickly. */


	/* Undo/Redo support */
	ULONG			 Changes;
	ULONG			 UndoCount;
	ULONG			 UndoMem;
	ULONG			 MaxUndoLevels;
	ULONG			 MaxUndoMem;
	struct MinList	 UndoList;
	struct MinList	 RedoList;

	/* For testing double click */
	ULONG			 DoubleClickSeconds;
	ULONG			 DoubleClickMicros;

	/* Experimental: timer.device stuff */
//	struct timerequest	TimerIO;
//	struct MsgPort		TimerPort;
//	struct Interrupt	TimerInt;
};


/* This structure holds an entry for the Undo/Redo buffer. */

struct UndoNode
{
	struct MinNode		Link;
	UWORD				Line,
						Track;
	struct Note	OldNote;
};



/* Function prototypes */

static ULONG __asm PattEditDispatcher (register __a0 Class *cl,
								register __a2 struct ExtGadget *g,
								register __a1 Msg msg);
static void		GetGadgetBox	(struct Window *win, struct ExtGadget *g, struct IBox *rect);
static BOOL		CalcDisplaySize	(struct PattEditData *ped, struct ExtGadget *g, struct GadgetInfo *gpi);
static void		SaveUndo		(struct PattEditData *ped);
static BOOL		UndoChange		(struct PattEditData *ped);
static BOOL		RedoChange		(struct PattEditData *ped);
static void		FreeUndoBuffers	(struct PattEditData *ped, BOOL freeall);
static BOOL		MoveCursor		(struct PattEditData *ped, WORD x, WORD y);
static void		EraseCursor		(struct RastPort *rp, struct PattEditData *ped);
static UWORD	DrawCursor		(struct RastPort *rp, struct PattEditData *ped, struct ExtGadget *g);
static void		DrawRange		(struct RastPort *rp, struct PattEditData *ped);
static void		ClearRange		(struct RastPort *rp, struct PattEditData *ped);
static void		RedrawAll		(struct RastPort *rp, struct PattEditData *ped, struct ExtGadget *g);
static void		RedrawPattern	(struct RastPort *rp, struct PattEditData *ped, struct ExtGadget *g);
static void		DrawTrackNumbers(struct RastPort *rp, struct PattEditData *ped);
static void		DrawPatternLines(struct RastPort *rp, struct PattEditData *ped, UWORD min, UWORD max);
static void		DrawNote		(struct RastPort *rp, struct PattEditData *ped);
static void		Note2ASCII		(struct Note *note, UBYTE *s);
static void		Note2ASCIIBlank0 (struct Note *note, UBYTE *s);
static UWORD	ScrollPattern	(struct RastPort *rp, struct PattEditData *ped, struct ExtGadget *g,
								UWORD lefttrack, UWORD topline);
static void		NotifyCursor	(struct ExtGadget *g, struct GadgetInfo *gi, ULONG flags);
static void		NotifyVSlider	(struct ExtGadget *g, struct GadgetInfo *gi, ULONG flags);
static void		NotifyHSlider	(struct ExtGadget *g, struct GadgetInfo *gi, ULONG flags);

//static void __asm TimerIntServer (register __a1 struct Gadget *g);

struct Library * __asm	_UserLibInit	(register __a6 struct Library *mybase);
void __asm				_UserLibCleanup	(register __a6 struct Library *mybase);
struct IClass * __asm	_GetEngine		(register __a6 struct Library *mybase);



/* Library data */

#ifdef _M68020
#define PATTVERS "_020"
#else
#define PATTVERS ""
#endif

const UBYTE LibName[] = "pattedit.gadget";
const UBYTE LibVer[] = { '$', 'V', 'E', 'R', ':', ' ' };
const UBYTE LibId[] = "pattedit.gadget" PATTVERS " 1.1 (20.4.95) © 1995 by Bernardo Innocenti";

/* Local data */

static const ULONG TextNotes[MAXTABLENOTE] =
{
	' -  ',
	'C-0 ', 'C#0 ', 'D-0 ', 'D#0 ', 'E-0 ', 'F-0 ',
	'F#0 ', 'G-0 ', 'G#0 ', 'A-0 ', 'A#0 ', 'B-0 ',

	'C-1 ', 'C#1 ', 'D-1 ', 'D#1 ', 'E-1 ', 'F-1 ',
	'F#1 ', 'G-1 ', 'G#1 ', 'A-1 ', 'A#1 ', 'B-1 ',

	'C-2 ', 'C#2 ', 'D-2 ', 'D#2 ', 'E-2 ', 'F-2 ',
	'F#2 ', 'G-2 ', 'G#2 ', 'A-2 ', 'A#2 ', 'B-2 ',

	'C-3 ', 'C#3 ', 'D-3 ', 'D#3 ', 'E-3 ', 'F-3 ',
	'F#3 ', 'G-3 ', 'G#3 ', 'A-3 ', 'A#3 ', 'B-3 ',

	'C-4 ', 'C#4 ', 'D-4 ', 'D#4 ', 'E-4 ', 'F-4 ',
	'F#4 ', 'G-4 ', 'G#4 ', 'A-4 ', 'A#4 ', 'B-4 ',

	'C-5 ', 'C#5 ', 'D-5 ', 'D#5 ', 'E-5 ', 'F-5 ',
	'F#5 ', 'G-5 ', 'G#5 ', 'A-5 ', 'A#5 ', 'B-5 '
};


/* Keyboard rawkeys -> notes conversion table */

static const UBYTE KeyNotes0[10] = { 0, 26, 28,  0, 31, 33, 35,  0, 38, 40};	/* (1..0) */
static const UBYTE KeyNotes1[10] = {25, 27, 29, 30, 32, 34, 36, 37, 39, 41};	/* (Q..]) */
static const UBYTE KeyNotes2[10] = { 0, 14, 16,  0, 19, 21, 23,  0, 26, 28};	/* (A..') */
static const UBYTE KeyNotes3[10] = {13, 15, 17, 18, 20, 22, 24, 25, 27, 29};	/* (Z../) */

static const UBYTE HexValues[20]	= {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F', 'G', 'H', 'I', 'J'};
static const UBYTE HexValuesNo0[20]	= {' ','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F', 'G', 'H', 'I', 'J'};



/*****************/
/* Library bases */
/*****************/

/* Get around a SAS/C bug which causes some annoying warnings
 * with the library bases defined below.
 */
#ifdef __SASC
#pragma msg 72 ignore push
#endif /* __SASC */

struct ExecBase			*SysBase		= NULL;
struct IntuitionBase	*IntuitionBase	= NULL;
struct GfxBase			*GfxBase		= NULL;
struct Library			*UtilityBase	= NULL;
struct Library			*KeymapBase		= NULL;

#ifdef __SASC
#pragma msg 72 pop
#endif /* __SASC */

static struct IClass	*PattEditClass	= NULL;


static ULONG __asm PattEditDispatcher (register __a0 Class *cl,
										register __a2 struct ExtGadget *g,
										register __a1 Msg msg)

/* PattEdit Class Dispatcher entrypoint.
 * Handle BOOPSI messages.
 */
{
	struct RastPort		*rp;
	struct PattEditData	*ped;
	struct TagItem		*ti;
	ULONG result = 0;


	switch (msg->MethodID)
	{
		case GM_GOACTIVE:

			ped = INST_DATA (cl, g);

			if (!ped->Patt)
			{
				result = GMR_NOREUSE;
				break;
			}

			g->Flags |= GFLG_SELECTED;

			/* Render active cursor */
			if (rp = ObtainGIRPort (((struct gpInput *)msg)->gpi_GInfo))
			{
				DrawCursor (rp, ped, g);
				ReleaseGIRPort (rp);
			}

			/* Do not process InputEvent when the gadget has been
			 * activated by ActivateGadget().
			 */
			if (!((struct gpInput *)msg)->gpi_IEvent)
			{
				result = GMR_MEACTIVE;
				break;
			}

			/* Note: The input event that triggered the gadget
			 * activation (usually a mouse click) should be passed
			 * to the GM_HANDLEINPUT method, so we fall down to it.
			 */

		case GM_HANDLEINPUT:
		{
			struct InputEvent *ie = ((struct gpInput *)msg)->gpi_IEvent;
			WORD	MouseX, MouseY;		/* Mouse coordinates relative to editing area bounds */
			BOOL	moved		= FALSE,
					change_note	= FALSE;
			UWORD	scrolled	= 0;

			result = GMR_MEACTIVE;
			ped = INST_DATA (cl, g);

			MouseX = ((struct gpInput *)msg)->gpi_Mouse.X + ped->GBounds.Left - ped->TBounds.Left;
			MouseY = ((struct gpInput *)msg)->gpi_Mouse.Y + ped->GBounds.Top - ped->TBounds.Top;

			switch (ie->ie_Class)
			{
				case IECLASS_TIMER:

					/* Timer events are used to keep scrolling
					 * when the mouse is outside the bounds of the
					 * gadget.  When a timer event is recevied and
					 * the mouse button is pressed, we scroll the
					 * cursor.
					 */
						if (ped->Flags & PEF_DRAGGING)
							moved = MoveCursor (ped, MouseX, MouseY);

					break;

				case IECLASS_RAWMOUSE:
				{
					BOOL double_click = FALSE;
					BOOL outside =
						(MouseX < 0) || (MouseX >= ped->TBounds.Width) ||
						(MouseY < 0) || (MouseY >= ped->TBounds.Height);

					switch (ie->ie_Code)
					{
						case MENUDOWN:

							/* Abort cursor dragging operation and restore
							 * old cursor position.
							 */
							if (ped->Flags & PEF_DRAGGING)
							{
								ped->Line	= ped->BackupLine;
								ped->Track	= ped->BackupTrack;
								ped->Column	= ped->BackupColumn;
								moved = TRUE;
								ped->Flags &= ~(PEF_DRAGGING | PEF_SCROLLING);
							}
							else result = GMR_REUSE;

							break;

						case SELECTUP:
							scrolled = 3;	/* Send final update to slider */
							ped->Flags &= ~(PEF_DRAGGING | PEF_SCROLLING);
							break;

						case SELECTDOWN:

							/* Check if mouse click is still over the gadget */

							if (outside)
							{
								/* Click outside editing area box:
								 * Check if click is really outside gadget box.
								 * If it is, deactivate the gadget and reuse the event.
								 * Notify application if it is interested in
								 * hearing IDCMP_GADGETUP codes.
								 */
								MouseX = ((struct gpInput *)msg)->gpi_Mouse.X;
								MouseY = ((struct gpInput *)msg)->gpi_Mouse.Y;

								if	((MouseX < 0) || (MouseX >= ped->GBounds.Width) ||
									(MouseY < 0) || (MouseY >= ped->GBounds.Height))
									result = GMR_REUSE | GMR_VERIFY;
								break;
							}
							else
							{
								/* Backup cursor position for undo feature */
								ped->BackupLine		= ped->Line;
								ped->BackupTrack	= ped->Track;
								ped->BackupColumn	= ped->Column;

								/* Start cursor drag mode */
								ped->Flags |= PEF_DRAGGING;
							}

							/* Check for double clicking */

							if (DoubleClick (ped->DoubleClickSeconds, ped->DoubleClickMicros,
								ie->ie_TimeStamp.tv_secs, ie->ie_TimeStamp.tv_micro))
								double_click = TRUE;

							ped->DoubleClickSeconds	= ie->ie_TimeStamp.tv_secs;
							ped->DoubleClickMicros	= ie->ie_TimeStamp.tv_micro;

							/* NOTE: I'm falling through here! */

						default:

/*							if ((outside) && (ped->Flags & PEF_DRAGGING) && !(ped->Flags & PEF_SCROLLING))
							{
								ped->Flags |= PEF_SCROLLING;

								ped->TimerIO.tr_node.io_Command = TR_ADDREQUEST;
								ped->TimerIO.tr_time.tv_micro = 100000;
								BeginIO ((struct IORequest *)&ped->TimerIO);
							}
							else */

							if ((!outside) && (ped->Flags & PEF_DRAGGING))
								moved = MoveCursor (ped, MouseX, MouseY);

							if (!moved && double_click)
							{
								if (ped->Flags & PEF_MARKING)
									ped->Flags &= ~PEF_MARKING;
								else
								{
									ped->Flags |= PEF_MARKING;
									ped->RangeStartLine = ped->Line;
									ped->RangeStartTrack = ped->Track;
								}

								if (rp = ObtainGIRPort (((struct gpInput *)msg)->gpi_GInfo))
								{
									if (!(ped->Flags & PEF_MARKING))
										ClearRange (rp, ped);

									DrawCursor (rp, ped, g);

									ReleaseGIRPort (rp);
								}
							}

							break;
					}
					break;
				}

				case IECLASS_RAWKEY:

					if (ie->ie_Code & IECODE_UP_PREFIX)
					{
						/* Send final update to slider */

						if ((ie->ie_Code == (IECODE_UP_PREFIX | CURSORUP))
							|| (ie->ie_Code == (IECODE_UP_PREFIX | CURSORDOWN)))
							scrolled = 1;
						else if ((ie->ie_Code == (IECODE_UP_PREFIX | CURSORLEFT))
							|| (ie->ie_Code == (IECODE_UP_PREFIX | CURSORRIGHT)))
							scrolled = 2;
					}
					else if ((ie->ie_Qualifier & IEQUALIFIER_COMMAND) && (ie->ie_Code != 0x67))
						result = GMR_REUSE;
					else switch (ie->ie_Code)
					{
						case CURSORUP:

							if (ped->Line)
							{
								if (ie->ie_Qualifier & IEQUALIFIER_SHIFT)
								{
									if (ped->Line > ped->TopLine)
										ped->Line = ped->TopLine;
									else
										if (ped->Line >= ped->DisplayLines - 1)
											ped->Line -= ped->DisplayLines - 1;
										else ped->Line = 0;
								}
								else if (ie->ie_Qualifier & IEQUALIFIER_ALT)
									ped->Line = 0;
								else ped->Line--;

								moved = TRUE;
							}
							else if (ped->Flags & PEF_VWRAP)
							{
								ped->Line = ped->Patt->Lines - 1;
								moved = TRUE;
							}

							break;


						case CURSORDOWN:

							if (ped->Line < ped->Patt->Lines - 1)
							{
								if (ie->ie_Qualifier & IEQUALIFIER_SHIFT)
								{
									if (ped->Line < ped->TopLine + ped->DisplayLines - 1)
										ped->Line = ped->TopLine + ped->DisplayLines - 1;
									else
									{
										ped->Line += ped->DisplayLines - 1;
										if (ped->Line > ped->Patt->Lines - 1)
											ped->Line = ped->Patt->Lines - 1;
									}
								}
								else if (ie->ie_Qualifier & IEQUALIFIER_ALT)
									ped->Line = ped->Patt->Lines - 1;
								else ped->Line++;

								moved = TRUE;
							}
							else if (ped->Flags & PEF_VWRAP)
							{
								ped->Line = 0;
								moved = TRUE;
							}

							break;


						case CURSORLEFT:

							if (ie->ie_Qualifier & IEQUALIFIER_SHIFT)
							{
								if (ped->Track)
								{
									ped->Track--;
									moved = TRUE;
								}
								else if (ped->Column)
								{
									ped->Column = 0;
									moved = TRUE;
								}
							}
							else if (ie->ie_Qualifier & IEQUALIFIER_ALT)
							{
								if (ped->Track)
								{
									ped->Track = 0;
									moved = TRUE;
								}
								else if (ped->Column)
								{
									ped->Column = 0;
									moved = TRUE;
								}
							}
							else
							{
								if (ped->Column)
								{
									ped->Column--;
									moved = TRUE;
								}
								else if (ped->Track)
								{
									ped->Track--;
									ped->Column = COL_COUNT-1;
									moved = TRUE;
								}
							}

							if (!moved && (ped->Flags & PEF_HWRAP))
							{
								ped->Track = ped->Patt->Tracks - 1;
								ped->Column = COL_COUNT-1;
								moved = TRUE;
							}

							break;


						case CURSORRIGHT:

							if (ie->ie_Qualifier & IEQUALIFIER_SHIFT)
							{
								if (ped->Track < ped->Patt->Tracks - 1)
								{
									ped->Track++;
									moved = TRUE;
								}
								else if (ped->Column != COL_COUNT-1)
								{
									ped->Column = COL_COUNT-1;
									moved = TRUE;
								}
							}
							else if (ie->ie_Qualifier & IEQUALIFIER_ALT)
							{
								if (ped->Track != ped->Patt->Tracks - 1)
								{
									ped->Track = ped->Patt->Tracks - 1;
									moved = TRUE;
								}
								else if (ped->Column != COL_COUNT-1)
								{
									ped->Column = COL_COUNT-1;
									moved = TRUE;
								}
							}
							else
							{
								if (ped->Column < COL_COUNT-1)
								{
									ped->Column++;
									moved = TRUE;
								}
								else if (ped->Track < ped->Patt->Tracks - 1)
								{
									ped->Track++;
									ped->Column = 0;
									moved = TRUE;
								}
							}

							if (!moved && (ped->Flags & PEF_HWRAP))
							{
								ped->Track = 0;
								ped->Column = 0;
								moved = TRUE;
							}

							break;


						case 0x00:	/* ESC	*/
						case 0x5F:	/* HELP	*/
							result = GMR_REUSE;
							break;


						case 0x42:	/* TAB */

							if (ie->ie_Qualifier & IEQUALIFIER_ALT)
								/* Deactivate gadget on ALT+TAB to allow
								 * window cycling in the application.
								 */
								result = GMR_REUSE;
							else
							{
								if (ie->ie_Qualifier & IEQUALIFIER_SHIFT)
								{
									 if (ped->Track > 0)
										ped->Track--;
									else
										ped->Track = ped->Patt->Tracks - 1;
								}
								else
								{
									 if (ped->Track < ped->Patt->Tracks - 1)
										ped->Track++;
									else
										ped->Track = 0;
								}

								ped->Column = COL_NOTE;
								moved = TRUE;
							}

							break;


						case 0x0D:	/* RETURN */
							ped->Column = COL_NOTE;
							if (ped->Line < ped->Patt->Lines - 1)
								ped->Line++;
							else if (ped->Flags & PEF_VWRAP)
								ped->Line = 0;
							moved = TRUE;
							break;


						case 0x46:	/* DEL */
						{
							struct Note *note = &ped->Patt->Notes[ped->Track][ped->Line];

							SaveUndo (ped);
							change_note = TRUE;

							if (ie->ie_Qualifier & IEQUALIFIER_SHIFT)
								memset (note, 0, sizeof (struct Note));
							else switch (ped->Column)
							{
								case COL_NOTE:
									note->Note = 0;
									note->Inst = 0;
									break;

								case COL_INSTH:
									note->Inst &= 0x0F;
									break;

								case COL_INSTL:
									note->Inst &= 0xF0;
									break;

								case COL_EFF:
									note->EffNum = EFF_NULL;
									break;

								case COL_VALH:
									note->EffVal &= 0x0F;
									break;

								case COL_VALL:
									note->EffVal &= 0xF0;
									break;
							}
							break;
						}

						default:
						{
							struct Note *note = &ped->Patt->Notes[ped->Track][ped->Line];
							UBYTE tmp = 0, keycode = 1;

							/* Convert to hex number */

							if (ped->Column != COL_NOTE)
							{
								if (MapRawKey (ie, &keycode, 1, NULL) == -1)
									keycode = 0;
								else
								{
									if (keycode >= '0' && keycode <= '9')
										tmp = keycode - '0';
									else if (keycode >= 'a' && keycode <= ((ped->Column == COL_EFF) ? 'j' : 'f'))
										tmp = keycode - ('a' - 10);
									else
										keycode = 0;
								}
							}

							if (keycode) switch (ped->Column)
							{
								case COL_NOTE:

									/* Insert note */

									if (ie->ie_Code >= 0x1 && ie->ie_Code <= 0x0A)
										tmp = KeyNotes0[ie->ie_Code - 0x1];
									else if (ie->ie_Code >= 0x10 && ie->ie_Code <= 0x19)
										tmp = KeyNotes1[ie->ie_Code - 0x10];
									else if (ie->ie_Code >= 0x20 && ie->ie_Code <= 0x29)
										tmp = KeyNotes2[ie->ie_Code - 0x20];
									else if (ie->ie_Code >= 0x31 && ie->ie_Code <= 0x39)
										tmp = KeyNotes3[ie->ie_Code - 0x31];

									if (tmp)
									{
										SaveUndo (ped);
										change_note = TRUE;
										note->Note = tmp;
										note->Inst = ped->CurrentInst;
									}
									break;

								case COL_INSTL:
									SaveUndo (ped);
									change_note = TRUE;
									note->Inst = (note->Inst & 0xF0) | tmp;
									break;

								case COL_INSTH:
									if (tmp < MAXINSTRUMENTS>>4)
									{
										SaveUndo (ped);
										change_note = TRUE;
										note->Inst = (note->Inst & 0x0F) | (tmp<<4);
									}
									break;

								case COL_EFF:
									SaveUndo (ped);
									change_note = TRUE;
									note->EffNum = tmp;
									break;

								case COL_VALL:
									SaveUndo (ped);
									change_note = TRUE;
									note->EffVal = (note->EffVal & 0xF0) | tmp;
									break;

								case COL_VALH:
									SaveUndo (ped);
									change_note = TRUE;
									note->EffVal = (note->EffVal & 0x0F) | (tmp<<4);
									break;
							}
							break;
						}

					} /* End switch (ie->ie_Code) */

					break;

				default:
					break;

			}	/* End switch (ie->ie_Class) */

			if (moved || change_note)
			{
				if (rp = ObtainGIRPort (((struct gpInput *)msg)->gpi_GInfo))
				{
					if (change_note)
					{
						EraseCursor (rp, ped);
						DrawNote (rp, ped);

						/* Advance cursor */

						ped->Track	+= ped->AdvanceTracks;
						ped->Line	+= ped->AdvanceLines;

						if (ped->Flags & PEF_HWRAP)
							ped->Track = ped->Track % ped->Patt->Tracks;
						else
						{
							if (ped->Track < 0)
								ped->Track = 0;
							else if (ped->Track > ped->Patt->Tracks - 1)
								ped->Track = ped->Patt->Tracks - 1;
						}

						if (ped->Flags & PEF_VWRAP)
							ped->Line = ped->Line % ped->Patt->Lines;
						else
						{
							if (ped->Line < 0)
								ped->Line = 0;
							else if (ped->Line > ped->Patt->Lines - 1)
								ped->Line = ped->Patt->Lines - 1;
						}
					}

					scrolled |= DrawCursor (rp, ped, g);
					ReleaseGIRPort (rp);
				}

				/* Broadcast notification to our target object. */
				NotifyCursor (g, ((struct gpInput *)msg)->gpi_GInfo, (ie->ie_Code & IECODE_UP_PREFIX) ? 0 : OPUF_INTERIM);
			}

			if (scrolled & 1)
				NotifyVSlider (g, ((struct gpInput *)msg)->gpi_GInfo, (ie->ie_Code & IECODE_UP_PREFIX) ? 0 : OPUF_INTERIM);
			if (scrolled & 2)
				NotifyHSlider (g, ((struct gpInput *)msg)->gpi_GInfo, (ie->ie_Code & IECODE_UP_PREFIX) ? 0 : OPUF_INTERIM);

			break;
		}


		case GM_RENDER:

			ped = INST_DATA (cl, g);

			/* We do not support GREDRAW_UPDATE and GREDRAW_TOGGLE */

			if (((struct gpRender *)msg)->gpr_Redraw == GREDRAW_REDRAW)
			{
				/* Recalculate the display size only on V37.
				 * As of V39, Intuition supports GM_LAYOUT, which
				 * allows a more optimized way to handle dynamic resizing.
				 */
				if (IntuitionBase->LibNode.lib_Version < 39)
				{
					if (CalcDisplaySize (ped, g, ((struct gpRender *)msg)->gpr_GInfo))
					{
						NotifyVSlider (g, ((struct gpRender *)msg)->gpr_GInfo, 0);
						NotifyHSlider (g, ((struct gpRender *)msg)->gpr_GInfo, 0);
					}
				}

				RedrawAll (((struct gpRender *)msg)->gpr_RPort, ped, g);
			}

			break;


		case GM_HITTEST:

			/* As we are rectangular shaped, we are always hit */
			result = GMR_GADGETHIT;
			break;

		case GM_HELPTEST:
			result = GMR_HELPHIT;
			break;

		case GM_GOINACTIVE:

			ped = INST_DATA (cl, g);

			g->Flags &= ~GFLG_SELECTED;

			if (ped->Patt)
				/* Render disabled cursor */
				if (rp = ObtainGIRPort (((struct gpGoInactive *)msg)->gpgi_GInfo))
				{
					DrawCursor (rp, ped, g);
					ReleaseGIRPort (rp);
				}
			break;


		case GM_LAYOUT:

			ped = INST_DATA (cl, g);

			if (CalcDisplaySize (ped, g, ((struct gpLayout *)msg)->gpl_GInfo))
			{
				NotifyVSlider (g, ((struct gpLayout *)msg)->gpl_GInfo, 0);
				NotifyHSlider (g, ((struct gpLayout *)msg)->gpl_GInfo, 0);
			}

			break;


		case OM_SET:
		case OM_UPDATE:
		{
			struct TagItem *tstate = ((struct opSet *)msg)->ops_AttrList;
			BOOL	redraw_all		= FALSE,
					move_cursor		= FALSE,
					scroll_pattern	= FALSE,
					change_note		= FALSE;
			WORD	lefttrack, topline;

			ped = INST_DATA (cl, g);

			lefttrack = ped->LeftTrack;
			topline = ped->TopLine;

			while (ti = NextTagItem(&tstate))
			{
				switch (ti->ti_Tag)
				{
					case PATTA_CursTrack:
						ped->Track = ti->ti_Data;
						move_cursor = TRUE;
						break;

					case PATTA_CursColumn:
						ped->Column = ti->ti_Data;
						move_cursor = TRUE;
						break;

					case PATTA_CursLine:
						ped->Line = ti->ti_Data;
						move_cursor = TRUE;
						break;

					case PATTA_LeftTrack:
						if (lefttrack != ti->ti_Data)
						{
							lefttrack = ti->ti_Data;
							ped->Track = lefttrack + (ped->DisplayTracks / 2);
							scroll_pattern = TRUE;
						}
						break;

					case PATTA_TopLine:
						if (topline != ti->ti_Data)
						{
							topline = ti->ti_Data;
							ped->Line = topline + (ped->DisplayLines / 2);
							scroll_pattern = TRUE;
						}
						break;

					case PATTA_Left:
						if (lefttrack)
						{
							ped->Track = ped->LeftTrack - 1;
							move_cursor = TRUE;
						}
						break;

					case PATTA_Right:
						if (ped->Patt && (lefttrack + ped->DisplayTracks < ped->Patt->Tracks))
						{
							ped->Track = lefttrack + ped->DisplayTracks;
							move_cursor = TRUE;
						}
						break;

					case PATTA_Up:
						if (topline)
						{
							ped->Line = ped->TopLine - 1;
							move_cursor = TRUE;
						}
						break;

					case PATTA_Down:
						if (ped->Patt && (topline + ped->DisplayLines < ped->Patt->Lines))
						{
							ped->Line = topline + ped->DisplayLines;
							move_cursor = TRUE;
						}
						break;

					case PATTA_CursLeft:
						if (ped->Track)
						{
							ped->Track--;
							move_cursor = TRUE;
						}
						else if (ped->Flags & PEF_VWRAP)
						{
							ped->Track = ped->Patt->Tracks - 1;
							move_cursor = TRUE;
						}

						break;

					case PATTA_CursRight:
						if (ped->Patt && ped->Track < ped->Patt->Tracks - 1)
						{
							ped->Track++;
							move_cursor = TRUE;
						}
						else if (ped->Flags & PEF_HWRAP)
						{
							ped->Track = 0;
							move_cursor = TRUE;
						}

						break;

					case PATTA_CursUp:
						if (ped->Line)
						{
							ped->Line--;
							move_cursor = TRUE;
						}
						else if (ped->Flags & PEF_VWRAP)
						{
							ped->Line = ped->Patt->Lines-1;
							move_cursor = TRUE;
						}

						break;

					case PATTA_CursDown:
						if (ped->Patt && ped->Line < ped->Patt->Lines - 1)
						{
							ped->Line++;
							move_cursor = TRUE;
						}
						else if (ped->Flags & PEF_VWRAP)
						{
							ped->Line = 0;
							move_cursor = TRUE;
						}

						break;

					case PATTA_UndoChange:
						if (((LONG)ti->ti_Data) < 0)
							change_note |= RedoChange (ped);
						else
							change_note |= UndoChange (ped);
						break;

					case PATTA_Changes:
						ped->Changes = ti->ti_Data;
						break;

					case PATTA_MarkRegion:
					{
						struct Rectangle *region = (struct Rectangle *)ti->ti_Data;

						if (!region)				/* End mark mode */

							ped->Flags &= ~PEF_MARKING;

						else if (region == (struct Rectangle *)-1)	/* Toggle mark mode */
						{
							ped->Flags ^= PEF_MARKING;
							ped->RangeStartTrack	= ped->Track;
							ped->RangeStartLine		= ped->Line;
						}
						else						/* Start mark mode */
						{
							memcpy (&ped->RangeStartTrack, region, sizeof (struct Rectangle));
							ped->Track	= region->MaxX;
							ped->Line	= region->MaxY;
							ped->Flags |= PEF_MARKING;
						}

						if (rp = ObtainGIRPort (((struct opSet *)msg)->ops_GInfo))
						{
							if (!(ped->Flags & PEF_MARKING))
								ClearRange (rp, ped);

							DrawCursor (rp, ped, g);

							ReleaseGIRPort (rp);
						}

						break;
					}

					case PATTA_Flags:
					{
						ULONG	oldflags = ped->Flags;
						ped->Flags = (ped->Flags & 0xFFFF0000) | ti->ti_Data;

						if ((oldflags & (PEF_HEXMODE | PEF_BLANKZERO | PEF_INVERSETEXT | PEF_DOTINYLINES)) !=
							(ped->Flags & (PEF_HEXMODE | PEF_BLANKZERO | PEF_INVERSETEXT | PEF_DOTINYLINES)))
						{
							/* Select Note2ASCII func */
							if (ped->Flags & PEF_BLANKZERO)
								ped->Note2ASCIIFunc = Note2ASCIIBlank0;
							else
								ped->Note2ASCIIFunc = Note2ASCII;

							/* Cause complete radraw */
							redraw_all = TRUE;
						}

						break;
					}

					case PATTA_Pattern:
						ped->Patt = (struct Pattern *) ti->ti_Data;
						redraw_all = TRUE;
						FreeUndoBuffers (ped, TRUE);

						if (ped->Patt == NULL)
						{
							SetAttrs (g, GA_Disabled, TRUE, TAG_DONE);
							lefttrack = topline = ped->DisplayTracks = ped->DisplayLines = 0;
						}
						else
						{
							/* Recalculate pattern dimensions */
							if (CalcDisplaySize (ped, g, ((struct opSet *)msg)->ops_GInfo))
							{
								NotifyVSlider (g, ((struct opSet *)msg)->ops_GInfo, 0);
								NotifyHSlider (g, ((struct opSet *)msg)->ops_GInfo, 0);
							}

							/* Force cursor inside pattern */

							if (ped->Line >= ped->Patt->Lines)
								ped->Line = ped->Patt->Lines - 1;

							if (ped->Track >= ped->Patt->Tracks)
								ped->Track = ped->Patt->Tracks - 1;

							if (lefttrack + ped->DisplayTracks > ped->Patt->Tracks)
								lefttrack = ped->Patt->Tracks - ped->DisplayTracks;

							if (topline + ped->DisplayLines > ped->Patt->Lines)
								topline = ped->Patt->Lines - ped->DisplayLines;

							if (g->Flags & GFLG_DISABLED)
								SetAttrs (g, GA_Disabled, FALSE, TAG_DONE);
						}
						break;

					case PATTA_CurrentInst:
						ped->CurrentInst = ti->ti_Data;
						break;

					case PATTA_MaxUndoLevels:
						ped->MaxUndoLevels = ti->ti_Data;
						FreeUndoBuffers (ped, FALSE);
						break;

					case PATTA_MaxUndoMem:
						ped->MaxUndoMem = ti->ti_Data;

						/* Unlimited undo memory */
						if (ped->MaxUndoMem == 0) ped->MaxUndoMem = ~0;

						FreeUndoBuffers (ped, FALSE);

						break;

					case PATTA_AdvanceCurs:
						ped->AdvanceLines = ti->ti_Data & 0xFFFF;
						ped->AdvanceTracks = ti->ti_Data >> 16;
						break;

					case PATTA_CursWrap:
						ped->Flags = (ped->Flags & (PEF_HWRAP | PEF_VWRAP)) | (ti->ti_Data & (PEF_HWRAP | PEF_VWRAP));
						break;

					case PATTA_TextPen:
						if (ped->TextPen != ti->ti_Data)
						{
							ped->TextPen = ti->ti_Data;
							redraw_all = TRUE;
						}
						break;

					case PATTA_LinesPen:
						if (ped->LinesPen != ti->ti_Data)
						{
							ped->LinesPen = ti->ti_Data;
							redraw_all = TRUE;
						}
						break;

					case PATTA_TinyLinesPen:
						if (ped->TinyLinesPen != ti->ti_Data)
						{
							ped->TinyLinesPen = ti->ti_Data;
							redraw_all = TRUE;
						}
						break;

					default:
						break;
				}

			}	/* End while (NextTagItem()) */


			result = DoSuperMethodA (cl, (Object *)g, msg);

			if (redraw_all || scroll_pattern || move_cursor || change_note)
			{
				WORD scrolled = 0;

				if (rp = ObtainGIRPort (((struct opSet *)msg)->ops_GInfo))
				{
					if (redraw_all)
					{
						ped->LeftTrack = lefttrack;
						ped->TopLine = topline;

						DoMethod ((Object *)g, GM_RENDER, ((struct opSet *)msg)->ops_GInfo, rp, GREDRAW_REDRAW);
						scrolled = TRUE;
					}
					else if (scroll_pattern)
						scrolled = ScrollPattern (rp, ped, g, lefttrack, topline);

					if (move_cursor || change_note)
					{
						if (change_note)
						{
							EraseCursor (rp, ped);
							DrawNote (rp, ped);
						}

						scrolled |= DrawCursor (rp, ped, g);
					}

					ReleaseGIRPort (rp);
				}

				if (scrolled & 1)
					NotifyVSlider (g, ((struct opSet *)msg)->ops_GInfo, msg->MethodID == OM_UPDATE ? (((struct opUpdate *)msg)->opu_Flags) : 0);
				if (scrolled & 2)
					NotifyHSlider (g, ((struct opSet *)msg)->ops_GInfo, msg->MethodID == OM_UPDATE ? (((struct opUpdate *)msg)->opu_Flags) : 0);

				if (scrolled || move_cursor)
					NotifyCursor (g, ((struct opSet *)msg)->ops_GInfo, msg->MethodID == OM_UPDATE ? (((struct opUpdate *)msg)->opu_Flags) : 0);
			}

			break;
		}


		case OM_GET:

			ped = INST_DATA (cl, g);
			result = TRUE;

			switch (((struct opGet *) msg)->opg_AttrID)
			{
				case PATTA_CursTrack:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->Track;
					break;

				case PATTA_CursColumn:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->Column;
					break;

				case PATTA_CursLine:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->Line;
					break;

				case PATTA_LeftTrack:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->LeftTrack;
					break;

				case PATTA_TopLine:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->TopLine;
					break;

				case PATTA_Changes:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->Changes;
					break;

				case PATTA_MarkRegion:
				{
					struct Rectangle *region = (struct Rectangle *) *(((struct opGet *) msg)->opg_Storage);

					region->MinX = min (ped->RangeStartTrack, ped->RangeEndTrack);
					region->MaxX = max (ped->RangeStartTrack, ped->RangeEndTrack);
					region->MinY = min (ped->RangeStartLine, ped->RangeEndLine);
					region->MaxY = max (ped->RangeStartLine, ped->RangeEndLine);
					break;
				}

				case PATTA_Flags:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->Flags;
					break;

				case PATTA_DisplayTracks:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->DisplayTracks;
					break;

				case PATTA_DisplayLines:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->DisplayLines;
					break;

				case PATTA_Pattern:
					*(((struct opGet *) msg)->opg_Storage) = (ULONG) ped->Patt;
					break;

				default:
					result = DoSuperMethodA (cl, (Object *)g, msg);
					break;
			}

			break;


		case OM_NEW:

			if (result = DoSuperMethodA (cl, (Object *)g, msg))
			{
				ULONG tmp;

				g = (struct ExtGadget *) result;

				ped = INST_DATA (cl, g);	/* Get pointer to instance data */
				memset (ped, 0, sizeof (struct PattEditData));

				/* We are going to use ScrollRaster() in this gadget... */

				if (g->Flags & GFLG_EXTENDED)
					g->MoreFlags |= GMORE_SCROLLRASTER;

				g->Flags |= GFLG_TABCYCLE | GFLG_RELSPECIAL;

				/* Initialize our lists */
				NewList ((struct List *)&ped->UndoList);
				NewList ((struct List *)&ped->RedoList);


				/* Open the timer.device */
/*
				NewList (&ped->TimerPort.mp_MsgList);
				ped->TimerPort.mp_Flags = PA_SOFTINT;
				ped->TimerPort.mp_SoftInt = &ped->TimerInt;
				ped->TimerInt.is_Node.ln_Type = NT_INTERRUPT;
				ped->TimerInt.is_Data = g;
				ped->TimerInt.is_Code = (void (*)())TimerIntServer;
				ped->TimerIO.tr_node.io_Message.mn_ReplyPort = &ped->TimerPort;

				if (OpenDevice (TIMERNAME, UNIT_VBLANK, (struct IORequest *)&ped->TimerIO, 0))
				{
					DisposeObject (g);
					result = NULL;
					break;
				}
*/

				/* Initialize attributes */

				ped->Patt			= (struct Pattern *)	GetTagData (PATTA_Pattern,	NULL, ((struct opSet *)msg)->ops_AttrList);
				ped->CurrentInst	= GetTagData (PATTA_CurrentInst,	NULL, ((struct opSet *)msg)->ops_AttrList);
				ped->EditorFont 	= (struct TextFont *)	GetTagData (PATTA_TextFont,	(ULONG)GfxBase->DefaultFont, ((struct opSet *)msg)->ops_AttrList);
				ped->TextPen		= GetTagData (PATTA_TextPen,		1, ((struct opSet *)msg)->ops_AttrList);
				ped->LinesPen		= GetTagData (PATTA_LinesPen,		2, ((struct opSet *)msg)->ops_AttrList);
				ped->TinyLinesPen	= GetTagData (PATTA_TinyLinesPen,	2, ((struct opSet *)msg)->ops_AttrList);
				ped->MaxUndoLevels	= GetTagData (PATTA_MaxUndoLevels,	32, ((struct opSet *)msg)->ops_AttrList);
				ped->MaxUndoMem		= GetTagData (PATTA_MaxUndoMem,		8192, ((struct opSet *)msg)->ops_AttrList);
				ped->Flags			= GetTagData (PATTA_Flags,			0, ((struct opSet *)msg)->ops_AttrList);
				ped->Flags			|= GetTagData (PATTA_CursWrap,		ped->Flags, ((struct opSet *)msg)->ops_AttrList) & (PEF_HWRAP | PEF_VWRAP);

				tmp = GetTagData (PATTA_AdvanceCurs, 1, ((struct opSet *)msg)->ops_AttrList);
				ped->AdvanceTracks	= tmp << 16;
				ped->AdvanceLines	= tmp & 0xFFFF;

				ped->Line	= GetTagData (PATTA_CursLine,	0, ((struct opSet *)msg)->ops_AttrList);
				ped->Track	= GetTagData (PATTA_CursTrack,	0, ((struct opSet *)msg)->ops_AttrList);
				ped->Column	= GetTagData (PATTA_CursColumn,	0, ((struct opSet *)msg)->ops_AttrList);

				ped->FontXSize		= ped->EditorFont->tf_XSize;
				ped->FontYSize		= ped->EditorFont->tf_YSize;

				/* Select Note2ASCII func */
				if (ped->Flags & PEF_BLANKZERO)
					ped->Note2ASCIIFunc = Note2ASCIIBlank0;
				else
					ped->Note2ASCIIFunc = Note2ASCII;

				/* Unlimited undo memory */
				if (ped->MaxUndoMem == 0) ped->MaxUndoMem = ~0;

				if (ped->Patt == NULL)
					SetAttrs (g, GA_Disabled, TRUE, TAG_DONE);
				else if (g->Flags & GFLG_DISABLED)
					SetAttrs (g, GA_Disabled, FALSE, TAG_DONE);
			}
			break;


		case OM_DISPOSE:
		{
			ped = INST_DATA (cl, g);

			FreeUndoBuffers (ped, TRUE);
//			CloseDevice ((struct IORequest *)&ped->TimerIO);

			/* NOTE: I'm falling through here! */
		}


		default:

			/* Unsupported method: let our superclass's
			 * dispatcher take a look at it.
			 */
			result = DoSuperMethodA (cl, (Object *)g, msg);
			break;
	}

	return (result);
}



static void SaveUndo (struct PattEditData *ped)
{
	struct UndoNode *undo;

	ped->Changes++;

	/* Is undo feature disabled ? */
	if (!ped->MaxUndoLevels) return;

	/* Empty redo list */
	while (undo = (struct UndoNode *) RemHead ((struct List *)&ped->RedoList))
		FreeMem (undo, sizeof (struct UndoNode));

	FreeUndoBuffers (ped, FALSE);

	while (ped->UndoCount >= ped->MaxUndoLevels || ped->UndoMem >= ped->MaxUndoMem)
		if (undo = (struct UndoNode *) RemTail ((struct List *)&ped->UndoList))
		{
			FreeMem (undo, sizeof (struct UndoNode));
			ped->UndoCount--;
			ped->UndoMem -= sizeof (struct UndoNode);
		}

	/* Allocate a new undo buffer and save current note */
	if (undo = AllocMem (sizeof (struct UndoNode), MEMF_ANY))
	{
		undo->Track	= ped->Track;
		undo->Line	= ped->Line;

		memcpy (&undo->OldNote, &ped->Patt->Notes[ped->Track][ped->Line],
			sizeof (struct Note));

		AddHead ((struct List *)&ped->UndoList, (struct Node *)undo);
		ped->UndoCount++;
		ped->UndoMem += sizeof (struct UndoNode);
	}
}



static BOOL UndoChange (struct PattEditData *ped)
{
	struct UndoNode	*undo;
	struct Note		*note;
	struct Note		 tmp_note;

	if (undo = (struct UndoNode *) RemHead ((struct List *) &ped->UndoList))
	{
		ped->UndoCount--;
		ped->UndoMem -= sizeof (struct UndoNode);
		ped->Changes--;

		ped->Track	= undo->Track;
		ped->Line	= undo->Line;

		note = &ped->Patt->Notes[ped->Track][ped->Line];

		/* Swap undo buffer with note */
		memcpy (&tmp_note, &undo->OldNote, sizeof (struct Note));
		memcpy (&undo->OldNote, note, sizeof (struct Note));
		memcpy (note, &tmp_note, sizeof (struct Note));


		/* Move this node to the redo buffer */
		AddHead ((struct List *)&ped->RedoList, (struct Node *)undo);

		return TRUE;
	}

	return FALSE;
}



static BOOL RedoChange (struct PattEditData *ped)
{
	struct UndoNode *undo;
	struct Note	*note;
	struct Note	 tmp_note;

	if (undo = (struct UndoNode *) RemHead ((struct List *) &ped->RedoList))
	{
		ped->Track	= undo->Track;
		ped->Line	= undo->Line;

		note = &ped->Patt->Notes[ped->Track][ped->Line];

		/* Swap undo buffer and note */
		memcpy (&tmp_note, &undo->OldNote, sizeof (struct Note));
		memcpy (&undo->OldNote, note, sizeof (struct Note));
		memcpy (note, &tmp_note, sizeof (struct Note));

		/* Move this node to the undo buffer */
		AddHead ((struct List *)&ped->UndoList, (struct Node *)undo);

		ped->UndoCount++;
		ped->Changes++;
		ped->UndoMem += sizeof (struct UndoNode);

		return TRUE;
	}

	return FALSE;
}



static void FreeUndoBuffers (struct PattEditData *ped, BOOL freeall)

/* If <freeall> is TRUE, this routine will free all the undo buffers.
 * Otherwhise, it will check for undo overflow and free enough nodes
 * to keep the undo buffers inside the memory size and nodes count
 * limits.
 */
{
	struct UndoNode *undo;

	if (!freeall)
	{
		while (ped->UndoCount >= ped->MaxUndoLevels || ped->UndoMem >= ped->MaxUndoMem)
			if (undo = (struct UndoNode *) RemTail ((struct List *)&ped->UndoList))
			{
				FreeMem (undo, sizeof (struct UndoNode));
				ped->UndoCount--;
				ped->UndoMem -= sizeof (struct UndoNode);
			}

		return;
	}

	/* Free everything */

	while (undo = (struct UndoNode *) RemHead ((struct List *)&ped->UndoList))
		FreeMem (undo, sizeof (struct UndoNode));

	while (undo = (struct UndoNode *) RemHead ((struct List *)&ped->RedoList))
		FreeMem (undo, sizeof (struct UndoNode));

	ped->UndoCount = 0; ped->UndoMem = 0;
}



static void NotifyCursor (struct ExtGadget *g, struct GadgetInfo *gi, ULONG flags)
{
	static LONG tags[] =
	{
		PATTA_CursLine,		0,
		PATTA_CursTrack,	0,
		PATTA_CursColumn,	0,
		GA_ID,				0,
		TAG_DONE
	};

	struct PattEditData *ped;

	/* Always sends notification if the gadget has the GACT_IMMEDIATE
	 * flag set.  If it isn't, the editor will report its cursor
	 * position only on last cursor update.
	 */
	if ((g->Activation & GACT_IMMEDIATE) || !(flags & OPUF_INTERIM))
	{
		ped = INST_DATA (OCLASS(g), g);

		tags[1] = ped->Line;
		tags[3] = ped->Track;
		tags[5] = ped->Column;
		tags[7] = g->GadgetID;

		DoSuperMethod (OCLASS(g), (Object *)g, OM_NOTIFY, tags, gi, flags);
	}
}



static void NotifyVSlider (struct ExtGadget *g, struct GadgetInfo *gi, ULONG flags)
{
	static LONG tags[] =
	{
		PATTA_TopLine,			0,
		PATTA_DisplayLines,		0,
		GA_ID,					0,
		TAG_DONE
	};

	struct PattEditData *ped = INST_DATA (OCLASS(g), g);


	/* Optimized slider update; only send updates if one of
	 * these conditions is satisfied:
	 *
	 * - Final update (keyup or selectup),
	 * - SliderCounter reached,
	 * - Reached top/bottom of the pattern.
	 */
	if ((!(flags & OPUF_INTERIM)) || (ped->SliderCounter == 0) || (ped->TopLine == 0)
		|| (ped->TopLine + ped->DisplayLines >= ped->Patt->Lines))
	{
		ped->SliderCounter = 3;

		tags[1] = ped->TopLine;
		tags[3] = ped->DisplayLines;
		tags[5] = g->GadgetID;

		DoSuperMethod (OCLASS(g), (Object *)g, OM_NOTIFY, tags, gi, flags);
	}

	ped->SliderCounter--;
}



static void NotifyHSlider (struct ExtGadget *g, struct GadgetInfo *gi, ULONG flags)
{
	static LONG tags[] =
	{
		PATTA_LeftTrack,		0,
		PATTA_DisplayTracks,	0,
		GA_ID,					0,
		TAG_DONE
	};

	struct PattEditData *ped = INST_DATA (OCLASS(g), g);


	/* Optimized slider update; only send updates if one of
	 * these conditions is satisfied:
	 *
	 * - Final update (keyup or selectup),
	 * - SliderCounter reached,
	 * - Reached left/right of pattern.
	 */
	if ((!(flags & OPUF_INTERIM)) || (ped->SliderCounter == 0) || (ped->LeftTrack == 0)
		|| (ped->LeftTrack + ped->DisplayTracks >= ped->Patt->Tracks))
	{
		ped->SliderCounter = 3;

		tags[1] = ped->LeftTrack;
		tags[3] = ped->DisplayTracks;
		tags[5] = g->GadgetID;

		DoSuperMethod (OCLASS(g), (Object *)g, OM_NOTIFY, tags, gi, flags);
	}

	ped->SliderCounter--;
}



static void GetGadgetBox (struct Window *win, struct ExtGadget *g, struct IBox *rect)

/* This function gets the actual IBox where a gadget exists
 * in a window.  The special cases it handles are all the REL#?
 * (relative positioning flags).
 *
 * The function takes a struct Window pointer, a struct Gadget
 * pointer, and a struct IBox pointer.  It uses the window and
 * gadget to fill in the IBox.
 */
{
	rect->Left = g->LeftEdge;
	if (g->Flags & GFLG_RELRIGHT) rect->Left += win->Width - 1;

	rect->Top = g->TopEdge;
	if (g->Flags & GFLG_RELBOTTOM) rect->Top += win->Height - 1;

	rect->Width = g->Width;
	if (g->Flags & GFLG_RELWIDTH) rect->Width += win->Width;

	rect->Height = g->Height;
	if (g->Flags & GFLG_RELHEIGHT) rect->Height += win->Height;
}



static BOOL CalcDisplaySize (struct PattEditData *ped, struct ExtGadget *g, struct GadgetInfo *ginfo)

/* Calculate maximum number of tracks and lines that will fit in the gadget
 * size.  Returns TRUE if something has changed.
 *
 * GBounds are the bounds of the whole gadget and
 * TBounds are the bounds of the portion where the cursor lives.
 *
 * +--Window--------------------+
 * |                            |
 * | +--GBounds----------------+|
 * | |   +--TBounds-----------+||
 * | |001|C#2 1 000|B#2 2 C20 |||
 * | |002|--- 0 000|A-2 2 C30 |||
 * | |003|--- 0 000|C-2 2 C10 |||
 * | |004|--- 0 000|C#2 3 000 |||
 * | |   +--------------------+||
 * | +-------------------------+|
 * +----------------------------+
 */
{
	UWORD	old_displaytracks = ped->DisplayTracks,
			old_displaylines = ped->DisplayLines,
			numcol_width = ped->FontXSize * 4;

	ped->MyWindow = ginfo->gi_Window;

	GetGadgetBox (ped->MyWindow, g, &ped->GBounds);

	/* Setup DisplayTracks and DisplayLines */

	if (ped->Patt)
	{
		ped->DisplayTracks	= min ((ped->GBounds.Width - numcol_width)/ (TRACKWIDTH * ped->FontXSize), ped->Patt->Tracks);
		ped->DisplayLines	= min (ped->GBounds.Height / ped->FontYSize, ped->Patt->Lines);

		if (ped->TopLine + ped->DisplayLines > ped->Patt->Lines)
			ped->TopLine = max (0, ped->Patt->Lines - ped->DisplayLines);

		if (ped->LeftTrack + ped->DisplayTracks > ped->Patt->Tracks)
			ped->LeftTrack = max (0, ped->Patt->Tracks - ped->DisplayTracks);
	}


	/* Setup Text Bounds */

	ped->TBounds.Top	= ped->GBounds.Top;
	ped->TBounds.Left	= ped->GBounds.Left + numcol_width;
	ped->TBounds.Width	= ped->DisplayTracks * ped->FontXSize * TRACKWIDTH;
	ped->TBounds.Height	= ped->DisplayLines * ped->FontYSize;

	return ((BOOL)((old_displaytracks != ped->DisplayTracks) || (old_displaylines != ped->DisplayLines)));
}



static BOOL MoveCursor (struct PattEditData *ped, WORD x, WORD y)

/* Moves the cursor to a given xy position.  Checks whether the cursor has
 * really moved and returns FALSE if there is no need to update its imagery.
 */
{
	WORD tmp;
	BOOL moved = FALSE, maxtrack = FALSE;


	/* X Position (Track) */

	if (x < 0)
		tmp = ped->LeftTrack - 1;
	else
		tmp = (x / (ped->FontXSize * TRACKWIDTH)) + ped->LeftTrack;

	if (tmp < 0) tmp = 0;

	if (tmp >= ped->Patt->Tracks)
	{
		tmp = ped->Patt->Tracks - 1;
		maxtrack = TRUE;
	}

	if (ped->Track != tmp)
	{
		moved = TRUE;
		ped->Track = tmp;
	}


	/* X Position (Column) */

	if (maxtrack)
		tmp = TRACKWIDTH-1;
	else
		tmp = (x / ped->FontXSize) % TRACKWIDTH;


	if (tmp < 3)		tmp = COL_NOTE;
	else if (tmp == 3)	tmp = COL_INSTH;
	else if (tmp == 4)	tmp = COL_INSTL;
	else if (tmp < 7)	tmp = COL_EFF;
	else if (tmp == 7)	tmp = COL_VALH;
	else				tmp = COL_VALL;


	if (ped->Column != tmp)
	{
		moved = TRUE;
		ped->Column = tmp;
	}


	/* Y Position */

	tmp = (y / ped->FontYSize) + ped->TopLine;

	if (tmp < 0) tmp = 0;

	if (tmp >= ped->Patt->Lines)
		tmp = ped->Patt->Lines - 1;

	if (ped->Line != tmp)
	{
		moved = TRUE;
		ped->Line = tmp;
	}

	return moved;
}



/* Cursor patterns - Used in EraseCursor() and DrawCursor() */

static UWORD GhostPattern[]	= { 0xAAAA, 0x5555 };
static UWORD MarkPattern[]	= { 0xFFFF, 0x0000 };


static void EraseCursor (struct RastPort *rp, struct PattEditData *ped)
{
	SetDrMd (rp,COMPLEMENT);

	switch (ped->CursState)
	{
		case IDS_DISABLED:
			SetAfPt (rp, GhostPattern, 1);
			RectFill (rp, ped->CursRect.MinX, ped->CursRect.MinY,
				ped->CursRect.MaxX, ped->CursRect.MaxY);
			SetAfPt (rp, NULL, 0);	/* Reset Area Pattern	*/
			break;

		case IDS_BUSY:
			SetAfPt (rp, MarkPattern, 1);
			RectFill (rp, ped->CursRect.MinX, ped->CursRect.MinY,
				ped->CursRect.MaxX, ped->CursRect.MaxY);
			SetAfPt (rp, NULL, 0);	/* Reset Area Pattern	*/
			break;

		case IDS_SELECTED:
			RectFill (rp, ped->CursRect.MinX, ped->CursRect.MinY,
				ped->CursRect.MaxX, ped->CursRect.MaxY);

			if (ped->CursLinePos)
			{
				/* Erase cursor line */
				Move (rp, ped->GBounds.Left, ped->CursRect.MaxY);
				Draw (rp, ped->TBounds.Left + ped->TBounds.Width - 1, ped->CursRect.MaxY);
				ped->CursLinePos = 0;
			}
			break;

		default:

			/* When the cursor is not rendered, its state
			 * will be IDS_NORMAL, so we won't erase it at all.
			 */
			break;
	}

	ped->CursState = IDS_NORMAL;
}



static UWORD DrawCursor (struct RastPort *rp, struct PattEditData *ped, struct ExtGadget *g)

/* Draw the cursor image on the editor.  If the cursor goes outside
 * of the scrolling region, the view is scrolled to make
 * it visible.
 *
 * RESULT
 *  0 - no scrolling occurred,
 *  1 - vertical scroll occurred,
 *  2 - horizontal scroll occurred,
 *  3 - scrolled in both directions.
 */

{
	/* Cursor offsets for each track column */
	static UWORD ColumnOff[COL_COUNT] =  { 0, 3, 4, 6, 7, 8 };

	struct Rectangle	NewCurs;
	UWORD				NewState;

	/* Check whether cursor is outside the display bounds and
	 * scroll pattern to make it visible if required.
	 */
	{
		if (ped->Line < ped->TopLine)
			return ScrollPattern (rp, ped, g, ped->LeftTrack, ped->Line);
		else if (ped->Line >= ped->TopLine + ped->DisplayLines)
			return ScrollPattern (rp, ped, g, ped->LeftTrack, ped->Line - ped->DisplayLines + 1);
		if (ped->Track < ped->LeftTrack)
			return ScrollPattern (rp, ped, g, ped->Track, ped->TopLine);
		else if (ped->Track >= ped->LeftTrack + ped->DisplayTracks)
			return ScrollPattern (rp, ped, g, ped->Track - ped->DisplayTracks + 1, ped->TopLine);
	}


	/* Calculate new cursor rectangle */

	NewCurs.MinX = ped->TBounds.Left +
		(((ped->Track - ped->LeftTrack) * TRACKWIDTH) + ColumnOff[ped->Column]) * ped->FontXSize;
	NewCurs.MinY = ped->TBounds.Top + (ped->Line - ped->TopLine) * ped->FontYSize;
	NewCurs.MaxX = NewCurs.MinX + ped->FontXSize - 1;
	NewCurs.MaxY = NewCurs.MinY + ped->FontYSize - 1;


	/* Note field is three characters wide */
	if (ped->Column == COL_NOTE)
		NewCurs.MaxX += ped->FontXSize * 2;


	/* Set AreaPattern to show current cursor state */

	if (!(g->Flags & GFLG_SELECTED))
	{
		NewState = IDS_DISABLED;

		/* Set this pattern to draw an inactive cursor */
		SetAfPt (rp, GhostPattern, 1);
	}
	else if (ped->Flags & PEF_MARKING)
	{
		NewState = IDS_BUSY;

		/* Set this pattern to draw marking cursor */
		SetAfPt (rp, MarkPattern, 1);
	}
	else NewState = IDS_SELECTED;

	SetDrMd (rp, COMPLEMENT);
	/* Draw cursor */
	RectFill (rp, NewCurs.MinX, NewCurs.MinY,
		NewCurs.MaxX, NewCurs.MaxY);
	SetAfPt (rp, NULL, 0);	/* Reset AreaFill Pattern */

	if (NewState == IDS_SELECTED)
	{
		if (ped->CursLinePos != NewCurs.MaxY)
		{
			/* Draw horizontal line */
		 	Move (rp, ped->GBounds.Left, NewCurs.MaxY);
			Draw (rp, ped->TBounds.Left + ped->TBounds.Width - 1, NewCurs.MaxY);
		}
		/* Cause EraseCursor() to leave the old line alone */
		else ped->CursLinePos = 0;
	}


	/* Erase old cursor */
	EraseCursor (rp, ped);

	if (ped->Flags & PEF_MARKING)
		/* Update the range */
		DrawRange (rp, ped);


	/* Store new position and state */
	ped->CursRect	= NewCurs;
	ped->CursState	= NewState;

	if (NewState == IDS_SELECTED)
		ped->CursLinePos = NewCurs.MaxY;

	return FALSE;
}



static void DrawRange (struct RastPort *rp, struct PattEditData *ped)
{
	UWORD tmin, tmax, lmin, lmax;
	struct Rectangle newrange;

	ped->RangeEndTrack	= ped->Track;
	ped->RangeEndLine	= ped->Line;

	if (ped->RangeStartTrack < ped->Track)
	{
		tmin = ped->RangeStartTrack;
		tmax = ped->Track;
	}
	else
	{
		tmin = ped->Track;
		tmax = ped->RangeStartTrack;
	}

	if (ped->RangeStartLine < ped->Line)
	{
		lmin = ped->RangeStartLine;
		lmax = ped->Line;
	}
	else
	{
		lmin = ped->Line;
		lmax = ped->RangeStartLine;
	}

	/* Limit to visible portion of range rectangle */

	if (tmin < ped->LeftTrack)
		tmin = ped->LeftTrack;
	if (tmin >= ped->LeftTrack + ped->DisplayTracks)
		tmin = ped->LeftTrack + ped->DisplayTracks - 1;

	if (tmax < ped->LeftTrack)
		tmax = ped->LeftTrack;
	if (tmax >= ped->LeftTrack + ped->DisplayTracks)
		tmax = ped->LeftTrack + ped->DisplayTracks - 1;

	if (lmin < ped->TopLine)
		lmin = ped->TopLine;
	if (lmin >= ped->TopLine + ped->DisplayLines)
		lmin = ped->TopLine + ped->DisplayLines - 1;

	if (lmax < ped->TopLine)
		lmax = ped->TopLine;
	if (lmax >= ped->TopLine + ped->DisplayLines)
		lmax = ped->TopLine + ped->DisplayLines - 1;


	newrange.MinX = ped->TBounds.Left + (tmin - ped->LeftTrack) * (ped->FontXSize * TRACKWIDTH);
	newrange.MinY = ped->TBounds.Top + (lmin - ped->TopLine) * ped->FontYSize;
	newrange.MaxX = ped->TBounds.Left + ((tmax - ped->LeftTrack + 1) * (ped->FontXSize * TRACKWIDTH)) - 1;
	newrange.MaxY = ped->TBounds.Top + ((lmax - ped->TopLine + 1) * ped->FontYSize) - 1;

	SafeSetWriteMask (rp, ped->TextPen);
	SetDrMd (rp, COMPLEMENT);


	if (ped->RangeRect.MaxX == 0)
	{
		RectFill (rp, newrange.MinX,
			newrange.MinY,
			newrange.MaxX,
			newrange.MaxY);
	}
	else
	{
		/* Incremental range box update.  We only draw changes relative to last
		 * ranged box.  As the range box is drawn complementing bitplane 1,
		 * complementing it again will erase it, so we do not care if the box
		 * has grown or shrinked; we just complemnt delta boxes.
		 */

		/*	 range box
		 *	+---+-----+
		 *	|###|     |
		 *	|###|     |
		 *	|###|   <-+-- unchanged
		 *	|###|     |
		 *	+---+-----+
		 *	  ^---------- changed
		 */
		if (newrange.MinX != ped->RangeRect.MinX)
			RectFill (rp, min (ped->RangeRect.MinX, newrange.MinX),
				newrange.MinY,
				max (ped->RangeRect.MinX, newrange.MinX) - 1,
				newrange.MaxY);

		/*	+-----+---+
		 *	|     |###|
		 *	|     |###|
		 *	|     |###|
		 *	|     |###|
		 *	+-----+---+
		 */
		if (newrange.MaxX != ped->RangeRect.MaxX)
			RectFill (rp, min (ped->RangeRect.MaxX, newrange.MaxX) + 1,
				newrange.MinY,
				max (ped->RangeRect.MaxX, newrange.MaxX),
				newrange.MaxY);

		/*	+---------+
		 *	|#########|
		 *	+---------+
		 *	|         |
		 *	|         |
		 *	+---------+
		 */
		if (newrange.MinY != ped->RangeRect.MinY)
			RectFill (rp, ped->RangeRect.MinX,
				min (ped->RangeRect.MinY, newrange.MinY),
				ped->RangeRect.MaxX,
				max (ped->RangeRect.MinY, newrange.MinY) - 1);

		/*	+---------+
		 *	|         |
		 *	|         |
		 *	+---------+
		 *	|#########|
		 *	+---------+
		 */
		if (newrange.MaxY != ped->RangeRect.MaxY)
			RectFill (rp, ped->RangeRect.MinX,
				min (ped->RangeRect.MaxY, newrange.MaxY) + 1,
				ped->RangeRect.MaxX,
				max (ped->RangeRect.MaxY, newrange.MaxY));
	}

	/* Copy new values */
	ped->RangeRect = newrange;

	SafeSetWriteMask (rp, (UBYTE)~0);
}



static void ClearRange (struct RastPort *rp, struct PattEditData *ped)
{
	SafeSetWriteMask (rp, ped->TextPen);
	SetDrMd (rp, COMPLEMENT);

	RectFill (rp, ped->RangeRect.MinX, ped->RangeRect.MinY,
		ped->RangeRect.MaxX, ped->RangeRect.MaxY);

	memset (&ped->RangeRect, 0, sizeof (ped->RangeRect));

	SafeSetWriteMask (rp, (UBYTE)~0);
}



static void RedrawAll (struct RastPort *rp, struct PattEditData *ped, struct ExtGadget *g)
{
	UWORD	HOffset,
			TrackSize = ped->FontXSize * TRACKWIDTH,
			tmp;
	ULONG	i;


	/* Erase the whole gadget imagery */

	SetAPen (rp, 0);
	SetDrMd (rp, JAM2);

	if (!ped->Patt)
	{
		/* Clear everything */

		RectFill (rp, ped->GBounds.Left, ped->GBounds.Top,
			ped->GBounds.Left + ped->GBounds.Width - 1, ped->GBounds.Top + ped->GBounds.Height - 1);
		return;
	}

	if (rp->BitMap->Depth > 1)
	{
		/* Do not clear the bitplanes used by the text because they will
		 * be completely redrawn later.
		 */
		SafeSetWriteMask (rp, (UBYTE)~ped->TextPen);


		/* +------------+
		 * |*********   |
		 * |*Cleared*   |
		 * |*********   |
		 * |            |
		 * +------------+
		 */
		RectFill (rp, ped->GBounds.Left, ped->GBounds.Top,
			ped->TBounds.Left + ped->TBounds.Width - 1, ped->TBounds.Top + ped->TBounds.Height - 1);

		/* Restore the Mask */
		SafeSetWriteMask (rp, (UBYTE)~0);
	}

	/* Now clear the area at the right and bottom side of
	 * the editing field.
	 */

		/* +------------+
		 * |         ***|
		 * |         ***|
		 * |         ***|
		 * |            |
		 * +------------+
		 */
	if (ped->TBounds.Left + ped->TBounds.Width < ped->GBounds.Left + ped->GBounds.Width)
		RectFill (rp, ped->TBounds.Left + ped->TBounds.Width, ped->GBounds.Top,
			ped->GBounds.Left + ped->GBounds.Width - 1, ped->TBounds.Top + ped->TBounds.Height - 1);

		/* +------------+
		 * |            |
		 * |            |
		 * |            |
		 * |************|
		 * +------------+
		 */
	if (ped->TBounds.Top + ped->TBounds.Height < ped->GBounds.Top + ped->GBounds.Height)
		RectFill (rp, ped->GBounds.Left, ped->TBounds.Top + ped->TBounds.Height,
			ped->GBounds.Left + ped->GBounds.Width - 1, ped->GBounds.Top + ped->GBounds.Height - 1);


	/* Cursor shouldn't be deleted */
	ped->CursState = IDS_NORMAL;

	if (!(ped->Patt)) return;


	/* Draw track separator lines */

	SetAPen (rp, ped->LinesPen);
	HOffset = ped->TBounds.Left - 1;

	for (i = 0; i <= ped->DisplayTracks; i++, HOffset += TrackSize)
	{
		Move (rp, HOffset, ped->GBounds.Top);
		Draw (rp, HOffset, ped->GBounds.Top + ped->GBounds.Height - 1);
		Move (rp, HOffset - 1, ped->GBounds.Top);
		Draw (rp, HOffset - 1, ped->GBounds.Top + ped->GBounds.Height - 1);
	}


	/* Draw tiny vertical separator lines */

	if (ped->Flags & PEF_DOTINYLINES)
	{
		SetAPen (rp, ped->TinyLinesPen);
		SetDrPt (rp, 0xAAAA);
		HOffset = ped->TBounds.Left - 1;

		for (i = 0; i < ped->DisplayTracks; i++, HOffset += TrackSize)
		{
			Move (rp, tmp = HOffset + ped->FontXSize * 3, ped->GBounds.Top);
			Draw (rp, tmp, ped->GBounds.Top + ped->GBounds.Height - 1);
			Move (rp, tmp = HOffset + ped->FontXSize * 5, ped->GBounds.Top);
			Draw (rp, tmp, ped->GBounds.Top + ped->GBounds.Height - 1);
			Move (rp, tmp = HOffset + ped->FontXSize * 7, ped->GBounds.Top);
			Draw (rp, tmp, ped->GBounds.Top + ped->GBounds.Height - 1);
		}

		SetDrPt (rp, 0xFFFF);
	}

	RedrawPattern (rp, ped, g);

	DrawTrackNumbers (rp, ped);
}



static void DrawTrackNumbers (struct RastPort *rp, struct PattEditData *ped)
{
	struct TextFont *oldfont  = rp->Font;
	UWORD	TrackSize = ped->FontXSize * TRACKWIDTH,
			HOffset = ped->TBounds.Left + ped->FontXSize * 5;
	UWORD	i;
	UBYTE	ch;


	if (GfxBase->lib_Version >= 39)
	{
		SetWrMsk (rp, ped->LinesPen);
		SetABPenDrMd (rp, ped->LinesPen, 0, JAM2);
	}
	else
	{
		rp->Mask = ped->LinesPen;
		SetAPen (rp, ped->LinesPen);
		SetBPen (rp, 0);
		SetDrMd (rp, JAM2);	/* JAM1 or JAM2... Which one is faster? */
	}

	SetFont (rp, ped->EditorFont);

	for (i = 0; i < ped->DisplayTracks; i++, HOffset += TrackSize)
	{
		Move (rp, HOffset, ped->GBounds.Top + ped->EditorFont->tf_Baseline);
		ch = HexValuesNo0[((i+ped->LeftTrack)>>4) & 0xF];
		Text (rp, &ch, 1);
		Move (rp, HOffset, ped->GBounds.Top + ped->FontXSize + ped->EditorFont->tf_Baseline);
		ch = HexValues[(i+ped->LeftTrack) & 0xF];
		Text (rp, &ch, 1);
	}

	SetFont (rp, oldfont);
}



static void RedrawPattern (struct RastPort *rp, struct PattEditData *ped, struct ExtGadget *g)
{
	/* Redraw all lines */
	if (ped->DisplayLines)
		DrawPatternLines (rp, ped, 0, ped->DisplayLines-1);

	if (ped->Flags & PEF_MARKING)
		/* Clear the range rectangle bounds so the next call
		 * to DrawCursor() will redraw all the range box.
		 */
		memset (&ped->RangeRect, 0, sizeof (ped->RangeRect));

	DrawCursor (rp, ped, g);
}



static void DrawPatternLines (struct RastPort *rp, struct PattEditData *ped, UWORD min, UWORD max)

/* Draws Pattern display lines.  Only lines from <min> to <max> are drawn.
 * To redraw all the display, pass min = 0 and max = ped->DisplayLines - 1.
 */
{
	struct Pattern		*patt;
	struct TextFont		*oldfont = rp->Font;
	UWORD				 i, j;
	UWORD				 VOffset = ped->TBounds.Top + ped->EditorFont->tf_Baseline;
	UBYTE __aligned		*l,
						 line[TRACKWIDTH*MAXTRACKS + 4];


	if (!(patt = ped->Patt)) return;

	SetFont (rp, ped->EditorFont);

	if (GfxBase->lib_Version >= 39)
	{
		SetWriteMask (rp, ped->TextPen);
		SetABPenDrMd (rp, ped->TextPen, 0, JAM2);
	}
	else
	{
		rp->Mask = ped->TextPen;
		SetAPen (rp, ped->TextPen);
		SetBPen (rp, 0);
		SetDrMd (rp, JAM2);	/* JAM1 or JAM2... Which one is faster? */
	}

	for (i = min; i <= max; i++)
	{
		l = line;

		/* Write Line Numbers column */

		if (ped->Flags & PEF_HEXMODE)
		{
			*l++ = HexValues[((i+ped->TopLine)>>8) & 0xF];
			*l++ = HexValues[((i+ped->TopLine)>>4) & 0xF];
			*l++ = HexValues[((i+ped->TopLine) & 0xF)];
		}
		else
		{
			*l++ = HexValues[((i+ped->TopLine) / 100) % 10];
			*l++ = HexValues[((i+ped->TopLine) / 10) % 10];
			*l++ = HexValues[((i+ped->TopLine) % 10)];
		}

		*l++ = ' ';

		for (j = 0; j < ped->DisplayTracks; j++, l += TRACKWIDTH)
			ped->Note2ASCIIFunc (&patt->Notes[j+ped->LeftTrack][i+ped->TopLine], l);

		Move (rp, ped->GBounds.Left, VOffset + i * ped->FontYSize);
		Text (rp, line, ped->DisplayTracks * TRACKWIDTH + 4);
	}

	SafeSetWriteMask (rp, (UBYTE)~0);
	SetFont (rp, oldfont);
}



static void DrawNote (struct RastPort *rp, struct PattEditData *ped)

/* Draws the note under the cursor. DrawNote() won't draw if the cursor
 * is outside the editing area. Range marking mode is also taken into
 * account and the colors of the note will be reversed if the note must
 * be hilighted.
 */
{
	struct Pattern		*patt;
	struct TextFont		*oldfont = rp->Font;

	UBYTE buf[TRACKWIDTH];


	if (!(patt = ped->Patt)) return;

	/* Is the cursor outside the editing area? */

	if ((ped->Line < ped->TopLine) || (ped->Line >= ped->TopLine + ped->DisplayLines) ||
		(ped->Track < ped->LeftTrack) || (ped->Track >= ped->LeftTrack + ped->DisplayTracks))
			return;

	SetFont (rp, ped->EditorFont);

	if (GfxBase->lib_Version >= 39)
	{
		SetWriteMask (rp, ped->TextPen);
		if (ped->Flags & PEF_MARKING)
			SetABPenDrMd (rp, 0, ped->TextPen, JAM2);
		else
			SetABPenDrMd (rp, ped->TextPen, 0, JAM2);
	}
	else
	{
		rp->Mask = ped->TextPen;
		if (ped->Flags & PEF_MARKING)
		{
			SetAPen (rp, 0);
			SetBPen (rp, ped->TextPen);
		}
		else
		{
			SetAPen (rp, ped->TextPen);
			SetBPen (rp, 0);
		}
		SetDrMd (rp, JAM2);	/* JAM1 or JAM2... Which one is faster? */
	}


	ped->Note2ASCIIFunc (&patt->Notes[ped->Track][ped->Line], buf);

	Move (rp, ped->TBounds.Left + ((ped->Track - ped->LeftTrack) * ped->FontXSize * TRACKWIDTH),
		ped->TBounds.Top + ped->EditorFont->tf_Baseline + (ped->Line - ped->TopLine) * ped->FontYSize);
	Text (rp, buf, TRACKWIDTH);

	SafeSetWriteMask (rp, (UBYTE)~0);
	SetFont (rp, oldfont);
}



static void Note2ASCIIBlank0 (struct Note *note, UBYTE *s)

/* Fill buffer <s> with the ASCII representation of a
 * Note structure.  <s> should be able to hold at
 * least <TRACKWIDTH> characters.
 */
{
	*((ULONG *)s) = TextNotes[note->Note];

	if (note->Inst)
	{
		s[3] = HexValuesNo0[note->Inst>>4];
		s[4] = HexValues[note->Inst & 0x0F];
	}
	else
	{
		s[3] = ' ';
		s[4] = '-';
	}

	s[5] = ' ';

	if (note->EffNum || note->EffVal)
	{
		s[6] = HexValues[note->EffNum];
		s[7] = HexValues[note->EffVal>>4];
		s[8] = HexValues[note->EffVal & 0xF];
		s[9] = ' ';
	}
	else
		*((ULONG *)(s+6)) = ' .  ';
}



static void Note2ASCII (struct Note *note, UBYTE *s)

/* Fill buffer <s> with the ASCII representation of a
 * Note structure.  <s> should be able to hold at
 * least <TRACKWIDTH> characters.
 */
{
	*((ULONG *)s) = note->Note ? TextNotes[note->Note] : '--- ';

	s[3] = HexValuesNo0[note->Inst>>4];
	s[4] = HexValues[note->Inst & 0x0F];

	s[5] = ' ';

	s[6] = HexValues[note->EffNum];
	s[7] = HexValues[note->EffVal>>4];
	s[8] = HexValues[note->EffVal & 0xF];
	s[9] = ' ';
}



static UWORD ScrollPattern (struct RastPort *rp, struct PattEditData *ped, struct ExtGadget *g, UWORD lefttrack, UWORD topline)
/*
 * Scroll the display to the new position <lefttrack>, <topline>.
 *
 * RESULT
 *  0 - no scrolling occurred,
 *  1 - vertical scroll occurred,
 *  2 - horizontal scroll occurred,
 *  3 - scrolled in both directions.
 */
{
	if (ped->LeftTrack != lefttrack)
	{
		UWORD retval = 2 | ped->TopLine != topline;

		ped->LeftTrack = lefttrack;
		ped->TopLine = topline;

		EraseCursor (rp, ped);
		DrawTrackNumbers (rp, ped);
		RedrawPattern (rp, ped, g);

		return retval;
	}
	else
	{
		UWORD scroll_lines = abs(ped->TopLine - topline);

		/* Redraw everything if more than a quarter of the screen
		 * has changed.
		 */
		if (scroll_lines > ped->DisplayLines / 4)
		{
			ped->LeftTrack = lefttrack;
			ped->TopLine = topline;

			EraseCursor (rp, ped);
			RedrawPattern (rp, ped, g);
			return 1;
		}
		else
		{
			WORD scroll_dy = (topline - ped->TopLine) * ped->FontYSize;

			EraseCursor (rp, ped);

			/* Scroll range rectangle */

			ped->RangeRect.MinY -= scroll_dy;
			ped->RangeRect.MaxY -= scroll_dy;

			if (ped->RangeRect.MinY < ped->TBounds.Top)
				ped->RangeRect.MinY = ped->TBounds.Top;
			if (ped->RangeRect.MaxY >= ped->TBounds.Top + ped->TBounds.Height)
				ped->RangeRect.MaxY = ped->TBounds.Top + ped->TBounds.Height - 1;

			/* We use ClipBlit() to scroll the pattern because it doesn't clear
			 * the scrolled region like ScrollRaster() would do.  Unfortunately,
			 * ClipBlit() does not scroll along the damage regions, so we also
			 * call ScrollRaster() with the mask set to 0, which will scroll the
			 * layer damage regions without actually modifying the display.
			 */

			SafeSetWriteMask (rp, ped->TextPen);

			if (scroll_dy > 0)
				/* Scroll Down */
				ClipBlit (rp, ped->GBounds.Left, ped->TBounds.Top + scroll_dy,
					rp, ped->GBounds.Left, ped->TBounds.Top,
					ped->TBounds.Width + (ped->TBounds.Left - ped->GBounds.Left), ped->TBounds.Height - scroll_dy,
					0x0C0);
			else
				/* Scroll Up */
				ClipBlit (rp, ped->GBounds.Left, ped->TBounds.Top,
					rp, ped->GBounds.Left, ped->TBounds.Top - scroll_dy,
					ped->TBounds.Width + (ped->TBounds.Left - ped->GBounds.Left), ped->TBounds.Height + scroll_dy,
					0x0C0);


			/* This will scroll the layer damage regions */
			SafeSetWriteMask (rp, 0);
			ScrollRaster (rp, 0, scroll_dy,
				ped->GBounds.Left, ped->TBounds.Top,
				ped->TBounds.Left + ped->TBounds.Width - 1,
				ped->TBounds.Top + ped->TBounds.Height - 1);

			ped->LeftTrack = lefttrack;
			ped->TopLine = topline;

			if (scroll_dy > 0)
				/* Scroll down */
				DrawPatternLines (rp, ped, ped->DisplayLines - scroll_lines, ped->DisplayLines-1);
			else
				/* Scroll up */
				DrawPatternLines (rp, ped, 0, scroll_lines - 1);

			SafeSetWriteMask (rp, (UBYTE)~0);
			DrawCursor (rp, ped, g);

			return 1;
		}
	}

	return 0;
}



/*
static void __interrupt __asm TimerIntServer (register __a1 struct Gadget *g)
{
	struct PattEditData *ped = INST_DATA (OCLASS(g), g);

	/* Remove TimerIO for further usage */
	GetMsg (&ped->TimerPort);

	if ((ped->Flags & PEF_SCROLLING) && ped->TopLine)
	{
		SetGadgetAttrs (g, ped->MyWindow, NULL,
			PATTA_Up,	1,
			TAG_DONE);

		/* Send another request for next scroll */
		ped->TimerIO.tr_node.io_Command = TR_ADDREQUEST;
		ped->TimerIO.tr_time.tv_micro = 500000;
		BeginIO ((struct IORequest *)&ped->TimerIO);
	}
}
*/


struct Library * __asm _UserLibInit (register __a6 struct Library *mybase)
{
	SysBase = *((struct ExecBase **)4);

	IntuitionBase	= (struct IntuitionBase *) OpenLibrary ("intuition.library", 37);
	GfxBase			= (struct GfxBase *) OpenLibrary ("graphics.library", 37);
	UtilityBase		= OpenLibrary ("utility.library", 37);
	KeymapBase		= OpenLibrary ("keymap.library", 36);

	if (!(IntuitionBase && GfxBase && UtilityBase && KeymapBase))
	{
		_UserLibCleanup (mybase);
		return NULL;
	}

	if (PattEditClass = MakeClass (PATTEDITCLASS, GADGETCLASS, NULL, sizeof (struct PattEditData), 0))
	{
		PattEditClass->cl_Dispatcher.h_Entry = (ULONG (*)()) PattEditDispatcher;
		AddClass (PattEditClass);
	}
	else
	{
		_UserLibCleanup (mybase);
		return NULL;
	}

	return mybase;
}



void __asm _UserLibCleanup (register __a6 struct Library *mybase)
{
	if (PattEditClass)
	{
		RemoveClass		(PattEditClass);
		FreeClass		(PattEditClass);
	}

	if (KeymapBase)		CloseLibrary ((struct Library *)KeymapBase);
	if (UtilityBase)	CloseLibrary ((struct Library *)UtilityBase);
	if (GfxBase)		CloseLibrary ((struct Library *)GfxBase);
	if (IntuitionBase)	CloseLibrary ((struct Library *)IntuitionBase);
}



struct IClass * __asm _GetEngine (register __a6 struct Library *mybase)
{
	return (PattEditClass);
}
