
 * A little routine that uses the keyboard.device to create a matrix of all
 * keys that are currently up (not pressed) and currently down (pressed).
 * The matrix is 16 bytes. To find out if a key is currently up or down
 * you devide its value by 8 and then check its remainder bit. For example.
 * With F2 you do 81 (F2's decimal value) devided by 8 = 10. You now look at
 * byte 11 (0 to 10 = 11th byte) and check if bit 1 is set (1 = remainder
 * value of F2). If it is set then F2 is being pressed. To check T you would
 * do 20 (T's decimal value) devided 8 = 2. Look at byte 3 (0 to 2 = 3rd
 * byte) and check if bit 4 is set (4 = remainder value). If it is set....
 * You can check as many keys as you like as they are in a matrix (buffer).

	INCDIR	WORK:Include/

	INCLUDE exec/exec_lib.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	devices/keyboard.i

	INCLUDE	misc/easystart.i

	moveq	#37,d0
	lea	int_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit_quit

	moveq	#37,d0
	lea	graf_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#37,d0
	lea	dos_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase
	beq	exit_closegfx

	CALLEXEC	CreateMsgPort
	move.l	d0,keybport
	beq.s	exit_closedos
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	CALLEXEC	CreateIORequest
	move.l	d0,keybio
	beq.s	exit_keybport
	move.l	d0,a1
	lea	ip_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	CALLEXEC	OpenDevice
	tst.l	d0
	bne.s	exit_keybio

	movea.l	keybio(pc),a1
	move.w	#KBD_READMATRIX,IO_COMMAND(a1)
	move.l	#keybbuf,IO_DATA(a1)
	move.l	#16,IO_LENGTH(a1)
	CALLEXEC	DoIO

	movea.l	keybio(pc),a1
	move.l	IO_DATA(a1),a0		; address of your `matrix' buffer
	move.l	IO_ACTUAL(a1),d0	; #bytes put into `matrix' buffer


exit_closedevice
	movea.l	keybio(pc),a1
	CALLEXEC	CloseDevice

exit_keybio
	movea.l	keybio(pc),a0
	CALLEXEC	DeleteIORequest

exit_keybport
	movea.l	keybport(pc),a0
	CALLEXEC	DeleteMsgPort

exit_message

exit_closedos
	movea.l	_DOSBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closegfx
	movea.l	_GfxBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closeint
	movea.l	_IntuitionBase(pc),a1
	CALLEXEC	CloseLibrary

exit_quit
	moveq	#0,d0
	rts


 * Include Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
keybport	dc.l	0
keybio		dc.l	0


 * String Variables.
 
int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0
ip_name		dc.b	'keyboard.device',0


 * Buffer Variables.

keybbuf		dcb.b	16,0