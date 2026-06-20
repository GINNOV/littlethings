; mc0101.s				; wait for left mouse button	
; from disk1/brev01
; explanation on letter_01 p. 16
; from Mark Wrobel course letter 03, 04, 05, 06

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0101.s		; .s is optional also mc0101 works
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:
	move.w    #$4000,$DFF09A
	move.w    #$03A0,$DFF096
loop:
	move.w    $DFF006,$DFF180	; Set background color to VHPOSR
	btst      #6,$BFE001		; Check left mouse button 
	bne.s     loop              ; If not pressed go to loop
	move.w    #$83A0,$DFF096
	move.w    #$C000,$DFF09A
	rts

	end


SEKA>wo				; write objectfile
MODE>f
FILENAME>mc0101		; to execute from CLI

SEKA>w				; to write the sourcefile
FILENAME>mc0101

SEKA>r
FILENAME>mc0101.s
SEKA>a
OPTIONS>v			; line-by-line view of the program translation of the object code
No errors
SEKA>j		

SEKA>h				; statistics on memory

SEKA>q $C2847C		; part from memory of program

