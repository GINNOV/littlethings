#ifndef PATTEDITCLASS_H
#define PATTEDITCLASS_H
/*
**	PattEditClass.h
**
**	Copyright (C) 1995 by Bernardo Innocenti
**
**	Pattern editor class built on top of the "gadgetclass".
**
**	Note: Use 4 chars wide TABs to read this file.
*/


#define PATTEDITNAME	"gadgets/pattedit.gadget"
#define PATTEDITCLASS	"patteditclass"
#define PATTEDITVERS	1


/********************/
/* Class Attributes */
/********************/

#define PATTA_CursTrack			(TAG_USER+1)
#define PATTA_CursColumn		(TAG_USER+2)
#define PATTA_CursLine			(TAG_USER+3)
	/* (IGSNU) Cursor position.
	 */

#define PATTA_LeftTrack			(TAG_USER+4)
#define PATTA_TopLine			(TAG_USER+5)
	/* (IGSNU) Top line and leftmost track of the editor view.
	 */

#define PATTA_Left				(TAG_USER+6)
#define PATTA_Right				(TAG_USER+7)
#define PATTA_Up				(TAG_USER+8)
#define PATTA_Down				(TAG_USER+9)
#define PATTA_CursLeft			(TAG_USER+10)
#define PATTA_CursRight			(TAG_USER+11)
#define PATTA_CursUp			(TAG_USER+12)
#define PATTA_CursDown			(TAG_USER+13)
	/* (S) PATTA_Left and PATTA_Right scroll the view left and right one
	 * line.  The cursor is positioned to the leftmost or rightmost
	 * position, respectively. PATTA_Up and PATTA_Down scroll the view up
	 * and down of one line.  The cursor is positioned to the upper or
	 * lower visible line, respectively.   PATTA_Curs#? attributes move
	 * the cursor one position towards the direction specified.  The
	 * contents of ti_Data is meaningless for all these attributes.
	 */

#define PATTA_UndoChange		(TAG_USER+14)
	/* (S) If ti_Data is > 0, one change made to the pattern is
	 * undone.  If ti_Data is < 0, a previously undone change is
	 * redone.  The cursor is always moved on the affected position.
	 */

#define PATTA_Changes			(TAG_USER+15)
	/* (IGS) ti_Data contains the number of changes made to the pattern.
	 */

#define PATTA_MarkRegion		(TAG_USER+16)
	/* (GS) ti_Data points to a struct Rectangle containing the
	 * limits (tracks and lines) of a pattern sub-region.
	 * When set, this attribute automatically starts range mode.
	 * Passing NULL in ti_Data causes the editor to clear the
	 * marked region. Passing ~0 in ti_Data toggles mark mode.
	 * Getting this attribute returns a copy of the currently
	 * marked region, or {0,0,0,0} if no region is currently
	 * selected.
	 */

#define PATTA_Flags			(TAG_USER+17)
	/* (IGSN) See PEF_#? flags definitions below.
	 */

#define PATTA_DisplayTracks		(TAG_USER+18)
#define PATTA_DisplayLines		(TAG_USER+19)
	/* (GN) Maximum number of tracks and lines that fit in the gadget
	 * bounds.
	 */

#define PATTA_Pattern			(TAG_USER+20)
	/* (ISGU) ti_Data is a pointer to the Pattern
	 * structure to be displayed by the PatternEditor.
	 */

#define PATTA_CurrentInst		(TAG_USER+21)
	/* (IS) ti_Data is the default instrument
	 * number to be used when entering notes in the
	 * pattern editor.
	 */

#define PATTA_MaxUndoLevels		(TAG_USER+22)
	/* (IS) ti_Data is the maximum size of the undo buffer in number
	 * of slots.  0 disables undo feature.  Defaults to 16.
	 */

#define PATTA_MaxUndoMem		(TAG_USER+23)
	/* (IS) ti_Data is the maximum memory used by the undo buffers.
	 * Setting it to 0 means unlimited memory.  Defaults to 8192 bytes.
	 */

#define PATTA_TextFont			(TAG_USER+24)
	/* (I) ti_Data points to the TextFont to be
	 * used with the PatternEditor.  The font must
	 * be mono spaced.
	 */

#define PATTA_AdvanceCurs		(TAG_USER+25)
	/* (IS) The lower 16 bits of ti_Data contain the (signed)
	 * number of lines the cursor moves when a note is typed.
	 * The upper 16 bits contain the number of tracks.
	 */

#define PATTA_CursWrap			(TAG_USER+26)
	/* (IS) Can be 0 for no wrapping, PEF_HWRAP, PEF_VWRAP or both.
	 */

#define PATTA_TextPen			(TAG_USER+27)
#define PATTA_LinesPen			(TAG_USER+28)
#define PATTA_TinyLinesPen		(TAG_USER+29)
	/* (IS) Pens to be used to render the various editor elements.
	 * PATTA_TextPen must be a power of two (1, 2, 4, 8...) because
	 * the text is rendered on one bitplane only. PATTA_LinesPen
	 * and PATTA_TinyLinesPen must not have the PATTA_TextPen bit
	 * set because text scrolling happens on the text bitplane only
	 * and must not disturb the other elements.  The defaults are
	 * 1 for PATTA_TextPen and 2 for both PATTA_LinesPen and
	 * PATTA_TinyLinesPen.
	 */

#define PATTA_KeyboardMap		(TAG_USER+30)
	/* (IS) ti_Data points to a table which describes the notes associated
	 * to of the keys.  The table starts with 1 Word specifying the number
	 * of keys following.
	 *
	 * Each key definition has this format:
	 *
	 *	1 Byte with the note associated with the first key.
	 *	1 Byte with the instrument associated with the first key.
	 *		This value may be 0, in which case the current instrument
	 *		will be used.
	 *
	 * Passing NULL in ti_Data disables keyboard mapping.
	 *
	 * NOTE: The table is referenced, not copied, so it must stay in
	 * memory until the pattern editor is disposed or the table is
	 * disabled.
	 */



/* Definitions for PATTA_Flags attribute */

#define PEF_MARKING			(1<<0)	/* Range mode						*/
#define PEF_HWRAP			(1<<1)	/* Horizontal cursor wrap			*/
#define PEF_VWRAP			(1<<2)	/* Vertical cursor wrap				*/
#define PEF_HEXMODE			(1<<3)	/* Use hexadecimal numbers			*/
#define PEF_BLANKZERO		(1<<4)	/* Blank zero digits				*/
#define PEF_INVERSETEXT		(1<<5)	/* Show backfilled text				*/
#define PEF_DOTINYLINES		(1<<6)	/* Show tiny separator lines		*/
#define PEF_DOCURSORRULER	(1<<7)	/* Show a ruler under the cursor	*/

/* Private flags - Not settable by application */
#define PEF_SCROLLING		(1<<30)	/* View is scrolling (read only)	*/
#define PEF_DRAGGING		(1<<31)	/* Cursor drag mode (read only)		*/



/* Width of a track expressed in chars */
#define TRACKWIDTH	10


/* Cursor column names */
enum {
	COL_NOTE,	/* Cursor on note field					*/
	COL_INSTH,	/* Cursor on instrument high nibble		*/
	COL_INSTL,	/* Cursor on instrument low  nibble 	*/
	COL_EFF,	/* Cursor on effect field				*/
	COL_VALH,	/* Cursor on effect value high nibble	*/
	COL_VALL,	/* Cursor on effect value low  nibble	*/

	COL_COUNT
};

#endif /* PATTEDITCLASS_H */
