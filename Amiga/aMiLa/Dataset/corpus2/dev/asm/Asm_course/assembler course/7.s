
; have you ever heared of 'libraries' ?  good ! Libraries contain
; many interesting subroutines that can take a lot of work out of
; our hands. Amiga has several libraries, one for graphics, one
; for disk, one for workbench...  The only problem is, that the
; routines are in most cases very SLOW. That is so because AMiga is
; a very complex computer, and these routines are written in a way
; that they keep everything in mind, for example it's possible that
; 2 programs are using disk, so the routines must count with this
; possibility. It must for example wait for one routine to be 
; finished before it can start itself, etc etc...
; In DEMOS, we ofcourse want to do much things at one time, and 
; preferably as FAST as posible, (try to put 200 bobs on a screen,
; you'll know what I mean)  So we will reduce the use of libraries
; to a MINIMUM !!
; For some purposes, libraries can be very interesting, though.
; That's why I'll tell you how to use them...

; Now, first good question: where are these libraries ?
; The computer knows where they are, but you can only find out by
; calling a routine called 'openlibrary', which is in a LIBRARY.
; Well, again, where is this library ??????
; (seems like we're getting nowhere this way)
;
; Here's the solution: the longword stored at address $4 (the 2nd
; longword of the memory) is the start of the 'EXEC LIBRARY'
; so with a 'MOVE.L $4,a6'   you can get the starting address of
; this library.  (not MOVE.L #$4,a6 !!!)
; In other words, you don't need the routine Openlibrary to open the
; execlibrary. EXECLIBRARY is therefor the 'most basical' library,
; with the most important routines.
; The other libraries must be opened using a function in the execlib
; The list with available routines is among the copies...

; All routines have a relative address: start location of library +
; offset. These offsets are for some unknown reason negative,
; (which means that the 'start location' is in fact the endlocation)
; Anyway, the function 'OPENLIBRARY' has offset -408, which means
; that if you move the starting location to A6 (with MOVE.L $4,A6)
; you must do a 'JSR -408(a6)' to execute the routine OPENLIBRARY.
; The communication between you and libraries is done through the 
; REGISTERS (D0-D7 & A0-A6)
; Each routine has it's own input- and output registers. In the 
; example of the openlibrary routine, you must tell the routine 
; which library you wanna open and he will tell you where it is. 
; If the libary you wanna open is called "graphics.library", the
; way to open it is :
;

start:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	$4,a6		; get the start of the execlib in a6

	clr.l	d0

	move.l	#libname,a1	; a1 is the register through which
				; you tell the routine which library
				; you wish to open.
				; Libname is a label at which we 
				; have stored the name. A1 now 
				; contains the address of this label

	jsr	-408(a6)	; execute the routine

	move.l	d0,gfxbase	; in D0 is the result of the routine:
				; the start of the library. If D0 is
				; 0, the library couldn't be opened.

*************************

; the library is now opened, in other words, we know where the start
; location of the GFXlibrary is. If we move this startinglocation to
; an addresregister, like A6, we can use the routines in the gfx-
; library, just like we called the 'openlibrary' routine. DOn't forget
; to tell the computer that you are about to use a routine in the GFX
; lib,so get this one's starting adress ready in a6:

;	move.l	gfxbase,a6
;	jsr	-xx(a6)

; At the end of the program, we have to close the opened libraries
; again (except the execlib) The 'CloseLibrary' routine is at offset
; -414 from the EXEClibrary.
; Now we must put the starting location of the previously opened
; library in A0 to tell the routine which library to close. In our 
; example, we have put this value in 'gfxbase':

	move.l	gfxbase,a1	; move CONTENTS of gfxbase to a1
				; this is the start of the library,
				; the one we saved earlier.

	move.l	$4,a6		; we use the EXEC lib !!!
	jsr	-414(a6)	; the closelib-routine

	movem.l	(a7)+,d0-d7/a0-a6

	rts			; exit this program

*************************


gfxbase:	dc.l	0	; we reserve 1 longword to store
				; the starting location of the 
				; graphicslibrary. after execution of
				; the source, type '@hgfxbase'. The first
				; 4 bytes that will be displayed, are
				; the contents of this longword.

libname:	dc.b	"graphics.library",0
		even
				; this is the name of the library.
				; The last byte is 0 as 'end-of-
				; string' marker.

