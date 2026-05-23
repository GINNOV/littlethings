include "exec/types.h"
	include "exec/allocmem.h"

;------------------------------------------------------------------------------
; Alloc1024Chip - Allocates 1024 bytes of available chip memory.
;------------------------------------------------------------------------------
Alloc1024Chip:
	moveq	#0,d0		; Clear D0 - used for return codes/pointers
	moveq	#0,d1		; Clear D1
	moveq	#0,d2		; Clear D2
	moveq	#0,d3		; Clear D3
	moveq	#0,d4		; Clear D4
	moveq	#0,d5		; Clear D5
	moveq	#0,d6		; Clear D6
	moveq	#0,d7		; Clear D7

	; --- Set up arguments for AllocMem ---
	; Argument 1: Pointer to receive the allocated block address
	move.l	@ResultPtr,a6	; Put address of pointer variable in A6

	; Argument 2: Number of bytes to allocate
	move.l	#1024,d1	; 1024 bytes

	; Argument 3: Allocation flags
	move.l	#CLIENT_AVAILABLE,d2	; Request available client memory

	; --- Call the Exec library function ---
	jsr	ExecAllocMem

	; --- Check the return value ---
	; If the allocation failed, the pointer in @ResultPtr will be NULL.
	move.l	@ResultPtr,d0	; Move the resulting pointer into D0

	; Add error checking here if necessary (e.g., if d0 == #0)

	rts
;------------------------------------------------------------------------------