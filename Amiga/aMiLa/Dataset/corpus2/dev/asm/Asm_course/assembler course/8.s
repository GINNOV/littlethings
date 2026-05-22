
; after 7 boring programs, it's time for action. I suppose you know
; enough about STACK, SUBROUTINES, ADRESSING METHODS, and LIBRARIES
; so it's time to make a small DEMO !!!!
; We will need a whole lot of 'hardware-numbers' these are addresses
; that have a special function. You already encountered the $bfe001
; which was used to check left mousebutton, $dff016 for right mouse
; and $dff180 and $dff182 for both background and textcolor.
; We will add some to this list in this program. Don't worry, I'll
; send (or maybe you already have it) a list with all these addreses
; and their function.

; The lesson that now follows is, as we said, about HARDWARE-RELATED
; stuff. It's therefore important that I tell you about this hardware
; Amiga uses some extra chips for things like gfx, sound, disk access
; etc...  One of these 'extra' chips is the Copper (in fact copper
; is only PART of a chip, but who cares)
; The copper is a very 'dumb' chip, it can only do 3 things, of which
; one thing is never used. (which makes it does only 2 things)
; The copper can 'WAIT' and 'MOVE'. 
;  WAITING: you can tell copper to wait for the 'beam' of the monitor
;	    to reach a certain position. For example:
;		'wait for line 10'
;  MOVING:  You can say: put this value in this address. 
;	    The addresses you can write to are limited to the 
;	    hardware registers, like for example the color-addresses
;	    $dff180 and $dff182. In fact all the addresses that are
;	    accessable with copper start with '$dff', and therefor
;	    these 3 digits are never written in a copper-program.
; THAT'S ALL !!
;
; Copper has it's own language. The Seka assembler translates 
; commands like 'JMP' in numbers, like $4ef9, but the instructions
; of the copper aren't supported, so we will just have to write
; the numbers ourselves. This list of numbers (the copper-program)
; is called a 'COPPERLIST'  Writing such a list isn't too hard, coz
; only 2 commands are used, as I told you.

; This examplesource will contain such a copperlist: have a look...
; You'll need almost everything you have learned 'till now, so be
; prepared. It won't be easy... If something is not clear, refer 
; back to somewhere where it was explained.  You should be familiar
; to the addressing methods etc by now.


top:	movem.l	d0-d7/a0-a6,-(a7)	; you guessed right...
					; save the registers !

	move.l	$4,a6		; the start of the execlib to A6
	move.l	#libname,a1	; the name of the library is here...
	jsr	-408(a6)	; openlibrary
	move.l	d0,gfxbase	; store the result in gfxbase

	; the next 4 lines cause our own copperlist to be 'executed'
	; from now on. The 2 lines with *** are very difficult to 
	; explain at this moment. I'll do it next time, when we will
	; discuss all the hardware registers.  Notice that the
	; values are here in binary notation. (%)

	move.w	#%0000001110100000,$dff096	; ***

	move.l	#copperlist,$dff080	; these 2 lines
	clr.w	$dff088			; effectively start our list

	move.w	#%1000001010000000,$dff096	; ***

	; now, wait for a mouseclick...

loop:	btst	#6,$bfe001
	bne.s	loop

	; something I didn't tell yet: at ofset +38 of the gfxlib is
	; the address of the current copperlist. After you've 
	; installed your own copperlist, you can find the old one
	; here, and put this one back to work, so you can return
	; properly. Let's do it:

	move.l	gfxbase,a6		; a6 = start of gfxlib !
	move.l	38(a6),$dff080		; turn the old copperlist
	clr.w	$dff088			; back on...

	move.w	#%1000001111100000,$dff096	; ***

	; and close the gfxlibrary:

	move.l	$4,a6			; we need exec again !
	move.l	gfxbase,a1
	jsr	-414(a6)

	movem.l	(a7)+,d0-d7/a0-a6
	rts


libname:	dc.b	"graphics.library",0
		even
gfxbase:	dc.l	0	; reserve a longword for the
				; start of the library

; here follows the copperlist. As I said, there are only 2 commands:
; The WAIT command looks as follows:
;
;	dc.w	$yyxx,$fffe    (or    dc.l  $yyxxfffe)
;
; yy is the number of the line you wish to wait for: from $0 to $ff
; xx is horizontal position. The 'resolution' is 8 pixels: you can
; only wait for pixel 1,8,16,...  xx must be an odd numer, ranging
; from $0f (left side) to ??? (I dunno exactly the right side)
; I almost always use 0f as horizontal position...
; The $fffe is the characteristic of the WAIT command. Example:
;
;	dc.l	$100ffffe
;
; waits for line $10 (=16), leftmost side...
;
; NOW the MOVE command:
;
;	dc.w	$aaaa,$bbbb     (or     dc.l   $aaaabbbb)
;
; aaaa is the hardware register you wanna move bbbb in. We already
; had the hardware registers $dff180 and $dff182, the colors...
; If we wanna move $0888 (grey) to these registers, the copperlist
; would look as follows:
;
;	dc.l	$01800888
;	dc.l	$01820888
;		 ^^^^
;	    registers
;		     ^^^^
;			values
;
; THE LAST LINE OF A COPPERLIST IS ALWAYS $FFFFFFFE, which is a wait
; instruction. 'Wait for FFFF', this is an impossible position, and
; it represents the end of the copperlist.
;
; HERE WE GO WITH A COMBINATION:

copperlist:
	dc.l	$200ffffe	; wait for line $20, horiz $0f
	dc.l	$01800000	; color background ($dff180) to $000
	dc.l	$400ffffe
	dc.l	$01800222
	dc.l	$600ffffe
	dc.l	$01800444
	dc.l	$800ffffe	; wait for line $80
	dc.l	$01800666	; background color to $0666
	dc.l	$a00ffffe
	dc.l	$01800888
	dc.l	$c00ffffe
	dc.l	$01800aaa
	dc.l	$fffffffe	; end of copperlist

