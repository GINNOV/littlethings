    IFND INTUITION_GADGETCLASS_I
INTUITION_GADGETCLASS_I SET 1

**
** $Id: gadgetclass.i,v 40.0 94/02/15 18:04:33 davidj Exp Locker: davidj $
**
** Custom and 'boopsi' gadget class interface
**
**  (C) Copyright 1989-1994 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

;*****************************************************************************

    IFND EXEC_TYPES_I
    INCLUDE "exec/types.i"
    ENDC

    IFND INTUITION_INTUITION_I
    INCLUDE "intuition/intuition.i"
    ENDC

    IFND UTILITY_TAGITEM_I
    INCLUDE "utility/tagitem.i"
    ENDC

;*****************************************************************************
*
* NOTE:  intuition/iobsolete.i is included at the END of this file!
*
;*****************************************************************************

; Gadget Class attributes
GA_Dummy 		equ	(TAG_USER+$30000)

GA_Left			equ	(GA_Dummy+1)
     * (LONG) Left edge of the gadget relative to the left edge of
     * the window

GA_RelRight		equ	(GA_Dummy+2)
     * (LONG) Left edge of the gadget relative to the right edge of
     * the window

GA_Top			equ	(GA_Dummy+3)
     * (LONG) Top edge of the gadget relative to the top edge of
     * the window

GA_RelBottom		equ	(GA_Dummy+4)
     * (LONG) Top edge of the gadget relative to the bottom edge
     * of the window

GA_Width		equ	(GA_Dummy+5)
     * (LONG) Width of the gadget

GA_RelWidth		equ	(GA_Dummy+6)
     * (LONG) Width of the gadget relative to the width of the
     * window

GA_Height		equ	(GA_Dummy+7)
     * (LONG) Height of the gadget

GA_RelHeight		equ	(GA_Dummy+8)
     * (LONG) Height of the gadget relative to the height of
     * the window

GA_Text			equ	(GA_Dummy+9)
     * (STRPTR) Gadget imagry is NULL terminated string

GA_Image		equ	(GA_Dummy+10)
     * (struct Image *) Gadget imagry is an image

GA_Border		equ	(GA_Dummy+11)
     * (struct Border *) Gadget imagry is a border

GA_SelectRender		equ	(GA_Dummy+12)
     * (struct Image *) Selected gadget imagry

GA_Highlight		equ	(GA_Dummy+13)
     * (UWORD) One of GFLG_GADGHNONE, GFLG_GADGHBOX, GFLG_GADGHCOMP,
     * or GFLG_GADGHIMAGE

GA_Disabled		equ	(GA_Dummy+14)
     * (BOOL) Indicate whether gadget is disabled or not.
     * Defaults to FALSE.

GA_GZZGadget		equ	(GA_Dummy+15)
     * (BOOL) Indicate whether the gadget is for
     * WFLG_GIMMEZEROZERO window borders or not.  Defaults
     * to FALSE.

GA_ID			equ	(GA_Dummy+16)
     * (UWORD) Gadget ID assigned by the application

GA_UserData		equ	(GA_Dummy+17)
     * (APTR) Application specific data

GA_SpecialInfo		equ	(GA_Dummy+18)
     * (APTR) Gadget specific data

GA_Selected		equ	(GA_Dummy+19)
     * (BOOL) Indicate whether the gadget is selected or not.
     * Defaults to FALSE

GA_EndGadget		equ	(GA_Dummy+20)
     * (BOOL) When set tells the system that when this gadget
     * is selected causes the requester that it is in to be
     * ended.  Defaults to FALSE.

GA_Immediate		equ	(GA_Dummy+21)
     * (BOOL) When set indicates that the gadget is to
     * notify the application when it becomes active.  Defaults
     * to FALSE.

GA_RelVerify		equ	(GA_Dummy+22)
     * (BOOL) When set indicates that the application wants to
     * verify that the pointer was still over the gadget when
     * the select button is released.  Defaults to FALSE.

GA_FollowMouse		equ	(GA_Dummy+23)
     * (BOOL) When set indicates that the application wants to
     * be notified of mouse movements while the gadget is active.
     * It is recommmended that GA_Immediate and GA_RelVerify are
     * also used so that the active gadget can be tracked by the
     * application.  Defaults to FALSE.

GA_RightBorder		equ	(GA_Dummy+24)
     * (BOOL) Indicate whether the gadget is in the right border
     * or not.  Defaults to FALSE.

GA_LeftBorder		equ	(GA_Dummy+25)
     * (BOOL) Indicate whether the gadget is in the left border
     * or not.  Defaults to FALSE.

GA_TopBorder		equ	(GA_Dummy+26)
     * (BOOL) Indicate whether the gadget is in the top border
     * or not.  Defaults to FALSE.

GA_BottomBorder		equ	(GA_Dummy+27)
     * (BOOL) Indicate whether the gadget is in the bottom border
     * or not.  Defaults to FALSE.

GA_ToggleSelect		equ	(GA_Dummy+28)
     * (BOOL) Indicate whether the gadget is toggle-selected
     * or not.  Defaults to FALSE.

GA_SysGadget		equ	(GA_Dummy+29)
     * (BOOL) Reserved for system use to indicate that the
     * gadget belongs to the system.  Defaults to FALSE.

GA_SysGType		equ	(GA_Dummy+30)
     * (UWORD) Reserved for system use to indicate the
     * gadget type.

GA_Previous		equ	(GA_Dummy+31)
     * (struct Gadget *) Previous gadget in the linked list.
     * NOTE: This attribute CANNOT be used to link new gadgets
     * into the gadget list of an open window or requester.
     * You must use AddGList().

GA_Next			equ	(GA_Dummy+32)
     * (struct Gadget *) Next gadget in the linked list.

GA_DrawInfo		equ	(GA_Dummy+33)
     * (struct DrawInfo *) Some gadgets need a DrawInfo at creation time

 * You should use at most ONE of GA_Text, GA_IntuiText, and GA_LabelImage
GA_IntuiText		equ	(GA_Dummy+34)
     * (struct IntuiText *) Label is an IntuiText.

GA_LabelImage		equ	(GA_Dummy+35)
     * (Object *) Label is an image object.

GA_TabCycle		equ	(GA_Dummy+36)
     * (BOOL) Indicate whether gadget is part of TAB/SHIFT-TAB cycle
     * activation.  Defaults to FALSE.  New for V37.

GA_GadgetHelp		equ	(GA_Dummy+37)
     * (BOOL) Indicate whether gadget is to send IDCMP_GADGETHELP.
     * Defaults to FALSE.  New for V39.

GA_Bounds		equ	(GA_Dummy+38)
     * (struct IBox *) Copied into the extended gadget's bounds.
     * New for V39.

GA_RelSpecial		equ	(GA_Dummy+39)
     * (BOOL) Indicate whether gadget has special relativity.  Defaults to
     * FALSE.  New for V39.

GA_TextAttr		equ	(GA_Dummy+40)
     * (struct TextAttr *) Indicate the font to use for the gadget.
     * New for V42.

GA_ReadOnly		equ	(GA_Dummy+41)
     * (BOOL) Indicate that the gadget is read-only (non-selectable).
     * Defaults to FALSE. New for V42.

;*****************************************************************************

* PROPGCLASS attributes

PGA_Dummy		EQU	(TAG_USER+$31000)
PGA_Freedom		EQU	(PGA_Dummy+$0001)
* either or both of FREEVERT and FREEHORIZ
PGA_Borderless		EQU	(PGA_Dummy+$0002)
PGA_HorizPot		EQU	(PGA_Dummy+$0003)
PGA_HorizBody		EQU	(PGA_Dummy+$0004)
PGA_VertPot		EQU	(PGA_Dummy+$0005)
PGA_VertBody		EQU	(PGA_Dummy+$0006)
PGA_Total		EQU	(PGA_Dummy+$0007)
PGA_Visible		EQU	(PGA_Dummy+$0008)
PGA_Top			EQU	(PGA_Dummy+$0009)
; New for V37:
PGA_NewLook		EQU	(PGA_Dummy+$000A)

;*****************************************************************************

* STRGCLASS attributes

STRINGA_Dummy  		EQU	(TAG_USER+$32000)
STRINGA_MaxChars	EQU	(STRINGA_Dummy+$0001)
* Note:  There is a minor problem with Intuition when using boopsi integer
* gadgets (which are requested by using STRINGA_LongInt).  Such gadgets
* must not have a STRINGA_MaxChars to be bigger than 15.  Setting
* STRINGA_MaxChars for a boopsi integer gadget will cause a mismatched
* FreeMem() to occur.

STRINGA_Buffer		EQU	(STRINGA_Dummy+$0002)
STRINGA_UndoBuffer	EQU	(STRINGA_Dummy+$0003)
STRINGA_WorkBuffer	EQU	(STRINGA_Dummy+$0004)
STRINGA_BufferPos	EQU	(STRINGA_Dummy+$0005)
STRINGA_DispPos		EQU	(STRINGA_Dummy+$0006)
STRINGA_AltKeyMap	EQU	(STRINGA_Dummy+$0007)
STRINGA_Font		EQU	(STRINGA_Dummy+$0008)
STRINGA_Pens		EQU	(STRINGA_Dummy+$0009)
STRINGA_ActivePens	EQU	(STRINGA_Dummy+$000A)
STRINGA_EditHook	EQU	(STRINGA_Dummy+$000B)
STRINGA_EditModes	EQU	(STRINGA_Dummy+$000C)

* booleans
STRINGA_ReplaceMode	EQU	(STRINGA_Dummy+$000D)
STRINGA_FixedFieldMode	EQU	(STRINGA_Dummy+$000E)
STRINGA_NoFilterMode	EQU	(STRINGA_Dummy+$000F)

STRINGA_Justification	EQU	(STRINGA_Dummy+$0010)
* GACT_STRINGCENTER, GACT_STRINGLEFT, GACT_STRINGRIGHT
STRINGA_LongVal		EQU	(STRINGA_Dummy+$0011)
STRINGA_TextVal		EQU	(STRINGA_Dummy+$0012)

STRINGA_ExitHelp	EQU	(STRINGA_Dummy+$0013)
* STRINGA_ExitHelp is new for V37, and ignored by V36.
* Set this if you want the gadget to exit when Help is
* pressed.  Look for a code of 0x5F, the rawkey code for Help

SG_DEFAULTMAXCHARS	EQU	(128)

;*****************************************************************************

* Gadget Layout related attributes

LAYOUTA_Dummy 		EQU	(TAG_USER+$38000)
LAYOUTA_LayoutObj	EQU	(LAYOUTA_Dummy+$0001)
LAYOUTA_Spacing		EQU	(LAYOUTA_Dummy+$0002)
LAYOUTA_Orientation	EQU	(LAYOUTA_Dummy+$0003)

LAYOUTA_ChildMaxWidth	equ	(LAYOUTA_Dummy+$0004)
     * (BOOL) Child objects are of equal width.  Should default to TRUE for
     * gadgets with a horizontal orientation.  New for V42.
LAYOUTA_ChildMaxHeight	equ	(LAYOUTA_Dummy+$0005)
     * (BOOL) Child objects are of equal height.  Should default to TRUE for
     * gadgets with a vertical orientation.  New for V42.

* orientation values
LORIENT_NONE		EQU	0
LORIENT_HORIZ		EQU	1
LORIENT_VERT		EQU	2

;*****************************************************************************

; Custom gadget hook command ID's
; (gadget class method/message ID's)

GM_HITTEST EQU		0	; return GMR_GADGETHIT if you are clicked
				; (whether or not you are disabled)
GM_RENDER EQU		1	; draw yourself, in the appropriate state
GM_GOACTIVE EQU		2	; you are now going to be fed input
GM_HANDLEINPUT EQU	3	; handle that input
GM_GOINACTIVE EQU	4	; whether or not by choice, you are done
GM_HELPTEST EQU		5	; Will you send gadget help if the mouse is
				; at the specified coordinates?  See below
				; for possible GMR_ values.
GM_LAYOUT EQU		6	; re-evaluate your size based on the GadgetInfo
				; Domain.  Do NOT re-render yourself yet, you
				; will be called when it is time...

;*****************************************************************************

; Parameter "Messages" passed to gadget class methods

; All parameter structure begin with a MethodID field
; This definition of an abstract generic "message" is
; equivalent to a better one in intuition/classusr.i, but
; it's left here for historic reasons
 STRUCTURE MsgHeader,0
	ULONG	MethodID
	LABEL	methodid_SIZEOF

; GM_HITTEST and GM_HELPTEST send this message.
; For GM_HITTEST, gpht_Mouse are coordinates relative to the gadget
; select box.  For GM_HELPTEST, the coordinates are relative to
; the gadget bounding box (which defaults to the select box).
 STRUCTURE	gpHitTest,methodid_SIZEOF
    APTR	gpht_GInfo
    WORD	gpht_MouseX
    WORD	gpht_MouseY

; For GM_HITTEST, return GMR_GADGETHIT if you were indeed hit,
; otherwise return zero.
;
; For GM_HELPTEST, return GMR_NOHELPHIT (zero) if you were not hit.
; Typically, return GMR_HELPHIT if you were hit.
; It is possible to pass a UWORD to the application via the Code field
; of the IDCMP_GADGETHELP message.  Return GMR_HELPCODE or'd with
; the UWORD-sized result you wish to return.
;
; GMR_HELPHIT yields a Code value of ((UWORD) ~0), which should
; mean "nothing particular" to the application.

GMR_GADGETHIT	EQU $00000004	; GM_HITTEST hit

GMR_NOHELPHIT	EQU $00000000	; GM_HELPTEST didn't hit
GMR_HELPHIT	EQU $FFFFFFFF	; GM_HELPTEST hit, return code = ~0
GMR_HELPCODE	EQU $00010000	; GM_HELPTEST hit, return low word as code

;*****************************************************************************

; GM_RENDER
 STRUCTURE	gpRender,methodid_SIZEOF
    APTR	gpr_GInfo	; gadget context
    APTR	gpr_RPort	; all ready for use
    LONG	gpr_Redraw	; might be a "highlight pass"

; values of gpr_Redraw
GREDRAW_UPDATE	EQU 2	; update for change in attributesvalues
GREDRAW_REDRAW	EQU 1	; redraw gadget
GREDRAW_TOGGLE	EQU 0	; toggle highlight, if applicable

;*****************************************************************************

; GM_GOACTIVE, GM_HANDLEINPUT
 STRUCTURE	gpInput,methodid_SIZEOF
    APTR	gpi_GInfo
    APTR	gpi_IEvent
    APTR	gpi_Termination
    WORD	gpi_MouseX
    WORD	gpi_MouseY

    ; (V39) Pointer to TabletData structure, if this event originated
    ; from a tablet which sends IESUBCLASS_NEWTABLET events, or NULL if
    ; not.
    ;
    ; DO NOT ATTEMPT TO READ THIS FIELD UNDER INTUITION PRIOR TO V39!
    ; IT WILL BE INVALID!
    APTR	gpi_TabletData

; GM_HANDLEINPUT and GM_GOACTIVE  return code flags
; return GMR_MEACTIVE (0) alone if you want more input.
; Otherwise, return ONE of GMR_NOREUSE and GMR_REUSE, and optionally
; GMR_VERIFY.

; here are the original constant "equates"
GMR_MEACTIVE	EQU $0000 	; (bugfix: was $0001 during beta)
GMR_NOREUSE	EQU $0002
GMR_REUSE	EQU $0004
GMR_VERIFY	EQU $0008	; you MUST set gpi_Termination

* New for V37:
* You can end activation with one of GMR_NEXTACTIVE and GMR_PREVACTIVE,
* which instructs Intuition to activate the next or previous gadget
* that has GFLG_TABCYCLE set.
*
GMR_NEXTACTIVE	EQU $0010
GMR_PREVACTIVE	EQU $0020

; here are standard bit/flag pairs
GMRB_NOREUSE	EQU 1
GMRB_REUSE	EQU 2
GMRB_VERIFY	EQU 3
GMRB_NEXTACTIVE	EQU 4
GMRB_PREVACTIVE	EQU 5

GMRF_NOREUSE	EQU $0002
GMRF_REUSE	EQU $0004
GMRF_VERIFY	EQU $0008
GMRF_NEXTACTIVE	EQU $0010
GMRF_PREVACTIVE	EQU $0020

;*****************************************************************************

; GM_GOINACTIVE
 STRUCTURE	gpGoInactive,methodid_SIZEOF
    APTR	gpgi_GInfo

* V37 field only!  DO NOT attempt to read under V36!
    ULONG	gpgi_Abort	; gpgi_Abort=1 if gadget was aborted
				; by Intuition and 0 if gadget went
				; inactive at its own request

;*****************************************************************************

* New for V39: Intuition sends GM_LAYOUT to any GREL_ gadget when
* the gadget is added to the window (or when the window opens, if
* the gadget was part of the NewWindow.FirstGadget or the WA_Gadgets
* list), or when the window is resized.  Your gadget can set the
* GA_RelSpecial property to get GM_LAYOUT events without Intuition
* changing the interpretation of your gadget select box.  This
* allows for completely arbitrary resizing/repositioning based on
* window size.

; GM_LAYOUT
 STRUCTURE	gpLayout,methodid_SIZEOF
    APTR	gpl_GInfo
    APTR	gpl_Initial	; non-zero if this method was invoked
				; during AddGList() or OpenWindow()
				; time.  zero if this method was invoked
				; during window resizing.

;*****************************************************************************

; The GM_DOMAIN method is used to obtain the sizing requirements of an
; object for a class before ever creating an object.

; GM_DOMAIN
 STRUCTURE	 gpDomain,methodid_SIZEOF
    APTR	 gpd_GInfo
    APTR	 gpd_RPort		; RastPort to layout for
    LONG	 gpd_Which
    STRUCT	 gpd_Domain,ibox_SIZEOF	; Result domain
    APTR	 gpd_Attrs		; Additional attributes

GDOMAIN_MINIMUM		equ	0
    ; Minimum size

GDOMAIN_NOMINAL		equ	1
    ; Nominal size

GDOMAIN_MAXIMUM		equ	2
    ; Maximum size

;*****************************************************************************

* Include obsolete identifiers:
	IFND	INTUITION_IOBSOLETE_I
	INCLUDE "intuition/iobsolete.i"
	ENDC

;*****************************************************************************

	ENDC
