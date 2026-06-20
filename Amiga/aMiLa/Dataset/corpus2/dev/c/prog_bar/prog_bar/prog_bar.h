/*
** $Filename: progbar.h $
** $Release: 1.0 $
** $Revision: 36.1 $
** $Date: 18/11/96 $
**
** Prog_Bar definitions, a progress bar system
**
** (C) Copyright 1996 by Allan Savage
** All Rights Reserved
*/

#ifndef PROG_BAR_H
#define PROG_BAR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

/* ----------------------------------------------------------------------- */

#define PB_Dummy        TAG_USER + 0x60000

/* Tags for CreateProgBar() and SetProgBarAttrs() */

#define PB_LeftEdge        PB_Dummy+1           /* X pos */
#define PB_TopEdge         PB_Dummy+2           /* Y pos */
#define PB_Width           PB_Dummy+3           /* Width */
#define PB_Height          PB_Dummy+4           /* Height */
#define PB_Direction       PB_Dummy+5           /* Direction of Expansion */
#define PB_BarColour       PB_Dummy+6           /* Bar colour */
#define PB_BarBackColour   PB_Dummy+7           /* Bar Background colour */
#define PB_BarSize         PB_Dummy+8           /* Value of full Bar */
#define PB_BarValue        PB_Dummy+9           /* Value of filled Bar */
#define PB_BorderType      PB_Dummy+10          /* Type of Border */

#define PB_TextMode        PB_Dummy+11          /* Actual Value or %age */
#define PB_TextPosition    PB_Dummy+12          /* Position to display text */
#define PB_TextColour      PB_Dummy+13          /* Text Colour */
#define PB_TextBackColour  PB_Dummy+14          /* Text BackGround Colour */
#define PB_TextFont        PB_Dummy+15          /* Font for text (*TextAttr) */

/* Options for PB_Direction */

#define PBDE_RIGHT         0        /* From Left to Right  ( default ) */
#define PBDE_LEFT          1        /* From Right to Left */
#define PBDE_UP            2        /* From Bottom to Top */
#define PBDE_DOWN          3        /* From Top to Bottom */

/* Options for PB_BorderType */

#define PBBT_NONE          10       /* No Border */
#define PBBT_PLAIN         11       /* Plain Black Box  ( default )*/
#define PBBT_RECESSED      12       /* Recessed Box */
#define PBBT_RAISED        13       /* Raised Box */
#define PBBT_RIDGE         14       /* Raised Ridge */

/* Options for Text Mode */

#define PBTM_NONE          20       /* No Text  ( default ) */
#define PBTM_PERCENT       21       /* Display Value as a %age */
#define PBTM_VALUE         22       /* Display Value as "Value/Total" */

/* Options for Text Position */

#define PBTP_BELOW         30       /* Text centred below Bar  ( default ) */
#define PBTP_ABOVE         31       /* Text centred above Bar */
#define PBTP_LEFT          32       /* Text to left of Bar */
#define PBTP_RIGHT         33       /* Text to right of Bar */
#define PBTP_CENTRE        34       /* Text centred inside Bar */

/* Structure Definition */

struct P_Bar {

   /* The following fields are set up when the Progress Bar is created.
      They are simply quick reference points for the information needed
      to display the Progress Bar.  DO NOT CHANGE THE VALUES STORED HERE. */

   struct Window *   Wnd;              /* Window to render Bar in */
   struct RastPort * R_Port;           /* RastPort used for rendering */
   APTR              Vis_Info;         /* VisualInfo for Bar */
   struct IntuiText  Bar_IText;        /* Used to display the Text */
   char              Bar_Text[16];     /* Used to store the Text */

   /* The following fields are used to store the current settings for the
      Progress Bar.  They should not be changed directly, but can be altered
      using SetProgBarAttrs() */

   UWORD             LeftEdge;         /* Column Number for Left Edge */
   UWORD             TopEdge;          /* Row Number for Top Edge */
   UWORD             Width;            /* Total Width  ( including Border ) */
   UWORD             Height;           /* Total Height ( including Border ) */

   UBYTE             Direction;        /* Direction for Bar Expansion */

   UBYTE             Bar_Colour;       /* Pen Number for rendering Bar */
   UBYTE             Bar_Background;   /* Pen Number for Bar Background */
   UWORD             Bar_Size;         /* Value for full bar */
   UWORD             Bar_Value;        /* Current Value for Bar */

   UBYTE             Border_Type;      /* Type of Border */

   UBYTE             Text_Mode;        /* Mode for text display */
   UBYTE             Text_Position;    /* Placement for Text */

   /* The following fields are working variables for the functions and
      should not be used or altered by your program. */

   UWORD             B_LeftEdge;       /* LeftEdge of Bar ( No Border ) */
   UWORD             B_RightEdge;      /* RightEdge of Bar ( No Border ) */
   UWORD             B_TopEdge;        /* TopEdge of Bar ( No Border ) */
   UWORD             B_BottomEdge;     /* BottomEdge of Bar ( No Border ) */
   UWORD             B_Length;         /* Bar Length in pixels ( No Border ) */
   UWORD             B_Value;          /* Number of pixels to fill */
   UBYTE             B_Percent;        /* Percentage of Bar filled */
   UWORD             T_Width;          /* Width of text in pixels */
   UWORD             T_Height;         /* Height of text in pixels */
   UWORD             MT_Width;         /* Max Text Width in Pixels */
   UWORD             MT_Left;          /* Left coordinate of longest test */
   UWORD             MT_Top;           /* Top coordinate of longest text */
   };

typedef struct P_Bar       PBAR;


/* Function Prototypes */

PBAR *CreateProgBarA ( struct Window *Wnd, UWORD Left, UWORD Top, UWORD Width,
                       UWORD Height, UWORD Size, struct TagList *taglist );
PBAR *CreateProgBar  ( struct Window *Wnd, UWORD Left, UWORD Top, UWORD Width,
                       UWORD Height, UWORD Size, Tag First_Tag, ... );
void SetProgBarAttrsA ( PBAR *PB, struct TagList *taglist );
void SetProgBarAttrs ( PBAR *PB, Tag First_Tag, ... );
void FreeProgBar ( PBAR *PB );
void RefreshProgBar ( PBAR *PB );
void UpdateProgBar ( PBAR *PB, UWORD Value );
#define ResetProgBar(PB) UpdateProgBar(PB, 0)
void ClearProgBar ( PBAR *PB );
void ClearBar ( PBAR *PB );
void ClearText ( PBAR *PB );

#endif
