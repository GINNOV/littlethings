; AddKickMem
; Copyright 1987 by Glen McDiarmid
; Use and distribute freely

; I may be contacted at:-
; Glen McDiarmid
; 28 Marginson Street,
; Ipswich, Queensland
; Australia  4305

; (07) 812-2963


_LVOForbid    equ   -$84
_LVOAddHead   equ   -$f0
_LVOPermit    equ   -$8a
_LVOAllocMem  equ   -$c6
startaddress  set   $f80000     ;Place new start address here
endaddress    set   $fbffff     ;Place new end address here

startaddress  set   startaddress&$fffffff8
endaddress    set   endaddress&$fffffff8
length        set   endaddress-startaddress-$20

    movea.l   4,A6
    movea.l   #startaddress,a2
    clr.l     $20(a2)
    move.l    #length,$24(a2)
    move.b    #$0A,$8(a2)
    move.w    #5,$e(a2)
    move.l    #startaddress,$14(a2)
    move.l    #endaddress,$18(a2)
    move.l    #startaddress+$20,$10(a2)
    move.l    #length,$1c(a2)
    jsr       _LVOForbid(a6)
    lea.l     $142(a6),a0
    move.l    #startaddress,a1
    jsr       _LVOAddHead(a6)
    jsr       _LVOPermit(a6)
    eor.l     d0,d0
    rts
; Sorry about the lack of comments - I prefer informative labels