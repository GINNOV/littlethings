; BootMenu by J Davis 09/1990
;
; version 1.0 - beta 05
;
; assembled using HiSoft DevPac v2
;
; a little program to allow choice of NTSC/PAL screen mode
; and expansion boards enabled/disabled at boot-time
;
; hangs around via both cool and coldcapture (see note 1)
;
; on each reboot puts up a menu allowing mode choice
;
; if there's no input in 10 secs, it defaults to the left most
; option ( PAL and boards ON respectively )
;
;
; note 1 : on machines with 1mb of chip, due to a slight oversight
;          in the 1.3/1.2 kickstart reset routine, EVERY reboot causes
;	   a TOTAL system rebuild. This of course makes it hard to make
;          our code hang around.
;
;  	   Hence, we add a coldcapture handler that fixes the bug,
;          then run our menu routine of coolcapture
;
;          Hence our coldcapt routine also acts as an IMPROVED setpatch R,
;          in that two reboots in a row KILLS setpatch r, wheras ours,
;          hangs around and hence protects RAD: properly. Therefore 
;          DO NOT use SetPatch r and BootMenu at the same time!
;
;
; note 2 : if do_addemem is set to 1, this will build a version
;          that does an addmem of memory on the ronin 020 board
;          on the fly, due to the ronin mem not being dma-able we
;          have to set a low pri on the mem
; 

		; turn on debug info and turn off optimising
		OPT	D+
		OPT 	O-

;======================

do_addmem	equ	0	; flag for whether we do an addmem
				; for hurricane board as well

;======================


	IFNE	do_addmem=1
		FORMAT 0-,1-,2-
		LIST
		; building PBMC_BootMenu
		NOLIST
		output	PBMC_BootMenu
	ELSEIF
		FORMAT 0-,1-,2-
		LIST
		; building normal BootMenu
		NOLIST
		output	bootmenu
	ENDC	

chip_addr	equ	$40000	; where we swap our chip data to/from

; process structure offsets

pr_cli		equ	$0Ac	; process cli flag offset
pr_msgport	equ	$05c	; process msgport offset

; execbase structure offsets

coldcapture	equ	$02a
coolcapture	equ	$02e
sysstklower	equ	$03a
		
; misc library functions

forbid		equ	-$084	; offsets for various exec and int calls
getmsg		equ	-$174	; saves long includes and compile times
replymsg	equ	-$17a
waitport	equ	-$180
findtask	equ	-$126
autoreq		equ	-$15c
openlib		equ	-$228
closelib	equ	-$19e

output		equ	-$003c		
write		equ	-$0030

openlibrary	equ	-$0228
closelibrary	equ	-$019e

addmemlist 	equ	-618	

; hardware equates 

potgor		equ	$dff016
potgo		equ	$dff034

intreq		equ	$dff09c
intreqr		equ	$dff01e

ddfstart	equ	$dff092
ddfstop		equ	$dff094

diwstart	equ	$dff08e
diwstop		equ	$dff090

bpl1mod		equ	$dff108

bplcon1		equ	$dff102
bplcon0		equ	$dff100

r_color0	equ	$0180
r_color1	equ	$0182

r_bpl1pth	equ	$00e0
r_bpl1ptl	equ	$00e2

cop1lch		equ	$dff080
cop1lcl		equ	$dff082
copjmp1		equ	$dff088

dmacon		equ	$dff096

agnusdetect	equ	$dff004

;==============================================================

startup:	; startup code - determine if run from wb/cli etc
	
		move.l	$4,a6
		move.l	#0,a1
		jsr	findtask(a6)		; find ourselves

		move.l	d0,a4			; save our process pointer

		move.l	pr_cli(a4),d0
		bne	fromdos			; was a DOS startup

		; was started from WB

fromwb:		lea	pr_msgport(a4),a0
		jsr	waitport(a6)		; wait for startup msg
		lea	pr_msgport(a4),a0
		jsr	getmsg(a6)		; get the wb msg

		move.l	d0,wbmsg		; save pointer to our startup msg
		move.l	#1,wb			; flag we started from wb

		lea	intuiname,a1
		move.l	#0,d0
		move.l	$4,a6
		jsr	openlib(a6) 		; open intuition lib

		move.l	d0,a6			; save ibase
		
		move.l	#0,a0			; window to display in
		move.l	#bodyitext1,a1		; body text
		move.l	#gaditext,a2 		; postive text
		move.l	#gaditext,a3  		; negative text
		move.l	#0,d0			; pflags
		move.l	#0,d1			; nflags
		move.l	#370,d2			; width
		move.l	#80,d3			; height
		jsr	autoreq(a6)		; request user confirmation

		move.l	a6,a1			; close intuition lib
		move.l	$4,a6
		jsr	closelib(A6)

		bsr	install			; install ourselves

		bra	exit

fromdos:	; was run from dos - output message to stdout

		move.l	$4,a6
		lea	dosname,a1
		move.l	#$0,d0
		jsr	openlibrary(a6)	 	; open dos library
		
		move.l	d0,a6		 	; save dos base
		
		jsr	output(a6)	 	; get handle on stdout
		
		move.l	d0,d1		 	; get file handle
		move.l	#msgtxt,d2
		move.l	#etext-msgtxt,d3
		jsr	write(a6)	 	; put up a message saying we're installed
		
		move.l	$4,a6
		move.l	a6,a1
		jsr	closelibrary(a6) 	; close dos

		bsr	install		

exit:		move.l	wb,d0
		cmp.l	#0,d0			; was this a CLI invocation
		beq	exit_dos		; DOS - just exit 

		; workbench exit

		move.l	$4,a6
		jsr	forbid(a6)		; lock out everyone else

		move.l	wbmsg,a1
		jsr	replymsg(a6)		; reply to Wbstartup msg

exit_dos:	move.l	#0,d0			; return with return code 0
		rts			

;=================================================
		even
wb:		dc.l	0			; run mode flag 0=dos process 1=wbprocess
wbmsg:		dc.l	0			; where we save our workbench msg

		even
intuiname:	dc.b	"intuition.library",0
		
		even
dosname:	dc.b	"dos.library",0

		; message we output for cli startup
	IFNE	do_addmem=1
msgtxt:		dc.b	27,"[33mBootMenu PBMC",27,"[0m, by J Davis 09/1990",10
	ELSEIF
msgtxt:		dc.b	27,"[33mBootMenu v1.0",27,"[0m, by J Davis 09/1990",10
	ENDC
		dc.b	"installed ok - menu will become active at next reboot",10,0
etext:		dc.b	0

		even

		; stuff for our autorequester for wb usage
bodyitext1:	dc.b	2	   	; front pen
		dc.b	1	   	; back pen
		dc.b	0	   	; draw mode
		dc.w	40	   	; leftedge
		dc.w	6	   	; topedge
		dc.l	0	   	; textattr = default
		dc.l	bodytext1  	; actual text
		dc.l	bodyitext2	 	; next

bodyitext2:	dc.b	3	   	; front pen
		dc.b	0	   	; back pen
		dc.b	0	   	; draw mode
		dc.w	120	   	; leftedge
		dc.w	26	   	; topedge
		dc.l	0	   	; textattr = default
		dc.l	bodytext2  	; actual text
		dc.l 	bodyitext3	; next

bodyitext3:	dc.b	3	   	; front pen
		dc.b	0	   	; back pen
		dc.b	0	   	; draw mode
		dc.w	20	   	; leftedge
		dc.w	36	   	; topedge
		dc.l	0	   	; textattr = default
		dc.l	bodytext3  	; actual text
		dc.l	0	 	; next

gaditext:	dc.b	0		; front pen
		dc.b	0		; back pen
		dc.b	0		; draw mode
		dc.w	4		; leftedge
		dc.w	4		; topedge
		dc.l	0		; textattr = default
		dc.l	gadtext		; actual text
		dc.l	0		; next
		
		; actual text for our requester

	IFNE	do_addmem=1
bodytext1:	dc.b	"BootMenu PBMC, by J Davis 09/1990",0
        ELSEIF
bodytext1:	dc.b	"BootMenu v1.0, by J Davis 09/1990",0
	ENDC
bodytext2:	dc.b	"installed ok",0
bodytext3:	dc.b	"menu will become active at next reboot",0
gadtext:	dc.b	"Ok",0

;=====================================================

		even

install:	; this routine does the actual cold/coolcapture
		; setting 

		; works out where we're going to install to
		; then copies handler code there and hooks vectors
		
		move.l	$4,a6
		move.l	sysstklower(A6),a0			; get pointer to base of sys-stack
		move.l	a0,codetarget				; save pointer to address

		move.l	a0,a1
		add.l	#coldcapt-captstart,a1			; point to coldcapt address
		move.l	a1,coldcaptaddr				; save address

		move.l	a0,a1
		add  	#coolcapt-captstart,a1			; point to coolcapt addres
		move.l	a1,coolcaptaddr				; save address

		; now stuff our code away on the bottom of the system stack

		lea	captstart(pc),a1			; code to copy
		move.l	codetarget,a2	 			; where to copy to
		move.l	#endcapt-captstart,d0 			; amount to copy
mloop:		move.b	(a1)+,(a2)+
		dbf	d0,mloop

		; now install a vector to the copied code in execbase.coldcapture
		
		move.l	$4,a6		   			; get execbase
		move.l	coldcaptaddr,a0				; address of our coldcap routine
		move.l	a0,coldcapture(a6) 			; set coldcapture

		move.l	coolcaptaddr,a0				; address of our coolcap routine
		move.l	a0,coolcapture(a6)			; set coolcapture to our code

		; finally, recalc the execbase checksum
		
		lea	34(a6),a0			 	; start of checksummed area in execbase
		move.w	#$16,d0		 			; number of checksummed words
		move.w	#$0,d1		 			; clear counter
	
sum:		add.w	(A0)+,d1	 			; sum execbase and update checksum
		dbf	d0,sum
	
		not.w	d1
		move.w	d1,82(a6)	 			; set new execbase checksum

		; all done
		rts

		even
		
codetarget:	dc.l	0
coolcaptaddr:	dc.l	0
coldcaptaddr:	dc.l	0
		
;==============================================================
;
; our capture routines
;
; since this is going to stick around, we need to copy
; it somewhere safe - like the SysStack area
;
; since we can't guarantee sys-stack will be in chip, we 
; swap our bitplane data and copper list to chip mem on the fly
; and then swap it back out ( in case rad: was using the bit where
; we put our screen ! )

		even

captstart:	

coldcapt:	; this is our coldcapture routine - basically
		; fixes the rebuild problem that SETPATCH R tries
		; ( but fails ) to

		; CAUTION!! This code is _specific to kickstart 1.x
		; DO NOT USE WITH KickStart 2.x!!!

		; important - reinsert our code into execbase, as coldcapt
		; is cleared before it's called!! this is what setpatch r
		; fails to do (and hence why it's not reliable)!

		lea	coldcapt(pc),a0				; on entry A6=execbase
		move.l	a0,coldcapture(a6)			; reset our vector in execbase - don't need to resum

		; the following is a kludge to get around exec 34.x
		; insisting on doing a system rebuild if >512k chip
		; it is directly based on the rom code in ks1.2/1.3
		
		bchg	#1,$bfe001				; toggle led on
		
		move.l	$fc0010,d0				; get ks ver no.
		cmp.l	$14(a6),d0				; compare with execbase ver
		bne.s	rebuild_all

		; the following is the bit that's wrong with ks1.x
		; now fixed to work with 1mb chipmem
		
		move.l	$3e(a6),a3				; get maxchipmem
		cmpa.l	#$100000,a3				; more than 1mb chip ?
		bhi.s	rebuild_all
		
		add.l	#$1e,a5					; point A5 past the (incorrect) code we skip
		jmp	(A5)					; carry on with rest of boot

rebuild_all:	jmp	$fc01ce					; jump to rom rebuild code

;====================================================================

		even

coolcapt:	; our coolcapture routine - actually does the menus etc

		movem.l	d0-d7/a0-a6,-(a7)			; save everything

		bsr	swapmem					; first, copy our bitplane data and copper list to chip mem

		move.w	#$ffff,potgo 				; set for button inputs on mouse
		
		; finished setting up - ask whether to turn boards off
		
		move.l	#chip_addr+board_mode-chipdata_start,a1	; address where bitplane data is copied to
		bsr 	doscreen				; put up screen and wait for choice

		btst	#0,d0
		beq.s	next					; left mouse=leave on so skip

		; user requested expansion board disable - do it

		moveq.l	#$7,d1					; max no boards we fix = 8 

bchk:		move.w	$e80008,d0				; get flag byte from board
		not.w	d0					; invert
		btst.l	#14,d0					; see if board supports shut_up
		beq.s	shut_up					; bit=0 means board shuts up ok

		; board doesn't support shut up, so 
		; config board to $200000 (only gap big enough for 8mb boards)
		
		move.w	#$0000,$e8004a  			; fake board out to $200000
		move.w	#$2000,$e80048  
		
		bra.s	nboard					; carry on

shut_up:	move.b	#$ff,$e8004c    			; tell the board to shut up

nboard:		dbf	d1,bchk					; loop thru all boards

		; now query for screen mode
next:		; see if this machine has the 1mb Agnus

		move.w	agnusdetect,d0
		and.w	#$2000,d0
		beq.s	no_8372					; doesn't have obese agnus - skip screen mode choice

		; has the 1mb agnus, offer screen mode choice

		move.l	#chip_addr+scr_mode-chipdata_start,a1	; address where bitplane data is copied to
		bsr	doscreen				; put up screen and wait for choice

		btst	#0,d0					; left mouse = PAL
		beq.s	go_pal

		move.w	#$0000,$dff1dc				; set NTSC mode on agnus
		bra.s	no_8372

go_pal:		move.w	#$0020,$dff1dc				; set PAL mode on agnus
		
no_8372:	bsr	swapmem					; finally restore chipmem	

	IFNE do_addmem=1 
	
		FORMAT	0-,1-,2-
		LIST
		; adding special addmem code!
		NOLIST
		
		; Addmem the 32 bit mem on the Ronin 020 board
		; into the system
		;
		; we add 1mb, starting at $600000

		move.l	$4,a6		; get execbase
		move.l	#$100000,d0	; amount of mem we're adding ( 1mb )
		move.l	#$5,d1		; attributes ( memf_fast | memf_public )
		move.l	#-20,d2		; pri of mem must be low so as to force HD to use chip!!!
		move.l	#$600000,a0	; where the mem starts ( 6 mb )
		move.l	#0,a1		; pointer to a name for this block 
					; don't want one so pass NULL
		jsr	addmemlist(a6)	; do the deed !!!			

		; you need to be careful after this to NOT run the 
		; ronin addmem prog - as otherwise you will get the 
		; same block of mem added TWICE ( can you say 'guru' ? :-)
	ENDC

		movem.l	(A7)+,d0-d7/a0-a6			; get back all regs
		rts


; ===============================
; this routine swaps chipdata into/out of a block of chipmem

swapmem:	lea	chipdata_start(pc),a0			; where to copy from
		move.l	#chip_addr,a1				; where we copy to
		move.l	#chipdata_end-chipdata_start,d0		; amount to copy

cm_loop:	move.b	(a0),d1					; we exchange data in and out
		move.b	(a1),d2			
		move.b	d2,(a0)+
		move.b	d1,(a1)+
		dbf	d0,cm_loop
		
		rts


;====================================
; this subroutine puts up the screen pointed to by a1
; and return d0=0 for left mouse and d0<>0 for right mouse
; also trashes d1

doscreen:	; setup screen hardware

		move.w	#$1200,bplcon0				; set for lores, 1 plane
		move.w	#$0000,bplcon1
		
		move.w	#$0000,bpl1mod				; modulo = 0
		
		move.w	#$0038,ddfstart				; data fetch start
		move.w	#$00d0,ddfstop 				; data fetch stop
		
		move.w	#$7081,diwstart				; display window start
		move.w	#$89b0,diwstop				; display window stop
		
		move.l	a1,d0					; setup up copper list bitplane pointers
		move.w	d0,chip_addr+screen_l-chipdata_start	; point cop1l load addr to right place
		swap	d0
		move.w	d0,chip_addr+screen_h-chipdata_start	; point cop1h load addr to right place

		move.l	#chip_addr+ourcoplist-chipdata_start,cop1lch ; point copper at our copper list
		
		move.w	copjmp1,d0				; force copper to our list
		
		move.w	#%1000000110000000,dmacon		; enable bitplane and copper dma
		
		move.w	#10*50,d1				; 10 secs worth of vblanks before timeout

waittof:	move.w	intreqr,d0
		btst	#5,d0					; vblank int ?
		beq.s	waittof					; wait until tof true
	
		move.w	#$0020,intreq				; clear int
		
		btst	#6,$bfe001				; left button down ?
		beq.s	lmb
		
		btst	#10,potgor				; right button down
		beq.s	rmb

		subq.w	#$1,d1					; dec frame counter
		cmp.w	#$0,d1					; time up ?
		beq.s	lmb					; default to left mouse button
		
		bra.s	waittof		
		
lmb:		moveq	#0,d0
		bra.s	_exit_1
			
rmb:		moveq	#1,d0

_exit_1:	; debounce buttons to avoid 'fallthru' - wait for both buttons up

		btst	#10,potgor
		beq	_exit_1					; wait for user to let go of rmb
		
		btst	#6,$bfe001
		beq	_exit_1					; wait for user to let go of rmb

		; now delay 15 vblanks to allow buttons to settle
		
		move.w	#15,d2
		
_1waittof:	move.w	intreqr,d1
		btst	#5,d1					; vblank int ?
		beq.s	_1waittof				; wait until tof true
	
		move.w	#$0020,intreq				; clear int

		subq.w	#1,d2					; dec delay counter
		cmp.w	#$0,d2
		bne	_1waittof
		
		move.w	#%0000000110000000,dmacon		; disable bitplane and copper dma

		rts

;=========================================

		; message for people running VMK etc 

		dc.b	"  BootMenu v1.0 J Davis - this is NOT a virus!!!  "
		
;=========================================

		even

chipdata_start:
		
ourcoplist:	; the following copperlist runs our screen

		dc.w	r_bpl1pth
screen_h	dc.w	0		; set high bitplane address

		dc.w	r_bpl1ptl
screen_l	dc.w	0		; set low bitplane address

		dc.w	r_color0
		dc.w	$0026		; set background 

		dc.w	$6f01,$ff00	; wait for top of our display
		
		dc.w	r_color1
		dc.w	$0fff		; set fg 

		dc.w	$7101,$ff00	; wait til after top line

		dc.w	r_color1
		dc.w	$0f08		; set fg 

		dc.w	$7c01,$ff00	; wait for next bit of text

		dc.w	r_color1
		dc.w	$006c		; set fg

		dc.w	$8801,$ff00	; wait for bottom line

		dc.w	r_color1
		dc.w	$0fff		; set fg

		dc.w	$ffff,$fffe	; wait for next TOF
		
		; the following is the bit map for out first screen

board_mode:	dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$0000038C,$60000000,$0000000F,$E0000000,$00018000,$000FC000,$0000E000,$00000000,$00000000,$00000000
		dc.l	$000006CE,$60000000,$00000006,$60000000,$00000000,$00066000,$00006000,$00000000,$71FDFC00,$00000000
		dc.l	$0007EC6F,$67E00000,$00000006,$063DC3C7,$C3E383C7,$C00663C3,$CEC363E0,$00000000,$D8CCCC00,$00000000
		dc.l	$07E00C6D,$E007E000,$00000007,$83666066,$66018666,$6007C660,$6766E600,$000000FD,$8CC0C0FC,$00000000
		dc.l	$00000C6C,$E0000000,$00000006,$01C661E6,$63C18666,$60066661,$E66663C0,$0000FC01,$8CF0F000,$FC000000
		dc.l	$0007E6CC,$67E00000,$00000006,$6367C666,$60618666,$60066666,$66066060,$00000001,$8CC0C000,$00000000
		dc.l	$0000038C,$60000000,$0000000F,$E63603B6,$67C3C3C6,$600FC3C3,$BF03B7C0,$000000FC,$D8C0C0FC,$00000000
		dc.l	$00000000,$00000000,$00000000,$000F0000,$00000000,$00000000,$00000000,$00000000,$71E1E000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$000007E0,$00004000,$00000006,$18C001E0,$07E00000,$7007C000,$00C00001,$E1E018C1,$E1E1E000,$00000000
		dc.l	$00000330,$0000C000,$00000006,$19C00330,$03300000,$30036000,$00000003,$333031C3,$33333000,$00000000
		dc.l	$00000331,$E1E1F331,$E3E33003,$30C00370,$03333000,$300331E3,$31C1F003,$733060C3,$33337000,$00000000
		dc.l	$000003E3,$3330C3BB,$33333003,$30C003F0,$03E33000,$30033033,$30C30003,$F1F0C0C1,$F1F3F000,$00000000
		dc.l	$00000333,$3330C35B,$F3333001,$E0C003B0,$03333003,$300330F3,$30C1E003,$B03180C0,$3033B000,$00000000
		dc.l	$00000333,$3330D31B,$03333001,$E0C0C330,$0331E003,$30036331,$E0C03003,$306300C0,$60633000,$00000000
		dc.l	$000007E1,$E1E06319,$E331D800,$C3F0C1E0,$07E0C001,$E007C1D8,$C1E3E001,$E1C603F1,$C1C1E000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00038000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff
		
		; the following is the bitmap for our second screen
		
scr_mode:	dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$000007E0,$C7800000,$00000000,$00001E00,$00000000,$00410007,$00000000,$0000018C,$FC787800,$00000000
		dc.l	$00000331,$E3000000,$00000000,$00003300,$00000000,$00630003,$00000000,$000001CC,$B4CCCC00,$00000000
		dc.l	$0003F331,$E303F000,$00000000,$0000381E,$761E1E3E,$00771E1B,$1E000000,$0000FDEC,$30E180FC,$00000000
		dc.l	$03F003E3,$330003F0,$00000000,$00001C33,$3B333333,$007F3337,$33000000,$00FC01BC,$30718000,$FC000000
		dc.l	$00000303,$F3100000,$00000000,$00000730,$333F3F33,$006B3333,$3F000000,$0000019C,$301D8000,$00000000
		dc.l	$0003F306,$1B33F000,$00000000,$00003333,$30303033,$00633333,$30000000,$0000FD8C,$30CCCCFC,$00000000
		dc.l	$00000786,$1FF00000,$00000000,$00001E1E,$781E1E33,$00631E1D,$9E000000,$0000018C,$78787800,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$000007E0,$00004000,$00000006,$18C001E0,$07E00000,$7007C000,$00C00001,$E1E018C1,$E1E1E000,$00000000
		dc.l	$00000330,$0000C000,$00000006,$19C00330,$03300000,$30036000,$00000003,$333031C3,$33333000,$00000000
		dc.l	$00000331,$E1E1F331,$E3E33003,$30C00370,$03333000,$300331E3,$31C1F003,$733060C3,$33337000,$00000000
		dc.l	$000003E3,$3330C3BB,$33333003,$30C003F0,$03E33000,$30033033,$30C30003,$F1F0C0C1,$F1F3F000,$00000000
		dc.l	$00000333,$3330C35B,$F3333001,$E0C003B0,$03333003,$300330F3,$30C1E003,$B03180C0,$3033B000,$00000000
		dc.l	$00000333,$3330D31B,$03333001,$E0C0C330,$0331E003,$30036331,$E0C03003,$306300C0,$60633000,$00000000
		dc.l	$000007E1,$E1E06319,$E331D800,$C3F0C1E0,$07E0C001,$E007C1D8,$C1E3E001,$E1C603F1,$C1C1E000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00038000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff

chipdata_end:

endcapt:	

		END

