/* Fader_protos.h - (22-Feb-1999)
 * mad.nano (mad.nano@mailcity.com)
 *
 * Feel free to use/modify this code as much as you like.
 *
 * USE AT YOUR OWN RISK. I AM NOT RESPONSIBLE FOR
 * ANY DAMAGE THIS CODE MIGHT DO.
 *
 *
 *	NOTE:
 *	 You need to open graphics.library
 */


/*	Fades the screen to BLACK.
		Screen *	screen
		APTR			Source table. Same format as for LoadRGB32()
		UWORD		speed (0-30)
		NOTE: The table passed to this function will be over-written */
extern void FadeBlack(struct Screen *,APTR,UWORD);


/*	Fades the screen to WHITE.
		Screen *	screen
		APTR			Source table. Same format as for LoadRGB32().
		UWORD		speed (0-30)
		NOTE: The table passed to this function will be over-written. */
extern void FadeWhite(struct Screen *,APTR,UWORD);


/*	Fades from a given source table to a given destination table.
		Screen *	screen
		APTR			Source table. Same format as for LoadRGB32()
		APTR			Destination table.
		UWORD		speed (0-30) */
extern void FadeCol2Col(struct Screen *,APTR,APTR,UWORD);


/*	Fades from BLACK to specified table.
		Screen *	screen
		APTR			Destination table. Same format as for LoadRGB32()
		UWORD		speed (0-30) */
extern void FadeBlack2Col(struct Screen *,APTR,UWORD);


/*	Fades from WHITE.to specified table.
		Screen *	screen
		APTR			Destination table. Same format as for LoadRGB32()
		UWORD		speed (0-30) */
extern void FadeWhite2Col(struct Screen *,APTR,UWORD);


