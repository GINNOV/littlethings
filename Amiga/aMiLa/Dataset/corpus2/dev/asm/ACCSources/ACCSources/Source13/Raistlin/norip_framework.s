          section Coldcap,code_c
          opt c-
          include 'sys:include/exec/exec_lib.i'

; get enough memory to load program into and set cold capture
          move.l   4,a6
          move.l   #PROGRAM_END-PROGRAM,d0 ; size of program 
          move.l   #1,d1                   ; use chip memory
          jsr      _LVOallocmem(a6)        ; get the memory
          beq      ERROR                   ; an error
          move.l   d0,a1                   ; get address of memory to be used
          move.l   a1,42(a6)               ; enter address into coldcapture
          move.w   #PROGRAM_END-PROGRAM,d0 ; size of program for loop
          lea      PROGRAM,a0              ; program address
LOOP1     move.b   (a0)+,(a1)+             ; load program into memory
          dbra     d0,LOOP1   

; recalculate coldcapture checksum

          move.l   #0,d1                  
          lea      34(a6),a0
          move.w   #22,d0
LOOP2     add.w    (a0)+,d1
          dbra     d0,LOOP2
          not.w    d1
          move.w   d1,82(a6)
ERROR     rts



PROGRAM:
          move.l   a5,resume      ; store register a5
          jsr      DISP           ; branch to program to execute
          move.l   resume,a5      ; put back contents of a5
          jmp      (a5)           ; continue reset routine


DISP    
	move.l	#Endaddress,d0	  ; End address of data to wipe
	move.l	#startaddress,a0  ; Start address of data to wipe
LOOPY	move.l	#0,(a0)+	  ; Wipe long word
	cmp.l	d0,a0		  ; Check to see if end of data has been reached
	blt	loopy		  ; If not go back to start of data block


RESET	cnop	0,4		  ; See hardware ref or other code
	move.l	4,a6
	lea	MagicResetCode(pc),a5
	jsr	-30(a6)

	cnop	0,4
MagicResetCode
	lea	2,a0
	RESET
	jmp	(a0)



PROGRAM_END:

resume dc.l 0

Startaddress
Endaddress
