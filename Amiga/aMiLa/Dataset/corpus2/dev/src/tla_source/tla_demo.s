
; +-------------------------------+
; |                               |
; | EXPERIENCE: T.L.A.            |
; |  (19.07.97)                   |
; |                               |
; +-------------------------------+-------------------------------------------+


	MACHINE	68000
	Jmp	Start
	Dc.b	'EXPERIENCE Demo 1.0 (12.7.97)',0
	EVEN

;+-----------+
;| CONSTANTS |
;+-----------+--------------------------------+

TRUE		= -1
FALSE		=  0
DS_MINPROC	=  68020			; Minimum 68020 Processor
DS_AGAMODE	=  TRUE				; Needs AGA?


;+----------+
;| INCLUDES |
;+----------+---------------------------------+

	MACHINE	DS_MINPROC
	include	'demo.i'			; All the crap needed!!


;--+------------------+
;--| CODE STARTS HERE |
;--+------------------+-------------------------------------------------------+

	MACHINE 68000				; So it wont die on 68000

Start
	;--( Open Libraries )--
	_OpenLibrary	graphics
	_OpenLibrary	dos

	;--( Do Hardware Check )--
	Bsr	Diag			; Do a system diagnosis to CLI
	Beq.s	_no_hw			;  H/W not good enough for some reason

	MACHINE	DS_MINPROC

	;--+------------------+--
	;--| Politely Kill OS |--
	;--+------------------+--

	_FlushView				; No Display Now
	Call	_LVOForbid,exec			; No multitasking either

	;-- KILL THE DMA --
	_WaitVBL

	Lea	$DFF000,a5
	Move.w	DMACONR(a5),WB_DMACON
	Move.w	#$07FF,DMACON(a5)
	Or.w	#$8000,WB_DMACON		; SETIT

	Move.l	HW_VBR(pc),a0
	Move.l	$6C(a0),HW_INT3			; Save Old Lev3 Interrupt

  ; ***********************************************************************
  ; ** We can do what we want to the hardware now without disturbing the **
  ; **  OS too much, so be prepared for some NASTY coding from now on!!  **
  ; ***********************************************************************

	;--+------------------+--
	;--| Initialise Music |--
	;--+------------------+--

	Move.w	#$8200,DMACON(a5)
	Lea	IntroMod,a0			; ** Start Intro Mod **
	Jsr	PT_Init

	Lea	Int3,a0
	Bsr	AddInt3				; Enable Our Interrupt

 ; +-<||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||>-+

	Move.w	#$0000,COL00(a5)

	;-- CHUNKY INITIALISATION --
	Lea	CHUNKY,a0
	Jsr	prec_chk_table

	;-- DEMO EFFECTS --

	Jsr	INT_INT				; The Intro
	Tst.w	EXIT
	Bne.s	.ende

	; +-------------------+
	Lea	MainMod,a0			; ** Main Module Now ***
	Jsr	PT_Init
	; +-------------------+

	Jsr	TNL_INT				; Tunnel
	Tst.w	EXIT
	Bne.s	.ende

	Jsr	LNS_INT
	Tst.w	EXIT
	Bne.s	.ende

	Jsr	YIN_INT				; Yin-Yang Bunpmap
	Tst.w	EXIT
	Bne.s	.ende

	Jsr	TRI_INT				; Siperpinski Triangle
	Tst.w	EXIT
	Bne.s	.ende

	Jsr	PIC_INT				; EXP raytraced
	Tst.w	EXIT
	Bne.s	.ende

	Jsr	LNS2_INT				; Lens Effect
	Tst.w	EXIT
	Bne.s	.ende


	; +-------------------+
	; FADE OUT MOD

	Move.w	#63,d0
.fmlp	_WaitVBL 2
	Move.w	d0,d1

	Move.l	d0,-(sp)
	Jsr	PT_SetMasterVol
	Move.l	(sp)+,d0

	Dbra	d0,.fmlp

	; RESET VOLUME
	Move.w	#63,d0
	Move.w	d0,d1
	Jsr	PT_SetMasterVol

	; +-------------------+
	; PLAY LAST MOD
	Lea	EndMod,a0
	Jsr	PT_Init
	; +-------------------+

	Jsr	ECD_INT
;	Tst.w	EXIT
;	Bne.s	.ende

.ende
 ; +-<||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||>-+



	;-- Demo Is Now Considered Finished --
	Lea	$DFF000,a5
	Move.l	HW_VBR(pc),a0
	Move.l	HW_INT3(pc),$6C(a0)		; Old VBlank Interrupt

	Jsr	PT_End

	;-- Restore OS To Former Glory --
	Move.w	WB_DMACON(pc),DMACON(a5)

  ; ****************************************************************************
  ; ** From now on we have to be nice to the OS, since things are nearly back **
  ; ** to normal. Back to OS friendly code (OS's inteerupts are restored)     **
  ; ****************************************************************************


	_RestoreView				; WB's Display is back!
						;  + Multitask (WaitTOF's)

	;-- Close Libs & shit like that --

	MACHINE	68000
_no_hw	_CloseLibrary	dos
	_CloseLibrary	graphics
	Moveq	#0,d0
	Rts					; To the realms of AmigaDOS ;^)



; +-------------+
; | SUBROUTINES |
; +-------------+-------------------------------------------------------------+


	MACHINE	68010
GrabVBR	Move.l	d0,-(sp)
	Movec	VBR,d0
	Move.l	d0,HW_VBR
	Move.l	(sp)+,d0
	Rte


	MACHINE	68000
Diag	Movem.l	d1-7/a0-6,-(sp)
	Lea	TD_VALS,a2

	;-- CPU Check --
	_CheckCPU
	Move.w	d0,(a2)+

	;-- AGA Check --
	Move.w	$DFF07C,d0		; LISAID
	Cmp.b	#$F8,d0
	Bne.s	.noaga

	Move.l	#TT_AGAY,(a2)+			; Apparently AGA
	Move.w	#-1,HW_AGA
	Bra.s	.agafin

.noaga	Move.l	#TT_AGAN,(a2)+			; Not AGA
	Move.w	#00,HW_AGA
.agafin	
	;-- Mem Checks --
	LibBase	exec
	Move.l	#2,d1			; Chip
	Call	_LVOAvailMem
	Move.l	d0,(a2)+
	Move.l	#$80002,d1		; Total Chip
	Call	_LVOAvailMem
	Move.l	d0,(a2)+
	Move.l	#4,d1			; Fast
	Call	_LVOAvailMem
	Move.l	d0,(a2)+
	Move.l	#$80004,d1		; Total Fast
	Call	_LVOAvailMem
	Move.l	d0,(a2)+

	;-- Get VBR --
	Tst.w	HW_CPU			; Is Processor A '000 ?
	Beq.s	.novbr			;  Yes -> No VBR on an '000 !!
	Lea	GrabVBR(pc),a5
	Call	_LVOSupervisor

	;-- Display Results --
.novbr	_PutCLI	TT_DIAA			; Title Bit
	_PutCLI	TT_DIAB, TD_VALS	; Hardware Bit

	;--Last Microsecond Checks --
	IFNE DS_AGAMODE
	 Tst.w	HW_AGA
	 Beq.s	.d_fail			; No AGA - Can't run
	ENDC
	Cmp.w	#(DS_MINPROC-68000)/10,HW_CPU		; ;^)
	Blt.s	.d_fail			; Processor not good enough

;d_okay	;-- We're OK now --
	_PutCLI	TT_DIAC			; Everything's OK to run demo
	Movem.l	(sp)+,d1-7/a0-6
	Moveq	#-1,d0					; Return -1 = OK
	Rts

.d_fail	;-- Whoa! Something's not right! --
	_PutCLI	TT_DIAD
	Movem.l	(sp)+,d1-7/a0-6
	Moveq	#0,d0					; Return  0 = FAIL!
	Rts



;-- AddInt3 - A0.l = Int3 Address

	MACHINE	DS_MINPROC
AddInt3	Move.l	HW_VBR,a1
	Move.l	a0,$6C(a1)
	Move.w	#$C020,$DFF000+INTENA
	Rts


;+------------------+
;| VBLANK INTERRUPT |
;+------------------+---------------------------------------------------------+

Int3	Movem.l	d0-7/a0-6,-(sp)

	Jsr	PT_Music			; Oi! TrackerPlayer

	Add.w	#1,INT_Timer1			; General Timers
	Add.w	#1,INT_Timer2

	Btst	#6,$BFE001
	Bne.s	.nolmb
	Move.w	#-1,EXIT			; User wants to exit!!

.nolmb	Movem.l	(sp)+,d0-7/a0-6
	Move.w	#$0020,$DFF000+INTREQ		; Have dealt with VBL interrupt
	Nop
	Rte


; +---------------------------------------------------------------------------+

	include	'CNK_2x1_INI.s'
	include	'CNK_2x1_32.s'
	include	'CNK_2x1_16.s'





;+--------------+
;| DATA SECTION |
;+--------------+-------------------------------------------------------------+

	Library	graphics
	Library	dos


	; +-----------------------------------+

WB_DMACON	Dc.w 0


TD_VALS						; Text Data Values Follow...

HW_CPU	Dc.w 0					; CPU # (0,1,2,3,4)
	Dc.l 0					; Ptr -> TT_AGAx
HW_CHIP	Dc.l 0,0				; Chip RAM free (total)
HW_FAST	Dc.l 0,0				; Fast RAM free (total)
HW_VBR	Dc.l 0					; VBR Address (if any)

HW_AGA	Dc.w 0					; Boolean: 0 - FALSE, -1 - TRUE
HW_INT3	Dc.l 0					; Addr Of OS Vblank Int.



	; +--| GLOBALS |----------------------+

INT_Timer1	Dc.w	0			; Updated by VBL interrupt
INT_Timer2	Dc.w	0			; "
EXIT		Dc.w	0			; Subprogs set to nonzero if immediate quit

	CNOP	0,4

PAL_black	Dcb.l	256,$000000
PAL_white	Dcb.l	256,$FFFFFF
PAL_temp	Dcb.l	256,$000000

	; +-----------------------------------+


TT_DIAA	Dc.b $0A,$1B,'[4m',$1B,'[44m'
	Dc.b 'EXPeRIeNCe! System check V1.00'
	Dc.b $1B,'[0m',$1B,'[40m',$0A,$0A,$00

TT_DIAB	Dc.b 'CPU  : 680%d0',$0A
	Dc.b 'AGA  : %s',$0A
	Dc.b 'CHIP : %ld (%ld)',$0A
	Dc.b 'FAST : %ld (%ld)',$0A
	Dc.b 'VBR  : $%lx',$0A,$00

TT_DIAC	Dc.b $1B,'[4m'
	Dc.b '                              ',$1B,'[0m',$0A,$0A
	Dc.b 'Running production...',$0A,$0A,$00

TT_DIAD	Dc.b $0A,"** YOUR HARWARE'S NOT GOOD ENOUGH! **",$0A,$0A,$00


TT_AGAY	Dc.b 'Yes',$00
TT_AGAN	Dc.b 'No',$00

; +---------------------------------------------------------------------------+

	section 'mod',DATA_C
IntroMod	incbin	'TLA/mod.Eps_TLA-Intro'
		Ds.b	64			; Avoid PT_Replayer bug !! (SafetyBuffer)
MainMod		incbin	'TLA/mod.Eps_TLA-Main'
		Ds.b	64
EndMod		incbin	'TLA/mod.Eps_tla-end'
		Ds.b	64

; +---------------------------------------------------------------------------+

	section	'ChunkyBuffer',BSS
CHUNKY	Ds.b	1024*1024


; +----------------------+
; | Other Included Stuff |
; | (The Demo Bits)      |
; +----------------------+----------------------------------------------------+

	section	'Intro',CODE
	include	'TLA/Intro/intro.s'

	section	'Lens',CODE
	include	'TLA/lens/lensefx.s'

	section	'Pic',CODE
	include	'TLA/ExpPic/pic.s'

	section	'Tunnel',CODE
	include	'TLA/Tunnel/tunnel.s'

	section	'YinYang',CODE
	include	'TLA/YinYang/yin.s'

	section	'Sierprinski Triangle',CODE
	include	'TLA/S-Tri/tri.s'

	section	'EndCreds',CODE
	include	'TLA/EndCreds/cred.s'

; +------+
; | ENDE |
; +------+--------------------------------------------------------------------+
