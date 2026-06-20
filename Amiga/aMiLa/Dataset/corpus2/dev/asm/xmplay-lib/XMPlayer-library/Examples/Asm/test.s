;This program explains how to use xmplayer.library
;Author: CruST/Amnesty^Humbug
;Date: 17.04.2001
;Library coded by CruST / Amnesty^.humbug.
;Released by .humbug. 17.01.2001
;Library based on the PS3M source 
;Copyright (c) Jarno Paananen a.k.a. Guru / S2 1994-96.

		incdir	include:
		include	dos/dos.i
		include	libraries/xmplayer.i
		include	lvos.i

		section	code,code_p

Start
		movem.l	d0-a6,-(sp)
		
		move.l	$4.w,a6
		moveq	#0,d0
		lea	dos_name,a1
		jsr	_LVOOpenLibrary(a6)
		tst.l	d0
		beq	.error
		move.l	d0,dos_base

		move.l	$4.w,a6
		moveq	#0,d0
		lea	xm_pl_name,a1
		jsr	_LVOOpenLibrary(a6)
		tst.l	d0
		beq	.error_xmpl
		move.l	d0,xmpl_base

		move.l	xmpl_base,a6
		move.l	#xm_struct,a0
		move.l	#module,XMPl_Cont(a0)		;module pointer
		move.l	#XM_STEREO14,XMPl_Mixtype(a0)	;mixing type - see autodoc
		move.l	#22000,XMPl_Mixfreq(a0)		;mixing frequency - see autodoc
		move.l	#2,XMPl_Vboost(a0)		;volume boosting - see autodoc
		move.l	#pr_name,XMPl_PrName(a0)	;name for playing process - see autodoc
		move.l	#0,XMPl_PrPri(a0)		;playing process priority - see autodoc
		jsr	_LVOXMPl_Init(a6)		;inits a player structure
		cmp.l	#FALSE,d0			;if FALSE
		beq	.ende				;error

		move.l	xmpl_base,a6
		jsr	_LVOXMPl_Play(a6)		;I don't know... ;)
		cmp.l	#FALSE,d0			;if FALSE
		beq	.fuck				;error

		move.l	dos_base,a6
		move.l	#20*TICKS_PER_SECOND,d1
		jsr	_LVODelay(a6)			;delay 20 secs and...

		move.l	xmpl_base,a6
		jsr	_LVOXMPl_StopPlay(a6)		;stop playing process
.fuck		
		move.l	xmpl_base,a6
		jsr	_LVOXMPl_DeInit(a6)		;guess what...	
.ende
		move.l	$4.w,a6
		move.l	xmpl_base,a1
		jsr	_LVOCloseLibrary(a6)
.error_xmpl
		move.l	$4.w,a6
		move.l	dos_base,a1
		jsr	_LVOCloseLibrary(a6)

.error
		movem.l	(sp)+,d0-a6
		moveq	#0,d0
		rts
		
xmpl_base	dc.l	0
dos_base	dc.l	0
	
xm_pl_name	dc.b	"xmplayer.library",0
dos_name	dc.b	"dos.library",0
pr_name		dc.b	"Amnesty XM-Player",0
xm_struct	ds.b	XMPlayerInfo_SIZE

			section	xmmodule,data_p

module		incbin	"example.xm"
