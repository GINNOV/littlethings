/*
 * rlib.c   v1.3
 * ~~~~~~
 *   Copyright (C) 1986,1987 by Manx Software Systems, Inc.
 *   Copyright (C) 1992 by Anthon Pang, Omni Communications Products.
 *
 *   Replacement library for:
 *     - stkchk.a68
 */

/*
 * stkchk()
 */
#ifdef __STKCHK_REPLACE

#if defined(__BETTER_STKCHK) && defined(__DYNASTACK_STKCHK)
#error "Conflicting stkchk() flags--{BETTER, DYNASTACK}"
#endif

#if defined(__BETTER_STKCHK) && defined(__DYNASTACK_STKCHK)
#error "Missing stkchk() flags--{BETTER, DYNASTACK}"
#endif

#asm
    cseg

    public  __stkbase
    public  __stkover
    public  _malloc
    public  __savsp

; constants defined externally...examples
;   STKCHK_MIN_STACK    SET 2768
;   STKCHK_STACK_SIZE   SET 8192
;   STKCHK_CONTEXT_SIZE SET  128

; __stkchk
;
;   - check if stack's magic cookie munged
;   - check if sufficent stack for stack frame
;   - allocate additional stack space if required (and enabled)
; 
; scratch registers: d0/a0-a1

    public  __stkchk
__stkchk:
    move.l  __stkbase,a0

    cmp.l   #'MANX',(a0)                ; check magic cookie
    bne.s   crunch                      ; branch if stack munged

    add.w   #%%STKCHK_MIN_STACK,a0      ; check stack space available
    neg.w   d0
    add.w   d0,a0
    cmp.l   a7,a0

#endasm

#ifdef __BETTER_STKCHK
#asm
    bge.s   crunch                      ; branch if stack would overflow
#endasm
#endif

#ifdef __DYNASTACK_STKCHK
#asm
    blt.s   captain                     ; branch if there's enough stack

    ext.l   d0                          ; alloc mem for size of stack frame...
    add.l   #%%STKCHK_STACK_SIZE,d0     ; ...and add a bit for future use
    move.l  d0,-(a7)
    jsr     _malloc#

    tst.l   d0                          ; check ptr
    beq.s   crunch                      ; branch if unable to alloc memory

    move.l  d0,a0                       ; d0 = a0 = new stkbase
    move.l  #'MANX',(a0)                ; store magic cookie
    move.l  (a7)+,a0                    ; pop size
    add.l   d0,a0                       ; get top of new stack

    move.l  __stkbase,-(a0)             ; save old stkbase on extension stack
    move.l  a7,-(a0)                    ; save the current stack pointer
    move.l  d0,__stkbase                ; store new stkbase

    move.l  __savsp,a1                  ; get top
    cmp.l   a1,a7
    bge.s   copyfullcontext             ; ignore the case where the extension
                                        ; stack is higher than the orig. stack

                                        ; at this point: a1 > a7
    sub.l   a7,a1                       ; get difference of top & current sp
                                        ; this represents amt of valid context
                                        ; plus 8

    cmp.l   #%%STKCHK_CONTEXT_SIZE+8,a1 ; compare difference with context size
    bge.s   copyfullcontext             ; if a1 greater, a full context is
                                        ; available

copypartialcontext:     ; but pad it out to 128 bytes
    sub.l   #%%STKCHK_CONTEXT_SIZE,a0
    add.l   a1,a0                       ; skip unavailable context

    move.l  a1,d0                       ; number of bytes to copy
                                        ; (this may not work out to
                                        ; an even number of longs)

    lea     8(a7,d0),a1

    lsr.l   #1,d0                       ; number of words to copy
    subq.l  #1,d0                       ; number of words to copy - 1

    bra.s   copynextword

copyfullcontext:
    moveq   #(%%STKCHK_CONTEXT_SIZE-2)/2,d0 ; copy 'small' context from current...
    lea     %%STKCHK_CONTEXT_SIZE+8(a7),a1  ; ...stack to extension stack

copynextword:
    move.w  -(a1),-(a0)
    dbra    d0,copynextword

finishedcopy:
    move.l  (a7),d0                     ; get return address (caller of stkchk)

    move.l  a0,a7                       ; swap stacks

    pea     __stkfree#                  ; this is the clean up routine; called
                                        ; when the calling 'proc' ends

    move.l  d0,-(a7)                    ; push addr of where to resume
#endasm
#endif

#asm
captain:
    rts

crunch:
    jmp     __stkover#
#endasm

#ifdef __DYNASTACK_STKCHK
#asm
    public  __stkfree
    public  _free

;
; __stkfree - free a dynamically allocated stack (as stack unwinds)
;   scratch registers: a0
;
__stkfree:
    lea     %%STKCHK_CONTEXT_SIZE(a7),a7    ; skip past context (note: no copyback)

    move.l  __stkbase,a0                ; temp = current stkbase
    move.l  4(a7),__stkbase             ; restore old stkbase

    move.l  (a7),a7                     ; unwind stack

    move.l  a0,-(a7)
    jsr     _free                       ; free empty stack
    addq.l  #8,a7                       ; clean up stack after malloc() & free()

    rts

#endasm
#endif
#endif /* __STKCHK_REPLACE */
