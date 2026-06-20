; Stack
; Copyright 1987 Glen McDiarmid
; Use and distribute freely

; I may be contacted at:-
; Glen McDiarmid
; 28 Marginson Street,
; Ipswich, Queensland
; Australia  4305

; (07) 812-2963

_LVOAlert              equ     -$6c
_LVOAllocMem           equ     -$c6
_LVOFreeMem            equ     -$d2
_LVOFindTask           equ     -$126
_LVOCloseLibrary       equ     -$19e
_LVOOpenLibrary        equ     -$228



_LVOWrite              equ     -$30
_LVOOutput             equ     -$3c

cli_DefaultStack       equ     $34
pr_CLI                 equ     $AC
execbase               equr    a2
dosbase                equr    d6
outputhandle           equr    a3

start:

               movea.l a0,a5   
               move.l  d0,d5   
               movea.l $4,execbase
               movea.l execbase,a6
               lea.l   dosname(pc),a1  
               eor.l   d0,d0   
               jsr     _LVOOpenLibrary(a6) 
               move.l  d0,dosbase  
               movea.l d0,a6
               jsr     _LVOOutput(a6)  
               move.l  d0,outputhandle
               move.l  execbase,a6
               suba.l  a1,a1 
               jsr     _LVOFindTask(a6)
               movea.l d0,a0
               movea.l pr_CLI(a0),a4 
               adda.l  a4,a4 
               adda.l  a4,a4 
               move.l  cli_DefaultStack(a4),d7 
               asl.l   #$2,d7   
               subi.w  #$2,d5   
               bge     isparms
               move.l  #message,d2
               move.l  #messagelength,d3
               bsr.s   print   

               eor.l   d3,d3
               clr.l   -(a7)   
               move.l  #$1,d0   
loop7:         move.l  d0,-(a7)  
               asl.l   #1,d0   
               move.l  d0,d1   
               asl.l   #$2,d0   
               add.l   d1,d0   
               bcc.s   loop7   
loop8:         move.l  (a7)+,d0  
               beq.s   divdone   
               move.b  #$2f,d1   
loop9:         addi.b  #$1,d1   
               sub.l   d0,d7
               bcc.s   loop9
               add.l   d0,d7
               cmpi.b  #$30,d1
               bne.s   notzero
               tst.b   d3
               beq.s   loop8
notzero        move.b d1,-(a7)  
               move.l  a7,d2   
               bsr.s   print2
               tst.w   (a7)+   
               bra.s   loop8   
divdone:       move.l  #finishmessage,d2 
               move.l  #finishmessagelength,d3
               bsr.s   print
exit:          move.l  dosbase,a1
               jsr     _LVOCloseLibrary(a6)
               eor.l   d0,d0   
               rts      
badparms:      move.l  #errmessage,d2
               move.l  #errmessagelength,d3
               bsr.s   print   
skip:          move.l  10,d0   
errorexit:     rts

print2:        moveq.l #$1,d3   
print:         move.l  outputhandle,d1
               move.l  dosbase,a6
               jsr     _LVOWrite(a6)  
               move.l  execbase,a6
               rts
jtoosmall:     lea.l   toosmall(pc),a5 
               bra     sizejoin
jtoobig:       lea.l   toobig(pc),a5
sizejoin:      move.l  #badsize,d2  
               move.l  #badsizelength,d3
               bsr.s   print
               move.l  a5,d2
               move.l  #$6,d3
               bsr.s   print   
               bra     skip
isparms:       eor.l   d2,d2
               move.l  d2,d0
anotherspace:  move.b  (a5)+,d0  
               cmpi.b  #$20,d0   
               dbne    d5,anotherspace

loop2:         cmpi.b  #$20,d0   
               beq     endofnumber
               subi.b  #$30,d0   
               blt     badparms  
               cmpi.b  #$9,d0
               bgt     badparms  
               mulu    #$A,d2   
               add.l   d0,d2   
               move.b  (a5)+,d0  
               dbra    d5,loop2(pc)  
endofnumber:   cmpi.l  #1600,d2  
               blt     jtoosmall
               move.l  d2,d0
               moveq.l #$1,d1   
               jsr     _LVOAllocMem(a6) 
               tst.l   d0
               beq     jtoobig   
               movea.l d0,a1   
               move.l  d2,d0   
               jsr     _LVOFreeMem(a6)  
               asr.l   #$2,d2   
               move.l  d2,cli_DefaultStack(a4)
               bra     exit  
 

dosname:       dc.b    'dos.library',0

message:       dc.b    'current stack size is '
messagelength  equ *-message

finishmessage: dc.b    ' bytes',$a
finishmessagelength equ *-finishmessage

errmessage:    dc.b    'Usage: STACK [size]',$a
errmessagelength equ *-errmessage

badsize:       dc.b    'suggested stack size too '
badsizelength  equ *-badsize

toosmall:      dc.b    'small',$a

toobig:        dc.b    'large',$a
; Sorry about the lack of comments - I prefer informative labels