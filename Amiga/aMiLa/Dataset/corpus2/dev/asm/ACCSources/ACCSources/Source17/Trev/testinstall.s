		section	install,code_c
		opt	o+,c-,a+

Install:	move.l	4.w,a6
		lea	dosname(pc),a1
		moveq.l	#0,d0
		jsr	-408(a6)	  ;Open dos library
		move.l	d0,dosbase	  ;Save BaseAddress ptr
		beq	error

		move.l	4.w,a6
		moveq.l	#0,d5
		sub.l	a1,a1
		jsr	-294(a6)	  ;Find task
		move.l	d0,diskrep+$10	  ;Save base address ptr

		lea	diskrep(pc),a1
		jsr	-354(a6)	  ;Add Port

		lea	diskio(pc),a1
		move.l	#diskrep,14(a1)
		move.l	d5,d0
		moveq.l	#0,d1
		lea	trddevice(pc),a0
		jsr	-444(a6)	  ;Open trackdisk device

		lea	diskio(pc),a1
		move.w	#3,28(a1)	  ;Command (2 READ)  (3 WRITE)
		move.l	#bootdata,40(a1)  ;Bootdata ptr
		move.l	#1024,36(a1)	  ;Length (2 sectors 2*512)
		move.l	#0,44(a1)	  ;Offset (0 is from start of disk)
		move.l	4.w,a6
		jsr	-456(a6)

		lea	diskio(pc),a1
		move.w	#4,28(a1)	  ;Command (2 READ)  (3 WRITE)
		move.l	#bootdata,40(a1)  ;Bootdata ptr
		move.l	#1024,36(a1)	  ;Length (2 sectors 2*512)
		move.l	#0,44(a1)	  ;Offset (0 is from start of disk)
		move.l	4.w,a6
		jsr	-456(a6)

; turn off drive motor
		lea	diskio(pc),a1
		move.l	32(a1),d7
		move.w	#9,28(a1)
		move.l	#0,36(a1)
		move.l	4.w,a6
		jsr	-456(a6)

; close trackdisk device
		move.l	4.w,a6
		lea	diskio(pc),a1
		jsr	-450(a6)

; close disk reply port 
		lea	diskrep(pc),a1
		jsr	-360(a6)
; close dos
		move.l	dosbase(pc),a1
		move.l	4.w,a6
		jsr	-414(a6)

; no exit code,back to cli
error:		moveq.l	#0,d0		;no cli return code
		rts

DosName:	dc.b	'dos.library',0
		even
TrdDevice:	dc.b	'trackdisk.device',0
		even
DosBase:	dc.l	0
ConHandle:	dc.l	0
diskio:		dcb.l	20,0
diskrep:	dcb.l	8,0
Bootdata:	incbin	'df1:trev/boot1'

