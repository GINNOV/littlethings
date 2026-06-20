
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

 STRUCTURE rtFontRequester,0
	ULONG rtfo_ReqPos
	UWORD rtfo_LeftOffset
	UWORD rtfo_TopOffset
	ULONG rtfo_Flags_
	APTR  rtfo_Hook;
	STRUCT rtfo_Attr,8		;ta_SIZEOF * READ ONLY!
	APTR  rtfo_DefaultFont
	ULONG rtfo_WaitPointer

CALL_HANDLER	equ	$80000000

RT_FILEREQ	equ	0
RT_REQINFO	equ	1
RT_FONTREQ	equ	2

RT_TagBase	equ	$80000000

RT_Window	equ	RT_TagBase+1
RT_IDCMPFlags	equ	RT_TagBase+2
RT_ReqPos	equ	RT_TagBase+3
RT_LeftOffset	equ	RT_TagBase+4
RT_TopOffset	equ	RT_TagBase+5
RT_PubScrName	equ	RT_TagBase+6
RT_Screen	equ	RT_TagBase+7
RT_ReqHandler	equ	RT_TagBase+8
RT_DefaultFont	equ	RT_TagBase+9
RT_WaitPointer	equ	RT_TagBase+10
RT_UnderScore	equ	RT_TagBase+11

RTEZ_ReqTitle	equ	RT_TagBase+20
RTEZ_Flags	equ	RT_TagBase+22
RTEZ_DefaultResponse	equ	RT_TagBase+23

RTGL_Min	equ	RT_TagBase+30
RTGL_Max	equ	RT_TagBase+31
RTGL_Width	equ	RT_TagBase+32
RTGL_ShowDefault equ	RT_TagBase+33
RTGL_TextFmt	equ	RT_TagBase+38

RTGS_Width	equ	RTGL_Width
RTGS_AllowEmpty	equ	RT_TagBase+80
RTGS_TextFmt	equ	RTGL_TextFmt

RTFI_Flags	equ	RT_TagBase+40
RTFI_Height	equ	RT_TagBase+41
RTFI_OkText	equ	RT_TagBase+42

RTFO_Flags	equ	RTFI_Flags
RTFO_Height	equ	RTFI_Height
RTFO_OkText	equ	RTFI_OkText
RTFO_SampleHeight equ	RT_TagBase+60
RTFO_MinHeight	equ	RT_TagBase+61
RTFO_MaxHeight	equ	RT_TagBase+62

RTFI_Dir	equ	RT_TagBase+50
RTFI_MatchPat	equ	RT_TagBase+51
RTFI_AddEntry	equ	RT_TagBase+52
RTFI_RemoveEntry equ	RT_TagBase+53
RTFO_FontName	equ	RT_TagBase+63
RTFO_FontHeight	equ	RT_TagBase+64
RTFO_FontStyle	equ	RT_TagBase+65
RTFO_FontFlags	equ	RT_TagBase+66

RTPA_Color	equ	RT_TagBase+70

RTRH_EndRequest	equ	RT_TagBase+60

REQPOS_POINTER		equ	0
REQPOS_CENTERWIN	equ	1
REQPOS_CENTERSCR	equ	2
REQPOS_TOPLEFTWIN	equ	3
REQPOS_TOPLEFTSCR	equ	4

REQ_CANCEL	equ	0
REQ_OK	equ	1

	BITDEF FREQ,NOBUFFER,2
	BITDEF FREQ,DOWILDFUNC,11

	BITDEF FREQ,MULTISELECT,0
	BITDEF FREQ,SAVE,1
	BITDEF FREQ,NOFILES,3
	BITDEF FREQ,PATGAD,4
	BITDEF FREQ,SELECTDIRS,12

	BITDEF FREQ,FIXEDWIDTH,5
	BITDEF FREQ,COLORFONTS,6
	BITDEF FREQ,CHANGEPALETTE,7
	BITDEF FREQ,LEAVEPALETTE,8
	BITDEF FREQ,SCALE,9
	BITDEF FREQ,STYLE,10

	BITDEF EZREQ,NORETURNKEY,0
	BITDEF EZREQ,LAMIGAQUAL,1
	BITDEF EZREQ,CENTERTEXT,2

	BITDEF GSREQ,CENTERTEXT,2

REQHOOK_WILDFILE	equ	0
REQHOOK_WILDFONT	equ	1
