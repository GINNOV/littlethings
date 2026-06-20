

* If Nico Francois doesn't like my version of the reqtools.library
* include files, TOUGH. I'm writing software on MY Amiga and I'll
* do it MY way...


rtAllocRequestA		equ	-30
rtFreeRequest		equ	-36
rtFreeReqBuffer		equ	-42
rtChangeReqAttrA		equ	-48
rtFileRequestA		equ	-54
rtFreeFileList		equ	-60
rtEZRequestA		equ	-66
rtGetStringA		equ	-72
rtGetLongA		equ	-78
rtInternalGetPasswordA	equ	-84	; private!
rtInternalEnterPasswordA	equ	-90	; private!
rtFontRequestA		equ	-96
rtPaletteRequestA		equ	-102
rtReqHandlerA		equ	-108
rtSetWaitPointer		equ	-114
rtGetVScreenSize		equ	-120
rtSetReqPosition		equ	-126
rtSpread			equ	-132
rtScreenToFrontSafely	equ	-138


REQTOOLSVERSION	equ	 37


* TextAttr structure


		rsreset
ta_Name		rs.l	1
ta_YSize		rs.w	1
ta_Style		rs.b	1
ta_Flags		rs.b	1
ta_sizeof	rs.w	0


		rsreset

rt_RTBase	rs.b	lib_sizeof
rt_Flags		rs.b	1
rt_Pad		rs.b	3
rt_SegList	rs.l	1
rt_IntuitionBase	rs.l	1
rt_GFXBase	rs.l	1
rt_DOSBase	rs.l	1
rt_GadToolsBase	rs.l	1
rt_UtilityBase	rs.l	1
rt_Sizeof	rs.w	0


* types of requesters, for rtAllocRequestA()


RT_FILEREQ		equ	 0
RT_REQINFO		equ	 1
RT_FONTREQ		equ	 2

************************
*                      *
*    File requester    *
*                      *
************************


* structure _MUST_ be allocated with rtAllocRequest()


		rsreset

rtfi_ReqPos	rs.l	1
rtfi_LeftOffset	rs.w	1
rtfi_TopOffset	rs.w	1
rtfi_Flags	rs.l	1
rtfi_Hook	rs.l	1
rtfi_Dir		rs.l	1	;READ ONLY:Change with rtChangeReqAttrA()
rtfi_MatchPat	rs.l	1	;READ ONLY:Change with rtChangeReqAttrA()
rtfi_DefaultFont	rs.l	1
rtfi_WaitPointer	rs.l	1

* Lots of private data follows! HANDS OFF :-)

rtfi_Private	rs.w	0


* returned by rtFileRequestA() if multiselect is enabled,
* free list with rtFreeFileList()

		rsreset

rtfl_Next	rs.l	1
rtfl_StrLen	rs.l	1
rtfl_Name	rs.l	1
rtfl_Sizeof	rs.w	0


************************
*                      *
*    Font requester    *
*                      *
************************

* structure _MUST_ be allocated with rtAllocRequest()


		rsreset

rtfo_ReqPos	rs.l	1
rtfo_LeftOffset	rs.w	1
rtfo_TopOffset	rs.w	1
rtfo_Flags	rs.l	1
rtfo_Hook	rs.l	1
rtfo_Attr	rs.b	ta_sizeof
rtfo_DefaultFont	rs.l	1
rtfo_WaitPointer	rs.l	1

* Lots of private data follows! HANDS OFF :-)

rtfo_Private	rs.w	0


************************
*                      *
*    Requester Info    *
*                      *
************************

* for rtEZRequestA(), rtGetLongA(), rtGetStringA() and rtPaletteRequestA(),
* _MUST_ be allocated with rtAllocRequest()


		rsreset

rtri_Reqpos	rs.l	1
rtri_LeftOffset	rs.w	1
rtri_TopOffset	rs.w	1
rtri_Width	rs.l	1	;not for rtEZRequestA()
rtri_ReqTitle	rs.l	1	;currently only for rtEZRequestA()
rtri_Flags	rs.l	1	;only for rtEZRequestA()
rtri_DefaultFont	rs.l	1	;currently only for rtPaletteRequestA()
rtri_WaitPointer	rs.l	1

* structure may be extended in future

rtri_Private	rs.w	0



************************
*                      *
*     Handler Info     *
*                      *
************************

* for rtReqHandlerA(), will be allocated for you when you use
* the RT_ReqHandler tag, never try to allocate this yourself!


		rsreset
rthi_Private1	rs.l	1	;first longword is private!
rthi_WaitMask	rs.l	1
rthi_DoNotWait	rs.l	1

* Private data follows, HANDS OFF :-)



* possible return codes from rtReqHandlerA()

CALL_HANDLER		equ	 $80000000


**************************************
*                                    *
*                TAGS                *
*                                    *
**************************************

RT_TagBase		equ	 TAG_USER

*** tags understood by most requester functions ***
*
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
*
* title of requester window - default "Request" or "Information"
RTEZ_ReqTitle		equ	 (RT_TagBase+20)
* (RT_TagBase+21) reserved
* various flags (see below)
RTEZ_Flags		equ	 (RT_TagBase+22)
* default response (activated by pressing RETURN) - default TRUE
RTEZ_DefaultResponse	equ	 (RT_TagBase+23)

*** tags specific to rtNewGetLongA ***
*
* minimum allowed value - default MININT
RTGL_Min		equ	 (RT_TagBase+30)
* maximum allowed value - default MAXINT
RTGL_Max		equ	 (RT_TagBase+31)
* suggested width of requester window (in pixels)
RTGL_Width		equ	 (RT_TagBase+32)
* boolean to show the default value - default TRUE
RTGL_ShowDefault	equ	 (RT_TagBase+33)

*** tags specific to rtNewGetStringA ***
*
* suggested width of requester window (in pixels)
RTGS_Width		equ	 RTGL_Width
* allow empty string to be accepted - default FALSE
RTGS_AllowEmpty		equ	 (RT_TagBase+80)

*** tags specific to rtFileRequestA ***
*
* various flags (see below)
RTFI_Flags		equ	 (RT_TagBase+40)
* suggested height of file requester
RTFI_Height		equ	 (RT_TagBase+41)
* replacement text for 'Ok' gadget (max 6 chars)
RTFI_OkText		equ	 (RT_TagBase+42)

*** tags specific to rtFontRequestA ***
*
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
*
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
*
* initially selected color - default 1
RTPA_Color		equ	 (RT_TagBase+70)

*** tags for rtReqHandlerA ***
*
* end requester by software control, set tagdata to REQ_CANCEL, REQ_OK or
* in case of rtEZRequest to the return value
RTRH_EndRequest		equ	 (RT_TagBase+60)

*** tags for rtAllocRequestA ***
* no tags defined yet


*************
* RT_ReqPos *
*************
REQPOS_POINTER		equ	 0
REQPOS_CENTERWIN	equ	 1
REQPOS_CENTERSCR	equ	 2
REQPOS_TOPLEFTWIN	equ	 3
REQPOS_TOPLEFTSCR	equ	 4

*******************
* RTRH_EndRequest *
*******************
REQ_CANCEL		equ	 0
REQ_OK			equ	 1

****************************************
* flags for RTFI_Flags and RTFO_Flags  *
* or filereq->Flags and fontreq->Flags *
****************************************

FREQ_NOBUFFER		equ	$0004
FREQ_DOWILDFUNC		equ	$0800

******************************************
* flags for RTFI_Flags or filereq->Flags *
******************************************

FREQ_MULTISELECT		equ	$0001
FREQ_SAVE		equ	$0002
FREQ_NOFILES		equ	$0008
FREQ_PATGAD		equ	$0010
FREQ_SELECTDIRS		equ	$1000

******************************************
* flags for RTFO_Flags or fontreq->Flags *
******************************************

FREQ_FIXEDWIDTH		equ	$0020
FREQ_COLORFONTS		equ	$0040
FREQ_CHANGEPALETTE	equ	$0080
FREQ_LEAVEPALETTE		equ	$0100
FREQ_SCALE		equ	$0200
FREQ_STYLE		equ	$0400

******************************************
* flags for RTEZ_Flags or reqinfo->Flags *
******************************************

EZREQ_NORETURNKEY		equ	$0001
EZREQ_LAMIGAQUAL		equ	$0002
EZREQ_CENTERTEXT		equ	$0004

*********
* hooks *
*********

REQHOOK_WILDFILE	equ	 0
REQHOOK_WILDFONT	equ	 1









