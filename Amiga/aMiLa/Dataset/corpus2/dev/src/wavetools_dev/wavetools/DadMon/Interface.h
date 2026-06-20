/*
** Available routines
** The only way to quit is closing the window
** the main prog checks in from time to time via
** UpdateFace and could be told then if user has closed window
** ie. returns -1.
*/

struct MsgPort *OpenFace( WORD WIN_LEFT,  WORD WIN_TOP,  WORD WIN_WIDTH, WORD WIN_HEIGHT);	/* open the interface, it returns a UserPort */

void MoveFace(WORD left_sample,WORD right_sample); 		/* scroll window, draw new lines, */

void FreshFace(void);			/* just redraw face */

void CloseFace(void); 			/* close window and such */

