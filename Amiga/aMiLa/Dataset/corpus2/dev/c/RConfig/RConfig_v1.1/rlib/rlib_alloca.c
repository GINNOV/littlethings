/*
 * rlib.c   v1.3
 * ~~~~~~
 *   Copyright (C) 1992 by Anthon Pang, Omni Communications Products.
 *
 *   Replacement library for:
 *     - alloca.a68
 */

/*
 * alloca()
 */
#ifdef __ALLOCA_REPLACE

#if defined(__SAFE_ALLOCA) && defined(__RISKY_ALLOCA)
#error "Conflicting alloca() flags--{SAFE, RISKY}"
#endif

#if !defined(__SAFE_ALLOCA) && !defined(__RISKY_ALLOCA)
#error "Missing alloca() flag--{SAFE, RISKY}"
#endif

#ifdef __SETJMP_REPLACE
#asm
    dseg
    global  __last_alloca_blk,4     ; chain the alloca()'d blocks
#endasm
#endif

#asm
    xref    _malloc
    xref    _free

    cseg

; ``stub()'' - cleanup--free temp. block, and restore program counter
;
; scratch registers: <none>

    ds.w    0   ; word align this

blockstart set *
blockstart2:
rtsvector:
    dc.l    0   ; original return address
#endasm

#ifdef __SETJMP_REPLACE
#asm
prevblock:
    dc.l    0   ; ptr to previous allocated block
#endasm
#endif

#asm
codestart set *
codestart2:
#endasm

#ifdef __SETJMP_REPLACE
#asm
    move.l  prevblock(pc),__last_alloca_blk     ; unlink
#endasm
#endif

#asm
    move.l  rtsvector(pc),-(a7)
    movem.l d0/d1,-(a7)         ; save return values

    pea     blockstart2(pc)

    ; kludge, as ``far code'' doesn't prevent jmp->bra optimization
    dc.b    $4e,$f9     ; jmp <absolute>
    dc.l    freea

blockend set *

; constants
;   size of block to copy (in bytes)
blocksize   set blockend-blockstart
codesize    set blockend-codestart

; _alloca
;
; scratch registers: d0/a0-a1
;
#endasm

#ifdef __RISKY_ALLOCA
#asm
    public  _alloca

_alloca
    moveq   #blocksize,d0
    add.l   4(sp),d0        ; add the block size to allocate
#endasm
#else ; __SAFE_ALLOCA
#asm
    public  __alloca

__alloca
    moveq   #blocksize,d0
    add.l   8(sp),d0        ; add the block size to allocate
#endasm
#endif

#asm
    move.l  d0,-(sp)

    jsr     _malloc

    tst.l   d0
    beq.s   alloca_exit     ; branch if unable to alloc memory

    move.l  d0,a0           ; a0 = start of temp. block
#endasm

#ifdef __RISKY_ALLOCA
#asm
    move.l  4(a5),(a0)+     ; copy the return address above the stack frame
                            ;   to the temp. block
#endasm
#ifdef __SETJMP_REPLACE
#asm
    move.l  __last_alloca_blk,(a0)+     ; link
    move.l  d0,__last_alloca_blk        ; update
#endasm
#endif
#asm
    move.l  a0,4(a5)        ; replace return address with this address (a0)
                            ;   this is where the freea stub is copied
#endasm
#endif

#ifdef __SAFE_ALLOCA
#asm
; compensate for size of temp block on stack, and our proc's return address

    move.l  8(sp),a1        ; get pointer to return address
    move.l  (a1),(a0)+      ; copy return address to temp. block

#endasm
#ifdef __SETJMP_REPLACE
#asm
    move.l  __last_alloca_blk,(a0)+     ; link
    move.l  d0,__last_alloca_blk        ; update
#endasm
#endif

#asm
    move.l  a0,(a1)         ; replace return address with this address (a0)
                            ;   pointer to freea stub
#endasm
#endif

#asm
    lea     codestart2(pc),a1
    moveq   #(codesize/2)-1,d0      ; size in words

copy_block
    move.w  (a1)+,(a0)+
    dbra    d0,copy_block

    movem.l a0/a6,-(sp)
    move.l  $0004,a6
    cmpi.l  #37,$0014(a6)           ; lib_Version
    ble     1$

    jsr     -$027c(a6)              ; CacheClearU()     (* v37 *)

1$  movem.l (sp)+,d0/a6

alloca_exit
    addq.w  #4,sp           ; pop size off stack (which we pushed for malloc())
    rts

; freea
;
;   - we can't touch a7 and we can't have global vars...so we store
;     information in the temp.block
;   - a stub is required to access this information
;   - freea() is also needed since stub can't free the block while it's
;     running inside
;
; scratch registers:

freea
    jsr     _free       ; assumes pointer to block is on stack...
    addq.w  #4,a7
    movem.l (sp)+,d0/d1
    rts                 ; ...and the original return address is right above

#endasm
#endif /* __ALLOCA_REPLACE */
