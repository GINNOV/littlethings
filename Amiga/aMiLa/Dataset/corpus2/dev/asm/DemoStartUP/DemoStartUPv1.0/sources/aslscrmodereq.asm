	xdef    _AslCgxModeRequester
	xdef	_displayid

	xref	_DosBase
	xref	_IntuitionBase
	xref	_GfxBase
	xref	_CyberGfxBase

	include	"basemacros.i"

	incdir	include:

	include utility/tagitem.i

	include LVO/exec_lib.i
	include	LVO/cybergraphics_lib.i
	include	LVO/asl_lib.i

	include	libraries/asl.i

	include cybergraphx/cybergraphics.i

_AslCgxModeRequester

	;Open asl.library
	lea.l	ASLName(pc),a1
	moveq.l	#39,d0
	callExe	OpenLibrary
	move.l	d0,_AslBase
	beq.w	.noasl

	;Allocate ASL requester
	move.l	#ASL_ScreenModeRequest,d0
	lea	aslreqtaglist,a0
	callAsl	AllocAslRequest
	move.l	d0,aslrequest
	beq.s	.closeasl

	;Show ASL requester
	move.l	aslrequest(pc),a0
	move.l	#0,a1
	callAsl	AslRequest
	move.l	#0,_displayid
	tst.l	d0
	beq.w	.closeasl

	move.l	aslrequest(pc),a0
	move.l	sm_DisplayID(a0),_displayid

.closeasl
        ;Close asl.library
	move.l	_AslBase(pc),a1
	callExe	CloseLibrary
.noasl
	rts

ASLName	dc.b	'asl.library',0
	even
_AslBase dc.l	 0

aslrequest
	dc.l	0

aslreqtaglist
	dc.l	ASLSM_TitleText,asl_title
	dc.l	ASLSM_FilterFunc,smfilterhook
	dc.l	TAG_END

asl_title
	dc.b	'Select CGX/P96 screen mode (320x256)',0
	even
smfilterhook
	dc.l	0,0
	dc.l	smfilterfunc
	dc.l	0,0


smfilterfunc
	move.l	a1,_displayid

	;Check if it is CGX mode
	move.l	a1,d0
	callCgx	IsCyberModeID
        tst.l	d0
        beq.s	.false

	;Check if it is LUT8
	move.l	#CYBRIDATTR_PIXFMT,d0
	move.l	_displayid,d1
	callCgx	GetCyberIDAttr
	cmp.l	#PIXFMT_LUT8,d0
	bne.s   .false

	rept	0

	;Check if width is 320
	move.l  #CYBRIDATTR_WIDTH,d0
	move.l  _displayid,d1
	callCgx	GetCyberIDAttr
	cmp.l   #SCREEN_WIDTH,d0
	bne.s   .false

	;Check if height is 256
	move.l	#CYBRIDATTR_HEIGHT,d0
	move.l	_displayid,d1
	callCgx	GetCyberIDAttr
	cmp.l	#SCREEN_HEIGHT,d0
	bne.s	.false

	endr

	moveq	#TRUE,d0
	rts
.false
	moveq	#FALSE,d0
	rts

_displayid
	dc.l	0

