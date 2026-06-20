	IFND	LIBRARIES_REQTOOLS_I
LIBRARIES_REQTOOLS_I SET 1

	IFND	EXEC_LISTS_I
	include "exec/lists.i"
	ENDC

	IFND	EXEC_LIBRARIES_I
	include "exec/libraries.i"
	ENDC

	IFND	GRAPHICS_TEXT_I
	include "graphics/text.i"
	ENDC

	IFND	UTILITY_TAGITEM_I
	include "utility/tagitem.i"
	ENDC

;REQTOOLSNAME	MACRO
;	dc.b "reqtools.library",0
;	ENDM

REQTOOLSVERSION	equ	37

	STRUCTURE ReqToolsBase,LIB_SIZE
		UBYTE rt_Flags
		STRUCT rt_pad,3
		ULONG rt_SegList
* The following library bases may be read and used by your program
		APTR rt_IntuitionBase
		APTR rt_GfxBase
		APTR rt_DOSBase
* Next two library bases are only (and always) valid on Kickstart 2.0!
* (1.3 version of reqtools also initializes these when run on 2.0)
		APTR rt_GadToolsBase
		APTR rt_UtilityBase
		LABEL ReqToolsBase_SIZE

* types of requesters, for rtAllocRequestA()
RT_FILEREQ	equ	0
RT_REQINFO	equ	1
RT_FONTREQ	equ	2

************************
*                      *
*    File requester    *
*                      *
************************

* structure _MUST_ be allocated with rtAllocRequest()

	STRUCTURE rtFileRequester,0
		ULONG rtfi_ReqPos
		UWORD rtfi_LeftOffset
		UWORD rtfi_TopOffset
		ULONG rtfi_Flags_
		APTR  rtfi_Hook;
		APTR  rtfi_Dir_            * READ ONLY! Change with rtChangeReqAttrA()!
		APTR  rtfi_MatchPat_       * READ ONLY! Change with rtChangeReqAttrA()!
		APTR  rtfi_DefaultFont
		ULONG rtfi_WaitPointer
* Lots of private data follows! HANDS OFF :-)

* returned by rtFileRequestA() if multiselect is enabled,
* free list with rtFreeFileList()

	STRUCTURE rtFileList,0
		APTR  rtfl_Next
		ULONG rtfl_StrLen
		APTR  rtfl_Name
		LABEL rtFileList_SIZE

************************
*                      *
*    Font requester    *
*                      *
************************

* structure _MUST_ be allocated with rtAllocRequest()

	STRUCTURE rtFontRequester,0
		ULONG rtfo_ReqPos
		UWORD rtfo_LeftOffset
		UWORD rtfo_TopOffset
		ULONG rtfo_Flags_
		APTR  rtfo_Hook;
		STRUCT rtfo_Attr,ta_SIZEOF	* READ ONLY!
		APTR  rtfo_DefaultFont
		ULONG rtfo_WaitPointer
* Lots of private data follows! HANDS OFF :-)

************************
*                      *
*    Requester Info    *
*                      *
************************

* for rtEZRequestA(), rtGetLongA(), rtGetStringA() and rtPaletteRequestA(),
* _MUST_ be allocated with rtAllocRequest()

	STRUCTURE rtReqInfo,0
		ULONG rtri_ReqPos
		UWORD rtri_LeftOffset
		UWORD rtri_TopOffset
		ULONG rtri_Width	* not for rtEZRequestA()
		APTR  rtri_ReqTitle	* currently only for rtEZRequestA()
		ULONG rtri_Flags	* only for rtEZRequestA()
		APTR  rtri_DefaultFont	* currently only for rtPaletteRequestA()
		ULONG rtri_WaitPointer
* structure may be extended in future

************************
*                      *
*     Handler Info     *
*                      *
************************

* for rtReqHandlerA(), will be allocated for you when you use
* the RT_ReqHandler tag, never try to allocate this yourself!

	STRUCTURE rtHandlerInfo,4	* first longword is private!
		ULONG rthi_WaitMask
		ULONG rthi_DoNotWait
* Private data follows, HANDS OFF :-)

* possible return codes from rtReqHandlerA()

CALL_HANDLER	equ	$80000000


**************************************
*                                    *
*                TAGS                *
*                                    *
**************************************

RT_TagBase		equ	 TAG_USER

*** tags understood by most requester functions ***

* optional pointer to window
RT_Window		equ	 (RT_TagBase+1)
* idcmp flags requester should abort on (useful for IDCMP_DISKINSERTED)
RT_IDCMPFlags		equ	 (RT_TagBase+2)
* position of requester window (see below) - default REQPOS_POINTER
RT_ReqPos		equ	 (RT_TagBase+3)
* leftedge offset of requester relative to position specified by RT_ReqPos
RT_LeftOffset		equ	 (RT_TagBase+4)
* topedge offset of requester relative to position specified by RT_ReqPos
RT_TopOffset		equ	 (RT_TagBase+5)
* name of public screen to put requester on (use on Kickstart 2.0 only!)
RT_PubScrName		equ	 (RT_TagBase+6)
* address of screen to put requester on
RT_Screen		equ	 (RT_TagBase+7)
* additional signal mask to wait on
RT_ReqHandler		equ	 (RT_TagBase+8)
* font to use when screen font is rejected, _MUST_ be fixed-width font!
* (struct TextFont *, not struct TextAttr *!)
* - default GfxBase->DefaultFont
RT_DefaultFont		equ	 (RT_TagBase+9)
* boolean to set the standard wait pointer in window - default FALSE
RT_WaitPointer		equ	 (RT_TagBase+10)

*** tags specific to rtEZRequestA ***

* title of requester window - default "Request" or "Information"
RTEZ_ReqTitle		equ	 (RT_TagBase+20)
* (RT_TagBase+21) reserved
* various flags (see below)
RTEZ_Flags		equ	 (RT_TagBase+22)
* default response (activated by pressing RETURN) - default TRUE
RTEZ_DefaultResponse	equ	 (RT_TagBase+23)

*** tags specific to rtNewGetLongA ***

* minimum allowed value - default MININT
RTGL_Min		equ	 (RT_TagBase+30)
* maximum allowed value - default MAXINT
RTGL_Max		equ	 (RT_TagBase+31)
* suggested width of requester window (in pixels)
RTGL_Width		equ	 (RT_TagBase+32)
* boolean to show the default value - default TRUE
RTGL_ShowDefault	equ	 (RT_TagBase+33)

*** tags specific to rtNewGetStringA ***

* suggested width of requester window (in pixels)
RTGS_Width		equ	 RTGL_Width
* allow empty string to be accepted - default FALSE
RTGS_AllowEmpty		equ	 (RT_TagBase+80)

*** tags specific to rtFileRequestA ***

* various flags (see below)
RTFI_Flags		equ	(RT_TagBase+40)
* suggested height of file requester
RTFI_Height		equ	(RT_TagBase+41)
* replacement text for 'Ok' gadget (max 6 chars)
RTFI_OkText		equ	(RT_TagBase+42)

*** tags specific to rtFontRequestA ***

* various flags (see below)
RTFO_Flags		equ	 RTFI_Flags
* suggested height of font requester
RTFO_Height		equ	 RTFI_Height
* replacement text for 'Ok' gadget (max 6 chars)
RTFO_OkText		equ	 RTFI_OkText
* suggested height of font sample display - default 24
RTFO_SampleHeight	equ	 (RT_TagBase+60)
* minimum height of font displayed
RTFO_MinHeight		equ	 (RT_TagBase+61)
* maximum height of font displayed
RTFO_MaxHeight		equ	 (RT_TagBase+62)
* [(RT_TagBase+63) to (RT_TagBase+66) used below]

*** tags for rtChangeReqAttrA ***

* file requester - set directory
RTFI_Dir		equ	 (RT_TagBase+50)
* file requester - set wildcard pattern
RTFI_MatchPat		equ	 (RT_TagBase+51)
* file requester - add a file or directory to the buffer
RTFI_AddEntry		equ	 (RT_TagBase+52)
* file requester - remove a file or directory from the buffer
RTFI_RemoveEntry	equ	 (RT_TagBase+53)
* font requester - set font name of selected font
RTFO_FontName		equ	 (RT_TagBase+63)
* font requester - set font size
RTFO_FontHeight		equ	 (RT_TagBase+64)
* font requester - set font style
RTFO_FontStyle		equ	 (RT_TagBase+65)
* font requester - set font flags
RTFO_FontFlags		equ	 (RT_TagBase+66)

*** tags for rtPaletteRequestA ***

* initially selected color - default 1
RTPA_Color		equ	 (RT_TagBase+70)

*** tags for rtReqHandlerA ***

* end requester by software control, set tagdata to REQ_CANCEL, REQ_OK or
* in case of rtEZRequest to the return value
RTRH_EndRequest		equ	 (RT_TagBase+60)

*** tags for rtAllocRequestA ***
* no tags defined yet


*************
* RT_ReqPos *
*************
REQPOS_POINTER		equ	0
REQPOS_CENTERWIN	equ	1
REQPOS_CENTERSCR	equ	2
REQPOS_TOPLEFTWIN	equ	3
REQPOS_TOPLEFTSCR	equ	4

*******************
* RTRH_EndRequest *
*******************
REQ_CANCEL		equ	0
REQ_OK			equ	1

****************************************
* flags for RTFI_Flags and RTFO_Flags  *
* or filereq->Flags and fontreq->Flags *
****************************************
   BITDEF FREQ,NOBUFFER,2
   BITDEF FREQ,DOWILDFUNC,11

******************************************
* flags for RTFI_Flags or filereq->Flags *
******************************************
   BITDEF FREQ,MULTISELECT,0
   BITDEF FREQ,SAVE,1
   BITDEF FREQ,NOFILES,3
   BITDEF FREQ,PATGAD,4
   BITDEF FREQ,SELECTDIRS,12

******************************************
* flags for RTFO_Flags or fontreq->Flags *
******************************************
   BITDEF FREQ,FIXEDWIDTH,5
   BITDEF FREQ,COLORFONTS,6
   BITDEF FREQ,CHANGEPALETTE,7
   BITDEF FREQ,LEAVEPALETTE,8
   BITDEF FREQ,SCALE,9
   BITDEF FREQ,STYLE,10

******************************************
* flags for RTEZ_Flags or reqinfo->Flags *
******************************************
   BITDEF EZREQ,NORETURNKEY,0
   BITDEF EZREQ,LAMIGAQUAL,1
   BITDEF EZREQ,CENTERTEXT,2

*********
* hooks *
*********
REQHOOK_WILDFILE	equ	0
REQHOOK_WILDFONT	equ	1

	ENDC ; LIBRARIES_REQTOOLS_I
