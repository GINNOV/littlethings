; mc1001.s				; memory allocation examples
; from disk1/brev10
; explanation on letter_10 p. 05
; from Mark Wrobel course letter 26
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1001.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j			
			
start:							; comments from Mark Wrobel					
	move.l	#100000,d0			; set d0 input to allochip to 100.000 bytes
	bsr	allocchip				; branch to subroutine allocchip

	cmp.l	#0,d0				; compare output from allocchip with 0
	beq	nomem					; if 0 goto nomem (could not allocate memory)

	lea.l	buffer,a0			; put address of buffer into a0
	move.l	d0,(a0)				; store d0 (pointer to allocated memory) into the address in a0
	
	move.l	#100000,d0			; set d0 input to freemem to 
	lea.l	buffer,a0			; move address of buffer into a0)
	move.l	(a0),a0				; put the pointer to the allocated memory into a0
	bsr	freemem					; branch to subroutine freemem to free the alocated memory
	rts							; return from subroutine

nomem:
	rts							; return from subroutine

buffer:
	dc.l	0					; buffer for holding a pointer to allocated memory


allocdef:						; subroutine for allocating memory - first fast then chip. ML: d0 = allocdef(d0).
	movem.l	d1-d7/a0-a6,-(a7)   ; push registers on the stack
	moveq	#1,d1               ; trick to quickly get $#10000
	swap	d1                  ; set d1 to MEMF_CLEAR initialize memory to all zeros
	move.l	$4,a6               ; fetch base pointer for exec.library
	jsr	-198(a6)				; call AllocMem. d0 = AllocMem(d0,d1)
	movem.l	(a7)+,d1-d7/a0-a6   ; pop registers from the stack
	rts                         ; return from subroutine

allocchip:						; subroutine for allocating chip memory. ML: d0 = allocchip(d0).
	movem.l	d1-d7/a0-a6,-(a7)   ; push registers on the stack
	move.l	#$10002,d1          ; set d1 to MEMF_CHIP
	move.l	$4,a6               ; fetch base pointer for exec.library
	jsr	-198(a6)				; call AllocMem. d0 = AllocMem(d0,d1)
	movem.l	(a7)+,d1-d7/a0-a6   ; pop registers from the stack
	rts                         ; return from subroutine

allocfast:						; subroutine for allocating fast memory. ML: d0 = allocfast(d0).
	movem.l	d1-d7/a0-a6,-(a7)   ; push registers on the stack
	move.l	#$10004,d1          ; set d1 to MEMF_FAST
	move.l	$4,a6               ; fetch base pointer for exec.library
	jsr	-198(a6)				; call AllocMem. d0 = AllocMem(d0,d1)
	movem.l	(a7)+,d1-d7/a0-a6   ; pop registers from the stack
	rts                         ; return from subroutine

freemem:						; subroutine for deallocating. ML: freemem(a1,d0).
	movem.l	d0-d7/a0-a6,-(a7)   ; push registers on the stack
	move.l	a0,a1               ; set a1 to the memory block to free
	move.l	$4,a6               ; fetch base pointer for exec.library
	jsr	-210(a6)				; call FreeMem. FreeMem(a1,d0)
	movem.l	(a7)+,d0-d7/a0-a6   ; pop registers from the stack
	rts                         ; return from subroutine

	end



