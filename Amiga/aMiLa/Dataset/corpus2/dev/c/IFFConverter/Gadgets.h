// These are the gadgets for you to use.
// © by Gerben Venekamp (24-2-94)




// Some often used TagItems by GT_SetGadgetAttrsA

// Make Gadget Enabled  (None Ghosted)
ULONG EnableGadget[] = {
   GA_Disabled, FALSE,
   TAG_DONE
};

// Make Gadget Disabled (Ghosted)
ULONG DisableGadget[] = {
   GA_Disabled, TRUE,
   TAG_DONE
};


// Control your contents of your Text Gadget
// NOTE: GTTX_Text has a NULL pointer. Make sure you fill this pointer
// with the correct value. It should point to a NULL terminated string!
ULONG SetTextGadget[] = {
   GTTX_Text, NULL,
   TAG_DONE
};

// Control your contents of your Integer Gadget
ULONG SetIntegerGadget[] = {
   GTIN_Number, 0,
   TAG_DONE
};


ULONG MakeChecked[] = {
   GTCB_Checked, TRUE,
   TAG_DONE
};

ULONG UnmakeChecked[] = {
   GTCB_Checked, FALSE,
   TAG_DONE
};


/*
**   struct MyNewGadget {
**      struct NewGadget mng;
**      ULONG MyGadgetType;
**      APTR MyGadgetTags;
**   };
*/

struct Gadget *GadgetIAddress[GD_Sentinal];

UBYTE *CYL_FileMode[] = {
   "Single",
   "Sequence",
   "Multiple",
   "Dir",
   NULL
};

UBYTE *CYL_RenderMode[] = {
   "Interleave",
   "Raw",
   "Copper",
   "Font8",
//   "Sprite",  Think this one over. Should it be implemented????
   NULL
};

UBYTE *MXL_ByteBoundry[] = { 
   "None",
   "Type 1",
   "Type 2",
   "Type 3",
   NULL
};

ULONG GT_Copyright[] = {
   GTTX_Text, (ULONG) "IFFConverter © 24-2-94 by Gerben Venekamp",
   GTTX_Clipped, TRUE,
   GTTX_Justification, GTJ_CENTER,
   TAG_DONE
};

ULONG GT_PicClipDimensions[] = {
   GTTX_Text, (ULONG) "Picture and Clip Dimensions",
   TAG_DONE
};

ULONG GT_PicWidth[] = {
   GTTX_Text, (ULONG) "----",
   GTTX_Border, TRUE,
   GTTX_Justification, GTJ_RIGHT,
   TAG_DONE
};

ULONG GT_PicHeight[] = {
   GTTX_Text, (ULONG) "----",
   GTTX_Border, TRUE,
   GTTX_Justification, GTJ_RIGHT,
   TAG_DONE
};

ULONG GT_PicDepth[] = {
   GTTX_Text, (ULONG) "----",
   GTTX_Border, TRUE,
   GTTX_Justification, GTJ_RIGHT,
   TAG_DONE
};

ULONG GT_PicSize[] = {
   GTTX_Text, (ULONG) "-------",
   GTTX_Border, TRUE,
   GTTX_Justification, GTJ_RIGHT,
   TAG_DONE
};

ULONG GT_ClipWidth[] = {
   GA_Disabled, TRUE,
   GA_TabCycle, TRUE,
   GTIN_Number, 0,
   GTIN_MaxChars, 4,
   TAG_DONE
};

ULONG GT_ClipHeight[] = {
   GA_Disabled, TRUE,
   GA_TabCycle, TRUE,
   GTIN_Number, 0,
   GTIN_MaxChars, 4,
   TAG_DONE
};

ULONG GT_ClipLeft[] = {
   GA_Disabled, TRUE,
   GA_TabCycle, TRUE,
   GTIN_Number, 0,
   GTIN_MaxChars, 4,
   TAG_DONE
};

ULONG GT_ClipTop[] = {
   GA_Disabled, TRUE,
   GA_TabCycle, TRUE,
   GTIN_Number, 0,
   GTIN_MaxChars, 4,
   TAG_DONE
};

ULONG GT_ClipSize[] = {
   GTTX_Text, (ULONG) "-------",
   GTTX_Border, TRUE,
   GTTX_Justification, GTJ_RIGHT,
   TAG_DONE
};

ULONG GT_FileMode[] = {
   GTCY_Labels, (ULONG)&CYL_FileMode,
   GTCY_Active, 0,
   TAG_DONE
};

ULONG GT_RenderMode[] = {
   GTCY_Labels, (ULONG)&CYL_RenderMode,
   GTCY_Active, 0,
   TAG_DONE
};

ULONG GT_ByteBoundry[] = {
   GTMX_Labels, (ULONG)&MXL_ByteBoundry,
   GTMX_Active, 0,
   GTMX_Spacing, 2,
   TAG_DONE
};

struct MyNewGadget PanelGadgets [GD_Sentinal] = {
/* Copyright */
   0, PanelHeight-1, 640, 12,	// Left, Top, Width, Height
   NULL,		// Label
   &System_8,		// Gadget Font
   GD_Copyright,	// Gadget ID
   NULL,		// Gadget Flags
   NULL,		// Visual Info
   NULL,		// User Date
   TEXT_KIND,		// Gadget Kind
   &GT_Copyright,	// Gadget Tags.

/* Quit */
   6, 16, 50, 12,
   "Quit",
   &System_8,
   GD_Quit,
   PLACETEXT_IN,
   NULL,
   NULL,
   BUTTON_KIND,
   NULL,

/* Load */
   6, 30, 50, 12,
   "Load",
   &System_8,
   GD_Load,
   PLACETEXT_IN,
   NULL,
   NULL,
   BUTTON_KIND,
   NULL,

/* Save */
   6, 44, 50, 12,
   "Save",
   &System_8,
   GD_Save,
   PLACETEXT_IN,
   NULL,
   NULL,
   BUTTON_KIND,
   &DisableGadget,

/* PicClipDimensions */
   117, 16, 216, 12,
   NULL,
   &System_8,
   GD_PicClipDimensions,
   NULL,
   NULL,
   NULL,
   TEXT_KIND,
   &GT_PicClipDimensions,

/* PicWidth */
   154, 30, 48, 12,
   "Width :",
   &System_8,
   GD_PicDepth,
   PLACETEXT_LEFT,
   NULL,
   NULL,
   TEXT_KIND,
   &GT_PicDepth,

/* PicHeight */
   154, 44, 48, 12,
   "Height:",
   &System_8,
   GD_PicDepth,
   PLACETEXT_LEFT,
   NULL,
   NULL,
   TEXT_KIND,
   &GT_PicDepth,

/* PicDepth */
   154, 58, 48, 12,
   "Depth :",
   &System_8,
   GD_PicDepth,
   PLACETEXT_LEFT,
   NULL,
   NULL,
   TEXT_KIND,
   &GT_PicDepth,

/* PicSize */
   130, 86, 72, 12,
   "Size",
   &System_8,
   GD_PicSize,
   PLACETEXT_LEFT,
   NULL,
   NULL,
   TEXT_KIND,
   &GT_PicSize,

/* ClipWidth */
   208, 30, 56, 12,
   "Clip Width",
   &System_8,
   GD_ClipWidth,
   PLACETEXT_RIGHT,
   NULL,
   NULL,
   INTEGER_KIND,
   &GT_ClipWidth,

/* ClipHeight */
   208, 44, 56, 12,
   "Clip Height",
   &System_8,
   GD_ClipHeight,
   PLACETEXT_RIGHT,
   NULL,
   NULL,
   INTEGER_KIND,
   &GT_ClipHeight,

/* ClipLeft */
   208, 58, 56, 12,
   "Clip Left",
   &System_8,
   GD_ClipLeft,
   PLACETEXT_RIGHT,
   NULL,
   NULL,
   INTEGER_KIND,
   &GT_ClipLeft,
   
/* ClipTop */
   208, 72, 56, 12,
   "Clip Top",
   &System_8,
   GD_ClipTop,
   PLACETEXT_RIGHT,
   NULL,
   NULL,
   INTEGER_KIND,
   &GT_ClipTop,

/* ClipSize */
   208, 86, 70, 12,
   "Clip Size",
   &System_8,
   GD_ClipSize,
   PLACETEXT_RIGHT,
   NULL,
   NULL,
   TEXT_KIND,
   &GT_ClipSize,
   
/* File Mode */
   514, 16, 120, 12,
   "File Mode",
   &System_8,
   GD_FileMode,
   PLACETEXT_LEFT,
   NULL,
   NULL,
   CYCLE_KIND,
   &GT_FileMode,

/* Render Mode */
   514, 30, 120, 12,
   "Render Mode",
   &System_8,
   GD_RenderMode,
   PLACETEXT_LEFT,
   NULL,
   NULL,
   CYCLE_KIND,
   &GT_RenderMode,

/* Draw cross */
   608, 50, 0, 0,
   "Draw cross",
   &System_8,
   GD_DrawCross,
   PLACETEXT_LEFT,
   NULL,
   NULL,
   CHECKBOX_KIND,
   NULL,
   
/* Picture Info */
   6, 58, 50, 12,
   "Info",
   &System_8,
   GD_Info,
   PLACETEXT_IN,
   NULL,
   NULL,
   BUTTON_KIND,
   NULL,

/* Byte Boundry */
   612, 66, 0, 0,
   "Byte Boundry",
   &System_8,
   GD_ByteBoundry,
   PLACETEXT_LEFT,
   NULL,
   NULL,
   MX_KIND,
   &GT_ByteBoundry,

};
