#ifndef  _CLIPITCONSTANTS_H
# define _CLIPITCONSTANTS_H 1

# define FORMSIZE_OFFSET 8

# define FTXT_CLIP_TYPE 0
# define ILBM_CLIP_TYPE 1

# define FTXT_RESPONSE  1 // Requester button numbers
# define ILBM_RESPONSE  0

// Main GUI Gadget-related constants...

# define ID_ViewClip 	    0
# define ID_MakeClip 	    1
# define ID_ClipLV 	    2
# define ID_ToolTypes 	    3
# define ID_ClipSize  	    4
# define ID_ClipType 	    5
# define ID_TTypeString     6
# define ID_Delete 	    7
# define ID_StatusTxt       8
# define ID_ClipSelectedTxt 9
# define ID_ClipNum         10
# define ID_UpdateBt        11

# define DBC_CNT 	    12

# define VIEWCLIPBt      DBCGadgets[ ID_ViewClip ]
# define DELETECLIPBt    DBCGadgets[ ID_Delete ]
# define TOOLTYPES_LV    DBCGadgets[ ID_ToolTypes ]
# define CLIPS_LV        DBCGadgets[ ID_ClipLV ]
# define TOOLSTR_GAD     DBCGadgets[ ID_TTypeString ]
# define STATUS_TXT_GAD  DBCGadgets[ ID_StatusTxt ]
# define CLIPTYPE_TXT    DBCGadgets[ ID_ClipType ]
# define CLIPSIZE_TXT    DBCGadgets[ ID_ClipSize ]
# define CLIP_NUMGAD     DBCGadgets[ ID_ClipNum ]
# define CLIP_TXT_GAD    DBCGadgets[ ID_ClipSelectedTxt ]

# define CLIP_NUMBER     IntBfPtr( CLIP_NUMGAD )
# define TOOLTYPE_STRING StrBfPtr( TOOLSTR_GAD )
# define CLIP_TEXT       StrBfPtr( CLIP_TXT_GAD )

// ListView-related constants...
# define MAX_CLIPS          256 // There can only be one for each clip number!
# define NUM_TOOLS          20
# define ELEMENT_SIZE       80

// ToolType-related constants...
# define TNAMELENGTH 32
# define TOOL_LENGTH 128

# define CLIPPATH_TOOL    0
# define TEXTEDITOR_TOOL  1
# define TEXTVIEWER_TOOL  2
# define IMAGEEDITOR_TOOL 3
# define IMAGEVIEWER_TOOL 4
# define PROGRAMPATH_TOOL 5
# define HELPFILE_TOOL    6
# define HELPVIEWER_TOOL  7

#endif // _CLIPITCONSTANTS_H

/* --------------- END of ClipItConstants.h file! -------------- */
