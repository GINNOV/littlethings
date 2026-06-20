/*
 * rlib.c   v1.3
 * ~~~~~~
 *   Copyright (C) 1986,1987 by Manx Software Systems, Inc.
 *   Copyright (C) 1992 by Anthon Pang, Omni Communications Products.
 *
 *   Replacement library for:
 *     - setjmp/longjmp.a68
 */

/*
 * setjmp()/longjmp()
 */
#ifdef __SETJMP_REPLACE

#if !defined(__ALLOCA_REPLACE) && !defined(__DYNASTACK_STKCHK)
#error "Missing alloca() and/or stkchk() for replacement setjmp()"
#endif

#asm
    cseg

    public  _setjmp
_setjmp
    move.l  (sp)+,d0            ; save return address
    move.l  (sp),a0             ; get ptr to env_buf
    movem.l d0-d7/a1-a7,(a0)    ; save PC and regs d1-d7/a1-a7
#endasm

#if defined(__ALLOCA_REPLACE) || defined(__DYNASTACK_STKCHK)
#asm
    lea     60(a0),a0
#endasm
#endif

#ifdef __ALLOCA_REPLACE
#asm
    move.l  __last_alloca_blk#,(a0)+
#endasm
#endif
#ifdef __DYNASTACK_STKCHK
#asm
    move.l  __stkbase#,(a0)+
#endasm
#endif

#asm
    move.l  d0,a0               ; put PC in a0
    move.l  #0,d0               ; return
    jmp     (a0)                ; continue


SETUPOLDSTACK   macro
    move.l  56(a0),a6           ; get a7 from jmp_buf
    move.l  (a0),-(a6)          ; push PC onto old stack
    move.l  52(a0),-(a6)        ; push a6 onto old stack
  endm

COPYTOOLDSTACK  macro
    sub.l   #68,sp              ; to avoid overwriting current stack frame

    move.l  a4,-(sp)            ; save a4 (for near data references)
    movem.l 4(a0),d1-d7/a1-a5   ; get regs from jmp_buf
    movem.l d0-d7/a1-a5,-(a6)   ; save regs on old stack
#endasm

#if defined(__ALLOCA_REPLACE) && defined(__DYNASTACK_STKCHK)
#asm
    move.l  64(a0),-(a6)        ; copy __stkbase to old stack
#endasm
#endif

#asm
    move.l  60(a0),-(a6)        ; copy __last_alloca_blk (or __stkbase)

    move.l  (sp)+,a4            ; restore a4
    move.l  a6,a7               ; swap stacks!
  endm

JMPTOOLDSTACK   macro
    movem.l (sp)+,d0-d7/a1-a6   ; restore regs
    move.l  (sp)+,a0            ; restore old PC
    jmp     (a0)
  endm


    xref    _free

    public  _longjmp
_longjmp
    addq.l  #4,sp
    move.l  (sp)+,a0
#endasm

#if defined(__ALLOCA_REPLACE) || defined(__DYNASTACK_STKCHK)
#asm
    SETUPOLDSTACK
#endasm
#endif

#asm
  IF INT32
    move.l  (sp),d0
  ELSE
    move.w  (sp),d0
  ENDC
    bne     9$
    move.l  #1,d0               ; force to 1 to avoid conflict with setjmp()
9$
#endasm

#if !defined(__ALLOCA_REPLACE) && !defined(__DYNASTACK_STKCHK)
#asm
    movem.l 4(a0),d1-d7/a1-a7   ; restore regs
    move.l  (a0),a0             ; get return address
    jmp (a0)
#endasm
#endif

#if defined(__ALLOCA_REPLACE) || defined(__DYNASTACK_STKCHK)
#asm
    COPYTOOLDSTACK
#endasm
#endif

#ifdef __ALLOCA_REPLACE
#asm
    move.l  (sp)+,a3                ; get saved __last_alloca_blk
    move.l  __last_alloca_blk,a2    ; get current pointer

    move.l  a3,__last_alloca_blk    ; restore __last_alloca_blk

next_alloca_blk:
    cmpa.l  a2,a3                   ; have we popped sub-chain yet?
    beq     last_alloca_blk

    move.l  a2,-(sp)                ; push pointer for free()ing
    move.l  4(a2),a2                ; get previous __last_alloca_blk

    jsr     _free                   ; free block
    addq.l  #4,sp                   ; clean up
    bra     next_alloca_blk

last_alloca_blk:
#endasm
#endif

#ifdef __DYNASTACK_STKCHK
#asm
    move.l  (sp)+,a3                ; get saved __stkbase
    move.l  __stkbase,a2            ; get current pointer
    move.l  a3,__stkbase            ; restore __stkbase

next_stkbase:
    cmpa.l  a2,a3                   ; have we popped sub-chain yet?
    beq     last_stkbase

    move.l  a2,-(sp)                ; push pointer for free() call
    add.l   -(a2),a2                ; add block size to get top of ext. stack
    move.l  (a2),a2                 ; get previous __stkbase
    jsr     _free                   ; free block
    addq.l  #4,sp                   ; clean up
    bra     next_stkbase

last_stkbase
#endasm
#endif

#if defined(__ALLOCA_REPLACE) || defined(__DYNASTACK_STKCHK)
#asm
    JMPTOOLDSTACK
#endasm
#endif

#endif /* __SETJMP_REPLACE */
