/*
**	ScrollButtonClass.h
**
**	Copyright (C) 1995 by Bernardo Innocenti
**
**	Scroller button class built on top of the "buttongclass".
*/

/* Function prototypes */

Class	*InitScrollButtonClass	(void);
BOOL	 FreeScrollButtonClass	(Class *);
Class	*InitVImageClass		(void);
BOOL	 FreeVImageClass		(Class *);


/* Values for SYSIA_Which attribute of ImageButtonClass */
#define IM_PLAY 0
#define IM_STOP 1
#define IM_REW	2
#define IM_FWD	3
